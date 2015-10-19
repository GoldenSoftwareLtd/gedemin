(*//Учитываем кодовую страницу в файле данных, по умолчанию OEM
CodePage: {ANSI| OEM}

//Указывает на то, удалять концевые пробелы или нет, по умолчанию Yes
TrimRight: {Yes|No}

// Указывает на то, удалять начальные пробелы или нет, по умолчанию No
TrimLeft: {Yes|No}

//Учитывать или не учитывать регистр при поиске маркеров, по умолчанию Yes
CaseSensitive: {Yes|No}

// Системные символы
// BOF -- пачатак файлу
// EOF -- канец файлу
// EOL -- канец радка
// BOL -- пачатак радка
// EL  -- пусты радок

// Синтаксис файла
  File           = BEGINFILE :<Chars> [[<Area>][<Area>]...] ENDFILE :<Chars>.
//  Chars          = { <System_Symbol> | <Literal_String> }
//   System_Symbol  = { BOF | EOF | EOL | BOL | EL }
//   Literal_String = "any chars"
   Area           = BEGINAREA
                      :<Chars>
                      Name: <Literal_String>
                      [[<AreaItem>][<AreaItem>]...]
                    ENDAREA :<Chars>
   AreaItem       = { <Field> | <Table> }
   Marker         = BEGINMARKER
                       [[TEXT: <Literal_String>]
                       [WHOLEWORD: {Yes|No}]]
                       [ [SKIPCHARS: {EL|Literal_String}] |
                         [SKIPUNTILCHARS: <Chars>] |
                         [SKIPNEXTCHARS: int N]]
                    ENDMARKER
   Field          = BEGINFIELD
                      NAME: <Literal_String>
                      SIZE: int Size
                      [MARKER: {Marker}]
                      [POSX: int X]
                      [POSY: int Y]
                      [NODATA: int]
                      [TERMINATOR: " Literal_String "]
                      [TRIMCHARS: " Literal_String "]
                      [LEGALCHARS: "chars"]
                      [ALIGNMENT: <Alignment>]
                      [HEIGHT: int]
                     ENDFIELD
 UserField     = BEGINUSERFIELD
                      NAME: <Literal_String>
                      SIZE: int Size
                     ENDUSERFIELD
   Alignment      = { LEFT | RIGHT }
   Table          = BEGINTABLE
                      [:<Chars>]
                      NAME: <Literal_String>
                      [Marker]
                      [[NECESSARILY: int] | [RECORDLABEL] | [ENDRECORD: <Chars> ]]
                      [[Field][Field]...]
                    ENDTABLE [:<Chars>]
// Комментарии в шаблоне указываются символом "//"  *)

unit gsTextTemplate_unit;
interface
uses
  Classes, dbclient, SysUtils, db, Dialogs, contnrs, gsTextDatabase_unit,
  ComServ, ComObj, Gedemin_TLB;

type
  TMarkerClause = (mcBeginMarker, mcText, mcWholeWord, mcSkipChars, mcSkipUntilChars, mcSkipNextChars, mcEndMarker);
  TFieldClause = (fcBeginField, fcName, fcSize, fcPosX, fcPosY, fcTerminator,
                  fcTrimChars, fcLegalChars, fcAlignment, fcNoData, fcHeight,
                  fcEndField, fcBeginMarker);
  TUserFieldClause = (ufcBeginField, ufcName, ufcSize, ufcEndField);
  TTableClause = (tcBeginTable, tcName, tcNecessarily, tcEndTable, tcRecordEnd,
    tcBeginLabel, tcBeginMarker, tcBeginField, tcBeginUserField);
  TAreaClause = (acBeginArea, acName, acEndArea);
  TFileClause = (dcBeginFile, dcCodePage, dcTrimRight, dcTrimLeft,dcCaseSensitive, dcEndFile);
  TRecordLabelClause = (rlBeginLabel, rlPosX, rlMask, rlEndLabel);

const
  MarkerClauseText: array[TMarkerClause] of String = (
    'BEGINMARKER',
    'TEXT',
    'WHOLEWORD',
    'SKIPCHARS',
    'SKIPUNTILCHARS',
    'SKIPNEXTCHARS',
    'ENDMARKER');

  FieldClauseText: array[TFieldClause] of String = (
    'BEGINFIELD',
    'NAME',
    'SIZE',
    'POSX',
    'POSY',
    'TERMINATOR',
    'TRIMCHARS',
    'LEGALCHARS',
    'ALIGNMENT',
    'NODATA',
    'HEIGHT',
    'ENDFIELD',
    'BEGINMARKER');

  UserFieldClauseText: array[TUserFieldClause] of String = (
    'BEGINUSERFIELD',
    'NAME',
    'SIZE',
    'ENDUSERFIELD');

  TableClauseText: array[TTableClause] of String = (
    'BEGINTABLE',
    'NAME',
    'NECESSARILY',
    'ENDTABLE',
    'ENDRECORD',
    'BEGINLABEL',
    'BEGINMARKER',
    'BEGINFIELD',
    'BEGINUSERFIELD');

  AreaClauseText: array[TAreaClause] of String = (
    'BEGINAREA',
    'NAME',
    'ENDAREA');

  FileClauseText: array[TFileClause] of String = (
    'BEGINFILE',
    'CODEPAGE',
    'TRIMRIGHT',
    'TRIMLEFT',
    'CASESENSITIVE',
    'ENDFILE');

  RecordLabelClauseText: array[TRecordLabelClause] of String = (
    'BEGINLABEL',
    'POSX',
    'MASK',
    'ENDLABEL');

type
  TSystemSymbol = (ssBOF, ssEOF, ssEOL, ssBOL, ssEL);
  TKeyWordSet = (
    kwYes, kwNo, kwOem, kwAnsi, kwRight, kwLeft,
    kwComent, kwCommas, kwColon);

const
  SystemSymbol: array[TSystemSymbol] of String = ('BOF', 'EOF', 'EOL', 'BOL', 'EL');
  KeyWordSet: array[TKeyWordSet] of String = ('YES', 'NO', 'OEM', 'ANSI', 'RIGHT',
                                              'LEFT', '//', '"', ':');

type
  TChars = Record
    case System: Boolean of
      True: (Symbol: TSystemSymbol);
      False: (Text: String[255]);
  end;


  TFieldAlignment = (aLeft, aRight);

  TCodePage = (cpOEM, cpANSI);


TgsTextTemplateMarker = class(TObject)
private
  FMarkerText: TChars;
  FSkipChars: TChars;
  FSkipUntilChars: TChars;
  FSkipNextChars: Integer;
  FWholeWord: boolean;

public
  constructor Create;

  property MarkerText: TChars read FMarkerText write FMarkerText;
  property SkipChars: TChars read FSkipChars write FSkipChars;
  property SkipUntilChars: TChars read FSkipUntilChars write FSkipUntilChars;
  property SkipNextChars: Integer read FSkipNextChars write FSkipNextChars;
  property WholeWord: boolean read FWholeWord write FWholeWord;
end;

TgsTextTemplateField = class (TObject)
private
  FName: TChars;
  FMarker: TgsTextTemplateMarker;
  FSize: Integer;
  FPosX: Integer;
  FPosY: Integer;
  FTerminator: TChars;
  FTrimChars: TChars;
  FLegalChars: TChars;
  FAlignment: TFieldAlignment;
  FNoData: Integer;
  FHeight: Integer;

  procedure SetMarker(Const mrk: TgsTextTemplateMarker);

public
  constructor Create;
  destructor Destroy; override;

  property Name: TChars read FName write FName;
  property Marker: TgsTextTemplateMarker read FMarker write SetMarker;
  property Size: Integer read FSize write FSize;
  property PosX: Integer read FPosX write FPosX;
  property PosY: Integer read FPosY write FPosY;
  property Terminator: TChars read FTerminator write FTerminator;
  property TrimChars: TChars read FTrimChars write FTrimChars;
  property LegalChars: TChars read FLegalChars write FLegalChars;
  property Alignment: TFieldAlignment read FAlignment write FAlignment;//SetAlignFld;
  property NoData: Integer read FNoData write FNoData;
  property Height: Integer read FHeight write FHeight;
end;

TgsTextTemplateUserField = class (TObject)
private
  FName: TChars;
  FSize: Integer;

public
  property Name: TChars read FName write FName;
  property Size: Integer read FSize write FSize;
end;

TgsTextTemplateRecordLabel = class(TObject)
private
  FPosX: Integer;
  FMask: String;

public
  constructor Create;

  property PosX: Integer read FPosX write FPosX;
  property Mask: String read FMask write FMask;
end;

TgsTextTemplateTable = class (TObject)
private
  FBeginTable: TChars;
  FName: TChars;
  FMarker: TgsTextTemplateMarker;
  FNecessarily: Integer;
  FList: TObjectList;
  FUserList: TObjectList;
  FEndTable: TChars;
  FEndRecord: TChars;
  FRecordLabel: TgsTextTemplateRecordLabel;

  procedure SetMarker(mrk: TgsTextTemplateMarker);
  function GetFieldsCount: Integer;
  function GetField(const Index: Integer): TgsTextTemplateField;
  function GetUserFieldsCount: Integer;
  function GetUserField(const Index: Integer): TgsTextTemplateUserField;

  function CreateFields: TClientDataset;
  procedure SetNecessarily(const Value: Integer);
  procedure SetEndRecord(const Value: TChars);
  procedure SetRecordLabel(const Value: TgsTextTemplateRecordLabel);

protected
  function CreateTables: TgsTextDatabaseTable;

public
  constructor Create;
  destructor Destroy; override;

  property BeginTable: TChars read FBeginTable write FBeginTable;
  property Name: TChars read FName write FName;
  property Marker: TgsTextTemplateMarker read FMarker write SetMarker;
  property Necessarily: Integer read FNecessarily write SetNecessarily;
  property FieldsCount: Integer read GetFieldsCount;
  property FieldsList[Const Index: Integer]: TgsTextTemplateField read GetField;
  property UserFieldsCount: Integer read GetUserFieldsCount;
  property UserFieldsList[Const Index: Integer]: TgsTextTemplateUserField read GetUserField;
  property EndRecord: TChars read FEndRecord write SetEndRecord;
  property RecordLabel: TgsTextTemplateRecordLabel read FRecordLabel write SetRecordLabel;
  property EndTable: TChars read FEndTable write FEndTable;

  function AddField(Item: TgsTextTemplateField): Integer;
  procedure DeleteField(const Index: Integer);

  function AddUserField(Item: TgsTextTemplateUserField): Integer;
  procedure DeleteUserField(const Index: Integer);
end;

TgsTextTemplateArea = class (TObject)
private
  FBeginArea: TChars;
  FName: TChars;
  FFieldsList: TObjectList;
  FUserList: TObjectList;
  FTablesList: TObjectList;

  FEndArea: TChars;

  function GetField(const Index: Integer): TgsTextTemplateField;
  function GetFieldsCount: Integer;
  function GetTable(const Index: Integer): TgsTextTemplateTable;
  function GetTablesCount: Integer;
    function GetUserField(const Index: Integer): TgsTextTemplateUserField;
    function GetUserFieldsCount: Integer;

protected
  function CreateFields: TClientDataSet;
  function CreateAreas: TgsTextDatabaseArea;

public
  constructor Create;
  destructor Destroy; override;

  property BeginArea: TChars read FBeginArea write FBeginArea;
  property Name: TChars read FName write FName;
  property FieldsList[const Index: Integer]: TgsTextTemplateField read GetField;
  property FieldsCount: Integer read GetFieldsCount;
  property UserFieldsCount: Integer read GetUserFieldsCount;
  property UserFieldsList[Const Index: Integer]: TgsTextTemplateUserField read GetUserField;
  property TablesList[const Index: Integer]: TgsTextTemplateTable read GetTable;
  property TablesCount: Integer read GetTablesCount;
  property EndArea: TChars read FEndArea write FEndArea;

  function AddField(Item: TgsTextTemplateField): Integer;
  procedure DeleteField(Const Index: Integer);

  function AddUserField(Item: TgsTextTemplateUserField): Integer;
  procedure DeleteUserField(const Index: Integer);

  function AddTable(Item: TgsTextTemplateTable): Integer;
  procedure DeleteTable(Const Index: Integer);
end;

TgsTextTemplateFile = class (TObject)
private
  FBeginFile: TChars;
  FTrimRightString: boolean;
  FTrimLeftString: boolean;
  FCaseSensitive: boolean;
  FCodePage: TCodePage;
  FAreaList: TObjectList;
  FEndFile: TChars;

  function GetArea(I: Integer): TgsTextTemplateArea;
  function GetAreaCount: Integer;

public
  constructor Create;
  destructor Destroy; override;

  property BeginFile: TChars read FBeginFile write FBeginFile;
  property TrimRightString: boolean read FTrimRightString write FTrimRightString;
  property TrimLeftString: boolean read FTrimLeftString write FTrimLeftString;
  property CaseSensitive: boolean read FCaseSensitive write FCaseSensitive;
  property CodePage: TCodePage read FCodePage write FCodePage;
  property AreaCount: Integer read GetAreaCount;
  property AreaList[Index: Integer]: TgsTextTemplateArea read GetArea;
  property EndFile: TChars read FEndFile write FEndFile;

  function AddArea(Item: TgsTextTemplateArea): Integer;
  procedure DeleteArea(const I: Integer);

  procedure LoadFromTextFile(const AFileName: String; var ADatabase: TgsTextDatabase);

end;

TgsTextFile = class (TObject)
private
  FTrimRightString: boolean;
  FTrimLeftString: boolean;
  FCaseSensitive: boolean;
  FCodePage: TCodePage;
  FCurrentRow: Integer;
  FPosY: Integer;
  FRowHeight: Integer;

  FCurrentString: String;
  FCurrentPos: Integer;

protected
  Rows: TStringList;

  procedure PreviousString;

public
  constructor Create(TrimR, TrimL, CaseS: boolean; CodeP: TCodePage);
  destructor Destroy; override;

  property TrimRightString: boolean read FTrimRightString write FTrimRightString;
  property TrimLeftString: boolean read FTrimLeftString write FTrimLeftString;
  property CaseSensitive: boolean read FCaseSensitive write FCaseSensitive;
  property CodePage: TCodePage read FCodePage write FCodePage;
  property CurrentRow: Integer read FCurrentRow;
  property PosY: Integer read FPosY write FPosY;
  property RowHeight: Integer read FRowHeight write FRowHeight;

  procedure OpenFile(AFileName: String);

  function FindInString(Key: TChars): boolean;
  function FindInStringSet(Key: TChars): boolean;
  function FindWholeWord(Key: TChars; WholeW: boolean): boolean;
  function CompareStr(FirstSt: String; SecondSt: String): boolean;
  function NextString: Boolean;
  procedure NextRecord(Necess: Integer; EndRec: TChars; EndTable: TChars;
    RecordLabel: TgsTextTemplateRecordLabel);
  function FindRecordLabel(RecordLabel: TgsTextTemplateRecordLabel): Boolean;
  function GetFieldValue(Fld: TgsTextTemplateField; Necess: Integer;
    EndRecord: TChars; EndTable: TChars;
    RecordLabel: TgsTextTemplateRecordLabel): String;
  function SetPosInFile (Mrk: TgsTextTemplateMarker; LimitSymbol: TChars): boolean;

end;

TgsTempFile = class(TObject)
private
  FCurrentRow: Integer;

  FTemplateFile: TStringList;
  FCurentString: String;
  FKeyWordList: TStringList;
  FSystemList: TStringList;

  procedure DeleteUnnecessary;

public
  constructor Create;
  destructor Destroy; override;

  property CurrentRow: Integer read FCurrentRow;

  procedure OpenFile(AFileName: String); overload;
  procedure OpenFile(S: TStream); overload;

  function NextString: boolean;
  function FindKeyWord(Key: String): boolean;
  function GetKeyWord: String;
  function Means: TChars;
end;

TgsTextConverter = class(TAutoObject, IgsTextConverter)
private
  FDatabase: TgsTextDatabase;

  TempFile: TgsTempFile;

  FileTm: TgsTextTemplateFile;

  MarkerAttrList: TStringList;
  FieldAttrList: TStringList;
  UserFieldAttrList: TStringList;
  FileAttrList: TStringList;
  TableAttrList: TStringList;
  RecordLblAttrList: TStringList;

  function GetMarker: TgsTextTemplateMarker;
  function GetFields: TgsTextTemplateField;
  function GetUserFields: TgsTextTemplateUserField;
  function GetTables: TgsTextTemplateTable;
  function GetAreas: TgsTextTemplateArea;
  function GetDatabase: TgsTextDatabase;
  function GetRecordLabel: TgsTextTemplateRecordLabel;

protected
  function  Get_Database: IgsTextDatabase; safecall;

public
  constructor Create;
  destructor Destroy; override;

  //Загружает шаблон из потока
  procedure LoadTemplateFromStream(S: TStream); overload;
  procedure LoadTemplateFromStream(const S: IgsStream); overload; safecall;
  //ATempName - имя файла-шаблона
  procedure LoadFromTempFile(const ATempName: WideString); safecall;
  //ATextName - имя файла-выписки
  procedure StartConvert (const ATextName: WideString); safecall;

  property Database: TgsTextDatabase read GetDatabase;
end;

implementation

uses
  windows,
  prp_methods
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
  DataFile: TgsTextFile;
  EofText: TChars;
  cstEndFile: TChars;
  EmptyChars: TChars;

function TCharsToString(Value: TChars): String;
begin
  if Value.System then
    Case Value.Symbol of
    ssBOF: Result := 'BOF';
    ssEOF: Result := 'EOF';
    ssEOL: Result := 'EOL';
    ssBOL: Result := 'BOL';
    ssEL: Result := 'EL';
    End
  else
    Result := Value.Text;
end;


{TgsTextTemplateMarker}

constructor TgsTextTemplateMarker.Create;
begin
  FMarkerText.System := false;
  FMarkerText.Text := '';
  FSkipChars.System := false;
  FSkipChars.Text := '';
  FSkipUntilChars.System := false;
  FSkipUntilChars.Text := '';
  FSkipNextChars := 0;
  FWholeWord := false;
end;

{TgsTextTemplateField}

constructor TgsTextTemplateField.Create;
begin
  FTerminator.System := false;
  FTerminator.Text := '';
  FTrimChars.System := false;
  FTrimChars.Text := '';
  FAlignment := aLeft;
  FPosX := 0;
  FPosY := 1;
  FLegalChars.System := false;
  FLegalChars.Text := '';
  FNoData := 0;
  FHeight := 1;
end;

destructor TgsTextTemplateField.Destroy;
begin
  FMarker.Free;
  inherited;
end;

procedure TgsTextTemplateField.SetMarker(Const mrk: TgsTextTemplateMarker);
begin
  if FMarker = nil then
  begin
    if FMarker <> mrk then FMarker := mrk
  end else
    raise Exception.Create('Для поля может быть указан только один маркер!');
end;

{ TgsTextTemplateTable }

constructor TgsTextTemplateTable.Create;
begin
  inherited;
  FList := TObjectList.Create;
  FUserList := TObjectList.Create;
  FNecessarily := 0;
  FRecordLabel := nil;
  FEndRecord.System := False;
  FEndRecord.Text := '';
end;

destructor TgsTextTemplateTable.Destroy;
begin
  FList.Free;
  FUserList.Free;
  FMarker.Free;
  inherited;
end;

function TgsTextTemplateTable.AddField(Item: TgsTextTemplateField): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  FList.Add(Item);
end;

procedure TgsTextTemplateTable.DeleteField(Const Index: Integer);
begin
  FList.Delete(Index);
end;

function TgsTextTemplateTable.AddUserField(Item: TgsTextTemplateUserField): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  FUserList.Add(Item);
end;

procedure TgsTextTemplateTable.DeleteUserField(Const Index: Integer);
begin
  FUserList.Delete(Index);
end;

function TgsTextTemplateTable.CreateTables: TgsTextDatabaseTable;
var
  FTableText: TgsTextDatabaseTable;
begin
  FTableText := TgsTextDatabaseTable.Create;
  FTableText.Name := Name.Text;
  if DataFile.SetPosInFile (FMarker, EmptyChars) then
  begin
    FTableText.FillFields(CreateFields);
    Result := FTableText;
  end
  else
  begin
    FTableText.Free;
    Result := nil;
  end;
end;

procedure TgsTextTemplateTable.SetMarker(Mrk: TgsTextTemplateMarker);
begin
  if FMarker = nil then
    FMarker := Mrk
  else
    raise Exception.Create('Для таблицы может быть указан только один маркер!')
end;

function TgsTextTemplateTable.GetFieldsCount: Integer;
begin
  Result := FList.Count;
end;

function TgsTextTemplateTable.GetField(Const Index: Integer): TgsTextTemplateField;
begin
  Result := TgsTextTemplateField(FList[Index]);
end;

function TgsTextTemplateTable.GetUserFieldsCount: Integer;
begin
  Result := FUserList.Count;
end;

function TgsTextTemplateTable.GetUserField(Const Index: Integer): TgsTextTemplateUserField;
begin
  Result := TgsTextTemplateUserField(FUserList[Index]);
end;

function TgsTextTemplateTable.CreateFields: TClientDataset;
var
  j: Integer;
  Fld: TClientDataset;
begin
  Fld := TClientDataSet.Create(nil);
  try
    Fld.FieldDefs.Clear;
    for j:=0 to FieldsCount - 1 do
      with FieldsList [j] do
        Fld.FieldDefs.Add(Name.Text, ftString, Size*Height, false);
    for j:=0 to UserFieldsCount - 1 do
      with UserFieldsList [j] do
        Fld.FieldDefs.Add(Name.Text, ftString, Size, false);
    Fld.IndexDefs.Clear;
    Fld.Data := NULL;
    Fld.CreateDataSet;

    if FieldsCount > 0 then
      DataFile.PosY := 1;
    while not (DataFile.FindInString(EndTable) or DataFile.FindInString(cstEndFile)) do
    begin
      Fld.Insert;
      DataFile.RowHeight := 1;
      for j := 0 to FieldsCount - 1 do
        if DataFile.SetPosInFile (FieldsList[j].Marker, EndTable) then
          Fld.Fields.Fields[j].Value := DataFile.GetFieldValue (FieldsList [j],
            FNecessarily, EndRecord, EndTable, RecordLabel);

      for j := 0 to FieldsCount - 1 do
      begin
     //если запись содержит только пустые поля сохранять ее не будем!
        if Fld.Fields[j].AsString > '' then
        begin
          Fld.Post;
          Break;
        end;
      end;
      if Fld.State in dsEditModes then
        Fld.Cancel;
      DataFile.NextRecord(FNecessarily, EndRecord, EndTable, FRecordLabel);
      DataFile.PosY := 1;
    end;
    Result := Fld;

  except
    on E: Exception do
    begin
      Fld.Free;
      raise Exception.Create('Неправильно описаны поля в файле шаблона! Таблица ' + FName.Text +
        #13#10 + E.Message);
    end;
  end;
end;

procedure TgsTextTemplateTable.SetNecessarily(const Value: Integer);
begin
  FNecessarily := Value;
  FEndRecord.System := False;
  FEndRecord.Text := '';
  if Assigned(FRecordLabel) then
    FreeAndNil(FRecordLabel);
end;

procedure TgsTextTemplateTable.SetEndRecord(const Value: TChars);
begin
  if (FNecessarily = 0) and (FRecordLabel = nil) then
    FEndRecord := Value;
end;

procedure TgsTextTemplateTable.SetRecordLabel(
  const Value: TgsTextTemplateRecordLabel);
begin
  if FNecessarily = 0 then
  begin
    if FRecordLabel = nil then
      FRecordLabel := Value
    else
      raise Exception.Create('Для таблицы может быть указана только одна метка записи!');
  end;
end;

{ TgsTextTemplateArea}

constructor TgsTextTemplateArea.Create;
begin
  inherited;
  FFieldsList := TObjectList.Create;
  FTablesList := TObjectList.Create;
  FUserList := TObjectList.Create;
end;

destructor TgsTextTemplateArea.Destroy;
begin
  FFieldsList.Free;
  FTablesList.Free;
  FUserList.Free;
  inherited;
end;

function TgsTextTemplateArea.AddField(Item: TgsTextTemplateField): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  Result := FFieldsList.Add(Item);
end;

procedure TgsTextTemplateArea.DeleteField(Const Index: Integer);
begin
  FFieldsList.Delete(Index);
end;

function TgsTextTemplateArea.AddTable(Item: TgsTextTemplateTable): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  Result := FTablesList.Add(Item);
end;

procedure TgsTextTemplateArea.DeleteTable(Const Index: Integer);
begin
  FTablesList.Delete(Index);
end;

function TgsTextTemplateArea.CreateFields: TClientDataSet;
var
  j: Integer;
  Fld: TClientDataset;
  EndRec: TChars;
begin
  EndRec.System := False;
  EndRec.Text := '';

  Fld := TClientDataSet.Create(nil);
  try
    Fld.FieldDefs.Clear;
    for j:=0 to FieldsCount - 1 do
      with FieldsList [j] do
        Fld.FieldDefs.Add(Name.Text, ftString, Size, false);
    for j:=0 to UserFieldsCount - 1 do
      with UserFieldsList [j] do
        Fld.FieldDefs.Add(Name.Text, ftString, Size, false);
    Fld.IndexDefs.Clear;
    Fld.Data := NULL;
    Fld.CreateDataSet;
  except
{    ShowMessage('Неправильно описаны поля в файле шаблона! Область ' + FName.Text);
    Fld.Free;
    Result := nil;
    Exit;}
    on E: Exception do
    begin
      Fld.Free;
      raise Exception.Create('Неправильно описаны поля в файле шаблона! Область ' + FName.Text +
       #13#10 + E.Message);
    end;
  end;

  if FieldsCount > 0 then
  begin
    Fld.Insert;
    DataFile.RowHeight := 1;
    for j:=0 to FieldsCount - 1 do
      if DataFile.SetPosInFile (FieldsList[j].Marker, EmptyChars) then
        Fld.Fields.Fields[j].Value := DataFile.GetFieldValue (FieldsList [j], 0, EndRec, EndArea, nil);

    Fld.Post;
  end;
  Result := Fld;
end;

function TgsTextTemplateArea.CreateAreas: TgsTextDatabaseArea;
var
  i: Integer;
  FAreaText: TgsTextDatabaseArea;
begin
  FAreaText := TgsTextDatabaseArea.Create;
  FAreaText.Name := Name.Text;
  if (FFieldsList.Count > 0) or (FUserList.Count > 0) then
    FAreaText.FillFields(CreateFields);
  while true do
  begin
    for i := 0 to TablesCount - 1 do
      if DataFile.FindInString(TablesList [i].BeginTable) then
      begin
        FAreaText.AddTable(TablesList[i].CreateTables);
      end;
    if (DataFile.FindInString(EndArea)) or (DataFile.FindInString(EofText)) then Break;
    DataFile.NextString;
  end;

  Result := FAreaText;
end;

function TgsTextTemplateArea.GetField(const Index: Integer): TgsTextTemplateField;
begin
  Result := TgsTextTemplateField(FFieldsList[Index]);
end;

function TgsTextTemplateArea.GetFieldsCount: Integer;
begin
  Result := FFieldsList.Count;
end;

function TgsTextTemplateArea.GetTable(const Index: Integer): TgsTextTemplateTable;
begin
  Result := TgsTextTemplateTable(FTablesList[Index]);
end;

function TgsTextTemplateArea.GetTablesCount: Integer;
begin
  Result := FTablesList.Count;
end;

function TgsTextTemplateArea.AddUserField(
  Item: TgsTextTemplateUserField): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  FUserList.Add(Item);
end;

procedure TgsTextTemplateArea.DeleteUserField(const Index: Integer);
begin
  FUserList.Delete(Index);
end;

function TgsTextTemplateArea.GetUserField(
  const Index: Integer): TgsTextTemplateUserField;
begin
  Result := TgsTextTemplateUserField(FUserList[Index]);
end;

function TgsTextTemplateArea.GetUserFieldsCount: Integer;
begin
  Result := FUserList.Count;
end;

{ TgsTextTemplateFile }

constructor TgsTextTemplateFile.Create;
begin
  inherited Create;
  FAreaList := TObjectList.Create;
  FTrimRightString := true;
  FTrimLeftString := false;
  FCaseSensitive := true;
end;

destructor TgsTextTemplateFile.Destroy;
begin
  FAreaList.Free;
  inherited;
end;

function TgsTextTemplateFile.AddArea(Item: TgsTextTemplateArea): Integer;
begin
  Result := -1;
  if not Assigned(Item) then Exit;
  Result := FAreaList.Add(Item);
end;

procedure TgsTextTemplateFile.DeleteArea(Const I: Integer);
begin
  FAreaList.Delete(I);
end;

procedure TgsTextTemplateFile.LoadFromTextFile(const AFileName: String; var ADatabase: TgsTextDatabase);
var
  I: Integer;
  IsFoundArea: Boolean;
begin
  DataFile := TgsTextFile.Create(FTrimRightString, FTrimLeftString, FCaseSensitive, FCodePage);
  try
    DataFile.OpenFile (AFileName);
    while (not DataFile.FindInString(BeginFile)) and (not DataFile.FindInString(EofText)) do
      DataFile.NextString;
    if DataFile.FindInString(EofText) then
      raise Exception.Create('Некорректный файл с данными!')
    else
      while not (DataFile.FindInString(EndFile) or DataFile.FindInString(EofText)) do
      begin
        // Ищем и считываем области
        for i := 0 to AreaCount - 1 do
          if DataFile.FindInString(AreaList[i].BeginArea) then
            ADatabase.AddArea(AreaList[i].CreateAreas);

        // Если мы еще не дошли до конца файла анализируем текущую строку
        if not(DataFile.FindInString(EndFile) or DataFile.FindInString(EofText)) then
        begin
          // Возможно начало следующей области находится на той же строчке что и конец предыдущей,
          //  поэтому не переходя на след. строку пробуем искать области снова
          IsFoundArea := False;
          for i := 0 to AreaCount - 1 do
            if DataFile.FindInString(AreaList[i].BeginArea) then
              IsFoundArea := True;
          if not IsFoundArea then
            DataFile.NextString;
        end;
      end;
   finally
     DataFile.Free;
   end;
end;

function TgsTextTemplateFile.GetArea(I: Integer): TgsTextTemplateArea;
begin
  Result := TgsTextTemplateArea(FAreaList[I]);
end;

function TgsTextTemplateFile.GetAreaCount: Integer;
begin
  Result := FAreaList.Count;
end;

{ TgsTextFile }

constructor TgsTextFile.Create(TrimR, TrimL, CaseS: boolean; CodeP: TCodePage);
begin
  inherited Create;
  Rows := TStringList.Create;
  FTrimLeftString := TrimL;
  FTrimRightString := TrimR;
  FCaseSensitive := CaseS;
  FCodePage := CodeP;
  FCurrentRow := 0;
  FPosY := 1;
end;

destructor TgsTextFile.Destroy;
begin
  Rows.Free;
  inherited;
end;

procedure TgsTextFile.OpenFile(AFileName: String);
var
  S: String;
  FTx: Text;
begin
  try
    AssignFile(FTx, AFileName);
    Reset(FTx);
    try
      FCurrentRow := 1;
      FCurrentPos := 1;
      while not EOF(FTx) do
      begin
        Readln(FTx, S);
        if FTrimRightString then S := TrimRight(S);
        if FTrimLeftString then S := TrimLeft(S);
        if S > '' then
          case FCodePage of
          //cpANSI:;
            cpOEM:  OemToChar(PChar(S), PChar(S));
          end;
        Rows.Add (S);
      end;
    finally
      Close(FTx);
    end;
    FCurrentString := Rows[FCurrentRow - 1];
  except
    MessageBox(HWND(nil),PChar('Неправильное имя файла ' + AFileName),
	    'Внимание', MB_OK);
  end;
end;

function TgsTextFile.FindInString(Key: TChars): boolean;
var
  St: String;

begin
  Result := false;
  if Key.System then
  begin
    St := FCurrentString;
    case Key.Symbol of
    ssBOF: if (FCurrentPos = 1) and (FCurrentRow = 1) then Result := true else Result := false;
    ssEOF: if (FCurrentRow = Rows.Count) and (FCurrentPos >= Length(St) + 1) then Result := true else Result := false;
    ssEOL: if FCurrentPos > Length(St) then Result := true else Result := false;
    ssBOL: if FCurrentPos = 1 then Result := true else Result := false;
    ssEL: if St = '' then Result := true else Result := false;
    end;
  end
  else
  begin
    if Key.Text = '' then
    begin
//      Result := true;
      Exit;
    end;

    St := Copy(FCurrentString, FCurrentPos, Length(FCurrentString) - FCurrentPos +1);
    if FCaseSensitive then
    begin
      if AnsiPos(Key.Text, St)>0 then
      begin
        FCurrentPos := AnsiPos(Key.Text, St) + FCurrentPos -1;
        Result := true;
      end;
    end
    else
      if AnsiPos(AnsiUpperCase(Key.Text), AnsiUpperCase(St)) > 0 then
      begin
        FCurrentPos := AnsiPos(AnsiUpperCase(Key.Text), AnsiUpperCase(St)) + FCurrentPos - 1;
        Result := True;
      end;
  end;
end;

function TgsTextFile.FindInStringSet(Key: TChars): boolean;
var
  I, J: Integer;
begin
  Result := false;
  if Key.System then
  begin
    case Key.Symbol of
    ssBOF:
      Result := (FCurrentPos = 1) and (FCurrentRow = 1);
    ssEOF:
      Result := (FCurrentRow = Rows.Count) and (FCurrentPos >= Length(FCurrentString) + 1);
    ssEOL:
      Result := FCurrentPos > Length(FCurrentString);
    ssBOL:
      Result := FCurrentPos = 1;
    ssEL:
      Result := FCurrentString = '';
    end;
  end else
  begin
    if Key.Text > '' then
    begin
      I := FCurrentPos;
      while (not Result) and (I <= Length(FCurrentString)) do
      begin
        for J := 1 to Length(Key.Text) do
        begin
          if Key.Text[J] = FCurrentString[I] then
          begin
            Result := True;
            FCurrentPos := I;
            break;
          end;
        end;
        Inc(I);
      end;
    end;
  end;
end;

function TgsTextFile.FindWholeWord(Key: TChars; WholeW: boolean): boolean;
begin
  Result := FindInString(Key);
  if (not WholeW) or Key.System or (not Result) then Exit;

  if FCurrentPos > 1 then
    if Trim (Copy (FCurrentString, FCurrentPos - 1, 1 )) > '' then
    begin
      Result := false;
      Exit;
    end;

  if Trim( Copy (FCurrentString, FCurrentPos + Length(Key.Text), 1)) = '' then
    Result := true
  else Result := false;
end;

function TgsTextFile.CompareStr(FirstSt: String; SecondSt: String): boolean;
begin
  Result := false;
  if FCaseSensitive then
  begin
    if AnsiCompareStr(FirstSt, SecondSt) = 0 then Result := true;
  end
  else
  begin
    if AnsiCompareText(FirstSt, SecondSt) = 0 then Result := true;
  end;
end;

function TgsTextFile.NextString: Boolean;
begin
  if FCurrentRow = Rows.Count then
  begin
    if FCurrentPos > Length(FCurrentString) then
      raise Exception.Create('Достигнут конец файла!');
    FCurrentPos := Length(FCurrentString) + 1;
    Result := False
  end else
  begin
    FCurrentString := Rows[FCurrentRow];
    FCurrentPos := 1;
    FCurrentRow := FCurrentRow + 1;
    Result := True;
  end;
end;

procedure TgsTextFile.NextRecord(Necess: Integer; EndRec: TChars; EndTable: TChars;
  RecordLabel: TgsTextTemplateRecordLabel);
begin
  if FindInString(EndTable) then Exit;

  NextString;
  if (Necess > 0) then
  begin
    while (Necess >= FCurrentPos) and (Trim(Copy(FCurrentString, Necess, 1)) = '') and (not FindInString(EndTable)) do
      NextString;
  end else

  if Assigned(RecordLabel) then
  begin
    while (not FindRecordLabel(RecordLabel)) and (not FindInString(EndTable)) do
      NextString;
  end else

  begin
    if ((not EndRec.System) and (EndRec.Text > '')) or EndRec.System then
    begin
      while (not FindInString(EndRec)) and (not FindInString(EndTable)) do
        NextString;
      if FindInString(EndRec) then
        NextString;
    end;
  end;
end;

function TgsTextFile.GetFieldValue(Fld: TgsTextTemplateField; Necess: Integer;
  EndRecord: TChars; EndTable: TChars; RecordLabel: TgsTextTemplateRecordLabel): String;

  function ReadField (Fld: TgsTextTemplateField; St: String): String;
  var
    StHelp: String;
    i: Integer;

  begin
    if FCurrentPos > Length(FCurrentString) then
    begin
      Result := '';
      Exit;
    end;

    //Если выравнивание идет по левой границе поля
    if Fld.Alignment = aLeft then
    begin
      //Проверяем есть ли даннные в текущей позиции
      if (Fld.NoData <> 0) and (Trim(Copy(St, FCurrentPos - Fld.NoData, FCurrentPos - 1)) > '')
      then
      begin
        Result := '';
        Exit;
      end;

      St := Copy(St, FCurrentPos, Length(St) - FCurrentPos + 1);

      if Fld.Size < Length(St) then St := Copy(St, 1, Fld.Size);

      {Все-таки будем ститывать пустые поля}      
{      if Trim(Copy(St,1,1)) = '' then
      begin
        Result := '';
        Exit;
      end;  }

      if not Fld.Terminator.System then
      begin
        if (Fld.Terminator.Text  > '') and (AnsiPos(Fld.Terminator.Text, St) <> 0) then
          St := Copy (St, 1, AnsiPos(Fld.Terminator.Text, St) - 1);
      end;

      if Fld.LegalChars.Text > '' then
      begin
        for i := 1 to Length(St) do
          if AnsiPos(Copy(St,1,1), Fld.LegalChars.Text) > 0 then
          begin
            StHelp := StHelp + Copy(St,1,1);
            Delete(St,1,1);
          end
          else
            Break;
        St := StHelp;
      end;

      if not Fld.TrimChars.System then
        if Fld.TrimChars.Text  > '' then
        begin
          StHelp := Fld.TrimChars.Text ;
          while Length(StHelp)>0 do
          begin
            while AnsiPos(Copy(StHelp, 1, 1), St) > 0 do
              Delete (St, AnsiPos(Copy(StHelp, 1, 1), St), 1);
            Delete (StHelp,1,1);
          end;
        end;

      St := TrimRight(St);

    end
    //Если выравнивание идет по правой границе поля
    else
    begin
      if (Fld.NoData <> 0) and (Trim(Copy(St, FCurrentPos + 1, FCurrentPos + Fld.NoData)) > '')
      then
      begin
        Result := '';
        Exit;
      end;

      St := Copy(St, 1, FCurrentPos);

      if Fld.Size < Length(St) then St := Copy(St, Length(St) - Fld.Size + 1, Fld.Size);

      {Все-таки будем ститывать пустые поля}
{      if Trim(Copy(St,Length(St),1)) = '' then
      begin
        Result := '';
        Exit;
      end;}

      if not Fld.Terminator.System then
      begin
        if Fld.Terminator.Text > '' then
        while AnsiPos(Fld.Terminator.Text, St) > 0 do
          Delete (St, 1, AnsiPos(Fld.Terminator.Text, St));
      end;

      if Fld.LegalChars.Text > '' then
      begin
        for i := 1 to Length(St) do
          if AnsiPos(Copy(St,Length(St),1), Fld.LegalChars.Text) > 0 then
          begin
            StHelp := Copy(St,Length(St),1) + StHelp;
            Delete(St,Length(St),1);
          end
          else
            Break;
        St := StHelp;
      end;

      if not Fld.TrimChars.System then
        if Fld.TrimChars.Text  > '' then
        begin
          StHelp := Fld.TrimChars.Text ;
          while Length(StHelp)>0 do
          begin
            while AnsiPos(Copy(StHelp, 1, 1), St) > 0 do
              Delete (St, AnsiPos(Copy(StHelp, 1, 1), St), 1);
            Delete (StHelp,1,1);
          end;
        end;

      St := TrimLeft(St);
    end;
    Result := St;
  end;

var
  St: String;
  StHelp: String;
  j: Integer;
  H: Integer;
  Posit: Integer;
begin

  if FindInString(EndTable) or FindInString(EndRecord) then
  begin
    Result := '';
    Exit;
  end;

  if (Fld.PosY = 1) and (Necess > 0) then
    while (Trim(Copy(FCurrentString, Necess, 1)) = '') and NextString do;

  if FPosY <  Fld.PosY then
  begin
    for j := FPosY to Fld.PosY + FRowHeight - 2 do
    begin
      //это последняя строка
      if (not NextString) then
      begin
        Result := '';
        Exit;
      end;
      //если следующая строка оказвается новой записью, делаем откат
      if ((Necess > 0) and (Trim(Copy(FCurrentString, Necess, 1)) > ''))
        or FindInString(EndTable) or FindInString(EndRecord) or
        FindRecordLabel(RecordLabel)
      then
      begin
        PreviousString;
        Result := '';
        Exit;
      end;
    end;
    FPosY := Fld.PosY;
    FRowHeight := 1;
  end;

  if Fld.PosX <> 0 then FCurrentPos := Fld.PosX;

  St := ReadField(Fld, FCurrentString);

  Posit := FCurrentPos;
  H := 1;
  if (Necess > 0) and (St > '') then
  begin
    for j := 1 to Fld.Height - 1 do
    begin
      if (not NextString) then
      begin
        Break;
      end;
      H := H + 1;
      FCurrentPos := Posit;
      if (Trim(Copy(FCurrentString, Necess, 1)) > '') or FindInString(EndTable) then
      begin
        PreviousString;
        H := H - 1;
        Break;
      end;
      StHelp := ReadField(Fld, FCurrentString);
      if StHelp = '' then
      begin
        PreviousString;
        H := H - 1;
        Break;
      end;
      St := St + ' ' + StHelp;
    end;
  end
  else if ((EndRecord.System) or ((not EndRecord.System) and (EndRecord.Text > ''))
    or Assigned(RecordLabel))
    and (St > '')  then
  begin
    for j := 1 to Fld.Height - 1 do
    begin
      if (not NextString) then
      begin
        Break;
      end;
      H := H + 1;
      FCurrentPos := Posit;
      if FindInString(EndRecord) or FindInString(EndTable) or FindRecordLabel(RecordLabel)
      then
      begin
        PreviousString;
        H := H - 1;
        Break;
      end;
      StHelp := ReadField(Fld, FCurrentString);
      if StHelp = '' then
      begin
        PreviousString;
        H := H - 1;
        Break;
      end;
      St := St + ' ' + StHelp;
    end;
  end;


  for j := 1 to H - 1 do
  begin
    PreviousString;
  end;
  FCurrentPos := Posit;
  if FRowHeight < H then FRowHeight := H;

  Result := St;
end;

function TgsTextFile.SetPosInFile(Mrk: TgsTextTemplateMarker; LimitSymbol: TChars): boolean;
var
  OldCurrentRow: Integer;
begin
  Result := true;
  OldCurrentRow := FCurrentRow;
  if Mrk = nil then Exit;
  if Mrk.MarkerText.Text  > '' then
    while not FindWholeWord(Mrk.MarkerText, Mrk.WholeWord) do
    begin
      if FindInString(EofText) then
      begin
        raise Exception.Create('Достигнут конец файла! Файл шаблона не соотвествует файлу данных! '#13#10 +
          'Маркер ' + Mrk.MarkerText.Text + ' не найден, начиная со строки ' + IntToStr(OldCurrentRow));
      end;
      NextString;
      if FindWholeWord(LimitSymbol, False) then
      begin
        PreviousString;
        Result := False;
        Exit;
      end;
    end;

  if Mrk.SkipChars.System then
  begin
    case Mrk.SkipChars.Symbol of
    ssEL: while FCurrentString = '' do NextString;
    end;
  end
  else
    if ((not Mrk.SkipChars.System) and (mrk.SkipChars.Text > '')) then
    begin
      FCurrentPos := FCurrentPos + Length(Mrk.MarkerText.Text);
      while CompareStr(Copy(FCurrentString, FCurrentPos, Length(Mrk.SkipChars.Text )), Mrk.SkipChars.Text) do
        FCurrentPos := FCurrentPos + Length(Mrk.SkipChars.Text);
    end;

  if Mrk.SkipUntilChars.System then
  begin
    case Mrk.SkipUntilChars.Symbol  of
{    ssBOF: begin
             FCurrentPos := 1;
             FCurrentRow := 1;
           end;               }
    ssBOL: begin
             NextString;
           end;
    ssEOL: FCurrentPos := Length(FCurrentString);
    ssEOF: begin
             FCurrentRow := Rows.Count;
             FCurrentString := Rows[FCurrentRow - 1];
             FCurrentPos := Length(FCurrentString);
           end;
     ssEL: while not FindInString(Mrk.SkipUntilChars) do NextString;
    end;
    if Mrk.SkipUntilChars.Symbol <> ssBOL then
      FCurrentPos := FCurrentPos + 1;
    if FCurrentPos > Length(FCurrentString) then NextString;
  end
  else
    if ((not Mrk.SkipUntilChars.System) and (mrk.SkipUntilChars.Text > '')) then
    begin
      OldCurrentRow := FCurrentRow;
      FCurrentPos := FCurrentPos + Length(Mrk.MarkerText.Text);
      while not FindInStringSet(Mrk.SkipUntilChars) do
      begin
        if FindInString(EofText) then
        begin
          raise Exception.Create('Достигнут конец файла! Файл шаблона не соотвествует файлу данных! '#13#10 +
              'Маркер "пропустить пока не найдены символы"' +
              TCharsToString(Mrk.SkipUntilChars) +
              ' не найден, начиная со строки ' + IntToStr(OldCurrentRow));

        end;
        NextString;
        if FindWholeWord(LimitSymbol, False) then
        begin
          Result := False;
          Exit;
        end;

      end;
      //FCurrentPos := FCurrentPos + Length(Mrk.SkipUntilChars.Text);
      if FCurrentPos > Length(FCurrentString) then NextString;
    end;

  if Mrk.SkipNextChars <> 0 then FCurrentPos := FCurrentPos + Mrk.SkipNextChars;
end;

procedure TgsTextFile.PreviousString;
begin
  if FCurrentRow = 1 then
  begin
    FCurrentPos := 1;
    Exit;
  end;
  FCurrentPos := 1;
  FCurrentRow := FCurrentRow - 1;
  FCurrentString := Rows[FCurrentRow - 1];
end;

function TgsTextFile.FindRecordLabel(
  RecordLabel: TgsTextTemplateRecordLabel): Boolean;
var
  SubSt: String;
  I, J: Integer;
  WasPredicate: Boolean;
begin
  if Assigned(RecordLabel) then
  begin
    if RecordLabel.Mask = '' then
    begin
      Result := True;
      Exit;
    end else
      Result := False;

    if RecordLabel.PosX < 1 then
    begin
      RecordLabel.PosX := 1;
    end;

    if (RecordLabel.PosX > Length(FCurrentString)) or
      (Length(RecordLabel.Mask) > (Length(FCurrentString) - RecordLabel.PosX + 1)) then Exit;

    SubSt := Copy(FCurrentString, RecordLabel.PosX, Length(RecordLabel.Mask));
    J := 1;
    WasPredicate := False;
    for I := 1 to Length(RecordLabel.Mask) do
    begin
      //Предикат специального символа
      //На совпадение будет проверяться следующий символ
      if RecordLabel.Mask[I] = '@' then
      begin
        WasPredicate := True;
        Dec(J);
      end else

      //если предыдущий символ был предикат, то текущий символ сравниваем на совпадение
      if WasPredicate then
      begin
       if RecordLabel.Mask[I] <> SubSt[J] then
         Exit;
       WasPredicate := False;
      end else

      //Любой символ
      if RecordLabel.Mask[I] = '&' then
      begin
        WasPredicate := False;
      end else

      //Возможно цифра
      if RecordLabel.Mask[I] = '#' then
      begin
        if not (SubSt[J] in ['0'..'9']) then
          Dec(J);
        WasPredicate := False;
      end else

      //Обязательно цифра
      if RecordLabel.Mask[I] = '0' then
      begin
        if not (SubSt[J] in ['0'..'9']) then
          Exit;
        WasPredicate := False;
      end else
      begin
        //На совпадение
        if RecordLabel.Mask[I] <> SubSt[J] then
          Exit;
        WasPredicate := False;
      end;

      Inc(J);
    end;
    Result := True;
  end else
    Result := False;
end;

{ TgsTempFile}

constructor TgsTempFile.Create;
begin
  FSystemList := TStringList.Create;
  FSystemList.Add (SystemSymbol[ssBOF]);
  FSystemList.Add (SystemSymbol[ssEOF]);
  FSystemList.Add (SystemSymbol[ssEOL]);
  FSystemList.Add (SystemSymbol[ssBOL]);
  FSystemList.Add (SystemSymbol[ssEL]);

  FKeyWordList := TStringList.Create;
  FKeyWordList.Add (KeyWordSet[kwYES]);
  FKeyWordList.Add (KeyWordSet[kwNO]);
  FKeyWordList.Add (KeyWordSet[kwOEM]);
  FKeyWordList.Add (KeyWordSet[kwANSI]);
  FKeyWordList.Add (KeyWordSet[kwRIGHT]);
  FKeyWordList.Add (KeyWordSet[kwLEFT]);

  FTemplateFile := TStringList.Create;
end;

destructor TgsTempFile.Destroy;
begin
  FTemplateFile.Free;
  FSystemList.Free;
  FKeyWordList.Free;
  inherited;
end;

procedure TgsTempFile.OpenFile(AFileName: String);
begin
//  try
  FTemplateFile.LoadFromFile(AFileName);
  FCurrentRow := 0;
{  except
    MessageBox(HWND(nil),PChar('Неправильное имя файла ' + AFileName),
    'Внимание', MB_OK);
  end;}
end;

function TgsTempFile.NextString: boolean;
begin
  if FCurrentRow >= FTemplateFile.Count then
  begin
    raise Exception.Create('Ошибка в файле шаблона. Достигнут конец файла!');
  end;

  repeat
    FCurentString := FTemplateFile[FCurrentRow];
    FCurrentRow := FCurrentRow + 1;
    DeleteUnnecessary;
  until (FCurentString > '') or (FCurrentRow >= FTemplateFile.Count);
  Result := true;
end;

function TgsTempFile.FindKeyWord (key: String): boolean;
begin
  if (AnsiCompareText (GetKeyWord, key) = 0) then Result := true
  else Result := false;
end;

function TgsTempFile.GetKeyWord;
begin
  if AnsiPos(':', FCurentString) > 0 then
    Result := Copy(FCurentString, 1, AnsiPos(':', FCurentString) - 1)
  else
    Result := FCurentString;
end;

function TgsTempFile.Means: TChars;
var
  St: String;
  StR: TChars;
begin
  St := FCurentString;
  if AnsiPos(KeyWordSet[kwColon], St) = 0 then
  begin
    StR.System := false;
    StR.Text := '';
    Result := StR;
    Exit;
  end;

  Delete(St, 1, AnsiPos(KeyWordSet[kwColon], St));
  St := Trim(St);

  if AnsiPos(KeyWordSet[kwCommas], St)=1 then
  begin
    Delete(St, 1, 1);
    if St[Length(St)] = KeyWordSet[kwCommas] then
      SetLength(St, Length(St) - 1);
    StR.System := false;
    StR.Text := St;
    Result := StR;
    Exit;
  end;

  if AnsiPos('''', St)=1 then
  begin
    Delete(St, 1, 1);
    if St[Length(St)] = '''' then
      SetLength(St, Length(St) - 1);
    StR.System := false;
    StR.Text := St;
    Result := StR;
    Exit;
  end;

  if (AnsiPos('“', St)=1)
    and (St[Length(St)] = '”') then
  begin
    Delete(St, 1, 1);
    if Length(St) > 0 then
      SetLength(St, Length(St) - 1);
    StR.System := false;
    StR.Text := St;
    Result := StR;
    Exit;
  end;

  if FKeyWordList.IndexOf(AnsiUpperCase(St)) > -1 then
  begin
    StR.System := false;
    StR.Text := St;
    Result := StR;
    Exit;
  end;

  StR.System := true;
  case FSystemList.IndexOf(AnsiUpperCase(St)) of
  0: StR.Symbol := ssBOF;
  1: StR.Symbol := ssEOF;
  2: StR.Symbol := ssEOL;
  3: StR.Symbol := ssBOL;
  4: StR.Symbol := ssEL;
  else
    try
      StrToInt(St);
      StR.System := false;
      StR.Text := St;
      Result := StR;
//      Exit;
    except
      On E: Exception do
        raise Exception.Create ('Ошибка в шаблоне! Строка ' + IntToStr(FCurrentRow)
          + #13#10 + E.Message);
    end;
  end;
  Result := StR;
end;

//удаляем из строки комментарии, начальные и конечные пробелы
procedure TgsTempFile.DeleteUnnecessary;
begin
  if AnsiPos (KeyWordSet[kwComent], FCurentString) > 0 then
  begin
    if (AnsiPos (KeyWordSet[kwComent], FCurentString) = 1) then
    begin
      FCurentString := '';
      Exit;
    end
    else
      FCurentString := Copy(FCurentString, 1, AnsiPos(KeyWordSet[kwComent], FCurentString) - 1);
  end;
  FCurentString := Trim(FCurentString);
end;

procedure TgsTempFile.OpenFile(S: TStream);
begin
  try
    S.Position := 0;
    FTemplateFile.LoadFromStream(S);
    FCurrentRow := 0;
  except
    raise Exception.Create('Некорректный поток!');
  end;
end;

{ TgsTextConverter }

constructor TgsTextConverter.Create;
var
  MC: TMarkerClause;
  FC: TFieldClause;
  UFC: TUserFieldClause;
  FlC: TFileClause;
  TC: TTableClause;
  RLC: TRecordLabelClause;
begin
  inherited;
  MarkerAttrList := TStringList.Create;
  MarkerAttrList.Sorted := True;
  for MC := Low(MarkerClauseText) to High(MarkerClauseText) do
   MarkerAttrList.AddObject(MarkerClauseText[MC], Pointer(MC));

  FieldAttrList := TStringList.Create;
  FieldAttrList.Sorted := True;
  for FC := Low(FieldClauseText) to High(FieldClauseText) do
    FieldAttrList.AddObject(FieldClauseText[FC], Pointer(FC));

  UserFieldAttrList := TStringList.Create;
  UserFieldAttrList.Sorted := True;
  for UFC := Low(UserFieldClauseText) to High(UserFieldClauseText) do
    UserFieldAttrList.AddObject(UserFieldClauseText[UFC], Pointer(UFC));

  FileAttrList := TStringList.Create;
  FileAttrList.Sorted := True;
  for FlC := Low(FileClauseText) to High(FileClauseText) do
    FileAttrList.AddObject(FileClauseText[FlC], Pointer(FlC));

  TableAttrList := TStringList.Create;
  TableAttrList.Sorted := True;
  for TC := Low(TableClauseText) to High(TableClauseText) do
    TableAttrList.AddObject(TableClauseText[TC], Pointer(TC));

  RecordLblAttrList := TStringList.Create;
  RecordLblAttrList.Sorted := True;
  for RLC := Low(RecordLabelClauseText) to High(RecordLabelClauseText) do
    RecordLblAttrList.AddObject(RecordLabelClauseText[RLC], Pointer(RLC));

  FDataBase := TgsTextDatabase.Create;
  (FDataBase as IgsTextDatabase)._AddRef;
  FileTm := TgsTextTemplateFile.Create;
end;

destructor TgsTextConverter.Destroy;
begin
  MarkerAttrList.Free;
  FieldAttrList.Free;
  UserFieldAttrList.Free;
  FileAttrList.Free;
  TableAttrList.Free;
  RecordLblAttrList.Free;
  (FDataBase as IgsTextDatabase)._Release;
  FDataBase := nil;
  FileTm.Free;
  inherited;
end;

procedure TgsTextConverter.LoadFromTempFile(const ATempName: WideString);
var
  i: Integer;
  Ind: Integer;
begin
  if FileTm = nil then
    FileTm := TgsTextTemplateFile.Create
  else
  begin
    FileTm.Free;
    FileTm := TgsTextTemplateFile.Create;
  end;

  TempFile := TgsTempFile.Create;
  try
    TempFile.OpenFile(ATempName);
    TempFile.NextString;
    for i := 1 to 4 do
    begin
      Ind := FileAttrList.IndexOf(AnsiUpperCase(TempFile.GetKeyWord));
      if Ind = -1 then
        Break;
      case TFileClause(FileAttrList.Objects[Ind]) of
      dcTrimRight: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwYes])=0 then
             FileTm.TrimRightString := true
           else
             FileTm.TrimRightString := false;
           TempFile.NextString;
         end;
      dcTrimLeft: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwYes])=0 then
             FileTm.TrimLeftString := true
           else
             FileTm.TrimLeftString := false;
           TempFile.NextString;
         end;
      dcCaseSensitive: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwYes])=0 then
             FileTm.CaseSensitive := true
           else
             FileTm.CaseSensitive := false;
           TempFile.NextString;
         end;
      dcCodePage: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwAnsi])=0 then
             FileTm.CodePage := cpANSI
           else
             FileTm.CodePage := cpOEM;
           TempFile.NextString;
         end;
      end;
    end;
    if TempFile.FindKeyWord (FileClauseText[dcBeginFile]) then
    begin
      FileTm.BeginFile := TempFile.Means;
      while TempFile.NextString do
      begin
        if TempFile.FindKeyWord (FileClauseText[dcEndFile]) then
        begin
          FileTm.EndFile := TempFile.Means;
          cstEndFile := FileTm.EndFile;
          Break;
        end
        else if TempFile.FindKeyWord (AreaClauseText[acBeginArea]) then
        begin
          FileTm.AddArea(GetAreas);
        end
        else
          raise Exception.Create('Незарезервированное слово: ' + TempFile.FCurentString);
      end;
    end
    else
    begin
      raise Exception.Create('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
    end;
  finally
    TempFile.Free;
  end;
end;

procedure TgsTextConverter.StartConvert(const ATextName: WideString);
begin
  if FileTm = nil then Exit;
  FDatabase.Clear;
  {if FDatabase = nil then
  begin
    FDatabase := TgsTextDatabase.Create;
  end else
  begin
    FDatabase.Free;
    FDatabase := TgsTextDatabase.Create;
  end; }
  FileTm.LoadFromTextFile(ATextName, FDatabase);
end;

function TgsTextConverter.GetMarker: TgsTextTemplateMarker;
var
  Ind: Integer;
  MarkerTm: TgsTextTemplateMarker;
begin
  MarkerTm := TgsTextTemplateMarker.Create;
  try
    TempFile.NextString;
    while not TempFile.FindKeyWord(MarkerClauseText[mcEndMarker]) do
    begin
      Ind := MarkerAttrList.IndexOf (TempFile.GetKeyWord);
      if Ind = -1 then
        raise Exception.Create('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
      case TMarkerClause(MarkerAttrList.Objects[Ind]) of
        mcText: MarkerTm.MarkerText := TempFile.Means;
        mcSkipChars: MarkerTm.SkipChars := TempFile.Means;
        mcSkipUntilChars: MarkerTm.SkipUntilChars := TempFile.Means;
        mcSkipNextChars: MarkerTm.SkipNextChars := StrToInt(TempFile.Means.Text);
        mcWholeWord: if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwYes])=0 then
             MarkerTm.WholeWord := true
           else MarkerTm.WholeWord := false;
      end;
      TempFile.NextString;
    end;
    Result := MarkerTm;
  except
    on E: Exception do
    begin
      MarkerTm.Free;
      raise Exception.Create('Ошибка при считывании маркера! ' + E.Message);
    end;
  end;
end;

function TgsTextConverter.GetFields: TgsTextTemplateField;
var
  Ind: Integer;
  FieldTm: TgsTextTemplateField;
begin
  FieldTm := TgsTextTemplateField.Create;
  try
    TempFile.NextString;
    while not TempFile.FindKeyWord(FieldClauseText[fcEndField]) do
    begin
      Ind := FieldAttrList.IndexOf (TempFile.GetKeyWord);
      if Ind = -1 then
        raise Exception.Create('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
      case TFieldClause(FieldAttrList.Objects[Ind]) of
        fcName: FieldTm.Name := TempFile.Means;
        fcBeginMarker:
          if FieldTm.Marker = nil then
            FieldTm.Marker := GetMarker
          else
            raise Exception.Create('Для поля может быть указан только один маркер!');
        fcSize: FieldTm.Size := StrToInt(TempFile.Means.Text);
        fcNoData: FieldTm.NoData := StrToInt(TempFile.Means.Text);
        fcPosX: FieldTm.PosX := StrToInt(TempFile.Means.Text);
        fcPosY: FieldTm.PosY := StrToInt(TempFile.Means.Text);
        fcTerminator: FieldTm.Terminator := TempFile.Means;
        fcLegalChars: FieldTm.LegalChars := TempFile.Means;
        fcTrimChars: FieldTm.TrimChars := TempFile.Means;
        fcAlignment: if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwRight]) = 0 then
             FieldTm.Alignment := aRight
           else
             FieldTm.Alignment := aLeft;
        fcHeight: FieldTm.Height := StrToInt(TempFile.Means.Text);
      end;
      TempFile.NextString;
    end;
    Result := FieldTm;
  except
    on E: Exception do
    begin
      FieldTm.Free;
      raise Exception.Create('Ошибка при считывании полей!  Строка ' +
        IntToStr(TempFile.CurrentRow) + E.Message);
    end;
  end;
end;

function TgsTextConverter.GetUserFields: TgsTextTemplateUserField;
var
  Ind: Integer;
  UserFieldTm: TgsTextTemplateUserField;
begin
  UserFieldTm := TgsTextTemplateUserField.Create;
  try
    TempFile.NextString;
    while not TempFile.FindKeyWord(UserFieldClauseText[ufcEndField]) do
    begin
      Ind := UserFieldAttrList.IndexOf (TempFile.GetKeyWord);
      if Ind = -1 then
        raise Exception.Create ('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
      case TUserFieldClause(UserFieldAttrList.Objects[Ind]) of
        ufcName: UserFieldTm.Name := TempFile.Means;
        ufcSize: UserFieldTm.Size := StrToInt(TempFile.Means.Text);
      end;
      TempFile.NextString;
    end;
    Result := UserFieldTm;
  except
    on E: Exception do
    begin
      UserFieldTm.Free;
      raise Exception.Create('Ошибка при считывании пользовательских полей! ' + E.Message);
    end;
  end;
end;

function TgsTextConverter.GetTables: TgsTextTemplateTable;
var
  TableTm: TgsTextTemplateTable;
  Ind: Integer;
begin
  TableTm := TgsTextTemplateTable.Create;
  try
    TableTm.BeginTable := TempFile.Means;
    TempFile.NextString;
    if TempFile.FindKeyWord(TableClauseText[tcName]) then
      TableTm.Name := TempFile.Means
    else
      raise Exception.Create ('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
    TempFile.NextString;
    while not TempFile.FindKeyWord(TableClauseText[tcEndTable]) do
    begin
      Ind := TableAttrList.IndexOf (AnsiUpperCase(TempFile.GetKeyWord));
      if Ind = -1 then
        raise Exception.Create ('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
      case TTableClause(TableAttrList.Objects[Ind]) of
        tcBeginMarker:
          if not Assigned(TableTm.Marker) then
            TableTm.Marker := GetMarker
          else
            raise Exception.Create('Для таблицы может быть указан только один маркер!');
        tcNecessarily: TableTm.Necessarily := StrToInt(TempFile.Means.Text);
        tcBeginField: TableTm.AddField(GetFields);
        tcBeginUserField: TableTm.AddUserField(GetUserFields);
        tcRecordEnd: TableTm.EndRecord := TempFile.Means;
        tcBeginLabel:
          if not Assigned(TableTm.RecordLabel) then
            TableTm.RecordLabel := GetRecordLabel;
          else
            raise Exception.Create('Для таблицы может быть указана только одна метка записи!');
      end;
      TempFile.NextString;
    end;
    TableTm.EndTable := TempFile.Means;
    Result := TableTm;
  except
    on E: Exception do
    begin
      TableTm.Free;
      raise Exception.Create('Ошибка при считывании таблицы!' + E.Message);
    end;
  end;
end;

function TgsTextConverter.GetAreas: TgsTextTemplateArea;
var
  AreaTm: TgsTextTemplateArea;
  AName: String;
begin
  AreaTm := TgsTextTemplateArea.Create;
  try
    AreaTm.BeginArea := TempFile.Means;
    TempFile.NextString;
    if TempFile.FindKeyWord(AreaClauseText[acName]) then
      AreaTm.Name := TempFile.Means
    else
      raise Exception.Create ('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ) +
        '. Необходимо название области!');
    TempFile.NextString;
    while not TempFile.FindKeyWord (AreaClauseText[acEndArea]) do
    begin
      if TempFile.FindKeyWord(FieldClauseText[fcBeginField]) then
        AreaTm.AddField(GetFields)
      else if TempFile.FindKeyWord(UserFieldClauseText[ufcBeginField]) then
        AreaTm.AddUserField(GetUserFields)
      else if TempFile.FindKeyWord(TableClauseText[tcBeginTable]) then
          AreaTm.AddTable(GetTables)
      else
        raise Exception.Create('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ) +
        '. Не найдена метка конца области!');
      TempFile.NextString;
    end;
    AreaTm.EndArea := TempFile.Means;
    Result := AreaTm;
  except
    on E:Exception do
    begin
      AName := TCharsToString(AreaTm.Name);
      AreaTm.Free;
      raise Exception.Create(Format('Ошибка при считывании области %s: ',
        [AName]) + E.Message);
    end;
  end;
end;

function TgsTextConverter.Get_Database: IgsTextDatabase;
begin
  Result := FDatabase;
end;

function TgsTextConverter.GetDatabase: TgsTextDatabase;
begin
  Result := FDatabase;
end;

function TgsTextConverter.GetRecordLabel: TgsTextTemplateRecordLabel;
var
  Ind: Integer;
  RecordLblTm: TgsTextTemplateRecordLabel;
begin
  RecordLblTm := TgsTextTemplateRecordLabel.Create;
  try
    TempFile.NextString;
    while not TempFile.FindKeyWord(RecordLabelClauseText[rlEndLabel]) do
    begin
      Ind := RecordLblAttrList.IndexOf (TempFile.GetKeyWord);
      if Ind = -1 then
        raise Exception.Create('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
      case TRecordLabelClause(RecordLblAttrList.Objects[Ind]) of
        rlPosX: RecordLblTm.PosX := StrToInt(TempFile.Means.Text);
        rlMask: RecordLblTm.Mask := TempFile.Means.Text;
      end;
      TempFile.NextString;
    end;
    Result := RecordLblTm;
  except
    on E: Exception do
    begin
      RecordLblTm.Free;
      raise Exception.Create('Ошибка при считывании метки записи! ' + E.Message);
    end;
  end;
end;

procedure TgsTextConverter.LoadTemplateFromStream(S: TStream);
var
  i: Integer;
  Ind: Integer;
begin
  if FileTm = nil then
    FileTm := TgsTextTemplateFile.Create
  else
  begin
    FileTm.Free;
    FileTm := TgsTextTemplateFile.Create;
  end;

  TempFile := TgsTempFile.Create;
  try
    TempFile.OpenFile(S);
    TempFile.NextString;
    for i := 1 to 4 do
    begin
      Ind := FileAttrList.IndexOf(AnsiUpperCase(TempFile.GetKeyWord));
      if Ind = -1 then
        Break;
      case TFileClause(FileAttrList.Objects[Ind]) of
      dcTrimRight: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwYes])=0 then
             FileTm.TrimRightString := true
           else
             FileTm.TrimRightString := false;
           TempFile.NextString;
         end;
      dcTrimLeft: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwYes])=0 then
             FileTm.TrimLeftString := true
           else
             FileTm.TrimLeftString := false;
           TempFile.NextString;
         end;
      dcCaseSensitive: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwYes])=0 then
             FileTm.CaseSensitive := true
           else
             FileTm.CaseSensitive := false;
           TempFile.NextString;
         end;
      dcCodePage: begin
           if AnsiCompareText(TempFile.Means.Text, KeyWordSet[kwAnsi])=0 then
             FileTm.CodePage := cpANSI
           else
             FileTm.CodePage := cpOEM;
           TempFile.NextString;
         end;
      end;
    end;
    if TempFile.FindKeyWord (FileClauseText[dcBeginFile]) then
    begin
      FileTm.BeginFile := TempFile.Means;
      while TempFile.NextString do
      begin
        if TempFile.FindKeyWord (FileClauseText[dcEndFile]) then
        begin
          FileTm.EndFile := TempFile.Means;
          cstEndFile := FileTm.EndFile;
          Break;
        end;
        if TempFile.FindKeyWord (AreaClauseText[acBeginArea]) then
        begin
          FileTm.AddArea(GetAreas);
        end;
      end;
    end
    else
    begin
      raise Exception.Create('Ошибка в файле шаблона. Строка ' + IntToStr(TempFile.CurrentRow ));
    end;
  finally
    TempFile.Free;
  end;
end;

procedure TgsTextConverter.LoadTemplateFromStream(const S: IgsStream);
var
  InternalS: TStream;
begin
  InternalS := InterfaceToObject(S) as TStream;
  LoadTemplateFromStream(InternalS);
end;

{ TgsTextTemplateRecordLabel }

constructor TgsTextTemplateRecordLabel.Create;
begin
  inherited;
  FPosX := -1;
  FMask := '';
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsTextConverter, CLASS_gs_TextConverter,
    ciMultiInstance, tmApartment);

  EofText.System := True;
  EofText.Symbol := ssEOF;

  cstEndFile.System := True;
  cstEndFile.Symbol := ssEOF;

  EmptyChars.System := False;
  EmptyChars.Text := '';
end.

