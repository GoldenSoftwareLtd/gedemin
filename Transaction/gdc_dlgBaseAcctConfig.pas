unit gdc_dlgBaseAcctConfig;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls,
  gdv_frameBaseAnalitic_unit, gdv_frameQuantity_unit, gdv_frameSum_unit,
  Mask, DBCtrls, ComCtrls, AcctUtils, gdv_AcctConfig_unit, AcctStrings,
  gdv_frameAnalyticValue_unit, gd_ClassList, gd_common_functions, IBSQL,
  gsIBLookupComboBox, dmImages_unit, Storages, gsStorage_CompPath;

type
  TdlgBaseAcctConfig = class(Tgdc_dlgTR)
    PageControl: TPageControl;
    tsGeneral: TTabSheet;
    frSum: TframeSum;
    frQuantity: TframeQuantity;
    Label2: TLabel;
    lAccounts: TLabel;
    dbeName: TDBEdit;
    cbAccounts: TComboBox;
    cbSubAccounts: TCheckBox;
    cbIncludeInternalMovement: TCheckBox;
    tsAnalytics: TTabSheet;
    Button1: TButton;
    actAccounts: TAction;
    GroupBox1: TGroupBox;
    dbcShowInExplorer: TDBCheckBox;
    lShowInFolder: TLabel;
    iblFolder: TgsIBLookupComboBox;
    lImage: TLabel;
    cbImage: TDBComboBox;
    cbExtendedFields: TCheckBox;
    frAnalytics: TframeAnalyticValue;
    procedure actAccountsExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbSubAccountsClick(Sender: TObject);
    procedure cbAccountsChange(Sender: TObject);
    procedure cbAccountsExit(Sender: TObject);
    procedure cbImageDropDown(Sender: TObject);
    procedure cbImageDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure dbcShowInExplorerClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FAccountIDs: TList;
    procedure UpdateControls; virtual;

    procedure DoLoadConfig(const Config: TBaseAcctConfig);virtual;
    procedure DoSaveConfig(Config: TBaseAcctConfig);virtual;
    class function ConfigClassName: string; virtual;
    procedure FillImageList;
    class function DefImageIndex: Integer; virtual;
    class function DefFolderKey: Integer; virtual;
  public
    { Public declarations }
    procedure SetupRecord; override;
    procedure BeforePost; override;
    function TestCorrect: Boolean; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  dlgBaseAcctConfig: TdlgBaseAcctConfig;

implementation
uses gd_security_operationconst;
{$R *.DFM}

procedure TdlgBaseAcctConfig.actAccountsExecute(Sender: TObject);
begin
  if AccountDialog(cbAccounts, 0) then
  begin
    if FAccountIDs <> nil then
      FAccountIDs.Clear;
    UpdateControls;
  end;
end;

procedure TdlgBaseAcctConfig.UpdateControls;
begin
  if FAccountIds = nil then
    FAccountIds := TList.Create;
  SetAccountIDs(cbAccounts, FAccountIDs, cbSubAccounts.Checked);
  frQuantity.UpdateAvail(FAccountIDs);
  frAnalytics.UpdateAnalytic(FAccountIDs);
end;

procedure TdlgBaseAcctConfig.FormDestroy(Sender: TObject);
begin
  inherited;
  FAccountIDs.Free;
end;

procedure TdlgBaseAcctConfig.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  C: TBaseAcctConfigClass;
  Str: TStream;
  Config: TBaseAcctConfig;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGBASEACCTCONFIG', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGBASEACCTCONFIG', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGBASEACCTCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGBASEACCTCONFIG',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGBASEACCTCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  gdcObject.FieldByName('classname').AsString := ConfigClassName;
  Str := gdcObject.CreateBlobStream(gdcObject.FieldByName(fnCONFIG), bmWrite);
  try
    SaveStringToStream(ConfigClassName, Str);
    TPersistentClass(C) := GetClass(ConfigClassName);
    if C <> nil then
    begin
      Config := C.Create;
      try
        DoSaveConfig(Config);
        Config.SaveToStream(Str);
      finally
        Config.Free;
      end;
    end;
  finally
    Str.Free;
  end;
  gdcObject.FieldByName('imageindex').AsInteger := cbImage.ItemIndex;
  SaveHistory(cbAccounts);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGBASEACCTCONFIG', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGBASEACCTCONFIG', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure TdlgBaseAcctConfig.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Str: TStream;
  C: TBaseAcctConfigClass;
  Config: TBaseAcctConfig;
  CName: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGBASEACCTCONFIG', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGBASEACCTCONFIG', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGBASEACCTCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGBASEACCTCONFIG',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGBASEACCTCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if gdcObject.State = dsEdit then
  begin
    Str := gdcObject.CreateBlobStream(gdcObject.FieldByName(fnCONFIG), bmRead);
    try
      CName := ReadStringFromStream(Str);
      TPersistentClass(C) := GetClass(CName);
      if C <> nil then
      begin
        Config := C.Create;
        try
          Config.LoadFromStream(Str);
          DoLoadConfig(Config);
        finally
          Config.Free;
        end;
      end;
    finally
      Str.Free;
    end;
  end else
  begin
    gdcObject.FieldByName('showinexplorer').AsInteger := 0; 
    gdcObject.FieldByName('imageindex').AsInteger := DefImageIndex;
    gdcObject.FieldByName('folder').AsInteger := DefFolderKey;
  end;
  cbImage.ItemIndex := gdcObject.FieldByName('imageindex').AsInteger;
  UpdateControls;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGBASEACCTCONFIG', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGBASEACCTCONFIG', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function TdlgBaseAcctConfig.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  var
    SQl: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TDLGBASEACCTCONFIG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TDLGBASEACCTCONFIG', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGBASEACCTCONFIG') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGBASEACCTCONFIG',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TDLGBASEACCTCONFIG' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  if gdcObject.FieldByName('name').IsNull then
  begin
    ShowMessage('Пожалуйста, введите наименование конфигурации.');
    Result := False;
  end else
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcObject.ReadTransaction;
      SQL.SQL.Text := 'SELECT * FROM ac_acct_config WHERE Upper(name) = :name and Upper(classname) = :classname AND ' +
        ' id <>  :id';
      SQL.ParamByName('name').AsString := UpperCase(gdcObject.FieldByName('name').AsString);
      SQL.ParamByName('classname').AsString := UpperCase(ConfigClassName);
      SQL.ParamByName('id').AsInteger := gdcObject.FieldByName('id').AsInteger;
      SQL.ExecQuery;
      if SQL.RecordCount > 0 then
      begin
        ShowMessage('Наименование конфигурации не уникально.'#13#10 +
          'Пожалуйста, введите другое наименование конфигурации.');
        Result := False;
      end else
      begin
        Result := inherited TestCorrect;
      end;
    finally
      SQL.Free;
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGBASEACCTCONFIG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGBASEACCTCONFIG', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure TdlgBaseAcctConfig.DoLoadConfig(const Config: TBaseAcctConfig);
begin
  with Config do
  begin
    cbAccounts.Text := Accounts;
    cbSubAccounts.Checked := IncSubAccounts;
    UpdateControls;
    
    cbIncludeInternalMovement.Checked := IncludeInternalMovement;

    frSum.InNcu := InNcu;
    frSum.NcuDecDigits := NcuDecDigits;
    frSum.NcuScale := NcuScale;

    frSum.InCurr := InCurr;
    frSum.CurrDecDigits := CurrDecDigits;
    frSum.CurrScale := CurrScale;
    frSum.Currkey := CurrKey;

    frSum.InEQ := InEQ;
    frSum.EQDecDigits := EQDecDigits;
    frSum.EQScale := EQScale;

    frSum.QuantityDecDigits := QuantityDecDigits;
    frSum.QuantityScale := QuantityScale;

    frQuantity.Values := Quantity;
    frAnalytics.Values := Analytics;

    cbExtendedFields.Checked := ExtendedFields;
  end;
end;

procedure TdlgBaseAcctConfig.DoSaveConfig(Config: TBaseAcctConfig);
begin
  with Config do
  begin
    Accounts := cbAccounts.Text;
    IncSubAccounts := cbSubAccounts.Checked;
    IncludeInternalMovement := cbIncludeInternalMovement.Checked;

    InNcu := frSum.InNcu;
    NcuDecDigits := frSum.NcuDecDigits;
    NcuScale := frSum.NcuScale;

    InCurr := frSum.InCurr;
    CurrDecDigits := frSum.CurrDecDigits;
    CurrScale := frSum.CurrScale;
    CurrKey := frSum.Currkey;

    InEQ := frSum.InEQ;
    EQDecDigits := frSum.EQDecDigits;
    EQScale := frSum.EQScale;

    QuantityDecDigits := frSum.QuantityDecDigits;
    QuantityScale := frSum.QuantityScale;

    Quantity := frQuantity.Values;
    Analytics := frAnalytics.Values;

    ExtendedFields := cbExtendedFields.Checked;
  end;
end;

procedure TdlgBaseAcctConfig.cbSubAccountsClick(Sender: TObject);
begin
  if FAccountIDs <> nil then
    FAccountIDs.Clear;
  UpdateControls;
end;

procedure TdlgBaseAcctConfig.cbAccountsChange(Sender: TObject);
begin
  if FAccountIDs <> nil then
    FAccountIDs.Clear;
end;

procedure TdlgBaseAcctConfig.cbAccountsExit(Sender: TObject);
begin
  UpdateControls;
end;

class function TdlgBaseAcctConfig.ConfigClassName: string;
begin
  Result := 'TBaseAcctConfigClass';
end;

procedure TdlgBaseAcctConfig.cbImageDropDown(Sender: TObject);
begin
  FillImageList;
end;

procedure TdlgBaseAcctConfig.cbImageDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  C: TCanvas;
begin
  C := TComboBox(Control).Canvas;
  if odSelected in State then
    C.Brush.Color := clHighlight
  else
    C.Brush.Color := clWindow;

  C.Brush.Style := bsSolid;
  C.FillRect(Rect);

  if odFocused in State then
    C.FrameRect(Rect);
  dmImages.il16x16.Draw(C, Rect.Left, Rect.Top, Index, Control.Enabled);
end;

procedure TdlgBaseAcctConfig.FillImageList;
var
  I: Integer;
begin
  if cbImage.Items.Count <> dmImages.il16x16.Count then
  begin
    cbImage.Items.Clear;
    for I := 0 to dmImages.il16x16.Count - 1 do
    begin
      cbImage.Items.Add(IntToStr(I));
    end;
  end;
end;

procedure TdlgBaseAcctConfig.FormCreate(Sender: TObject);
begin
  inherited;
  FillImageList;
  frSum.NcuDecDigits := LocateDecDigits;
  frSum.CurrDecDigits := LocateDecDigits;
  frSum.EQDecDigits := LocateDecDigits;
end;

class function TdlgBaseAcctConfig.DefImageIndex: Integer;
begin
  Result := iiGreenCircle;
end;

class function TdlgBaseAcctConfig.DefFolderKey: Integer;
begin
  Result := AC_ACCOUNTANCY;
end;

procedure TdlgBaseAcctConfig.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGBASEACCTCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGBASEACCTCONFIG', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGBASEACCTCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGBASEACCTCONFIG',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGBASEACCTCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    cbAccounts.Items.Text := UserStorage.ReadString(ComponentPath, 'AccountHistory', '');
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGBASEACCTCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGBASEACCTCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgBaseAcctConfig.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGBASEACCTCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGBASEACCTCONFIG', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGBASEACCTCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGBASEACCTCONFIG',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGBASEACCTCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    UserStorage.WriteString(ComponentPath, 'AccountHistory', cbAccounts.Items.Text);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGBASEACCTCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGBASEACCTCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgBaseAcctConfig.dbcShowInExplorerClick(Sender: TObject);
begin
  iblFolder.Enabled := dbcShowInExplorer.Checked;
  cbImage.Enabled := dbcShowInExplorer.Checked;;
end;

initialization
  RegisterFrmClass(TdlgBaseAcctConfig);

finalization
  UnRegisterFrmClass(TdlgBaseAcctConfig);

end.
