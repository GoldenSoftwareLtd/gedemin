{*********************************************************}
{                                                         }
{       Delphi Visual Component Library                   }
{ QBuilder is  Copyright (c) 1996-99 Sergey Orlik         }
{       www.geocities.com/SiliconValley/Way/9006/         }
{                                                         }
{---------------------------------------------------------}
{ Interface with QBuilder and FastReport 2.4              }
{ Idea : Use QB for define the SQL property               }
{ Olivier GUILBAUD                                        }
{ 18/11/1999 : Create                                     }
{*********************************************************}

unit FR_QBEng;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DB, QBuilder, FRD_Wrap {$IFDEF BDE}, DBTables {$ENDIF};


type
  TfrQBEngine = class(TOQBEngine)
  private
    FShowViews: Boolean;
    FResultQuery: TfrQuery;
    FOnNotifDB: TNotifyEvent;
    function GetfrDatabase: String;
    procedure SetfrQuery(Value: TfrQuery);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReadTableList; override;
    procedure ReadFieldList(ATableName: string); override;
    procedure ClearQuerySQL; override;
    procedure SetQuerySQL(Value: string); override;
    function ResultQuery: TDataSet; override;
    procedure OpenResultQuery; override;
    procedure CloseResultQuery; override;
    procedure SaveResultQueryData; override;
    function SelectDatabase: Boolean; override;
    procedure UpdateTableList;
  published
    property UserName;
    property Password;
    property ShowViews: Boolean read FShowViews write FShowViews default True;
    property frDatabaseName: String read GetfrDatabase;
    property frQuery: TfrQuery read FResultQuery write SetfrQuery;
    property OnDataBaseNameChange: TNotifyEvent read FOnNotifDB write FOnNotifDB;
  end;

  TfrQBuilderDialog = class(TOQBuilderDialog)
  public
    constructor Create(AOwner: TComponent); override;
  end;


implementation


uses FR_Utils, FRD_Mngr;

{ TfrQBEngine }

constructor TfrQBEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShowViews := True;
  FResultQuery := nil;
end;

destructor TfrQBEngine.Destroy;
begin
  CloseResultQuery;
  inherited Destroy;
end;

procedure TfrQBEngine.UpdateTableList;
begin
  Self.ReadTableList;
end;

function TfrQBEngine.SelectDatabase: Boolean;
begin
  Result := False;
end;

procedure TfrQBEngine.SetfrQuery(Value: TfrQuery);
begin
  FResultQuery := Value;
  Self.DatabaseName := frDatabaseName;
  if Assigned(fOnNotifDB) then fOnNotifDB(Self);
end;

{$HINTS OFF}
procedure TfrQBEngine.ReadTableList;
var
  fDb: TfrDatabase;
begin
{$IFDEF BDE}
  Session.GetTableNames(Self.frDatabaseName, '', True, ShowSystemTables, TableList);
{$ELSE}
  TableList.Clear;
  fDb := TfrDatabase(frFindComponent(nil, frDatabaseName));
  if fDB <> nil then
  begin
//    fDb.ShowViews := fShowViews;
    fDb.GetTableNames(TableList);
  end;
{$ENDIF}
end;
{$HINTS ON}

procedure TfrQBEngine.ReadFieldList(ATableName: String);
var
  i: Integer;
  Temp: TfrTable;
  St: String;
begin
  Temp := nil;
  try
    Temp := TfrTable.Create(frDataModule);
    Temp.frDataBaseName := fResultQuery.frDatabaseName;
    Temp.TableName := aTableName;

    FieldList.Clear;
    FieldList.Add('*');

    Temp.FieldDefs.Update;
    for i := 0 to Temp.FieldDefs.Count - 1 do
    begin
      St := Temp.FieldDefs.Items[i].Name;
      FieldList.Add(St);
    end;
  finally
    Temp.Close;
    Temp.Free;
  end;
end;

procedure TfrQBEngine.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TfrQBEngine.SetQuerySQL(Value: String);
begin
  ClearQuerySQL;
  FResultQuery.SQL.Text := Value;
end;

function TfrQBEngine.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TfrQBEngine.OpenResultQuery;
begin
  if not FResultQuery.Prepared then
    FResultQuery.Prepare;
  FResultQuery.Active := True;
end;

procedure TfrQBEngine.CloseResultQuery;
begin
  FResultQuery.Active := False;
end;

procedure TfrQBEngine.SaveResultQueryData;
begin
  ShowMessage('Operation non supported.');
end;

function TfrQBEngine.GetfrDatabase: String;
begin
  Result := '';
{$IFDEF ADO}
  if Connection <> nil then
    Result := Connection.Name;
{$ELSE}
  Result := fResultQuery.frDatabaseName;
{$ENDIF}
end;


constructor TfrQBuilderDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowButtons := [bOpenDialog, bSaveDialog, bRunQuery];
end;



end.

