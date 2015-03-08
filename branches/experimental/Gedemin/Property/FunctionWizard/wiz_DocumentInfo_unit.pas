unit wiz_DocumentInfo_unit;

interface

uses
  gdcBase, gdcBaseInterface, gdcConstants, gdcClasses_interface, gdcClasses,
  wiz_Strings_unit, contnrs, at_Classes, classes, Sysutils;

type
  TCustomDocumntInfo = class;

  TDocumentField = class
  private
    FDisplayName: string;
    FRelationField: TatRelationField;
    FDocumentInfo: TCustomDocumntInfo;
    FNameInScript: string;
    FFieldName: string;
    FFieldRepresentation: String;

    procedure SetDisplayName(const Value: string);
    procedure SetRelationField(const Value: TatRelationField);
    procedure SetDocumentInfo(const Value: TCustomDocumntInfo);
    procedure SetNameInScript(const Value: string);
    procedure SetFieldName(const Value: string);
    function GetFieldRepresentation: String;
  public
    function Script: string;

    property RelationField: TatRelationField read FRelationField write SetRelationField;
    property DisplayName: string read FDisplayName write SetDisplayName;
    property DocumentInfo: TCustomDocumntInfo read FDocumentInfo write SetDocumentInfo;
    property NameInScript: string read FNameInScript write SetNameInScript;
    property FieldName: string read FFieldName write SetFieldName;
    property FieldRepresentation: String read GetFieldRepresentation ;
  end;

  TCustomDocumntInfo = class
  private
    FDocumentRUID: string;
    FDocument: TgdcBase;
    FFields: TObjectList;
    procedure SetDocumentRUID(const Value: string);
    function GetDocument: TgdcBase;
    function GetFields(Index: Integer): TDocumentField;
    function GetFieldCount: Integer;
    procedure CheckDocument;
    procedure CheckFields;
  protected
    function GetDocumentClassPart: TgdcDocumentClassPart;virtual; abstract;
    function GetDisplayDocumentClassPart: string; virtual; abstract;
  public
    destructor Destroy; override;
    function NameInScript: string; virtual; abstract;
    procedure ForeignFields(ForeignTableName: string; List: TList);
    procedure SQLTypeFields(SQLType: Integer; List: TList);
    function Find(FieldName: string): TDocumentField;

    property Document: TgdcBase read GetDocument;
    property DocumentRUID: string read FDocumentRUID write SetDocumentRUID;
    property Fields[Index: Integer]: TDocumentField read GetFields; default;
    property FieldCount: Integer read GetFieldCount;
  end;

  TDocumentInfo = class(TCustomDocumntInfo)
  protected
    function GetDocumentClassPart: TgdcDocumentClassPart; override;
    function GetDisplayDocumentClassPart: string; override;
  public
    function NameInScript: string; override;
  end;

  TDocumentLineInfo = class(TCustomDocumntInfo)
  protected
    function GetDocumentClassPart: TgdcDocumentClassPart; override;
    function GetDisplayDocumentClassPart: string; override;
  public
    function NameInScript: string; override;
  end;

implementation

{ TCustomDocumntInfo }
procedure OriginNames(Origin: string; out TableName: string;
  out FieldName: string);
var
  S: TStrings;
begin
  S := TStringList.Create;
  try
    TableName := '';
    FieldName := '';
    S.Text := StringReplace(StringReplace(Origin, '"', '', [rfReplaceAll]), '.',
      #13#10, [rfReplaceAll]);
    if S.Count = 2 then
    begin
      TableName := S[0];
      FieldName := S[1];
    end;
  finally
    S.Free;
  end;
end;


procedure TCustomDocumntInfo.CheckDocument;
var
  gdcFullClass: TgdcFullClass;
  Key: Integer;
begin
  if FDocument = nil then
  begin
    Key := gdcBaseManager.GetIDByRUIDString(FDocumentRUID);
    gdcFullClass := TgdcDocument.GetDocumentClass(Key, GetDocumentClassPart);
    if gdcFullClass.gdClass = nil then
      raise Exception.Create(RUS_INVALIDDOCUMENTTYPE);
    FDocument := gdcFullClass.gdClass.Create(nil);
    FDocument.SubType := gdcFullClass.SubType;
    FDocument.Open;
  end;
end;

procedure TCustomDocumntInfo.CheckFields;
var
  I: Integer;
  TableName, FieldName: string;
  F: TatRelationField;
  DF: TDocumentField;
begin
  if FFields = nil then
    FFields := TObjectList.Create;

  if FFields.Count = 0 then
  begin
    CheckDocument;
    for I := 0 to FDocument.Fields.Count - 1 do
    begin
      if not FDocument.Fields[i].Calculated then
      begin
        OriginNames(FDocument.Fields[i].Origin, TableName, FieldName);
        F := atDataBase.FindRelationField(TableName, FieldName);
        if F <> nil then
        begin
          DF := TDocumentField.Create;
          DF.DocumentInfo := Self;
          FFields.Add(DF);
          DF.RelationField := F;
          DF.NameInScript := FDocument.Fields[i].FieldName;
          DF.FieldName := FDocument.Fields[i].FieldName;

          DF.DisplayName := Format('%s: %s(%s)', [GetDisplayDocumentClassPart,
            FDocument.Fields[i].FieldName, F.LName]);
        end;
      end;
    end;
  end;
end;

destructor TCustomDocumntInfo.Destroy;
begin
  FFields.Free;
  FDocument.Free;

  inherited;
end;

function TCustomDocumntInfo.Find(FieldName: string): TDocumentField;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FieldCount - 1 do
  begin
    if UpperCase(Fields[I].FieldName) = UpperCase(FieldName) then
    begin
      Result := Fields[I];
      Exit;
    end;
  end;
end;

procedure TCustomDocumntInfo.ForeignFields(ForeignTableName: string;
  List: TList);
var
  I: Integer;
  F:TatRelationField;
  Flag: Boolean;
begin
  Assert(List <> nil, 'Список неинициализирован');

  CheckFields;
  for I := 0 to FFields.Count - 1 do
  begin
    Flag := False;
    F := TDocumentField(FFields[I]).RelationField;
    repeat
      if (F <> nil) and (F.References <> nil) then
      begin
        if (UpperCase(F.References.RelationName) = UpperCase(ForeignTableName)) then
        begin
          List.Add(FFields[I]);
          Flag := True;
        end else
        begin
          F := F.ReferencesField;
        end;
      end;
    until (F = nil) or (F.References = nil) or Flag;
  end;
end;

function TCustomDocumntInfo.GetDocument: TgdcBase;
begin
  CheckDocument;
  Result := FDocument;
end;

function TCustomDocumntInfo.GetFieldCount: Integer;
begin
  CheckFields;
  Result := FFields.Count;
end;

function TCustomDocumntInfo.GetFields(Index: Integer): TDocumentField;
begin
  CheckFields;
  Result := TDocumentField(FFields[Index]);
end;

procedure TCustomDocumntInfo.SetDocumentRUID(const Value: string);
begin
  FDocumentRUID := Value;
end;

procedure TCustomDocumntInfo.SQLTypeFields(SQLType: Integer; List: TList);
var
  I: Integer;
  F:TatRelationField;
begin
  Assert(List <> nil, 'Список неинициализирован');

  CheckFields;
  for I := 0 to FFields.Count - 1 do
  begin
    F := TDocumentField(FFields[I]).RelationField;
    if (F <> nil) and (F.SQLType = SQLType) then
    begin
      List.Add(FFields[I]);
    end;
  end;
end;

{ TDocumentField }

function TDocumentField.GetFieldRepresentation: String;
begin
  if FFieldRepresentation = '' then
  begin
    case FRelationField.Field.SQLType of
      14, 37: FFieldRepresentation := 'AsString';
      12, 13, 35: FFieldRepresentation := 'AsDateTime';
      7, 8, 16:
      begin
        if FRelationField.Field.SQLSubType = 0 then
        begin
          case FRelationField.Field.SQLType of
//            7: FFieldRepresentation := 'AsSmallInt';
            7, 8, 16: FFieldRepresentation := 'AsInteger';
//            16: FFieldRepresentation := 'AsInt64'
          end;
        end else
          FFieldRepresentation := 'AsCurrency'
      end;
      11, 10: FFieldRepresentation := 'AsFloat';
      27, 9: FFieldRepresentation := 'AsCurrency';
//      9: FFieldRepresentation := 'AsQuard';
      261:
      begin
        if FRelationField.Field.SQLSubType = 1 then
        begin
          FFieldRepresentation := 'AsString';
        end else
          raise Exception.Create('Нельзя обратится к BLOB полю.')
      end;
    end;
  end;

  Result := FFieldRepresentation;
end;

function TDocumentField.Script: string;
begin
  if (FDocumentInfo <> nil) and (FRelationField <> nil) then
    Result := '[' + FDocumentInfo.NameInScript + '.' + {FRelationField.FieldName}
    FNameInScript + ']';
end;

procedure TDocumentField.SetDisplayName(const Value: string);
begin
  FDisplayName := Value;
end;

procedure TDocumentField.SetDocumentInfo(const Value: TCustomDocumntInfo);
begin
  FDocumentInfo := Value;
end;

procedure TDocumentField.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;


procedure TDocumentField.SetNameInScript(const Value: string);
begin
  FNameInScript := Value;
end;

procedure TDocumentField.SetRelationField(const Value: TatRelationField);
begin
  FRelationField := Value;
  FFieldRepresentation := '';
end;

{ TDocumentInfo }

function TDocumentInfo.GetDisplayDocumentClassPart: string;
begin
  Result := cwHeader;
end;

function TDocumentInfo.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpHeader;
end;

function TDocumentInfo.NameInScript: string;
begin
  Result := 'H'
end;

{ TDocumentLineInfo }

function TDocumentLineInfo.GetDisplayDocumentClassPart: string;
begin
  Result := cwLine
end;

function TDocumentLineInfo.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpLine
end;

function TDocumentLineInfo.NameInScript: string;
begin
  Result := 'L'
end;

end.
