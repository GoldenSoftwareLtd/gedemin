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

unit FR_IBXQB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DB, QBuilder, IBTable, IBQuery, IBDatabase;


type
  TfrQBIBXEngine = class(TOQBEngine)
  private
    FResultQuery: TIBQuery;
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
    property Query: TIBQuery read FResultQuery write FResultQuery;
  end;


implementation

uses FR_Utils, FR_Class;


{ TfrQBIBXEngine }

constructor TfrQBIBXEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResultQuery := nil;
end;

destructor TfrQBIBXEngine.Destroy;
begin
  CloseResultQuery;
  inherited Destroy;
end;

procedure TfrQBIBXEngine.UpdateTableList;
begin
  ReadTableList;
end;

function TfrQBIBXEngine.SelectDatabase: Boolean;
begin
  Result := False;
end;

procedure TfrQBIBXEngine.ReadTableList;
var
  fDb: TIBDataBase;
begin
  TableList.Clear;
  fDb := TIBDataBase(frFindComponent(frDialogForm, DatabaseName));
  if fDB <> nil then
    fDb.GetTableNames(TableList);
end;

procedure TfrQBIBXEngine.ReadFieldList(const ATableName: String);
var
  i: Integer;
  Temp: TIBTable;
begin
  Temp := nil;
  try
    Temp := TIBTable.Create(frDialogForm);
    Temp.DataBase := FResultQuery.Database;
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

procedure TfrQBIBXEngine.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TfrQBIBXEngine.SetQuerySQL(const Value: String);
begin
  FResultQuery.SQL.Text := Value;
end;

function TfrQBIBXEngine.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TfrQBIBXEngine.OpenResultQuery;
begin
  if not FResultQuery.Prepared then
    FResultQuery.Prepare;
  FResultQuery.Active := True;
end;

procedure TfrQBIBXEngine.CloseResultQuery;
begin
  FResultQuery.Active := False;
end;

procedure TfrQBIBXEngine.SaveResultQueryData;
begin
  ShowMessage('Operation not supported.');
end;


end.

