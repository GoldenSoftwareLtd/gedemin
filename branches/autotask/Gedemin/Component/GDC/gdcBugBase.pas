
unit gdcBugBase;

interface

uses
  Classes, Forms, gdcBase, gd_createable_form, gsStorage,
  gdcBaseInterface;

type
  TgdcBugBase = class(TgdcBase)
  private
    FBugAreas, FSubSystems: TStrings;

    procedure CheckAndAdd(S: TStrings; const AValue: String);

  protected
    procedure DoAfterPost; override;
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure _DoOnNewRecord; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetDialogDefaultsFields: String; override;

    // считывает из базы список областей и заполняет им
    // предоставленный объект
    procedure GetBugAreas(S: TStrings);

    //
    procedure GetSubSystems(S: TStrings);

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  IBSQL, SysUtils, gd_ClassList, gdc_bug_frmBugBase_unit, gdc_bug_dlgBugBase_unit,
  gdc_bug_dlgUpdate_unit, gd_security;


{ TgdcBugBase }

procedure TgdcBugBase.CheckAndAdd(S: TStrings; const AValue: String);
var
  I: Integer;
  Found: Boolean;
begin
  if S <> nil then
  begin
    Found := False;
    for I := 0 to S.Count - 1 do
    begin
      if AnsiCompareText(S[I], AValue) = 0 then
      begin
        Found := True;
        break;
      end;
    end;
    if not Found then
      S.Add(AValue);
  end;
end;

constructor TgdcBugBase.Create(AnOwner: TComponent);
begin
  inherited;
  FBugAreas := nil;
  FSubSystems := nil;
end;

destructor TgdcBugBase.Destroy;
begin
  inherited;
  FBugAreas.Free;
  FSubSystems.Free;  
end;

procedure TgdcBugBase.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBUGBASE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBUGBASE', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBUGBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBUGBASE',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBUGBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CheckAndAdd(FBugAreas, FieldByName('bugarea').AsString);
  CheckAndAdd(FSubSystems, FieldByName('subsystem').AsString);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBUGBASE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBUGBASE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBugBase.GetBugAreas(S: TStrings);
begin
  Assert(S <> nil);
  if FBugAreas = nil then
  begin
    FBugAreas := TStringList.Create;
    GetDistinctColumnValues('bugarea', FBugAreas, True);
  end;
  S.Assign(FBugAreas);
end;

function TgdcBugBase.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBUGBASE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBUGBASE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBUGBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBUGBASE',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBUGBASE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM ' +
    '  bug_bugbase z ' +
    '    LEFT JOIN gd_contact f ON z.founderkey=f.id ' +
    '    LEFT JOIN gd_contact r ON z.responsiblekey=r.id ' +
    '    LEFT JOIN gd_contact x ON z.fixerkey=x.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBUGBASE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBUGBASE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcBugBase.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcBugBase.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'bug_bugbase';
end;

function TgdcBugBase.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBUGBASE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBUGBASE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBUGBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBUGBASE',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBUGBASE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.*, ' +
    '  f.name AS FounderName, ' +
    '  x.name AS FixerName, ' +
    '  r.name AS ResponsibleName ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBUGBASE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBUGBASE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBugBase.GetSubSystems(S: TStrings);
begin
  Assert(S <> nil);
  if FSubSystems = nil then
  begin
    FSubSystems := TStringList.Create;
    GetDistinctColumnValues('subsystem', FSubSystems, True);
  end;
  S.Assign(FSubSystems);
end;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcBugBase]);
end;

procedure TgdcBugBase._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBUGBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBUGBASE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBUGBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBUGBASE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBUGBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  // присваиваем значения по-умолчанию
  FieldByName('decision').AsString := 'АДКРЫТА';
  FieldByName('raised').AsDateTime := Now;
  FieldByName('priority').AsInteger := 3;
  FieldByName('founderkey').AsInteger := IBLogin.ContactKey;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBUGBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBUGBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcBugBase.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBUGBASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBUGBASE', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBUGBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBUGBASE',
  {M}          'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBUGBASE' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'subsystem;versionfrom;versionto;priority;bugarea;bugtype;bugfrequency;founderkey;responsiblekey;';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBUGBASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBUGBASE', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

class function TgdcBugBase.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_bug_frmBugBase';
end;

class function TgdcBugBase.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_bug_dlgBugBase';
end;

initialization
  RegisterGDCClass(TgdcBugBase, 'Памылка');
  
finalization
  UnregisterGdcClass(TgdcBugBase);
end.
