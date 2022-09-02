// ShlTanya, 29.01.2019

unit dlgAddGoodGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, ActnList, gd_security, IBQuery, Db,
  IBCustomDataSet, IBStoredProc, IBUpdateSQL, GroupType_unit, IBSQL,
  IBDatabase, dmDatabase_unit, at_sql_setup, at_Container, ComCtrls;

type
  TdlgAddGoodGroup = class(TForm)
    ActionList1: TActionList;
    actSetRigth: TAction;
    ibqryGroup: TIBQuery;
    ibudGroup: TIBUpdateSQL;
    dsGroup: TDataSource;
    ibsqlGroupKey: TIBSQL;
    ibtrGroup: TIBTransaction;
    PageControl1: TPageControl;
    tsGood: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    dbmDescription: TDBMemo;
    dbcbDisabled: TDBCheckBox;
    dbeName: TDBEdit;
    dbeAlias: TDBEdit;
    btnHelp: TButton;
    btnRight: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    TabSheet1: TTabSheet;
    atContainer1: TatContainer;
    atSQLSetup: TatSQLSetup;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function AddGroup(var GroupData: TGroupData): Boolean;
    function EditGroup(var GroupData: TGroupData): Boolean;
  end;

var
  dlgAddGoodGroup: TdlgAddGoodGroup;

implementation

uses gd_security_OperationConst;

{$R *.DFM}

function TdlgAddGoodGroup.AddGroup(var GroupData: TGroupData): Boolean;
begin
  Result := False;
  try
    if not ibtrGroup.InTransaction then
      ibtrGroup.StartTransaction;
    // Вытягиваем запись
    ibqryGroup.Open;
    // Инициализация Д.О.
    // Проверка на режим. Если редактирование
    ibqryGroup.Insert;
    SetTID(ibqryGroup.FieldByName('id'), GenUniqueID);
    ibqryGroup.FieldByName('disabled').AsInteger := 0;
    ibqryGroup.FieldByName('lb').Required := False;
    ibqryGroup.FieldByName('rb').Required := False;
    ibqryGroup.FieldByName('afull').AsInteger := GroupData.AFull
    ibqryGroup.FieldByName('achag').AsInteger := GroupData.AChag;
    ibqryGroup.FieldByName('aview').AsInteger := GroupData.AView;

    if GroupData.GroupKey <> 0 then
      SetTID(ibqryGroup.FieldByName('parent'), GroupData.GroupKey);

    if ShowModal = mrOk then
    try
      ibqryGroup.Post;
      GroupData.GroupKey := GetTID(ibqryGroup.FieldByName('id'));
      GroupData.Name := ibqryGroup.FieldByName('name').AsString;
      GroupData.AFull := ibqryGroup.FieldByName('afull').AsInteger;
      GroupData.AChag := ibqryGroup.FieldByName('achag').AsInteger;
      GroupData.AView := ibqryGroup.FieldByName('aview').AsInteger;
      Result := True;
      if ibtrGroup.InTransaction then
        ibtrGroup.Commit;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
        ibqryGroup.Cancel;
        if ibtrGroup.InTransaction then
          ibtrGroup.Rollback;
      end;
    end else
    begin
      ibqryGroup.Cancel;
      if ibtrGroup.InTransaction then
        ibtrGroup.Rollback;
    end;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
    end;
  end;
end;

function TdlgAddGoodGroup.EditGroup(var GroupData: TGroupData): Boolean;
begin
  Result := False;
  try
    if not ibtrGroup.InTransaction then
      ibtrGroup.StartTransaction;
    // Вытягиваем запись
    ibqryGroup.Close;
    SetTID(ibqryGroup.ParamByName('id'), GroupData.GroupKey);
    ibqryGroup.Open;
    // Установка возможности редактирования группы товаров
    ibqryGroup.Edit;

    if ShowModal = mrOk then
    try
      ibqryGroup.Post;
      GroupData.Name := ibqryGroup.FieldByName('Name').AsString;
      Result := True;
      if ibtrGroup.InTransaction then
        ibtrGroup.Commit;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
        ibqryGroup.Cancel;
        if ibtrGroup.InTransaction then
          ibtrGroup.Rollback;
      end;
    end else
    begin
      ibqryGroup.Cancel;
      if ibtrGroup.InTransaction then
        ibtrGroup.Rollback;
    end;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TdlgAddGoodGroup.btnOkClick(Sender: TObject);
begin
  dbeName.Text := Trim(dbeName.Text);
  // Проверка имени группы
  if dbeName.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не указано наименование группы.',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    Exit;
  end;
end;

end.

