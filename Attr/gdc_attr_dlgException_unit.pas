unit gdc_attr_dlgException_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Db, ActnList, StdCtrls, Mask, DBCtrls, Menus,
  gdc_dlgG_unit, gdcBase;

type
  Tgdc_dlgException = class(Tgdc_dlgGMetaData)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    dbeName: TDBEdit;
    dbeMessage: TDBEdit;
    dbeLMessage: TDBEdit;
    procedure dbeNameEnter(Sender: TObject);
    procedure dbeNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbeNameKeyPress(Sender: TObject; var Key: Char);

  protected
    procedure BeforePost; override;
  end;

var
  gdc_dlgException: Tgdc_dlgException;

implementation

uses at_classes, gd_ClassList;
{$R *.DFM}

{ Tgdc_dlgException }

procedure Tgdc_dlgException.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGEXCEPTION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGEXCEPTION', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEXCEPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEXCEPTION',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEXCEPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  //  Если исключение не имеет префикса исключения-атрибута,
//  добавляем указанный префикс;
  with gdcObject do
    if (State = dsInsert) and
      (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('exceptionname').AsString)) <> 1)
    then
      FieldByName('exceptionname').AsString :=
        UserPrefix + FieldByName('exceptionname').AsString;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXCEPTION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXCEPTION', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgException.dbeNameEnter(Sender: TObject);
var
  S: string;
begin
  S:= '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_dlgException.dbeNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then begin
    CheckClipboardForName;
  end;
end;

procedure Tgdc_dlgException.dbeNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key:= CheckNameChar(Key);
end;

initialization
  RegisterFrmClass(Tgdc_dlgException);

finalization
  UnRegisterFrmClass(Tgdc_dlgException);

end.
