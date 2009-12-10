
{******************************************}
{                                          }
{     FastReport v2.4 - ADO components     }
{            Database component            }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_ADODB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs, DB, ADODB, ADOInt;

type
  TfrADOComponents = class(TComponent) // fake component
  end;

  TfrADODatabase = class(TfrNonVisualControl)
  private
    FDatabase: TADOConnection;
    procedure DBNameEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property Database: TADOConnection read FDatabase;
  end;


implementation

uses FR_Utils, FR_Const, FR_LEdit, FR_DBLookupCtl, FR_ADOTable, FR_ADOQuery
{$IFDEF Delphi6}
, Variants
{$ENDIF};


{$R FR_ADO.RES}


{ TfrADODatabase }

constructor TfrADODatabase.Create;
begin
  inherited Create;
  FDatabase := TADOConnection.Create(frDialogForm);
  Component := FDatabase;
  BaseName := 'Database';
  Bmp.LoadFromResourceName(hInstance, 'FR_ADODB');
  Flags := Flags or flDontUndo;
end;

destructor TfrADODatabase.Destroy;
begin
  FDatabase.Free;
  inherited Destroy;
end;

procedure TfrADODatabase.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Connected', [frdtBoolean], nil);
  AddProperty('DatabaseName', [frdtString, frdtHasEditor], DBNameEditor);
  AddProperty('LoginPrompt', [frdtBoolean], nil);
end;

procedure TfrADODatabase.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'DATABASENAME' then
    FDatabase.ConnectionString := Value
  else if Index = 'LOGINPROMPT' then
    FDatabase.LoginPrompt := Value
  else if Index = 'CONNECTED' then
    FDatabase.Connected := Value
end;

function TfrADODatabase.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATABASENAME' then
    Result := FDatabase.ConnectionString
  else if Index = 'LOGINPROMPT' then
    Result := FDatabase.LoginPrompt
  else if Index = 'CONNECTED' then
    Result := FDatabase.Connected
end;

procedure TfrADODatabase.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FDatabase.ConnectionString := frReadString(Stream);
  FDatabase.LoginPrompt := frReadBoolean(Stream);
  FDatabase.Connected := frReadBoolean(Stream);
end;

procedure TfrADODatabase.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, FDatabase.ConnectionString);
  frWriteBoolean(Stream, FDatabase.LoginPrompt);
  frWriteBoolean(Stream, FDatabase.Connected);
end;

procedure TfrADODatabase.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;
  WriteStr(' DatabaseName="' + StrToXML(FDatabase.ConnectionString) + '"');
  if not FDatabase.LoginPrompt then
    WriteStr(' LoginPrompt="True"');
  if FDatabase.Connected then
    WriteStr(' Connected="True"');
end;

procedure TfrADODatabase.DBNameEditor(Sender: TObject);
var
  SaveConnected: Bool;
  fName: String;
begin
  SaveConnected := FDatabase.Connected;
  FDatabase.Connected := False;
  fName := PromptDataLinkFile(Application.Handle, '');
  if fName <> '' then
    FDatabase.ConnectionString := CT_FILENAME + fName;
  FDatabase.Connected := SaveConnected;
end;


var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_ADODBCONTROL');
  frRegisterControl(TfrADODatabase, Bmp, IntToStr(SInsertDB));

finalization
  frUnRegisterObject(TfrADODatabase);
  Bmp.Free;

end.

