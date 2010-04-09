unit tr_dlgAddTran_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, DBCtrls, Mask, dmDatabase_unit, Db, IBCustomDataSet,
  IBDatabase, gsIBLookupComboBox, Grids, DBGrids, gsDBGrid, gsIBGrid, IBSQL,
  gd_security;

type
  TdlgAddTran = class(TForm)
    Label1: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    dbmDescription: TDBMemo;
    bOk: TButton;
    bNext: TButton;
    bCancel: TButton;
    ActionList1: TActionList;
    actOK: TAction;
    actNext: TAction;
    actCancel: TAction;
    ibdsTrType: TIBDataSet;
    dsTrType: TDataSource;
    IBTransaction: TIBTransaction;
    Label3: TLabel;
    gsibgrTrDocType: TgsIBGrid;
    ibdsTrDocType: TIBDataSet;
    dsTrDocType: TDataSource;
    Button1: TButton;
    Button2: TButton;
    actChooseDoc: TAction;
    actDelDoc: TAction;
    ibdsTrDocTypeTRTYPEKEY: TIntegerField;
    ibdsTrDocTypeDOCUMENTTYPEKEY: TIntegerField;
    ibdsTrDocTypeID: TIntegerField;
    ibdsTrDocTypePARENT: TIntegerField;
    ibdsTrDocTypeLB: TIntegerField;
    ibdsTrDocTypeRB: TIntegerField;
    ibdsTrDocTypeNAME: TIBStringField;
    ibdsTrDocTypeDESCRIPTION: TIBStringField;
    ibdsTrDocTypeAFULL: TIntegerField;
    ibdsTrDocTypeACHAG: TIntegerField;
    ibdsTrDocTypeAVIEW: TIntegerField;
    ibdsTrDocTypeDISABLED: TSmallintField;
    ibdsTrDocTypeRESERVED: TIntegerField;
    Button3: TButton;
    Button4: TButton;
    actTypeEntry: TAction;
    actCondition: TAction;
    ibdsListTrTypeCond: TIBDataSet;
    dbcbIsDocument: TDBCheckBox;
    Label4: TLabel;
    DBEdit1: TDBEdit;
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actChooseDocExecute(Sender: TObject);
    procedure actDelDocExecute(Sender: TObject);
    procedure actTypeEntryExecute(Sender: TObject);
    procedure actConditionExecute(Sender: TObject);
  private

    FID: Integer;
    FParent: Integer;
    procedure AppendNew;
    function Save: Boolean;
    procedure BeforeAction;
  public

    procedure SetupDialog(const aID, aParent: Integer);
    property ID: Integer read FID;
  end;

var
  dlgAddTran: TdlgAddTran;

implementation

{$R *.DFM}

uses tr_dlgChooseDocument_unit,
  flt_dlgShowFilter_unit, flt_sqlfilter_condition_type, tr_dlgAddTypeEntry_unit;

procedure TdlgAddTran.actOKExecute(Sender: TObject);
begin
  if not Save then
  begin
    ModalResult := mrNone;
    abort;
  end;
end;

procedure TdlgAddTran.actCancelExecute(Sender: TObject);
begin
  Close;
end;

procedure TdlgAddTran.actNextExecute(Sender: TObject);
begin
  if Save then
  begin
    AppendNew;
    dbedName.SetFocus;
  end;  
end;

procedure TdlgAddTran.SetupDialog(const aID, aParent: Integer);
begin
  FID := aID;
  FParent := aParent;
  if FID = -1 then
    AppendNew
  else
  begin
    BeforeAction;
    actNext.Enabled := False;
    ibdsTrType.Params.ByName('ID').AsInteger := FID;
    ibdsTrType.Open;

    ibdsTrDocType.Params.ByName('trtypekey').AsInteger := FID;
    ibdsTrDocType.Open;
  end;
end;

procedure TdlgAddTran.AppendNew;
begin
  BeforeAction;
  if not ibdsTrType.Active then
    ibdsTrType.Open;

  FID := GenUniqueID;

  ibdsTrType.Insert;
  ibdsTrType.FieldByName('LB').Required := False;
  ibdsTrType.FieldByName('RB').Required := False;
  ibdsTrType.FieldByName('ID').AsInteger := FID;
  if (FParent <> -1) and (FParent <> 0) then
    ibdsTrType.FieldByName('Parent').AsInteger := FParent;
  ibdsTrType.FieldByName('aFull').AsInteger := -1;
  ibdsTrType.FieldByName('aChag').AsInteger := -1;
  ibdsTrType.FieldByName('aView').AsInteger := -1;
  ibdsTrType.FieldByName('IsDocument').AsInteger := 0;
  ibdsTrType.FieldByName('companykey').AsInteger := IBLogin.CompanyKey;

  ibdsTrDocType.Close;
  ibdsTrDocType.Params.ByName('trtypekey').AsInteger := FID;
  ibdsTrDocType.Open;

end;

procedure TdlgAddTran.BeforeAction;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;
end;

function TdlgAddTran.Save: Boolean;
begin
  Result := False;
(*
   Если было введено наименование операции и нажата клавиша Enter
   или клавиша Insert то поле Наименование еще не заполенено для
   того что бы оно стало заполнено принудительно переводим фокус на
   другой контрол
*)
  if dbedName.Focused then
    dbmDescription.SetFocus;

  if ibdsTrType.FieldByName('Name').IsNull then
  begin
    MessageBox(HANDLE, 'Необходимо заполнить Наименование', 'Внимание', mb_Ok or
      mb_IconExclamation);
    dbedName.SetFocus;
    exit;
  end;

  if ibdsTrType.State in [dsEdit, dsInsert] then
    ibdsTrType.Post;

  if ibdsTrDocType.State in [dsEdit, dsInsert] then
    ibdsTrDocType.Post;

  IBTransaction.Commit;
  Result := True;
end;

procedure TdlgAddTran.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsTrDocType.State in [dsEdit, dsInsert] then
      ibdsTrDocType.Cancel;

    ibdsTrDocType.CancelUpdates;

    if ibdsTrType.State in [dsEdit, dsInsert] then
      ibdsTrType.Cancel;
      
    if IBTransaction.InTransaction then
      IBTransaction.RollBack;
  end;
end;

procedure TdlgAddTran.actChooseDocExecute(Sender: TObject);
var
  i: Integer;
begin

 { Выбор документов по операции }

  with TdlgChooseDocument.Create(Self) do
    try
      if SetupDialog(IBTransaction) then
      begin
        if ibdsTrType.State in [dsEdit, dsInsert] then
          ibdsTrType.Post;
        ibdsTrDocType.Close;
        ibdsTrDocType.Open;
        for i:= 0 to gsibgrDocumentType.CheckBox.CheckList.Count - 1 do
        begin
          ibdsTrDocType.Insert;
          ibdsTrDocType.FieldByName('trtypekey').AsInteger := FID;
          ibdsTrDocType.FieldByName('documenttypekey').AsInteger :=
            gsibgrDocumentType.CheckBox.IntCheck[i];
          try
            ibdsTrDocType.Post;
          except
            ibdsTrDocType.Cancel;
          end;
        end;
      end;
    finally
      Free;
    end;
    
end;

procedure TdlgAddTran.actDelDocExecute(Sender: TObject);
begin
  { Удаление документа из списка }
  if ibdsTrDocType.FieldByName('trtypekey').IsNull then exit;

  if MessageBox(HANDLE, PChar(Format('Удалить документ ''%s'' из списка?',
    [ibdsTrDocType.FieldByName('name').AsString])), 'Внимание',
        mb_YesNo or mb_IconQuestion) = idYes
  then
    ibdsTrDocType.Delete;
end;

procedure TdlgAddTran.actTypeEntryExecute(Sender: TObject);
begin
  if ibdsTrType.State in [dsEdit, dsInsert] then
    ibdsTrType.Post;
  with TdlgAddTypeEntry.Create(Self) do
    try
      ibdsEntry.Transaction := Self.IBTransaction;
      SetupDialog(-1, FID);
      ShowModal;
    finally
      Free;
    end;

end;

procedure TdlgAddTran.actConditionExecute(Sender: TObject);
var
  TableList: TfltStringList;
  FilterData: TFilterData;
  ibsql: TIBSQL;
  documenttypekey: Integer;
  LocBlobStream: TIBDSBlobStream;
  isAppend: Boolean;
begin
{ Добавление условия формирования операции }
  if ibdsTrDocType.FieldByName('documenttypekey').AsInteger = 0 then
    exit;

  FilterData := TFilterData.Create;
  TableList := TfltStringList.Create;
  ibsql := TIBSQL.Create(Self);
  try
    documenttypekey := ibdsTrDocType.FieldByName('documenttypekey').AsInteger;
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text :=
      Format(
        'SELECT relationname FROM gd_relationtypedoc WHERE doctypekey = %d',
        [documenttypekey]);

    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      TableList.Add(ibsql.Fields[0].AsString + '=a');
      ibsql.Next;
    end;
    ibsql.Close;

    ibdsListTrTypeCond.ParamByName('dt').AsInteger := documenttypekey;
    ibdsListTrTypeCond.ParamByName('trkey').AsInteger := FID;
    ibdsListTrTypeCond.Open;
    if ibdsListTrTypeCond.RecordCount > 0 then
    begin
      isAppend := False;
      LocBlobStream := ibdsListTrTypeCond.CreateBlobStream(ibdsListTrTypeCond.FieldByName('data'),
                 bmRead) as TIBDSBlobStream;
      try
        try
          FilterData.ConditionList.ReadFromStream(LocBlobStream);
        except
        end;
      finally
        FreeAndNil(LocBlobStream);
      end;
    end
    else
      isAppend := True;

    with TdlgShowFilter.Create(Self) do
      try
        Transaction := Self.IBTransaction;
        Database := Self.IBTransaction.DefaultDatabase;
        if ShowFilter(FilterData.ConditionList, nil, nil, TableList, nil, True) then
        begin
          if isAppend then
            Self.ibdsListTrTypeCond.Append
          else
            Self.ibdsListTrTypeCond.Edit;
          LocBlobStream :=
            Self.ibdsListTrTypeCond.CreateBlobStream(ibdsListTrTypeCond.FieldByName('data'),
               bmWrite) as TIBDSBlobStream;
          try
            if isAppend then
            begin
              Self.ibdsListTrTypeCond.FieldByName('ID').AsInteger := GenUniqueID;
              Self.ibdsListTrTypeCond.FieldByName('listtrtypekey').AsInteger := FID;
              Self.ibdsListTrTypeCond.FieldByName('documenttypekey').AsInteger :=
                documenttypekey;
            end;
            FilterData.ConditionList.WriteToStream(LocBlobStream);
            ibdsListTrTypeCond.FieldByName('textcondition').AsString :=
              FilterData.FilterText;
          finally
            FreeAndNil(LocBlobStream);
          end;
          ibdsListTrTypeCond.Post;
          ibdsListTrTypeCond.Close;
        end;
      finally
        Free;
      end;

  finally
    FilterData.Free;
    TableList.Free;
    ibsql.Free;
  end;
end;

end.
