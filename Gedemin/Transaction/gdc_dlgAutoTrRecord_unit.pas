unit gdc_dlgAutoTrRecord_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls, gsIBLookupComboBox, Mask,
  DBCtrls, gd_ClassList, IBCustomDataSet, gdcBase, gdcCustomFunction,
  gdcFunction, gdcBaseInterface, prm_ParamFunctions_unit, gdcConstants,
  ExtCtrls, rp_report_const;

type
  Tgdc_dlgAutoTrRecord = class(Tgdc_dlgG)
    actWizard: TAction;
    dsFunction: TDataSource;
    gdcFunction: TgdcFunction;
    Panel1: TPanel;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    dbeFumctionName: TDBEdit;
    Button1: TButton;
    dbcbShowInExplorer: TDBCheckBox;
    Bevel1: TBevel;
    iblFolder: TgsIBLookupComboBox;
    lShowInFolder: TLabel;
    lImage: TLabel;
    cbImage: TComboBox;
    iblcAccountChart: TgsIBLookupComboBox;
    Label3: TLabel;
    procedure actWizardExecute(Sender: TObject);
    procedure cbImageDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbImageDropDown(Sender: TObject);
    procedure dbcbShowInExplorerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbImageClick(Sender: TObject);
    procedure actWizardUpdate(Sender: TObject);
  private
    { Private declarations }
    FScriptChanged: Boolean;
  protected
    procedure SetupRecord; override;
    procedure SetupDialog; override;

    procedure Post; override;
    procedure Cancel; override;
    procedure FillImageList;
    class function DefImageIndex: Integer; virtual;
    class function DefFolderKey: Integer; virtual;
  public
    { Public declarations }
    function TestCorrect: Boolean; override;
  end;

  Egdc_dlgAutoTrRecord = class(Exception);
var
  gdc_dlgAutoTrRecord: Tgdc_dlgAutoTrRecord;

implementation
uses wiz_Main_Unit, gd_security_operationconst, gd_security,
  gd_i_ScriptFactory, dmImages_unit;
{$R *.DFM}

{ Tgdc_dlgAutoTrRecord }

function Tgdc_dlgAutoTrRecord.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGAUTOTRRECORD', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGAUTOTRRECORD', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTRRECORD') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTRRECORD',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTRRECORD' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := inherited TestCorrect;

  if Result and (gdcObject.FieldByName(fnDESCRIPTION).AsString = '') then
  begin
    Result := False;
    gdcObject.FieldByName(fnDESCRIPTION).FocusControl;
    raise Egdc_dlgAutoTrRecord.Create('Укажите описание автоматической операции!');
  end;

  if Result and (gdcObject.FieldByName(fnFUNCTIONKEY).IsNull) then
  begin
    Result := False;
    gdcObject.FieldByName(fnFUNCTIONKEY).FocusControl;
    raise Egdc_dlgAutoTrRecord.Create('Укажите функцию автоматической операции!');
  end;

  if Result and (gdcObject.FieldByName(fnSHOWINEXPLORER).AsInteger = 1) and
    (gdcObject.FieldByName(fnFOLDERKEY).AsInteger <= 0) then
  begin
    Result := False;
    gdcObject.FieldByName(fnFOLDERKEY).FocusControl;
    raise Egdc_dlgAutoTrRecord.Create('Укажите папку!');
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTRRECORD', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTRRECORD', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTrRecord.actWizardExecute(Sender: TObject);
var
  F: TdlgFunctionWisard;
  D: TDataSet;
  Str, PStr: TStream;
  Params: TgsParamList;
  FunctionCreater: TNewEntryFunctionCreater;
  DS: TDataSetState;
  NewFun: Boolean;
begin
  F := TdlgFunctionWisard.Create(Application);
  try
    D := dsgdcBase.DataSet;
    if D <> nil then
    begin
      DS := gdcFunction.State;
      NewFun := False;
      if not (DS in [dsEdit, dsInsert]) then
      begin
        if D.FieldByName(fnFunctionKey).AsInteger = 0 then
        begin
          if not D.FieldByName(fnFunctionKey).IsNull then
            D.FieldByName(fnFunctionKey).Clear;

          gdcFunction.Insert;
          gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;
          gdcFunction.FieldByName(fnModule).AsString := scrEntryModuleName;
          gdcFunction.FieldByName(fnName).AsString := Format('AutoEntryScript%d_%d',
            [gdcFunction.FieldByName(fnId).AsInteger, IbLogin.DBID]);
          gdcFunction.FieldByName(fnLANGUAGE).AsString := DefaultLanguage;
          NewFun := True;
        end else
          gdcFunction.Edit;
      end;

      Str := D.CreateBlobStream(D.FieldByName(fnFunctionTemplate), bmReadWrite);
      try
        FunctionCreater := TNewEntryFunctionCreater.Create;
        try
          FunctionCreater.FunctionRUID := RUIDToStr(gdcFunction.GetRUID);
          FunctionCreater.Stream := Str;
          FunctionCreater.FunctionName := gdcFunction.FieldByName(fnName).AsString;
          FunctionCreater.TransactionRUID := gdcBaseManager.GetRUIDStringByID(D.FieldByName(fnTransactionkey).AsInteger);
          FunctionCreater.TrRecordRUID := gdcBaseManager.GetRUIDStringByID(D.FieldByName(fnId).AsInteger);
          FunctionCreater.CardOfAccountRUID := gdcBaseManager.GetRUIDStringByID(gdcObject.FieldByName(fnAccountKey).AsInteger);
          F.CreateNewFunction(FunctionCreater);
        finally
          FunctionCreater.Free;
        end;

        if NewFun
          and (gdcFunction.FieldByName(fnName).AsString <> '')
          and (AnsiCompareText(F.MainFunctionName, gdcFunction.FieldByName(fnName).AsString) <> 0)  then
        begin
          F.MainFunctionName := gdcFunction.FieldByName(fnName).AsString;
        end;  

        FScriptChanged := F.ShowModal = mrOk;
        if FScriptChanged then
        begin
          Str.size := 0;
          Str.Position := 0;
          F.SaveToStream(Str);
          gdcFunction.FieldByName(fnScript).AsString := F.Script;
          gdcFunction.FieldByName(fnName).AsString := F.MainFunctionName;
          Params := TgsParamList.Create;
          try
            Params.Assign(F.Params);
            PStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmWrite);
            try
              Pstr.Size := 0;
              PStr.Position := 0;
              Params.SaveToStream(PStr);
            finally
              PStr.Free;
            end;
          finally
            Params.Free;
          end;
          D.FieldByName(fnfunctionkey).AsInteger :=
            gdcFunction.FieldByName(fnid).AsInteger;
        end else
        begin
          if not (DS in [dsEdit, dsInsert]) then
          begin
            gdcFunction.Cancel;
          end;
        end;
      finally
        Str.Free;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure Tgdc_dlgAutoTrRecord.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTRRECORD', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTRRECORD', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTRRECORD',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if gdcObject.State = dsInsert then
  begin
    gdcObject.FieldByName(fnFunctionKey).Clear;
    gdcObject.FieldByName(fnImageIndex).AsInteger := DefImageIndex;
    gdcObject.FieldByName(fnFolderKey).AsInteger := DefFolderKey;
    gdcObject.FieldByName(fnAccountKey).AsInteger := IbLogin.ActiveAccount;
  end;
  cbImage.ItemIndex := gdcObject.FieldByName(fnImageIndex).AsInteger;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTRRECORD', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTRRECORD', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTrRecord.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTRRECORD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTRRECORD', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTRRECORD',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gdcFunction.Transaction := gdcObject.Transaction;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTRRECORD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTRRECORD', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTrRecord.Cancel;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTRRECORD', 'CANCEL', KEYCANCEL)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTRRECORD', KEYCANCEL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCANCEL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTRRECORD',
  {M}          'CANCEL', KEYCANCEL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if gdcFunction.State in [dsEdit, dsInsert] then
    gdcFunction.Cancel;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTRRECORD', 'CANCEL', KEYCANCEL)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTRRECORD', 'CANCEL', KEYCANCEL);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTrRecord.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTRRECORD', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTRRECORD', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTRRECORD',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if gdcFunction.State in [dsEdit, dsInsert] then
    gdcFunction.Post;
    
  inherited;

  if FScriptChanged then
  begin
    ScriptFactory.ReloadFunction(gdcObject.FieldByName('functionkey').AsInteger);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTRRECORD', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTRRECORD', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTrRecord.cbImageDrawItem(Control: TWinControl;
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

procedure Tgdc_dlgAutoTrRecord.cbImageDropDown(Sender: TObject);
begin
  FillImageList;
end;

procedure Tgdc_dlgAutoTrRecord.FillImageList;
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

procedure Tgdc_dlgAutoTrRecord.dbcbShowInExplorerClick(Sender: TObject);
begin
  iblFolder.Enabled := dbcbShowInExplorer.Checked;
  cbImage.Enabled := dbcbShowInExplorer.Checked;
end;

class function Tgdc_dlgAutoTrRecord.DefFolderKey: Integer;
begin
  Result := 714000;
end;

class function Tgdc_dlgAutoTrRecord.DefImageIndex: Integer;
begin
  Result := 126;
end;

procedure Tgdc_dlgAutoTrRecord.FormCreate(Sender: TObject);
begin
  inherited;
  FillImageList;
end;

procedure Tgdc_dlgAutoTrRecord.cbImageClick(Sender: TObject);
begin
  inherited;
  gdcObject.FieldByName('imageindex').AsInteger := cbImage.ItemIndex;
end;

procedure Tgdc_dlgAutoTrRecord.actWizardUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcObject.FieldByName(fnAccountKey).AsInteger > 0;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAutoTrRecord);

finalization
  UnRegisterFrmClass(Tgdc_dlgAutoTrRecord);

end.
