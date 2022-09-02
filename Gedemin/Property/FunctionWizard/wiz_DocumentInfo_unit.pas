// ShlTanya, 09.03.2019

unit wiz_DocumentInfo_unit;

interface

uses
  gdcBase, gdcBaseInterface, gdcConstants, gdcClasses_interface, gdcClasses,
  wiz_Strings_unit, contnrs, at_Classes, classes, Sysutils;

type
  TCustomDocumntInfo = class;

  TDocumentField = class
  private
    FDisplayName: String;
    FRelationField: TatRelationField;
    FDocumentInfo: TCustomDocumntInfo;
    FNameInScript: String;
    FFieldName: String;
    FFieldRepresentation: String;

    procedure SetDisplayName(const Value: String);
    procedure SetRelationField(const Value: TatRelationField);
    procedure SetDocumentInfo(const Value: TCustomDocumntInfo);
    procedure SetNameInScript(const Value: String);
    procedure SetFieldName(const Value: String);
    function GetFieldRepresentation: String;

  public
    function Script: String;

    property RelationField: TatRelationField read FRelationField write SetRelationField;
    property DisplayName: String read FDisplayName write SetDisplayName;
    property DocumentInfo: TCustomDocumntInfo read FDocumentInfo write SetDocumentInfo;
    property NameInScript: String read FNameInScript write SetNameInScript;
    property FieldName: String read FFieldName write SetFieldName;
    property FieldRepresentation: String read GetFieldRepresentation ;
  end;

  TCustomDocumntInfo = class
  private
    FDocumentRUID: String;
    FDocument: TgdcBase;
    FFields: TObjectList;

    procedure SetDocumentRUID(const Value: String);
    function GetDocument: TgdcBase;
    function GetFields(Index: Integer): TDocumentField;
    function GetFieldCount: Integer;
    procedure CheckDocument;
    procedure CheckFields;

  protected
    function GetDocumentClassPart: TgdcDocumentClassPart;virtual; abstract;
    function GetDisplayDocumentClassPart: String; virtual; abstract;

  public
    destructor Destroy; override;

    function NameInScript: String; virtual; abstract;
    procedure ForeignFields(ForeignTableName: String; List: TList);
    procedure SQLTypeFields(SQLType: Integer; List: TList);
    function Find(FieldName: String): TDocumentField;

    property Document: TgdcBase read GetDocument;
    property DocumentRUID: String read FDocumentRUID write SetDocumentRUID;
    property Fields[Index: Integer]: TDocumentField read GetFields; default;
    property FieldCount: Integer read GetFieldCount;
  end;

  TDocumentInfo = class(TCustomDocumntInfo)
  protected
    function GetDocumentClassPart: TgdcDocumentClassPart; override;
    function GetDisplayDocumentClassPart: String; override;

  public
    function NameInScript: String; override;
  end;

  TDocumentLineInfo = class(TCustomDocumntInfo)
  protected
    function GetDocumentClassPart: TgdcDocumentClassPart; override;
    function GetDisplayDocumentClassPart: String; override;

  public
    function NameInScript: String; override;
  end;

implementation

uses
  gd_common_functions;

{ TCustomDocumntInfo }

procedure TCustomDocumntInfo.CheckDocument;
var
  gdcFullClass: TgdcFullClass;
  Key: TID;
begin
  if FDocument = nil then
  begin
    Key := gdcBaseManager.GetIDByRUIDString(FDocumentRUID);
    gdcFullClass := TgdcDocument.GetDocumentClass(Key, GetDocumentClassPart);
    if gdcFullClass.gdClass = nil then
      raise Exception.Create(RUS_INVALIDDOCUMENTTYPE);
    FDocument := gdcFullClass.gdClass.Create(nil);
    FDocument.SubType := gdcFullClass.SubType;

    // https://github.com/GoldenSoftwareLtd/gedemin/issues/3694
    // открывать датасет с большим количеством записей
    // может быть накладно по времени (особенно, если там
    // присутствует сортировка или группировка)
    // заведомо открываем с нулЄм записей
    // так как нам надо только информаци€ о пол€х
    FDocument.SubSet := 'ByID';
    FDocument.ID := 0;

    FDocument.Open;
  end;
end;

procedure TCustomDocumntInfo.CheckFields;
var
  I: Integer;
  TableName, FieldName: String;
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
        ParseFieldOrigin(FDocument.Fields[i].Origin, TableName, FieldName);
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

function TCustomDocumntInfo.Find(FieldName: String): TDocumentField;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FieldCount - 1 do
  begin
    if AnsiSameText(Fields[I].FieldName, FieldName) then
    begin
      Result := Fields[I];
      exit;
    end;
  end;
end;

procedure TCustomDocumntInfo.ForeignFields(ForeignTableName: String;
  List: TList);
var
  I: Integer;
  F:TatRelationField;
  Flag: Boolean;
begin
  Assert(List <> nil, '—писок не инициализирован');

  CheckFields;
  for I := 0 to FFields.Count - 1 do
  begin
    Flag := False;
    F := TDocumentField(FFields[I]).RelationField;
    repeat
      if (F <> nil) and (F.References <> nil) then
      begin
        if AnsiSameText(F.References.RelationName, ForeignTableName) then
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

procedure TCustomDocumntInfo.SetDocumentRUID(const Value: String);
begin
  FDocumentRUID := Value;
end;

procedure TCustomDocumntInfo.SQLTypeFields(SQLType: Integer; List: TList);
var
  I: Integer;
  F:TatRelationField;
begin
  Assert(List <> nil, '—писок не инициализирован');

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
        if FRelationField.Field.FieldScale < 0 then
          FFieldRepresentation := 'AsCurrency'
        else
          case FRelationField.Field.SQLType of
            7, 8: FFieldRepresentation := 'AsInteger';
          else
            FFieldRepresentation := 'AsCurrency';
          end;
      end;
      11, 10: FFieldRepresentation := 'AsFloat';
      27, 9: FFieldRepresentation := 'AsCurrency';
      261:
      begin
        if FRelationField.Field.SQLSubType = 1 then
        begin
          FFieldRepresentation := 'AsString';
        end else
          raise Exception.Create('Ќельз€ обратитьс€ к BLOB полю.')
      end;
    end;
  end;

  Result := FFieldRepresentation;
end;

function TDocumentField.Script: String;
begin
  if (FDocumentInfo <> nil) and (FRelationField <> nil) then
    Result := '[' + FDocumentInfo.NameInScript + '.' + FNameInScript + ']';
end;

procedure TDocumentField.SetDisplayName(const Value: String);
begin
  FDisplayName := Value;
end;

procedure TDocumentField.SetDocumentInfo(const Value: TCustomDocumntInfo);
begin
  FDocumentInfo := Value;
end;

procedure TDocumentField.SetFieldName(const Value: String);
begin
  FFieldName := Value;
end;

procedure TDocumentField.SetNameInScript(const Value: String);
begin
  FNameInScript := Value;
end;

procedure TDocumentField.SetRelationField(const Value: TatRelationField);
begin
  FRelationField := Value;
  FFieldRepresentation := '';
end;

{ TDocumentInfo }

function TDocumentInfo.GetDisplayDocumentClassPart: String;
begin
  Result := cwHeader;
end;

function TDocumentInfo.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpHeader;
end;

function TDocumentInfo.NameInScript: String;
begin
  Result := 'H'
end;

{ TDocumentLineInfo }

function TDocumentLineInfo.GetDisplayDocumentClassPart: String;
begin
  Result := cwLine
end;

function TDocumentLineInfo.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpLine
end;

function TDocumentLineInfo.NameInScript: String;
begin
  Result := 'L'
end;

end.
