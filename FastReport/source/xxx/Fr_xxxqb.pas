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

unit FR_XXXQB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DB, UXXXQuery, QBuilder;


type
  TfrQBXXXEngine = class(TOQBEngine)
  private
    FResultQuery: TXXXQuery;
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
    property Query: TXXXQuery read FResultQuery write FResultQuery;
  end;


implementation

uses FR_Utils, FR_Class;


{ TfrQBXXXEngine }

constructor TfrQBXXXEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResultQuery := nil;
end;

destructor TfrQBXXXEngine.Destroy;
begin
  CloseResultQuery;
  inherited Destroy;
end;

procedure TfrQBXXXEngine.UpdateTableList;
begin
  ReadTableList;
end;

function TfrQBXXXEngine.SelectDatabase: Boolean;
begin
  Result := False;
end;

procedure TfrQBXXXEngine.ReadTableList;
begin
  Session.GetTableNames(DatabaseName, '', True, ShowSystemTables, TableList);
end;

procedure TfrQBXXXEngine.ReadFieldList(ATableName: String);
var
  i: Integer;
  Temp: TXXXTable;
begin
  Temp := nil;
  try
    Temp := TXXXTable.Create(frDialogForm);
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

procedure TfrQBXXXEngine.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TfrQBXXXEngine.SetQuerySQL(Value: String);
begin
  FResultQuery.SQL.Text := Value;
end;

function TfrQBXXXEngine.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TfrQBXXXEngine.OpenResultQuery;
begin
  if not FResultQuery.Prepared then
    FResultQuery.Prepare;
  FResultQuery.Active := True;
end;

procedure TfrQBXXXEngine.CloseResultQuery;
begin
  FResultQuery.Active := False;
end;

procedure TfrQBXXXEngine.SaveResultQueryData;
begin
  ShowMessage('Operation non supported.');
end;


end.

