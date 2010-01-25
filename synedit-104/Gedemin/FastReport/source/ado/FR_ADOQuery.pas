
{******************************************}
{                                          }
{     FastReport v2.4 - ADO components     }
{             Query component              }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_ADOQuery;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, StdCtrls, Controls, Forms,
  Menus, Dialogs, FR_Class, FR_Pars, DB, ADODB, ADOInt, FR_ADOTable, FR_DBUtils;

type
  TfrADOQuery = class(TfrADODataSet)
  private
    FQuery: TADOQuery;
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
    property Query: TADOQuery read FQuery;
    property ParamKind[Index: Integer]: TfrParamKind read GetParamKind write SetParamKind;
    property ParamText[Index: Integer]: String read GetParamText write SetParamText;
  end;


implementation

uses
  FR_Utils, FR_Const, FR_DBSQLEdit, FR_ADOQueryParam
{$IFDEF QBUILDER} 
, FR_ADOQB, QBuilder
{$ENDIF}
, TypInfo
{$IFDEF Delphi6}
, Variants
{$ENDIF};


{ TfrADOQuery }

constructor TfrADOQuery.Create;
begin
  inherited Create;
  FQuery := TADOQuery.Create(frDialogForm);
  FQuery.BeforeOpen := BeforeOpenQuery;
  FQuery.EnableBCD := False;
  FDataSet := TADODataSet(FQuery);
  FDataSource.DataSet := FDataSet;

  FParams := TfrVariables.Create;

  Component := FQuery;
  BaseName := 'Query';
  Bmp.LoadFromResourceName(hInstance, 'FR_ADOQUERY');
end;

destructor TfrADOQuery.Destroy;
begin
  FParams.Free;
  inherited Destroy;
end;

procedure TfrADOQuery.DefineProperties;

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

procedure TfrADOQuery.SetPropValue(Index: String; Value: Variant);
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

function TfrADOQuery.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATASOURCE' then
    Result := frGetDataSetName(FQuery.Owner, FQuery.DataSource)
  else if Index = 'SQL' then
    Result := FQuery.SQL.Text
  else if Index = 'SQL.COUNT' then
    Result := FQuery.SQL.Count;
end;

function TfrADOQuery.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
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

procedure TfrADOQuery.LoadFromStream(Stream: TStream);
var
  s: String;
begin
  FFixupList.Clear;
  inherited LoadFromStream(Stream);
  FFixupList['DataBase'] := frReadString(Stream);
  Prop['DataBase'] := FFixupList['DataBase'];
  FQuery.Filter := frReadString(Stream);
  FQuery.Filtered := Trim(FQuery.Filter) <> '';
  s := frReadString(Stream);
  FFixupList['DataSource'] := s;
  Prop['DataSource'] := FFixupList['DataSource'];
  frReadMemo(Stream, FQuery.SQL);
  FFixupList['Active'] := frReadBoolean(Stream);

  if LVersion >= 2 then
    Prop['EnableBCD'] := frReadBoolean(Stream);

  ReadFields(Stream);
  ReadParams(Stream);
  try
    FQuery.Active := FFixupList['Active'];
  except;
  end;
end;

procedure TfrADOQuery.SaveToStream(Stream: TStream);
begin
  LVersion := 2;
  inherited SaveToStream(Stream);
  frWriteString(Stream, Prop['DataBase']);
  frWriteString(Stream, FQuery.Filter);
  frWriteString(Stream, Prop['DataSource']);
  frWriteMemo(Stream, FQuery.SQL);
  frWriteBoolean(Stream, FQuery.Active);
  frWriteBoolean(Stream, FQuery.EnableBCD);
  WriteFields(Stream);
  WriteParams(Stream);
end;

procedure TfrADOQuery.SaveToFR3Stream(Stream: TStream);

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

    for i := 0 to FQuery.Parameters.Count - 1 do
      with FQuery.Parameters[i] do
      begin
        wr.WriteListBegin;
        wr.WriteStr('Name');
        wr.WriteString(Name);
        wr.WriteStr('DataType');
        v := vaIdent;
        wr.Write(v, SizeOf(v));
        s := GetEnumName(TypeInfo(TDataType), Integer(DataType));
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
  if FQuery.Parameters.Count > 0 then
    WriteParams;
end;

procedure TfrADOQuery.Loaded;
begin
  Prop['DataSource'] := FFixupList['DataSource'];
  inherited Loaded;
end;

procedure TfrADOQuery.SQLEditor(Sender: TObject);
begin
  with TfrDBSQLEditorForm.Create(nil) do
  begin
    Query := FQuery;
    M1.Lines.Assign(FQuery.SQL);
{$IFDEF QBUILDER}
    QBEngine := TfrQBADOEngine.Create(nil);
    TfrQBADOEngine(QBEngine).Query := FQuery;
    QBEngine.DatabaseName := Prop['Database'];
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

procedure TfrADOQuery.ParamsEditor(Sender: TObject);
var
  Params: TParameters;
  ParamValues: TfrVariables;
  vParam: TParameter; //***ITSDEV
  TempQry : TADOQuery; //***ITSDEV
  i : Integer ;    //***ITSDEV
begin
  //***ITSDEV ->  Fixes TADOQuery not creating parameters
  TempQry := TADOQuery.Create(frDialogForm);   //Create a temporary Query
  TempQry.Parameters.ParseSQL(FQuery.SQL.Text,true);
     for i := 0 to (TempQry.Parameters.Count-1) do
      begin
      if (FQuery.Parameters.FindParam(TempQry.Parameters.Items[i].Name) = nil)
         then
          begin
          vParam := FQuery.Parameters.AddParameter;
          vParam.Name := TempQry.Parameters.Items[i].Name;
          End;

       end;
       vParam := nil;
      TempQry.Free;
      vParam.Free;
   //<-***ITSDEV

  if FQuery.Parameters.Count > 0 then
  begin
    Params := TParameters.Create(FQuery, TParameter);

    Params.AssignValues(FQuery.Parameters);
//    Params.Assign(FQuery.Parameters);

    ParamValues := TfrVariables.Create;
    ParamValues.Assign(FParams);
    with TfrADOParamsForm.Create(nil) do
    begin
      QueryComp := Self;
      Query := FQuery;
      Caption := Self.Name + ' ' + frLoadStr(SParams);
      if ShowModal = mrOk then
        frDesigner.Modified := True
      else
      begin
        FQuery.Parameters.AssignValues(Params);
        FParams.Assign(ParamValues);
      end;
      Free;
    end;
    Params.Free;
    ParamValues.Free;
  end;
end;

function TfrADOQuery.GetParamKind(Index: Integer): TfrParamKind;
begin
  Result := pkValue;
  if not (paNullable in FQuery.Parameters[Index].Attributes) then
    Result := pkAssignFromMaster;
end;

procedure TfrADOQuery.SetParamKind(Index: Integer; Value: TfrParamKind);
begin
  if Value = pkAssignFromMaster then
  begin
    FQuery.Parameters[Index].Attributes := [];
    FParams.Delete(FParams.IndexOf(FQuery.Parameters[Index].Name));
  end
  else
  begin
    FQuery.Parameters[Index].Attributes := [paNullable];
    FParams[FQuery.Parameters[Index].Name] := '';
  end;
end;

function TfrADOQuery.GetParamText(Index: Integer): String;
var
  v: Variant;
begin
  v := '';
  if ParamKind[Index] = pkValue then
    v := FParams[FQuery.Parameters[Index].Name];
  if v = Null then
    v := '';
  Result := v;
end;

procedure TfrADOQuery.SetParamText(Index: Integer; Value: String);
begin
  if ParamKind[Index] = pkValue then
    FParams[FQuery.Parameters[Index].Name] := Value;
end;

procedure TfrADOQuery.ReadParams(Stream: TStream);
var
  i: Integer;
  w, n: Word;
begin
  Stream.Read(n, 2);
  for i := 0 to n - 1 do
  with FQuery.Parameters[i] do
  begin
    Stream.Read(w, 2);
    DataType := ParamTypes[w];
    Stream.Read(w, 2);
    ParamKind[i] := TfrParamKind(w);
    ParamText[i] := frReadString(Stream);
  end;
end;

procedure TfrADOQuery.WriteParams(Stream: TStream);
var
  i: Integer;
  w: Word;
begin
  w := FQuery.Parameters.Count;
  Stream.Write(w, 2);
  for i := 0 to FQuery.Parameters.Count - 1 do
  with FQuery.Parameters[i] do
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

procedure TfrADOQuery.BeforeOpenQuery(DataSet: TDataSet);
var
  i: Integer;
  SaveView: TfrView;
  SavePage: TfrPage;
  SaveBand: TfrBand;

  function DefParamValue(Param: TParameter): String;
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
    while i < FQuery.Parameters.Count do
    begin
      if ParamKind[i] = pkValue then
        if DocMode = dmPrinting then
          FQuery.Parameters[i].Value := frParser.Calc(ParamText[i]) else
          FQuery.Parameters[i].Value := DefParamValue(FQuery.Parameters[i]);
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
  Bmp.LoadFromResourceName(hInstance, 'FR_ADOQUERYCONTROL');
  frRegisterControl(TfrADOQuery, Bmp, IntToStr(SInsertQuery));

finalization
  frUnRegisterObject(TfrADOQuery);
  Bmp.Free;

end.

