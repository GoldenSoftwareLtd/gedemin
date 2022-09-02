// andreik, 15.01.2019

unit gdc_dlgDepartment_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, StdCtrls, Mask, DBCtrls, IBDatabase, Menus, Db,
  ActnList, at_Container, ComCtrls, gsIBLookupComboBox, gdcBase;

type
  Tgdc_dlgDepartment = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedName: TDBEdit;
    iblkupCompany: TgsIBLookupComboBox;
    iblkupDepartment: TgsIBLookupComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label9: TLabel;
    gsiblkupAddress: TgsIBLookupComboBox;
    Label4: TLabel;
    dbedCountry: TDBEdit;
    dbedDistrict: TDBEdit;
    dbedCity: TDBEdit;
    Label13: TLabel;
    Label5: TLabel;
    dbedArea: TDBEdit;
    Label6: TLabel;
    Label31: TLabel;
    dbmAddress: TDBMemo;
    Label10: TLabel;
    dbeZIP: TDBEdit;
    Label7: TLabel;
    dbePbox: TDBEdit;
    Label11: TLabel;
    dbeEmail: TDBEdit;
    Label17: TLabel;
    dbedWWW: TDBEdit;
    Label66: TLabel;
    dbePhone: TDBEdit;
    Label67: TLabel;
    dbeFax: TDBEdit;
    dbcbDisabled: TDBCheckBox;
    Label8: TLabel;
    edGEOCoord: TEdit;
    btnShowMap: TButton;
    actShowOnMap: TAction;
    procedure iblkupCompanyChange(Sender: TObject);
    procedure iblkupDepartmentCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure actShowOnMapExecute(Sender: TObject);

  protected
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;

  public
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
    procedure BeforePost; override;
  end;

var
  gdc_dlgDepartment: Tgdc_dlgDepartment;

implementation

{$R *.DFM}

uses
  IBSQL, gd_ClassList, gdcBaseInterface, ShellAPI, gd_common_functions,
  gd_directories_const;

procedure Tgdc_dlgDepartment.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Lat, Lon: Double;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDEPARTMENT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDEPARTMENT', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEPARTMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEPARTMENT',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEPARTMENT' then
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

  if iblkupDepartment.CurrentKey > '' then
  begin
    if GetTID(gdcObject.FieldByName('parent')) <> iblkupDepartment.CurrentKeyInt then
      SetTID(gdcObject.FieldByName('parent'), iblkupDepartment.CurrentKeyInt);
  end else
  begin
    if (iblkupCompany.CurrentKey > '') and (GetTID(gdcObject.FieldByName('parent')) <> iblkupCompany.CurrentKeyInt) then
      SetTID(gdcObject.FieldByName('parent'), iblkupCompany.CurrentKeyInt);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEPARTMENT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEPARTMENT', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDepartment.iblkupCompanyChange(Sender: TObject);
begin
  if iblkupCompany.CurrentKey > '' then
  begin
    iblkupDepartment.Condition := Format(
      'contacttype=4 AND lb > (SELECT c1.lb FROM gd_contact c1 WHERE c1.id = %0:s) AND rb <= (SELECT c1.rb FROM gd_contact c1 WHERE c1.id = %0:s)',
      [iblkupCompany.CurrentKey]);
    iblkupDepartment.ReadOnly := False;
    iblkupDepartment.CurrentKey := iblkupDepartment.CurrentKey;
  end;
end;

function Tgdc_dlgDepartment.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGDEPARTMENT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGDEPARTMENT', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEPARTMENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEPARTMENT',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEPARTMENT' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if AnsiCompareText(ARelationName, 'GD_HOLDING') = 0 then
    Result := False
  else if AnsiCompareText(ARelationName, 'GD_CONTACTLIST') = 0 then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEPARTMENT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEPARTMENT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDepartment.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDEPARTMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDEPARTMENT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEPARTMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEPARTMENT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEPARTMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (not gdcObject.FieldByName('lat').IsNull)
    and (not gdcObject.FieldByName('lon').IsNull) then
  begin
    edGEOCoord.Text := GEOCoord2String(gdcObject.FieldByName('lat').AsFloat, gdcObject.FieldByName('lon').AsFloat);
  end else
    edGEOCoord.Text := '';

  inherited;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcObject.ReadTransaction;
    q.SQL.Text :=
      'SELECT c.id as companykey FROM gd_contact c JOIN gd_contact d ' +
      '  ON c.lb <= d.lb AND c.rb >= d.rb ' +
      'WHERE d.id = :ID AND c.contacttype = 3 ';
    SetTID(q.ParamByName('id'), gdcObject.FieldByName('parent'));
    q.ExecQuery;

    if q.EOF or q.FieldByName('companykey').IsNull then
    begin
      iblkupCompany.CurrentKeyInt := -1;
      iblkupCompany.ReadOnly := False;

      iblkupDepartment.CurrentKeyInt := -1;
      iblkupDepartment.ReadOnly := True;
    end else
    begin
      iblkupCompany.CurrentKeyInt := GetTID(q.FieldByName('companykey'));
      iblkupCompany.ReadOnly := True;

      iblkupDepartment.Condition :=
        Format('contacttype=4 AND lb > (SELECT c1.lb FROM gd_contact c1 WHERE c1.id=%0:s) AND rb <= (SELECT c2.rb FROM gd_contact c2 WHERE c2.id=%0:s)',
        [TID2S(q.FieldByName('companykey'))]);
      iblkupDepartment.CurrentKeyInt := GetTID(gdcObject.FieldByName('parent'));
      iblkupDepartment.ReadOnly := False;
    end;
  finally
    q.Free;
  end;

  if not gdcObject.CanChangeRights then
  begin
    iblkupCompany.ReadOnly := True;
    iblkupDepartment.ReadOnly := True;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEPARTMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEPARTMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDepartment.iblkupDepartmentCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if iblkupCompany.CurrentKey > '' then
    SetTID(ANewObject.FieldByName('parent'), iblkupCompany.CurrentKeyInt);
end;

procedure Tgdc_dlgDepartment.actShowOnMapExecute(Sender: TObject);
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

function Tgdc_dlgDepartment.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Lat, Lon: Double;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGDEPARTMENT', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGDEPARTMENT', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEPARTMENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEPARTMENT',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEPARTMENT' then
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

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEPARTMENT', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEPARTMENT', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgDepartment);

finalization
  UnRegisterFrmClass(Tgdc_dlgDepartment);
end.
