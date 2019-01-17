// andreik 15.01.2019


{
  Адм. территориальная единица
}

unit gdc_dlgPlace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, Db, gdc_dlgTRPC_unit, Menus, gdc_dlgG_unit,
  IBDatabase, at_Container, ComCtrls;

type
  Tgdc_dlgPlace = class(Tgdc_dlgTRPC)
    cbMaster: TgsIBLookupComboBox;
    dbeTelPrefix: TDBEdit;
    dbedName: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    DBComboBox1: TDBComboBox;
    Label4: TLabel;
    Label5: TLabel;
    dbeCode: TDBEdit;
    Label6: TLabel;
    edGEOCoord: TEdit;
    btnShowMap: TButton;
    actShowMap: TAction;
    procedure actShowMapExecute(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
    procedure BeforePost; override;
  end;

var
  gdc_dlgPlace: Tgdc_dlgPlace;

implementation
{$R *.DFM}

uses
  gdcBase, gd_ClassList, ShellAPI, gd_common_functions, gd_directories_const;

{ Tgd_dlgPlace }

class function Tgdc_dlgPlace.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_dlgPlace) then
    gdc_dlgPlace := Tgdc_dlgPlace.Create(AnOwner);
  Result := gdc_dlgPlace;
end;

procedure Tgdc_dlgPlace.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Lat, Lon: Double;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGPLACE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGPLACE', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGPLACE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGPLACE',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGPLACE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Trim(edGEOCoord.Text) = '' then
  begin
    gdcObject.FieldbyName('lat').Clear;
    gdcObject.FieldbyName('lon').Clear;
  end else
  begin
    if GEOString2Coord(edGEOCoord.Text, Lat, Lon) then
    begin
      gdcObject.FieldbyName('lat').AsFloat := Lat;
      gdcObject.FieldbyName('lon').AsFloat := Lon;
    end else
      raise Exception.Create('Invalid GEO coordinates');
  end;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGPLACE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGPLACE', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgPlace.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGPLACE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGPLACE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGPLACE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGPLACE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGPLACE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (not gdcObject.FieldByName('lat').IsNull)
    and (not gdcObject.FieldByName('lon').IsNull) then
  begin
    edGEOCoord.Text := GEOCoord2String(gdcObject.FieldByName('lat').AsFloat, gdcObject.FieldByName('lon').AsFloat);
  end else
    edGEOCoord.Text := '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGPLACE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGPLACE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;


function Tgdc_dlgPlace.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Lat, Lon: Double;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGPLACE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGPLACE', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGPLACE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGPLACE',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGPLACE' then
  {M}      begin
  {M}        Result := inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := (inherited TestCorrect)
    and (
      (Trim(edGEOCoord.Text) = '')
      or
      GEOString2Coord(edGEOCoord.Text, Lat, Lon)
    );

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGPLACE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGPLACE', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgPlace.actShowMapExecute(Sender: TObject);
var
  S: String;
  Lat, Lon: Double;
begin
  if GEOString2Coord(edGEOCoord.Text, Lat, Lon) then
  begin
    S := StringReplace(edGEOCoord.Text, ',', '+', []);
    ShellExecute(Handle,
      'open',
      PChar(GoogleGEOSearch + S),
      nil,
      nil,
      SW_SHOW);
  end else
    ShellExecute(Handle,
      'open',
      GoogleGEOHome,
      nil,
      nil,
      SW_SHOW);
end;

initialization
  RegisterFrmClass(Tgdc_dlgPlace);

finalization
  UnRegisterFrmClass(Tgdc_dlgPlace);
end.
