{++
   Project GDReference
   Copyright © 2000- by Golden Software

   Модуль

     gd_dlgViewAttrElement_unit

   Описание

     Окно для редактирования добавления и удаления элемента множества

   Автор

     Kornachenko Nikolai

   История

     ver    date    who    what
     1.00 - 14.06.2000 - NK - Первая версия

 --}

unit gd_dlgAttrElement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, ExtCtrls, IBCustomDataSet, IBUpdateSQL, Db,
  IBQuery, IBSQL, ActnList, gd_security, IBDatabase;

type
  Tgd_dlgAttrElement = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    dbeName: TDBEdit;
    btnOk: TButton;
    Button2: TButton;
    dsAttrSet: TDataSource;
    qryAttrSet: TIBQuery;
    ibuAttrSet: TIBUpdateSQL;
    cbDisabled: TCheckBox;
    qryAttribute: TIBQuery;
    ibsqlDelete: TIBSQL;
    qryChildren: TIBQuery;
    Button3: TButton;
    ActionList1: TActionList;
    aNew: TAction;
    btnAccess: TButton;
    ibsqlGenUniqueID: TIBSQL;

    procedure btnOkClick(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FParent: Integer;
    FAttrKey: Integer;
    procedure CheckDatabase;
  public
    KeyList: TStringList;
    Text: String;
    procedure SetDatabase(const Database: TIBDatabase; const Transaction: TIBTransaction);
    function AddElement(const AnAttrKey: Integer): Boolean; overload;
    function AddElement(const AnAttrKey: Integer; const AParent: Integer): Boolean; overload;
    function EditElement(const AKey: Integer): Boolean;
//    function EditElement(const ARefValueKey: Integer; const AnAttrKey: Integer): Boolean; overload;
    function DeleteElement(const AKey: Integer): Boolean; overload;
//    function DeleteElement(const ARefValueKey: Integer; const AnAttrKey: Integer): Boolean; overload;
    procedure AddNextElement;
  end;

var
  gd_dlgAttrElement: Tgd_dlgAttrElement;

implementation

{$R *.DFM}

uses
  gd_security_OperationConst;

procedure Tgd_dlgAttrElement.AddNextElement;
begin
  CheckDatabase;
  //Добавляем новую запись
  qryAttrSet.Open;
  qryAttrSet.Insert;
  qryAttrSet.FieldByName('attrkey').AsInteger := FAttrKey;
  qryAttrSet.FieldByName('afull').AsInteger := -1;
  qryAttrSet.FieldByName('achag').AsInteger := -1;
  qryAttrSet.FieldByName('aview').AsInteger := -1;
  ibsqlGenUniqueID.ExecQuery; // Не подключать dmDatabase
  qryAttrSet.FieldByName('id').AsInteger := ibsqlGenUniqueID.Fields[0].AsInteger;

  if FParent > -1 then
    qryAttrSet.FieldByName('parent').AsInteger := FParent
  else
    qryAttrSet.FieldByName('parent').Clear;

  if cbDisabled.Checked then
    qryAttrSet.FieldByName('disabled').AsInteger := 1
  else
    qryAttrSet.FieldByName('disabled').AsInteger := 0;

//  qryAttrSet.FieldByName('refvaluekey').AsInteger := qryNewAttrSet.FieldByName('V').AsInteger;

  if not Self.Visible then
  if ShowModal = mrOk then
  begin
    KeyList.AddObject(dbeName.Text,Pointer(qryAttrSet.FieldByName('ID').AsInteger));
  end;
end;

//Добавление подэлемента множества
function Tgd_dlgAttrElement.AddElement(const AnAttrKey: Integer; const AParent: Integer): Boolean;
begin
  CheckDatabase;
  FParent := AParent;
  FAttrKey := AnAttrKey;
  aNew.Visible := True;
  if not qryAttrSet.Transaction.InTransaction then
    qryAttrSet.Transaction.StartTransaction;
  qryAttribute.Close;
  qryAttribute.ParamByName('Key').AsInteger := AnAttrKey;
  qryAttribute.Open;
  if qryAttribute.RecordCount > 0 then
  if qryAttribute.FieldByName('refkey').IsNull then
  begin
    AddNextElement;
  end
  else
  begin
    ShowMessage('Невозможно добавить элементы в указанный справочник.');
  end;
  if KeyList.Count > 0 then
    Result := True
  else
    Result := False;
end;

procedure Tgd_dlgAttrElement.CheckDatabase;
begin
  //!!!

  Assert(False);

{ TODO -oандрэй -cпамылка :
старый код, к тому же выкинет ошибку из-за использования ДефТранзакции,
надо выкинуть из финальной версии }

  if (ibsqlGenUniqueID.Database = nil) or (ibsqlGenUniqueID.Transaction = nil) then
    if (IBLogin.Database <> nil) and (IBLogin.Database.DefaultTransaction <> nil) then
      SetDatabase(IBLogin.Database, IBLogin.Database.DefaultTransaction);
end;

procedure Tgd_dlgAttrElement.SetDatabase(const Database: TIBDatabase; const Transaction: TIBTransaction);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TIBQuery) then
    begin
      (Components[I] as TIBQuery).Database := Database;
      (Components[I] as TIBQuery).Transaction := Transaction;
    end else
      if (Components[I] is TIBDataSet) then
      begin
        (Components[I] as TIBDataSet).Database := Database;
        (Components[I] as TIBDataSet).Transaction := Transaction;
      end else
        if (Components[I] is TIBSQL) then
        begin
          (Components[I] as TIBSQL).Database := Database;
          (Components[I] as TIBSQL).Transaction := Transaction;
        end;
end;

//Добавление элемента множества
function Tgd_dlgAttrElement.AddElement(const AnAttrKey: Integer): Boolean;
begin
  Result := AddElement(AnAttrKey, -1);
end;

//Редактирование элемента множества по refkey и attrkey
{function Tgd_dlgAttrElement.EditElement(const ARefValueKey: Integer; const AnAttrKey: Integer): Boolean;
begin
  ibsqlDelete.Close;
  ibsqlDelete.SQL.Text := 'SELECT id FROM gd_attrset ' +
                          ' WHERE (refvaluekey = ' + IntToStr(ARefValueKey) + ') ' +
                          '   AND (attrkey = ' + IntToStr(AnAttrKey) + ')';
  ibsqlDelete.ExecQuery;
  Result := False;
  if ibsqlDelete.RecordCount > 0 then
    Result := EditElement(ibsqlDelete.FieldByName('id').AsInteger);

end;}

//Редактирование элемента множества
function Tgd_dlgAttrElement.EditElement(const AKey: Integer): Boolean;
begin
  CheckDatabase;
  aNew.Visible := False;
  Result := False;
  if not qryAttrSet.Transaction.InTransaction then
    qryAttrSet.Transaction.StartTransaction;

  qryAttrSet.Close;
  qryAttrSet.ParamByName('id').AsInteger := AKey;
  qryAttrSet.Open;

  qryAttribute.Close;
  qryAttribute.ParamByName('Key').AsInteger := qryAttrSet.FieldByName('attrkey').AsInteger;
  qryAttribute.Open;
  if qryAttribute.RecordCount > 0 then
  begin
    if qryAttribute.FieldByName('refkey').IsNull then
    begin
      cbDisabled.Checked := qryAttrSet.FieldByName('disabled').AsInteger = 1;
      qryAttrSet.Edit;
      Result := True;
      if ShowModal <> mrOk then
      begin
        qryAttrSet.RevertRecord;
        Result := False;
      end
      else
      begin
        qryAttrSet.Edit;
        if cbDisabled.Checked then
          qryAttrSet.FieldByName('disabled').AsInteger := 1
        else
          qryAttrSet.FieldByName('disabled').AsInteger := 0;
        qryAttrSet.Post;
      end;
    end
    else
    begin
      ShowMessage('Невозможно редактировать элементы указанного справочника.');
    end;
  end;
end;

//Удаление элемента множества по коду в справочнике и коду атрибута
{function Tgd_dlgAttrElement.DeleteElement(const ARefValueKey: Integer; const AnAttrKey: Integer): Boolean;
begin
  ibsqlDelete.Close;
  ibsqlDelete.SQL.Text := 'SELECT id FROM gd_attrset ' +
                          ' WHERE (refvaluekey = ' + IntToStr(ARefValueKey) + ') ' +
                          '   AND (attrkey = ' + IntToStr(AnAttrKEy) + ')';
  ibsqlDelete.ExecQuery;
  Result := False;
  if ibsqlDelete.RecordCount > 0 then
    Result := DeleteElement(ibsqlDelete.FieldByName('id').AsInteger);
end;}

//Удаление элемента множества
function Tgd_dlgAttrElement.DeleteElement(const AKey: Integer): Boolean;
begin
  CheckDatabase;

  Result := False;

  if MessageDlg('Удалить элемент справочника?',
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  begin
    if not qryAttrSet.Transaction.InTransaction then
      qryAttrSet.Transaction.StartTransaction;

    qryAttrSet.Close;
    qryAttrSet.ParamByName('id').AsInteger := AKey;
    qryAttrSet.Open;

    qryChildren.Close;
    qryChildren.ParamByName('akey').AsInteger := qryAttrSet.FieldByName('attrkey').AsInteger;
    qryChildren.ParamByName('id').AsInteger := AKey;
    qryChildren.Open;
    if qryChildren.RecordCount > 0 then
    begin
      ShowMessage('Невозможно удалить элемент, так как он имеет вложенные элементы.');
      Exit;
    end;
    qryAttribute.Close;
    qryAttribute.ParamByName('Key').AsInteger := qryAttrSet.FieldByName('attrkey').AsInteger;
    qryAttribute.Open;

    if qryAttribute.RecordCount > 0 then
    if qryAttribute.FieldByName('refkey').IsNull then
    begin
      if not ibsqlDelete.Transaction.InTransaction then
        ibsqlDelete.Transaction.StartTransaction;
      try
        ibsqlDelete.Close;
        ibsqlDelete.SQL.Text := 'DELETE FROM gd_attrset ' +
                                ' WHERE id = ' + IntToStr(AKey);
        ibsqlDelete.ExecQuery;
        ibsqlDelete.Transaction.CommitRetaining;
        Result := True;
      except
        on E: Exception do
        begin
          ShowMessage('Невозможно удалить элемент.');
        end
      end;
    end
    else
      ShowMessage('Невозможно удалить элемент указанного справочника.');
  end;
end;

//Сохранение результатов изменения
procedure Tgd_dlgAttrElement.btnOkClick(Sender: TObject);
begin
  dbeName.Text := Trim(dbeName.Text);
  Text := dbeName.Text;
  if dbeName.Text = '' then
  begin
    ShowMessage('Необходимо ввести наименование.');
    dbeName.SetFocus;
    ModalResult := mrNone;
    exit;
  end;
  qryAttrSet.Post;
  qryAttrSet.Transaction.CommitRetaining;
end;

procedure Tgd_dlgAttrElement.aNewExecute(Sender: TObject);
begin
  KeyList.AddObject(dbeName.Text,Pointer(qryAttrSet.FieldByName('ID').AsInteger));
  ModalResult := mrOk;
  btnOkClick(btnOk);
  ModalResult := mrNone;
  AddNextElement;
end;

procedure Tgd_dlgAttrElement.FormCreate(Sender: TObject);
begin
  KeyList := TStringList.Create;
end;

procedure Tgd_dlgAttrElement.FormDestroy(Sender: TObject);
begin
    KeyList.Free;
end;

end.
