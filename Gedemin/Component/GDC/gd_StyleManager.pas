unit gd_StyleManager;

interface

uses
  Contnrs, Classes, TypInfo, Forms, SysUtils, gsDBGrid, Graphics, Windows, IBDatabase;

const
  //ObjTypes
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
  cExpandOption             = 1031;

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
  cConditionDisplayOption   = 1048;
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

  //Default Values
  //Table
  cDefTableFontName            = 'Tahoma';
  cDefTableFontColor           = clWindowText;
  cDefTableFontHeight          = -11;
  cDefTableFontPitch           = fpDefault;
  cDefTableFontSize            = 8;
  cDefTableFontStyles          = [];
  cDefTableFontCharSet         = DEFAULT_CHARSET;
  cDefTableColor               = clWindow;

  //Selected
  cDefSelectedFontName         = 'Tahoma';
  cDefSelectedFontColor        = clHighlightText;
  cDefSelectedFontHeight       = -11;
  cDefSelectedFontPitch        = fpDefault;
  cDefSelectedFontSize         = 8;
  cDefSelectedFontStyles       = [];
  cDefSelectedFontCharSet      = DEFAULT_CHARSET;
  cDefSelectedColor            = clHighlight;

  //Title
  cDefTitleFontName            = 'Tahoma';
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
  cDefConditionFontName        = 'Tahoma';
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

  cDefColumnTitleFontName      = 'Tahoma';
  cDefColumnTitleFontColor     = clWindowText;
  cDefColumnTitleFontHeight    = -11;
  cDefColumnTitleFontPitch     = fpDefault;
  cDefColumnTitleFontSize      = 8;
  cDefColumnTitleFontStyles    = [];
  cDefColumnTitleFontCharSet   = DEFAULT_CHARSET;
  cDefColumnTitleColor         = clBtnFace;

  cDefColumnFontName           = 'Tahoma';
  cDefColumnFontColor          = clWindowText;
  cDefColumnFontHeight         = -11;
  cDefColumnFontPitch          = fpDefault;
  cDefColumnFontSize           = 8;
  cDefColumnFontStyles         = [];
  cDefColumnFontCharSet        = DEFAULT_CHARSET;
  cDefColumnColor              = clWindow;

  cDefColumnTitleAlignment     = taLeftJustify;
  cDefColumnAlignment          = taLeftJustify;

type

  TgdStyleEntry = class
  private
    FID: Integer;
    FObjectKey: Integer;
    FPropID: Integer;
    FIntValue: Integer;
    FStrValue: String;
    FUserKey: Integer;
    FThemeKey: Integer;

  public
    property ID: Integer read FID;
    property ObjectKey: Integer read FObjectKey;
    property PropID: Integer read FPropID;
    property IntValue: Integer read FIntValue;
    property StrValue: String read FStrValue;
    property UserKey: Integer read FUserKey;
    property ThemeKey: Integer read FThemeKey;
  end;

  TgdStyleObject = class
  private
    FID: Integer;
    FObjectType: Integer;
    FObjectName: String;

    FEntry: TObjectList;

    function GetEntry(Index: Integer): TgdStyleEntry;
    function GetCount: Integer;

  public
    function Compare(const AnObjectType: Integer;
      const AnObjectName: String): Integer;

    property ID: Integer read FID;
    property ObjectType: Integer read FObjectType;
    property ObjectName: String read FObjectName;



    property Entry[Index: Integer]: TgdStyleEntry read GetEntry;
    property Count: Integer read GetCount;
  end;

  TgdStyleManager = class
  private
    FStyleObjects: array of TgdStyleObject;
    FCount: Integer;

    FChanges: TStringList;

    procedure _Grow;
    procedure _Compact;

    function _Find(const AnObjectType: Integer; const AnObjectName: String;
      out Index: Integer): Boolean;
    procedure _Insert(const Index: Integer; ASO: TgdStyleObject);

  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromDB;
    procedure SaveToDB;

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

    procedure ParseGridStream(const AnObjectName: String;
      const AnUserKey: Integer; Stream: TStream);

  public
    constructor Create(ATransaction: TIBTransaction);
    procedure Run;
  end;

var
  _gdStyleManager: TgdStyleManager;

function gdStyleManager: TgdStyleManager;

implementation

uses
  gd_security, gdcBaseInterface, IBSQL, DBGrids;

function gdStyleManager: TgdStyleManager;
begin
  if _gdStyleManager = nil then
    _gdStyleManager := TgdStyleManager.Create;
  Result := _gdStyleManager;
end;

{ TgdStyleEntry }

{ TgdStyleObject }

function TgdStyleObject.GetEntry(Index: Integer): TgdStyleEntry;
begin
  Result := FEntry[Index] as TgdStyleEntry;
end;

function TgdStyleObject.GetCount: Integer;
begin
  if FEntry = nil then
    Result := 0
  else
    Result := FEntry.Count;
end;

function TgdStyleObject.Compare(const AnObjectType: Integer;
  const AnObjectName: String): Integer;
begin
  if FObjectType > AnObjectType then
    Result := 1
  else if FObjectType < AnObjectType then
    Result := -1
  else
    Result := 0;

  if Result = 0 then
    Result := CompareText(FObjectName, AnObjectName);
end;

{ TgdStyleManager }

constructor TgdStyleManager.Create;
begin
  inherited;

  FChanges := TStringList.Create;
end;

destructor TgdStyleManager.Destroy;
begin
  FChanges.Free;

  inherited;
end;

procedure TgdStyleManager._Grow;
begin
  if High(FStyleObjects) = -1 then
    SetLength(FStyleObjects, 2048)
  else
    SetLength(FStyleObjects, High(FStyleObjects) + 1 + 1024);
end;

procedure TgdStyleManager._Compact;
var
  B, E: Integer;
begin
  B := 0;
  while B < FCount do
  begin
    E := B;
    while (E < FCount) and (FStyleObjects[E] = nil) do
      Inc(E);
    if E = FCount then
    begin
      FCount := B;
      break;
    end;
    if E > B then
    begin
      System.Move(FStyleObjects[E], FStyleObjects[B], (FCount - E) * SizeOf(FStyleObjects[0]));
      Dec(FCount, E - B);
    end;
    Inc(B);
  end;
end;

function TgdStyleManager._Find(const AnObjectType: Integer; const AnObjectName: String;
  out Index: Integer): Boolean;
var
  L, H, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    Index := (L + H) shr 1;
    C := FStyleObjects[Index].Compare(AnObjectType, AnObjectName);
    if C < 0 then
      L := Index + 1
    else if C > 0 then
      H := Index - 1
    else begin
      Result := True;
      exit;
    end;
  end;
  Index := L;
end;

procedure TgdStyleManager._Insert(const Index: Integer; ASO: TgdStyleObject);
begin
  if FCount > High(FStyleObjects) then _Grow;
  if Index < FCount then
  begin
    System.Move(FStyleObjects[Index], FStyleObjects[Index + 1],
      (FCount - Index) * SizeOf(FStyleObjects[0]));
  end;
  FStyleObjects[Index] := ASO;
  Inc(FCount);
end;

procedure TgdStyleManager.LoadFromDB;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      q.SQL.Text := ''; 

      q.ExecQuery;
      Tr.Commit;
    finally
      Tr.Free;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdStyleManager.SaveToDB;
var
  I: Integer;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if FChanges.Count > 0 then
  begin
    try
      Assert(gdcBaseManager <> nil);

      q := TIBSQL.Create(nil);
      try
        Tr := TIBTransaction.Create(nil);
        try
          Tr.DefaultDatabase := gdcBaseManager.Database;
          Tr.StartTransaction;
          for I := 0 to FChanges.Count - 1 do
          begin
            q.Close;
            q.SQL.Text := FChanges[I];
            q.ExecQuery;
          end;
          Tr.Commit;
        finally
          Tr.Free;
        end;
      finally
        q.Free;
      end;
    finally
      FChanges.Clear;
    end;
  end;
end;

{ TgdGridParser }

constructor TgdGridParser.Create(ATransaction: TIBTransaction);
begin
  Assert(ATransaction <> nil);
  FTransaction := ATransaction;
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
    q.SQL.Text := 'SELECT id FROM at_style_object WHERE objtype = :objtype AND objname = :objname';
    q.ParamByName('objtype').AsInteger := AnObjType;
    q.ParamByName('objname').AsString := AnObjName;
    q.ExecQuery;
    if not q.EOF then
      Result := q.FieldByName('id').AsInteger
    else
    begin
      q.Close;
      Result := gdcBaseManager.GetNextID;

      q.SQL.Text := 'INSERT INTO at_style_object(id, objtype, objname) VALUES (:id, :objtype, :objname)';

      q.ParamByName('id').AsInteger := Result;
      q.ParamByName('objtype').AsInteger := AnObjType;
      q.ParamByName('objname').AsString := AnObjName;
      q.ExecQuery;
    end;
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
  Assert(AStrValue > '');
  Assert(AnUserKey > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    q.SQL.Text :=
      'UPDATE OR INSERT INTO at_style (objectkey, propid, strvalue, userkey) ' +
      'VALUES (:objectkey, :propid, :strvalue, :userkey) ' +
      'matching (objectkey, propid, userkey)';
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
      'UPDATE OR INSERT INTO at_style (objectkey, propid, intvalue, userkey) ' +
      'VALUES (:objectkey, :propid, :intvalue, :userkey) ' +
      'matching (objectkey, propid, userkey)';
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
  Columns: TgsColumns;
  Expands: TColumnExpands;
  Conditions: TGridConditions;
  ExpandsActive: Boolean;
  ExpandsSeparate: Boolean;
  ScaleColumns: Boolean;
  ConditionsActive: Boolean;
  TitlesExpanding: Boolean;
  O: TDBGridOptions;
  ShowRowLines: Boolean;
  ShowTotals: Boolean;
  ShowFooter: Boolean;

  procedure SaveTableFont;
  var
    Name: String;
    Color: TColor;
    Height: Integer;
    Pitch: TFontPitch; {(fpDefault, fpVariable, fpFixed);}
    Size: Integer;
    Styles: TFontStyles;  {(fsBold, fsItalic, fsUnderline, fsStrikeOut);}
    CharSet: TFontCharset;
  begin
    R.ReadListBegin;

    try
      Name := R.ReadString;
      if (Name <> cDefTableFontName) and (Name > '') then
        SaveStrValue(ObjectKey, cTableFontName, Name, AnUserKey);

      Color := StringToColor(R.ReadString);
      if Color <> cDefTableFontColor then
        SaveStrValue(ObjectKey, cTableFontColor, ColorToString(Color), AnUserKey);

      Height := R.ReadInteger;
      if Height <> cDefTableFontHeight then
        SaveIntValue(ObjectKey, cTableFontHeight, Height, AnUserKey);

      R.Read(Pitch, SizeOf(TFontPitch));
      if Pitch <> cDefTableFontPitch then
      begin
        if Pitch = fpVariable then
          SaveStrValue(ObjectKey, cTableFontPitch, 'fpVariable', AnUserKey)
        else
          SaveStrValue(ObjectKey, cTableFontPitch, 'fpFixed', AnUserKey);
      end;

      Size := R.ReadInteger;
      if Size <> 8 then
        SaveIntValue(ObjectKey, cTableFontSize, Size, AnUserKey);

      R.Read(Styles, SizeOf(TFontStyles));
      if Styles <> cDefTableFontStyles then
      begin
        if fsBold in Styles then
          SaveStrValue(ObjectKey, cTableFontStyle, 'fsBold', AnUserKey);
        if fsItalic in Styles then
          SaveStrValue(ObjectKey, cTableFontStyle, 'fsItalic', AnUserKey);
        if fsUnderline in Styles then
          SaveStrValue(ObjectKey, cTableFontStyle, 'fsUnderline', AnUserKey);
        if fsStrikeOut in Styles then
          SaveStrValue(ObjectKey, cTableFontStyle, 'fsStrikeOut', AnUserKey);
      end;

      CharSet := R.ReadInteger;
      if CharSet <> cDefTableFontCharSet then
        SaveIntValue(ObjectKey, cTableFontCharSet, CharSet, AnUserKey);

      R.ReadListEnd;
    except
      R.ReadListEnd;
    end;
  end;

  ///////////////////////////////////////////////////////////////////////////////

  procedure SaveSelectedFont;
  var
    Name: String;
    Color: TColor;
    Height: Integer;
    Pitch: TFontPitch;
    Size: Integer;
    Styles: TFontStyles;
    CharSet: TFontCharset;
  begin
    R.ReadListBegin;

    try
      Name := R.ReadString;
      if (Name <> cDefSelectedFontName) and (Name > '') then
        SaveStrValue(ObjectKey, cSelectedFontName, Name, AnUserKey);

      Color := StringToColor(R.ReadString);
      if Color <> cDefSelectedFontColor then
        SaveStrValue(ObjectKey, cSelectedFontColor, ColorToString(Color), AnUserKey);

      Height := R.ReadInteger;
      if Height <> cDefSelectedFontHeight then
        SaveIntValue(ObjectKey, cSelectedFontHeight, Height, AnUserKey);

      R.Read(Pitch, SizeOf(TFontPitch));
      if Pitch <> cDefSelectedFontPitch then
      begin
        if Pitch = fpVariable then
          SaveStrValue(ObjectKey, cSelectedFontPitch, 'fpVariable', AnUserKey)
        else
          SaveStrValue(ObjectKey, cSelectedFontPitch, 'fpFixed', AnUserKey);
      end;

      Size := R.ReadInteger;
      if Size <> 8 then
        SaveIntValue(ObjectKey, cSelectedFontSize, Size, AnUserKey);

      R.Read(Styles, SizeOf(TFontStyles));
      if Styles <> cDefSelectedFontStyles then
      begin
        if fsBold in Styles then
          SaveStrValue(ObjectKey, cSelectedFontStyle, 'fsBold', AnUserKey);
        if fsItalic in Styles then
          SaveStrValue(ObjectKey, cSelectedFontStyle, 'fsItalic', AnUserKey);
        if fsUnderline in Styles then
          SaveStrValue(ObjectKey, cSelectedFontStyle, 'fsUnderline', AnUserKey);
        if fsStrikeOut in Styles then
          SaveStrValue(ObjectKey, cSelectedFontStyle, 'fsStrikeOut', AnUserKey);
      end;

      CharSet := R.ReadInteger;
      if CharSet <> cDefSelectedFontCharSet then
        SaveIntValue(ObjectKey, cSelectedFontCharSet, CharSet, AnUserKey);

      R.ReadListEnd;
    except
      R.ReadListEnd;
    end;
  end;

  ////////////////////////////////////////////////////////////////////////////////

  procedure SaveTitleFont;
  var
    Name: String;
    Color: TColor;
    Height: Integer;
    Pitch: TFontPitch; {(fpDefault, fpVariable, fpFixed);}
    Size: Integer;
    Styles: TFontStyles;  {(fsBold, fsItalic, fsUnderline, fsStrikeOut);}
    CharSet: TFontCharset;
  begin
    R.ReadListBegin;

    try
      Name := R.ReadString;
      if (Name <> cDefTitleFontName) and (Name > '') then
        SaveStrValue(ObjectKey, cTitleFontName, Name, AnUserKey);

      Color := StringToColor(R.ReadString);
      if Color <> cDefTitleFontColor then
        SaveStrValue(ObjectKey, cTitleFontColor, ColorToString(Color), AnUserKey);

      Height := R.ReadInteger;
      if Height <> cDefTitleFontHeight then
        SaveIntValue(ObjectKey, cTitleFontHeight, Height, AnUserKey);

      R.Read(Pitch, SizeOf(TFontPitch));
      if Pitch <> cDefTitleFontPitch then
      begin
        if Pitch = fpVariable then
          SaveStrValue(ObjectKey, cTitleFontPitch, 'fpVariable', AnUserKey)
        else
          SaveStrValue(ObjectKey, cTitleFontPitch, 'fpFixed', AnUserKey);
      end;

      Size := R.ReadInteger;
      if Size <> 8 then
        SaveIntValue(ObjectKey, cTitleFontSize, Size, AnUserKey);

      R.Read(Styles, SizeOf(TFontStyles));
      if Styles <> cDefTitleFontStyles then
      begin
        if fsBold in Styles then
          SaveStrValue(ObjectKey, cTitleFontStyle, 'fsBold', AnUserKey);
        if fsItalic in Styles then
          SaveStrValue(ObjectKey, cTitleFontStyle, 'fsItalic', AnUserKey);
        if fsUnderline in Styles then
          SaveStrValue(ObjectKey, cTitleFontStyle, 'fsUnderline', AnUserKey);
        if fsStrikeOut in Styles then
          SaveStrValue(ObjectKey, cTitleFontStyle, 'fsStrikeOut', AnUserKey);
      end;

      CharSet := R.ReadInteger;
      if CharSet <> cDefTitleFontCharSet then
        SaveIntValue(ObjectKey, cTitleFontCharSet, CharSet, AnUserKey);

      R.ReadListEnd;
    except
      R.ReadListEnd;
    end;
  end;

  procedure SaveExpands;
  var
    OK: Integer;
    I: Integer;
  begin
    Assert(Expands <> nil);
    //objname записываем так (форма, грид, Expand(DisplayField, FieldName))
    //DisplayField - имя поля в котором отображается
    //И все равно так не уникально, в программе в расширенное отображение можно добавить одно и то же поле несколько раз, но возможно это ошибка!!! сомнительный функционал

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

        if Expands[I].Options <> cDefExpandOptions then
        begin
          if ceoAddField in Expands[I].Options then
            SaveStrValue(OK, cExpandOption, 'ceoAddField', AnUserKey);

          if ceoAddFieldMultiline in Expands[I].Options then
            SaveStrValue(OK, cExpandOption, 'ceoAddFieldMultiline', AnUserKey);

          if ceoMultiline in Expands[I].Options then
            SaveStrValue(OK, cExpandOption, 'ceoMultiline', AnUserKey);
        end;
      end;
    end;
  end;

  procedure SaveConditions;
  var
    I: Integer;
    OK: Integer;
  begin
    Assert(Conditions <> nil);

    for I := 0 to Conditions.Count - 1 do
    begin
      //ConditionName не уникально, так что с этим надо что то придумать, возможно генерировать
      if Conditions[I].ConditionName = '' then
         Conditions[I].ConditionName := 'cn_' + IntToStr(Random(100000) + 1000000);
      Assert(Conditions[I].ConditionName > '');
      OK := GetObjID(cCondition, AnObjectName + ',' + 'Condition(' + Conditions[I].ConditionName +')');

      SaveStrValue(OK, cConditionName, Conditions[I].ConditionName, AnUserKey);

      //DisplayFields Странное конечно условие
      if (Length(Conditions[I].DisplayFields) <= 60) and (Conditions[I].DisplayFields > '') then
      SaveStrValue(OK, cConditionDisplayFields, Conditions[I].DisplayFields, AnUserKey);

      //FieldName
      if Conditions[I].FieldName <> cDefConditionFieldName then
        SaveStrValue(OK, cConditionFieldName, Conditions[I].FieldName, AnUserKey);

      //Font//////////////////////////////////////////////////////////////////////

      if Conditions[I].Font.Name <> cDefConditionFontName then
        SaveStrValue(OK, cConditionFontName, Conditions[I].Font.Name, AnUserKey);

      if Conditions[I].Font.Color <> cDefConditionFontColor then
        SaveStrValue(OK, cConditionFontColor, ColorToString(Conditions[I].Font.Color), AnUserKey);

      if Conditions[I].Font.Height <> cDefConditionFontHeight then
        SaveIntValue(OK, cConditionFontHeight, Conditions[I].Font.Height, AnUserKey);

      if Conditions[I].Font.Pitch <> cDefConditionFontPitch then
      begin
        if Conditions[I].Font.Pitch = fpVariable then
          SaveStrValue(OK, cConditionFontPitch, 'fpVariable', AnUserKey)
        else
          SaveStrValue(OK, cConditionFontPitch, 'fpFixed', AnUserKey);
      end;

      if Conditions[I].Font.Size <> cDefConditionFontSize then
        SaveIntValue(OK, cConditionFontSize, Conditions[I].Font.Size, AnUserKey);


      if Conditions[I].Font.Style <> cDefConditionFontStyles then
      begin
        if fsBold in Conditions[I].Font.Style then
          SaveStrValue(OK, cConditionFontStyle, 'fsBold', AnUserKey);
        if fsItalic in Conditions[I].Font.Style then
          SaveStrValue(OK, cConditionFontStyle, 'fsItalic', AnUserKey);
        if fsUnderline in Conditions[I].Font.Style then
          SaveStrValue(OK, cConditionFontStyle, 'fsUnderline', AnUserKey);
        if fsStrikeOut in Conditions[I].Font.Style then
          SaveStrValue(OK, cConditionFontStyle, 'fsStrikeOut', AnUserKey);
      end;

      if Conditions[I].Font.CharSet <> cDefConditionFontCharSet then
        SaveIntValue(OK, cConditionFontCharSet, Conditions[I].Font.CharSet, AnUserKey);

      //Color
      if Conditions[I].Color <> cDefConditionColor then
        SaveStrValue(OK, cConditionColor, ColorToString(Conditions[I].Color), AnUserKey);
      // тут тоже не факт что будет меньше 60-ти
      if Conditions[I].Expression1 > cDefConditionExpression1 then
        SaveStrValue(OK, cConditionExpression1, Conditions[I].Expression1, AnUserKey);

      if Conditions[I].Expression2 > cDefConditionExpression2 then
        SaveStrValue(OK, cConditionExpression2, Conditions[I].Expression2, AnUserKey);

      if Conditions[I].ConditionKind <> cDefConditionKind then
      begin
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
        else
          Assert(False);
      end;

      if Conditions[I].DisplayOptions <> cDefConditionDisplayOptions then
      begin
        if doColor in Conditions[I].DisplayOptions then
          SaveStrValue(OK, cConditionDisplayOption, 'doColor', AnUserKey);
        if doFont in Conditions[I].DisplayOptions then
          SaveStrValue(OK, cConditionDisplayOption, 'doFont', AnUserKey);
      end;

      if Conditions[I].EvaluateFormula <> cDefConditionEvaluateFormula then
        SaveBoolValue(OK, cConditionEvaluateFormula, Conditions[I].EvaluateFormula, AnUserKey);

      if Conditions[I].UserCondition <> cDefConditionUserCondition then
        SaveBoolValue(OK, cConditionUserCondition, Conditions[I].UserCondition, AnUserKey);

      // Вот с этим пока не знаю что делать!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      //Conditions[I].OnUserCondition
    end;
  end;

  procedure SaveColumns;
  var
    TotalSum: Boolean;
    I: Integer;
    OK: Integer;
    TitleCaption: String;
  begin
    Assert(Columns <> nil);

    for I := 0 to Columns.Count - 1 do
    begin
      if Columns[I].FieldName > '' then
      begin
        Assert(Columns[I].FieldName > '');
        OK := GetObjID(cColumn, AnObjectName + ',' + 'Column(' + Columns[I].FieldName +')');

        // Заглавие колонки
        TitleCaption := Columns[I].Title.Caption;
        // Обрезаем
        if Length(TitleCaption) > 60 then
          SetLength(TitleCaption, 60);

        if TitleCaption <> cDefColumnTitleCaption then
          SaveStrValue(OK, cColumnTitleCaption, TitleCaption, AnUserKey);

        // Формат
        if Columns[I].DisplayFormat <> cDefColumnDisplayFormat then
          SaveStrValue(OK, cColumnDisplayFormat, Columns[I].DisplayFormat, AnUserKey);

        // колонка отображается
        if Columns[I].Visible <> cDefColumnVisible then
          SaveBoolValue(OK, cColumnVisible, Columns[I].Visible, AnUserKey);

        // только чтение
        if Columns[I].ReadOnly <> cDefColumnReadOnly then
          SaveBoolValue(OK, cColumnReadOnly, Columns[I].ReadOnly, AnUserKey);

        // подсчитывать итоговое значение
        TotalSum := Columns[I].TotalType = ttSum;
        if TotalSum <> cDefColumnTotalSum then
          SaveBoolValue(OK, cColumnTotalSum, TotalSum, AnUserKey);

        // ширина колонки
        if Columns[I].Width <> cDefColumnWidth then
          SaveIntValue(OK, cColumnWidth, Columns[I].Width, AnUserKey);

        // шрифт заголовка
        if Columns[I].Title.Font.Name <> cDefColumnTitleFontName then
          SaveStrValue(OK, cColumnTitleFontName, Columns[I].Title.Font.Name, AnUserKey);

        if Columns[I].Title.Font.Color <> cDefColumnTitleFontColor then
          SaveStrValue(OK, cColumnTitleFontColor, ColorToString(Columns[I].Title.Font.Color), AnUserKey);

        if Columns[I].Title.Font.Height <> cDefColumnTitleFontHeight then
          SaveIntValue(OK, cColumnTitleFontHeight, Columns[I].Title.Font.Height, AnUserKey);

        if Columns[I].Title.Font.Pitch <> cDefColumnTitleFontPitch then
        begin
          if Columns[I].Title.Font.Pitch = fpVariable then
            SaveStrValue(OK, cColumnTitleFontPitch, 'fpVariable', AnUserKey)
          else
            SaveStrValue(OK, cColumnTitleFontPitch, 'fpFixed', AnUserKey);
        end;

        if Columns[I].Title.Font.Size <> cDefColumnTitleFontSize then
          SaveIntValue(OK, cColumnTitleFontSize, Columns[I].Title.Font.Size, AnUserKey);

        if Columns[I].Title.Font.Style <> cDefColumnTitleFontStyles then
        begin
          if fsBold in Columns[I].Title.Font.Style then
            SaveStrValue(OK, cColumnTitleFontStyle, 'fsBold', AnUserKey);
          if fsItalic in Columns[I].Title.Font.Style then
            SaveStrValue(OK, cColumnTitleFontStyle, 'fsItalic', AnUserKey);
          if fsUnderline in Columns[I].Title.Font.Style then
            SaveStrValue(OK, cColumnTitleFontStyle, 'fsUnderline', AnUserKey);
          if fsStrikeOut in Columns[I].Title.Font.Style then
            SaveStrValue(OK, cColumnTitleFontStyle, 'fsStrikeOut', AnUserKey);
        end;

        if Columns[I].Title.Font.CharSet <> cDefColumnTitleFontCharSet then
          SaveIntValue(OK, cColumnTitleFontCharSet, Columns[I].Title.Font.CharSet, AnUserKey);

        // Цвет заголовка
        if Columns[I].Title.Color <> cDefColumnTitleColor then
          SaveStrValue(OK, cColumnTitleColor, ColorToString(Columns[I].Title.Color), AnUserKey);

        // шрифт колонки
        if Columns[I].Font.Name <> cDefColumnFontName then
          SaveStrValue(OK, cColumnFontName, Columns[I].Font.Name, AnUserKey);

        if Columns[I].Font.Color <> cDefColumnFontColor then
          SaveStrValue(OK, cColumnFontColor, ColorToString(Columns[I].Font.Color), AnUserKey);

        if Columns[I].Font.Height <> cDefColumnFontHeight then
          SaveIntValue(OK, cColumnFontHeight, Columns[I].Font.Height, AnUserKey);

        if Columns[I].Font.Pitch <> cDefColumnFontPitch then
        begin
          if Columns[I].Font.Pitch = fpVariable then
            SaveStrValue(OK, cColumnFontPitch, 'fpVariable', AnUserKey)
          else
            SaveStrValue(OK, cColumnFontPitch, 'fpFixed', AnUserKey);
        end;

        if Columns[I].Font.Size <> cDefColumnFontSize then
          SaveIntValue(OK, cColumnFontSize, Columns[I].Font.Size, AnUserKey);

        if Columns[I].Font.Style <> cDefColumnFontStyles then
        begin
          if fsBold in Columns[I].Font.Style then
            SaveStrValue(OK, cColumnFontStyle, 'fsBold', AnUserKey);
          if fsItalic in Columns[I].Font.Style then
            SaveStrValue(OK, cColumnFontStyle, 'fsItalic', AnUserKey);
          if fsUnderline in Columns[I].Font.Style then
            SaveStrValue(OK, cColumnFontStyle, 'fsUnderline', AnUserKey);
          if fsStrikeOut in Columns[I].Font.Style then
            SaveStrValue(OK, cColumnFontStyle, 'fsStrikeOut', AnUserKey);
        end;

        if Columns[I].Font.CharSet <> cDefColumnFontCharSet then
          SaveIntValue(OK, cColumnFontCharSet, Columns[I].Font.CharSet, AnUserKey);

        // цвет колонки
        if Columns[I].Color <> cDefColumnColor then
          SaveStrValue(OK, cColumnColor, ColorToString(Columns[I].Color), AnUserKey);

        // Выравнивание в заголовке
        if Columns[I].Title.Alignment <> cDefColumnTitleAlignment then
        begin
          if Columns[I].Title.Alignment = taRightJustify then
            SaveStrValue(OK, cColumnTitleAlignment, 'taRightJustify', AnUserKey)
          else
            SaveStrValue(OK, cColumnTitleAlignment, 'taCenter', AnUserKey);
        end;

        // Выравнивание в колонке
        if Columns[I].Alignment <> cDefColumnAlignment then
        begin
          if Columns[I].Alignment = taRightJustify then
            SaveStrValue(OK, cColumnAlignment, 'taRightJustify', AnUserKey)
          else
            SaveStrValue(OK, cColumnAlignment, 'taCenter', AnUserKey)
        end;
      end;

    end;
  end;

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

      SaveTableFont;

      Color := StringToColor(R.ReadString);
      if Color <> cDefTableColor then
        SaveStrValue(ObjectKey, cTableColor, ColorToString(Color), AnUserKey);

      SaveSelectedFont;

      Color := StringToColor(R.ReadString);
      if Color <> cDefSelectedColor then
        SaveStrValue(ObjectKey, cSelectedColor, ColorToString(Color), AnUserKey);

      SaveTitleFont;

      Color := StringToColor(R.ReadString);
      if Color <> cDefTitleColor then
        SaveStrValue(ObjectKey, cTitleColor, ColorToString(Color), AnUserKey);

      Striped := R.ReadBoolean;
      if Striped <> cDefStriped then
        SaveBoolValue(ObjectKey, cStriped, Striped, AnUserKey);

      StripeOdd := StringToColor(R.ReadString);
      if StripeOdd <> cDefStripeOdd then
        SaveStrValue(ObjectKey, cStripeOdd, ColorToString(StripeOdd), AnUserKey);

      StripeEven := StringToColor(R.ReadString);
      if StripeOdd <> cDefStripeEven then
        SaveStrValue(ObjectKey, cStripeEven, ColorToString(StripeEven), AnUserKey);

      if R.ReadValue = vaCollection then
      begin
        Expands := TColumnExpands.Create(nil);
        try
        R.ReadCollection(Expands);
        SaveExpands;
        finally
          Expands.Free;
        end;
      end;

      ExpandsActive := R.ReadBoolean;
      if ExpandsActive <> cDefExpandsActive then
        SaveBoolValue(ObjectKey, cExpandsActive, ExpandsActive, AnUserKey);

      ExpandsSeparate := R.ReadBoolean;
      if ExpandsSeparate <> cDefExpandsSeparate then
        SaveBoolValue(ObjectKey, cExpandsSeparate, ExpandsActive, AnUserKey);

      if R.ReadValue = vaCollection then
      begin
        Conditions := TGridConditions.Create(nil);
        try
          R.ReadCollection(Conditions);
          SaveConditions;
        finally
          Conditions.Free;
        end;
      end;

      ConditionsActive := R.ReadBoolean;
      if ConditionsActive <> cDefConditionsActive then
        SaveBoolValue(ObjectKey, cConditionsActive, ConditionsActive, AnUserKey);

      if R.ReadValue = vaCollection then
      begin
        Columns := TgsColumns.Create(nil, TgsColumn, False);
        try
          R.ReadCollection(Columns);
          SaveColumns;
        finally
          Columns.Free;
        end;
      end;

      ScaleColumns := R.ReadBoolean;
      if ScaleColumns <> cDefScaleColumns then
        SaveBoolValue(ObjectKey, cScaleColumns, ScaleColumns, AnUserKey);


      if (Version = 'GRID_STREAM_2') then
      begin
        TitlesExpanding := R.ReadBoolean;
        if TitlesExpanding <> cDefTitlesExpanding then
          SaveBoolValue(ObjectKey, cTitlesExpanding, TitlesExpanding, AnUserKey);
      end
      else if (Version = 'GRID_STREAM_3') or (Version = 'GRID_STREAM_4') then
      begin
        TitlesExpanding := R.ReadBoolean;
        if TitlesExpanding <> cDefTitlesExpanding then
          SaveBoolValue(ObjectKey, cTitlesExpanding, TitlesExpanding, AnUserKey);

        R.Read(O, SizeOf(TDBGridOptions));
        ShowRowLines := dgRowLines in O;

        if ShowRowLines <> cDefShowRowLines then
          SaveBoolValue(ObjectKey, cShowRowLines, True, AnUserKey);
      end;

      if (Version = 'GRID_STREAM_4') then
      begin
        ShowTotals := R.ReadBoolean;
        if ShowTotals <> cDefShowTotals then
          SaveBoolValue(ObjectKey, cShowTotals, ShowTotals, AnUserKey);

        ShowFooter := R.ReadBoolean;
        if ShowFooter <> cDefShowFooter then
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
  S: TMemoryStream;
  T: String;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTransaction;
    // Запрос явно не правильный!!! Надо переделать!!!!!!!
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  gsd.name, '#13#10 +
      '  gsd2.name as pname, '#13#10 +
      '  gsd3.blob_data, '#13#10 +
      '  gsd4.int_data as userkey '#13#10 +
      '   '#13#10 +
      'FROM gd_storage_data gsd '#13#10 +
      'LEFT JOIN gd_storage_data gsd2 '#13#10 +
      '  ON gsd.parent = gsd2.id '#13#10 +
      'LEFT JOIN gd_storage_data gsd3 '#13#10 +
      '  ON gsd.id = gsd3.parent '#13#10 +
      '   '#13#10 +
      'LEFT JOIN gd_storage_data gsd4 '#13#10 +
      '  ON gsd4.id = gsd2.parent '#13#10 +
      ' '#13#10 +
      'WHERE gsd.name LIKE ''%(TgsIBGrid)%'' AND gsd3.name = ''data''';
    q.ExecQuery;
    while not q.EoF do
    begin
      if q.FieldByName('userkey').AsInteger > 0 then
        begin
        S := TMemoryStream.Create;
        try
          S.Size := 0;
          T := q.FieldByName('blob_data').AsString;

          if Length(T) > 0 then
          begin
            S.WriteBuffer(T[1], Length(T));
            S.Position := 0;
            ParseGridStream(q.FieldByName('pname').AsString + ',' + q.FieldByName('name').AsString, q.FieldByName('userkey').AsInteger, S);
          end;
        finally
          S.Free;
        end;
      end;
      q.Next;
    end;
  finally
    q.Free
  end;
end;

initialization

finalization
  FreeAndNil(_gdStyleManager);

end.
