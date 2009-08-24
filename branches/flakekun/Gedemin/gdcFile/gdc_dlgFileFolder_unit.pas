unit gdc_dlgFileFolder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, Menus, Db, ActnList, StdCtrls, ExtCtrls, gdc_dlgG_unit,
  gsIBLookupComboBox, Mask, DBCtrls, IBDatabase, SynEditHighlighter;

type
  Tgdc_dlgFileFolder = class(Tgdc_dlgTR)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label2: TLabel;
    lkParent: TgsIBLookupComboBox;
    Label1: TLabel;
    dbName: TDBEdit;
    Label4: TLabel;
    dbtID: TDBText;
    lblDataSize: TLabel;

  protected
    procedure SetupRecord; override;
  end;

var
  gdc_dlgFileFolder: Tgdc_dlgFileFolder;

implementation
uses
  gd_ClassList, gdcFile;

{$R *.DFM}


{ Tgdc_dlgFileFolder }

procedure Tgdc_dlgFileFolder.SetupRecord;
VAR
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFILEFOLDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFILEFOLDER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFILEFOLDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFILEFOLDER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFILEFOLDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

   inherited;
   if (gdcObject is TgdcFileFolder) then
   begin
     lblDataSize.Caption := IntToStr((gdcObject as TgdcFileFolder).FolderSize);
   end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFILEFOLDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFILEFOLDER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}

end;

initialization
  RegisterFrmClass(Tgdc_dlgFileFolder);

finalization
  UnRegisterFrmClass(Tgdc_dlgFileFolder);

end.
