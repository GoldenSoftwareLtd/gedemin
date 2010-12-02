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

unit FR_DBXQB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DB, DBXpress, SqlExpr, QBuilder;


type
  TfrQBDBXEngine = class(TOQBEngine)
  private
    FResultQuery: TSQLQuery;
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
    property Query: TSQLQuery read FResultQuery write FResultQuery;
  end;


implementation

uses FR_Utils, FR_Class;


{ TfrQBDBXEngine }

constructor TfrQBDBXEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResultQuery := nil;
end;

destructor TfrQBDBXEngine.Destroy;
begin
  CloseResultQuery;
  inherited Destroy;
end;

procedure TfrQBDBXEngine.UpdateTableList;
begin
  ReadTableList;
end;

function TfrQBDBXEngine.SelectDatabase: Boolean;
begin
  Result := False;
end;

procedure TfrQBDBXEngine.ReadTableList;
var
  fDb: TSQLConnection;
begin
  TableList.Clear;
  fDb := TSQLConnection(frFindComponent(frDialogForm, DatabaseName));
  if fDB <> nil then
    fDb.GetTableNames(TableList);
end;

procedure TfrQBDBXEngine.ReadFieldList(const ATableName: String);
var
  i: Integer;
  Temp: TSQLTable;
begin
  Temp := nil;
  try
    Temp := TSQLTable.Create(frDialogForm);
    Temp.SQLConnection := FResultQuery.SQLConnection;
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

procedure TfrQBDBXEngine.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TfrQBDBXEngine.SetQuerySQL(const Value: String);
begin
  FResultQuery.SQL.Text := Value;
end;

function TfrQBDBXEngine.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TfrQBDBXEngine.OpenResultQuery;
begin
//  if not FResultQuery.Prepared then
//    FResultQuery.Prepare;
  FResultQuery.Active := True;
end;

procedure TfrQBDBXEngine.CloseResultQuery;
begin
  FResultQuery.Active := False;
end;

procedure TfrQBDBXEngine.SaveResultQueryData;
begin
  ShowMessage('Operation non supported.');
end;


end.

