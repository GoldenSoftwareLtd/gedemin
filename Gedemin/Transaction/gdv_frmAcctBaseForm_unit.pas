{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdv_frmAcctBaseForm_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    23.09.03    tiptop        Initial version.
--}

unit gdv_frmAcctBaseForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frmG_unit, flt_sqlFilter, gd_ReportMenu, Menus, gd_MacrosMenu,
  ActnList, Db, StdCtrls, Mask, xDateEdits, Buttons, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, SuperPageControl, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBCustomDataSet, contnrs, AcctUtils, Storages, gsStorage_CompPath,
  at_classes, gd_ClassList, AcctStrings, IBSQL, gdcBaseInterface, dmImages_unit,
  gsIBLookupComboBox, gdvParamPanel, gdv_frAcctSum_unit, gdv_AvailAnalytics_unit,
  gdv_frAcctQuantity_unit, gdv_frAcctAnalytics_unit, gdv_frAcctCompany_unit,
  IBDatabase, gd_common_functions, gdv_AcctConfig_unit, gd_createable_form,
  gdcBase, gd_security_operationconst, gdcConstants,
  gdvAcctBase, amSplitter, gsPeriodEdit;

type

  Tgdv_frmAcctBaseForm = class(Tgdv_frmG)
    actShowParamPanel: TAction;
    actAccounts: TAction;
    sLeft: TSplitter;
    ibgrMain: TgsIBGrid;
    pLeft: TPanel;
    ScrollBox: TScrollBox;
    Panel5: TPanel;
    Label17: TLabel;
    bAccounts: TButton;
    cbSubAccount: TCheckBox;
    cbIncludeInternalMovement: TCheckBox;
    Panel2: TPanel;
    sbCloseParamPanel: TSpeedButton;
    frAcctQuantity: TfrAcctQuantity;
    frAcctSum: TfrAcctSum;
    frAcctAnalytics: TfrAcctAnalytics;
    actCloseParamPanel: TAction;
    frAcctCompany: TfrAcctCompany;
    cbAccounts: TComboBox;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem3: TTBItem;
    TBToolbar1: TTBToolbar;
    pCofiguration: TPanel;
    TBControlItem2: TTBControlItem;
    iblConfiguratior: TgsIBLookupComboBox;
    lConfiguration: TLabel;
    Transaction: TIBTransaction;
    ppAppear: TgdvParamPanel;
    cbExtendedFields: TCheckBox;
    actGoto: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem2: TTBItem;
    ppMain: TPopupMenu;
    actGoto1: TMenuItem;
    TBItem5: TTBItem;
    actSaveConfig: TAction;
    AccountDelayTimer: TTimer;
    actEditInGrid: TAction;
    TBItem6: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBSeparatorItem4: TTBSeparatorItem;
    actSaveGridSetting: TAction;
    iSaveGridSettings: TTBItem;
    actClearGridSetting: TAction;
    iClearSaveGrid: TTBItem;
    tbiComeBack: TTBItem;
    actBack: TAction;
    IBReadTr: TIBTransaction;
    procedure actShowParamPanelExecute(Sender: TObject);
    procedure actShowParamPanelUpdate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actAccountsExecute(Sender: TObject);
    procedure cbAccountsChange(Sender: TObject);
    procedure cbAccountsExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCloseParamPanelExecute(Sender: TObject);
    procedure cbSubAccountClick(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure iblConfiguratiorChange(Sender: TObject);
    procedure actGotoUpdate(Sender: TObject);
    procedure actGotoExecute(Sender: TObject);
    procedure ibgrMainKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actSaveConfigExecute(Sender: TObject);
    procedure AccountDelayTimerTimer(Sender: TObject);
    procedure actEditInGridUpdate(Sender: TObject);
    procedure actEditInGridExecute(Sender: TObject);
    procedure ibgrMainDblClick(Sender: TObject);
    procedure actSaveGridSettingUpdate(Sender: TObject);
    procedure actSaveGridSettingExecute(Sender: TObject);
    procedure actClearGridSettingExecute(Sender: TObject);
    procedure actBackUpdate(Sender: TObject);
    procedure actBackExecute(Sender: TObject);
  private
    function GetIncSubAccounts: Boolean;
    procedure SetIncSubAccounts(const Value: Boolean);
  protected
    FFieldInfos: TgdvFieldInfos;
    FAccountIDs: TList;
    FCorrAccountIDs: TList;
    FValueList: TStrings;

    FMakeEmpty: Boolean;
    FShowMessage: Boolean;
    FSortColumns: Boolean;
    FSaveGridSetting: Boolean;

    // Функция возвращает объект бухгалтерского отчета, должна быть
    //   переопределена в каждой наследованной форме
    function GetGdvObject: TgdvAcctBase; virtual;

    procedure InitColumns; virtual;
    procedure DoBeforeBuildReport; virtual;
    procedure DoBuildReport; virtual;
    procedure DoAfterBuildReport; virtual;
    procedure DoEmptyReport; virtual;

    procedure UpdateControls; virtual;
    function FindColumn(FieldName: string): TgsColumn;
    procedure AddExpand(DisplayFieldName, FieldName: string);
    procedure Loaded; override;

    procedure DoLoadConfig(const Config: TBaseAcctConfig);virtual;
    procedure DoSaveConfig(Config: TBaseAcctConfig);virtual;

    procedure LoadConfig(const Stream: TStream);
    procedure SaveConfig(const Stream: TStream);

    class function ConfigClassName: string; virtual;
    procedure ParamsVisible(Value: Boolean);

    procedure SetParams; virtual;
    procedure PushForm;
    procedure Go_to(NewWindow: Boolean = false); virtual;
    function CanGo_to: boolean; virtual;

  public
    { Public declarations }
    procedure BuildAcctReport; virtual;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure Execute(Config: TBaseAcctConfig); virtual;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    property IncSubAccounts: Boolean read GetIncSubAccounts write SetIncSubAccounts;
    property gdvObject: TgdvAcctBase read GetgdvObject;
  end;

var
  gdv_frmAcctBaseForm: Tgdv_frmAcctBaseForm;

function AcctFormList: TComponentList;

implementation

uses
  gdv_dlgAccounts_unit, gd_security, gdv_dlgConfigName_unit,
  IBBlob;

const
  cNCUPrefix = 'NCU';
  cCURRPrefix = 'CURR';
  cEQPrefix = 'EQ';
  cQuantityDisplayFormat = '### ##0.##';

var
  AcctFormList_: TComponentList;

function AcctFormList: TComponentList;
begin
  if AcctFormList_ = nil then
  begin
    AcctFormList_ := TComponentList.Create(False);
  end;

  Result := AcctFormList_;
end;

{$R *.DFM}

procedure Tgdv_frmAcctBaseForm.actShowParamPanelExecute(Sender: TObject);
begin
  ParamsVisible(not pLeft.Visible);
end;

procedure Tgdv_frmAcctBaseForm.actShowParamPanelUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := pLeft.Visible;
end;

procedure Tgdv_frmAcctBaseForm.BuildAcctReport;
var
  B: Boolean;
  C: TCursor;
begin
  if frAcctCompany.CompanyKey = -1 then
  begin
    if not gdvObject.MakeEmpty then
      MessageBox(Handle,
        'Выберите организацию в поле "Компания" раздела "Компании холдинга".',
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
  end
  else
  begin
    if (Self.DateBegin > Self.DateEnd) and not gdvObject.MakeEmpty then
    begin
      MessageBox(Handle,
        'Ошибка при вводе периода построения отчета: дата начала больше даты окончания.',
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end
    else
    begin
      B := gdvObject.MakeEmpty;
      C := Screen.Cursor;
      Screen.Cursor := crSQLWait;
      try
        if not gdvObject.MakeEmpty and not CheckActiveAccount(frAcctCompany.CompanyKey) then
          gdvObject.MakeEmpty := True;

        DoBeforeBuildReport;
        // Передадим параметры отчета выбранные на форме в FgdvObject 
        SetParams;
        DoBuildReport;
        DoAfterBuildReport;
      finally
        gdvObject.MakeEmpty := B;
        Screen.Cursor := C;
      end;
    end;
  end;
end;

procedure Tgdv_frmAcctBaseForm.InitColumns;
var
  I, J: Integer;
  F: TgdvFieldInfo;
  DisplayFieldName: string;
  C, MainColumn: TgsColumn;
begin
  ibgrMain.Expands.Clear;

  if Assigned(FFieldInfos) then
  begin
    for I := 0 to gdvObject.Fields.Count - 1 do
    begin
      F := FFieldInfos.FindInfo(gdvObject.Fields[I].FieldName);
      C := FindColumn(gdvObject.Fields[I].FieldName);
      if Assigned(F) and Assigned(C) then
      begin
        C.Title.Caption := F.Caption;
        C.DisplayFormat := '';
        C.DisplayFormat := F.DisplayFormat;

        // если F.Visible = fvUnknown, то видимость поля определяется сохраненными настройками грида
        case F.Visible of
          fvVisible: C.Visible := True;
          fvHidden: C.Visible := False;
        end;

        if F.Total then
          C.TotalType := ttSum
        else
          C.TotalType := ttNone;

        if F.DisplayFields.Count > 0 then
        begin
          ibgrMain.ExpandsActive := True;
          ibgrMain.ExpandsSeparate := True;
          ibgrMain.TitlesExpanding := True;

          for J := 0 to F.DisplayFields.Count - 1 do
          begin
            DisplayFieldName := F.DisplayFields[J];
            MainColumn := FindColumn(DisplayFieldName);
            if Assigned(MainColumn) then
            begin
              AddExpand(DisplayFieldName, F.FieldName);
              C.Visible := False;
            end;
          end;
        end;
      end;
    end;
  end;

  if FSortColumns then
  begin
    J := 0;
    for I := 0 to gdvObject.Fields.Count - 1 do
    begin
      C := FindColumn(gdvObject.Fields[I].FieldName);
      if (C <> nil) and C.Visible then
      begin
        C.Index := J;
        Inc(J);
      end;
    end;
  end;  
end;

procedure Tgdv_frmAcctBaseForm.FormDestroy(Sender: TObject);
begin
  inherited;

  FFieldInfos.Free;
  FAccountIDs.Free;
  FCorrAccountIDs.Free;
  FValueList.Free;
end;

procedure Tgdv_frmAcctBaseForm.DoAfterBuildReport;
var
  Config: TBaseAcctConfig;
begin
  try
    if iblConfiguratior.CurrentKey > '' then
    begin
      Config := LoadConfigById(iblConfiguratior.CurrentKeyInt);
      try
        if (Config <> nil) and (Config.GridSettings.Size > 0) then
          ibgrMain.LoadFromStream(Config.GridSettings)
        else
          InitColumns;
      finally
        Config.Free;
      end;
    end
    else
      InitColumns;
    ibgrMain.ResizeColumns;
  finally
    ibgrMain.Columns.EndUpdate;
  end;
end;

procedure Tgdv_frmAcctBaseForm.DoBeforeBuildReport;
var
  I, J: Integer;                    
  F: TgdvFieldInfo;
begin
  // Объект, который будет содержать информацию о полях отчета
  if FFieldInfos = nil then
    FFieldInfos := TgdvFieldInfos.Create
  else
    FFieldInfos.Clear;

  // Очистка параметров в объекте бух. отчета
  gdvObject.Clear;
  // Закроем датасет перед подготовкой к построению
  if gdvObject.Active then
    gdvObject.Close;

  // Локализуем поля сумм по умолчанию
  for I := 0 to BaseAcctFieldCount - 1 do
  begin
    F := FFieldInfos.AddInfo;
    F.FieldName := BaseAcctFieldList[I].FieldName;
    F.Caption := BaseAcctFieldList[I].Caption;
    F.Condition := True;
    F.Total := True;
    if Pos('NCU_', BaseAcctFieldList[I].FieldName) = 1 then
    begin
      F.DisplayFormat := DisplayFormat(frAcctSum.NcuDecDigits);
      if frAcctSum.InNcu then
        F.Visible := fvVisible
      else
        F.Visible := fvHidden;
    end
    else if Pos('CURR_', BaseAcctFieldList[I].FieldName) = 1 then
    begin
      F.DisplayFormat := DisplayFormat(frAcctSum.CurrDecDigits);
      if (frAcctSum.InCurr) and (not frAcctSum.InNcu) then
        F.Visible := fvVisible
      else
        F.Visible := fvHidden;
      if (frAcctSum.InCurr) and (frAcctSum.InNcu) then
        F.DisplayFields.Add(BaseAcctFieldList[I].DisplayFieldName);
    end
    else if Pos('EQ_', BaseAcctFieldList[I].FieldName) = 1 then
    begin
      F.DisplayFormat := DisplayFormat(frAcctSum.EQDecDigits);
      if (frAcctSum.InEQ) and (not frAcctSum.InNcu) then
        F.Visible := fvVisible
      else
        F.Visible := fvHidden;
      if (frAcctSum.InEQ) and (frAcctSum.InNcu) then
        F.DisplayFields.Add(BaseAcctFieldList[I].DisplayFieldName);
    end;
  end;

  // Сохраним выбранные счета в хранилище
  SaveHistory(cbAccounts);

  if FValueList = nil then
    FValueList := TStringList.Create;

  if FAccountIDs = nil then
    FAccountIDs := TList.Create;

  // Получим список выбранных количественных показателей из панели формы
  frAcctQuantity.ValueList(FValueList, FAccountIDs, Self.DateBegin, Self.DateEnd);
  // Перенесем строку выбранных счетов в список, опционально с субсчетами
  SetAccountIDs(cbAccounts, FAccountIDs, IncSubAccounts);

  // Локализуем поля сумм для количественных показателей по умолчанию
  if FValueList.Count > 0 then
  begin
    for J := 0 to BaseAcctQuantityFieldCount - 1 do
    begin
      for I := 0 to FValueList.Count - 1 do
      begin
        F := FFieldInfos.AddInfo;
        F.FieldName := Format(BaseAcctQuantityFieldList[J].FieldName, [gdvObject.GetKeyAlias(FValueList.Names[I])]);
        F.Caption := Format(BaseAcctQuantityFieldList[J].Caption,
            [FValueList.Values[FValueList.Names[I]]]);
        F.Visible := fvHidden;
        F.Total := True;

        F.DisplayFields.Add(Format(BaseAcctQuantityFieldList[J].DisplayFieldName, [cNCUPrefix]));
        F.DisplayFields.Add(Format(BaseAcctQuantityFieldList[J].DisplayFieldName, [cCURRPrefix]));
        F.DisplayFields.Add(Format(BaseAcctQuantityFieldList[J].DisplayFieldName, [cEQPrefix]));
        F.DisplayFormat := DisplayFormat(frAcctSum.QuantityDecDigits);
      end;
    end;
  end;

  ibgrMain.Columns.BeginUpdate;
  gdvObject.FieldInfos := FFieldInfos;  

  FSortColumns := True;  
end;

procedure Tgdv_frmAcctBaseForm.DoBuildReport;
begin
  if gdvObject.Active then
    gdvObject.Close;
  gdvObject.BuildReport;
end;

procedure Tgdv_frmAcctBaseForm.actAccountsExecute(Sender: TObject);
begin
  if AccountDialog(cbAccounts, GetActiveAccount(frAcctCompany.CompanyKey)) then
  begin
    if FAccountIDs <> nil then
      FAccountIDs.Clear;
    UpdateControls;
  end;
end;

procedure Tgdv_frmAcctBaseForm.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTBASEFORM', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTBASEFORM', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTBASEFORM') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTBASEFORM',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTBASEFORM' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  LoadGrid(ibgrMain);
  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    cbAccounts.Items.Text := UserStorage.ReadString(ComponentPath, 'AccountHistory', '');
    frAcctSum.ppMain.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'SumUnwraped', True);
    frAcctAnalytics.ppAnalytics.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'AnalyticsUnwraped', True);
    frAcctQuantity.ppMain.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'QuantityUnwraped', True);
    frAcctCompany.ppMain.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'CompanyUnwraped', True);
    ppAppear.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'AppearUnwraped', True);

    ParamsVisible(UserStorage.ReadBoolean(ComponentPath, 'ParamsVisible', True));
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTBASEFORM', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTBASEFORM', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctBaseForm.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTBASEFORM', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTBASEFORM', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTBASEFORM') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTBASEFORM',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTBASEFORM' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  SaveGrid(ibgrMain);
  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    UserStorage.WriteString(ComponentPath, 'AccountHistory', cbAccounts.Items.Text);
    UserStorage.WriteBoolean(ComponentPath, 'SumUnwraped', frAcctSum.ppMain.Unwraped);
    UserStorage.WriteBoolean(ComponentPath, 'AnalyticsUnwraped', frAcctAnalytics.ppAnalytics.Unwraped);
    UserStorage.WriteBoolean(ComponentPath, 'QuantityUnwraped', frAcctQuantity.ppMain.Unwraped);
    UserStorage.WriteBoolean(ComponentPath, 'CompanyUnwraped', frAcctCompany.ppMain.Unwraped);
    UserStorage.WriteBoolean(ComponentPath, 'AppearUnwraped', ppAppear.Unwraped);

    UserStorage.WriteBoolean(ComponentPath, 'ParamsVisible', pLeft.Visible);
    UserStorage.WriteInteger(ComponentPath, 'LastConfig', iblConfiguratior.CurrentKeyInt);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTBASEFORM', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTBASEFORM', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

function Tgdv_frmAcctBaseForm.GetIncSubAccounts: Boolean;
begin
  Result := cbSubAccount.Checked;
end;

procedure Tgdv_frmAcctBaseForm.SetIncSubAccounts(const Value: Boolean);
begin
  cbSubAccount.Checked := Value;
end;

procedure Tgdv_frmAcctBaseForm.cbAccountsChange(Sender: TObject);
begin
  if FAccountIDs <> nil then
    FAccountIDs.Clear;
  AccountDelayTimer.Enabled := False;
  AccountDelayTimer.Enabled := True;
end;              

procedure Tgdv_frmAcctBaseForm.UpdateControls;
begin
  if not Assigned(FAccountIDs) then
    FAccountIDs := TList.Create;
  SetAccountIDs(cbAccounts, FAccountIDs, IncSubAccounts, FShowMessage);
  frAcctQuantity.UpdateQuantityList(FAccountIDs);
  frAcctAnalytics.UpdateAnalyticsList(FAccountIDs);

  // Отображение настроек количественных сумм
  frAcctSum.SetQuantityVisible(frAcctQuantity.ValueCount > 0);

  ScrollBox.Realign;
end;

procedure Tgdv_frmAcctBaseForm.cbAccountsExit(Sender: TObject);
begin
  if CheckActiveAccount(frAcctCompany.CompanyKey, False) then
  begin
    FShowMessage := True;
    UpdateControls;
  end;
end;

procedure Tgdv_frmAcctBaseForm.FormCreate(Sender: TObject);
var
  DefaultDecDigits: Integer;
begin
  inherited;
  Transaction.DefaultDataBase := gdcBaseManager.Database;
  IBReadTr.DefaultDataBase := gdcBaseManager.Database;
  gdvObject.Transaction := IBReadTr;

  iblConfiguratior.Condition := Format('CLASSNAME = ''%s''', [ConfigClassName]);

  // Настройки вывода сумм
  DefaultDecDigits := LocateDecDigits;
  frAcctSum.NcuDecDigits := DefaultDecDigits;
  frAcctSum.CurrDecDigits := DefaultDecDigits;
  frAcctSum.EQDecDigits := DefaultDecDigits;
  frAcctSum.QuantityDecDigits := DefaultDecDigits;
  if Assigned(GlobalStorage) and Assigned(IBLogin)
     and ((GlobalStorage.ReadInteger('Options\Policy', GD_POL_EQ_ID, GD_POL_EQ_MASK, False) and IBLogin.InGroup) = 0) then
  begin
    frAcctSum.SetEQVisible(False);
  end;
  frAcctSum.SetQuantityVisible(False);

  // Построим пустой отчет
  gdvObject.MakeEmpty := True;
  try
    BuildAcctReport;
  finally
    gdvObject.MakeEmpty := False;
  end;
  UpdateControls;
end;

procedure Tgdv_frmAcctBaseForm.actCloseParamPanelExecute(Sender: TObject);
begin
  ParamsVisible(False);
end;

procedure Tgdv_frmAcctBaseForm.cbSubAccountClick(Sender: TObject);
begin
  if FAccountIDs <> nil then
    FAccountIDs.Clear;
  UpdateControls;
end;

procedure Tgdv_frmAcctBaseForm.actRunExecute(Sender: TObject);
begin
  BuildAcctReport;
end;

procedure Tgdv_frmAcctBaseForm.DoEmptyReport;
begin
  if gdvObject.Active then
    gdvObject.Close;
  gdvObject.MakeEmpty := True;
  gdvObject.BuildReport;
end;

function Tgdv_frmAcctBaseForm.FindColumn(FieldName: string): TgsColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ibgrMain.Columns.Count - 1 do
  begin
    if Assigned(ibgrMain.Columns[I].Field) and
       AnsiSameText(ibgrMain.Columns[I].Field.FieldName, FieldName) then
    begin
      Result := ibgrMain.Columns[I] as TgsColumn;
      Exit;
    end;
  end;
end;

procedure Tgdv_frmAcctBaseForm.AddExpand(DisplayFieldName, FieldName: string);
var
  Ex: TColumnExpand;
begin
  if Assigned(FindColumn(DisplayFieldName)) and Assigned(FindColumn(FieldName)) then
  begin
    Ex := ibgrMain.Expands.Add;
    Ex.DisplayField := DisplayFieldName;
    Ex.FieldName := FieldName;
    Ex.Options := [ceoAddField];
  end;
end;

procedure Tgdv_frmAcctBaseForm.Loaded;
begin
  inherited;
  bAccounts.Left := Panel5.ClientWidth - 5 - bAccounts.Width;
  cbAccounts.Width := bAccounts.Left - cbAccounts.Left; 
end;

procedure Tgdv_frmAcctBaseForm.LoadConfig(const Stream: TStream);
var
  C: TBaseAcctConfigClass;
  Config: TBaseAcctConfig;
  CName: string;
begin
  CName := ReadStringFromStream(Stream);
  TPersistentClass(C) := GetClass(CName);
  if C <> nil then
  begin
    Config := C.Create;
    try
      try
        Config.LoadFromStream(Stream);
        DoLoadConfig(Config);
      except
        on E: Exception do
        begin
          Application.ShowException(E);
          MessageBox(0,
            'Возникла ошибка при считывании конфигурации журнала-ордера.'#13#10 +
            'Пожалуйста, пересохраните конфигурацию.',
            'Ошибка',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
        end;
      end;
    finally
      Config.Free;
    end;
  end;
end;

procedure Tgdv_frmAcctBaseForm.SaveConfig(const Stream: TStream);
var
  C: TBaseAcctConfigClass;
  Config: TBaseAcctConfig;
begin
  TPersistentClass(C) := GetClass(ConfigClassName);
  if C <> nil then
  begin
    Config := C.Create;
    try
      SaveStringToStream(ConfigClassName, Stream);
      DoSaveConfig(Config);
      Config.SaveToStream(Stream);
    finally
      Config.Free;
    end;
  end;
end;

procedure Tgdv_frmAcctBaseForm.DoLoadConfig(const Config: TBaseAcctConfig);
begin
  if FAccountIDs <> nil then
    FAccountIDs.Clear;
  if FCorrAccountIDs <> nil then
    FCorrAccountIDs.Clear;
  with Config do
  begin
    cbAccounts.Text := Accounts;
    cbSubAccount.Checked := IncSubAccounts;
    cbIncludeInternalMovement.Checked := IncludeInternalMovement;
    UpdateControls;

    frAcctSum.InNcu := InNcu;
    frAcctSum.NcuDecDigits := NcuDecDigits;
    frAcctsum.NcuScale := NcuScale;

    frAcctSum.InCurr := InCurr;
    frAcctSum.CurrDecDigits := CurrDecDigits;
    frAcctSum.CurrScale := CurrScale;
    frAcctSum.Currkey := CurrKey;

    frAcctSum.InEQ := InEQ;
    frAcctSum.EQDecDigits := EQDecDigits;
    frAcctSum.EQScale := EQScale;

    frAcctSum.QuantityDecDigits := QuantityDecDigits;
    frAcctSum.QuantityScale := QuantityScale;

    frAcctQuantity.Selected := Quantity;
    frAcctAnalytics.Values := Analytics;

    cbExtendedFields.Checked := ExtendedFields;

    if CompanyKey > 0 then
    begin
      frAcctCompany.CompanyKey := CompanyKey;
      frAcctCompany.AllHoldingCompanies := AllHoldingCompanies;
    end else
    begin
      frAcctCompany.CompanyKey := IbLogin.CompanyKey;
      frAcctCompany.AllHoldingCompanies := IbLogin.IsHolding;
    end;
  end;
end;

procedure Tgdv_frmAcctBaseForm.DoSaveConfig(Config: TBaseAcctConfig);
begin
  Assert(Config <> nil);
  with Config do
  begin
    Accounts := cbAccounts.Text;
    IncSubAccounts := cbSubAccount.Checked;
    IncludeInternalMovement := cbIncludeInternalMovement.Checked;

    InNcu := frAcctSum.InNcu;
    NcuDecDigits := frAcctSum.NcuDecDigits;
    NcuScale := frAcctsum.NcuScale;

    InCurr := frAcctSum.InCurr;
    CurrDecDigits := frAcctSum.CurrDecDigits;
    CurrScale := frAcctSum.CurrScale;
    CurrKey := frAcctSum.Currkey;

    InEQ := frAcctSum.InEQ;
    EQDecDigits := frAcctSum.EQDecDigits;
    EQScale := frAcctsum.EQScale;

    QuantityDecDigits := frAcctSum.QuantityDecDigits;
    QuantityScale := frAcctsum.QuantityScale;

    Quantity := frAcctQuantity.Selected;
    Analytics := frAcctAnalytics.Values;

    ExtendedFields := cbExtendedFields.Checked;

    CompanyKey := frAcctCompany.CompanyKey;
    AllHoldingCompanies := frAcctCompany.AllHoldingCompanies;
  end;
end;

class function Tgdv_frmAcctBaseForm.ConfigClassName: string;
begin
  Result := 'TBaseAcctConfigClass';
end;

procedure Tgdv_frmAcctBaseForm.iblConfiguratiorChange(Sender: TObject);
var
  SQL: TIBSQL;
  bs: TIBBlobStream;
begin
  if CheckActiveAccount(frAcctCompany.CompanyKey) then
  begin
    if iblConfiguratior.CurrentKey > '' then
    begin
      SQL := TIBSQl.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQL.SQL.Text := 'SELECT config FROM ac_acct_config WHERE id = :id';
        SQL.ParamByName('id').AsInteger := iblConfiguratior.CurrentKeyInt;
        SQl.ExecQuery;
        if SQL.RecordCount > 0 then
        begin
          bs := TIBBlobStream.Create;
          try
            bs.Mode := bmRead;
            bs.Database := SQL.Database;
            bs.Transaction := SQL.Transaction;
            bs.BlobID := SQL.FieldByName('config').AsQuad;
            LoadConfig(bs);
          finally
            bs.Free;
          end;
        end;
      finally
        SQL.Free;
      end;
    end;
  end;
end;

procedure Tgdv_frmAcctBaseForm.ParamsVisible(Value: Boolean);
begin
  if not Value then
  begin
    pLeft.Visible := False;
    sLeft.Visible := False;
  end else
  begin
    pLeft.Visible :=True;
    sLeft.Visible := True;
    sLeft.Left := pLeft.Left + pLeft.Width;
  end;
end;

procedure Tgdv_frmAcctBaseForm.SetParams;
var
  I: Integer;
begin
  gdvObject.UseEntryBalance := True;

  if not gdvObject.MakeEmpty then
  begin
    gdvObject.DateBegin := Self.DateBegin;
    gdvObject.DateEnd := Self.DateEnd;

    gdvObject.CompanyKey := frAcctCompany.CompanyKey;
    gdvObject.AllHolding := frAcctCompany.AllHoldingCompanies;
    gdvObject.WithSubAccounts := cbSubAccount.Checked;
    gdvObject.IncludeInternalMovement := cbIncludeInternalMovement.Checked;
    gdvObject.ShowExtendedFields := cbExtendedFields.Checked;

    // Передадим счета
    for I := 0 to FAccountIDs.Count - 1 do
      gdvObject.AddAccount(Integer(FAccountIDs.Items[I]));

    // Значения аналитик
    for I := 0 to frAcctAnalytics.AnalyticsCount - 1 do
      if not frAcctAnalytics.Analytics[I].IsEmpty then
      begin
        gdvObject.AddCondition(frAcctAnalytics.Analytics[I].Field.FieldName,
          frAcctAnalytics.Analytics[I].Value);
      end
      else
      begin
        if frAcctAnalytics.Analytics[I].IsNull then
        begin
          gdvObject.AddCondition(frAcctAnalytics.Analytics[I].Field.FieldName, '');
        end;  
      end;

    // Количественные показатели
    for I := 0 to FValueList.Count - 1 do
      gdvObject.AddValue(StrToInt(FValueList.Names[I]), FValueList.Values[FValueList.Names[I]]);

    // Параметры вывода сумм
    gdvObject.ShowInNcu(frAcctSum.InNcu, frAcctSum.NcuDecDigits, frAcctSum.NcuScale);
    gdvObject.ShowInCurr(frAcctSum.InCurr, frAcctSum.CurrDecDigits, frAcctSum.CurrScale, frAcctSum.Currkey);
    gdvObject.ShowInEQ(frAcctSum.InEQ, frAcctSum.EQDecDigits, frAcctSum.EQScale);

  end;
end;

class function Tgdv_frmAcctBaseForm.CreateAndAssign(
  AnOwner: TComponent): TForm;
var
  I: Integer;
  Index: Integer;
begin
  Index := - 1;
  if FormsList <> nil then
  begin
    for I := 0 to FormsList.Count - 1 do
    begin
      if FormsList[I].ClassName = ClassName then
      begin
        Index := I;
        Break;
      end;
    end;
  end;

  if Index = - 1 then
  begin
    Result := Create(AnOwner)
  end else
    Result := TForm(FormsList[Index])
end;

procedure Tgdv_frmAcctBaseForm.actGotoUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanGo_to;
end;

procedure Tgdv_frmAcctBaseForm.actGotoExecute(Sender: TObject);
begin
  PushForm;
  Go_to;
end;

procedure Tgdv_frmAcctBaseForm.ibgrMainKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and not (dgEditing in ibgrMain.Options) and CanGo_to then
  begin
    Key := 0;
    PushForm;
    Go_to([ssCtrl] * Shift <> []);
  end else
    inherited;
end;

procedure Tgdv_frmAcctBaseForm.Go_to(NewWindow: Boolean = false);
begin

end;

function Tgdv_frmAcctBaseForm.CanGo_to: boolean;
begin
  Result := Assigned(gdvObject) and gdvObject.Active and not gdvObject.IsEmpty;
end;

procedure Tgdv_frmAcctBaseForm.Execute(Config: TBaseAcctConfig);
begin
  if Config <> nil then
  begin
    DoLoadConfig(Config);
    BuildAcctReport;
  end;
end;

procedure Tgdv_frmAcctBaseForm.actSaveConfigExecute(Sender: TObject);
var
  D: TdlgConfigName;
  Str: TStream;
  SQL: TIBSQL;
  DidActivate: Boolean;
  Id: Integer;
begin
  D := TdlgConfigName.Create(nil);
  try
    D.iblName.Condition := iblConfiguratior.Condition;
    D.iblName.CurrentKey := iblConfiguratior.CurrentKey;
    D.iblName.gdClassName := iblConfiguratior.gdClassName;
    if D.ShowModal = mrOk then
    begin
      Str := TMemoryStream.Create;
      try
        SaveConfig(Str);
        if Str.Size > 0 then
        begin
          Str.Position := 0;
          SQL := TIBSQl.Create(nil);
          try
            SQL.Transaction := Transaction;
            DidActivate := not Transaction.InTransaction;
            if DidActivate then
              Transaction.StartTransaction;
            try
              if D.iblName.CurrentKey <> '' then
              begin
                if Application.MessageBox(
                  PChar(Format(MSG_CONFIGEXITS, [D.ConfigName])),
                  PChar(MSG_WARNING),
                  MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) <> IDYES then
                begin
                  Exit;
                end;

                SQL.SQL.Text := 'UPDATE ac_acct_config SET name = :name, config = :config WHERE id = :id';
                SQL.ParamByName(fnId).AsInteger := D.iblName.CurrentKeyInt;
                id := D.iblName.CurrentKeyInt;
              end else
              begin
                {
                SQL.SQL.Text := 'SELECT gen_id(gd_g_unique, 1) FROM RDB$DATABASE';
                SQL.ExecQuery;
                Id := SQL.Fields[0].AsInteger;
                SQL.Close;
                }
                Id := gdcBaseManager.GetNextID;
                
                SQL.SQL.Text := 'INSERT INTO ac_acct_config (id, name, config, ' +
                  'imageindex, folder, showinexplorer, classname) VALUES (:id, ' +
                  ' :name, :config, :imageindex, :folder, :showinexplorer, :classname)';
                SQL.ParamByName(fnImageIndex).AsInteger := iiGreenCircle;
                SQL.ParamByName(fnFolder).AsInteger := AC_ACCOUNTANCY;
                SQL.ParamByName(fnShowInExplorer).AsInteger := 0;
                SQL.ParamByName(fnClassName).AsString := ConfigClassName;
                SQL.ParamByName(fnId).AsInteger := Id;
              end;

              SQL.ParamByName(fnName).AsString := D.ConfigName;
              SQL.ParamByName(fnConfig).LoadFromStream(Str);
              SQL.ExecQuery;

//              if DidActivate then
                Transaction.Commit;
              iblConfiguratior.CurrentKeyInt := Id;
              if FSaveGridSetting then
              begin
                if MessageDlg('Сохранить настройки таблицы?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                  actSaveGridSetting.Execute;
              end;
            except
//              if DidActivate then
                Transaction.RollBack;
              raise;
            end;
          finally
            SQL.Free;
          end;
        end;
      finally
        Str.Free;
      end;
    end;
  finally
    D.Free;
  end;
end;

procedure Tgdv_frmAcctBaseForm.AccountDelayTimerTimer(Sender: TObject);
begin
  TTimer(Sender).Enabled := False;
  if CheckActiveAccount(frAcctCompany.CompanyKey, False) then
  begin
    FShowMessage := False;
    UpdateControls;
  end;
end;

procedure Tgdv_frmAcctBaseForm.actEditInGridUpdate(Sender: TObject);
begin
  actEditInGrid.Checked := dgEditing in ibgrMain.Options;
end;

procedure Tgdv_frmAcctBaseForm.actEditInGridExecute(Sender: TObject);
begin
  if dgEditing in ibgrMain.Options then
    ibgrMain.Options := ibgrMain.Options - [dgEditing]
  else
    ibgrMain.Options := ibgrMain.Options + [dgEditing];
end;

procedure Tgdv_frmAcctBaseForm.ibgrMainDblClick(Sender: TObject);
begin
  if (ibgrMain.GridCoordFromMouse.Y > - 1) and
    not (dgEditing in ibgrMain.Options) and CanGo_to then
  begin
    PushForm;
    Go_to(GetAsyncKeyState(VK_LCONTROL) shr 1 > 0);
  end else
    inherited;
end;

procedure Tgdv_frmAcctBaseForm.actSaveGridSettingUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := iblConfiguratior.CurrentKey > '';
  FSaveGridSetting := iblConfiguratior.CurrentKey > '';
end;

procedure Tgdv_frmAcctBaseForm.actSaveGridSettingExecute(Sender: TObject);
var
  SQL: TIBSQL;
  DidActivate: Boolean;
  Str: TStream;
  Config: TBaseAcctConfig;
  Transaction: TIBTransaction;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := gdcBaseManager.Database;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      DidActivate := not Transaction.InTransaction;
      if DidActivate then
        Transaction.StartTransaction;
      try
        SQL.SQL.text := 'SELECT * FROM ac_acct_config WHERE id = :id';
        SQL.ParamByName(fnId).AsInteger := iblConfiguratior.CurrentKeyInt;
        SQL.ExecQuery;

        if SQL.RecordCount > 0 then
        begin
          Str := TMemoryStream.Create;
          try
            SQL.FieldByName(fnConfig).SaveToStream(Str);

            Str.Position := 0;
            Config := LoadConfigFromStream(Str);

            if Config = nil then
              Exit;

            try
              ibgrMain.SaveToStream(Config.GridSettings);

              SQL.Close;
              SQL.SQL.Text := 'UPDATE ac_acct_config SET config = :config WHERE id = :id';

              SQL.ParamByName(fnId).asInteger := iblConfiguratior.CurrentKeyInt;
              Str.Size := 0;
              SaveConfigToStream(Config, Str);

              Str.Position := 0;
              SQL.ParamByName(fnConfig).LoadFromStream(Str);

              SQL.ExecQuery;
            finally
              Config.Free;
            end;
          finally
            Str.Free;
          end;
        end;
        if DidActivate then
          Transaction.Commit;
      except
        if DidActivate then
          Transaction.Rollback;
      end;
    finally
      SQl.Free;
    end;
  finally
    Transaction.Free;
  end;
end;

procedure Tgdv_frmAcctBaseForm.actClearGridSettingExecute(Sender: TObject);
var
  SQL: TIBSQL;
  DidActivate: Boolean;
  Str: TStream;
  Config: TBaseAcctConfig;
  Transaction: TIBTransaction;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := gdcBaseManager.Database;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      DidActivate := not Transaction.InTransaction;
      if DidActivate then
        Transaction.StartTransaction;
      try
        SQL.SQL.text := 'SELECT * FROM ac_acct_config WHERE id = :id';
        SQL.ParamByName(fnId).AsInteger := iblConfiguratior.CurrentKeyInt;
        SQL.ExecQuery;

        if SQL.RecordCount > 0 then
        begin
          Str := TMemoryStream.Create;
          try
            SQL.FieldByName(fnConfig).SaveToStream(Str);

            Str.Position := 0;
            Config := LoadConfigFromStream(Str);

            if Config = nil then
              Exit;

            try
              Config.GridSettings.Size := 0;

              SQL.Close;
              SQL.SQL.Text := 'UPDATE ac_acct_config SET config = :config WHERE id = :id';

              SQL.ParamByName(fnId).asInteger := iblConfiguratior.CurrentKeyInt;
              Str.Size := 0;
              SaveConfigToStream(Config, Str);

              Str.Position := 0;
              SQL.ParamByName(fnConfig).LoadFromStream(Str);

              SQL.ExecQuery;
            finally
              Config.Free;
            end;
          finally
            Str.Free;
          end;
        end;
        if DidActivate then
          Transaction.Commit;
      except
        if DidActivate then
          Transaction.Rollback;
      end;
    finally
      SQl.Free;
    end;
  finally
    Transaction.Free;
  end;
end;

procedure Tgdv_frmAcctBaseForm.PushForm;
var
  Index: Integer;
begin
  Index := AcctFormList.IndexOf(Self);
  if Index = - 1 then
  begin
    AcctFormList.Add(Self);
  end else
  begin
    AcctFormList.Move(Index, AcctFormList.Count - 1);
  end;
end;

procedure Tgdv_frmAcctBaseForm.actBackUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (AcctFormList_ <> nil) and (AcctFormList_.Count > 0) and
    (AcctFormList_.Items[AcctFormList_.Count - 1] <> Self);
end;

procedure Tgdv_frmAcctBaseForm.actBackExecute(Sender: TObject);
begin
  TWinControl(AcctFormList.Items[AcctFormList.Count - 1]).BringToFront;
  AcctFormList.Delete(AcctFormList.Count - 1);
end;

function Tgdv_frmAcctBaseForm.GetGdvObject: TgdvAcctBase;
begin
  Result := nil;
end;

initialization
  RegisterFrmClass(Tgdv_frmAcctBaseForm);
finalization
  FreeAndNil(AcctFormList_);
  UnRegisterFrmClass(Tgdv_frmAcctBaseForm);

end.
