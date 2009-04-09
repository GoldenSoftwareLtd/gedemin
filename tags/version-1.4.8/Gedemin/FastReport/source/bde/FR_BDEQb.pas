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

unit FR_BDEQB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DB, DBTables, QBuilder;


type
  TfrQBBDEEngine = class(TOQBEngine)
  private
    FResultQuery: TQuery;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReadTableList; override;
    procedure ReadFieldList(const ATableName: string); override;
    procedure ClearQuerySQL; override;
    procedure SetQuerySQL(const Value: string); override;
    function ResultQuery: TDataSet; override;
    procedure OpenResultQuery; override;
    procedure CloseResultQuery; override;
    procedure SaveResultQueryData; override;
    function SelectDatabase: Boolean; override;
    procedure UpdateTableList;
  published
    property Query: TQuery read FResultQuery write FResultQuery;
  end;


implementation

uses FR_Utils, FR_Class;


{ TfrQBBDEEngine }

constructor TfrQBBDEEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResultQuery := nil;
end;

destructor TfrQBBDEEngine.Destroy;
begin
  CloseResultQuery;
  inherited Destroy;
end;

procedure TfrQBBDEEngine.UpdateTableList;
begin
  ReadTableList;
end;

function TfrQBBDEEngine.SelectDatabase: Boolean;
begin
  Result := False;
end;

procedure TfrQBBDEEngine.ReadTableList;
begin
  Session.GetTableNames(DatabaseName, '', True, ShowSystemTables, TableList);
end;

procedure TfrQBBDEEngine.ReadFieldList(const ATableName: String);
var
  i: Integer;
  Temp: TTable;
begin
  Temp := nil;
  try
    Temp := TTable.Create(frDialogForm);
    Temp.DataBaseName := FResultQuery.DatabaseName;
    Temp.TableName := aTableName;

    FieldList.Clear;
    FieldList.Add('*');
    Temp.FieldDefs.Update;
    for i := 0 to Temp.FieldDefs.Count - 1 do
      FieldList.Add(Temp.FieldDefs.Items[i].Name);
  finally
    Temp.Close;
    Temp.Free;
  end;
end;

procedure TfrQBBDEEngine.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TfrQBBDEEngine.SetQuerySQL(const Value: String);
begin
  FResultQuery.SQL.Text := Value;
end;

function TfrQBBDEEngine.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TfrQBBDEEngine.OpenResultQuery;
begin
  if not FResultQuery.Prepared then
    FResultQuery.Prepare;
  FResultQuery.Active := True;
end;

procedure TfrQBBDEEngine.CloseResultQuery;
begin
  FResultQuery.Active := False;
end;

procedure TfrQBBDEEngine.SaveResultQueryData;
begin
  ShowMessage('Operation non supported.');
end;


end.

