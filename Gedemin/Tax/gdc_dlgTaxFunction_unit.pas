// ShlTanya, 12.03.2019

{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgTaxFunction_unit.pas

  Abstract

    Form for creation and editing function of financial report.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit gdc_dlgTaxFunction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Buttons, StdCtrls, Mask, DBCtrls, ExtCtrls, Menus, Db,
  ActnList, ToolWin, ComCtrls, TB2Dock, TB2ToolWindow, TB2Item, TB2Toolbar;

type
  Tgdc_dlgTaxFunction = class(Tgdc_dlgG)
    pnlMain: TPanel;
    lblFText: TLabel;
    lblFName: TLabel;
    edFName: TDBEdit;
    lblDescription: TLabel;
    mmDescription: TDBMemo;
    pnlTaxFunction: TPanel;
    mmTaxFunction: TDBMemo;
    actAddFunction: TAction;
    actTestFunction: TAction;
    actAddAccount: TAction;
    actAddAnalytics: TAction;
    tbdFunction: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    cbTest: TCheckBox;
    procedure actAddFunctionExecute(Sender: TObject);
    procedure actAddAccountExecute(Sender: TObject);
    procedure actAddAnalyticsExecute(Sender: TObject);
    procedure actTestFunctionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actOkExecute(Sender: TObject);
    procedure mmTaxFunctionChange(Sender: TObject);
  private

    procedure TestFunctionName;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
    procedure SaveSettings; override;
    procedure LoadSettings; override;
  end;

var
  gdc_dlgTaxFunction: Tgdc_dlgTaxFunction;

implementation

uses
  gd_ClassList, tax_frmAvailableTaxFunc_unit, gdc_frmAccountSel_unit,
  gdcTaxFunction, rp_ReportScriptControl, rp_BaseReport_unit,
  tax_frmAnalytics_unit, Storages, gsStorage_CompPath;

{$R *.DFM}

procedure Tgdc_dlgTaxFunction.actAddFunctionExecute(Sender: TObject);
begin
  with TfrmAvailableTaxFunc.CreateWithParams(Self,
    GetTID(gdcObject.FieldByName('taxactualkey')),
    gdcObject.FieldByName('name').AsString) do
  try
    if ShowModal = idOk then
    begin
      mmTaxFunction.SelText := SelectedFunction;
    end;
  finally
    Free;
  end;
end;

procedure Tgdc_dlgTaxFunction.actAddAccountExecute(Sender: TObject);
begin
  with TfrmAccountSel.Create(nil) do
  try
    if ShowModal = idOk then
      mmTaxFunction.SelText := '"' + ibcbAnalytics.Text + '"';
  finally
    Free;
  end
end;

procedure Tgdc_dlgTaxFunction.actAddAnalyticsExecute(Sender: TObject);
begin
  with TfrmAnalytics.Create(nil) do
  try
    if ShowModal = idOk then
    begin
      mmTaxFunction.SelText := '"' + Analytics + '"';
    end;
  finally
    Free
  end;
end;

procedure Tgdc_dlgTaxFunction.actTestFunctionExecute(Sender: TObject);
var
  TestFunction: TrpCustomFunction;
  TestRS: TReportScript;
  Script: String;
  ArrayEstabl: TArrayEstabl;
  ContainIncFunc: Boolean;
begin
  TestFunctionName;
  TestFunction := TrpCustomFunction.Create;
  try
    TestFunction.Language := 'VBScript';
    Script := mmTaxFunction.Lines.Text;
    ConvertTFIntoScript(edFName.Text, Script, ArrayEstabl, ContainIncFunc);

    TestFunction.Script.Text := Script;
    TestRS := TReportScript.Create(nil);
    try
      TestRS.AddScript(TestFunction);
    finally
      TestRS.Free;
    end;
  finally
    TestFunction.Free;
  end;
  if ModalResult = mrNone then
    MessageBox(Handle,
      PChar('Тест успешно завершен.' + #13#10 + 'Синтаксические ошибки не обнаружены.'),
      PChar('Тест функции'), MB_OK or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST);
end;

constructor Tgdc_dlgTaxFunction.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure Tgdc_dlgTaxFunction.TestFunctionName;
var
  FName: String;
  I: Integer;

const
  tDigits = '1234567890';
  tCurSym = '1234567890_qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
begin
  FName := Trim(edFName.Text);
  TgdcTaxFunction(gdcObject).TestFunctionName(FName);
  if Length(FName) = 0 then
    raise Exception.Create('Имя функции не может буть пустым.');

  if Pos(FName[1], tDigits) > 0 then
    raise Exception.Create('Имя функции не может начинаться цифрой.');

  for I := 1 to Length(FName) do
    if Pos(FName[I], tCurSym) = 0 then
      raise Exception.Create('Имя функции содержит некорректные символы.');
end;

procedure Tgdc_dlgTaxFunction.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = idOk then
  begin
    TestFunctionName;
    if cbTest.Checked then
      actTestFunctionExecute(Sender);
  end;

  inherited;
end;

procedure Tgdc_dlgTaxFunction.actOkExecute(Sender: TObject);
begin
  inherited;
//hghfg
end;

procedure Tgdc_dlgTaxFunction.mmTaxFunctionChange(Sender: TObject);
begin
  inherited;
  if gdcObject.FieldByName('taxfunction').AsString <> mmTaxFunction.Lines.Text then
    SetTID(gdcObject.FieldByName('id'), gdcObject.ID);
end;

procedure Tgdc_dlgTaxFunction.LoadSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  S: String;
//  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTAXFUNCTION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTAXFUNCTION', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXFUNCTION',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    S := BuildComponentPath(Self);
    cbTest.Checked := UserStorage.ReadBoolean(S, 'TestOfClose');

{    I := UserStorage.ReadInteger(S, 'edFNameWidth');
    if I > 0 then
      edFName.Width := I;
    I := UserStorage.ReadInteger(S, 'pnlTaxFunctionWidth');
    if I > 0 then
      pnlTaxFunction.Width := I;
    I := UserStorage.ReadInteger(S, 'tbdFunctionWidth');
    if I > 0 then
      tbdFunction.Width := I;
    I := UserStorage.ReadInteger(S, 'mmTaxFunctionWidth');
    if I > 0 then
      mmTaxFunction.Width := I;
    I := UserStorage.ReadInteger(S, 'mmDescriptionWidth');
    if I > 0 then
      mmDescription.Width := I
      }
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXFUNCTION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXFUNCTION', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTaxFunction.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTAXFUNCTION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTAXFUNCTION', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXFUNCTION',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    S := BuildComponentPath(Self);
    UserStorage.WriteBoolean(S, 'TestOfClose', cbTest.Checked);

{    UserStorage.WriteInteger(S, 'edFNameWidth', edFName.Width);
    UserStorage.WriteInteger(S, 'pnlTaxFunctionWidth', pnlTaxFunction.Width);
    UserStorage.WriteInteger(S, 'tbdFunctionWidth',    tbdFunction.Width);
    UserStorage.WriteInteger(S, 'mmTaxFunctionWidth',  mmTaxFunction.Width);
    UserStorage.WriteInteger(S, 'mmDescriptionWidth',  mmDescription.Width);
    }
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXFUNCTION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXFUNCTION', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTaxFunction.Loaded;
var
  LLeft, LWidth: Integer;
begin
  inherited;
  LLeft := 8;
  LWidth := pnlMain.ClientWidth - 2 * LLeft;

  edFName.Left := LLeft;
  edFName.Width := LWidth;

  pnlTaxFunction.Left := LLeft;
  pnlTaxFunction.Width := LWidth;

  mmDescription.Left := LLeft;
  mmDescription.Width := LWidth;

  lblFText.Left := LLeft;
  lblDescription.Left := LLeft;
  cbTest.Left := LLeft;
end;

initialization
  RegisterFrmClass(Tgdc_dlgTaxFunction);

finalization
  UnRegisterFrmClass(Tgdc_dlgTaxFunction);

end.
