unit gd_StyleManager;

interface

uses
  Classes,
  Graphics,
  IBDatabase,
  JclStrHashMap;

const
  cDefMaxLengthStrValue = 60;
  cGloblaObjName = 'global';

  //ObjTypes
  cGlobal    = 1;
  cGrid      = 10;
  cExpand    = 11;
  cCondition = 12;
  cColumn    = 13;

  //PropIDs
  //Table
  cTableFontName            = 1001;
  cTableFontColor           = 1002;
  cTableFontHeight          = 1003;
  cTableFontPitch           = 1004;
  cTableFontSize            = 1005;
  cTableFontStyle           = 1006;
  cTableFontCharSet         = 1007;
  cTableColor               = 1008;

  //Selected
  cSelectedFontName         = 1009;
  cSelectedFontColor        = 1010;
  cSelectedFontHeight       = 1011;
  cSelectedFontPitch        = 1012;
  cSelectedFontSize         = 1013;
  cSelectedFontStyle        = 1014;
  cSelectedFontCharSet      = 1015;
  cSelectedColor            = 1016;

  //Title
  cTitleFontName            = 1017;
  cTitleFontColor           = 1018;
  cTitleFontHeight          = 1019;
  cTitleFontPitch           = 1020;
  cTitleFontSize            = 1021;
  cTitleFontStyle           = 1022;
  cTitleFontCharSet         = 1023;
  cTitleColor               = 1024;

  cStriped                  = 1025;
  cStripeEvenColor          = 1026;
  cStripeOddColor           = 1027;

  //expand
  cExpandFieldName          = 1028;
  cExpandDisplayField       = 1029;
  cExpandLineCount          = 1030;
  cExpandOptions            = 1031;

  cExpandsActive            = 1032;
  cExpandsSeparate          = 1033;

  //Condition
  cConditionName            = 1034;
  cConditionDisplayFields   = 1035;
  cConditionFieldName       = 1036;
  cConditionFontName        = 1037;
  cConditionFontColor       = 1038;
  cConditionFontHeight      = 1039;
  cConditionFontPitch       = 1040;
  cConditionFontSize        = 1041;
  cConditionFontStyle       = 1042;
  cConditionFontCharSet     = 1043;
  cConditionColor           = 1044;
  cConditionExpression1     = 1045;
  cConditionExpression2     = 1046;
  cConditionKind            = 1047;
  cConditionDisplayOptions  = 1048;
  cConditionEvaluateFormula = 1049;
  cConditionUserCondition   = 1050;

  cScaleColumns             = 1051;
  cShowTotals               = 1052;
  cShowFooter               = 1053;
  cTitlesExpanding          = 1054;
  cConditionsActive         = 1055;
  cShowRowLines             = 1056;

  cColumnTitleCaption       = 1057;
  cColumnDisplayFormat      = 1058;
  cColumnVisible            = 1059;
  cColumnReadOnly           = 1060;
  cColumnTotalSum           = 1061;
  cColumnWidth              = 1062;

  cColumnTitleFontName      = 1063;
  cColumnTitleFontColor     = 1064;
  cColumnTitleFontHeight    = 1065;
  cColumnTitleFontPitch     = 1066;
  cColumnTitleFontSize      = 1067;
  cColumnTitleFontStyle     = 1068;
  cColumnTitleFontCharSet   = 1069;
  cColumnTitleColor         = 1070;

  cColumnFontName           = 1071;
  cColumnFontColor          = 1072;
  cColumnFontHeight         = 1073;
  cColumnFontPitch          = 1074;
  cColumnFontSize           = 1075;
  cColumnFontStyle          = 1076;
  cColumnFontCharSet        = 1077;
  cColumnColor              = 1078;

  cColumnTitleAlignment     = 1079;
  cColumnAlignment          = 1080;
  cColumnSerialNumber       = 1081;

  {//Default Values
  //Table
  cDefTableFontName            = 'MS Sans Serif';
  cDefTableFontColor           = clWindowText;
  cDefTableFontHeight          = -11;
  cDefTableFontPitch           = fpDefault;
  cDefTableFontSize            = 8;
  cDefTableFontStyles          = [];
  cDefTableFontCharSet         = DEFAULT_CHARSET;
  cDefTableColor               = clWindow;

  //Selected
  cDefSelectedFontName         = 'MS Sans Serif';
  cDefSelectedFontColor        = clHighlightText;
  cDefSelectedFontHeight       = -11;
  cDefSelectedFontPitch        = fpDefault;
  cDefSelectedFontSize         = 8;
  cDefSelectedFontStyles       = [];
  cDefSelectedFontCharSet      = DEFAULT_CHARSET;
  cDefSelectedColor            = clHighlight;

  //Title
  cDefTitleFontName            = 'MS Sans Serif';
  cDefTitleFontColor           = clWindowText;
  cDefTitleFontHeight          = -11;
  cDefTitleFontPitch           = fpDefault;
  cDefTitleFontSize            = 8;
  cDefTitleFontStyles          = [];
  cDefTitleFontCharSet         = DEFAULT_CHARSET;
  cDefTitleColor               = clBtnFace;


  cDefStriped                  = True;
  cDefStripeEven               = $00D6E7E7;
  cDefStripeOdd                = $00E7F3F7;

  //Expand
  cDefExpandOptions            = [];
  cDefExpandsActive            = False;
  cDefExpandsSeparate          = False;

  //Condition
  cDefConditionFieldName       = '';
  cDefConditionFontName        = 'MS Sans Serif';
  cDefConditionFontColor       = clWindowText;
  cDefConditionFontHeight      = -11;
  cDefConditionFontPitch       = fpDefault;
  cDefConditionFontSize        = 8;
  cDefConditionFontStyles      = [];
  cDefConditionFontCharSet     = DEFAULT_CHARSET;
  cDefConditionColor           = clWhite;
  cDefConditionExpression1     = '';
  cDefConditionExpression2     = '';
  cDefConditionKind            = ckNone;
  cDefConditionDisplayOptions  = [];
  cDefConditionEvaluateFormula = False;
  cDefConditionUserCondition   = False;

  cDefScaleColumns             = False;
  cDefShowTotals               = True;
  cDefShowFooter               = False;
  cDefTitlesExpanding          = False;
  cDefConditionsActive         = False;
  cDefShowRowLines             = False;

  cDefColumnTitleCaption       = '';
  cDefColumnDisplayFormat      = '';
  cDefColumnVisible            = True;
  cDefColumnReadOnly           = False;
  cDefColumnTotalSum           = False;
  cDefColumnWidth              = 0;

  cDefColumnTitleFontName      = 'MS Sans Serif';
  cDefColumnTitleFontColor     = clWindowText;
  cDefColumnTitleFontHeight    = -11;
  cDefColumnTitleFontPitch     = fpDefault;
  cDefColumnTitleFontSize      = 8;
  cDefColumnTitleFontStyles    = [];
  cDefColumnTitleFontCharSet   = DEFAULT_CHARSET;
  cDefColumnTitleColor         = clBtnFace;

  cDefColumnFontName           = 'MS Sans Serif';
  cDefColumnFontColor          = clWindowText;
  cDefColumnFontHeight         = -11;
  cDefColumnFontPitch          = fpDefault;
  cDefColumnFontSize           = 8;
  cDefColumnFontStyles         = [];
  cDefColumnFontCharSet        = DEFAULT_CHARSET;
  cDefColumnColor              = clWindow;

  cDefColumnTitleAlignment     = taLeftJustify;
  cDefColumnAlignment          = taLeftJustify;}

type
  TStyleOwner = (
    soUser,          //для пользователя
    soAllUser,       //для всех пользователей
    soTheme         //для темы
  );

  TStyleOwners = set of TStyleOwner;

  PStyle = ^TStyle;
  TStyle = record
    StrVal: String;
    IntVal: Integer;
    IsInt: Boolean;
  end;

  TgdStyleManager = class
  private
    FStyleList: TStringHashMap;

    procedure ClearData;
    function Iterate_FreeStyle(AUserData: PUserData; const AStr: string; var AData: PData): Boolean;
    function Iterate_Assign(AUserData: PUserData; const AStr: string; var AData: PData): Boolean;

    function FindStr(const AnObjName: String; out AStrValue: String): Boolean;
    function FindInt(const AnObjName: String; out AnIntValue: Integer): Boolean;

    procedure AddStr(const AnObjName: string; const AStrValue: String);
    procedure AddInt(const AnObjName: string; AnIntValue: Integer);

    procedure _Remove(const AnObjName: string);

    function GetObjName(const AnObjectNane: String; AnPropID: Integer; AStyleOwner: TStyleOwner): String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(ASource: TgdStyleManager);

    function GetStrProp(const AnObjectNane: String;
      AnPropID: Integer; AStyleOwner: TStyleOwner;
      out AStrValue: String): Boolean;
    function GetIntProp(const AnObjectNane: String;
      AnPropID: Integer; AStyleOwner: TStyleOwner;
      out AnIntValue: Integer): Boolean;
    function GetBoolProp(const AnObjectNane: String;
      AnPropID: Integer; AStyleOwner: TStyleOwner;
      out ABoolValue: Boolean): Boolean;

    procedure SetStrProp(const AnObjectNane: String;
      AnPropID: Integer; AStyleOwner: TStyleOwner;
      const AStrValue: String);
    procedure SetIntProp(const AnObjectNane: String;
      AnPropID: Integer; AStyleOwner: TStyleOwner;
      AnIntValue: Integer);
    procedure SetBoolProp(const AnObjectNane: String;
      AnPropID: Integer; AStyleOwner: TStyleOwner;
      ABoolValue: Boolean);

    procedure Remove(const AnObjectNane: String;
      AnPropID: Integer; AStyleOwner: TStyleOwner);

    procedure LoadFromDB;

    // Для грида
    function EvalGridStrValue(const AnFormName: String; const AnGridName: String;
      APropID: Integer; out AStrValue: String): Boolean;
    function EvalGridIntValue(const AnFormName: String; const AnGridName: String;
      APropID: Integer; out AnIntValue: Integer): Boolean;
    function EvalGridBoolValue(const AnFormName: String; const AnGridName: String;
      APropID: Integer; out ABoolValue: Boolean): Boolean;

    // Для колонок
    function EvalColumnStrValue(AnObjectName: String;
      APropID: Integer; out AStrValue: String): Boolean;
    function EvalColumnIntValue(AnObjectName: String;
      APropID: Integer; out AnIntValue: Integer): Boolean;
    function EvalColumnBoolValue(AnObjectName: String;
      APropID: Integer; out ABoolValue: Boolean): Boolean;
  end;

  TgdGridParser = class
  private
    FTransaction: TIBTransaction;

    function GetObjID(const AnObjType: Integer; const AnObjName: String): Integer;

    procedure SaveStrValue(const AnObjectKey: Integer;
      const APropID: Integer; const AStrValue: String; const AnUserKey: Integer);

    procedure SaveIntValue(const AnObjectKey: Integer;
      const APropID: Integer; const AIntValue: Integer; const AnUserKey: Integer);

    procedure SaveBoolValue(const AnObjectKey: Integer;
      const APropID: Integer; const AnBoolValue: Boolean; const AnUserKey: Integer);

    procedure ReadFont(R: TReader; AFont: TFont);

    procedure SaveConditions(R: TReader; AnObjectName: String; AnUserKey: Integer);

    procedure SaveColumns(R: TReader; AnObjectName: String; AnUserKey: Integer);

    procedure SaveExpands(R: TReader; AnObjectName: String; AnUserKey: Integer);

    procedure SaveFont(AFont: TFont;
      CurrFontName: Integer;
      CurrFontColor: Integer;
      CurrFontHeight: Integer;
      CurrFontPitch: Integer;
      CurrFontSize: Integer;
      CurrFontStyle: Integer;
      CurrFontCharSet: Integer;
      AnObjKey: Integer; AnUserKey: Integer);

    procedure SaveColumnFont(const AValue: String; AFont: TFont; AnObjKey: Integer; AnUserKey: Integer);

    procedure SaveGridFont(const AValue: String; R: TReader; AnObjKey: Integer; AnUserKey: Integer);

    procedure ParseGridStream(const AnObjectName: String;
      const AnUserKey: Integer; Stream: TStream);

    function GetDefaultStrValue(APropID: Integer): String;
    function GetDefaultIntValue(APropID: Integer): Integer;
    function GetDefaultBollValue(APropID: Integer): Boolean;

    procedure DeleteStrValues(APropID: Integer; const AStrValue: String);
    procedure DeleteIntValues(APropID: Integer; AnIntValue: Integer);
    procedure DeleteBoolValues(APropID: Integer; ABollValue: Boolean);

    procedure _SetDefault(AnObjKey: Integer);

    procedure SetDefault;

  public
    constructor Create(ATransaction: TIBTransaction);
    destructor Destroy; override;

    procedure Run;
  end;

var
  _gdStyleManager: TgdStyleManager;

function gdStyleManager: TgdStyleManager;

function FontStyleToString(AFontStyles: TFontStyles): String;
function StringToFontStyle(AFontStyles: String): TFontStyles;

function FontPitchToString(AFontPitch: TFontPitch): String;
function StringToFontPitch(AFontPitch: String): TFontPitch;

function AlignmentToString(AnAlignment: TAlignment): String;
function StringToAlignment(AnAlignment: String): TAlignment;

implementation

uses
  SysUtils,
  gsDBGrid,
  gd_security,
  gdcBaseInterface,
  IBSQL,
  DBGrids;

function gdStyleManager: TgdStyleManager;
begin
  if _gdStyleManager = nil then
    _gdStyleManager := TgdStyleManager.Create;
  Result := _gdStyleManager;
end;

function FontStyleToString(AFontStyles: TFontStyles): String;
begin
  Result := '';

  if fsBold in AFontStyles then
    Result := Result + 'fsBold' + ',';
  if fsItalic in AFontStyles then
    Result := Result + 'fsItalic' + ',';
  if fsUnderline in AFontStyles then
    Result := Result + 'fsUnderline' + ',';
  if fsStrikeOut in AFontStyles then
    Result := Result + 'fsStrikeOut' + ',';

  if Result > '' then
    SetLength(Result, Length(Result) - 1);
end;

function StringToFontStyle(AFontStyles: String): TFontStyles;
var
  SL: TStringList;
  I: Integer;
begin
  if AFontStyles = '' then
  begin
    Result := [];
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.CommaText := AFontStyles;

    for I := 0 to SL.Count - 1 do
    begin
      if SL[I] = 'fsBold' then
        Result := Result + [fsBold]
      else if SL[I] = 'fsItalic' then
        Result := Result + [fsItalic]
      else if SL[I] = 'fsUnderline' then
        Result := Result + [fsUnderline]
      else if SL[I] = 'fsStrikeOut' then
        Result := Result + [fsStrikeOut]
      else
        raise Exception.Create('invalid font styles');
    end;
  finally
    SL.Free;
  end;
end;

function FontPitchToString(AFontPitch: TFontPitch): String;
begin
  if AFontPitch = fpDefault then
    Result := 'fpDefault'
  else if AFontPitch = fpVariable then
    Result := 'fpVariable'
  else
    Result := 'fpFixed';
end;

function StringToFontPitch(AFontPitch: String): TFontPitch;
begin
  if AFontPitch = 'fpDefault' then
    Result := fpDefault
  else if AFontPitch = 'fpVariable' then
    Result := fpVariable
  else if AFontPitch = 'fpFixed' then
    Result := fpFixed
  else
    raise Exception.Create('invalid font pitch');
end;

function AlignmentToString(AnAlignment: TAlignment): String;
begin
  if AnAlignment = taLeftJustify then
    Result := 'taLeftJustify'
  else if AnAlignment = taRightJustify then
    Result := 'taRightJustify'
  else
    Result := 'taCenter';
end;

function StringToAlignment(AnAlignment: String): TAlignment;
begin
  if AnAlignment = 'taLeftJustify' then
    Result := taLeftJustify
  else if AnAlignment = 'taRightJustify' then
    Result := taRightJustify
  else if AnAlignment = 'taCenter' then
    Result := taCenter
  else
    raise Exception.Create('invalid Alignment');
end;

{ TgdStyleManager }

constructor TgdStyleManager.Create;
begin
  inherited;

  FStyleList := TStringHashMap.Create(CaseInsensitiveTraits, 1024);
end;

destructor TgdStyleManager.Destroy;
begin
  ClearData;
  FStyleList.Free;

  inherited;
end;

procedure TgdStyleManager.Assign(ASource: TgdStyleManager);
begin
  Assert(ASource <> nil);

  ASource.FStyleList.IterateMethod(nil, Iterate_Assign);
end;

function TgdStyleManager.Iterate_Assign(AUserData: PUserData; const AStr: string; var AData: PData): Boolean;
var
  PS: PStyle;
  NPS: PStyle;
begin
  PS := AData;

  New(NPS);
  // правильно ли отработает копирование строки, ввиду того что она является указателем????
  NPS^.StrVal := PS^.StrVal;
  NPS^.IntVal := PS^.IntVal;
  NPS^.IsInt := PS^.IsInt;

  FStyleList.Add(AStr, NPS);

  Result := True;
end;

function TgdStyleManager.GetStrProp(const AnObjectNane: String;
  AnPropID: Integer; AStyleOwner: TStyleOwner;
  out AStrValue: String): Boolean;
begin
  Result := FindStr(GetObjName(AnObjectNane, AnPropID, AStyleOwner), AStrValue);
end;

function TgdStyleManager.GetIntProp(const AnObjectNane: String;
  AnPropID: Integer; AStyleOwner: TStyleOwner;
  out AnIntValue: Integer): Boolean;
begin
  Result := FindInt(GetObjName(AnObjectNane, AnPropID, AStyleOwner), AnIntValue);
end;

function TgdStyleManager.GetBoolProp(const AnObjectNane: String;
  AnPropID: Integer; AStyleOwner: TStyleOwner;
  out ABoolValue: Boolean): Boolean;
var
  IntValue: Integer;
begin
  Result := GetIntProp(AnObjectNane, AnPropID, AStyleOwner, IntValue);

  if Result then
  begin
    if IntValue = 0 then
      ABoolValue := False
    else if IntValue = 1 then
      ABoolValue := True
    else
      raise Exception.Create('invalid boolean value');
  end;
end;

function TgdStyleManager.GetObjName(const AnObjectNane: String; AnPropID: Integer; AStyleOwner: TStyleOwner): String;
begin
  if AStyleOwner = soUser then
    Result := AnObjectNane + ',' + IntToStr(AnPropID) + ',' + IntToStr(IBLogin.UserKey) + ',' + '0'
  else if AStyleOwner = soAllUser then
    Result := AnObjectNane + ',' + IntToStr(AnPropID) + ',' + '0' + ',' + '0'
  //else if soTheme then
  //  Result := AnObjectNane + ',' + IntToStr(AnPropID) + ',' + '0' + ',' + '0';
end;

procedure TgdStyleManager.SetStrProp(const AnObjectNane: String;
  AnPropID: Integer; AStyleOwner: TStyleOwner;
  const AStrValue: String);
var
  PS: PStyle;
begin
  if FStyleList.Find(GetObjName(AnObjectNane, AnPropID, AStyleOwner), PS) then
    PS^.StrVal := AStrValue
  else
    AddStr(GetObjName(AnObjectNane, AnPropID, AStyleOwner), AStrValue);
end;

procedure TgdStyleManager.SetIntProp(const AnObjectNane: String;
  AnPropID: Integer; AStyleOwner: TStyleOwner;
  AnIntValue: Integer);
var
  PS: PStyle;
begin
  if FStyleList.Find(GetObjName(AnObjectNane, AnPropID, AStyleOwner), PS) then
    PS^.IntVal := AnIntValue
  else
    AddInt(GetObjName(AnObjectNane, AnPropID, AStyleOwner), AnIntValue);
end;

procedure TgdStyleManager.SetBoolProp(const AnObjectNane: String;
  AnPropID: Integer; AStyleOwner: TStyleOwner;
  ABoolValue: Boolean);
var
  IntValue: Integer;
begin
  if ABoolValue then
    IntValue := 1
  else
    IntValue := 0;

  SetIntProp(AnObjectNane, AnPropID, AStyleOwner, IntValue);
end;

procedure TgdStyleManager.Remove(const AnObjectNane: String;
  AnPropID: Integer; AStyleOwner: TStyleOwner);
var
  PS: PStyle;
begin
   if FStyleList.Find(GetObjName(AnObjectNane, AnPropID, AStyleOwner), PS) then
    _Remove(GetObjName(AnObjectNane, AnPropID, AStyleOwner));
end;

function TgdStyleManager.FindStr(const AnObjName: String; out AStrValue: String): Boolean;
var
  PS: PStyle;
begin
  Result := FStyleList.Find(AnObjName, PS);

  if Result then
  begin
    if PS^.IsInt then
      Assert(False);

    AStrValue := PS^.StrVal;
  end;
end;

function TgdStyleManager.FindInt(const AnObjName: String; out AnIntValue: Integer): Boolean;
var
  PS: PStyle;
begin
  Result := FStyleList.Find(AnObjName, PS);

  if Result then
  begin
    if not PS^.IsInt then
      Assert(False);

    AnIntValue := PS^.IntVal;
  end;
end;

procedure TgdStyleManager.AddStr(const AnObjName: string; const AStrValue: String);
var
  PS: PStyle;
  P: Pointer;
begin
  if FStyleList.Find(AnObjName, P) then
    Assert(False);

  New(PS);
  PS^.StrVal := AStrValue;
  PS^.IsInt := False;

  FStyleList.Add(AnObjName, PS);
end;

procedure TgdStyleManager.AddInt(const AnObjName: string; AnIntValue: Integer);
var
  PS: PStyle;
  P: Pointer;
begin
  if FStyleList.Find(AnObjName, P) then
    Assert(False);

  New(PS);
  PS^.IntVal := AnIntValue;
  PS^.IsInt := True;

  FStyleList.Add(AnObjName, PS);
end;

procedure TgdStyleManager._Remove(const AnObjName: string);
var
  PS: PStyle;
begin
  PS := FStyleList.Remove(AnObjName);
  Dispose(PS);
end;

procedure TgdStyleManager.ClearData;
begin
  FStyleList.IterateMethod(nil, Iterate_FreeStyle);
end;

function TgdStyleManager.Iterate_FreeStyle(AUserData: PUserData; const AStr: string; var AData: PData): Boolean;
var
  PS: PStyle;
begin
  PS := AData;
  Dispose(PS);
  AData := nil;
  Result := True;
end;

procedure TgdStyleManager.LoadFromDB;
var
  q: TIBSQL;
  Str: String;
  Int: Integer;
  S: String;
begin
  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  so.objtype, '#13#10 +
      '  so.objname, '#13#10 +
      '  s.id, '#13#10 +
      '  s.objectkey, '#13#10 +
      '  s.propid, '#13#10 +
      '  s.intvalue, '#13#10 +
      '  s.strvalue, '#13#10 +
      '  s.userkey, '#13#10 +
      '  s.themekey '#13#10 +
      'FROM at_style_object so '#13#10 +
      'JOIN at_style s '#13#10 +
      '  ON so.id = s.objectkey';
    q.ExecQuery;

    while not q.Eof do
    begin
      S := q.FieldByName('objname').AsString + ','
        + IntToStr(q.FieldByName('propid').AsInteger) + ','
        + IntToStr(q.FieldByName('userkey').AsInteger) + ','
        + IntToStr(q.FieldByName('themekey').AsInteger);

      if not q.FieldByName('strvalue').IsNull then
      begin
        AddStr(S, q.FieldByName('strvalue').AsString);

        //проверка//
        Assert(FindStr(S, Str));
        Assert(Str = q.FieldByName('strvalue').AsString);
        ////////////
      end

      else if not q.FieldByName('intvalue').IsNull then
      begin
        AddInt(S, q.FieldByName('intvalue').AsInteger);

        //проверка//
        Assert(FindInt(S, Int));
        Assert(Int = q.FieldByName('intvalue').AsInteger);
        ////////////
      end
      else
        Assert(False);

      q.Next;
    end;
  finally
    q.Free;
  end;
end;

function TgdStyleManager.EvalGridStrValue(const AnFormName: String; const AnGridName: String;
  APropID: Integer; out AStrValue: String): Boolean;

  function Eval(ALevel: Integer; ASubLevel: Integer;
    const AnFormName: String; const AnGridName: String;
    APropID: Integer; out AStrValue: String): Boolean;
  const
    MaxLevel = 2;
    MaxSubLevel = 2;
  var
    ObjectName: String;
    StyleOwner: TStyleOwner;
  begin
    if ALevel = 0 then
      ObjectName := AnGridName
    else if ALevel = 1 then
      ObjectName := AnFormName + ',' + AnGridName
    else if ALevel = 2 then
      ObjectName := cGloblaObjName
    else
      raise Exception.Create('');

    if ASubLevel = 0 then
      StyleOwner := soUser
    else if ASubLevel = 1 then
      StyleOwner := soAllUser
    else if ASubLevel = 2 then
      StyleOwner := soTheme
    else
      raise Exception.Create('');

    if GetStrProp(ObjectName, APropID, StyleOwner, AStrValue) then
    begin
      Result := True;
      Exit;
    end
    else
    begin
      if ASubLevel < MaxSubLevel then
      begin
        Inc(ASubLevel);
        Result := Eval(ALevel, ASubLevel, AnFormName, AnGridName, APropID, AStrValue);
      end
      else
      begin
        ASubLevel := 0;
        if ALevel < MaxLevel then
        begin
          Inc(ALevel);
          Result := Eval(ALevel, ASubLevel, AnFormName, AnGridName, APropID, AStrValue);
        end
        else
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;

begin
  Assert(AnFormName > '');
  Assert(AnGridName > '');
  
  Result := Eval(0, 0, AnFormName, AnGridName, APropID, AstrValue);
end;

function TgdStyleManager.EvalGridIntValue(const AnFormName: String; const AnGridName: String;
  APropID: Integer; out AnIntValue: Integer): Boolean;

  function Eval(ALevel: Integer; ASubLevel: Integer;
    const AnFormName: String; const AnGridName: String;
    APropID: Integer; out AnIntValue: Integer): Boolean;
  const
    MaxLevel = 2;
    MaxSubLevel = 2;
  var
    ObjectName: String;
    StyleOwner: TStyleOwner;
  begin
    if ALevel = 0 then
      ObjectName := AnGridName
    else if ALevel = 1 then
      ObjectName := AnFormName + ',' + AnGridName
    else if ALevel = 2 then
      ObjectName := cGloblaObjName
    else
      raise Exception.Create('');

    if ASubLevel = 0 then
      StyleOwner := soUser
    else if ASubLevel = 1 then
      StyleOwner := soAllUser
    else if ASubLevel = 2 then
      StyleOwner := soTheme
    else
      raise Exception.Create('');

    if GetIntProp(ObjectName, APropID, StyleOwner, AnIntValue) then
    begin
      Result := True;
      Exit;
    end
    else
    begin
      if ASubLevel < MaxSubLevel then
      begin
        Inc(ASubLevel);
        Result := Eval(ALevel, ASubLevel, AnFormName, AnGridName, APropID, AnIntValue);
      end
      else
      begin
        ASubLevel := 0;
        if ALevel < MaxLevel then
        begin
          Inc(ALevel);
          Result := Eval(ALevel, ASubLevel, AnFormName, AnGridName, APropID, AnIntValue);
        end
        else
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
begin
  Assert(AnFormName > '');
  Assert(AnGridName > '');
  
  Result := Eval(0, 0, AnFormName, AnGridName, APropID, AnIntValue);
end;

function TgdStyleManager.EvalGridBoolValue(const AnFormName: String; const AnGridName: String;
  APropID: Integer; out ABoolValue: Boolean): Boolean;
var
  IntValue: Integer;
begin
  Result := EvalGridIntValue(AnFormName, AnGridName, APropID, IntValue);

  if Result then
  begin
    if IntValue = 0 then
      ABoolValue := False
    else if IntValue = 1 then
      ABoolValue := True
    else
      raise Exception.Create('invalid boolean value');
  end
end;

function TgdStyleManager.EvalColumnStrValue(AnObjectName: String;
  APropID: Integer; out AStrValue: String): Boolean;
Var
  ObjectName: String;
  StyleOwner: TStyleOwner;
begin
  // пока по упрощенной программе

  ObjectName := AnObjectName;
  StyleOwner := soUser;
  Result := GetStrProp(ObjectName, APropID, StyleOwner, AStrValue);

  if not Result then
  begin
    StyleOwner := soAllUser;
    Result := GetStrProp(ObjectName, APropID, StyleOwner, AStrValue);
  end;

  if not Result then
  begin
    StyleOwner := soTheme;
    Result := GetStrProp(ObjectName, APropID, StyleOwner, AStrValue);
  end;

  if not Result then
  begin
    ObjectName := cGloblaObjName;
    StyleOwner := soUser;
    Result := GetStrProp(ObjectName, APropID, StyleOwner, AStrValue);
  end;

  if not Result then
  begin
    StyleOwner := soAllUser;
    Result := GetStrProp(ObjectName, APropID, StyleOwner, AStrValue);
  end;

  if not Result then
  begin
    StyleOwner := soTheme;
    Result := GetStrProp(ObjectName, APropID, StyleOwner, AStrValue);
  end;
end;

function TgdStyleManager.EvalColumnIntValue(AnObjectName: String;
  APropID: Integer; out AnIntValue: Integer): Boolean;
Var
  ObjectName: String;
  StyleOwner: TStyleOwner;
begin
  // пока по упрощенной программе

  ObjectName := AnObjectName;
  StyleOwner := soUser;
  Result := GetIntProp(ObjectName, APropID, StyleOwner, AnIntValue);

  if not Result then
  begin
    StyleOwner := soAllUser;
    Result := GetIntProp(ObjectName, APropID, StyleOwner, AnIntValue);
  end;

  if not Result then
  begin
    StyleOwner := soTheme;
    Result := GetIntProp(ObjectName, APropID, StyleOwner, AnIntValue);
  end;

  if not Result then
  begin
    ObjectName := cGloblaObjName;
    StyleOwner := soUser;
    Result := GetIntProp(ObjectName, APropID, StyleOwner, AnIntValue);
  end;

  if not Result then
  begin
    StyleOwner := soAllUser;
    Result := GetIntProp(ObjectName, APropID, StyleOwner, AnIntValue);
  end;

  if not Result then
  begin
    StyleOwner := soTheme;
    Result := GetIntProp(ObjectName, APropID, StyleOwner, AnIntValue);
  end;
end;

function TgdStyleManager.EvalColumnBoolValue(AnObjectName: String;
  APropID: Integer; out ABoolValue: Boolean): Boolean;
var
  IntValue: Integer;
begin
  Result := EvalColumnIntValue(AnObjectName, APropID, IntValue);

  if Result then
  begin
    if IntValue = 0 then
      ABoolValue := False
    else if IntValue = 1 then
      ABoolValue := True
    else
      raise Exception.Create('invalid boolean value');
  end
end;

{ TgdGridParser }

constructor TgdGridParser.Create(ATransaction: TIBTransaction);
begin
  Assert(ATransaction <> nil);

  FTransaction := ATransaction;
end;

destructor TgdGridParser.Destroy;
begin

  inherited;
end;

function TgdGridParser.GetObjID(const AnObjType: Integer; const AnObjName: String): Integer;
var
  q: TIBSQL;
begin
  Assert(AnObjType >= 0);
  Assert(AnObjName > '');

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.Close;
    Result := gdcBaseManager.GetNextID;
    q.SQL.Text := 'INSERT INTO at_style_object(id, objtype, objname) VALUES (:id, :objtype, :objname)';
    q.ParamByName('id').AsInteger := Result;
    q.ParamByName('objtype').AsInteger := AnObjType;
    q.ParamByName('objname').AsString := AnObjName;
    q.ExecQuery;
  finally
    q.Free;
  end;
end;

procedure TgdGridParser.SaveStrValue(const AnObjectKey: Integer;
  const APropID: Integer; const AStrValue: String; const AnUserKey: Integer);
var
  q: TIBSQL;
begin
  Assert(AnObjectKey > 0);
  Assert(APropID > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'INSERT INTO at_style (objectkey, propid, strvalue, userkey) ' +
      'VALUES (:objectkey, :propid, :strvalue, :userkey)';
    q.ParamByName('objectkey').AsInteger := AnObjectKey;
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('strvalue').AsString := AStrValue;
    if AnUserKey > 0 then
      q.ParamByName('userkey').AsInteger := AnUserKey
    else
      q.ParamByName('userkey').Clear;
    q.ExecQuery;
  finally
    q.Free;
  end;
end;

procedure TgdGridParser.SaveIntValue(const AnObjectKey: Integer;
  const APropID: Integer; const AIntValue: Integer; const AnUserKey: Integer);
var
  q: TIBSQL;
begin
  Assert(AnObjectKey > 0);
  Assert(APropID > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'INSERT INTO at_style (objectkey, propid, intvalue, userkey) ' +
      'VALUES (:objectkey, :propid, :intvalue, :userkey)';
    q.ParamByName('objectkey').AsInteger := AnObjectKey;
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('intvalue').AsInteger := AIntValue;
    if AnUserKey > 0 then
      q.ParamByName('userkey').AsInteger := AnUserKey
    else
      q.ParamByName('userkey').Clear;
    q.ExecQuery;
  finally
    q.Free;
  end;
end;

procedure TgdGridParser.SaveBoolValue(const AnObjectKey: Integer;
  const APropID: Integer; const AnBoolValue: Boolean; const AnUserKey: Integer);
var
  IntValue: Integer;
begin
  Assert(AnObjectKey > 0);
  Assert(APropID > 0);

  if AnBoolValue then
    IntValue := 1
  else
    IntValue := 0;

  SaveIntValue(AnObjectKey, APropID, IntValue, AnUserKey);
end;

procedure TgdGridParser.ReadFont(R: TReader; AFont: TFont);
var
  Pitch: TFontPitch;
  Style: TFontStyles;
begin
  Assert(R <> nil);
  Assert(AFont <> nil);

  R.ReadListBegin;
  try
    AFont.Name := R.ReadString;
    AFont.Color := StringToColor(R.ReadString);
    AFont.Height := R.ReadInteger;
    R.Read(Pitch, SizeOf(TFontPitch));
    AFont.Pitch := Pitch;
    AFont.Size := R.ReadInteger;
    R.Read(Style, SizeOf(TFontStyles));
    AFont.Style := Style;
    AFont.CharSet := R.ReadInteger;
    R.ReadListEnd;
  except
    R.ReadListEnd;
  end;
end;

procedure TgdGridParser.SaveConditions(R: TReader; AnObjectName: String; AnUserKey: Integer);
var
  Conditions: TGridConditions;
  OK: Integer;
  I: Integer;
  S: String;
  N: Integer;
  SL: TStringList;
begin
  Assert(R <> nil);
  Assert(AnObjectName > '');
  Assert(AnUserKey > 0);

  Conditions := TGridConditions.Create(nil);
  try
    R.ReadCollection(Conditions);

    // На случай если ConditionName окажется не уникальным или пустым делаем подстраховку
    SL := TStringList.Create;
    try
      N := 0;
      for I := 0 to Conditions.Count - 1 do
      begin

        if (Conditions[I].ConditionName = '')
          or (SL.IndexOf(Conditions[I].ConditionName) <> -1) then
        begin
           Conditions[I].ConditionName := 'cn_' + IntToStr(N);
           Inc(N);
        end;

        SL.Add(Conditions[I].ConditionName);

        Assert(Conditions[I].ConditionName > '');

        OK := GetObjID(cCondition, AnObjectName + ',' + Conditions[I].ConditionName);

        SaveStrValue(OK, cConditionName, Conditions[I].ConditionName, AnUserKey);

        //DisplayFields
        if (Length(Conditions[I].DisplayFields) <= cDefMaxLengthStrValue)
          and (Conditions[I].DisplayFields > '') then
        begin
          SaveStrValue(OK, cConditionDisplayFields, Conditions[I].DisplayFields, AnUserKey);
        end;

        //FieldName
        SaveStrValue(OK, cConditionFieldName, Conditions[I].FieldName, AnUserKey);

        //Font
        SaveColumnFont('ConditionFont', Conditions[I].Font, OK, AnUserKey);

        //Color
        SaveStrValue(OK, cConditionColor, ColorToString(Conditions[I].Color), AnUserKey);

        // тут тоже не факт что будет меньше 60-ти
        if (Conditions[I].Expression1 > '')
          and (Length(Conditions[I].Expression1) <= cDefMaxLengthStrValue) then
        begin
          SaveStrValue(OK, cConditionExpression1, Conditions[I].Expression1, AnUserKey);
        end;

        if (Conditions[I].Expression2 > '')
          and (Length(Conditions[I].Expression2) <= cDefMaxLengthStrValue) then
        begin
          SaveStrValue(OK, cConditionExpression2, Conditions[I].Expression2, AnUserKey);
        end;

        if Conditions[I].ConditionKind = ckEqual then
          SaveStrValue(OK, cConditionKind, 'ckEqual', AnUserKey)
        else if Conditions[I].ConditionKind = ckNotEqual then
          SaveStrValue(OK, cConditionKind, 'ckNotEqual', AnUserKey)
        else if Conditions[I].ConditionKind = ckIn then
          SaveStrValue(OK, cConditionKind, 'ckIn', AnUserKey)
        else if Conditions[I].ConditionKind = ckOut then
          SaveStrValue(OK, cConditionKind, 'ckOut', AnUserKey)
        else if Conditions[I].ConditionKind = ckBigger then
          SaveStrValue(OK, cConditionKind, 'ckBigger', AnUserKey)
        else if Conditions[I].ConditionKind = ckSmaller then
          SaveStrValue(OK, cConditionKind, 'ckSmaller', AnUserKey)
        else if Conditions[I].ConditionKind = ckBiggerEqual then
          SaveStrValue(OK, cConditionKind, 'ckBiggerEqual', AnUserKey)
        else if Conditions[I].ConditionKind = ckSmallerEqual then
          SaveStrValue(OK, cConditionKind, 'ckSmallerEqual', AnUserKey)
        else if Conditions[I].ConditionKind = ckStarts then
          SaveStrValue(OK, cConditionKind, 'ckStarts', AnUserKey)
        else if Conditions[I].ConditionKind = ckContains then
          SaveStrValue(OK, cConditionKind, 'ckContains', AnUserKey)
        else if Conditions[I].ConditionKind = ckExist then
          SaveStrValue(OK, cConditionKind, 'ckExist', AnUserKey)
        else if Conditions[I].ConditionKind = ckNotExist then
          SaveStrValue(OK, cConditionKind, 'ckNotExist', AnUserKey)
        else if Conditions[I].ConditionKind = ckNone then
          SaveStrValue(OK, cConditionKind, 'ckNone', AnUserKey);

        S := '';

        if doColor in Conditions[I].DisplayOptions then
          S := S + 'doColor' + ',';
        if doFont in Conditions[I].DisplayOptions then
          S := S + 'doFont' + ',';

        if S > '' then
          SetLength(S, Length(S) - 1);

        SaveStrValue(OK, cConditionDisplayOptions, S, AnUserKey);

        SaveBoolValue(OK, cConditionEvaluateFormula, Conditions[I].EvaluateFormula, AnUserKey);

        SaveBoolValue(OK, cConditionUserCondition, Conditions[I].UserCondition, AnUserKey);

        // Вот с этим пока не знаю что делать!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //Conditions[I].OnUserCondition
      end;
    finally
      SL.Free;
    end;
  finally
    Conditions.Free;
  end;
end;

procedure TgdGridParser.SaveColumns(R: TReader; AnObjectName: String; AnUserKey: Integer);
var
  Columns: TgsColumns;
  I: Integer;
  OK: Integer;
  TitleCaption: String;
begin
  Assert(R <> nil);
  Assert(AnObjectName > '');
  Assert(AnUserKey > 0);

  Columns := TgsColumns.Create(nil, TgsColumn, False);
  try
    R.ReadCollection(Columns);

    for I := 0 to Columns.Count - 1 do
    begin
      if Columns[I].FieldName > '' then
      begin
        Assert(Columns[I].FieldName > '');
        OK := GetObjID(cColumn, AnObjectName + ',' + Columns[I].FieldName);

        SaveIntValue(OK, cColumnSerialNumber, I, AnUserKey);

        // Заглавие колонки
        TitleCaption := Columns[I].Title.Caption;
        // Обрезаем
        if Length(TitleCaption) > cDefMaxLengthStrValue then
          SetLength(TitleCaption, cDefMaxLengthStrValue);

        SaveStrValue(OK, cColumnTitleCaption, TitleCaption, AnUserKey);

        // Формат
        SaveStrValue(OK, cColumnDisplayFormat, Columns[I].DisplayFormat, AnUserKey);

        // колонка отображается
        SaveBoolValue(OK, cColumnVisible, Columns[I].Visible, AnUserKey);

        // только чтение
        SaveBoolValue(OK, cColumnReadOnly, Columns[I].ReadOnly, AnUserKey);

        // подсчитывать итоговое значение
        SaveBoolValue(OK, cColumnTotalSum, Columns[I].TotalType = ttSum, AnUserKey);

        // ширина колонки
        SaveIntValue(OK, cColumnWidth, Columns[I].Width, AnUserKey);

        // шрифт заголовка
        SaveColumnFont('ColumnTitleFont', Columns[I].Title.Font, OK, AnUserKey);

        // Цвет заголовка
        SaveStrValue(OK, cColumnTitleColor, ColorToString(Columns[I].Title.Color), AnUserKey);

        // шрифт колонки
        SaveColumnFont('ColumnFont', Columns[I].Font, OK, AnUserKey);

        // цвет колонки
        SaveStrValue(OK, cColumnColor, ColorToString(Columns[I].Color), AnUserKey);

        // Выравнивание в заголовке
        SaveStrValue(OK, cColumnTitleAlignment, AlignmentToString(Columns[I].Title.Alignment), AnUserKey);

        // Выравнивание в колонке
        SaveStrValue(OK, cColumnAlignment, AlignmentToString(Columns[I].Alignment), AnUserKey);
      end;
    end;
  finally
    Columns.Free;
  end;
end;

procedure TgdGridParser.SaveExpands(R: TReader; AnObjectName: String; AnUserKey: Integer);
var
  Expands: TColumnExpands;
  I: Integer;
  OK: Integer;
  S: String;
begin
  Assert(R <> nil);
  Assert(AnObjectName > '');
  Assert(AnUserKey > 0);

  Expands := TColumnExpands.Create(nil);
  try
    R.ReadCollection(Expands);
    //objname записываем так (форма, грид, Expand(DisplayField/FieldName))
    //DisplayField - имя поля в котором отображается
    //И все равно так не уникально, в программе в расширенное отображение
    //можно добавить одно и то же поле несколько раз, но возможно это ошибка!!! сомнительный функционал
    for I := 0 to Expands.Count - 1 do
    begin
      if Expands[I].FieldName > '' then
      begin
        OK := GetObjID(cExpand, AnObjectName + ',' +
          'Expand(' + Expands[I].DisplayField + '/' + Expands[I].FieldName +')');

        SaveStrValue(OK, cExpandFieldName, Expands[I].FieldName, AnUserKey);
        SaveStrValue(OK, cExpandDisplayField, Expands[I].DisplayField, AnUserKey);
        SaveIntValue(OK, cExpandLineCount, Expands[I].LineCount, AnUserKey);

        //Возможно нужно сохранять порядковый номар!!!


        S := '';

        if ceoAddField in Expands[I].Options then
          S := S + 'ceoAddField' + ',';
        if ceoAddFieldMultiline in Expands[I].Options then
          S := S + 'ceoAddFieldMultiline' + ',';
        if ceoMultiline in Expands[I].Options then
          S := S + 'ceoAddFieldMultiline' + ',';

        if S > '' then
          SetLength(S, Length(S) - 1);

        SaveStrValue(OK, cExpandOptions, S, AnUserKey);
      end;
    end;
  finally
    Expands.Free;
  end;
end;

procedure TgdGridParser.SaveFont(AFont: TFont;
  CurrFontName: Integer;
  CurrFontColor: Integer;
  CurrFontHeight: Integer;
  CurrFontPitch: Integer;
  CurrFontSize: Integer;
  CurrFontStyle: Integer;
  CurrFontCharSet: Integer;
  AnObjKey: Integer; AnUserKey: Integer);
begin
  Assert(AFont <> nil);
  Assert(CurrFontName > 0);
  Assert(CurrFontColor > 0);
  Assert(CurrFontHeight > 0);
  Assert(CurrFontPitch > 0);
  Assert(CurrFontSize > 0);
  Assert(CurrFontStyle > 0);
  Assert(CurrFontCharSet > 0);
  Assert(AnObjKey > 0);
  Assert(AnUserKey > 0);

  SaveStrValue(AnObjKey, CurrFontName, AFont.Name, AnUserKey);

  SaveStrValue(AnObjKey, CurrFontColor, ColorToString(AFont.Color), AnUserKey);

  SaveIntValue(AnObjKey, CurrFontHeight, AFont.Height, AnUserKey);

  SaveStrValue(AnObjKey, CurrFontPitch, FontPitchToString(AFont.Pitch), AnUserKey);

  SaveIntValue(AnObjKey, CurrFontSize, AFont.Size, AnUserKey);

  SaveStrValue(AnObjKey, CurrFontStyle, FontStyleToString(AFont.Style), AnUserKey);

  SaveIntValue(AnObjKey, CurrFontCharSet, AFont.CharSet, AnUserKey);
end;

procedure TgdGridParser.SaveColumnFont(const AValue: String; AFont: TFont; AnObjKey: Integer; AnUserKey: Integer);
begin
  Assert(AValue > '');
  Assert(TFont <> nil);
  Assert(AnObjKey > 0);
  Assert(AnUserKey > 0);

  if AValue = 'ColumnTitleFont' then
    SaveFont(AFont,
      cColumnTitleFontName,
      cColumnTitleFontColor,
      cColumnTitleFontHeight,
      cColumnTitleFontPitch,
      cColumnTitleFontSize,
      cColumnTitleFontStyle,
      cColumnTitleFontCharSet,
      AnObjKey, AnUserKey)
  else if AValue = 'ColumnFont' then
    SaveFont(AFont,
      cColumnFontName,
      cColumnFontColor,
      cColumnFontHeight,
      cColumnFontPitch,
      cColumnFontSize,
      cColumnFontStyle,
      cColumnFontCharSet,
      AnObjKey, AnUserKey)
  else if AValue = 'ConditionFont' then
    SaveFont(AFont,
      cConditionFontName,
      cConditionFontColor,
      cConditionFontHeight,
      cConditionFontPitch,
      cConditionFontSize,
      cConditionFontStyle,
      cConditionFontCharSet,
      AnObjKey, AnUserKey)
  else
    Assert(False);

end;

procedure TgdGridParser.SaveGridFont(const AValue: String; R: TReader; AnObjKey: Integer; AnUserKey: Integer);
var
  Font: TFont;
begin
  Assert(AValue > '');
  Assert(R <> nil);
  Assert(AnObjKey > 0);
  Assert(AnUserKey > 0);

  Font := TFont.Create;
  try
    ReadFont(R, Font);

    if AValue = 'TableFont' then
      SaveFont(Font,
        cTableFontName,
        cTableFontColor,
        cTableFontHeight,
        cTableFontPitch,
        cTableFontSize,
        cTableFontStyle,
        cTableFontCharSet,
        AnObjKey, AnUserKey)
    else if AValue = 'TitleFont' then
      SaveFont(Font,
        cTitleFontName,
        cTitleFontColor,
        cTitleFontHeight,
        cTitleFontPitch,
        cTitleFontSize,
        cTitleFontStyle,
        cTitleFontCharSet,
        AnObjKey, AnUserKey)
    else if AValue = 'SelectedFont' then
      SaveFont(Font,
        cSelectedFontName,
        cSelectedFontColor,
        cSelectedFontHeight,
        cSelectedFontPitch,
        cSelectedFontSize,
        cSelectedFontStyle,
        cSelectedFontCharSet,
        AnObjKey, AnUserKey)
    else
      Assert(False);

  finally
    Font.Free;
  end;
end;

procedure TgdGridParser.ParseGridStream(const AnObjectName: String;
  const AnUserKey: Integer; Stream: TStream);
var
  R: TReader;
  I: Integer;
  Version: String;
  ObjectKey: Integer;
  Color: TColor;
  Striped: Boolean;
  StripeOdd: TColor;
  StripeEven: TColor;
  ExpandsActive: Boolean;
  ExpandsSeparate: Boolean;
  ScaleColumns: Boolean;
  ConditionsActive: Boolean;
  TitlesExpanding: Boolean;
  O: TDBGridOptions;
  ShowRowLines: Boolean;
  ShowTotals: Boolean;
  ShowFooter: Boolean;
begin
  Assert(AnObjectName > '');
  Assert(AnUserKey > 0);

  ObjectKey := GetObjID(cGrid, AnObjectName);

  if Stream.Size > 0 then
  begin
    R := TReader.Create(Stream, 1024);
    try
      R.ReadSignature;

      I := R.Position;
      try
        if (R.NextValue = vaString) then
        begin
          Version := R.ReadString;

          if (Version <> 'GRID_STREAM_2')
            and (Version <> 'GRID_STREAM_3')
            and (Version <> 'GRID_STREAM_4') then
          begin
            R.Position := I;
            Version := '';
          end;
        end
        else
          Version := '';
      except
        R.Position := I;
        Version := '';
      end;

      SaveGridFont('TableFont', R, ObjectKey, AnUserKey);

      Color := StringToColor(R.ReadString);
      SaveStrValue(ObjectKey, cTableColor, ColorToString(Color), AnUserKey);

      SaveGridFont('SelectedFont', R, ObjectKey, AnUserKey);

      Color := StringToColor(R.ReadString);
      SaveStrValue(ObjectKey, cSelectedColor, ColorToString(Color), AnUserKey);

      SaveGridFont('TitleFont', R, ObjectKey, AnUserKey);

      Color := StringToColor(R.ReadString);
      SaveStrValue(ObjectKey, cTitleColor, ColorToString(Color), AnUserKey);

      Striped := R.ReadBoolean;
      SaveBoolValue(ObjectKey, cStriped, Striped, AnUserKey);

      StripeOdd := StringToColor(R.ReadString);
      SaveStrValue(ObjectKey, cStripeOddColor, ColorToString(StripeOdd), AnUserKey);

      StripeEven := StringToColor(R.ReadString);
      SaveStrValue(ObjectKey, cStripeEvenColor, ColorToString(StripeEven), AnUserKey);

      if R.ReadValue = vaCollection then
        SaveExpands(R, AnObjectName, AnUserKey);

      ExpandsActive := R.ReadBoolean;
      SaveBoolValue(ObjectKey, cExpandsActive, ExpandsActive, AnUserKey);

      ExpandsSeparate := R.ReadBoolean;
      SaveBoolValue(ObjectKey, cExpandsSeparate, ExpandsSeparate, AnUserKey);

      if R.ReadValue = vaCollection then
        SaveConditions(R, AnObjectName, AnUserKey);

      ConditionsActive := R.ReadBoolean;
      SaveBoolValue(ObjectKey, cConditionsActive, ConditionsActive, AnUserKey);

      if R.ReadValue = vaCollection then
        SaveColumns(R, AnObjectName, AnUserKey);

      ScaleColumns := R.ReadBoolean;
      SaveBoolValue(ObjectKey, cScaleColumns, ScaleColumns, AnUserKey);

      if (Version = 'GRID_STREAM_2') then
      begin
        TitlesExpanding := R.ReadBoolean;
        SaveBoolValue(ObjectKey, cTitlesExpanding, TitlesExpanding, AnUserKey);
      end
      else if (Version = 'GRID_STREAM_3') or (Version = 'GRID_STREAM_4') then
      begin
        TitlesExpanding := R.ReadBoolean;
        SaveBoolValue(ObjectKey, cTitlesExpanding, TitlesExpanding, AnUserKey);

        R.Read(O, SizeOf(TDBGridOptions));
        ShowRowLines := dgRowLines in O;
        SaveBoolValue(ObjectKey, cShowRowLines, ShowRowLines, AnUserKey);
      end;

      if (Version = 'GRID_STREAM_4') then
      begin
        ShowTotals := R.ReadBoolean;
        SaveBoolValue(ObjectKey, cShowTotals, ShowTotals, AnUserKey);

        ShowFooter := R.ReadBoolean;
        SaveBoolValue(ObjectKey, cShowFooter, ShowFooter, AnUserKey);
      end;
    finally
      R.Free;
    end;
  end;
end;

{
procedure TgsCustomDBGrid.Read(Reader: TReader);
var
  I: Integer;
  Version: String;
  O: TDBGridOptions;

  function ReadColor(DefColor: TColor): TColor;
  begin
    try
      Result := StringToColor(Reader.ReadString);
    except
      Result := DefColor;
    end;
  end;

  procedure ReadFont(AFont: TFont);
  var
    Pitch: TFontPitch;
    Style: TFontStyles;
  begin
    Reader.ReadListBegin;

    try
      AFont.Name := Reader.ReadString;
      AFont.Color := ReadColor(AFont.Color);
      AFont.Height := Reader.ReadInteger;
      Reader.Read(Pitch, SizeOf(TFontPitch));
      AFont.Pitch := Pitch;
      AFont.Size := Reader.ReadInteger;
      Reader.Read(Style, SizeOf(TFontStyles));
      AFont.Style := Style;
      AFont.CharSet := Reader.ReadInteger;
      Reader.ReadListEnd;
    except
      Reader.ReadListEnd;
    end;
  end;

begin
  SelectedIndex := 0;

  BeginLayout;

  try
    Reader.ReadSignature;

    //////////////////////////////
    // Считывание данных для
    // версии грида

    I := Reader.Position;
    try
      if (Reader.NextValue = vaString) then
      begin
        Version := Reader.ReadString;

        if
          (Version <> GRID_STREAM_VERSION_2) and
          (Version <> GRID_STREAM_VERSION_3) and
          (Version <> GRID_STREAM_VERSION_4)
        then begin
          Reader.Position := I;
          Version := '';
        end;
      end else
        Version := '';
    except
      Reader.Position := I;
      Version := '';
    end;

    ReadFont(TableFont);
    TableColor := ReadColor(TableColor);

    ReadFont(SelectedFont);
    SelectedColor := ReadColor(SelectedColor);

    ReadFont(TitleFont);
    TitleColor := ReadColor(TitleColor);

    Striped := Reader.ReadBoolean;
    StripeOdd := ReadColor(StripeOdd);
    StripeEven := ReadColor(StripeEven);

    if Reader.ReadValue = vaCollection then Reader.ReadCollection(FExpands);
    ExpandsActive := Reader.ReadBoolean;
    ExpandsSeparate := Reader.ReadBoolean;

    if Reader.ReadValue = vaCollection then Reader.ReadCollection(FConditions);
    ConditionsActive := Reader.ReadBoolean;

    if Reader.ReadValue = vaCollection then Reader.ReadCollection(Columns);

    ScaleColumns := Reader.ReadBoolean;

    if (Version = GRID_STREAM_VERSION_2) then
      TitlesExpanding := Reader.ReadBoolean
    else if (Version = GRID_STREAM_VERSION_3) or (Version = GRID_STREAM_VERSION_4) then
    begin
      TitlesExpanding := Reader.ReadBoolean;

      Reader.Read(O, SizeOf(TDBGridOptions));
      if dgRowLines in O then
        Options := Options + [dgRowLines]
      else
        Options := Options - [dgRowLines];
    end;

    if (Version = GRID_STREAM_VERSION_4) then
    begin
      FShowTotals := Reader.ReadBoolean;
      FShowFooter := Reader.ReadBoolean;
    end;
    FSettingsLoaded := True;
  finally
    EndLayout;
    ValidateColumns;

    if Assigned(Parent) and (LayoutLock = 0) then
    begin
      UpdateRowCount;
      CountScaleColumns;
    end;
  end;
end;
}

procedure TgdGridParser.Run;
var
  q: TIBSQL;
  S: TStringStream;
  OwnerName: String;
  CompName: String;
  K: Integer;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'WITH RECURSIVE '#13#10 +
      '  grid_data AS ( '#13#10 +
      '    SELECT id, parent, name, int_data '#13#10 +
      '    FROM gd_storage_data '#13#10 +
      '    WHERE data_type = ''U'' '#13#10 +
      '    UNION ALL '#13#10 +
      '    SELECT sd2.id, sd2.parent, sd2.name, gd.int_data '#13#10 +
      '    FROM gd_storage_data sd2 '#13#10 +
      '    JOIN grid_data gd '#13#10 +
      '      ON gd.id = sd2.parent) '#13#10 +
      'SELECT '#13#10 +
      '  sd3.name AS parentname, '#13#10 +
      '  gd2.name AS name, '#13#10 +
      '  gd2.int_data AS userkey, '#13#10 +
      '  IIF(sd6.name = ''data'', sd6.blob_data, sd4.blob_data) AS bdata '#13#10 +
      'FROM grid_data gd2 '#13#10 +
      'JOIN gd_storage_data sd3 '#13#10 +
      '  ON gd2.parent = sd3.id '#13#10 +
      'LEFT JOIN gd_storage_data sd4 '#13#10 +
      '  ON sd4.parent = gd2.id AND (sd4.name = ''data'') '#13#10 +
      'LEFT JOIN gd_storage_data sd5 '#13#10 +
      '  ON sd5.parent = gd2.id AND (POSITION(sd5.name || ''('', sd3.name) > 0) '#13#10 +
      'LEFT JOIN gd_storage_data sd6 '#13#10 +
      '  ON sd6.parent = sd5.id AND (sd6.name = ''data'') '#13#10 +
      'WHERE gd2.name LIKE ''%(TgsIBGrid)%'' '#13#10 +
      '  AND (sd4.name = ''data'' OR sd6.name = ''data'')';
    q.ExecQuery;
    while not q.EoF do
    begin
      if q.FieldByName('userkey').AsInteger > 0 then
      begin
        if q.FieldByName('bdata').AsString > '' then
        begin
          S := TStringStream.Create(q.FieldByName('bdata').AsString);
          try
            OwnerName := q.FieldByName('parentname').AsString;
            K := Pos('(', OwnerName);
            if K > 0 then
              OwnerName := Copy(OwnerName, 1, K - 1)
            else
              Assert(False);

            CompName := q.FieldByName('name').AsString;
            K := Pos('(', CompName);
            if K > 0 then
              CompName := Copy(CompName, 1, K - 1)
            else
              Assert(False);

            ParseGridStream(OwnerName + ',' +
              CompName, q.FieldByName('userkey').AsInteger, S);
          finally
            S.Free;
          end;
        end
        else
          Assert(False);
      end;
      q.Next;
    end;
  finally
    q.Free
  end;

  SetDefault;
end;

function TgdGridParser.GetDefaultStrValue(APropID: Integer): String;
var
  q: TIBSQL;
begin
  Assert(APropID > 0);

  Result := '';

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  count(strvalue) AS c, '#13#10 +
      '  strvalue AS s '#13#10 +
      'FROM at_style '#13#10 +
      'WHERE propid = :propid '#13#10 +
      'GROUP BY strvalue '#13#10 +
      'ORDER BY c DESC';
    q.ParamByName('propid').AsInteger := APropID;
    q.ExecQuery;
    if not q.EoF then
      Result := q.FieldByName('s').AsString
    else
      Assert(False);
  finally
    q.Free
  end;
end;

function TgdGridParser.GetDefaultIntValue(APropID: Integer): Integer;
var
  q: TIBSQL;
begin
  Assert(APropID > 0);

  Result := 0;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  count(intvalue) AS c, '#13#10 +
      '  intvalue AS i '#13#10 +
      'FROM at_style '#13#10 +
      'WHERE propid = :propid '#13#10 +
      'GROUP BY intvalue '#13#10 +
      'ORDER BY c DESC';
    q.ParamByName('propid').AsInteger := APropID;
    q.ExecQuery;
    if not q.EoF then
      Result := q.FieldByName('i').AsInteger
    else
      Assert(False);
  finally
    q.Free
  end;
end;

function TgdGridParser.GetDefaultBollValue(APropID: Integer): Boolean;
var
  K: Integer;
begin
  Assert(APropID > 0);

  Result := False;

  K := GetDefaultIntValue(APropID);

  if K = 0 then
    Result := False
  else if K = 1 then
    Result := True
  else
    Assert(False);
end;

procedure TgdGridParser.DeleteStrValues(APropID: Integer; const AStrValue: String);
var
  q: TIBSQL;
begin
  Assert(APropID > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'DELETE FROM at_style WHERE propid = :propid AND strvalue = :strvalue';
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('strvalue').AsString := AStrValue;
    q.ExecQuery;
  finally
    q.Free
  end;
end;

procedure TgdGridParser.DeleteIntValues(APropID: Integer; AnIntValue: Integer);
var
  q: TIBSQL;
begin
  Assert(APropID > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'DELETE FROM at_style WHERE propid = :propid AND intvalue = :intvalue';
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('intvalue').AsInteger := AnIntValue;
    q.ExecQuery;
  finally
    q.Free
  end;
end;

procedure TgdGridParser.DeleteBoolValues(APropID: Integer; ABollValue: Boolean);
begin
 if ABollValue then
   DeleteIntValues(APropID, 1)
 else
   DeleteIntValues(APropID, 0);
end;

procedure TgdGridParser._SetDefault(AnObjKey: Integer);
var
  Str: String;
  Int: Integer;
  Bool: Boolean;
begin
  Assert(AnObjKey > 0);

  //cTableFontName
  Str := GetDefaultStrValue(cTableFontName);
  DeleteStrValues(cTableFontName, Str);
  SaveStrValue(AnObjKey, cTableFontName, Str, 0);

  //cTableFontColor
  Str := GetDefaultStrValue(cTableFontColor);
  DeleteStrValues(cTableFontColor, Str);
  SaveStrValue(AnObjKey, cTableFontColor, Str, 0);

  //cTableFontHeight          = 1003;
  Int := GetDefaultIntValue(cTableFontHeight);
  DeleteIntValues(cTableFontHeight, Int);
  SaveIntValue(AnObjKey, cTableFontHeight, Int, 0);

  //cTableFontPitch           = 1004;
  Str := GetDefaultStrValue(cTableFontPitch);
  DeleteStrValues(cTableFontPitch, Str);
  SaveStrValue(AnObjKey, cTableFontPitch, Str, 0);

  //cTableFontSize            = 1005;
  Int := GetDefaultIntValue(cTableFontSize);
  DeleteIntValues(cTableFontSize, Int);
  SaveIntValue(AnObjKey, cTableFontSize, Int, 0);

  //cTableFontStyle           = 1006;
  Str := GetDefaultStrValue(cTableFontStyle);
  DeleteStrValues(cTableFontStyle, Str);
  SaveStrValue(AnObjKey, cTableFontStyle, Str, 0);

  //cTableFontCharSet         = 1007;
  Int := GetDefaultIntValue(cTableFontCharSet);
  DeleteIntValues(cTableFontCharSet, Int);
  SaveIntValue(AnObjKey, cTableFontCharSet, Int, 0);

  //cTableColor               = 1008;
  Str := GetDefaultStrValue(cTableColor);
  DeleteStrValues(cTableColor, Str);
  SaveStrValue(AnObjKey, cTableColor, Str, 0);

  //Selected
  //cSelectedFontName         = 1009;
  Str := GetDefaultStrValue(cSelectedFontName);
  DeleteStrValues(cSelectedFontName, Str);
  SaveStrValue(AnObjKey, cSelectedFontName, Str, 0);

  //cSelectedFontColor        = 1010;
  Str := GetDefaultStrValue(cSelectedFontColor);
  DeleteStrValues(cSelectedFontColor, Str);
  SaveStrValue(AnObjKey, cSelectedFontColor, Str, 0);

  //cSelectedFontHeight       = 1011;
  Int := GetDefaultIntValue(cSelectedFontHeight);
  DeleteIntValues(cSelectedFontHeight, Int);
  SaveIntValue(AnObjKey, cSelectedFontHeight, Int, 0);

  //cSelectedFontPitch        = 1012;
  Str := GetDefaultStrValue(cSelectedFontPitch);
  DeleteStrValues(cSelectedFontPitch, Str);
  SaveStrValue(AnObjKey, cSelectedFontPitch, Str, 0);


  //cSelectedFontSize         = 1013;
  Int := GetDefaultIntValue(cSelectedFontSize);
  DeleteIntValues(cSelectedFontSize, Int);
  SaveIntValue(AnObjKey, cSelectedFontSize, Int, 0);

  //cSelectedFontStyle        = 1014;
  Str := GetDefaultStrValue(cSelectedFontStyle);
  DeleteStrValues(cSelectedFontStyle, Str);
  SaveStrValue(AnObjKey, cSelectedFontStyle, Str, 0);

  //cSelectedFontCharSet      = 1015;
  Int := GetDefaultIntValue(cSelectedFontCharSet);
  DeleteIntValues(cSelectedFontCharSet, Int);
  SaveIntValue(AnObjKey, cSelectedFontCharSet, Int, 0);

  //cSelectedColor            = 1016;
  Str := GetDefaultStrValue(cSelectedColor);
  DeleteStrValues(cSelectedColor, Str);
  SaveStrValue(AnObjKey, cSelectedColor, Str, 0);

  //Title
  //cTitleFontName            = 1017;
  Str := GetDefaultStrValue(cTitleFontName);
  DeleteStrValues(cTitleFontName, Str);
  SaveStrValue(AnObjKey, cTitleFontName, Str, 0);

  //cTitleFontColor           = 1018;
  Str := GetDefaultStrValue(cTitleFontColor);
  DeleteStrValues(cTitleFontColor, Str);
  SaveStrValue(AnObjKey, cTitleFontColor, Str, 0);

  //cTitleFontHeight          = 1019;
  Int := GetDefaultIntValue(cTitleFontHeight);
  DeleteIntValues(cTitleFontHeight, Int);
  SaveIntValue(AnObjKey, cTitleFontHeight, Int, 0);

  //cTitleFontPitch           = 1020;
  Str := GetDefaultStrValue(cTitleFontPitch);
  DeleteStrValues(cTitleFontPitch, Str);
  SaveStrValue(AnObjKey, cTitleFontPitch, Str, 0);

  //cTitleFontSize            = 1021;
  Int := GetDefaultIntValue(cTitleFontSize);
  DeleteIntValues(cTitleFontSize, Int);
  SaveIntValue(AnObjKey, cTitleFontSize, Int, 0);

  //cTitleFontStyle           = 1022;
  Str := GetDefaultStrValue(cTitleFontStyle);
  DeleteStrValues(cTitleFontStyle, Str);
  SaveStrValue(AnObjKey, cTitleFontStyle, Str, 0);

  //cTitleFontCharSet         = 1023;
  Int := GetDefaultIntValue(cTitleFontCharSet);
  DeleteIntValues(cTitleFontCharSet, Int);
  SaveIntValue(AnObjKey, cTitleFontCharSet, Int, 0);

  //cTitleColor               = 1024;
  Str := GetDefaultStrValue(cTitleColor);
  DeleteStrValues(cTitleColor, Str);
  SaveStrValue(AnObjKey, cTitleColor, Str, 0);

  //cStriped                  = 1025;
  Bool := GetDefaultBollValue(cStriped);
  DeleteBoolValues(cStriped, Bool);
  SaveBoolValue(AnObjKey, cStriped, Bool, 0);

  //cStripeEven               = 1026;
  Str := GetDefaultStrValue(cStripeEvenColor);
  DeleteStrValues(cStripeEvenColor, Str);
  SaveStrValue(AnObjKey, cStripeEvenColor, Str, 0);

  //cStripeOdd                = 1027;
  Str := GetDefaultStrValue(cStripeOddColor);
  DeleteStrValues(cStripeOddColor, Str);
  SaveStrValue(AnObjKey, cStripeOddColor, Str, 0);

  {//expand
  cExpandFieldName          = 1028;
  cExpandDisplayField       = 1029;
  cExpandLineCount          = 1030;
  cExpandOptions             = 1031;
  cExpandsActive            = 1032;
  cExpandsSeparate          = 1033;

  //Condition
  cConditionName            = 1034;
  cConditionDisplayFields   = 1035;
  cConditionFieldName       = 1036;
  cConditionFontName        = 1037;
  cConditionFontColor       = 1038;
  cConditionFontHeight      = 1039;
  cConditionFontPitch       = 1040;
  cConditionFontSize        = 1041;
  cConditionFontStyle       = 1042;
  cConditionFontCharSet     = 1043;
  cConditionColor           = 1044;
  cConditionExpression1     = 1045;
  cConditionExpression2     = 1046;
  cConditionKind            = 1047;
  cConditionDisplayOptions  = 1048;
  cConditionEvaluateFormula = 1049;
  cConditionUserCondition   = 1050;}

  //cScaleColumns             = 1051;
  Bool := GetDefaultBollValue(cScaleColumns);
  DeleteBoolValues(cScaleColumns, Bool);
  SaveBoolValue(AnObjKey, cScaleColumns, Bool, 0);

  //cShowTotals               = 1052;
  Bool := GetDefaultBollValue(cShowTotals);
  DeleteBoolValues(cShowTotals, Bool);
  SaveBoolValue(AnObjKey, cShowTotals, Bool, 0);

  //cShowFooter               = 1053;
  Bool := GetDefaultBollValue(cShowFooter);
  DeleteBoolValues(cShowFooter, Bool);
  SaveBoolValue(AnObjKey, cShowFooter, Bool, 0);

  //cTitlesExpanding          = 1054;
  Bool := GetDefaultBollValue(cTitlesExpanding);
  DeleteBoolValues(cTitlesExpanding, Bool);
  SaveBoolValue(AnObjKey, cTitlesExpanding, Bool, 0);

  //cConditionsActive         = 1055;
  Bool := GetDefaultBollValue(cConditionsActive);
  DeleteBoolValues(cConditionsActive, Bool);
  SaveBoolValue(AnObjKey, cConditionsActive, Bool, 0);

  //cShowRowLines             = 1056;
  Bool := GetDefaultBollValue(cShowRowLines);
  DeleteBoolValues(cShowRowLines, Bool);
  SaveBoolValue(AnObjKey, cShowRowLines, Bool, 0);

  //cColumnTitleCaption       = 1057;
  Str := '';
  DeleteStrValues(cColumnTitleCaption, Str);
  SaveStrValue(AnObjKey, cColumnTitleCaption, Str, 0);

  //cColumnDisplayFormat      = 1058;
  Str := GetDefaultStrValue(cColumnDisplayFormat);
  DeleteStrValues(cColumnDisplayFormat, Str);
  SaveStrValue(AnObjKey, cColumnDisplayFormat, Str, 0);

  //cColumnVisible            = 1059;
  Bool := GetDefaultBollValue(cColumnVisible);
  DeleteBoolValues(cColumnVisible, Bool);
  SaveBoolValue(AnObjKey, cColumnVisible, Bool, 0);

  //cColumnReadOnly           = 1060;
  Bool := GetDefaultBollValue(cColumnReadOnly);
  DeleteBoolValues(cColumnReadOnly, Bool);
  SaveBoolValue(AnObjKey, cColumnReadOnly, Bool, 0);

  //cColumnTotalSum           = 1061;
  Bool := GetDefaultBollValue(cColumnTotalSum);
  DeleteBoolValues(cColumnTotalSum, Bool);
  SaveBoolValue(AnObjKey, cColumnTotalSum, Bool, 0);

  //cColumnWidth              = 1062;
  Int := GetDefaultIntValue(cColumnWidth);
  DeleteIntValues(cColumnWidth, Int);
  SaveIntValue(AnObjKey, cColumnWidth, Int, 0);

  //cColumnTitleFontName      = 1063;
  Str := GetDefaultStrValue(cColumnTitleFontName);
  DeleteStrValues(cColumnTitleFontName, Str);
  SaveStrValue(AnObjKey, cColumnTitleFontName, Str, 0);

  //cColumnTitleFontColor     = 1064;
  Str := GetDefaultStrValue(cColumnTitleFontColor);
  DeleteStrValues(cColumnTitleFontColor, Str);
  SaveStrValue(AnObjKey, cColumnTitleFontColor, Str, 0);

  //cColumnTitleFontHeight    = 1065;
  Int := GetDefaultIntValue(cColumnTitleFontHeight);
  DeleteIntValues(cColumnTitleFontHeight, Int);
  SaveIntValue(AnObjKey, cColumnTitleFontHeight, Int, 0);

  //cColumnTitleFontPitch     = 1066;
  Str := GetDefaultStrValue(cColumnTitleFontPitch);
  DeleteStrValues(cColumnTitleFontPitch, Str);
  SaveStrValue(AnObjKey, cColumnTitleFontPitch, Str, 0);

  //cColumnTitleFontSize      = 1067;
  Int := GetDefaultIntValue(cColumnTitleFontSize);
  DeleteIntValues(cColumnTitleFontSize, Int);
  SaveIntValue(AnObjKey, cColumnTitleFontSize, Int, 0);

  //cColumnTitleFontStyle     = 1068;
  Str := GetDefaultStrValue(cColumnTitleFontStyle);
  DeleteStrValues(cColumnTitleFontStyle, Str);
  SaveStrValue(AnObjKey, cColumnTitleFontStyle, Str, 0);

  //cColumnTitleFontCharSet   = 1069;
  Int := GetDefaultIntValue(cColumnTitleFontCharSet);
  DeleteIntValues(cColumnTitleFontCharSet, Int);
  SaveIntValue(AnObjKey, cColumnTitleFontCharSet, Int, 0);

  //cColumnTitleColor         = 1070;
  Str := GetDefaultStrValue(cColumnTitleColor);
  DeleteStrValues(cColumnTitleColor, Str);
  SaveStrValue(AnObjKey, cColumnTitleColor, Str, 0);

  //cColumnFontName           = 1071;
  Str := GetDefaultStrValue(cColumnFontName);
  DeleteStrValues(cColumnFontName, Str);
  SaveStrValue(AnObjKey, cColumnFontName, Str, 0);

  //cColumnFontColor          = 1072;
  Str := GetDefaultStrValue(cColumnFontColor);
  DeleteStrValues(cColumnFontColor, Str);
  SaveStrValue(AnObjKey, cColumnFontColor, Str, 0);

  //cColumnFontHeight         = 1073;
  Int := GetDefaultIntValue(cColumnFontHeight);
  DeleteIntValues(cColumnFontHeight, Int);
  SaveIntValue(AnObjKey, cColumnFontHeight, Int, 0);

  //cColumnFontPitch          = 1074;
  Str := GetDefaultStrValue(cColumnFontPitch);
  DeleteStrValues(cColumnFontPitch, Str);
  SaveStrValue(AnObjKey, cColumnFontPitch, Str, 0);

  //cColumnFontSize           = 1075;
  Int := GetDefaultIntValue(cColumnFontSize);
  DeleteIntValues(cColumnFontSize, Int);
  SaveIntValue(AnObjKey, cColumnFontSize, Int, 0);

  //cColumnFontStyle          = 1076;
  Str := GetDefaultStrValue(cColumnFontStyle);
  DeleteStrValues(cColumnFontStyle, Str);
  SaveStrValue(AnObjKey, cColumnFontStyle, Str, 0);

  //cColumnFontCharSet        = 1077;
  Int := GetDefaultIntValue(cColumnFontCharSet);
  DeleteIntValues(cColumnFontCharSet, Int);
  SaveIntValue(AnObjKey, cColumnFontCharSet, Int, 0);

  //cColumnColor              = 1078;
  Str := GetDefaultStrValue(cColumnColor);
  DeleteStrValues(cColumnColor, Str);
  SaveStrValue(AnObjKey, cColumnColor, Str, 0);

  //cColumnTitleAlignment     = 1079;
  Str := GetDefaultStrValue(cColumnTitleAlignment);
  DeleteStrValues(cColumnTitleAlignment, Str);
  SaveStrValue(AnObjKey, cColumnTitleAlignment, Str, 0);

  //cColumnAlignment          = 1080;
  Str := GetDefaultStrValue(cColumnAlignment);
  DeleteStrValues(cColumnAlignment, Str);
  SaveStrValue(AnObjKey, cColumnAlignment, Str, 0);
end;

procedure TgdGridParser.SetDefault;
var
  ObjKey: Integer;
begin
  ObjKey := GetObjID(cGlobal, cGloblaObjName);

  _SetDefault(ObjKey);
end;

initialization

finalization
  FreeAndNil(_gdStyleManager);

end.
