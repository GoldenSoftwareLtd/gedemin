// ShlTanya, 09.02.2019

unit gd_OData;

interface

uses
  gd_ClassList, gdcBaseInterface;

type
  TgdOData = class(TObject)
  private
    function BuildServiceRoot(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
    function BuildServiceMetadata(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
    procedure ParseURL(const AnURL: String; out AClassName,
      ASubType: String; out AnID: TID);

  public
    function GetServiceRoot: String;
    function GetServiceMetadata: String;
    function GetEntitySet(const ADocument: String): String;
  end;

implementation

uses
  Classes, DB, gdcBase, at_classes, gd_common_functions, SysUtils, gdcContacts,
  gd_directories_const, gd_WebServerControl_unit, gdJSON, gdcWgPosition;

{ TgdOData }

function TgdOData.BuildServiceMetadata(ACE: TgdClassEntry; AData1,
  AData2: Pointer): Boolean;
begin
  (ACE as TgdBaseEntry).ODataBuild(TStringList(AData1), TStringList(AData2));
  Result := True;
end;

function TgdOData.BuildServiceRoot(ACE: TgdClassEntry; AData1,
  AData2: Pointer): Boolean;
begin
  if not (ACE as TgdBaseEntry).gdcClass.IsAbstractClass then
  begin
    TgdJSONWriter(AData1).BeginObject;
    TgdJSONWriter(AData1).AddValue('name', (ACE as TgdBaseEntry).GetEntitySetName);
    TgdJSONWriter(AData1).AddValue('kind', 'EntitySet');
    TgdJSONWriter(AData1).AddValue('url', (ACE as TgdBaseEntry).GetEntitySetUrl);
    TgdJSONWriter(AData1).EndObject;
  end;
  Result := True;
end;

function TgdOData.GetEntitySet(const ADocument: String): String;
var
  ClassName, SubType: String;
  ID: TID;
  I: Integer;
  BE: TgdBaseEntry;
  Obj: TgdcBase;
  SL: TStringList;
  W: TgdJSONWriter;
begin
  ParseURL(ADocument, ClassName, SubType, ID);
  BE := gdClassList.Get(TgdBaseEntry, ClassName, SubType) as TgdBaseEntry;
  SL := TStringList.Create;
  W := TgdJSONWriter.Create(SL);
  Obj := BE.gdcClass.Create(nil);
  try
    Obj.SubType := SubType;
    Obj.SubSet := 'All';
    Obj.Open;

    W.BeginObject;
    W.AddValue('@odata.context', gdWebServerControl.GetODataRoot + '/$metadata#' + BE.GetEntitySetUrl);
    W.AddValue('@odata.nextLink', gdWebServerControl.GetODataRoot + '/' + BE.GetEntitySetUrl + '?%24skiptoken=8');
    W.BeginArray('value');

    while not Obj.EOF do
    begin
      W.BeginObject;
      W.AddValue('@odata.id', gdWebServerControl.GetODataRoot + '/' + BE.GetEntitySetUrl + '(''' + TID2S(Obj.ID) + ''')');
      W.AddValue('@odata.etag', 'W/"' + FormatDateTime('yyyymmddhhnnss', Obj.EditionDate) + '"');
      W.AddValue('@odata.editLink', gdWebServerControl.GetODataRoot + '/' + BE.GetEntitySetUrl + '(''' + TID2S(Obj.ID) + ''')');

      for I := 0 to Obj.Fields.Count - 1 do
      begin
        W.AddField(Obj.Fields[I]);
      end;

      W.EndObject;
      Obj.Next;
    end;

    W.EndArray;
    W.EndObject;
    Result := SL.Text;
  finally
    SL.Free;
    Obj.Free;
  end;
end;

function TgdOData.GetServiceMetadata: String;
var
  SL, SL2: TStringList;
begin
  SL := TStringList.Create;
  SL2 := TStringList.Create;
  try
    gdClassList.Traverse(TgdcWgPosition, '', BuildServiceMetadata, SL, SL2);
    Result :=
      '<?xml version="1.0" encoding="Windows-1251"?>' +
      '<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">' +
      '  <edmx:DataServices>' +
      '    <Schema Namespace="' + ODataNS + '" xmlns="http://docs.oasis-open.org/odata/ns/edm">' +
      SL.Text +
      '      <EntityContainer Name="DefaultContainer">' +
      SL2.Text +
      '      </EntityContainer>' +
      '    </Schema>' +
      '  </edmx:DataServices>' +
      '</edmx:Edmx>';
  finally
    SL.Free;
  end;
end;

function TgdOData.GetServiceRoot: String;
var
  SL: TStringList;
  W: TgdJSONWriter;
begin
  SL := TStringList.Create;
  W := TgdJSONWriter.Create(SL);
  try
    W.BeginObject;
    W.AddValue('@odata.context', gdWebServerControl.GetODataRoot + '/$metadata');
    W.BeginArray('value');
    gdClassList.Traverse(TgdcWgPosition, '', BuildServiceRoot, W, nil);
    W.EndArray;
    W.EndObject;

    Result := SL.Text;
  finally
    W.Free;
    SL.Free;
  end;
end;

{

  OData/TgdcContact+MySubType(12345)
        ^          ^         ^     ^
        C          S         IDB   IDE

}

procedure TgdOData.ParseURL(const AnURL: String; out AClassName,
  ASubType: String; out AnID: TID);
var
  P, B, E: Integer;
begin
  P := Pos('+', AnURL);
  B := Length(ODataRoot) + 2;
  E := Pos('(', AnURL);
  if E = 0 then
    E := Length(AnURL);
  if P > 0 then
  begin
    AClassName := Copy(AnURL, B, P - B - 1);
    ASubType := Copy(AnURL, P + 1, E - P - 1);
  end else
  begin
    AClassName := Copy(AnURL, Length(ODataRoot) + 2, E - B);
    ASubType := '';
  end;
  AnID := -1;
end;

end.
