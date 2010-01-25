
unit ct_class;

interface

uses
  Classes, SysUtils, Contnrs, IB, IBDatabase, IBSQL;

type
  TClassSectionType = (cstPrivate, cstProtected, cstPublic, cstPublished);

  TctClass = class;
  TctUnit = class;
  TctClassSection = class;

  TctBase = class(TObject)
  private
    FComment: String;
    FName: String;
    FDecloration: String;

  public
    procedure Sort; virtual; abstract;

    property Comment: String read FComment write FComment;
    property Decloration: String read FDecloration write FDecloration;
    property Name: String read FName write FName;
  end;

  TctUses = class(TctBase)
  private
    FBelongs2Unit: TctUnit;

    function GetURL: String;


  public
    constructor Create(ABelongs2Unit: TctUnit);

    procedure Sort; override;
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);

    property URL: String read GetURL;
  end;

  TctConst = class(TctBase)
  end;

  TctConsts = class(TctBase)
  private
    FList: TObjectList;
    FBelongs2Unit: TctUnit;
    function GetCount: Integer;
    function GetItems(Index: Integer): TctConst;
    function GetURL: String;

  public
    constructor Create(ABelongs2Unit: TctUnit);
    destructor Destroy; override;

    function Add(AConst: TctConst): Integer;
    procedure Sort; override;
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);

    property Items[Index: Integer]: TctConst read GetItems;
    property Count: Integer read GetCount;
    property URL: String read GetURL;
  end;

  TctVar = class(TctBase)
  public
    procedure Sort; override;
  end;

  TctVars = class(TctBase)
  private
    FList: TObjectList;
    FBelongs2Unit: TctUnit;

    function GetCount: Integer;
    function GetItems(Index: Integer): TctVar;
    function GetURL: String;

  public
    constructor Create(ABelongs2Unit: TctUnit);
    destructor Destroy; override;

    function Add(AVar: TctVar): Integer;
    procedure Sort; override;
    procedure CreateVarsFromDecloration(ADecloration: String; const AComment: String);
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);
    procedure SaveAsDatabase(ADatabase: TIBDatabase; ATransaction: TIBTRansaction);

    property Items[Index: Integer]: TctVar read GetItems;
    property Count: Integer read GetCount;
    property URL: String read GetURL;
  end;

  TctRoutine = class(TctBase)
  end;

  TctRoutines = class(TctBase)
  private
    FList: TObjectList;
    FBelongs2Unit: TctUnit;

    function GetCount: Integer;
    function GetItems(Index: Integer): TctRoutine;
    function GetURL: String;

  public
    constructor Create(ABelongs2Unit: TctUnit);
    destructor Destroy; override;

    function Add(ARoutine: TctRoutine): Integer;
    procedure Sort; override;
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);

    property Items[Index: Integer]: TctRoutine read GetItems;
    property Count: Integer read GetCount;
    property URL: String read GetURL;
  end;

  TctField = class(TctBase)
  private
    FBelongs2Section: TctClassSection;
    FIsProperty: Boolean;
    function GetURL: String;

  public
    constructor Create(ABelongs2Section: TctClassSection; const AName: String = ''; const ADecloration: String = '');

    procedure SaveAsText(S: TStream);

    property Belongs2Section: TctClassSection read FBelongs2Section write FBelongs2Section;
    property IsProperty: Boolean read FIsProperty write FIsProperty;
    property URL: String read GetURL;
  end;

  TctFields = class(TctBase)
  private
    FList: TObjectList;
    FBelongs2ClassSection: TctClassSection;

    function GetItems(Index: Integer): TctField;
    function GetCount: Integer;
    function GetCountOfFields: Integer;
    function GetCountOfProperties: Integer;

  public
    constructor Create(ABelongs2ClassSection: TctClassSection);
    destructor Destroy; override;

    function Add(AField: TctField): Integer;
    procedure SaveAsText(S: TStream; const ASaveFields: Boolean);

    procedure Sort; override;

    property Belongs2ClassSection: TctClassSection read FBelongs2ClassSection;
    property Items[Index: Integer]: TctField read GetItems;
      default;
    property Count: Integer read GetCount;
    property CountOfFields: Integer read GetCountOfFields;
    property CountOfProperties: Integer read GetCountOfProperties;
  end;

  TctMethod = class(TctBase)
  private
    FBelongs2Section: TctClassSection;

  public
    constructor Create(ABelongs2Section: TctClassSection; const AName: String = ''; const ADecloration: String = '');

    procedure SaveAsText(S: TStream);

    property Belongs2Section: TctClassSection read FBelongs2Section write FBelongs2Section;
  end;

  TctMethods = class(TctBase)
  private
    FList: TObjectList;
    FBelongs2ClassSection: TctClassSection;

    function GetItems(Index: Integer): TctMethod;
    function GetCount: Integer;

  public
    constructor Create(ABelongs2ClassSection: TctClassSection);
    destructor Destroy; override;

    function Add(AMethod: TctMethod): Integer;
    procedure SaveAsText(S: TStream);

    procedure Sort; override;

    property Belongs2ClassSection: TctClassSection read FBelongs2ClassSection;
    property Items[Index: Integer]: TctMethod read GetItems;
      default;
    property Count: Integer read GetCount;
  end;

  TctClassSection = class(TctBase)
  private
    FSectionType: TClassSectionType;
    FMethods: TctMethods;
    FFields: TctFields;
    FBelongs2Class: TctClass;

  public
    constructor Create(AType: TClassSectionType; ABelongs2Class: TctClass);
    destructor Destroy; override;

    procedure SaveAsText(S: TStream);
    procedure Sort; override;

    property Belongs2Class: TctClass read FBelongs2Class;
    property SectionType: TClassSectionType read FSectionType write FsectionType;
    property Methods: TctMethods read FMethods;
    property Fields: TctFields read FFields;
  end;

  TctClassSections = class(TctBase)
  private
    FBelongs2Class: TctClass;
    FPrivateSection, FProtectedSection, FPublicSection, FPublishedsection: TctClassSection;
    function GetPropertiesURL: String;
    function GetMethodsURL: String;

  public
    constructor Create(ABelongs2Class: TctClass);
    destructor Destroy; override;

    procedure Add(CS: TctClassSection);
    procedure SaveAsText(S: TStream);
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);

    procedure Sort; override;

    property Belongs2Class: TctClass read FBelongs2Class;
    property PrivateSection: TctClassSection read FPrivateSection write FPrivateSection;
    property ProtectedSection: TctClassSection read FProtectedSection write FProtectedSection;
    property PublicSection: TctClassSection read FPublicSection write FPublicSection;
    property PublishedSection: TctClassSection read FPublishedSection write FPublishedSection;
    property PropertiesURL: String read GetPropertiesURL;
    property MethodsURL: String read GetMethodsURL;
  end;

  TctClass = class(TctBase)
  private
    FParent: TctClass;
    FBelongs2Unit: TctUnit;
    FSections: TctClassSections;
    FParentName: String;
    function GetParentName: String;
    procedure SetParentName(const Value: String);
    function GetURL: String;
    function GetSourceURL: String;

  public
    constructor Create(const AName: String; ABelongs2Unit: TctUnit);
    destructor Destroy; override;

    procedure SaveAsText(S: TStream);
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);

    procedure Sort; override;

    property Parent: TctClass read FParent write FParent;
    property Belongs2Unit: TctUnit read FBelongs2Unit;
    property Sections: TctClasssections read FSections;
    property ParentName: String read GetParentName write SetParentName;
    property URL: String read GetURL;
    property SourceURL: String read GetSourceURL;
  end;

  TctClasses = class(TctBase)
  private
    FList: TObjectList;
    FBelongs2Unit: TctUnit;

    function GetItems(Index: Integer): TctClass;
    function GetURL: String;
    function GetCount: Integer;

  public
    constructor Create(ABelongs2Unit: TctUnit);
    destructor Destroy; override;

    function Add(AClass: TctClass): Integer;
    function Find(const AName: String): TctClass;

    procedure SaveAsText(S: TStream);
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);

    procedure Sort; override;

    property Belongs2Unit: TctUnit read FBelongs2Unit;
    property Items[Index: Integer]: TctClass read GetItems;
      default;
    property URL: String read GetURL;
    property Count: Integer read GetCount;
  end;

  TctUnit = class(TctBase)
  private
    FClasses: TctClasses;
    FVars: TctVars;
    FRoutines: TctRoutines;
    FFileName: String;
    FConsts: TctConsts;
    FUses: TctUses;

    function GetURL: String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure SaveAsText(S: TStream);
    procedure SaveAsHTML(const ASourceDir, AnOutputDir: String);
    procedure SaveAsDatabase(ADatabase: TIBDatabase; ATransaction: TIBTRansaction);

    procedure Sort; override;

    property Classes: TctClasses read FClasses;
    property Vars: TctVars read FVars;
    property Routines: TctRoutines read FRoutines;
    property Consts: TctConsts read FConsts;
    property SectionUses: TctUses read FUses;
    property URL: String read GetURL;
    property FileName: String read FFileName write FFileName;
  end;

  TctUnits = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetItems(Index: Integer): TctUnit;

  public
    constructor Create;
    destructor Destroy; override;

    procedure SaveAsText(S: TStream);
    procedure SaveAsHtml(const ASourceDir, AnOutputDir: String);
    procedure SaveAsDatabase(ADatabase: TIBDatabase; ATransaction: TIBTRansaction);
    function Add(AUnit: TctUnit): Integer;

    procedure Sort;

    property Items[Index: Integer]: TctUnit read GetItems;
    property Count: Integer read GetCount;
  end;

implementation

uses
  IBQuery, Dialogs;

function DoublePercents(const S: String): String;
var
  F: Boolean;
  I: Integer;
begin
  Result := S;
  F := False;
  I := 1;
  while (I <= Length(Result)) do
  begin
    if Result[I] = '"' then
    begin
      F := not F;
      Inc(I);
      continue;
    end;

    if (Result[I] = '%') and F then
    begin
      Insert('%', Result, I);
      Inc(I, 2);
      continue;
    end;

    Inc(I);
  end;
end;

function InsertBRTag(const S: String): String; 
var
  F: Boolean;
  I: Integer;
begin
  Result := S;
  F := True;
  I := 1;

  // the last space we will not touch
  while (I < Length(Result)) do
  begin
    if (Result[I] = ' ') and F then
    begin
      Delete(Result, I, 1);
      Insert('&nbsp;', Result, I);
      Inc(I, 6);
      continue;
    end;

    if Result[I] <> ' ' then
      F := False;

    Inc(I);

    if ((Result[I] = #10) and (Result[I - 1] = #13)) or
      ((Result[I] = #13) and (Result[I - 1] = #10)) then
    begin
      Insert('<br>', Result, I - 1);
      Inc(I, 5);
      F := True;
      continue;
    end;
  end;
end;

function CompareBase(Item1, Item2: Pointer): Integer;
begin
  Assert(Assigned(Item1) and Assigned(Item2));

  if TctBase(Item1).Name > TctBase(Item2).Name then
    Result := 1
  else if TctBase(Item1).Name < TctBase(Item2).Name then
    Result := -1
  else
    Result := 0;
end;

{ TctMethods }

function TctMethods.Add(AMethod: TctMethod): Integer;
begin
  Result := FList.Add(AMethod);
end;

constructor TctMethods.Create;
begin
  inherited Create;
  FBelongs2ClassSection := ABelongs2ClassSection;
  FList := TObjectList.Create;
end;

destructor TctMethods.Destroy;
begin
  inherited;
  FList.Free;
end;

function TctMethods.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TctMethods.GetItems(Index: Integer): TctMethod;
begin
  Result := TctMethod(FList[Index]);
end;

procedure TctMethods.SaveAsText(S: TStream);
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TctMethod(FList[I]).SaveAsText(S);
end;

procedure TctMethods.Sort;
begin
  FList.Sort(CompareBase);
end;

{ TctClass }

constructor TctClass.Create;
begin
  inherited Create;
  FName := AName;
  FBelongs2Unit := ABelongs2Unit;
  FSections := TctClasssections.Create(Self);
end;

destructor TctClass.Destroy;
begin
  inherited;
  FSections.Free;
end;

function TctClass.GetParentName: String;
begin
  if Assigned(FParent) then
    Result := FParent.Name
  else
    Result := FParentName;  
end;

function TctClass.GetSourceURL: String;
begin
  Result := 'class_' + Name + '_source.html';
end;

function TctClass.GetURL: String;
begin
  Result := 'class_' + Name + '.html';
end;

procedure TctClass.SaveAsHTML(const ASourceDir, AnOutputDir: String);
var
  MS: TMemoryStream;
  Input, Output, Source: String;
begin
  with TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'class.html', fmOpenRead) do
  try
    SetLength(Input, Size);
    ReadBuffer(Input[1], Size);
  finally
    Free;
  end;

  Output := Format(DoublePercents(Input), [
    Name,
    Name,
    Sections.PropertiesURL,
    Sections.MethodsURL,
    '',
    SourceURL,
    Belongs2Unit.URL,
    Belongs2Unit.Classes.URL,
    InsertBRTag(Comment)]);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + URL, fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;

  MS := TMemoryStream.Create;
  try
    SaveAsText(MS);
    MS.Seek(0, soFromBeginning);
    SetLength(Source, MS.Size);
    MS.Read(Source[1], MS.Size);
  finally
    MS.Free;
  end;

  Output := Format(DoublePercents(Input), [
    Name,
    '<a href=' + URL + '>Source of ' + Name + '</a>',
    Sections.PropertiesURL,
    Sections.MethodsURL,
    '',
    SourceURL,
    Belongs2Unit.URL,
    Belongs2Unit.Classes.URL,
    '<code>' + InsertBRTag(Source) + '</code>']);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + SourceURL, fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;

  Sections.SaveAsHTML(ASourceDir, AnOutputDir);
end;

procedure TctClass.SaveAsText(S: TStream);
var
  C: String;
begin
  if Comment > '' then
    C := '(*' + Comment + '*)'#13#10
  else
    C := '';
  C := C + '  ' + FName + ' = class(' + ParentName + ')'#13#10;
  S.Write(C[1], Length(C));
  FSections.SaveAsText(S);
  C := '  end;'#13#10#13#10;
  S.Write(C[1], Length(C));
end;


procedure TctClass.SetParentName(const Value: String);
begin
  Assert(not Assigned(FParent));
  FParentName := Value;
end;

procedure TctClass.Sort;
begin
  Sections.Sort;
end;

{ TctClasses }

function TctClasses.Add(AClass: TctClass): Integer;
begin
  Result := FList.Add(AClass);
end;

constructor TctClasses.Create(ABelongs2Unit: TctUnit);
begin
  inherited Create;
  FList := TObjectList.Create;
  FBelongs2Unit := ABelongs2Unit;
end;

destructor TctClasses.Destroy;
begin
  inherited;
  FList.Free;
end;

function TctClasses.Find(const AName: String): TctClass;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FList.Count - 1 do
  begin
    if TctClass(FList[I]).Name = AName then
    begin
      Result := TctClass(FList[I]);
      exit;
    end;
  end;
end;

function TctClasses.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TctClasses.GetItems(Index: Integer): TctClass;
begin
  Result := TctClass(FList[Index]);
end;

function TctClasses.GetURL: String;
begin
  Result := 'unit_' + FBelongs2Unit.Name + '_classes.html';
end;

procedure TctClasses.SaveAsHTML(const ASourceDir, AnOutputDir: String);
var
  Template, Page: TFileStream;
  Input, Output: String;
  S: String;
  I: Integer;
begin
  S := '';
  for I := 0 to Count - 1 do
  begin
    S := S +
      '<a href="' + Items[I].URL + '">' +
      Items[I].Name +
      '</a>' +
      '<br>'#10#13;
  end;

  Template := TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'classes.html', fmOpenRead);
  try
    Page := TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + URL, fmCreate);
    try
      SetLength(Input, Template.Size);
      Template.ReadBuffer(Input[1], Template.Size);
      Output := Format(DoublePercents(Input), [
        Belongs2Unit.Name,
        '<a href=' + Belongs2Unit.URL + '>' + Belongs2Unit.Name + '</a>',
        Belongs2Unit.FileName,
        URL,
        '',
        '',
        '',
        '',
        S,
        '',
        InsertBRTag(Belongs2Unit.Comment)]);
      Page.WriteBuffer(Output[1], Length(Output));
    finally
      Page.Free;
    end;
  finally
    Template.Free;
  end;

  for I := 0 to Count - 1 do
  begin
    Items[I].SaveAsHTML(ASourceDir, AnOutputDir);
  end;
end;


procedure TctClasses.SaveAsText(S: TStream);
var
  I: Integer;
  Ch: array[0..1024] of Char;
begin
  StrPCopy(Ch, 'type'#13#10);
  S.Write(Ch, StrLen(Ch));
  for I := 0 to FList.Count - 1 do
    TctClass(FList[I]).SaveAsText(S);
end;

procedure TctClasses.Sort;
var
  I: Integer;
begin
  FList.Sort(CompareBase);
  for I := 0 to Count - 1 do
    Items[I].Sort;
end;

{ TctUnit }

constructor TctUnit.Create;
begin
  inherited;
  FClasses := TctClasses.Create(Self);
  FVars := TctVars.Create(Self);
  FRoutines := TctRoutines.Create(Self);
  FConsts := TctConsts.Create(Self);
  FUses := TctUses.Create(Self);
end;

destructor TctUnit.Destroy;
begin
  inherited;
  FClasses.Free;
  FVars.Free;
  FRoutines.Free;
  FConsts.Free;
  FUses.Free;
end;

function TctUnit.GetURL: String;
begin
  Result := 'unit_' + Name + '.html';
end;

procedure TctUnit.SaveAsDatabase(ADatabase: TIBDatabase;
  ATransaction: TIBTRansaction);
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Database := ADatabase;
    q.Transaction := ATransaction;

    if not ATransaction.InTransaction then
      ATransaction.StartTransaction;

    q.Close;
    q.SQL.Text := 'SELECT u.id FROM ct_unit u WHERE u.name = :name';
    q.Prepare;
    q.Params.ByName('name').AsString := Name;
    q.ExecQuery;

    if q.RecordCount > 0 then
    begin
      q.Close;
      q.SQL.Text := 'UPDATE ct_unit SET filename = :filename, comment = :comment, source = :source WHERE name = :name';
    end else
    begin
      q.Close;
      q.SQL.Text := 'INSERT INTO ct_unit (name, filename, comment, source) VALUES (:name, :filename, :comment, :source)';
    end;

    q.Prepare;
    q.Params.ByName('name').AsString := Name;
    q.Params.ByName('filename').AsString := FileName;
    q.Params.ByName('comment').AsString := Comment;
    q.Params.ByName('source').AsString := Decloration;
    q.ExecQuery;

    if ATransaction.InTransaction then
      ATransaction.CommitRetaining;
  finally
    q.Free;
  end;

  Vars.SaveAsDatabase(ADatabase, ATransaction);
end;

procedure TctUnit.SaveAsHTML(const ASourceDir, AnOutputDir: String);
var
  Input, Output: String;
begin
  with TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'unit.html', fmOpenRead) do
  try
    SetLength(Input, Size);
    ReadBuffer(Input[1], Size);
  finally
    Free;
  end;

  Output := Format(DoublePercents(Input), [
    Name,
    Name,
    FFileName,
    Classes.URL,
    '',
    Consts.URL,
    Vars.URL,
    Routines.URL,
    InsertBRTag(Comment),
    SectionUses.URL
    ]);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + URL, fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;

  Classes.SaveAsHTML(ASourceDir, AnOutputDir);
  Vars.SaveAsHTML(ASourceDir, AnOutputDir);
  Routines.SaveAsHTML(ASourceDir, AnOutputDir);
  Consts.SaveAsHTML(ASourceDir, AnOutputDir);
  FUses.SaveAsHTML(ASourceDir, AnOutputDir);
end;

procedure TctUnit.SaveAsText;
var
  Ch: array[0..1024] of Char;
begin
  StrPCopy(Ch, 'unit ' + FName + ';'#13#10#13#10'interface'#13#10#13#10);
  S.Write(Ch, StrLen(Ch));
  FClasses.SaveAsText(S);
  StrPCopy(Ch, 'implementation'#13#10#13#10'end.'#13#10#13#10);
  S.Write(Ch, StrLen(Ch));
end;

procedure TctUnit.Sort;
begin
  FClasses.Sort;
  FVars.Sort;
  FRoutines.Sort;
  FConsts.Sort;
  FUses.Sort;
end;

{ TctMethod }

constructor TctMethod.Create;
begin
  inherited Create;
  FBelongs2Section := ABelongs2Section;
  FName := AName;
  FDecloration := ADecloration;  
end;

procedure TctMethod.SaveAsText(S: TStream);
var
  Ch: array[0..1024] of Char;
begin
  StrPCopy(Ch, '    ' + FDecloration + #13#10);
  S.Write(Ch, StrLen(Ch));
  if Pos('destructor ', FDecloration) > 0 then
  begin
    StrPCopy(Ch, #13#10);
    S.Write(Ch, StrLen(Ch));
  end;
end;

{ TctClassSection }

constructor TctClassSection.Create(AType: TClassSectionType;
  ABelongs2Class: TctClass);
begin
  inherited Create;
  FBelongs2Class := ABelongs2Class;
  FSectionType := AType;
  FMethods := TctMethods.Create(Self);
  FFields := TctFields.Create(Self);
end;

destructor TctClassSection.Destroy;
begin
  inherited;
  FMethods.Free;
  FFields.Free;
end;

procedure TctClassSection.SaveAsText(S: TStream);
var
  Ch: array[0..1024] of Char;
begin
  if (FMethods.Count = 0) and (FFields.Count = 0) then
    exit;

  case FSectionType of
    cstPrivate: StrPCopy(Ch, '  private');
    cstProtected: StrPCopy(Ch, #13#10'  protected');
    cstPublic: StrPCopy(Ch, #13#10'  public');
    cstPublished: StrPCopy(Ch, #13#10'  published');
  end;
  StrCat(Ch, #13#10);
  S.Write(Ch, StrLen(Ch));

  StrPCopy(Ch, #13#10);
  FFields.SaveAsText(S, True);
  if (FFields.CountOfFields > 0) and (FMethods.Count > 0) then
  begin
    S.Write(Ch, StrLen(Ch));
  end;
  FMethods.SaveAsText(S);
  if ((FFields.CountOfFields > 0) or (FMethods.Count > 0)) and (FFields.CountOfProperties > 0) then
  begin
    S.Write(Ch, StrLen(Ch));
  end;
  FFields.SaveAsText(S, False);
end;

procedure TctClassSection.Sort;
begin
  FFields.Sort;
  FMethods.Sort;
end;

{ TctClassSections }

procedure TctClassSections.Add(CS: TctClassSection);
begin
  case CS.SectionType of
    cstPrivate: FPrivateSection := CS;
    cstProtected: FProtectedSection := CS;
    cstPublic: FPublicSection := CS;
    cstPublished: FPublishedSection := CS;
  end;
end;

constructor TctClassSections.Create(ABelongs2Class: TctClass);
begin
  inherited Create;
  FBelongs2Class := ABelongs2Class;
  FPrivateSection := TctClassSection.Create(cstPrivate, ABelongs2Class);
  FProtectedSection := TctClassSection.Create(cstProtected, ABelongs2Class);
  FPublicSection := TctClassSection.Create(cstPublic, ABelongs2Class);
  FPublishedSection := TctClassSection.Create(cstPublished, ABelongs2Class);
end;

destructor TctClassSections.Destroy;
begin
  inherited;
  if Assigned(FPrivateSection) then FPrivateSection.Free;
  if Assigned(FProtectedSection) then FProtectedSection.Free;
  if Assigned(FPublicSection) then FPublicSection.Free;
  if Assigned(FPublishedSection) then FPublishedSection.Free;
end;

function TctClassSections.GetMethodsURL: String;
begin
  Result := 'class_' + Belongs2Class.Name + '_methods.html';
end;

function TctClassSections.GetPropertiesURL: String;
begin
  Result := 'class_' + Belongs2Class.Name + '_properties.html';
end;

procedure TctClassSections.SaveAsHTML(const ASourceDir,
  AnOutputDir: String);
var
  Template, Page: TFileStream;
  I: Integer;
  Output, Input, S, S2: String;
begin
  S := '';
  S2 := '';

  for I := 0 to FPublicSection.Fields.Count - 1 do
  begin
    S := S + '<a href=#pblc' + IntToStr(I) + '>' + FPublicSection.Fields[I].Name + '</a><br>' + #13#10;
    S2 := S2 + '<a name=pblc' + IntToStr(I) + '>' + FPublicSection.Fields[I].Name + '</a><br>' + #13#10 +
      FPublicSection.Fields[I].Decloration + '<br><p>'#13#10 + InsertBRTag(FPublicSection.Fields[I].Comment) + '<br><p>'#13#10;
  end;

  for I := 0 to FPublishedSection.Fields.Count - 1 do
  begin
    S := S + '<a href=#pblsh' + IntToStr(I) + '>' + FPublishedSection.Fields[I].Name + '</a><br>' + #13#10;
    S2 := S2 + '<a name=pblsh' + IntToStr(I) + '>' + FPublishedSection.Fields[I].Name + '</a><br>' + #13#10 +
      FPublishedSection.Fields[I].Decloration + '<br><p>'#13#10 + InsertBRTag(FPublishedSection.Fields[I].Comment) + '<br><p>'#13#10;
  end;

  Template := TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'properties.html', fmOpenRead);
  try
    SetLength(Input, Template.Size);
    Template.ReadBuffer(Input[1], Template.Size);

    Output := Format(DoublePercents(Input), [
      Belongs2Class.Name,
      '<a href=' + Belongs2Class.URL + '>' + Belongs2Class.Name + '</a>',
      PropertiesURL,
      MethodsURL,
      '',
      Belongs2Class.SourceURL,
      Belongs2Class.Belongs2Unit.URL,
      Belongs2Class.Belongs2Unit.Classes.URL,
      S,
      S2]);

    Page := TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + PropertiesURL, fmCreate);
    try
      Page.WriteBuffer(Output[1], Length(Output));
    finally
      Page.Free;
    end;
  finally
    Template.Free;
  end;

  // methods
  S := '';
  S2 := '';

  for I := 0 to FPublicSection.Methods.Count - 1 do
  begin
    S := S + '<a href=#pblcm' + IntToStr(I) + '>' + FPublicSection.Methods[I].Name + '</a><br>' + #13#10;
    S2 := S2 + '<a name=pblcm' + IntToStr(I) + '>' + FPublicSection.Methods[I].Name + '</a><br>' + #13#10 +
      FPublicSection.Methods[I].Decloration + '<br><p>'#13#10 + InsertBRTag(FPublicSection.Methods[I].Comment) + '<br><p>'#13#10;
  end;

  Template := TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'methods.html', fmOpenRead);
  try
    SetLength(Input, Template.Size);
    Template.ReadBuffer(Input[1], Template.Size);

    Output := Format(DoublePercents(Input), [
      Belongs2Class.Name,
      '<a href=' + Belongs2Class.URL + '>' + Belongs2Class.Name + '</a>',
      PropertiesURL,
      MethodsURL,
      '',
      Belongs2Class.SourceURL,
      Belongs2Class.Belongs2Unit.URL,
      Belongs2Class.Belongs2Unit.Classes.URL,
      S,
      S2]);

    Page := TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + MethodsURL, fmCreate);
    try
      Page.WriteBuffer(Output[1], Length(Output));
    finally
      Page.Free;
    end;
  finally
    Template.Free;
  end;
end;

procedure TctClassSections.SaveAsText(S: TStream);
begin
  if Assigned(FPrivateSection) then FPrivateSection.SaveAsText(S);
  if Assigned(FProtectedSection) then FProtectedSection.SaveAsText(S);
  if Assigned(FPublicSection) then FPublicSection.SaveAsText(S);
  if Assigned(FPublishedSection) then FPublishedSection.SaveAsText(S);
end;

procedure TctClassSections.Sort;
begin
  FPublishedSection.Sort;
  FPublicSection.Sort;
  FProtectedSection.Sort;
  FPrivateSection.Sort;
end;

{ TctField }

constructor TctField.Create(ABelongs2Section: TctClassSection; const AName,
  ADecloration: String);
begin
  inherited Create;
  FBelongs2Section := ABelongs2Section;
  FName := AName;
  FDecloration := ADecloration;
end;

function TctField.GetURL: String;
begin
  Result := 'class_' + Belongs2Section.Belongs2Class.Name + '_prop_' + Name + '.html';
end;

procedure TctField.SaveAsText(S: TStream);
var
  Ch: array[0..1024] of Char;
begin
  StrPCopy(Ch, '    ' + FDecloration + #13#10);
  S.Write(Ch, StrLen(Ch));
end;

{ TctFields }

function TctFields.Add(AField: TctField): Integer;
begin
  Result := FList.Add(AField);
end;

constructor TctFields.Create(ABelongs2ClassSection: TctClassSection);
begin
  inherited Create;
  FBelongs2ClassSection := ABelongs2ClassSection;
  FList := TObjectList.Create;
end;

destructor TctFields.Destroy;
begin
  inherited;
  FList.Free;
end;

function TctFields.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TctFields.GetCountOfFields: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
  begin
    if not TctField(Flist[I]).IsProperty then
      Result := Result + 1;
  end;
end;

function TctFields.GetCountOfProperties: Integer;
begin
  Result := Count - CountOfFields;
end;

function TctFields.GetItems(Index: Integer): TctField;
begin
  Result := TctField(FList[Index]);
end;

procedure TctFields.SaveAsText;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
  begin
    if TctField(FList[I]).IsProperty xor ASaveFields then
      TctField(FList[I]).SaveAsText(S);
  end;
end;

procedure TctFields.Sort;
begin
  FList.Sort(CompareBase);
end;

{ TctUnits }

function TctUnits.Add(AUnit: TctUnit): Integer;
begin
  Result := FList.Add(AUnit);
end;

constructor TctUnits.Create;
begin
  inherited Create;
  FList := TObjectList.Create;
end;

destructor TctUnits.Destroy;
begin
  inherited;
  FList.Free;
end;

function TctUnits.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TctUnits.GetItems(Index: Integer): TctUnit;
begin
  Result := TctUnit(FList[Index]);
end;

procedure TctUnits.SaveAsDatabase(ADatabase: TIBDatabase;
  ATransaction: TIBTRansaction);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].SaveAsDatabase(ADatabase, ATransaction);
end;

procedure TctUnits.SaveAsHtml(const ASourceDir, AnOutputDir: String);
var
  Input, Output: String;
  S: String;
  I: Integer;
begin
  S := '';
  for I := 0 to Count - 1 do
  begin
    S := S +
      '<a href="' + Items[I].URL + '">' +
      Items[I].Name +
      '</a>' +
      '<br>'#10#13;
  end;

  with TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'units.html', fmOpenRead) do
  try
    SetLength(Input, Size);
    ReadBuffer(Input[1], Size);
  finally
    Free;
  end;

  Output := Format(DoublePercents(Input), ['Units', 'Units', S]);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + 'units.html', fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;

  for I := 0 to Count - 1 do
    Items[I].SaveAsHTML(ASourceDir, AnOutputDir);
end;

procedure TctUnits.SaveAsText;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Items[I].SaveAsText(S);
  end;
end;

procedure TctUnits.Sort;
var
  I: Integer;
begin
  FList.Sort(CompareBase);
  for I := 0 to Count - 1 do
    Items[I].Sort;
end;

{ TctVars }

function TctVars.Add(AVar: TctVar): Integer;
begin
  Result := FList.Add(AVar);
end;

constructor TctVars.Create;
begin
  inherited Create;
  FBelongs2Unit := ABelongs2Unit;
  FList := TObjectList.Create;
end;

procedure TctVars.CreateVarsFromDecloration(ADecloration: String; const AComment: String);
var
  E, I, K: Integer;
  Vr: array[1..200] of TctVar;
begin
  I := 0;
  E := Pos(',', ADecloration);
  while E > 0 do
  begin
    Inc(I);
    Vr[I] := TctVar.Create;
    Vr[I].Name := Copy(ADecloration, 1, E - 1);
    Delete(ADecloration, 1, E);
    E := Pos(',', ADecloration);
  end;

  Inc(I);
  Vr[I] := TctVar.Create;
  Vr[I].Name := Copy(ADecloration, 1, Pos(':', ADecloration) - 1);

  for K := 1 to I do
  begin
    Vr[K].Decloration := Vr[K].Name + ': ' + Copy(ADecloration, Pos(':', ADecloration) + 1, 1024);
    Vr[K].Comment := AComment;
    Add(Vr[K]);
  end;
end;

destructor TctVars.Destroy;
begin
  inherited;
  FList.Free;
end;

function TctVars.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TctVars.GetItems(Index: Integer): TctVar;
begin
  Result := TctVar(FList[Index]);
end;

function TctVars.GetURL: String;
begin
  Result := 'unit_' + FBelongs2Unit.Name + '_vars.html';
end;

procedure TctVars.SaveAsDatabase(ADatabase: TIBDatabase;
  ATransaction: TIBTRansaction);
var
  q: TIBSQL;
  UK, I: Integer;
begin
  q := TIBSQL.Create(nil);
  try
    q.Database := ADatabase;
    q.Transaction := ATransaction;

    if not ATransaction.InTransaction then
      ATransaction.StartTransaction;

    q.Close;
    q.SQL.Text := 'SELECT u.id FROM ct_unit u WHERE u.name = :name';
    q.Prepare;
    q.Params.ByName('name').AsString := FBelongs2Unit.Name;
    q.ExecQuery;

    UK := q.Fields[0].AsInteger;

    for I := 0 to Count - 1 do
    begin
      if Length(Items[I].Name) > 52 then
        ShowMessage(Items[I].Name);

      q.Close;
      q.SQL.Text := 'SELECT * FROM ct_var v WHERE v.unitkey = :unitkey AND v.name = :name';
      q.Prepare;
      q.Params.ByName('unitkey').AsInteger := UK;
      q.Params.ByName('name').AsString := Items[I].Name;
      q.ExecQuery;

      if q.RecordCount > 0 then
      begin
        q.Close;
        q.SQL.Text := 'UPDATE ct_var SET decloration = :decloration, comment = :comment WHERE unitkey = :unitkey AND name = :name';
      end else
      begin
        q.Close;
        q.SQL.Text := 'INSERT INTO ct_var (unitkey, name, decloration, comment) VALUES (:unitkey, :name, :decloration, :comment)';
      end;

      try
        q.Prepare;
        q.Params.ByName('unitkey').AsInteger := UK;
        q.Params.ByName('name').AsString := Copy(Items[I].Name, 1, 52);
        q.Params.ByName('decloration').AsString := Items[I].Decloration;
        q.Params.ByName('comment').AsString := Items[I].Comment;
        q.ExecQuery;
      except
        showmessage('2');
      end;
    end;

    if ATransaction.InTransaction then
      ATransaction.CommitRetaining;
  finally
    q.Free;
  end;
end;

procedure TctVars.SaveAsHTML(const ASourceDir, AnOutputDir: String);
var
  Input, Output, S: String;
  I: Integer;
begin
  S := '<code>';
  for I := 0 to Count - 1 do
  begin
    if Items[I].Comment > '' then
      S := S + '<i>' + Items[I].Comment + '</i>' + '<br>'#13#10;
    S := S + Items[I].Decloration + '<br>'#13#10;
  end;
  S := S + '<code>';

  with TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'vars.html', fmOpenRead) do
  try
    SetLength(Input, Size);
    ReadBuffer(Input[1], Size);
  finally
    Free;
  end;

  Output := Format(DoublePercents(Input), [
    FBelongs2Unit.Name,
    FBelongs2Unit.Name,
    FBelongs2Unit.FileName,
    FBelongs2Unit.Classes.URL,
    '',
    FBelongs2Unit.Consts.URL,
    FBelongs2Unit.Vars.URL,
    FBelongs2Unit.Routines.URL,
    S,
    FBelongs2Unit.SectionUses.URL
    ]);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + URL, fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;
end;

procedure TctVars.Sort;
begin
  FList.Sort(CompareBase);
end;

{ TctRoutines }

function TctRoutines.Add(ARoutine: TctRoutine): Integer;
begin
  Result := FList.Add(ARoutine);
end;

constructor TctRoutines.Create(ABelongs2Unit: TctUnit);
begin
  inherited Create;
  FBelongs2Unit := ABelongs2Unit;
  FList := TObjectList.Create;
end;

destructor TctRoutines.Destroy;
begin
  inherited;
  FList.Free;
end;

function TctRoutines.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TctRoutines.GetItems(Index: Integer): TctRoutine;
begin
  Result := TctRoutine(Flist[Index]);
end;

function TctRoutines.GetURL: String;
begin
  Result := 'unit_' + FBelongs2Unit.Name + '_routines.html';
end;

procedure TctRoutines.SaveAsHTML(const ASourceDir, AnOutputDir: String);
var
  Input, Output, S: String;
  I: Integer;
begin
  S := '<code>';
  for I := 0 to Count - 1 do
  begin
    if Items[I].Comment > '' then
      S := S + '<i>' + Items[I].Comment + '</i>' + '<br>'#13#10;
    S := S + Items[I].Decloration + '<br>'#13#10;
  end;
  S := S + '<code>';

  with TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'routines.html', fmOpenRead) do
  try
    SetLength(Input, Size);
    ReadBuffer(Input[1], Size);
  finally
    Free;
  end;

  Output := Format(DoublePercents(Input), [
    FBelongs2Unit.Name,
    FBelongs2Unit.Name,
    FBelongs2Unit.FileName,
    FBelongs2Unit.Classes.URL,
    '',
    FBelongs2Unit.Consts.URL,
    FBelongs2Unit.Vars.URL,
    FBelongs2Unit.Routines.URL,
    S,
    FBelongs2Unit.SectionUses.URL
    ]);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + URL, fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;
end;

procedure TctRoutines.Sort;
begin
  FList.Sort(CompareBase);
end;

{ TctConsts }

function TctConsts.Add(AConst: TctConst): Integer;
begin
  Result := FList.Add(AConst);
end;

constructor TctConsts.Create(ABelongs2Unit: TctUnit);
begin
  inherited Create;
  FList := TObjectList.Create;
  FBelongs2Unit := ABelongs2Unit;
end;

destructor TctConsts.Destroy;
begin
  inherited;
  FList.Free;
end;

function TctConsts.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TctConsts.GetItems(Index: Integer): TctConst;
begin
  Result := FList[Index] as TctConst;
end;

function TctConsts.GetURL: String;
begin
  Result := 'unit_' + FBelongs2Unit.Name + '_const.html';
end;

procedure TctConsts.SaveAsHTML(const ASourceDir, AnOutputDir: String);
var
  Input, Output, S: String;
  I: Integer;
begin
  S := '<code>';
  for I := 0 to Count - 1 do
  begin
    if Items[I].Comment > '' then
      S := S + '<i>' + Items[I].Comment + '</i>' + '<br>'#13#10;
    S := S + Items[I].Decloration + '<br>'#13#10;
  end;
  S := S + '<code>';

  with TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'consts.html', fmOpenRead) do
  try
    SetLength(Input, Size);
    ReadBuffer(Input[1], Size);
  finally
    Free;
  end;

  Output := Format(DoublePercents(Input), [
    FBelongs2Unit.Name,
    FBelongs2Unit.Name,
    FBelongs2Unit.FileName,
    FBelongs2Unit.Classes.URL,
    '',
    FBelongs2Unit.Consts.URL,
    FBelongs2Unit.Vars.URL,
    FBelongs2Unit.Routines.URL,
    S,
    FBelongs2Unit.SectionUses.URL
    ]);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + URL, fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;
end;

procedure TctConsts.Sort;
begin
  FList.Sort(CompareBase);
end;

{ TctUses }

constructor TctUses.Create(ABelongs2Unit: TctUnit);
begin
  inherited Create;
  FBelongs2Unit := ABelongs2Unit;
end;

function TctUses.GetURL: String;
begin
  Result := 'unit_' + FBelongs2Unit.Name + '_uses.html';
end;

procedure TctUses.SaveAsHTML(const ASourceDir, AnOutputDir: String);
var
  Input, Output, S: String;
begin
  S := '<code>' + FDecloration + '</code>';

  with TFileStream.Create(IncludeTrailingBackslash(ASourceDir) + 'uses.html', fmOpenRead) do
  try
    SetLength(Input, Size);
    ReadBuffer(Input[1], Size);
  finally
    Free;
  end;

  Output := Format(DoublePercents(Input), [
    FBelongs2Unit.Name,
    FBelongs2Unit.Name,
    FBelongs2Unit.FileName,
    FBelongs2Unit.Classes.URL,
    '',
    FBelongs2Unit.Consts.URL,
    FBelongs2Unit.Vars.URL,
    FBelongs2Unit.Routines.URL,
    S,
    FBelongs2Unit.SectionUses.URL
    ]);

  with TFileStream.Create(IncludeTrailingBackslash(AnOutputDir) + URL, fmCreate) do
  try
    WriteBuffer(Output[1], Length(Output));
  finally
    Free;
  end;
end;


procedure TctUses.Sort;
begin
  //...
end;

{ TctVar }

procedure TctVar.Sort;
begin
  // nothing to sort
end;

end.
