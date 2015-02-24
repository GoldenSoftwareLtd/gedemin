unit flt_SQLProposal;

interface

uses
  SysUtils, Classes, Windows, gdcBaseInterface, IBSQL, at_classes,
  Contnrs, flt_i_SQLProposal;

type
  TProceduresFields = class;

  TProcedures = class(TObject)
  protected
    FList: TObjectList;

    procedure FillObjectList;
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;

    function ByRelationName(const ARelationName: String): TProceduresFields;
  end;

  TProceduresFields = class(TObject)
  protected
    FRelationName: String;
    FFields: TStrings;

    procedure FillFields(ARelationName: String);
  public
    constructor Create(AOwner: TProcedures);
    destructor Destroy; override;
    property RelationName: String read FRelationName;
    property Fields: TStrings read FFields;
  end;

type
  TSQLProposal = class(TObject, ISQLProposal)
  protected
    FInsertList: TStrings;
    FItemList: TStrings;
    FFieldItemList: TStrings;
    FFieldInsertList: TStrings;
    FProcedures: TProcedures;

    function GetInsertList: TStrings;
    function GetItemList: TStrings;
    function GetFieldItemList: TStrings;
    function GetFieldInsertList: TStrings;

    procedure FillItemList;
    procedure FillInsertList(SL: TStrings; Field: Boolean = False);
    procedure FillFieldItem(const atRelation: TatRelation);
    function FindTable(const Str: String; const SQL: TStrings): String;
  private
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    procedure PrepareSQL(Alias: String; const SQL: TStrings);
    function GetStatement(var Str: String; Pos: Integer): String;

    property FieldItemList: TStrings read GetFieldItemList;
    property FieldInsertList: TStrings read GetFieldInsertList;
    property ItemList: TStrings read GetItemList;
    property InsertList: TStrings read GetInsertList;
  end;

  function TrimName(S: String): string;
  function StringListSortCompare(List: TStringList; Index1, Index2: Integer): Integer;

var
  SQLProposalObject: TSQLProposal;

implementation

const
  Letters = '1234567890$_qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';

  cTable = #1#240#81#81'table'#2#9;
  cView = #1#103#100#238'view'#2#9;
  cProcedure = #1#31#189#39'procedure'#2#9;
  cField = #1#103#100#238'field'#2#9;

{ TSQLProposal }

constructor TSQLProposal.Create(AOwner: TComponent);
begin
  if not Assigned(SQLProposal) then
  begin
    inherited Create;

    FItemList := TStringList.Create;
    FInsertList := TStringList.Create;
    FFieldItemList := TStringList.Create;
    FFieldInsertList := TStringList.Create;
    FProcedures := TProcedures.Create(Self);
    if Assigned(atDataBase) then
      FillItemList;

    SQLProposal := Self;
  end else
    raise Exception.Create(
      'Может быть создан только один экземпляр'#10#13 +
      'класса TSQLProposal');
end;

destructor TSQLProposal.Destroy;
begin
  FItemList.Free;
  FInsertList.Free;
  FFieldItemList.Free;
  FFieldInsertList.Free;
  FProcedures.Free;
  inherited;
  SQLProposal := nil;
end;

procedure TSQLProposal.FillItemList;
var
  Str: String;
  I: Integer;
begin
  FItemList.Clear;

  for I := 0 to atDataBase.Relations.Count - 1 do
  begin
    if atDataBase.Relations[I].RelationType = rtTable then
    begin
      Str := cTable + atDataBase.Relations[I].RelationName + #9;
      if ItemList.IndexOf(Str) = - 1 then
        ItemList.Add(Str);
    end else
    begin
      Str := cView + atDataBase.Relations[I].RelationName + #9;
      if ItemList.IndexOf(Str) = - 1 then
        ItemList.Add(Str);
    end;
  end;

  for I := 0 to FProcedures.FList.Count - 1 do
  begin
    Str := cProcedure + (FProcedures.FList[I] as TProceduresFields).RelationName + #9;
    if ItemList.IndexOf(Str) = - 1 then
      ItemList.Add(Str);
  end;

  TStringList(FItemList).CustomSort(StringListSortCompare);
  FillInsertList(FItemList);
end;

procedure TSQLProposal.FillInsertList(SL: TStrings; Field: Boolean = False);
var
  I: Integer;
  S: string;
begin
  if Field then
  begin
    FFieldInsertList.Clear;
    for I := 0 to Sl.Count - 1 do
    begin
      S := Sl[I];
      S := TrimName(S);
      FFieldInsertList.Add(S);
    end;
  end else
  begin
    FInsertList.Clear;
    for I := 0 to Sl.Count - 1 do
    begin
      S := Sl[I];
      S := TrimName(S);
      FInsertList.Add(S);
    end;
  end;
end;

function TSQLProposal.GetInsertList: TStrings;
begin
  Result := FInsertList;
end;

function TSQLProposal.GetItemList: TStrings;
begin
  Result := FItemList;
end;

function TrimName(S: String): string;
var
  P: Integer;
begin
  Result := S;
  P := Pos(#9, Result);
  if P > 1 then
  begin
    Result := Copy(Result, P + 1, Length(Result) - P);
    P := Pos(#9, Result);
    if P > 1 then
      Result := Copy(Result, 1, P - 1);
  end;

  P := Pos('(', Result);
  if P > 1 then
    Result := Copy(Result, 1, P - 1);
end;

function StringListSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  S1, S2: string;
begin
  S1 := TrimName(List[Index1]);
  S2 := TrimName(List[Index2]);

  S1 := TrimName(S1);
  S2 := TrimName(S2);
  Result := AnsiCompareText(S1, S2);
end;

function TSQLProposal.GetStatement(var Str: String; Pos: Integer): String;
var
  BeginPos, EndPos: Integer;
  CB: Integer;
begin
  Result := '';

  BeginPos := Pos;
  if BeginPos > Length(Str) then
    BeginPos := Length(Str);
  EndPos := BeginPos;
  CB := 0;
  while (BeginPos > 1) and ((System.Pos(Str[BeginPos - 1], Letters + '.)') > 0) or
    ((System.Pos(Str[BeginPos - 1], Letters + '.') = 0) and (CB > 0))) do
  begin
    if Str[BeginPos - 1] = ')' then
      Inc(CB);
    if Str[BeginPos] = '(' then
      Dec(CB);
    Dec(BeginPos);
  end;

  while (EndPos > 1) and (System.Pos(Str[EndPos], Letters) > 0) do
    Dec(EndPos);
  if BeginPos < EndPos then
    Result := System.Copy(Str, BeginPos, EndPos - BeginPos)
  else
    Result := '';
end;

function TSQLProposal.GetFieldItemList: TStrings;
begin
  Result := FFieldItemList;
end;

function TSQLProposal.GetFieldInsertList: TStrings;
begin
  Result := FFieldInsertList;
end;

procedure TSQLProposal.PrepareSQL(Alias: String;
  const SQL: TStrings);
var
  atRelation: TatRelation;
  aRelation: TProceduresFields;
  I: Integer;
  Str: String;
begin
// Проверяем что пришло, если таблица, то возвращаем её поля.
// Если алиас, то ищем по нему таблицу. Выводим её поля.
// Если ошибочно, то не заполняем.
  FFieldItemList.Clear;

  if Alias[Length(Alias)] = '.' then
    Alias := System.Copy(Alias, 0, Length(Alias) - 1);

  Alias := AnsiUpperCase(Alias);

  if Assigned(atDataBase) then
  begin
    atRelation := atDataBase.Relations.ByRelationName(Alias);

    if Assigned(atRelation) then
      FillFieldItem(atRelation)
    else begin
      Alias := FindTable(Alias, SQL);
      atRelation := atDataBase.Relations.ByRelationName(Alias);
      if Assigned(atRelation) then
        FillFieldItem(atRelation)
      else begin
        aRelation := FProcedures.ByRelationName(Alias);
        if Assigned(aRelation) then
        begin
          for I := 0 to aRelation.Fields.Count - 1 do
          begin
           str := cField + aRelation.Fields[I] + #9;
           if FFieldItemList.IndexOf(Str) = - 1 then
             FFieldItemList.Add(Str);
          end;
          TStringList(FFieldItemList).CustomSort(StringListSortCompare);
          FillInsertList(FFieldItemList, True);
        end;
      end;
    end;
  end;
end;

function TSQLProposal.FindTable(const Str: String;
  const SQL: TStrings): String;
var
  BeginPos, EndPos: Integer;
begin
  Result := Str;

  BeginPos := System.Pos(' ' + Str + ' ', AnsiUpperCase(SQL.Text));
  if BeginPos > 0 then
  begin
    while SQL.Text[BeginPos - 1] = ' ' do
      Dec(BeginPos);

    EndPos := BeginPos + 1;
    while ((SQL.Text[BeginPos - 1] <> ' ') and (SQL.Text[BeginPos - 1] <> #$A)) do
      Dec(BeginPos);

    Result := System.Copy(SQL.Text, BeginPos, EndPos - BeginPos);
    exit;
  end;

  BeginPos := System.Pos(' ' + Str + #$D, AnsiUpperCase(SQL.Text));
  if BeginPos > 0 then
  begin
    while SQL.Text[BeginPos - 1] = ' ' do
      Dec(BeginPos);

    EndPos := BeginPos +1;
    while ((SQL.Text[BeginPos - 1] <> ' ') and (SQL.Text[BeginPos - 1] <> #$A)) do
      Dec(BeginPos);

    Result := System.Copy(SQL.Text, BeginPos, EndPos - BeginPos);
    exit;
  end;
end;

procedure TSQLProposal.FillFieldItem(const atRelation: TatRelation);
var
  I: Integer;
  str: String;
begin
  for I := 0 to atRelation.RelationFields.Count - 1 do
  begin
    str := cField + atRelation.RelationFields[I].FieldName + #9;
    if FFieldItemList.IndexOf(Str) = - 1 then
     FFieldItemList.Add(Str);
  end;
  TStringList(FFieldItemList).CustomSort(StringListSortCompare);
  FillInsertList(FFieldItemList, True);
end;

function TSQLProposal._AddRef: Integer;
begin
  Result := 0;
end;

function TSQLProposal._Release: Integer;
begin
  Result := 0;
end;

function TSQLProposal.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := 0;
end;

{ TProcedures }

function TProcedures.ByRelationName(const ARelationName: String): TProceduresFields;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FList.Count - 1 do
    if AnsiCompareText((FList[I] as TProceduresFields).RelationName, ARelationName) = 0 then
    begin
      Result := FList[I] as TProceduresFields;
      break;
    end;
end;

constructor TProcedures.Create(AOwner: TObject);
begin
  inherited Create;
  FList := TObjectList.Create;
  FillObjectList;
end;

destructor TProcedures.Destroy;
begin
  FList.Free;

  inherited;
end;

procedure TProcedures.FillObjectList;
var
  FSQL: TIBSQL;
  aRelation: TProceduresFields;
begin
  FSQL := TIBSQL.Create(nil);
  try
    FSQL.Transaction := gdcBaseManager.ReadTransaction;
    FSQL.SQL.Text := 'SELECT RDB$PROCEDURE_NAME AS NAME FROM RDB$PROCEDURES'#13#10 +
      ' ORDER BY RDB$PROCEDURE_NAME ';
    FSQL.ExecQuery;
    while not FSQL.Eof do
    begin
      aRelation := TProceduresFields.Create(Self);
      aRelation.FillFields(FSQL.FieldByName('NAME').AsTrimString);
      FList.Add(aRelation);
      FSQL.Next;
    end;
  finally
    FSQL.Free;
  end;
end;

{ TProceduresFields }

constructor TProceduresFields.Create(AOwner: TProcedures);
begin
  inherited Create;
  FFields := TStringList.Create;
end;

destructor TProceduresFields.Destroy;
begin
  FFields.Free;

  inherited;
end;

procedure TProceduresFields.FillFields(ARelationName: String);
var
  FSQL: TIBSQL;
begin
  FRelationName := Trim(ARelationName);

  FSQL := TIBSQL.Create(nil);
  try
    FSQL.Transaction := gdcBaseManager.ReadTransaction;
    FSQL.SQL.Text :=
      ' SELECT PR.RDB$PARAMETER_NAME AS NAME '#13#10 +
      ' FROM RDB$PROCEDURE_PARAMETERS PR '#13#10 +
      ' WHERE PR.RDB$PROCEDURE_NAME = :PN '#13#10 +
      '   AND PR.RDB$PARAMETER_TYPE = 1 '#13#10 +
      ' ORDER BY PR.RDB$PARAMETER_NUMBER ';
    FSQL.ParamByName('PN').AsString := FRelationName;
    FSQL.ExecQuery;
    while not FSQL.Eof do
    begin
      FFields.Add(FSQL.FieldByName('NAME').AsTrimString);
      FSQL.Next;
    end;
  finally
    FSQL.Free;
  end;
end;

end.
