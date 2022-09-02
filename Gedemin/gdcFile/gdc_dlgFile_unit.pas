// ShlTanya, 24.02.2019

unit gdc_dlgFile_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgFileFolder_unit, Menus, Db, ActnList, StdCtrls, IBDatabase,
  gsIBLookupComboBox, Mask, DBCtrls, ExtCtrls;

type
  Tgdc_dlgFile = class(Tgdc_dlgFileFolder)
    actLoadDataFromFile: TAction;
    OpenDialog: TOpenDialog;
    actSaveDataToFile: TAction;
    SaveDialog: TSaveDialog;
    actViewFile: TAction;
    dbtDataSize: TDBText;
    GroupBox2: TGroupBox;
    btnLoad: TButton;
    btnSave: TButton;
    btnView: TButton;
    Image1: TImage;
    Label5: TLabel;
    Label6: TLabel;
    dbmDescription: TDBMemo;
    chbxZIP: TCheckBox;
    Label7: TLabel;
    procedure actLoadDataFromFileExecute(Sender: TObject);
    procedure actSaveDataToFileExecute(Sender: TObject);
    procedure actViewFileExecute(Sender: TObject);
    procedure actViewFileUpdate(Sender: TObject);
    procedure actSaveDataToFileUpdate(Sender: TObject);
    
  private

  protected
    procedure SetupRecord; override;
    procedure BeforePost; override;
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgFile: Tgdc_dlgFile;

implementation

uses
  gd_ClassList, gdcFile
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure Tgdc_dlgFile.actLoadDataFromFileExecute(Sender: TObject);
begin
  OpenDialog.InitialDir := ExtractFilePath((gdcObject as TgdcFile).RootDirectory +
    (gdcObject as TgdcFile).FullPath);
  if OpenDialog.Execute then
  begin
    (gdcObject as TgdcFile).LoadDataFromFile(OpenDialog.FileName, chbxZIP.Checked);
  end;
end;

procedure Tgdc_dlgFile.actSaveDataToFileExecute(Sender: TObject);
begin
  SaveDialog.InitialDir := ExtractFilePath((gdcObject as TgdcFile).RootDirectory +
    (gdcObject as TgdcFile).FullPath);
  SaveDialog.FileName := gdcObject.FieldByName('name').AsString;
  if SaveDialog.Execute then
  begin
    (gdcObject as TgdcFile).SaveDataToFile(SaveDialog.FileName);
  end;
end;

procedure Tgdc_dlgFile.actViewFileExecute(Sender: TObject);
begin
  (gdcObject as TgdcFile).ViewFile;
end;

procedure Tgdc_dlgFile.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFILE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFILE', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFILE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFILE',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFILE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFILE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFILE', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgFile.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFILE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFILE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFILE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFILE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFILE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

   inherited;
   ActivateTransaction(gdcObject.Transaction);
   
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFILE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFILE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}

end;

function Tgdc_dlgFile.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGFILE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGFILE', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFILE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFILE',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFILE' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result and (ExtractFileExt(gdcObject.ObjectName) = '') then
  begin
    if MessageBox(Handle,
      'В имени файла не указано расширение. Сохранить все равно?',
      'Внимание',
      MB_YESNO or MB_ICONQUESTION) = IDNO then
    begin
      Result := False;
      exit;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFILE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFILE', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgFile.actViewFileUpdate(Sender: TObject);
begin
  actViewFile.Enabled := Assigned(gdcObject)
     and (not gdcObject.FieldByName('data').IsNull);
end;

procedure Tgdc_dlgFile.actSaveDataToFileUpdate(Sender: TObject);
begin
  actSaveDataToFile.Enabled := Assigned(gdcObject)
     and (not gdcObject.FieldByName('data').IsNull);
end;

initialization
  RegisterFrmClass(Tgdc_dlgFile);

finalization
  UnRegisterFrmClass(Tgdc_dlgFile);

end.
