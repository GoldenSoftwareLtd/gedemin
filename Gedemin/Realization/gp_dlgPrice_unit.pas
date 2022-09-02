// ShlTanya, 11.03.2019

unit gp_dlgPrice_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, xDateEdits, ExtCtrls, ComCtrls, Grids, DBGrids,
  gsDBGrid, gsIBGrid, at_Controls, at_sql_setup, Db, IBCustomDataSet, dmDatabase_unit,
  IBDatabase, ToolWin, ActnList, Menus, flt_sqlFilter, IBSQL, 
  contnrs, xCalc, at_classes,  gsIBLookupComboBox,
  boCurrency, gsIBCtrlGrid, at_Container, FrmPlSvr, gd_security;

type
  TdlgPrice = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    bOk: TButton;
    bCancel: TButton;
    bHelp: TButton;
    Label1: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    dbmDescription: TDBMemo;
    dbchPriceType: TDBCheckBox;
    atSQLSetup: TatSQLSetup;
    ibdsPrice: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsPrice: TDataSource;
    xdbdeRelevanceDate: TxDateDBEdit;
    dbchDisabled: TDBCheckBox;
    ibdsPricePos: TIBDataSet;
    CoolBar1: TCoolBar;
    tbPricePosAction: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    Panel3: TPanel;
    dsPricePos: TDataSource;
    ActionList1: TActionList;
    actNewPosition: TAction;
    actDelPosition: TAction;
    PopupMenu1: TPopupMenu;
    gsQueryFilter: TgsQueryFilter;
    sbCurs: TScrollBox;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    ibsqlPricePosOption: TIBSQL;
    xFoCal: TxFoCal;
    boCurrency: TboCurrency;
    gsibgrPricePos: TgsIBCtrlGrid;
    gsiblcGood: TgsIBLookupComboBox;
    ibsqlGood: TIBSQL;
    Label4: TLabel;
    gsiblcContact: TgsIBLookupComboBox;
    atContainer: TatContainer;
    FormPlaceSaver: TFormPlaceSaver;
    Button1: TButton;
    actAccess: TAction;
    ToolButton4: TToolButton;
    actFilter: TAction;
    procedure actNewPositionExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actDelPositionExecute(Sender: TObject);
    procedure actDelPositionUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ibdsPricePosBeforeInsert(DataSet: TDataSet);
    procedure ibdsPricePosAfterInsert(DataSet: TDataSet);
    procedure ibdsPricePosAfterPost(DataSet: TDataSet);
    procedure ibdsPricePosAfterDelete(DataSet: TDataSet);
    procedure ibdsPricePosBeforePost(DataSet: TDataSet);
    procedure gsibgrPricePosSetCtrl(Sender: TObject; Ctrl: TWinControl;
      Column: TColumn; var Show: Boolean);
    procedure ToolButton4Click(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
  private
    { Private declarations }
    FPriceKey: TID;
    FCopyPriceKey: TID;
    FCalcFields: TObjectList;
    CursList: TList;
    FirstFieldName: String;
    TimeBegin: LongWord;
    isChange: Boolean;
    procedure BeforeAction;
    procedure AddPrice;
    procedure ReadOption(const isAppend: Boolean);
    procedure DoOnChangeField(Sender: TField);
    procedure DoOnChangeGoodKey(Sender: TField);
    procedure CalcFields;
  public
    { Public declarations }
    procedure SetupDialog(const aPriceKey, aCopyPriceKey: TID);
    property PriceKey: TID read FPriceKey;
  end;

var
  dlgPrice: TdlgPrice;

implementation

{$R *.DFM}

uses
  Storages, gdcBaseInterface;

const
  TopLabel = 10;
  TopEdit = 6;
  HeightStep = 24;
  LeftLabel = 7;

type
  TCalcFieldInfo = class
    FieldName: String;
    Expression: String;
    CurrKey: TId;
    constructor Create(const aFieldName, aExpression: String; aCurrKey: TID);
  end;

constructor TCalcFieldInfo.Create(const aFieldName, aExpression: String; aCurrKey: TID);
begin
  FieldName := Trim(aFieldName);
  Expression := aExpression;
  CurrKey := aCurrKey;
end;

type
  TCurs = class
    CurrKey: TID;
    Sign: String;
    Edit: TEdit;
    constructor Create(const aCurrKey: TID; const aSign: String; aEdit: TEdit);
  end;

constructor TCurs.Create(const aCurrKey: TID; const aSign: String; aEdit: TEdit);
begin
  Sign := aSign;
  Edit := aEdit;
  CurrKey := aCurrKey;
end;

{ TdlgPrice }

procedure TdlgPrice.AddPrice;
var
  ibsql: TIBSQL;
  atRelation: TatRelation;
  S, S1: String;
  i: Integer;
begin
  FPriceKey := gdcBaseManager.GetNextID;
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;

    ibsql.SQL.Text := 'INSERT INTO gd_price(id, name, pricetype) VALUES (:pricekey, :name, ''C'')';
    ibsql.Prepare;
    SetTID(ibsql.ParamByName('pricekey'), FPriceKey);
    ibsql.ParamByName('name').AsString := '';
    ibsql.ExecQuery;
    ibsql.Close;

    if FCopyPriceKey <> -1 then
    begin
      atRelation := atDatabase.Relations.ByRelationName('GD_PRICEPOS');
      S1 := '';
      if Assigned(atRelation) then
      begin
        for i:= 0 to atRelation.RelationFields.Count - 1 do
          if atRelation.RelationFields[i].IsUserDefined then
            S1 := S1 + ',' + atRelation.RelationFields[i].FieldName;
      end;
      S := Format('SELECT NULL, %d, p.goodkey %s FROM gd_pricepos p ' +
        'WHERE p.pricekey = %d', [FPriceKey, S1, FCopyPriceKey]);
//      S := atSQLSetup.PrepareSQL(S);
//      insert(' NULL, ', S, 7);
      ibsql.SQL.Text := Format('INSERT INTO gd_pricepos (id, pricekey, goodkey %s) ', [S1]) + S;

      ibsql.ExecQuery;
      ibsql.Close;
    end;

  finally
    ibsql.Free;
  end;
end;

procedure TdlgPrice.BeforeAction;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;
end;

procedure TdlgPrice.ReadOption(const isAppend: Boolean);
var
  LabelH: Integer;
  EditH: Integer;
  i: Integer;
  Lbl: TLabel;
  Edit: TEdit;
  ibsql: TIBSQL;
begin
  LabelH := TopLabel;
  EditH := TopEdit;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT rate FROM gd_pricecurr WHERE pricekey = :pk and currkey = :ck';
    ibsql.Prepare;
    SetTID(ibsql.ParamByName('pk'), FPriceKey);
    ibsqlPricePosOption.ExecQuery;
    while not ibsqlPricePosOption.EOF do
    begin
      FCalcFields.Add(TCalcFieldInfo.Create(ibsqlPricePosOption.FieldByName('FieldName').AsString,
        ibsqlPricePosOption.FieldByName('expression').AsString,
        GetTID(ibsqlPricePosOption.FieldByName('currkey'))));
      if GetTID(ibsqlPricePosOption.FieldByName('currkey')) > 0 then
      begin
        lbl := TLabel.Create(Self);
        lbl.Parent := sbCurs;
        lbl.Caption := ibsqlPricePosOption.FieldByName('name').AsString;
        lbl.Left := LeftLabel;
        lbl.Top := LabelH;

        Edit := TEdit.Create(Self);
        Edit.Parent := sbCurs;
        Edit.Text := '';
        Edit.Left := LeftLabel + lbl.Canvas.TextWidth(lbl.Caption) + 6;
        Edit.Top := EditH;
        Edit.Text := FloatToStr(boCurrency.GetRate(GetTID(ibsqlPricePosOption.FieldByName('currkey'))));
        if not isAppend then
        begin
          SetTID(ibsql.ParamByName('ck'),
            ibsqlPricePosOption.FieldByName('currkey'));
          ibsql.ExecQuery;
          if ibsql.RecordCount = 1 then
            Edit.Text := ibsql.FieldByName('rate').AsString;
          ibsql.Close;   
        end;
        CursList.Add(TCurs.Create(GetTID(ibsqlPricePosOption.FieldByName('currkey')),
          ibsqlPricePosOption.FieldByName('SIGN').AsString,
          Edit));

        LabelH := LabelH + HeightStep;
        EditH := EditH + HeightStep;
      end;
      ibsqlPricePosOption.Next;
    end;

    for i:= 0 to ibdsPricePos.FieldCount - 1 do
      if Pos(UserPrefix, ibdsPricePos.Fields[i].FieldName) > 0 then
        ibdsPricePos.Fields[i].OnChange := DoOnChangeField;

    ibdsPricePos.FieldByName('goodkey').OnChange := DoOnChangeGoodKey;    
  finally
    ibsql.Free;
  end;
end;

procedure TdlgPrice.SetupDialog(const aPriceKey, aCopyPriceKey: TID);
var
  i: Integer;
begin
  TimeBegin := GetTickCount;
  BeforeAction;
  FCopyPriceKey := aCopyPriceKey;
  if aPriceKey = -1 then
    AddPrice
  else
    FPriceKey := aPriceKey;

  SetTID(ibdsPrice.ParamByName('pricekey'), FPriceKey);
  ibdsPrice.Open;

  SetTID(ibdsPricePos.ParamByName('id'), FPriceKey);
  ibdsPricePos.Open;
  for i:= 0 to ibdsPricePos.FieldCount - 1 do
    try
      ibdsPricePos.Fields[i].Required := False;
    except
    end;

  isChange := False;  
  ReadOption(aPriceKey = -1);  
end;

procedure TdlgPrice.actNewPositionExecute(Sender: TObject);
begin
{  if boDirectGood.ChooseGood then
  begin
    for i:= 0 to boDirectGood.ChooseGoodList.Count - 1 do
    begin
      ibdsPricePos.Insert;
      ibdsPricePos.FieldByName('goodkey').AsInteger := StrToInt(boDirectGood.ChooseGoodList[i]);
      ibdsPricePos.Post;
    end;
  end;}
end;

procedure TdlgPrice.actOkExecute(Sender: TObject);
var
  Value: Double;
  ibsql: TIBSQL;
  i: Integer;
begin
  if ibdsPrice.FieldByName('name').AsString = '' then
  begin
    MessageBox(HANDLE, 'Необходимо указать название прайс-листа', 'Внимание', mb_Ok or
      mb_IconInformation);
    dbedName.SetFocus;
    exit;  
  end;

  if ibdsPrice.FieldByName('RELEVANCEDATE').AsString = '' then
  begin
    MessageBox(HANDLE, 'Необходимо указать дату прайс-листа', 'Внимание', mb_Ok or
      mb_IconInformation);
    xdbdeRelevanceDate.SetFocus;
    exit;
  end;

  if ibdsPrice.State in [dsEdit, dsInsert] then
    ibdsPrice.Post;

  if ibdsPricePos.State in [dsEdit, dsInsert] then
    ibdsPricePos.Post;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'INSERT INTO gd_pricecurr (pricekey, currkey, rate) VALUES (:pk, :ck, :r)';
    ibsql.Prepare;
    SetTiiD(bsql.ParamByName('pk'), FPriceKey);
    for i:= 0 to CursList.Count - 1 do
    begin
      try
        Value := StrToFloat(TCurs(CursList[i]).Edit.Text);
        SetTID(ibsql.ParamByName('ck'), TCurs(CursList[i]).CurrKey);
        ibsql.ParamByName('r').AsFloat := Value;
        ibsql.ExecQuery;
        ibsql.Close;
      except
      end;
    end;
  finally
    ibsql.Free;
  end;

  ibdsPricePos.ApplyUpdates;

  if IBTransaction.InTransaction then
    IBTransaction.Commit;

  ModalResult := mrOK;    
end;

procedure TdlgPrice.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgPrice.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then
  begin
    if not isChange or (MessageBox(HANDLE, 'Выйти без сохранения?', 'Внимание', mb_YesNo or mb_IconQuestion) =
       idYes)
    then
    begin
      if GetTickCount - TimeBegin > 600000 then
        if isChange and (MessageBox(HANDLE, 'Вы уверены, что не хотите сохранить произведенные изменения?', 'Внимание',
           mb_YesNo or mb_IconQuestion) = idNo)
        then
        begin
          ModalResult := mrNone;
          abort;
        end;
      if ibdsPricePos.State in [dsEdit, dsInsert] then
        ibdsPricePos.Cancel;

      ibdsPricePos.CancelUpdates;

      if ibdsPrice.State in [dsEdit, dsInsert] then
        ibdsPrice.Cancel;

      if IBTransaction.InTransaction then
        IBTransaction.RollBack;
    end
    else
    begin
      ModalResult := mrNone;
      abort;
    end;
  end;

  if Assigned(FCalcFields) then
    FreeAndNil(FCalcFields);
  if Assigned(CursList) then
    FreeAndNil(CursList);  
end;

procedure TdlgPrice.actDelPositionExecute(Sender: TObject);
begin
  if ibdsPricePos.FieldByName('id').IsNull then exit;

  if MessageBox(HANDLE, PChar(Format('Удалить позицию ''%s''?',
    [ibdsPricePos.FieldByName('name').AsString])),
    'Внимание', mb_YesNo or mb_IconQuestion) = idYes
  then
    ibdsPricePos.Delete;
end;

procedure TdlgPrice.actDelPositionUpdate(Sender: TObject);
begin
  actDelPosition.Enabled := not ibdsPricePos.FieldByName('ID').IsNull;
end;

procedure TdlgPrice.FormCreate(Sender: TObject);
var
  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;
begin
  ToolButton4.Enabled := IBLogin.IsIBUserAdmin;
  boCurrency.NCU := 200010;  //!!!!!!!!!!!
  FCalcFields := TObjectList.Create;
  CursList := TList.Create;
  FirstFieldName := '';
  UserStorage.LoadComponent(gsibgrPricePos, gsibgrPricePos.LoadFromStream);

  OldOnExit := gsiblcGood.OnExit;
  OldOnKeyDown := gsiblcGood.OnKeyDown;
  gsibgrPricePos.AddControl('NAME', gsiblcGood, OldOnExit,
    OldOnKeyDown);
  gsiblcGood.OnExit := OldOnExit;
  gsiblcGood.OnKeyDown := OldOnKeyDown;
  
end;

procedure TdlgPrice.DoOnChangeField(Sender: TField);
begin
  if FirstFieldName = '' then
  begin
    FirstFieldName := Sender.FieldName;
    CalcFields;
    FirstFieldName := '';
  end;
end;

procedure TdlgPrice.CalcFields;
var
  R: TatRelationField;
  i: Integer;
  Value: Double;
begin
  xFocal.ClearVariablesList;
  for i:= 0 to ibdsPricePos.FieldCount - 1 do
    if Pos(UserPrefix, ibdsPricePos.Fields[i].FieldName) > 0 then
    begin
      R := atDatabase.FindRelationField('GD_PRICEPOS', ibdsPricePos.Fields[i].FieldName);
      if Assigned(R) then
        xFocal.AssignVariable(R.LShortName, ibdsPricePos.Fields[i].AsFloat);
    end;

  for i:= 0 to CursList.Count - 1 do
  begin
    try
      Value := StrToFloat(TCurs(CursList[i]).Edit.Text);
      xFocal.AssignVariable('Курс_' + TCurs(CursList[i]).Sign, Value);
    except
    end;
  end;

  for i:= 0 to FCalcFields.Count - 1 do
  begin
    if (TCalcFieldInfo(FCalcFields[i]).FieldName <> FirstFieldName) and
       (TCalcFieldInfo(FCalcFields[i]).Expression > '')
    then
    begin
      xFocal.Expression := TCalcFieldInfo(FCalcFields[i]).Expression;
      ibdsPricePos.FieldByName(TCalcFieldInfo(FCalcFields[i]).FieldName).AsFloat :=
        xFocal.Value;
    end;
  end;
end;

procedure TdlgPrice.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(gsibgrPricePos, gsibgrPricePos.SaveToStream);
end;

procedure TdlgPrice.ibdsPricePosBeforeInsert(DataSet: TDataSet);
begin
  gsibgrPricePos.SelectedField := ibdsPricePos.FieldByName('Name');
end;

procedure TdlgPrice.DoOnChangeGoodKey(Sender: TField);
var
  ibsql: TIBSQL;
begin
  if Sender.IsNull then exit;
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT id FROM gd_pricepos WHERE goodkey = :gk and ' +
      'pricekey = :pk and id <> :id';
    ibsql.Prepare;
    SetTID(ibsql.ParamByName('gk'), Sender);
    SetTID(ibsql.ParamByName('pk'), FPriceKey);
    SetTID(ibsql.ParamByName('id'), ibdsPricePos.FieldByName('id'));
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      case MessageBox(HANDLE, 'Выбранная позиция уже есть в прайс-листе! Перейти на данную позицию ?',
        'Внимание', mb_YesNoCancel) of
      idYes:
        begin
          if ibdsPricePos.State in [dsEdit, dsInsert] then
            ibdsPricePos.Cancel;
          gsibgrPricePos.SetFocus;
          ibdsPricePos.Locate('id', ibsql.FieldByName('id').AsString, []);
          exit;
        end;
      idNo:
        begin
          if ibdsPricePos.State in [dsEdit, dsInsert] then ibdsPricePos.Cancel;
          gsibgrPricePos.SetFocus;
          exit;
        end;  
      idCancel:
        begin
          gsiblcGood.CurrentKey := '';
          abort;
        end;
      end;      
    end;
  finally
    ibsql.Close;
    ibsql.Free;
  end;
  
  if not ibsqlGood.Prepared then
    ibsqlGood.Prepare;
  SetTID(ibsqlGood.ParamByName('id'), Sender);
  ibsqlGood.ExecQuery;
  ibdsPricePos.FieldByName('Name').AsString := ibsqlGood.FieldByName('Name').AsString;
  ibdsPricePos.FieldByName('Mes').AsString := ibsqlGood.FieldByName('ValueName').AsString;
  ibsqlGood.Close;
end;

procedure TdlgPrice.ibdsPricePosAfterInsert(DataSet: TDataSet);
begin
  SetTID(ibdsPricePos.FieldByName('id'), gdcBaseManager.GetNextID);
  SetTID(ibdsPricePos.FieldByName('pricekey'), FPriceKey);
end;

procedure TdlgPrice.ibdsPricePosAfterPost(DataSet: TDataSet);
begin
  isChange := True;
end;

procedure TdlgPrice.ibdsPricePosAfterDelete(DataSet: TDataSet);
begin
  isChange := True;
end;

procedure TdlgPrice.ibdsPricePosBeforePost(DataSet: TDataSet);
var
  i: Integer;
  isNull: Boolean;
begin
  isNull := True;
  for i:= 0 to gsibgrPricePos.Columns.Count - 1 do
    if gsibgrPricePos.Columns[i].Visible and not gsibgrPricePos.Columns[i].Field.IsNull then
    begin
      isNull := False;
      Break;
    end;
  if isNull then
  begin
    ibdsPricePos.Cancel;
    abort;
  end;
end;

procedure TdlgPrice.gsibgrPricePosSetCtrl(Sender: TObject;
  Ctrl: TWinControl; Column: TColumn; var Show: Boolean);
begin
//
end;

procedure TdlgPrice.ToolButton4Click(Sender: TObject);
begin
  if ibdsPricePos.RecordCount = 0 then Exit;

  if MessageBox(HANDLE, 'Пересчитать цены ?', 'Внимание', mb_YesNo or mb_IconInformation) = idYes
  then
  begin
    ibdsPricePos.First;
    while not ibdsPricePos.EOF do
    begin
      ibdsPricePos.Edit;
      CalcFields;
      ibdsPricePos.Post;
      ibdsPricePos.Next;
    end;
  end;

end;

procedure TdlgPrice.actFilterExecute(Sender: TObject);
begin
  gsQueryFilter.PopupMenu;
end;

end.
