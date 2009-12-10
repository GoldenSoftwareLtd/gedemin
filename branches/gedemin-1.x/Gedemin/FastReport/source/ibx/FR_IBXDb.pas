
{******************************************}
{                                          }
{    FastReport v2.4 - IBX components      }
{           Database component             }
{                                          }
{        Copyright (c) 2000 by EMS         }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_IBXDB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs, DB, IBDatabase;

type
  TfrIBXComponents = class(TComponent) // fake component
  end;

  TfrIBXDatabase = class(TfrNonVisualControl)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    procedure LinesEditor(Sender: TObject);
    procedure DBNameEditor(Sender: TObject);
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
    procedure ShowEditor; override;
    property Database: TIBDatabase read FDatabase;
  end;


implementation

uses
  FR_Utils, FR_DBUtils, FR_Const, FR_LEdit, FR_DBLookupCtl,
  FR_IBXTable, FR_IBXQuery
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{$R FR_IBX.RES}


{ TfrIBXDatabase }

constructor TfrIBXDatabase.Create;
begin
  inherited Create;
  FDatabase := TIBDataBase.Create(frDialogForm);
  FTransaction := TIBTransaction.Create(frDialogForm);
  FDatabase.DefaultTransaction := FTransaction;
  Component := FDatabase;
  BaseName := 'Database';
  Bmp.LoadFromResourceName(hInstance, 'FR_IBXDB');
  Flags := Flags or flDontUndo;
end;

destructor TfrIBXDatabase.Destroy;
begin
  FTransaction.Free;
  FDatabase.Free;
  inherited Destroy;
end;

procedure TfrIBXDatabase.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Connected', [frdtBoolean], nil);
  AddProperty('DatabaseName', [frdtString], DBNameEditor);
  AddProperty('LoginPrompt', [frdtBoolean], nil);
  AddProperty('Params', [frdtHasEditor, frdtOneObject], LinesEditor);
  AddProperty('Params.Count', [], nil);
  AddProperty('SQLDialect', [frdtInteger], nil);
end;

procedure TfrIBXDatabase.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'DATABASENAME' then
    FDatabase.DatabaseName := Value
  else if Index = 'LOGINPROMPT' then
    FDatabase.LoginPrompt := Value
  else if Index = 'CONNECTED' then begin
    FDatabase.Connected := Value;
    if Assigned(FDataBase.DefaultTransaction) then
      FDataBase.DefaultTransaction.Active := Value;
  end
  else if Index = 'PARAMS' then
    FDatabase.Params.Text := Value
  else if Index = 'SQLDIALECT' then
    FDatabase.SQLDialect := Value
end;

function TfrIBXDatabase.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATABASENAME' then
    Result := FDataBase.DatabaseName
  else if Index = 'LOGINPROMPT' then
    Result := FDataBase.LoginPrompt
  else if Index = 'CONNECTED' then
    Result := FDataBase.Connected
  else if Index = 'PARAMS.COUNT' then
    Result := FDatabase.Params.Count
  else if Index = 'PARAMS' then
    Result := FDatabase.Params.Text
  else if Index = 'SQLDIALECT' then
    Result := FDataBase.SQLDialect
end;

function TfrIBXDataBase.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(FDataBase.Params, MethodName, 'PARAMS', Par1, Par2, Par3);
end;

procedure TfrIBXDatabase.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FDatabase.DatabaseName := frReadString(Stream);
  FDatabase.LoginPrompt := frReadBoolean(Stream);
  if HVersion * 10 + LVersion > 20 then
    FDatabase.SQLDialect := frReadInteger(Stream);
  frReadMemo(Stream, FDatabase.Params);
  FDatabase.Connected := frReadBoolean(Stream);
end;

procedure TfrIBXDatabase.SaveToStream(Stream: TStream);
begin
  LVersion := 1;
  inherited SaveToStream(Stream);
  frWriteString(Stream, FDatabase.DatabaseName);
  frWriteBoolean(Stream, FDatabase.LoginPrompt);
  frWriteInteger(Stream, FDatabase.SQLDialect);
  frWriteMemo(Stream, FDatabase.Params);
  frWriteBoolean(Stream, FDatabase.Connected);
end;

procedure TfrIBXDatabase.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;
  WriteStr(' DatabaseName="' + StrToXML(FDatabase.DatabaseName) + '"');
  if not FDatabase.LoginPrompt then
    WriteStr(' LoginPrompt="True"');
  WriteStr(' Params.text="' + StrToXML(FDatabase.Params.Text) + '"');
  if FDatabase.Connected then
    WriteStr(' Connected="True"');
  WriteStr(' SQLDialect="' + IntToStr(FDatabase.SQLDialect) + '"');
end;

procedure TfrIBXDatabase.LinesEditor(Sender: TObject);
var
  sl: TStringList;
  SaveConnected: Boolean;
begin
  sl := TStringList.Create;
  with TfrLinesEditorForm.Create(nil) do
  begin
    if FDatabase.Params.Text = '' then
      M1.Text := sl.Text else
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
  sl.Free;
end;

procedure TfrIBXDatabase.ShowEditor;
begin
  DBNameEditor(nil);
end;

procedure TfrIBXDatabase.DBNameEditor(Sender: TObject);
var
  SaveConnected: Bool;
begin
  SaveConnected := FDatabase.Connected;
  FDatabase.Connected := False;
  with TOpenDialog.Create(nil) do
  begin
    InitialDir := GetCurrentDir();
    Filter := {frLoadStr(SIBXDataBases); //}'Databases (*.gdb)|*.gdb|All files (*.*)|*.*';
    if Execute then
      FDatabase.DatabaseName := FileName;
    Free;
  end;
  FDatabase.Connected := SaveConnected;
end;


var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_IBXDBCONTROL');
  frRegisterControl(TfrIBXDatabase, Bmp, IntToStr(SInsertDB));

finalization
  frUnRegisterObject(TfrIBXDatabase);
  Bmp.Free;

end.

