// ShlTanya, 12.03.2019

unit gdc_dlgStorageFolder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, gsIBLookupComboBox;

type
  Tgdc_dlgStorageFolder = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedName: TDBEdit;
    btnOpenObject: TButton;
    actOpenObject: TAction;
    procedure actOpenObjectUpdate(Sender: TObject);
    procedure actOpenObjectExecute(Sender: TObject);

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgStorageFolder: Tgdc_dlgStorageFolder;

implementation

{$R *.DFM}

uses
  gdcBase,
  gdcUser,
  gdcContacts,
  gd_ClassList,
  gdcStorage_Types,
  gdcBaseInterface;

procedure Tgdc_dlgStorageFolder.actOpenObjectUpdate(Sender: TObject);
var
  F: Boolean;
begin
  F := (gdcObject <> nil)
    and (GetTID(gdcObject.FieldByName('int_data')) > 0)
    and (
      (gdcObject.FieldByName('data_type').AsString = cStorageUser) or
      (gdcObject.FieldByName('data_type').AsString = cStorageCompany));
  if F then
  begin
    actOpenObject.Visible := True;
    if gdcObject.FieldByName('data_type').AsString = cStorageUser then
      actOpenObject.Caption := 'Пользователь...'
    else
      actOpenObject.Caption := 'Организация...';
  end else
  begin
    actOpenObject.Visible := False;
    actOpenObject.Caption := 'Открыть объект...';
  end;
end;

procedure Tgdc_dlgStorageFolder.actOpenObjectExecute(Sender: TObject);
var
  Obj: TgdcBase;
begin
  if gdcObject.FieldByName('data_type').AsString = cStorageUser then
    Obj := TgdcUser.Create(Self)
  else
    Obj := TgdcCompany.Create(Self);
  try
    Obj.SubSet := 'ByID';
    Obj.ID := GetTID(gdcObject.FieldByName('int_data'));
    Obj.Open;
    if not Obj.IsEmpty then
      Obj.EditDialog;
  finally
    Obj.Free;
  end;
end;

procedure Tgdc_dlgStorageFolder.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSTORAGEFOLDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSTORAGEFOLDER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSTORAGEFOLDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSTORAGEFOLDER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSTORAGEFOLDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  dbedName.ReadOnly := gdcObject.IsEmpty or
    (Length(gdcObject.FieldByName('data_type').AsString) <> 1) or
    (gdcObject.FieldByName('data_type').AsString[1] <> cStorageFolder);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSTORAGEFOLDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSTORAGEFOLDER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgStorageFolder);

finalization
  UnRegisterFrmClass(Tgdc_dlgStorageFolder);
end.
