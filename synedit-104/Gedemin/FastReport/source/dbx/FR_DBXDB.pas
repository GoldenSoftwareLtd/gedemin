
{******************************************}
{                                          }
{     FastReport v2.4 - DBX components     }
{            Database component            }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_DBXDB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs, DB, DBXpress, SqlExpr;

type
  TfrDBXComponents = class(TComponent) // fake component
  end;

  TfrDBXDatabase = class(TfrNonVisualControl)
  private
    FDatabase: TSQLConnection;
    procedure LinesEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefineProperties; override;
    property Database: TSQLConnection read FDatabase;
  end;


implementation

uses FR_Utils, FR_Const, FR_LEdit, FR_DBLookupCtl, FR_DBXTable, FR_DBXQuery
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{$R FR_DBX.res}

type
  THackSQLConnection = class(TSQLConnection)
  end;


{ TfrDBXDatabase }

constructor TfrDBXDatabase.Create;
begin
  inherited Create;
  FDatabase := TSQLConnection.Create(frDialogForm);
// set ComponentState := csDesigning to obtain Params automatically
  THackSQLConnection(FDataBase).SetDesigning(True, False);
  Component := FDatabase;
  BaseName := 'Database';
  Bmp.LoadFromResourceName(hInstance, 'FR_DBXDB');
  Flags := Flags or flDontUndo;
end;

destructor TfrDBXDatabase.Destroy;
begin
  FDatabase.Free;
  inherited Destroy;
end;

procedure TfrDBXDatabase.DefineProperties;

  function _GetConnectionNames: String;
  var
    i: Integer;
    sl: TStringList;
  begin
    Result := '';
    sl := TStringList.Create;
    GetConnectionNames(sl);
    sl.Sort;
    for i := 0 to sl.Count - 1 do
      Result := Result + sl[i] + ';';
    sl.Free;
  end;

  function _GetDriverNames: String;
  var
    i, j: Integer;
    sl: TStringList;
    s: String;
  begin
    Result := '';
    sl := TStringList.Create;
    GetDriverNames(sl);
    sl.Sort;
    for i := 0 to sl.Count - 1 do
    begin
      s := sl[i];
      for j := 1 to Length(s) do
        if s[j] = ';' then
          s[j] := ',';
      Result := Result + s + ';';
    end;
    sl.Free;
  end;

begin
  inherited DefineProperties;
  AddProperty('Connected', [frdtBoolean], nil);
  AddEnumProperty('ConnectionName', _GetConnectionNames, [Null]);
  AddEnumProperty('DriverName', _GetDriverNames, [Null]);
  AddProperty('LoginPrompt', [frdtBoolean], nil);
  AddProperty('Params', [frdtHasEditor, frdtOneObject], LinesEditor);
  AddProperty('Params.Count', [], nil);
end;

procedure TfrDBXDatabase.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'CONNECTIONNAME' then
    FDatabase.ConnectionName := Value
  else if Index = 'DRIVERNAME' then
    FDatabase.DriverName := Value
  else if Index = 'LOGINPROMPT' then
    FDatabase.LoginPrompt := Value
  else if Index = 'CONNECTED' then
    FDatabase.Connected := Value
  else if Index = 'PARAMS' then
    FDatabase.Params.Text := Value
end;

function TfrDBXDatabase.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'CONNECTIONNAME' then
    Result := FDatabase.ConnectionName
  else if Index = 'DRIVERNAME' then
    Result := FDatabase.DriverName
  else if Index = 'LOGINPROMPT' then
    Result := FDatabase.LoginPrompt
  else if Index = 'CONNECTED' then
    Result := FDatabase.Connected
  else if Index = 'PARAMS.COUNT' then
    Result := FDatabase.Params.Count
  else if Index = 'PARAMS' then
    Result := FDatabase.Params.Text
end;

function TfrDBXDataBase.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(FDataBase.Params, MethodName, 'PARAMS', Par1, Par2, Par3);
end;

procedure TfrDBXDatabase.LoadFromStream(Stream: TStream);
var
  s: String;
begin
  inherited LoadFromStream(Stream);
  FDatabase.ConnectionName := frReadString(Stream);
  s := frReadString(Stream);
  if s <> '' then
    FDatabase.DriverName := s;
  FDatabase.LoginPrompt := frReadBoolean(Stream);
  frReadMemo(Stream, FDatabase.Params);
  FDatabase.Connected := frReadBoolean(Stream);
end;

procedure TfrDBXDatabase.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, FDatabase.ConnectionName);
  frWriteString(Stream, FDatabase.DriverName);
  frWriteBoolean(Stream, FDatabase.LoginPrompt);
  frWriteMemo(Stream, FDatabase.Params);
  frWriteBoolean(Stream, FDatabase.Connected);
end;

procedure TfrDBXDatabase.LinesEditor(Sender: TObject);
var
  SaveConnected: Boolean;
begin
  with TfrLinesEditorForm.Create(nil) do
  begin
    M1.Text := FDatabase.Params.Text;
    if (ShowModal = mrOk) and ((Restrictions and frrfDontModify) = 0) and
      M1.Modified then
    begin
      SaveConnected := FDatabase.Connected;
      FDatabase.Connected := False;
      FDatabase.Params.Text := M1.Text;
      FDatabase.Connected := SaveConnected;
      frDesigner.Modified := True;
    end;
    Free;
  end;
end;


var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_DBXDBCONTROL');
  frRegisterControl(TfrDBXDatabase, Bmp, IntToStr(SInsertDB));

finalization
  frUnRegisterObject(TfrDBXDatabase);
  Bmp.Free;

end.

