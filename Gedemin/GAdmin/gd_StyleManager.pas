unit gd_StyleManager;

interface

uses
  Classes,
  Graphics,
  IBDatabase,
  JclStrHashMap;

const
  cDefMaxLengthStrValue = 60;

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
  cStripeEven               = 1026;
  cStripeOdd                = 1027;

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
    function Iterate_FreeStyle(AUserData: PUserData; const AStr: string; var AData {$IFNDEF CLR}: PData{$ENDIF}): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    function FindStr(const S: String; out AStrValue: String): Boolean;
    function FindInt(const S: String; out AnIntValue: Integer): Boolean;

    procedure AddStr(const S: string; const AStrValue: String);
    procedure AddInt(const S: string; AnIntValue: Integer);
    procedure Remove(const S: string);

    procedure LoadFromDB;
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

    function GetDefaultStrValue(APropID: Integer; AnUserKey: Integer): String;
    function GetDefaultIntValue(APropID: Integer; AnUserKey: Integer): Integer;
    function GetDefaultBollValue(APropID: Integer; AnUserKey: Integer): Boolean;

    procedure DeleteStrValues(APropID: Integer; const AStrValue: String; AnUserKey: Integer);
    procedure DeleteIntValues(APropID: Integer; AnIntValue: Integer; AnUserKey: Integer);
    procedure DeleteBoolValues(APropID: Integer; ABollValue: Boolean; AnUserKey: Integer);

    function GetUserKeys: String;

    procedure _SetDefault(AnObjKey: Integer; AnUserKey: Integer);

    procedure SetDefault;

  public
    constructor Create(ATransaction: TIBTransaction);
    destructor Destroy; override;

    procedure Run;
  end;

var
  _gdStyleManager: TgdStyleManager;

function gdStyleManager: TgdStyleManager;

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

function TgdStyleManager.FindStr(const S: String; out AStrValue: String): Boolean;
var
  PS: PStyle;
begin
  Result := FStyleList.Find(S, PS);

  if Result then
  begin
    if PS^.IsInt then
      Assert(False);

    AStrValue := PS^.StrVal;
  end;
end;

function TgdStyleManager.FindInt(const S: String; out AnIntValue: Integer): Boolean;
var
  PS: PStyle;
begin
  Result := FStyleList.Find(S, PS);

  if Result then
  begin
    if not PS^.IsInt then
      Assert(False);

    AnIntValue := PS^.IntVal;
  end;
end;

procedure TgdStyleManager.AddStr(const S: string; const AStrValue: String);
var
  PS: PStyle;
  P: Pointer;
begin
  if FStyleList.Find(S, P) then
    Assert(False);

  New(PS);
  PS^.StrVal := AStrValue;
  PS^.IsInt := False;

  FStyleList.Add(S, PS);
end;

procedure TgdStyleManager.AddInt(const S: string; AnIntValue: Integer);
var
  PS: PStyle;
  P: Pointer;
begin
  if FStyleList.Find(S, P) then
    Assert(False);

  New(PS);
  PS^.IntVal := AnIntValue;
  PS^.IsInt := True;

  FStyleList.Add(S, PS);
end;

procedure TgdStyleManager.Remove(const S: string);
var
  PS: PStyle;
begin
  PS := FStyleList.Remove(S);
  Dispose(PS);
end;

procedure TgdStyleManager.ClearData;
begin
  FStyleList.IterateMethod(nil, Iterate_FreeStyle);
end;

function TgdStyleManager.Iterate_FreeStyle(AUserData: PUserData; const AStr: string; var AData {$IFNDEF CLR}: PData{$ENDIF}): Boolean;
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
        + IntToStr(q.FieldByName('propid').AsInteger);

      if q.FieldByName('userkey').AsInteger > 0 then
        S := S + ',' + IntToStr(q.FieldByName('userkey').AsInteger);

      if q.FieldByName('themekey').AsInteger > 0 then
        S := S + ',' + IntToStr(q.FieldByName('themekey').AsInteger);

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
  //Assert(AStrValue > '');
  Assert(AnUserKey > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'INSERT INTO at_style (objectkey, propid, strvalue, userkey) ' +
      'VALUES (:objectkey, :propid, :strvalue, :userkey)';
    q.ParamByName('objectkey').AsInteger := AnObjectKey;
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('strvalue').AsString := AStrValue;
    q.ParamByName('userkey').AsInteger := AnUserKey;
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
  Assert(AnUserKey > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'INSERT INTO at_style (objectkey, propid, intvalue, userkey) ' +
      'VALUES (:objectkey, :propid, :intvalue, :userkey)';
    q.ParamByName('objectkey').AsInteger := AnObjectKey;
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('intvalue').AsInteger := AIntValue;
    q.ParamByName('userkey').AsInteger := AnUserKey;
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
  Assert(AnUserKey > 0);

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
        if Columns[I].Title.Alignment = taLeftJustify then
          SaveStrValue(OK, cColumnTitleAlignment, 'taLeftJustify', AnUserKey)
        else if Columns[I].Title.Alignment = taRightJustify then
          SaveStrValue(OK, cColumnTitleAlignment, 'taRightJustify', AnUserKey)
        else
          SaveStrValue(OK, cColumnTitleAlignment, 'taCenter', AnUserKey);

        // Выравнивание в колонке
        if Columns[I].Alignment = taLeftJustify then
          SaveStrValue(OK, cColumnAlignment, 'taLeftJustify', AnUserKey)
        else if Columns[I].Alignment = taRightJustify then
          SaveStrValue(OK, cColumnAlignment, 'taRightJustify', AnUserKey)
        else
          SaveStrValue(OK, cColumnAlignment, 'taCenter', AnUserKey)
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
var
  S: String;
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

  if AFont.Pitch = fpDefault then
    SaveStrValue(AnObjKey, CurrFontPitch, 'fpDefault', AnUserKey)
  else if AFont.Pitch = fpFixed then
    SaveStrValue(AnObjKey, CurrFontPitch, 'fpFixed', AnUserKey)
  else
    SaveStrValue(AnObjKey, CurrFontPitch, 'fpVariable', AnUserKey);

  SaveIntValue(AnObjKey, CurrFontSize, AFont.Size, AnUserKey);

  S := '';

  if fsBold in AFont.Style then
    S := S + 'fsBold' + ',';
  if fsItalic in AFont.Style then
    S := S + 'fsItalic' + ',';
  if fsUnderline in AFont.Style then
    S := S + 'fsUnderline' + ',';
  if fsStrikeOut in AFont.Style then
    S := S + 'fsStrikeOut' + ',';

  if S > '' then
    SetLength(S, Length(S) - 1);

  SaveStrValue(AnObjKey, CurrFontStyle, S, AnUserKey);

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
      SaveStrValue(ObjectKey, cStripeOdd, ColorToString(StripeOdd), AnUserKey);

      StripeEven := StringToColor(R.ReadString);
      SaveStrValue(ObjectKey, cStripeEven, ColorToString(StripeEven), AnUserKey);

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

function TgdGridParser.GetDefaultStrValue(APropID: Integer; AnUserKey: Integer): String;
var
  q: TIBSQL;
begin
  Assert(APropID > 0);
  Assert(AnUserKey > 0);

  Result := '';

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  count(strvalue) AS c, '#13#10 +
      '  strvalue AS s '#13#10 +
      'FROM at_style '#13#10 +
      'WHERE propid = :propid AND userkey = :userkey '#13#10 +
      'GROUP BY strvalue '#13#10 +
      'ORDER BY c DESC';
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('userkey').AsInteger := AnUserKey;
    q.ExecQuery;
    if not q.EoF then
      Result := q.FieldByName('s').AsString
    else
      Assert(False);
  finally
    q.Free
  end;
end;

function TgdGridParser.GetDefaultIntValue(APropID: Integer; AnUserKey: Integer): Integer;
var
  q: TIBSQL;
begin
  Assert(APropID > 0);
  Assert(AnUserKey > 0);

  Result := 0;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  count(intvalue) AS c, '#13#10 +
      '  intvalue AS i '#13#10 +
      'FROM at_style '#13#10 +
      'WHERE propid = :propid AND userkey = :userkey '#13#10 +
      'GROUP BY intvalue '#13#10 +
      'ORDER BY c DESC';
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('userkey').AsInteger := AnUserKey;
    q.ExecQuery;
    if not q.EoF then
      Result := q.FieldByName('i').AsInteger
    else
      Assert(False);
  finally
    q.Free
  end;
end;

function TgdGridParser.GetDefaultBollValue(APropID: Integer; AnUserKey: Integer): Boolean;
var
  K: Integer;
begin
  Assert(APropID > 0);
  Assert(AnUserKey > 0);

  Result := False;

  K := GetDefaultIntValue(APropID, AnUserKey);

  if K = 0 then
    Result := False
  else if K = 1 then
    Result := True
  else
    Assert(False);
end;

procedure TgdGridParser.DeleteStrValues(APropID: Integer; const AStrValue: String; AnUserKey: Integer);
var
  q: TIBSQL;
begin
  Assert(APropID > 0);
  Assert(AnUserKey > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'DELETE FROM at_style WHERE propid = :propid AND strvalue = :strvalue AND userkey = :userkey';
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('strvalue').AsString := AStrValue;
    q.ParamByName('userkey').AsInteger := AnUserKey;
    q.ExecQuery;
  finally
    q.Free
  end;
end;

procedure TgdGridParser.DeleteIntValues(APropID: Integer; AnIntValue: Integer; AnUserKey: Integer);
var
  q: TIBSQL;
begin
  Assert(APropID > 0);
  Assert(AnUserKey > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'DELETE FROM at_style WHERE propid = :propid AND intvalue = :intvalue AND userkey = :userkey';
    q.ParamByName('propid').AsInteger := APropID;
    q.ParamByName('intvalue').AsInteger := AnIntValue;
    q.ParamByName('userkey').AsInteger := AnUserKey;
    q.ExecQuery;
  finally
    q.Free
  end;
end;

procedure TgdGridParser.DeleteBoolValues(APropID: Integer; ABollValue: Boolean; AnUserKey: Integer);
begin
 if ABollValue then
   DeleteIntValues(APropID, 1, AnUserKey)
 else
   DeleteIntValues(APropID, 0, AnUserKey);
end;

function TgdGridParser.GetUserKeys: String;
var
  q: TIBSQL;
begin
  Result := '';

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'SELECT LIST(userkey) FROM (SELECT userkey FROM at_style GROUP BY userkey)';
    q.ExecQuery;
    if not q.EoF then
      Result := q.FieldByName('list').AsString;
  finally
    q.Free
  end;

  Assert(Result > '');
end;

procedure TgdGridParser._SetDefault(AnObjKey: Integer; AnUserKey: Integer);
var
  Str: String;
  Int: Integer;
  Bool: Boolean;
begin
  Assert(AnObjKey > 0);
  Assert(AnUserKey > 0);

  //cTableFontName
  Str := GetDefaultStrValue(cTableFontName, AnUserKey);
  DeleteStrValues(cTableFontName, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTableFontName, Str, AnUserKey);

  //cTableFontColor
  Str := GetDefaultStrValue(cTableFontColor, AnUserKey);
  DeleteStrValues(cTableFontColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTableFontColor, Str, AnUserKey);

  //cTableFontHeight          = 1003;
  Int := GetDefaultIntValue(cTableFontHeight, AnUserKey);
  DeleteIntValues(cTableFontHeight, Int, AnUserKey);
  SaveIntValue(AnObjKey, cTableFontHeight, Int, AnUserKey);

  //cTableFontPitch           = 1004;
  Str := GetDefaultStrValue(cTableFontPitch, AnUserKey);
  DeleteStrValues(cTableFontPitch, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTableFontPitch, Str, AnUserKey);

  //cTableFontSize            = 1005;
  Int := GetDefaultIntValue(cTableFontSize, AnUserKey);
  DeleteIntValues(cTableFontSize, Int, AnUserKey);
  SaveIntValue(AnObjKey, cTableFontSize, Int, AnUserKey);

  //cTableFontStyle           = 1006;
  Str := GetDefaultStrValue(cTableFontStyle, AnUserKey);
  DeleteStrValues(cTableFontStyle, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTableFontStyle, Str, AnUserKey);

  //cTableFontCharSet         = 1007;
  Int := GetDefaultIntValue(cTableFontCharSet, AnUserKey);
  DeleteIntValues(cTableFontCharSet, Int, AnUserKey);
  SaveIntValue(AnObjKey, cTableFontCharSet, Int, AnUserKey);

  //cTableColor               = 1008;
  Str := GetDefaultStrValue(cTableColor, AnUserKey);
  DeleteStrValues(cTableColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTableColor, Str, AnUserKey);

  //Selected
  //cSelectedFontName         = 1009;
  Str := GetDefaultStrValue(cSelectedFontName, AnUserKey);
  DeleteStrValues(cSelectedFontName, Str, AnUserKey);
  SaveStrValue(AnObjKey, cSelectedFontName, Str, AnUserKey);

  //cSelectedFontColor        = 1010;
  Str := GetDefaultStrValue(cSelectedFontColor, AnUserKey);
  DeleteStrValues(cSelectedFontColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cSelectedFontColor, Str, AnUserKey);

  //cSelectedFontHeight       = 1011;
  Int := GetDefaultIntValue(cSelectedFontHeight, AnUserKey);
  DeleteIntValues(cSelectedFontHeight, Int, AnUserKey);
  SaveIntValue(AnObjKey, cSelectedFontHeight, Int, AnUserKey);

  //cSelectedFontPitch        = 1012;
  Str := GetDefaultStrValue(cSelectedFontPitch, AnUserKey);
  DeleteStrValues(cSelectedFontPitch, Str, AnUserKey);
  SaveStrValue(AnObjKey, cSelectedFontPitch, Str, AnUserKey);


  //cSelectedFontSize         = 1013;
  Int := GetDefaultIntValue(cSelectedFontSize, AnUserKey);
  DeleteIntValues(cSelectedFontSize, Int, AnUserKey);
  SaveIntValue(AnObjKey, cSelectedFontSize, Int, AnUserKey);

  //cSelectedFontStyle        = 1014;
  Str := GetDefaultStrValue(cSelectedFontStyle, AnUserKey);
  DeleteStrValues(cSelectedFontStyle, Str, AnUserKey);
  SaveStrValue(AnObjKey, cSelectedFontStyle, Str, AnUserKey);

  //cSelectedFontCharSet      = 1015;
  Int := GetDefaultIntValue(cSelectedFontCharSet, AnUserKey);
  DeleteIntValues(cSelectedFontCharSet, Int, AnUserKey);
  SaveIntValue(AnObjKey, cSelectedFontCharSet, Int, AnUserKey);

  //cSelectedColor            = 1016;
  Str := GetDefaultStrValue(cSelectedColor, AnUserKey);
  DeleteStrValues(cSelectedColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cSelectedColor, Str, AnUserKey);

  //Title
  //cTitleFontName            = 1017;
  Str := GetDefaultStrValue(cTitleFontName, AnUserKey);
  DeleteStrValues(cTitleFontName, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTitleFontName, Str, AnUserKey);

  //cTitleFontColor           = 1018;
  Str := GetDefaultStrValue(cTitleFontColor, AnUserKey);
  DeleteStrValues(cTitleFontColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTitleFontColor, Str, AnUserKey);

  //cTitleFontHeight          = 1019;
  Int := GetDefaultIntValue(cTitleFontHeight, AnUserKey);
  DeleteIntValues(cTitleFontHeight, Int, AnUserKey);
  SaveIntValue(AnObjKey, cTitleFontHeight, Int, AnUserKey);

  //cTitleFontPitch           = 1020;
  Str := GetDefaultStrValue(cTitleFontPitch, AnUserKey);
  DeleteStrValues(cTitleFontPitch, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTitleFontPitch, Str, AnUserKey);

  //cTitleFontSize            = 1021;
  Int := GetDefaultIntValue(cTitleFontSize, AnUserKey);
  DeleteIntValues(cTitleFontSize, Int, AnUserKey);
  SaveIntValue(AnObjKey, cTitleFontSize, Int, AnUserKey);

  //cTitleFontStyle           = 1022;
  Str := GetDefaultStrValue(cTitleFontStyle, AnUserKey);
  DeleteStrValues(cTitleFontStyle, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTitleFontStyle, Str, AnUserKey);

  //cTitleFontCharSet         = 1023;
  Int := GetDefaultIntValue(cTitleFontCharSet, AnUserKey);
  DeleteIntValues(cTitleFontCharSet, Int, AnUserKey);
  SaveIntValue(AnObjKey, cTitleFontCharSet, Int, AnUserKey);

  //cTitleColor               = 1024;
  Str := GetDefaultStrValue(cTitleColor, AnUserKey);
  DeleteStrValues(cTitleColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cTitleColor, Str, AnUserKey);

  //cStriped                  = 1025;
  Bool := GetDefaultBollValue(cStriped, AnUserKey);
  DeleteBoolValues(cStriped, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cStriped, Bool, AnUserKey);

  //cStripeEven               = 1026;
  Str := GetDefaultStrValue(cStripeEven, AnUserKey);
  DeleteStrValues(cStripeEven, Str, AnUserKey);
  SaveStrValue(AnObjKey, cStripeEven, Str, AnUserKey);

  //cStripeOdd                = 1027;
  Str := GetDefaultStrValue(cStripeOdd, AnUserKey);
  DeleteStrValues(cStripeOdd, Str, AnUserKey);
  SaveStrValue(AnObjKey, cStripeOdd, Str, AnUserKey);

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
  Bool := GetDefaultBollValue(cScaleColumns, AnUserKey);
  DeleteBoolValues(cScaleColumns, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cScaleColumns, Bool, AnUserKey);

  //cShowTotals               = 1052;
  Bool := GetDefaultBollValue(cShowTotals, AnUserKey);
  DeleteBoolValues(cShowTotals, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cShowTotals, Bool, AnUserKey);

  //cShowFooter               = 1053;
  Bool := GetDefaultBollValue(cShowFooter, AnUserKey);
  DeleteBoolValues(cShowFooter, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cShowFooter, Bool, AnUserKey);

  //cTitlesExpanding          = 1054;
  Bool := GetDefaultBollValue(cTitlesExpanding, AnUserKey);
  DeleteBoolValues(cTitlesExpanding, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cTitlesExpanding, Bool, AnUserKey);

  //cConditionsActive         = 1055;
  Bool := GetDefaultBollValue(cConditionsActive, AnUserKey);
  DeleteBoolValues(cConditionsActive, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cConditionsActive, Bool, AnUserKey);

  //cShowRowLines             = 1056;
  Bool := GetDefaultBollValue(cShowRowLines, AnUserKey);
  DeleteBoolValues(cShowRowLines, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cShowRowLines, Bool, AnUserKey);

  //cColumnTitleCaption       = 1057;
  Str := '';
  DeleteStrValues(cColumnTitleCaption, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnTitleCaption, Str, AnUserKey);

  //cColumnDisplayFormat      = 1058;
  Str := GetDefaultStrValue(cColumnDisplayFormat, AnUserKey);
  DeleteStrValues(cColumnDisplayFormat, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnDisplayFormat, Str, AnUserKey);

  //cColumnVisible            = 1059;
  Bool := GetDefaultBollValue(cColumnVisible, AnUserKey);
  DeleteBoolValues(cColumnVisible, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cColumnVisible, Bool, AnUserKey);

  //cColumnReadOnly           = 1060;
  Bool := GetDefaultBollValue(cColumnReadOnly, AnUserKey);
  DeleteBoolValues(cColumnReadOnly, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cColumnReadOnly, Bool, AnUserKey);

  //cColumnTotalSum           = 1061;
  Bool := GetDefaultBollValue(cColumnTotalSum, AnUserKey);
  DeleteBoolValues(cColumnTotalSum, Bool, AnUserKey);
  SaveBoolValue(AnObjKey, cColumnTotalSum, Bool, AnUserKey);

  //cColumnWidth              = 1062;
  Int := GetDefaultIntValue(cColumnWidth, AnUserKey);
  DeleteIntValues(cColumnWidth, Int, AnUserKey);
  SaveIntValue(AnObjKey, cColumnWidth, Int, AnUserKey);

  //cColumnTitleFontName      = 1063;
  Str := GetDefaultStrValue(cColumnTitleFontName, AnUserKey);
  DeleteStrValues(cColumnTitleFontName, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnTitleFontName, Str, AnUserKey);

  //cColumnTitleFontColor     = 1064;
  Str := GetDefaultStrValue(cColumnTitleFontColor, AnUserKey);
  DeleteStrValues(cColumnTitleFontColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnTitleFontColor, Str, AnUserKey);

  //cColumnTitleFontHeight    = 1065;
  Int := GetDefaultIntValue(cColumnTitleFontHeight, AnUserKey);
  DeleteIntValues(cColumnTitleFontHeight, Int, AnUserKey);
  SaveIntValue(AnObjKey, cColumnTitleFontHeight, Int, AnUserKey);

  //cColumnTitleFontPitch     = 1066;
  Str := GetDefaultStrValue(cColumnTitleFontPitch, AnUserKey);
  DeleteStrValues(cColumnTitleFontPitch, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnTitleFontPitch, Str, AnUserKey);

  //cColumnTitleFontSize      = 1067;
  Int := GetDefaultIntValue(cColumnTitleFontSize, AnUserKey);
  DeleteIntValues(cColumnTitleFontSize, Int, AnUserKey);
  SaveIntValue(AnObjKey, cColumnTitleFontSize, Int, AnUserKey);

  //cColumnTitleFontStyle     = 1068;
  Str := GetDefaultStrValue(cColumnTitleFontStyle, AnUserKey);
  DeleteStrValues(cColumnTitleFontStyle, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnTitleFontStyle, Str, AnUserKey);

  //cColumnTitleFontCharSet   = 1069;
  Int := GetDefaultIntValue(cColumnTitleFontCharSet, AnUserKey);
  DeleteIntValues(cColumnTitleFontCharSet, Int, AnUserKey);
  SaveIntValue(AnObjKey, cColumnTitleFontCharSet, Int, AnUserKey);

  //cColumnTitleColor         = 1070;
  Str := GetDefaultStrValue(cColumnTitleColor, AnUserKey);
  DeleteStrValues(cColumnTitleColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnTitleColor, Str, AnUserKey);

  //cColumnFontName           = 1071;
  Str := GetDefaultStrValue(cColumnFontName, AnUserKey);
  DeleteStrValues(cColumnFontName, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnFontName, Str, AnUserKey);

  //cColumnFontColor          = 1072;
  Str := GetDefaultStrValue(cColumnFontColor, AnUserKey);
  DeleteStrValues(cColumnFontColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnFontColor, Str, AnUserKey);

  //cColumnFontHeight         = 1073;
  Int := GetDefaultIntValue(cColumnFontHeight, AnUserKey);
  DeleteIntValues(cColumnFontHeight, Int, AnUserKey);
  SaveIntValue(AnObjKey, cColumnFontHeight, Int, AnUserKey);

  //cColumnFontPitch          = 1074;
  Str := GetDefaultStrValue(cColumnFontPitch, AnUserKey);
  DeleteStrValues(cColumnFontPitch, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnFontPitch, Str, AnUserKey);

  //cColumnFontSize           = 1075;
  Int := GetDefaultIntValue(cColumnFontSize, AnUserKey);
  DeleteIntValues(cColumnFontSize, Int, AnUserKey);
  SaveIntValue(AnObjKey, cColumnFontSize, Int, AnUserKey);

  //cColumnFontStyle          = 1076;
  Str := GetDefaultStrValue(cColumnFontStyle, AnUserKey);
  DeleteStrValues(cColumnFontStyle, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnFontStyle, Str, AnUserKey);

  //cColumnFontCharSet        = 1077;
  Int := GetDefaultIntValue(cColumnFontCharSet, AnUserKey);
  DeleteIntValues(cColumnFontCharSet, Int, AnUserKey);
  SaveIntValue(AnObjKey, cColumnFontCharSet, Int, AnUserKey);

  //cColumnColor              = 1078;
  Str := GetDefaultStrValue(cColumnColor, AnUserKey);
  DeleteStrValues(cColumnColor, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnColor, Str, AnUserKey);

  //cColumnTitleAlignment     = 1079;
  Str := GetDefaultStrValue(cColumnTitleAlignment, AnUserKey);
  DeleteStrValues(cColumnTitleAlignment, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnTitleAlignment, Str, AnUserKey);

  //cColumnAlignment          = 1080;
  Str := GetDefaultStrValue(cColumnAlignment, AnUserKey);
  DeleteStrValues(cColumnAlignment, Str, AnUserKey);
  SaveStrValue(AnObjKey, cColumnAlignment, Str, AnUserKey);
end;

procedure TgdGridParser.SetDefault;
var
  SL: TStringList;
  I: Integer;
  ObjKey: Integer;
begin
  SL := TStringList.Create;
  try
    SL.CommaText := GetUserKeys;

    ObjKey := GetObjID(cGlobal, 'global');

    for I := 0 to SL.Count - 1 do
    begin
      _SetDefault(ObjKey, StrToInt(SL[I]));
    end;
  finally
    SL.Free;
  end;
end;

initialization

finalization
  FreeAndNil(_gdStyleManager);

end.
