// ShlTanya, 10.02.2019, #4135

{++
   Project GDReference
   Copyright � 2000- by Golden Software

   ������

     gd_dlgViewAttrElement_unit

   ��������

     ���� ��� �������������� ���������� � �������� �������� ���������

   �����

     Kornachenko Nikolai

   �������

     ver    date    who    what
     1.00 - 14.06.2000 - NK - ������ ������

 --}

unit gd_dlgAttrElement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, ExtCtrls, IBCustomDataSet, IBUpdateSQL, Db,
  IBQuery, IBSQL, ActnList, gd_security, IBDatabase, gdcBaseInterface;

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
    FParent: TID;
    FAttrKey: TID;
    procedure CheckDatabase;
  public
    KeyList: TStringList;
    Text: String;
    destructor Destroy; override;
    procedure SetDatabase(const Database: TIBDatabase; const Transaction: TIBTransaction);
    function AddElement(const AnAttrKey: TID): Boolean; overload;
    function AddElement(const AnAttrKey: TID; const AParent: TID): Boolean; overload;
    function EditElement(const AKey: TID): Boolean;
//    function EditElement(const ARefValueKey: Integer; const AnAttrKey: Integer): Boolean; overload;
    function DeleteElement(const AKey: TID): Boolean; overload;
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
  //��������� ����� ������
  qryAttrSet.Open;
  qryAttrSet.Insert;
  SetTID(qryAttrSet.FieldByName('attrkey'), FAttrKey);
  qryAttrSet.FieldByName('afull').AsInteger := -1;
  qryAttrSet.FieldByName('achag').AsInteger := -1;
  qryAttrSet.FieldByName('aview').AsInteger := -1;
  ibsqlGenUniqueID.ExecQuery; // �� ���������� dmDatabase
  SetTID(qryAttrSet.FieldByName('id'), ibsqlGenUniqueID.Fields[0]);

  if FParent > -1 then
    SetTID(qryAttrSet.FieldByName('parent'), FParent)
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
    KeyList.AddObject(dbeName.Text, TID2Pointer(GetTID(qryAttrSet.FieldByName('ID')), Name));
  end;
end;

//���������� ����������� ���������
function Tgd_dlgAttrElement.AddElement(const AnAttrKey: TID; const AParent: TID): Boolean;
begin
  CheckDatabase;
  FParent := AParent;
  FAttrKey := AnAttrKey;
  aNew.Visible := True;
  if not qryAttrSet.Transaction.InTransaction then
    qryAttrSet.Transaction.StartTransaction;
  qryAttribute.Close;
  SetTID(qryAttribute.ParamByName('Key'), AnAttrKey);
  qryAttribute.Open;
  if qryAttribute.RecordCount > 0 then
  if qryAttribute.FieldByName('refkey').IsNull then
  begin
    AddNextElement;
  end
  else
  begin
    ShowMessage('���������� �������� �������� � ��������� ����������.');
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

{ TODO -o������ -c������� :
������ ���, � ���� �� ������� ������ ��-�� ������������� �������������,
���� �������� �� ��������� ������ }

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

//���������� �������� ���������
function Tgd_dlgAttrElement.AddElement(const AnAttrKey: TID): Boolean;
begin
  Result := AddElement(AnAttrKey, -1);
end;

//�������������� �������� ��������� �� refkey � attrkey
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

//�������������� �������� ���������
function Tgd_dlgAttrElement.EditElement(const AKey: TID): Boolean;
begin
  CheckDatabase;
  aNew.Visible := False;
  Result := False;
  if not qryAttrSet.Transaction.InTransaction then
    qryAttrSet.Transaction.StartTransaction;

  qryAttrSet.Close;
  SetTID(qryAttrSet.ParamByName('id'), AKey);
  qryAttrSet.Open;

  qryAttribute.Close;
  SetTID(qryAttribute.ParamByName('Key'), qryAttrSet.FieldByName('attrkey'));
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
      ShowMessage('���������� ������������� �������� ���������� �����������.');
    end;
  end;
end;

//�������� �������� ��������� �� ���� � ����������� � ���� ��������
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

//�������� �������� ���������
function Tgd_dlgAttrElement.DeleteElement(const AKey: TID): Boolean;
begin
  CheckDatabase;

  Result := False;

  if MessageDlg('������� ������� �����������?',
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  begin
    if not qryAttrSet.Transaction.InTransaction then
      qryAttrSet.Transaction.StartTransaction;

    qryAttrSet.Close;
    SetTID(qryAttrSet.ParamByName('id'), AKey);
    qryAttrSet.Open;

    qryChildren.Close;
    SetTID(qryChildren.ParamByName('akey'), qryAttrSet.FieldByName('attrkey'));
    SetTID(qryChildren.ParamByName('id'), AKey);
    qryChildren.Open;
    if qryChildren.RecordCount > 0 then
    begin
      ShowMessage('���������� ������� �������, ��� ��� �� ����� ��������� ��������.');
      Exit;
    end;
    qryAttribute.Close;
    SetTID(qryAttribute.ParamByName('Key'), qryAttrSet.FieldByName('attrkey'));
    qryAttribute.Open;

    if qryAttribute.RecordCount > 0 then
    if qryAttribute.FieldByName('refkey').IsNull then
    begin
      if not ibsqlDelete.Transaction.InTransaction then
        ibsqlDelete.Transaction.StartTransaction;
      try
        ibsqlDelete.Close;
        ibsqlDelete.SQL.Text := 'DELETE FROM gd_attrset ' +
                                ' WHERE id = ' + TID2S(AKey);
        ibsqlDelete.ExecQuery;
        ibsqlDelete.Transaction.CommitRetaining;
        Result := True;
      except
        on E: Exception do
        begin
          ShowMessage('���������� ������� �������.');
        end
      end;
    end
    else
      ShowMessage('���������� ������� ������� ���������� �����������.');
  end;
end;

//���������� ����������� ���������
procedure Tgd_dlgAttrElement.btnOkClick(Sender: TObject);
begin
  dbeName.Text := Trim(dbeName.Text);
  Text := dbeName.Text;
  if dbeName.Text = '' then
  begin
    ShowMessage('���������� ������ ������������.');
    dbeName.SetFocus;
    ModalResult := mrNone;
    exit;
  end;
  qryAttrSet.Post;
  qryAttrSet.Transaction.CommitRetaining;
end;

procedure Tgd_dlgAttrElement.aNewExecute(Sender: TObject);
begin
  KeyList.AddObject(dbeName.Text, TID2Pointer(GetTID(qryAttrSet.FieldByName('ID')), Name));
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

destructor Tgd_dlgAttrElement.Destroy;
begin
  {$IFDEF ID64}
  FreeConvertContext(Name);
  {$ENDIF}
  inherited;
end;

end.
