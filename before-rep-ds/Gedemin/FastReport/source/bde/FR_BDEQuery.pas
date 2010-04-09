
{******************************************}
{                                          }
{     FastReport v2.4 - BDE components     }
{             Query component              }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_BDEQuery;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, StdCtrls, Controls, Forms,
  Menus, Dialogs, FR_Class, FR_Pars, DB, DBTables, FR_BDETable, FR_DBUtils;

type
  TfrBDEQuery = class(TfrBDEDataSet)
  private
    FQuery: TQuery;
    FParams: TfrVariables;
    procedure SQLEditor(Sender: TObject);
    procedure ParamsEditor(Sender: TObject);
    procedure ReadParams(Stream: TStream);
    procedure WriteParams(Stream: TStream);
    function GetParamKind(Index: Integer): TfrParamKind;
    procedure SetParamKind(Index: Integer; Value: TfrParamKind);
    function GetParamText(Index: Integer): String;
    procedure SetParamText(Index: Integer; Value: String);
    procedure BeforeOpenQuery(DataSet: TDataSet);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    procedure Loaded; override;
    property Query: TQuery read FQuery;
    property ParamKind[Index: Integer]: TfrParamKind read GetParamKind write SetParamKind;
    property ParamText[Index: Integer]: String read GetParamText write SetParamText;
  end;


implementation

uses
  FR_Utils, FR_Const, FR_DBSQLEdit, FR_BDEQueryParam, TypInfo
{$IFDEF QBUILDER}
, FR_BDEQB, QBuilder
{$ENDIF}
{$IFDEF Delphi6}
, Variants
{$ENDIF};


{ TfrBDEQuery }

constructor TfrBDEQuery.Create;
begin
  inherited Create;
  FQuery := TQuery.Create(frDialogForm);
  FQuery.BeforeOpen := BeforeOpenQuery;
  FDataSet := FQuery;
  FDataSource.DataSet := FDataSet;

  FParams := TfrVariables.Create;

  Component := FQuery;
  BaseName := 'Query';
  Bmp.LoadFromResourceName(hInstance, 'FR_BDEQUERY');
end;

destructor TfrBDEQuery.Destroy;
begin
  FParams.Free;
  inherited Destroy;
end;

procedure TfrBDEQuery.DefineProperties;

  function GetMasterSource: String;
  var
    i: Integer;
    sl: TStringList;
  begin
    Result := '';
    sl := TStringList.Create;
    frGetComponents(FQuery.Owner, TDataSet, sl, FQuery);
    sl.Sort;
    for i := 0 to sl.Count - 1 do
      Result := Result + sl[i] + ';';
    sl.Free;
  end;

begin
  inherited DefineProperties;
  AddEnumProperty('DataSource', GetMasterSource, [Null]);
  AddProperty('Params', [frdtHasEditor], ParamsEditor);
  AddProperty('SQL', [frdtHasEditor], SQLEditor);
  AddProperty('SQL.Count', [], nil);
end;

procedure TfrBDEQuery.SetPropValue(Index: String; Value: Variant);
var
  d: TDataset;
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'DATASOURCE' then
  begin
    d := frFindComponent(FQuery.Owner, Value) as TDataSet;
    FQuery.DataSource := frGetDataSource(FQuery.Owner, d);
  end
  else if Index = 'SQL' then
    FQuery.SQL.Text := Value
end;

function TfrBDEQuery.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATASOURCE' then
    Result := frGetDataSetName(FQuery.Owner, FQuery.DataSource)
  else if Index = 'SQL' then
    Result := FQuery.SQL.Text
  else if Index = 'SQL.COUNT' then
    Result := FQuery.SQL.Count
end;

function TfrBDEQuery.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(FQuery.SQL, MethodName, 'SQL', Par1, Par2, Par3);
  if MethodName = 'EXECSQL' then
  begin
    BeforeOpenQuery(FQuery);
    FQuery.ExecSQL
  end;
end;

procedure TfrBDEQuery.LoadFromStream(Stream: TStream);
var
  s: String;
begin
  FFixupList.Clear;
  inherited LoadFromStream(Stream);
  FQuery.DatabaseName := frReadString(Stream);
  FQuery.Filter := frReadString(Stream);
  FQuery.Filtered := Trim(FQuery.Filter) <> '';
  s := frReadString(Stream);
  FFixupList['DataSource'] := s;
  Prop['DataSource'] := FFixupList['DataSource'];
  frReadMemo(Stream, FQuery.SQL);

  FFixupList['Active'] := frReadBoolean(Stream);
  ReadFields(Stream);
  ReadParams(Stream);
  try
    FQuery.Active := FFixupList['Active'];
  except;
  end;
end;

procedure TfrBDEQuery.SaveToStream(Stream: TStream);
begin
  LVersion := 1;
  inherited SaveToStream(Stream);
  frWriteString(Stream, FQuery.DatabaseName);
  frWriteString(Stream, FQuery.Filter);
  frWriteString(Stream, Prop['DataSource']);
  frWriteMemo(Stream, FQuery.SQL);
  frWriteBoolean(Stream, FQuery.Active);
  WriteFields(Stream);
  WriteParams(Stream);
end;

procedure TfrBDEQuery.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

  procedure WriteParams;
  var
    i: Integer;
    wr: TWriter;
    ms: TMemoryStream;
    v: TValueType;
    s: String;
  begin
    ms := TMemoryStream.Create;
    wr := TWriter.Create(ms, 4096);

    v := vaCollection;
    wr.WriteStr('Params');
    wr.Write(v, SizeOf(v));

    for i := 0 to FQuery.Params.Count - 1 do
      with FQuery.Params[i] do
      begin
        wr.WriteListBegin;
        wr.WriteStr('Name');
        wr.WriteString(Name);
        wr.WriteStr('DataType');
        v := vaIdent;
        wr.Write(v, SizeOf(v));
        s := GetEnumName(TypeInfo(TFieldType), Integer(DataType));
        wr.WriteStr(s);
        wr.WriteStr('Expression');
        wr.WriteString(ParamText[i]);
        wr.WriteListEnd;
      end;

    wr.WriteListEnd;
    wr.Free;
    WriteStr(' Propdata="' + frStreamToString(ms) + '"');
    ms.Free;
  end;

begin
  inherited;
  WriteStr(' SQL.text="' + StrToXML(FQuery.SQL.Text) + '"');
  if FQuery.Params.Count > 0 then
    WriteParams;
end;

procedure TfrBDEQuery.Loaded;
begin
  Prop['DataSource'] := FFixupList['DataSource'];
  inherited Loaded;
end;

procedure TfrBDEQuery.SQLEditor(Sender: TObject);
begin
  with TfrDBSQLEditorForm.Create(nil) do
  begin
    Query := FQuery;
    M1.Lines.Assign(FQuery.SQL);
{$IFDEF QBUILDER}
    QBEngine := TfrQBBDEEngine.Create(nil);
    TfrQBBDEEngine(QBEngine).Query := FQuery;
    QBEngine.DatabaseName := FQuery.DatabaseName;
{$ENDIF}
    if (ShowModal = mrOk) and ((Restrictions and frrfDontModify) = 0) then
    begin
      FQuery.SQL := M1.Lines;
      frDesigner.Modified := True;
    end;
{$IFDEF QBUILDER}
    QBEngine.Free;
{$ENDIF}
    Free;
  end;
end;

procedure TfrBDEQuery.ParamsEditor(Sender: TObject);
var
  Params: TParams;
  ParamValues: TfrVariables;
begin
  if FQuery.Params.Count > 0 then
  begin
    Params := TParams.Create;
    Params.Assign(FQuery.Params);
    ParamValues := TfrVariables.Create;
    ParamValues.Assign(FParams);
    with TfrBDEParamsForm.Create(nil) do
    begin
      QueryComp := Self;
      Query := FQuery;
      Caption := Self.Name + ' ' + frLoadStr(SParams);
      if ShowModal = mrOk then
        frDesigner.Modified := True
      else
      begin
        FQuery.Params.Assign(Params);
        FParams.Assign(ParamValues);
      end;
      Free;
    end;
    Params.Free;
    ParamValues.Free;
  end;
end;

function TfrBDEQuery.GetParamKind(Index: Integer): TfrParamKind;
begin
  Result := pkValue;
  if not FQuery.Params[Index].Bound then
    Result := pkAssignFromMaster;
end;

procedure TfrBDEQuery.SetParamKind(Index: Integer; Value: TfrParamKind);
begin
  if Value = pkAssignFromMaster then
  begin
    FQuery.Params[Index].Bound := False;
    FParams.Delete(FParams.IndexOf(FQuery.Params[Index].Name));
  end
  else
  begin
    FQuery.Params[Index].Clear;
    FQuery.Params[Index].Bound := True;
    FParams[FQuery.Params[Index].Name] := '';
  end;
end;

function TfrBDEQuery.GetParamText(Index: Integer): String;
begin
  Result := '';
  if ParamKind[Index] = pkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

procedure TfrBDEQuery.SetParamText(Index: Integer; Value: String);
begin
  if ParamKind[Index] = pkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

procedure TfrBDEQuery.ReadParams(Stream: TStream);
var
  i: Integer;
  w, n: Word;
begin
  Stream.Read(n, 2);
  for i := 0 to n - 1 do
  with FQuery.Params[i] do
  begin
    Stream.Read(w, 2);
    DataType := ParamTypes[w];
    Stream.Read(w, 2);
    ParamKind[i] := TfrParamKind(w);
    ParamText[i] := frReadString(Stream);
  end;
end;

procedure TfrBDEQuery.WriteParams(Stream: TStream);
var
  i: Integer;
  w: Word;
begin
  w := FQuery.Params.Count;
  Stream.Write(w, 2);
  for i := 0 to FQuery.Params.Count - 1 do
  with FQuery.Params[i] do
  begin
    for w := 0 to 10 do
      if DataType = ParamTypes[w] then
        break;
    Stream.Write(w, 2);
    w := Word(ParamKind[i]);
    Stream.Write(w, 2);
    frWriteString(Stream, ParamText[i]);
  end;
end;

procedure TfrBDEQuery.BeforeOpenQuery(DataSet: TDataSet);
var
  i: Integer;
  SaveView: TfrView;
  SavePage: TfrPage;
  SaveBand: TfrBand;

  function DefParamValue(Param: TParam): String;
  begin
    if Param.DataType in [ftDate, ftDateTime] then
      Result := '01.01.00'
    else if Param.DataType = ftTime then
      Result := '00:00'
    else
      Result := '0';
  end;

begin
  SaveView := CurView;
  CurView := nil;
  SavePage := CurPage;
  CurPage := ParentPage;
  SaveBand := CurBand;
  CurBand := nil;
  i := 0;
  try
    while i < FQuery.Params.Count do
    begin
      if ParamKind[i] = pkValue then
        if DocMode = dmPrinting then
          FQuery.Params[i].Text := frParser.Calc(ParamText[i]) else
          FQuery.Params[i].Text := DefParamValue(FQuery.Params[i]);
      Inc(i);
    end;
  except
    Memo.Clear;
    Memo.Add(ParamText[i]);
    CurView := Self;
    raise;
  end;
  CurView := SaveView;
  CurPage := SavePage;
  CurBand := SaveBand;
end;


var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_BDEQUERYCONTROL');
  frRegisterControl(TfrBDEQuery, Bmp, IntToStr(SInsertQuery));

finalization
  frUnRegisterObject(TfrBDEQuery);
  Bmp.Free;

end.

