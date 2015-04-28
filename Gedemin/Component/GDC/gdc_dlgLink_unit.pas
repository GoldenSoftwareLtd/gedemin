unit gdc_dlgLink_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, gdcBase;

type
  Tgdc_dlgLink = class(Tgdc_dlgTRPC)
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    DBEdit7: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Button1: TButton;
    actOpenLinkedObject: TAction;
    procedure actOpenLinkedObjectUpdate(Sender: TObject);
    procedure actOpenLinkedObjectExecute(Sender: TObject);

  protected
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgLink: Tgdc_dlgLink;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcLink
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_dlgLink.actOpenLinkedObjectUpdate(Sender: TObject);
begin
  actOpenLinkedObject.Enabled := Assigned(gdcObject)
    and (gdcObject.FieldByName('linkedkey').AsInteger > 0)
    and (gdcObject.FieldByName('linkedclass').AsString > '');
end;

procedure Tgdc_dlgLink.actOpenLinkedObjectExecute(Sender: TObject);
var
  Obj: TgdcBase;
begin
  Obj := (gdcObject as TgdcLink).CreateLinkedObject(
    gdcObject.FieldByName('linkedclass').AsString,
    gdcObject.FieldByName('linkedsubtype').AsString,
    gdcObject.ID,
    gdcObject.FieldByName('linkedkey').AsInteger);
  try
    if Obj <> nil then
      Obj.EditDialog;
  finally
    Obj.Free;
  end;
end;

function Tgdc_dlgLink.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGLINK', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGLINK', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGLINK') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGLINK',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGLINK' then
  {M}      begin
  {M}        Result := inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result then
  begin
    if not (gdClassList.Find(gdcObject.FieldByName('linkedclass').AsString) is TgdBaseEntry) then
    begin
      Result := MessageBox(Self.Handle,
        'Возможно введен неверный класс прикрепленного объекта. Сохранить?',
        'Внимание',
        MB_YESNO or MB_ICONQUESTION) = IDYES;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGLINK', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGLINK', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgLink);

finalization
  UnRegisterFrmClass(Tgdc_dlgLink);
end.
