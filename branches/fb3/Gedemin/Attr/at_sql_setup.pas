
{++

  Copyright (c) 2001-2013 by Golden Software of Belarus

  Module

    at_sql_setup.pas

  Abstract

    Delphi non-visual component - part of Gedemin project.
    Prepares sql objects - adds attribute information.

  Author

    Romanovski Denis    (31.12.2001)

  Revisions history

    1.0    Denis    31.12.2001    Initial version.

--}

unit at_sql_setup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Contnrs,
  Db, IBSQL, IBHeader, IBCustomDataSet, IBUpdateSQL, IBDatabase, IBQuery, 
  at_Classes, at_sql_parser, gdcBaseInterface;

const
{As-Наименование поля формируется из S$ + FieldName}
  cstSetPrefix = 'S$'; //Префикс для присоедиенных полей из таблиц множеств
  cstSetAlias  = 'GD$ST'; //Алиас для таблиц множеств

type
  TatSQLSetup = class;
  TatIgnoryType = (itFull, itReferences, itFields);
  TsqlSetupState = (ssPrepared, ssUnprepared);

  TatIgnore = class(TCollectionItem)
  private
    FLink: TComponent;
    FRelationName: String;
    FAliasName: String;
    FIgnoryType: TatIgnoryType;

  protected
    function GetDisplayName: string; override;

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

  published
    property Link: TComponent read FLink write FLink;
    property RelationName: String read FRelationName write FRelationName;
    property AliasName: String read FAliasName write FAliasName;
    property IgnoryType: TatIgnoryType read FIgnoryType write FIgnoryType;
  end;


  TatIgnores = class(TCollection)
  private
    FSQLSetup: TatSQLSetup;

    function GetIgnore(Index: Integer): TatIgnore;
    procedure SetIgnore(Index: Integer; Value: TatIgnore);

  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create(AnSQLSetup: TatSQLSetup);
    destructor Destroy; override;

    function  Add: TatIgnore;

    function AddAliasName(const AnAliasName: String): TatIgnore;

    property Items[Index: Integer]: TatIgnore read GetIgnore write SetIgnore; default;

  end;

  TatSQLLink = class
  private
    FOwner: TatSQLSetup;
    FLink: TComponent;
    FSQLText: String;

    FBeforeOpen, FAfterOpen: TDataSetNotifyEvent;
    FNotifyChange: TNotifyEvent;

    FBlock: Boolean;

    procedure SetupLink;
    procedure RemoveLink;

  protected
    procedure DoBefore(DataSet: TDataSet);
    procedure SQLChange(Sender: TObject);

  public
    constructor Create(AnOwner: TatSQLSetup; AComponent: TComponent);
    destructor Destroy; override;
  end;

  TatSQLSetup = class(TComponent)
  private
    FState: TsqlSetupState;

    FLinks: TObjectList;
    FIgnores: TatIgnores;
    FCurrLink: TComponent;

    function IsIgnored(const RelationName, AliasName: String;
      const CheckByLink: Boolean = False): Boolean;
    function IsIgnoredReferences(const RelationName, AliasName: String;
      const CheckByLink: Boolean = False): Boolean;

    function AdjustSQL(const Text: String;
      const ObjectClassName: String = ''): String;
    function IsNecessaryAttr(const AClassName, AFieldName, ARelationName: String; IsNess: Boolean): Boolean;

    procedure ChangeSQL(Parser: TsqlParser);
    //используется при разборе селект с добавлением необходимых аттрибутов
    //и таблиц-ссылок
    procedure ChangeFullEx(Parser: TsqlParser; Full: TsqlFull);
    procedure ChangeUpdate(Parser: TsqlParser; Update: TsqlUpdate);
    procedure ChangeInsert(Parser: TsqlParser; Insert: TsqlInsert);

    function FindLink(AComponent: TComponent; out Link: TatSQLLink): Boolean;
    function FindIgnore(AComponent: TComponent; out Ignore: TatIgnore): Boolean;

    procedure SetIgnores(const Value: TatIgnores);

  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    class function IsDataComponent(AComponent: TComponent): Boolean;

    procedure AdjustLinkSql(Link: TatSQLLink); dynamic;

  public
    constructor Create(AnOnwer: TComponent); override;
    destructor Destroy; override;

    procedure Prepare;

    procedure AddLink(AComponent: TComponent);
    function PrepareSQL(const Text: String;
      const ObjectClassName: String = ''): String;

    property State: TsqlSetupState read FState;

  published
    property Ignores: TatIgnores read FIgnores write SetIgnores;
  end;

  //Возвращает "алиса поля = алиас таблицы.реальное наименование поля"
  procedure GetTableAliasOriginField(Text: String; FList: TStrings);

  //Возвращает алиас поля = алиас таблицы
  procedure GetTableAlias(Text: String; FList: TStrings);
  procedure Clear_atSQLSetupCache;

  procedure Save_atSQLSetupCache(W: TWriter);
  procedure Load_atSQLSetupCache(R: TReader);

  //По as-наименованию поля возвращает является ли оно полем из мн-ва
  function IsSetField(AFieldName: String): Boolean;
  //Возвращает имя поля таблцы-множества по его As-наименованию
  function GetSetFieldName(AsName: String): String;
  { TODO -oJulia : Здесь проблема - нельзя использовать crc для сокращения имени,
    потому как может понадобиться обратное преобразование ... }
  //Возвращает As-наименование для поля-множества
  function GetAsSetFieldName(AFieldName: String): String;

  procedure Register;

implementation

uses
  jclSelected, ZLib;

var
  atSQLSetupCache: TStringList;

procedure Save_atSQLSetupCache(W: TWriter);
var
  I: Integer;
  P: PString;
begin
  W.WriteString('AB');
  W.WriteListBegin;
  for I := 0 to atSQLSetupCache.Count - 1 do
  begin
    P := Pointer(atSQLSetupCache.Objects[I]);
    W.WriteString(P^);
    W.WriteString(atSQLSetupCache[I]);
  end;
  W.WriteListEnd;
end;

procedure Load_atSQLSetupCache(R: TReader);
var
  P: PString;
begin
  Clear_atSQLSetupCache;

  try
    if (R.NextValue <> vaString) or (R.ReadString <> 'AB') then
      exit;

    R.ReadListBegin;
    while not R.EndOfList do
    begin
      New(P);
      Initialize(P^);
      P^ := R.ReadString;
      atSQLSetupCache.AddObject(R.ReadString, Pointer(P));
    end;
    R.ReadListEnd;
  except
    Clear_atSQLSetupCache;
  end;
end;

function IsSetField(AFieldName: String): Boolean;
begin
  Result := AnsiPos(cstSetPrefix, AFieldName) = 1;
end;

//Возвращает имя поля таблцы-множества по его As-наименованию
function GetSetFieldName(AsName: String): String;
begin
  Result := Copy(AsName, Length(cstSetPrefix) + 1, Length(AsName) -
    Length(cstSetPrefix));
end;

//Возвращает As-наименование для поля-множества
function GetAsSetFieldName(AFieldName: String): String;
begin
  Result := cstSetPrefix + AFieldName;
end;

procedure GetTableAliasOriginField(Text: String; FList: TStrings);
var
  FieldAlias, TableAlias, FieldName: String;
  I, J: Integer;
begin
  if not Assigned(atDatabase) then
    atDatabase := at_Classes.atDatabase;

  FList.Clear;

  if Assigned(atDatabase) then
    with TsqlParser.Create(Text) do
    begin
      try
        Parse;
        for I := 0 to Statements.Count - 1 do
        begin
        if (Statements.Items[I] is TsqlFull) then
          for J := 0 to (Statements[I] as TsqlFull).Select.Fields.Count - 1 do
          begin
            TableAlias := '';
            FieldAlias := '';
            FieldName := '';
            if (Statements[I] as TsqlFull).Select.Fields[J] is TsqlField then
            begin
              FieldName := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldName;
              if Trim(((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldAsName) <> '' then
                FieldAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldAsName
              else
                FieldAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldName;

              TableAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldAlias;
            end;
            if FieldName > '' then
              FList.Add(FieldAlias + '=' + TableAlias + '.' + FieldName);
          end;
        end;
      finally
        Free;
      end;
    end;
end;

procedure GetTableAlias(Text: String; FList: TStrings);
var
  FieldAlias, TableAlias: String;
  I, J: Integer;
begin
  if not Assigned(atDatabase) then
    atDatabase := at_Classes.atDatabase;

  FList.Clear;

  if Assigned(atDatabase) then
    with TsqlParser.Create(Text) do
    begin
      try
        Parse;
        for I := 0 to Statements.Count - 1 do
        begin
        if (Statements.Items[I] is TsqlFull) then
          for J := 0 to (Statements[I] as TsqlFull).Select.Fields.Count - 1 do
          begin
            TableAlias := '';
            if (Statements[I] as TsqlFull).Select.Fields[J] is TsqlField then
            begin
              if Trim(((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldAsName) <> '' then
                FieldAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldAsName
              else
                FieldAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldName;
              TableAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlField).FieldAlias;

            end else if (Statements[I] as TsqlFull).Select.Fields[J] is TsqlValue then
              FieldAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlValue).ValueAsName

            else if (Statements[I] as TsqlFull).Select.Fields[J] is TsqlFunction then
              FieldAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlFunction).FuncAsName

            else if (Statements[I] as TsqlFull).Select.Fields[J] is TsqlExpr then
              FieldAlias := ((Statements[I] as TsqlFull).Select.Fields[J] as TsqlExpr).ExprAsName;

            if FieldAlias > '' then
              FList.Add(FieldAlias + '=' + TableAlias);
          end;
        end;
      finally
        Free;
      end;
    end;
end;

{ TatSQLLink }

constructor TatSQLLink.Create(AnOwner: TatSQLSetup; AComponent: TComponent);
begin
  FOwner := AnOwner;
  FLink := AComponent;
  FLink.FreeNotification(FOwner);

  FBeforeOpen := nil;
  FAfterOpen := nil;
  FNotifyChange := nil;
  FBlock := False;

  FSQLText := '';

  SetupLink;
end;

destructor TatSQLLink.Destroy;
begin
  RemoveLink;

  inherited Destroy;
end;

procedure TatSQLLink.DoBefore(DataSet: TDataSet);
begin
  if FBlock then Exit;

  FBlock := True;

  try
    if Assigned(FBeforeOpen) then
      FBeforeOpen(DataSet);

    if Assigned(FOwner) then
      FOwner.AdjustLinkSql(Self);
  finally
    FBlock := False;
  end;
end;

procedure TatSQLLink.SQLChange(Sender: TObject);
begin
  if FBlock then Exit;

  FBlock := True;

  try
    if Assigned(FOwner) then
      FOwner.AdjustLinkSql(Self);

    if Assigned(FNotifyChange) then
      FNotifyChange(Sender);
  finally
    FBlock := False;
  end;
end;

procedure TatSQLLink.SetupLink;
begin
  if not Assigned(FLink) then Exit;
  
  if FLink is TDataSet then
  begin
    if FLink is TIBQuery then
    begin
      with FLink as TIBQuery do
      begin
        FBeforeOpen := BeforeOpen;
        BeforeOpen := DoBefore;
      end;
    end else

    if FLink is TIBDataSet then
    begin
      with FLink as TIBDataSet do
      begin
        FBeforeOpen := BeforeOpen;
        BeforeOpen := DoBefore;
      end;
    end;
  end;
end;

procedure TatSQLLink.RemoveLink;
begin
  if FLink is TDataSet then
  begin
    if FLink is TIBQuery then
    begin
      with FLink as TIBQuery do
        BeforeOpen := FBeforeOpen;
    end else

    if FLink is TIBDataSet then
    begin
      with FLink as TIBDataSet do
        BeforeOpen := FBeforeOpen;
    end;
  end;
end;

{ TatSQLSetup }

constructor TatSQLSetup.Create(AnOnwer: TComponent);
begin
  inherited Create(AnOnwer);

  FLinks := TObjectList.Create;

  FState := ssUnprepared;

  FIgnores := TatIgnores.Create(Self);
end;

destructor TatSQLSetup.Destroy;
begin
  FLinks.Free;
  FIgnores.Free;

  inherited Destroy;
end;

procedure TatSQLSetup.Prepare;
var
  I: Integer;
begin
  if not (csDesigning in ComponentState) and (FState = ssUnprepared) then
  begin
    if Assigned(Owner) then
      with Owner do
        for I := 0 to ComponentCount - 1 do
          if IsDataComponent(Components[I]) then
          begin
            FLinks.Add(TatSQLLink.Create(Self, Components[I]));
          end;

    FState := ssPrepared;
  end;
end;

procedure TatSQLSetup.Loaded;
begin
  inherited Loaded;
  
  if not (csDesigning in ComponentState) then
    Prepare;
end;

procedure TatSQLSetup.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  CurrLink: TatSQLLink;
  CurrIgnore: TatIgnore;
begin
  inherited Notification(AComponent, Operation);

  if not (csDesigning in ComponentState) then
  begin
    if Operation = opRemove then
    begin
      if FindLink(AComponent, CurrLink) then
        FLinks.Remove(CurrLink)
      else if FindIgnore(AComponent, CurrIgnore) then
        CurrIgnore.Link := nil;
    end;
  end;
end;

class function TatSQLSetup.IsDataComponent(
  AComponent: TComponent): Boolean;
begin
  Result := Assigned(AComponent) and (AComponent is TIBCustomDataSet);
end;

procedure TatSQLSetup.AdjustLinkSql(Link: TatSQLLink);
var
  I, K: Integer;
  Para: TStringList;
  P: TParams;
  ReassignParams: Boolean;
begin
  if (csDesigning in ComponentState) then Exit;

  with Link do
  begin
    FCurrLink := FLink;
    
    if FLink is TDataSet then
    begin
      if FLink is TIBQuery then
      begin
        with FLink as TIBQuery do
        begin
          if FSQLText = (FLink as TIBQuery).SQL.Text then
            Exit;

          P := TParams.Create;
          ReassignParams := Prepared;

          try
            P.Assign(Params);
            SQL.Text := AdjustSQL((FLink as TIBQuery).SQL.Text);

            if Assigned(UpdateObject) and (UpdateObject is TIBUpdateSQL) then
              with UpdateObject as TIBUpdateSQL do
              begin
                ModifySQL.Text := AdjustSQL(ModifySQL.Text);
                InsertSQL.Text := AdjustSQL(InsertSQL.Text);
                RefreshSQL.Text := AdjustSQL(RefreshSQL.Text);
              end;

            if ReassignParams then
              Params.Assign(P);
          finally
            P.Free;
          end;

          FSQLText := (FLink as TIBQuery).SQL.Text;
        end;
      end else

      if FLink is TIBDataSet then
      begin
        if FSQLText = TIBDataSet(FLink).SelectSQL.Text then
          exit;

        Para := TStringList.Create;
        ReassignParams := TIBDataSet(FLink).Prepared;

        try

          if ReassignParams then
          begin
            for I := 0 to TIBDataSet(FLink).Params.Count - 1 do
              if Para.IndexOfName(TIBDataSet(FLink).Params[I].Name) = -1 then
                Para.Add(TIBDataSet(FLink).Params[I].Name + '=' + TIBDataSet(FLink).Params[I].AsString);
          end;

          TIBDataSet(FLink).SelectSQL.Text := AdjustSQL(TIBDataSet(FLink).SelectSQL.Text);
          TIBDataSet(FLink).ModifySQL.Text := AdjustSQL(TIBDataSet(FLink).ModifySQL.Text);
          TIBDataSet(FLink).InsertSQL.Text := AdjustSQL(TIBDataSet(FLink).InsertSQL.Text);
          TIBDataSet(FLink).RefreshSQL.Text := AdjustSQL(TIBDataSet(FLink).RefreshSQL.Text);

          if ReassignParams then
          begin
            for K := 0 to Para.Count - 1 do
              TIBDataSet(FLink).ParamByName(Para.Names[K]).AsString := Para.Values[Para.Names[K]];
          end;
        finally
          Para.Free;
        end;

        FSQLText := TIBDataSet(FLink).SelectSQL.Text;
      end;
    end;

    FCurrLink := nil;
  end;
end;

function TatSQLSetup.AdjustSQL(const Text: String;
  const ObjectClassName: String = ''): String;
var
  Parser: TsqlParser;

begin
  Assert(atDatabase <> nil);

  if Assigned(atDatabase) then
  begin
    Parser := TsqlParser.Create(Text);
    Parser.ObjectClassName := ObjectClassName;
    try
      Parser.Parse;
      ChangeSQL(Parser);
      Parser.Build(Result);
    finally
      Parser.Free;
    end;
  end;
end;

procedure TatSQLSetup.ChangeSQL(Parser: TsqlParser);
var
  I: Integer;
begin
  for I := 0 to Parser.Statements.Count - 1 do
  begin
    if (Parser.Statements[I] is TsqlFull)  then
      ChangeFullEx(Parser, Parser.Statements[I] as TsqlFull)
    else

    if Parser.Statements[I] is TsqlUpdate then
      ChangeUpdate(Parser, Parser.Statements[I] as TsqlUpdate)
    else

    if Parser.Statements[I] is TsqlInsert then
      ChangeInsert(Parser, Parser.Statements[I] as TsqlInsert);
  end;
end;

procedure TatSQLSetup.ChangeUpdate(Parser: TsqlParser; Update: TsqlUpdate);
var
  I: Integer;
  atTable: TatRelation;
  atField: TatrelationField;

  NewConditions: TObjectList;
  CurrCondition: TsqlCondition;
  CurrField: TsqlField;
  CurrValue: TsqlValue;
  CurrMath: TsqlMath;
  NecessaryAttr: Boolean;
begin
  if not Assigned(Update.Table) or not Assigned(Update.Where) or
    (Update.FieldConditions.Count = 0)
  then
    Exit;

  atTable := atDatabase.Relations.ByRelationName(Update.Table.TableName);
  if not Assigned(atTable) then Exit;

  NewConditions := TObjectList.Create(False);

  try
    I := 0;

    while I < Update.FieldConditions.Count do
    begin
      CurrCondition := Update.FieldConditions[I] as TsqlCondition;

      if CurrCondition.Statements[0] is TsqlField then
      begin
        CurrField := CurrCondition.Statements[0] as TsqlField;
        atField := atTable.RelationFields.ByFieldName(CurrField.FieldName);

        if Assigned(atField) then
        begin
          if atField.IsUserDefined then
            Update.FieldConditions.Remove(CurrCondition)
          else begin
            NewConditions.Add(CurrCondition);

            with Update.FieldConditions do
            begin
              OwnsObjects := False;
              Remove(CurrCondition);
              OwnsObjects := True;
            end;
          end;

          Continue;
        end else begin
          Update.FieldConditions.Remove(CurrCondition);
          Continue;
        end;
      end;
    end;

    Update.FieldConditions.Clear;

    for I := 0 to atTable.RelationFields.Count - 1 do
    begin
      atField := atTable.RelationFields[I];

      if atField.IsUserDefined and (Parser.ObjectClassName > '') then
        NecessaryAttr := IsNecessaryAttr(Parser.ObjectClassName, atField.FieldName, atField.Relation.RelationName, False)
      else
        NecessaryAttr := True;

      if atField.IsUserDefined and not atField.IsComputed and NecessaryAttr then
      begin
        CurrCondition := TsqlCondition.Create(Parser);

        CurrField := TsqlField.Create(Parser, False);
        CurrField.FieldAttrs := [eoName];
        CurrField.FieldName := atField.FieldName;

        CurrValue := TsqlValue.Create(Parser, False);
        CurrValue.ValueAttrs := [eoValue];
        CurrValue.Value := ':' + atField.FieldName;

        CurrMath := TsqlMath.Create(Parser);
        CurrMath.Math.Add(mcEqual);

        with CurrCondition.Statements do
        begin
          Add(CurrField);
          Add(CurrMath);
          Add(CurrValue);
        end;

        NewConditions.Add(CurrCondition);
      end;
    end;

    for I := 0 to NewConditions.Count - 1 do
      Update.FieldConditions.Add(NewConditions[I]);

  finally
    NewConditions.Free;
  end;
end;

procedure TatSQLSetup.ChangeInsert(Parser: TsqlParser; Insert: TsqlInsert);
var
  I: Integer;
  atTable: TatRelation;
  atField: TatRelationField;
  NewFields, NewValues: TObjectList;
  CurrField: TsqlField;
  CurrValue: TsqlValue;
  NecessaryAttr: Boolean;
begin
  if not Assigned(Insert.Table) or (Insert.Fields.Count = 0) or
    (Insert.Values.Count = 0) or (Insert.Fields.Count > Insert.Values.Count)
  then
    Exit;

  atTable := atDatabase.Relations.ByRelationName(Insert.Table.TableName);
  if not Assigned(atTable) then Exit;

  NewFields := TObjectList.Create(False);
  NewValues := TObjectList.Create(False);

  try
    while Insert.Fields.Count > 0 do
    begin
      if (Insert.Fields[0] is TsqlField) then
      begin
        CurrField := Insert.Fields[0] as TsqlField;

        atField := atTable.RelationFields.ByFieldName(CurrField.FieldName);

        if Assigned(atField) then
        begin

          if atField.IsUserDefined then
          begin
            Insert.Fields.Delete(0);

            while Insert.Values[0] is TsqlMath do
              Insert.Values.Delete(0);

            Insert.Values.Delete(0);
          end else begin
            NewFields.Add(CurrField);

            with Insert.Fields do
              Extract(CurrField);

            with Insert.Values do
            begin
              OwnsObjects := False;

              while Items[0] is TsqlMath do
                NewValues.Add(Extract(Items[0]));

              NewValues.Add(Extract(Items[0]));
              OwnsObjects := True;
            end;
          end;

          Continue;
        end else begin
          Insert.Fields.Delete(0);

          while Insert.Values[0] is TsqlMath do
            Insert.Values.Delete(0);

          Insert.Values.Delete(0);
          Continue;
        end;
      end else begin
        Insert.Fields.Delete(0);

        while Insert.Values[0] is TsqlMath do
          Insert.Values.Delete(0);

        Insert.Values.Delete(0);
        Continue;
      end;
    end;

    for I := 0 to atTable.RelationFields.Count - 1 do
    begin
      atField := atTable.RelationFields[I];


      if atField.IsUserDefined and (Parser.ObjectClassName > '') then
        NecessaryAttr := IsNecessaryAttr(Parser.ObjectClassName, atField.FieldName, atField.Relation.RelationName, False)
      else
        NecessaryAttr := True;

      if atField.IsUserDefined and not atField.IsComputed and NecessaryAttr then
      begin
        CurrField := TsqlField.Create(Parser, False);
        CurrField.FieldAttrs := [eoName];
        CurrField.FieldName := atField.FieldName;

        CurrValue := TsqlValue.Create(Parser, False);
        CurrValue.ValueAttrs := [eoValue];
        CurrValue.Value := ':' + atField.FieldName;

        NewFields.Add(CurrField);
        NewValues.Add(CurrValue);
      end;
    end;

    for I := 0 to NewFields.Count - 1 do
      Insert.Fields.Add(NewFields[I]);

    for I := 0 to NewValues.Count - 1 do
      Insert.Values.Add(NewValues[I]);

  finally
    NewFields.Free;
    NewValues.Free;
  end;
end;

function TatSQLSetup.FindLink(AComponent: TComponent; out Link: TatSQLLink): Boolean;
var
  I: Integer;
begin
  for I := 0 to FLinks.Count - 1 do
    if (FLinks[I] as TatSQLLink).FLink = AComponent then
    begin
      Result := True;
      Link := FLinks[I] as TatSQLLink;
      Exit;
    end;

  Result := False;
end;

procedure TatSQLSetup.AddLink(AComponent: TComponent);
var
  Link: TatSQLLink;
begin
  if not (csDesigning in ComponentState) and not FindLink(AComponent, Link) then
    FLinks.Add(TatSQLLink.Create(Self, AComponent));
end;

function TatSQLSetup.PrepareSQL(const Text: String;
  const ObjectClassName: String = ''): String;
var
{$IFDEF DEBUG}
  T: TDateTime;
{$ENDIF}
  I, L: Integer;
  P: PString;
  S: String;
begin
{$IFDEF DEBUG}
  T := Now;
{$ENDIF}

  L := Length(Text);

  if L = 0 then
    Result := ''
  else
  begin
    if (atSQLSetupCache <> nil) and (Ignores.Count = 0) then
    begin
      S := ObjectClassName + IntToStr(CRC32_P(@Text[1], L, 0));
      I := atSQLSetupCache.IndexOf(S);
    end else
      I := -1;
    if I = -1 then
    begin
      Result := AdjustSQL(Text, ObjectClassName);

      if (atSQLSetupCache <> nil) and (Ignores.Count = 0) then
      begin
        New(P);
        Initialize(P^);
        P^ := ZCompressStr(Result, zcDefault);
        atSQLSetupCache.AddObject(S, Pointer(P));
      end;
    end else
    begin
      Result := ZDecompressStr(PString(atSQLSetupCache.Objects[I])^);
    end;
  end;
{$IFDEF DEBUG}
  if Now - T > 1 / (24 * 60 * 60) then
    OutputDebugString(PChar(Copy(Text, 1, 10) + '... ' + FormatDateTime('ss.z', Now - T)));
{$ENDIF}
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TatSQLSetup]);
end;

procedure TatSQLSetup.SetIgnores(const Value: TatIgnores);
begin
  if Assigned(Value) then
    FIgnores.Assign(Value);
end;

function TatSQLSetup.IsIgnored(const RelationName, AliasName: String;
  const CheckByLink: Boolean = False): Boolean;
var
  I: Integer;
begin
  for I := 0 to FIgnores.Count - 1 do
    if
      (
        (FIgnores[I].FLink = FCurrLink) or
        not CheckByLink
      )
        and
        (FIgnores[I].IgnoryType = itFull) and
      (
        (AnsiCompareText(RelationName, FIgnores[I].FRelationName) = 0)
          or
        (AliasName > '') and
        (AnsiCompareText(AliasName, FIgnores[I].FAliasName) = 0)
      )
    then begin
      Result := True;
      Exit;
    end;

  Result := False;
end;

function TatSQLSetup.IsIgnoredReferences(const RelationName, AliasName: String;
  const CheckByLink: Boolean = False): Boolean;
var
  I: Integer;
begin
  for I := 0 to FIgnores.Count - 1 do
    if
      (
        (FIgnores[I].FLink = FCurrLink) or
        not CheckByLink
      )
        and
        (FIgnores[I].IgnoryType = itReferences) and
      (
        (AnsiCompareText(RelationName, FIgnores[I].FRelationName) = 0)
          or
        (AliasName > '') and
        (AnsiCompareText(AliasName, FIgnores[I].FAliasName) = 0)
      )
    then begin
      Result := True;
      Exit;
    end;

  Result := False;
end;


function TatSQLSetup.FindIgnore(AComponent: TComponent;
  out Ignore: TatIgnore): Boolean;
var
  I: Integer;
begin
  for I := 0 to FIgnores.Count - 1 do
    if FIgnores[I].FLink = AComponent then
    begin
      Result := True;
      Ignore := FIgnores[I];
      Exit;
    end;

  Result := False;
end;

procedure TatSQLSetup.ChangeFullEx(Parser: TsqlParser; Full: TsqlFull);
var
  Relations, Fields, ToRemove: TObjectList;
  CurrTable: TsqlTable;
  I, K, J, G, H: Integer;
  R: TatRelation;
  F, Fld: TatRelationField;
  CurrField: TsqlField;
  ShouldLoadAllFields: Boolean;
  NecessaryAttr: Boolean;
  LinkJoin: TsqlJoin;
  LinkTable: TsqlTable;
  LinkCondition: TsqlCondition;
  LinkField: TsqlField;
  LinkAlias: String;
  IsBreak: Boolean;
  WasComment, SL: TStringList;
  NeedCreateField: Boolean;
  FieldList: TStringList;
  FieldPos: String;
begin
  Assert(Assigned(gdcBaseManager));

  //
  //  Проверяем наличие select, from частей в запросе

  if not Assigned(Full.Select) or not Assigned(Full.From) then Exit;

  Relations := TObjectList.Create(False);
  Fields := TObjectList.Create(False);
  ToRemove := TObjectList.Create(False);
  WasComment := TStringList.Create;
  FieldList := TStringList.Create;
  try
  //
  // Получаем список отношений

    for I := 0 to Full.From.Tables.Count - 1 do
    begin
      Relations.Add(Full.From.Tables[I]);

      //
      //  Осуществляем проверку на наличие JOIN-таблиц

      if Full.From.Tables[I] is TsqlTable then
      with Full.From.Tables[I] as TsqlTable do
        for K := 0 to Joins.Count - 1 do
          Relations.Add((Joins[K] as TsqlJoin).JoinTable)
      else

      //
      //  В случае наличия вложенных запросов
      //  осуществляем выбор таблиц и оттуда

      if Full.From.Tables[I] is TsqlFunction then
        with Full.From.Tables[I] as TsqlFunction do
          for K := 0 to Joins.Count - 1 do
            Relations.Add((Joins[K] as TsqlJoin).JoinTable)
    end;

    //
    //  Осущствляем выбор только таблиц и представлений

    for I := Relations.Count - 1 downto 0 do
      if not (Relations[I] is TsqlTable) then
        Relations.Delete(I)
      else

      //
      //  Дополнительно проверяем на случай необходимости
      //  пропуска таблицы

      if IsIgnored((Relations[I] as TsqlTable).TableName,
        (Relations[I] as TsqlTable).TableAlias, FCurrLink <> nil)
      then
        Relations.Delete(I);

      //Удаляем таблицы, добавленные вручную по полю ссылке
    for  I := Relations.Count - 1 downto 0 do
    begin
      //  Получаем таблицу из структуры базы данных
      R := atDatabase.Relations.ByRelationName((Relations[I] as TsqlTable).TableName);
      if not Assigned(R) then Continue;

      for K := 0 to R.RelationFields.Count - 1 do
      begin
        F := R.RelationFields[K];

       //Если поле-аттрибут является ссылкой
        if Assigned(F.References) and F.IsUserDefined then
        begin
          with Relations[I] as TsqlTable do
          begin
            if TableAlias <> '' then
              LinkAlias := TableAlias + '_' + F.FieldName
            else
              LinkAlias := TableName + '_' + F.FieldName;

            //Проверяем, была ли уже добавлена таблица (предполагается, что алиас уникален)
            for J := I to Relations.Count - 1 do
              if gdcBaseManager.AdjustMetaName((Relations[J] as TsqlTable).TableAlias) =
                gdcBaseManager.AdjustMetaName(LinkAlias) then
              begin
                Relations.Delete(J);
                Break;
              end;
          end;
        end;
      end;
    end;

    //
    //  Осуществляем проверку всех таблиц
    //  и выбор вставленных полей, но не атрибутов

    for I := 0 to Relations.Count - 1 do
    begin

      //
      //  Получаем таблицу из структуры базы данных

      CurrTable := Relations[I] as TsqlTable;
      R := atDatabase.Relations.ByRelationName(CurrTable.TableName);
      if not Assigned(R) then Continue;


      for K := Full.Select.Fields.Count - 1 downto 0 do
      begin

        if not(Full.Select.Fields[K] is TsqlField) then
          Continue;

        CurrField := Full.Select.Fields[K] as TsqlField;

        F := R.RelationFields.ByFieldName(CurrField.FieldName);

        //
        //  Если поле найдено - осуществляем его проверку,
        //  если нет - оставляем

        if Assigned(F) then
        begin
          if
            //  Если у таблицы и поля совпадают алиасы

            (eoAlias in CurrField.FieldAttrs) and
            (eoAlias in CurrTable.TableAttrs) and
            (CurrTable.TableAlias = CurrField.FieldAlias)

              or

            //  Если у поля и таблицы не алиасов, но поле с таким именем
            //  существует в таблице, сохраняем поля именно для этой таблицы
            //  Ситуация является спорной так, как в других таблицах
            //  могут быть поля с таким же наименованием

            not (eoAlias in CurrField.FieldAttrs) and
            not (eoAlias in CurrTable.TableAttrs)

              or

            //  Если у таблицы нет алиаса, но алиас есть у поля
            //  и он такой же как название таблицы - используем его

            (eoAlias in CurrField.FieldAttrs) and
            not (eoAlias in CurrTable.TableAttrs) and
            (CurrField.FieldAlias = CurrTable.TableName)
          then begin
            // Nick если есть Group By и поле блоб то не берем такое поле
            if Assigned(Full.GroupBy) and (F.SQLType  = blr_blob) then

              //Если поле типа мемо и в запросе есть Group by удалим поле
              Full.Select.Fields.Remove(CurrField)
            else
              //  Если атрибут - то добавим его в отдельный список, чтобы впоследствие его быстрее найти
              ToRemove.Add(CurrField);
          end;
        end else

        //  Если не найдено поле и его наименование
        //  содержит только символ "*", а также
        //  если у таблицы и поля совпадают алиасы

        if
          (CurrField.FieldName = '*') and
          (eoAlias in CurrField.FieldAttrs) and
          (eoAlias in CurrTable.TableAttrs) and
          (CurrTable.TableAlias = CurrField.FieldAlias)

            or

          //
          //  Если не найдено поле и его наименование
          //  содержит только символ "*", а также
          //  если наименование у таблицы и алиас у поля совпадают

          (CurrField.FieldName = '*') and
          (eoAlias in CurrField.FieldAttrs) and
          not (eoAlias in CurrTable.TableAttrs) and
          (CurrTable.TableName = CurrField.FieldAlias)

        then begin
          //
          //  Удаляем указанное поле
          //Сохраняем комментарии
          WasComment.Assign(CurrField.Comment);
          Full.Select.Fields.Remove(CurrField);

          //
          //  Добавляем все поля таблицы

          FieldList.Clear;
          for J := 0 to R.RelationFields.Count - 1 do
          begin
            FieldPos := IntToStr(R.RelationFields[J].FieldPosition);
            while Length(FieldPos) < 4 do
              FieldPos := '0' + FieldPos;
            FieldList.AddObject(FieldPos , R.RelationFields[J]);
          end;
          FieldList.Sort;

          for J := 0 to FieldList.Count - 1 do
          begin
            if (FieldList.Objects[J] as TatRelationField).IsUserDefined then Continue;

            CurrField := TsqlField.Create(Parser, False);

            CurrField.FieldAttrs := [eoName, eoAlias];
            CurrField.FieldName := (FieldList.Objects[J] as TatRelationField).FieldName;
            CurrField.FieldAlias := CurrTable.TableAlias;
            if J = 0 then
              CurrField.Comment.Assign(WasComment);

            //Если это поле присоединено из таблицы множества
            //проверяется по алиасу = GD$ST
            //то добавляем as-наименование, состоящее из префикса S$ и имени поля
            if AnsiCompareText(cstSetAlias, CurrField.FieldAlias) = 0 then
            begin
              CurrField.FieldAsName := GetAsSetFieldName(CurrField.FieldName);
              CurrField.FieldAttrs := CurrField.FieldAttrs + [eoSubName];
            end;

            Full.Select.Fields.Add(CurrField);
          end;
        end;
      end;
    end;

    ShouldLoadAllFields := False;

    //
    // Если есть только одно поле с наименованием
    // "*", то убираем его и вставляем поля для
    // всех таблиц

    if
      (Full.Select.Fields.Count = 1) and
      (Full.Select.Fields[0] is TsqlField) and
      ((Full.Select.Fields[0] as TsqlField).FieldName = '*') and
      not (eoAlias in (Full.Select.Fields[0] as TsqlField).FieldAttrs) and
      (Relations.Count > 0)
    then begin
      Full.Select.Fields.Delete(0);
      ShouldLoadAllFields := True;
    end;

    for I := 0 to Relations.Count - 1 do
    begin

      //
      //  Получаем таблицу из структуры базы данных

      CurrTable := Relations[I] as TsqlTable;
      R := atDatabase.Relations.ByRelationName(CurrTable.TableName);
      if not Assigned(R) then Continue;

      FieldList.Clear;
      for K := 0 to R.RelationFields.Count - 1 do
      begin
        //Nick
        if not (Assigned(Full.GroupBy) and (R.RelationFields[K].SQLType  = blr_blob)) then
        begin
          FieldPos := IntToStr(R.RelationFields[K].FieldPosition);
          while Length(FieldPos) < 4 do
            FieldPos := '0' + FieldPos;

          FieldList.AddObject(FieldPos, R.RelationFields[K]);
        end
      end;
      FieldList.Sort;

      for K := 0 to FieldList.Count - 1 do
      begin
        F := (FieldList.Objects[K] as TatRelationField);
        if not F.IsUserDefined and not ShouldLoadAllFields then Continue;

        CurrField := nil;

        if Parser.ObjectClassName > '' then
          NecessaryAttr := False
        else
          NecessaryAttr := True;

        NeedCreateField := True;
        //Если это поле уже есть, то продолжаем
        for J := 0 to ToRemove.Count - 1 do
        with (ToRemove[J] as TsqlField) do
          if
            (FieldName = F.FieldName)
              and
            (FieldAlias = CurrTable.TableAlias)
          then begin
            NeedCreateField := False;
            NecessaryAttr := True;
            CurrField := ToRemove[J] as TsqlField;
            Break;
          end;

        if NeedCreateField then
        begin
          CurrField := TsqlField.Create(Parser, False);
          CurrField.FieldAttrs := [eoName];

          CurrField.FieldName := F.FieldName;

          if eoAlias in CurrTable.TableAttrs then
          begin
            CurrField.FieldAttrs := CurrField.FieldAttrs + [eoAlias];
            CurrField.FieldAlias := CurrTable.TableAlias;
          end;

          //Если это поле присоединено из таблицы множества
          //проверяется по алиасу = GD$ST
          //то добавляем as-наименование, состоящее из префикса SET$ и имени поля
          if AnsiCompareText(cstSetAlias, CurrField.FieldAlias) = 0 then
          begin
            CurrField.FieldAsName := GetAsSetFieldName(CurrField.FieldName);
            CurrField.FieldAttrs := CurrField.FieldAttrs + [eoSubName];
          end;
        end;

        if F.IsUserDefined then
          NecessaryAttr := IsNecessaryAttr(Parser.ObjectClassName, F.FieldName, F.Relation.RelationName, NecessaryAttr);
        //Добавляем поле-аттрибут, если оно прописано для даного класса, если не указан класс,
        //если это поле из множества, или если это не атрибут
        if NecessaryAttr or (not F.IsUserDefined) or
          (AnsiCompareText(cstSetAlias, CurrField.FieldAlias) = 0) then
        begin
          if NeedCreateField then
            Fields.Add(CurrField);
          //Если поле-аттрибут является ссылкой
          if Assigned(F.References) and F.IsUserDefined and (not
             IsIgnoredReferences((Relations[I] as TsqlTable).TableName,
               (Relations[I] as TsqlTable).TableAlias, FCurrLink <> nil))
             and (F.ReferenceListField.References = nil)
          then
          begin
            with Relations[I] as TsqlTable do
            begin
              if TableAlias <> '' then
                LinkAlias := TableAlias + '_' + F.FieldName
              else
                LinkAlias := TableName + '_' + F.FieldName;
              //Проверяем, была ли уже добавлена таблица (предполагается, что алиас уникален)

              if not Full.From.FindTableByAlias(LinkAlias) then
              begin
                //Создаем новый LEFT JOIN
                LinkJoin := TsqlJoin.Create(Parser);
                LinkJoin.JoinClause.Add(cLeft);
                LinkJoin.JoinClause.Add(cJoin);
                LinkJoin.JoinAttrs := [eoClause, eoOn];

                //Добавляем таблицу
                LinkTable := TsqlTable.Create(Parser);
                LinkTable.TableName := F.References.RelationName;
                if TableAlias <> '' then
                  LinkTable.TableAlias := TableAlias + '_' + F.FieldName
                else
                  LinkTable.TableAlias := TableName + '_' + F.FieldName;
                LinkTable.TableAttrs := [eoName, eoAlias];
                LinkJoin.JoinTable := LinkTable;

                //Добавляем условия связи
                LinkCondition := TsqlCondition.Create(Parser);

                LinkField := TsqlField.Create(Parser, False);
                LinkField.FieldAlias := LinkTable.TableAlias;
                LinkField.FieldName := F.ReferencesField.FieldName;
                LinkField.FieldAttrs := [eoName, eoAlias];
                LinkCondition.Statements.Add(LinkField);

                LinkCondition.Statements.Add(TsqlMath.Create(Parser));
                (LinkCondition.Statements[LinkCondition.Statements.Count - 1] as TsqlMath).Math.Add(mcEqual);

                LinkField := TsqlField.Create(Parser, False);
                if TableAlias > '' then
                  LinkField.FieldAlias := TableAlias
                else
                  LinkField.FieldAlias := TableName;
                LinkField.FieldName := f.FieldName;
                LinkField.FieldAttrs := [eoName, eoAlias];
                LinkCondition.Statements.Add(LinkField);

                LinkJoin.Conditions.Add(LinkCondition);

                //Находим главную таблицу
                IsBreak := False;
                for J := 0 to Full.From.Tables.Count - 1 do
                begin
                  if Full.From.Tables[J] is TsqlTable then
                  begin
                    if Full.From.Tables[J] = Relations[I] then
                    begin
                      (Full.From.Tables[J] as TsqlTable).Joins.Add(LinkJoin);
                       IsBreak := True;
                       Break;
                    end;

                    for G := 0 to (Full.From.Tables[J] as TsqlTable).Joins.Count - 1 do
                      if ((Full.From.Tables[J] as TsqlTable).Joins[G] as TsqlJoin).JoinTable = Relations[I] then
                      begin
                        (Full.From.Tables[J] as TsqlTable).Joins.Add(LinkJoin);
                        IsBreak := True;
                        Break;
                      end;
                   end
                   else if Full.From.Tables[J] is TsqlFunction then
                   begin
                      for G := 0 to (Full.From.Tables[J] as TsqlFunction).Joins.Count - 1 do
                        if ((Full.From.Tables[J] as TsqlFunction).Joins[G] as TsqlJoin).JoinTable = Relations[I] then
                        begin
                          (Full.From.Tables[J] as TsqlFunction).Joins.Add(LinkJoin);
                          IsBreak := True;
                          Break;
                        end;
                   end;
                   if IsBreak then Break;
                end;

                if not isBreak and (Full.From.Tables.Count = 1) then
                  if (Full.From.Tables[0] is TsqlTable) then
                    (Full.From.Tables[0] as TsqlTable).Joins.Add(LinkJoin)
                  else if (Full.From.Tables[0] is TsqlFunction) then
                    (Full.From.Tables[0] as TsqlFunction).Joins.Add(LinkJoin);
              end;

              IsBreak := False;
              //Проверяем было ли уже добавлено поле для отображения по ссылке
              for G := 0 to Fields.Count - 1 do
                if (Fields.Items[G] as TsqlField).FieldAsName =
                  LinkAlias + '_' +  F.ReferenceListField.FieldName then
                begin
                  IsBreak := True;
                  Break;
                end;

              if not IsBreak then
              begin
                //Добавляем поле для отображения
                CurrField := TsqlField.Create(Parser, False);
                CurrField.FieldAttrs := [eoName, eoAlias, eoSubName];

                CurrField.FieldName := F.ReferenceListField.FieldName;
                CurrField.FieldAlias := LinkAlias;
                CurrField.FieldAsName := LinkAlias + '_' +
                   F.ReferenceListField.FieldName;

                Fields.Add(CurrField);
                //+ Поля для расширенного отображения, если они указаны
                if F.References.ExtendedFields > '' then
                begin
                  SL := TStringList.Create;
                  try
                    SL.CommaText := StringReplace(F.References.ExtendedFields,
                      ';', ',', [rfReplaceAll]);
                    for G := 0 to SL.Count - 1 do
                    begin
                      Fld := F.References.RelationFields.ByFieldName(SL[G]);
                      if Assigned(Fld) then
                      begin
                        for H := Fields.Count - 1 downto 0 do
                        begin
                          if AnsiCompareText(TsqlField(Fields[H]).FieldAsName,
                            LinkAlias + '_' + Fld.FieldName) = 0 then
                          begin
                            break;
                          end else if H = 0 then
                          begin
                            CurrField := TsqlField.Create(Parser, False);
                            CurrField.FieldAttrs := [eoName, eoAlias, eoSubName];

                            CurrField.FieldName := Fld.FieldName;
                            CurrField.FieldAlias := LinkAlias;
                            CurrField.FieldAsName := LinkAlias + '_' + Fld.FieldName;

                            Fields.Add(CurrField);
                          end;
                        end;
                      end;
                    end;
                  finally
                    SL.Free;
                  end;
                end;
              end;
            end;
          end;
        end
        else if NeedCreateField then
          CurrField.Free;
      end;
    end;

    //
    //  Переносим все поля в Select часть
    if (Full.GroupBy = nil) or ((Full.GroupBy.Fields.Count + Fields.Count) <= 255) then
    begin
      for I := 0 to Fields.Count - 1 do
        Full.Select.Fields.Add(Fields[I]);

    //
    //  Если используется Group By, добавляем в него все поля тоже

      if Assigned(Full.GroupBy) then
      begin
        for I := 0 to Fields.Count - 1 do
        with Fields[I] as TsqlField do
        begin
          //  Пропускаем поля пользователя
          if (AnsiPos(UserPrefix, FieldName) = 0) and (AnsiPos(UserPrefix, FieldAlias) = 0) then Continue;

          CurrField := TsqlField.Create(Parser, False);
          CurrField.FieldName := FieldName;
          CurrField.FieldAlias := FieldAlias;
          CurrField.FieldCollation := FieldCollation;
          CurrField.FieldAttrs := FieldAttrs - [eoSubName];
          Full.GroupBy.Fields.Add(CurrField);
        end;
      end;
    end;
  finally
    Relations.Free;
    Fields.Free;
    ToRemove.Free;
    WasComment.Free;
    FieldList.Free;
  end;

  if Full.Union <> nil then
    ChangeFullEx(Parser, Full.Union);
end;

function TatSQLSetup.IsNecessaryAttr(const AClassName, AFieldName, ARelationName: String; IsNess: Boolean): Boolean;
var
  AnObjects: TStringList;
  I: Integer;
  ClIn, Cl: TPersistentClass;
  ClNameIn, ClName: String;
  F: TatRelationField;
begin
  Assert(atDatabase <> nil);

  if (AClassName = '') or IsNess then
  begin
    Result := True;
    Exit;
  end else
    Result := False;

  //Если передано имя класса с сабтайпом
  if AnsiPos('(', AClassName) > 0 then
    //Вычленяем имя класса
    ClNameIn := Copy(AClassName, 1, AnsiPos('(', AClassName) - 1)
  else
    ClNameIn := AClassName;
  ClIn := GetClass(ClNameIn);
  if ClIn = nil then Exit;

  F := atDatabase.FindRelationField(ARelationName, AFieldName);

  AnObjects := F.ObjectsList;

  if AnObjects.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  for I := 0 to AnObjects.Count - 1 do
  begin
    ClName := AnObjects[I];
    if AnsiCompareText(ClName, AClassName) = 0 then
    begin
      Result := True;
      Break;
    end;

    if AnsiPos('(', ClName) > 0 then
    //Вычленяем имя класса
      ClName := Copy(ClName, 1, AnsiPos('(', ClName) - 1);

    Cl := GetClass(ClName);
    //Если выделен родитель
    if (Cl <> nil) and (ClIn.InheritsFrom(Cl)) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

{ TatIgnore }

constructor TatIgnore.Create(Collection: TCollection);
begin
  inherited;

  FLink := nil;
  FRelationName := '';
  FAliasName := '';
  FIgnoryType := itFull;
end;

destructor TatIgnore.Destroy;
begin
  inherited;
end;

function TatIgnore.GetDisplayName: string;
begin
  if Assigned(FLink) then
    Result := FLink.Name
  else
    Result := '(empty)';

  Result := Result + '[' + FRelationName + ']';
end;

{ TatIgnores }

function TatIgnores.Add: TatIgnore;
begin
  Result := TatIgnore(inherited Add);
end;

function TatIgnores.AddAliasName(const AnAliasName: String): TatIgnore;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if AnsiCompareText(Items[I].AliasName, AnAliasName) = 0 then
    begin
      Result := Items[I];
      exit;
    end;
  end;

  Result := Add;
  Result.AliasName := AnAliasName;
end;

constructor TatIgnores.Create(AnSQLSetup: TatSQLSetup);
begin
  inherited Create(TatIgnore);
  FSQLSetup := AnSQLSetup;
end;

destructor TatIgnores.Destroy;
begin
  inherited;
end;

function TatIgnores.GetIgnore(Index: Integer): TatIgnore;
begin
  Result := TatIgnore(inherited Items[Index]);
end;

function TatIgnores.GetOwner: TPersistent;
begin
  Result := FSQLSetup;
end;

procedure TatIgnores.SetIgnore(Index: Integer; Value: TatIgnore);
begin
  Items[Index].Assign(Value);
end;

procedure TatIgnores.Update(Item: TCollectionItem);
begin
  inherited;
end;

procedure Clear_atSQLSetupCache;
var
  I: Integer;
  P: PString;
begin
  if atSQLSetupCache <> nil then
  begin
    for I := 0 to atSQLSetupCache.Count - 1 do
    begin
      P := Pointer(atSQLSetupCache.Objects[I]);
      Finalize(P^);
      Dispose(P);
    end;
    atSQLSetupCache.Clear;
  end;  
end;

initialization
  atSQLSetupCache := TStringList.Create;
  atSQLSetupCache.Sorted := True;
  atSQLSetupCache.Duplicates := dupError;

finalization
  Clear_atSQLSetupCache;
  FreeAndNil(atSQLSetupCache);
end.

