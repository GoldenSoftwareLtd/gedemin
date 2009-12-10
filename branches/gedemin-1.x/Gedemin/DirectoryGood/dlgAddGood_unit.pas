unit dlgAddGood_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, ActnList, gd_security, Db, IBCustomDataSet,
  IBUpdateSQL, IBQuery, IBStoredProc, GroupType_unit, ComCtrls,
  ExtCtrls, IBDatabase, dmDatabase_unit, gsIBLookupComboBox,
  Grids, DBGrids, gsDBGrid, gsIBGrid, IBSQL, Buttons,
  at_sql_setup, gsIBCtrlGrid, xDateEdits;

type
  TdlgAddGood = class(TForm)
    pcGood: TPageControl;
    tsOption: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    dbeName: TDBEdit;
    dbmDescription: TDBMemo;
    dbeBarCode: TDBEdit;
    dbeAlias: TDBEdit;
    ActionList: TActionList;
    actSetRight: TAction;
    actNew: TAction;
    actAddValue: TAction;
    actAddTNVD: TAction;
    dsGood: TDataSource;
    tsAttribute: TTabSheet;
    tsValue: TTabSheet;
    tsPrMetal: TTabSheet;
    tsBarCode: TTabSheet;
    actShowBarCode: TAction;
    actAddBarCode: TAction;
    actEditBarCode: TAction;
    actDelBarCode: TAction;
    actAddPrMetal: TAction;
    actDelPrMetal: TAction;
    actShowPrMetal: TAction;
    Panel1: TPanel;
    Button6: TButton;
    Button8: TButton;
    Panel2: TPanel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    actAddTax: TAction;
    Panel4: TPanel;
    Button11: TButton;
    Button13: TButton;
    actSetValue: TAction;
    actDelValue: TAction;
    actShowValue: TAction;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    ibtrGood: TIBTransaction;
    dblcbTNVD: TgsIBLookupComboBox;
    dsTax: TDataSource;
    gsIbgrValues: TgsIBGrid;
    dsValues: TDataSource;
    gsibgrPrMetal: TgsIBGrid;
    dsSelPrMetal: TDataSource;
    gdibgrBarCode: TgsIBGrid;
    dsBarCode: TDataSource;
    ibdsBarCode: TIBDataSet;
    ibdsGoodPrMetal: TIBDataSet;
    ibdsSelValue: TIBDataSet;
    ibdsSelTax: TIBDataSet;
    actDelTax: TAction;
    ibdsGood: TIBDataSet;
    ibsqlNewGood: TIBSQL;
    ibsqlNewBarCode: TIBSQL;
    Panel5: TPanel;
    btnRight: TButton;
    btnNew: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    gsibgrTax: TgsIBCtrlGrid;
    Label5: TLabel;
    Button5: TButton;
    Button10: TButton;
    dbcbSet: TDBCheckBox;
    actNewAll: TAction;
    Label6: TLabel;
    dblcbValue: TgsIBLookupComboBox;
    sbAddValue: TSpeedButton;
    sbAddTNVD: TSpeedButton;
    actTaxSelect: TAction;
    atSQLSetup: TatSQLSetup;
    SpeedButton1: TSpeedButton;
    dbcbDisabled: TDBCheckBox;
    Label8: TLabel;
    dbedShortName: TDBEdit;
    ddbeDateTax: TxDateDBEdit;
    gsiblcTax: TgsIBLookupComboBox;
    procedure btnOkClick(Sender: TObject);
    procedure actViewValueUpdate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actAddTNVDExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actAddBarCodeExecute(Sender: TObject);
    procedure actEditBarCodeExecute(Sender: TObject);
    procedure actDelBarCodeExecute(Sender: TObject);
    procedure actAddPrMetalExecute(Sender: TObject);
    procedure actDelPrMetalExecute(Sender: TObject);
    procedure actDelTaxExecute(Sender: TObject);
    procedure actSetValueExecute(Sender: TObject);
    procedure actDelValueExecute(Sender: TObject);
    procedure pcGoodChange(Sender: TObject);
    procedure dblcbValueExit(Sender: TObject);
    procedure gdibgrBarCodeDblClick(Sender: TObject);
    procedure ibdsGoodPrMetalBeforePost(DataSet: TDataSet);
    procedure actAddTaxExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actAddValueExecute(Sender: TObject);
    procedure dblcbTNVDExit(Sender: TObject);
    procedure actNewAllExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actEditBarCodeUpdate(Sender: TObject);
    procedure actDelBarCodeUpdate(Sender: TObject);
    procedure actDelPrMetalUpdate(Sender: TObject);
    procedure actDelValueUpdate(Sender: TObject);
    procedure actDelTaxUpdate(Sender: TObject);
    procedure actTaxSelectExecute(Sender: TObject);
    procedure dbeNameChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure gsiblcTaxExit(Sender: TObject);
    procedure ibdsSelTaxAfterPost(DataSet: TDataSet);
    procedure ibdsSelTaxAfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
    FGoodKey: Integer;
    FGroupKey: Integer;
    isOk: Boolean;

    FNewGoodTax: Boolean;
    FNewGoodValue: Boolean;
    FNewGoodPrMetal: Boolean;
    FNewGoodBarCode: Boolean;

    procedure OpenTax;
    procedure OpenValue;
    procedure OpenPrMetal;
    procedure OpenBarCode;

    procedure PrepareNewGood(const aGroupKey: Integer);   // Подготовка для ввода нового товара
    procedure ClearFlag;
    procedure TAXKEYChange(Sender: TField);
    function SaveGood(IsNext: Boolean): Boolean;
  public
    { Public declarations }
    function AddGood(const aGroupKey: Integer): Boolean; // Добавляем товар
    function EditGood(const aGoodKey: Integer): Boolean;     // Редактируем товар

    property GoodKey: Integer read FGoodKey;
  end;

var
  dlgAddGood: TdlgAddGood;

implementation

{$R *.DFM}

uses
     gd_security_OperationConst, Storages,
     dlgSetParam_unit, dlgSelectPrMetal_unit,
     dlgSelectTax_unit, dlgSetParamTax_unit,
     dlgSelectValue_unit, dlgFindGood_unit,
     dlgChooseGroup_unit, dlgAddValue_unit;


procedure TdlgAddGood.PrepareNewGood(const aGroupKey: Integer);
var
  ValKey: Integer;
  ibsql: TIBSQL;
begin
  // Процедура подготовки нового товара
  if not ibdsGood.Transaction.InTransaction then
    ibdsGood.Transaction.StartTransaction;

  ibdsGood.Close;

  FGoodKey := GenUniqueID;

  if FGroupKey <= 0 then
    FGroupKey := GlobalStorage.ReadInteger('defaultgood', 'defaultgroup', -1);

  if FGroupKey <= 0 then
  begin
    with TdlgChooseGroup.Create(Self) do
      try
        Caption := 'Выбор группы ТМЦ';
        if ActiveDialog(ibdsGood.Transaction) then
          FGroupKey := GroupKey;
      finally
        Free;
      end;
  end;

  if FGroupKey <= 0 then
    abort;

  ValKey := GlobalStorage.ReadInteger('defaultgood', 'defaultvaluekey', 0);
  if ValKey <= 0 then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := ibdsGood.Transaction;
      ibsql.SQL.Text := 'SELECT MIN(id) FROM gd_value';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
        ValKey := ibsql.Fields[0].AsInteger;
    finally
      ibsql.Free;
    end;

    if ValKey <= 0 then
    begin
      with TdlgAddValue.Create(Self) do
        try
          ActiveDialog(-1);
          if ShowModal = mrOk then
            ValKey := ValueKey;
        finally
          Free;
        end;
    end;
    if ValKey <= 0 then
    begin
      MessageBox(HANDLE, 'Для добавления ТМЦ необходима ед.изм.', 'Внимание',
        mb_Ok or mb_IconInformation);
      abort;
    end;
    GlobalStorage.WriteInteger('defaultgood', 'defaultvaluekey', ValKey);
  end;

  ibsqlNewGood.SQL.Clear;
  ibsqlNewGood.SQL.Add(Format('INSERT INTO gd_good(id, groupkey, name, valuekey, isassembly) ' +
    'VALUES(%d, %d, '''', %d, 0)',
    [FGoodKey, FGroupKey, ValKey]));
  ibsqlNewGood.ExecQuery;
  ibsqlNewGood.Close;

  ibdsGood.Params.ByName('ID').AsInteger := FGoodKey;
  ibdsGood.Open;

  ClearFlag;
  OpenTax;

  pcGood.ActivePage := tsOption;
end;

function TdlgAddGood.AddGood(const aGroupKey: Integer): Boolean;
begin
  // Добавление нового товара
  FGroupKey := aGroupKey;
  PrepareNewGood(FGroupKey);
  Result := (ShowModal = mrOk) or isOk;
end;

function TdlgAddGood.EditGood(const aGoodKey: Integer): Boolean;
begin
  // Редактирование товара
  btnNew.Visible := False;
  actNew.Enabled := False;

  if not ibdsGood.Transaction.InTransaction then
    ibdsGood.Transaction.StartTransaction;

  FGoodKey := aGoodKey;

  ClearFlag;

  ibdsGood.Close;
  ibdsGood.Prepare;
  ibdsGood.Params.ByName('id').AsInteger := FGoodKey;
  ibdsGood.Open;
  Caption := 'ТМЦ: ' + dbeName.Text;

  OpenTax;
  Result := ShowModal = mrOk;
end;

procedure TdlgAddGood.btnOkClick(Sender: TObject);
begin
  if not SaveGood(False) then
  begin
    ModalResult := mrNone;
    abort;
  end;
end;

procedure TdlgAddGood.actViewValueUpdate(Sender: TObject);
begin
  // Устанавливаем возможность добавления доп. ед. изм.
  (Sender as TAction).Enabled := not ibdsGood.FieldByName('valuekey').IsNull;
end;

procedure TdlgAddGood.actNewExecute(Sender: TObject);
begin
  // Добавление следующего товара
  if SaveGood(True) then
    PrepareNewGood(FGroupKey);
  dbeName.SetFocus;
end;

procedure TdlgAddGood.actAddTNVDExecute(Sender: TObject);
begin
  with TdlgSetParam.Create(Self) do
    try
      ParamName := dblcbTNVD.Text;
      Caption := 'Добавление кода ТНВД';
      if ShowModal = mrOK then
      begin
        ibsqlNewGood.Transaction := ibdsGood.Transaction;
        ibsqlNewGood.SQL.Clear;
        ibsqlNewGood.SQL.Add(Format('INSERT INTO gd_tnvd(name, description)'+
        ' VALUES(''%s'', ''%s'')', [ParamName, Description]));
        ibsqlNewGood.ExecQuery;
        ibsqlNewGood.Close;
        dblcbTNVD.Text := ParamName;
        dblcbTNVD.DoLookup;
      end;
    finally
      Free;
    end;
end;

procedure TdlgAddGood.FormCreate(Sender: TObject);
var
  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;
begin
  isOk := False;
  UserStorage.LoadComponent(gdibgrBarCode, gdibgrBarCode.LoadFromStream);
  UserStorage.LoadComponent(gsibgrPrMetal, gsibgrPrMetal.LoadFromStream);
  UserStorage.LoadComponent(gsIbgrValues, gsIbgrValues.LoadFromStream);
  UserStorage.LoadComponent(gsibgrTax, gsibgrTax.LoadFromStream);

  OldOnExit := ddbeDateTax.OnExit;
  OldOnKeyDown := ddbeDateTax.OnKeyDown;
  gsibgrTax.AddControl('DATETAX', ddbeDateTax, OldOnExit, OldOnKeyDown);
  ddbeDateTax.OnExit := OldOnExit;
  ddbeDateTax.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcTax.OnExit;
  OldOnKeyDown := gsiblcTax.OnKeyDown;
  gsibgrTax.AddControl('NAME', gsiblcTax, OldOnExit, OldOnKeyDown);
  gsiblcTax.OnExit := OldOnExit;
  gsiblcTax.OnKeyDown := OldOnKeyDown;

  pcGood.ActivePage := tsOption;
  ActiveControl := dbeName;
end;

procedure TdlgAddGood.actAddBarCodeExecute(Sender: TObject);
begin

  with TdlgSetParam.Create(Self) do
    try
      Caption := 'Добавление штрих кода';
      if ShowModal = mrOk then
      begin
        ibdsBarCode.Insert;
        ibdsBarCode.FieldByName('ID').AsInteger := GenUniqueID;
        ibdsBarCode.FieldByName('goodkey').AsInteger := FGoodKey;
        ibdsBarCode.FieldByName('BarCode').AsString := ParamName;
        ibdsBarCode.FieldByName('Description').AsString := Description;
        ibdsBarCode.Post;
      end;
    finally
      Free;
    end;

end;

procedure TdlgAddGood.actEditBarCodeExecute(Sender: TObject);
begin
  if ibdsBarCode.FieldByName('BarCode').AsString > '' then
  begin
    with TdlgSetParam.Create(Self) do
      try
        Caption := 'Редактирование штрих кода';
        ParamName := ibdsBarCode.FieldByName('BarCode').AsString;
        Description := ibdsBarCode.FieldByName('Description').AsString;
        if ShowModal = mrOk then
        begin
          if not (ibdsBarCode.State in [dsEdit, dsInsert]) then
            ibdsBarCode.Edit;
          ibdsBarCode.FieldByName('BarCode').AsString := ParamName;
          ibdsBarCode.FieldByName('Description').AsString := Description;
          ibdsBarCode.Post;
        end;
      finally
        Free;
      end;
  end;
end;

procedure TdlgAddGood.actDelBarCodeExecute(Sender: TObject);
begin
  if MessageBox(HANDLE, PChar(Format('Удалить штрих-код %s?', [ibdsBarCode.FieldByName('barcode').AsString])), 'Внимание',
     mb_YesNo or mb_IconInformation) = idYes
  then
    ibdsBarCode.Delete;
end;

procedure TdlgAddGood.actAddPrMetalExecute(Sender: TObject);
begin
  with TdlgSelectPrMetal.Create(Self) do
  try
    ibdsPrMetal.Transaction := ibdsGoodPrMetal.Transaction;
    if ActiveDialog(FGoodKey, True) then
    begin
      ibdsGoodPrMetal.Close;
      ibdsGoodPrMetal.Open;
    end;
  finally
    Free;
  end;
end;

procedure TdlgAddGood.actDelPrMetalExecute(Sender: TObject);
begin
  if MessageBox(HANDLE, PChar(Format('Удалить драгметалл ''%s''?', [ibdsGoodPrMetal.FieldByName('name').AsString])),
    'Внимание', mb_YesNo or mb_IconQuestion) = idYes then
    ibdsGoodPrMetal.Delete;
end;

procedure TdlgAddGood.actDelTaxExecute(Sender: TObject);
begin
  // Удаление у товара налога
  if ibdsSelTax.FieldByName('GoodKey').IsNull then exit;

  if MessageBox(HANDLE, PChar(Format('Удалить налог ''%s'' из списка?', [ibdsSelTax.FieldByName('name').AsString])),
    'Внимание',
     mb_YesNo or mb_IconQuestion) = idYes
  then
    ibdsSelTax.Delete;
end;

procedure TdlgAddGood.actSetValueExecute(Sender: TObject);
begin
  if ibdsGood.FieldByName('valuekey').IsNull then
  begin
    MessageBox(Self.Handle, 'Не выбрана базовая единица измерения',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  with TdlgSelectValue.Create(Self) do
  begin
    try
      ibdsValues.Transaction := ibdsSelValue.Transaction;
      if ActiveDialog(FGoodKey, True) then
      begin
        ibdsSelValue.Close;
        ibdsSelValue.Open;
      end;
    finally
      Free;
    end;
  end;

end;

procedure TdlgAddGood.actDelValueExecute(Sender: TObject);
begin
  if ibdsSelValue.FieldByName('GoodKey').IsNull then exit;

  if MessageBox(HANDLE, PChar(Format('Удалить единицу измерения ''%s''?', [ibdsSelValue.FieldByName('name').AsString])),
    'Внимание',
    mb_YesNo or mb_IconQuestion) = idYes
  then
    ibdsSelValue.Delete;
end;

procedure TdlgAddGood.pcGoodChange(Sender: TObject);
begin
  if (pcGood.ActivePage = tsValue) then
    OpenValue
  else
    if (pcGood.ActivePage = tsPrMetal) then
      OpenPrMetal
    else
      if (pcGood.ActivePage = tsBarCode) then
        OpenBarCode;
end;

procedure TdlgAddGood.dblcbValueExit(Sender: TObject);
begin
  if dblcbValue.Text > '' then
  begin

    if dblcbValue.CurrentKey = '' then
      dblcbValue.DoLookup;

    if dblcbValue.CurrentKey = '' then
    begin
      MessageBox(HANDLE, 'Неверно указано значение ед.изм.', 'Внимание', mb_Ok or mb_IconInformation);
      dblcbValue.SetFocus;
      abort;
    end;

  end;
end;

procedure TdlgAddGood.dblcbTNVDExit(Sender: TObject);
begin
  if (dblcbTNVD.Text > '') then
  begin

    if dblcbTNVD.CurrentKey = '' then
      dblcbTNVD.DoLookup;

    if dblcbTNVD.CurrentKey = '' then
    begin
      MessageBox(HANDLE, 'Неверно указано значение кода ТНВД', 'Внимание', mb_Ok or mb_IconInformation);
      dblcbTNVD.SetFocus;
      abort;
    end;

  end;

end;

procedure TdlgAddGood.gdibgrBarCodeDblClick(Sender: TObject);
begin
  actEditBarCode.Execute;
end;

procedure TdlgAddGood.ibdsGoodPrMetalBeforePost(DataSet: TDataSet);
begin
  if ibdsGoodPrMetal.FieldByName('GoodKey').IsNull then
    ibdsGoodPrMetal.Cancel;
end;

procedure TdlgAddGood.actAddTaxExecute(Sender: TObject);
begin
  with TdlgSelectTax.Create(Self) do
    try
      ibdsTax.Transaction := ibdsSelTax.Transaction;
      if ActiveDialog(FGoodKey, True) then
      begin
        ibdsSelTax.Close;
        ibdsSelTax.Open;
      end;
    finally
      Free;
    end;
end;

function TdlgAddGood.SaveGood(IsNext: Boolean): Boolean;
begin
  Result := False;

  // Проверка на наличие наименование товара
  if ibdsGood.FieldByName('Name').AsString = '' then
  begin
    MessageBox(Handle, 'Не указано наименование товара',
        'Внимание', MB_OK or MB_ICONINFORMATION);
    dbeName.SetFocus;
    Exit;
  end;


  if ibdsGood.FieldByName('valuekey').IsNull then
  begin
    MessageBox(Handle, 'Не указана единица измерения',
        'Внимание', MB_OK or MB_ICONINFORMATION);
    dblcbValue.SetFocus;
    Exit;
  end;

  if ibdsGood.FieldByName('ShortName').AsString = '' then
  begin
    if not (ibdsGood.State in [dsEdit, dsInsert]) then
      ibdsGood.Edit;
    ibdsGood.FieldByName('shortname').AsString := ibdsGood.FieldByName('name').AsString;
  end;

  if ibdsSelTax.State in [dsEdit, dsInsert] then
    ibdsSelTax.Post;

  if ibdsSelTax.RecordCount = 0 then
  begin
    if MessageBox(HANDLE, 'Нет налогов. Желаете добавить ?', 'Внимание',
      mb_YesNo or mb_IconQuestion) = idYes then
    begin
      actAddTaxExecute(Self);
      gsibgrTax.SetFocus;
      exit;
    end;
  end;

  if ibdsGood.State in [dsEdit, dsInsert] then
    try
      ibdsGood.Post;
    except
      on E: Exception do
      begin
        ShowMessage(E.Message);
        abort;
      end;
    end;

  if ibdsSelTax.State in [dsEdit, dsInsert] then
    try
      ibdsSelTax.Post;
    except
      ibdsSelTax.Cancel;
    end;

  if ibdsSelValue.State in [dsEdit, dsInsert] then
    try
      ibdsSelValue.Post;
    except
      ibdsSelValue.Cancel;
    end;

  if ibdsGoodPrMetal.State in [dsEdit, dsInsert] then
    try
      ibdsGoodPrMetal.Post;
    except
      ibdsGoodPrMetal.Cancel;
    end;

  if ibdsBarCode.State in [dsEdit, dsInsert] then
    try
      ibdsBarCode.Post;
    except
      ibdsBarCode.Cancel;
    end;

  if isNext then
    ibdsGood.Transaction.CommitRetaining
  else
    ibdsGood.Transaction.Commit;

  isOK := True;  
  Result := True;
end;

procedure TdlgAddGood.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsSelTax.State in [dsEdit, dsInsert] then
      ibdsSelTax.Cancel;

    if ibdsSelValue.State in [dsEdit, dsInsert] then
      ibdsSelValue.Cancel;

    if ibdsGoodPrMetal.State in [dsEdit, dsInsert] then
      ibdsGoodPrMetal.Cancel;

    if ibdsBarCode.State in [dsEdit, dsInsert] then
      ibdsBarCode.Cancel;

    if ibdsGood.State in [dsEdit, dsInsert] then
      ibdsGood.Cancel;

    ibdsGood.Transaction.Rollback;
  end;
end;

procedure TdlgAddGood.OpenTax;
begin
  if FNewGoodTax then
    ibdsSelTax.Close;

  if not ibdsSelTax.Active then
  begin
    ibdsSelTax.Prepare;
    ibdsSelTax.Params.ByName('goodkey').AsInteger := FGoodKey;
    ibdsSelTax.Open;
    ibdsSelTax.FieldByName('taxkey').OnChange := TAXKEYChange; 
  end;
  FNewGoodTax := False;
end;

procedure TdlgAddGood.OpenValue;
begin
  if FNewGoodValue then
    ibdsSelValue.Close;

  if not ibdsSelValue.Active then
  begin
    ibdsSelValue.Prepare;
    ibdsSelValue.Params.ByName('goodkey').AsInteger := FGoodKey;
    ibdsSelValue.Open;
  end;
  FNewGoodValue := False;
end;

procedure TdlgAddGood.OpenPrMetal;
begin
  if FNewGoodPrMetal then
    ibdsGoodPrMetal.Close;

  if not ibdsGoodPrMetal.Active then
  begin
    ibdsGoodPrMetal.Prepare;
    ibdsGoodPrMetal.Params.ByName('goodkey').AsInteger := FGoodKey;
    ibdsGoodPrMetal.Open;
  end;
  FNewGoodPrMetal := False;
end;

procedure TdlgAddGood.OpenBarCode;
begin
  if FNewGoodBarCode then
    ibdsBarCode.Close;

  if not ibdsBarCode.Active then
  begin
    ibdsBarCode.Prepare;
    ibdsBarCode.Params.ByName('goodkey').AsInteger := FGoodKey;
    ibdsBarCode.Open;
  end;
  FNewGoodBarCode := False;
end;


procedure TdlgAddGood.ClearFlag;
begin
  FNewGoodTax := True;
  FNewGoodValue := True;
  FNewGoodPrMetal := True;
  FNewGoodBarCode := True;
end;

procedure TdlgAddGood.actAddValueExecute(Sender: TObject);
begin
  with TdlgAddValue.Create(Self) do
    try
      ActiveDialog(-1);
      if ShowModal = mrOk then
        dblcbValue.CurrentKey := IntToStr(ValueKey);
    finally
      Free;
    end;
end;

procedure TdlgAddGood.actNewAllExecute(Sender: TObject);
begin
  if gsibgrTax.Focused then
    actAddTax.Execute
  else
    if gsibgrValues.Focused then
      actSetValue.Execute
    else
      if gsibgrPrMetal.Focused then
        actAddPrMetal.Execute
      else
        if gdibgrBarCode.Focused then
          actAddBarCode.Execute
        else
          if actNew.Enabled then
            actNew.Execute;
end;

procedure TdlgAddGood.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(gsibgrTax, gsibgrTax.SaveToStream);
  UserStorage.SaveComponent(gsIbgrValues, gsIbgrValues.SaveToStream);
  UserStorage.SaveComponent(gsibgrPrMetal, gsibgrPrMetal.SaveToStream);
  UserStorage.SaveComponent(gdibgrBarCode, gdibgrBarCode.SaveToStream);
end;

procedure TdlgAddGood.actEditBarCodeUpdate(Sender: TObject);
begin
  actEditBarCode.Enabled := ibdsBarCode.Active and
    (ibdsBarCode.FieldByName('BarCode').AsString > '');
end;

procedure TdlgAddGood.actDelBarCodeUpdate(Sender: TObject);
begin
  actDelBarCode.Enabled := ibdsBarCode.Active and
    (ibdsBarCode.FieldByName('BarCode').AsString > '');
end;

procedure TdlgAddGood.actDelPrMetalUpdate(Sender: TObject);
begin
  actDelPrMetal.Enabled := ibdsGoodPrMetal.Active and
    not ibdsGoodPrMetal.FieldByName('PrMetalKey').IsNull; 
end;

procedure TdlgAddGood.actDelValueUpdate(Sender: TObject);
begin
  actDelValue.Enabled := ibdsSelValue.Active and not ibdsSelValue.FieldByName('ValueKey').IsNull;
end;

procedure TdlgAddGood.actDelTaxUpdate(Sender: TObject);
begin
  actDelTax.Enabled := ibdsSelTax.Active and not ibdsSelTax.FieldByName('TaxKey').IsNull;
end;

procedure TdlgAddGood.actTaxSelectExecute(Sender: TObject);
begin
  gsibgrTax.SetFocus;
end;

procedure TdlgAddGood.dbeNameChange(Sender: TObject);
begin
  Caption := 'ТМЦ: ' + dbeName.Text;
end;

procedure TdlgAddGood.SpeedButton1Click(Sender: TObject);
begin
  with TdlgFindGood.Create(Self) do
  try
    Find(dbeName.Text);
  finally
    Free;
  end;
end;

procedure TdlgAddGood.gsiblcTaxExit(Sender: TObject);
begin
  SendMessage(gsibgrTax.Handle, WM_KEYDOWN, VK_TAB, 0);
end;

procedure TdlgAddGood.ibdsSelTaxAfterPost(DataSet: TDataSet);
begin
  DataSet.Refresh;
end;

procedure TdlgAddGood.TAXKEYChange(Sender: TField);
var
  ibsql: TIBSQL;
begin
  if not Sender.IsNull then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := ibtrGood;
      ibsql.SQL.Text := 'SELECT name, rate FROM gd_tax WHERE id = :id';
      ibsql.Prepare;
      ibsql.ParamByName('id').AsInteger := Sender.AsInteger;
      ibsql.ExecQuery;
      ibdsSelTax.FieldByName('rate').AsCurrency := ibsql.FieldByName('rate').AsCurrency;
      ibdsSelTax.FieldByName('name').AsString := ibsql.FieldByName('name').AsString;
      ibsql.Close;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure TdlgAddGood.ibdsSelTaxAfterInsert(DataSet: TDataSet);
begin
  ibdsSelTax.FieldByName('GOODKEY').AsInteger := FGoodKey;
end;

end.


