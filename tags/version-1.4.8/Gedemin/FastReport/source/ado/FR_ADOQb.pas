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

unit FR_ADOQB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DB, ADODB, ADOInt, QBuilder;


type
  TfrQBADOEngine = class(TOQBEngine)
  private
    FResultQuery: TADOQuery;
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
    property Query: TADOQuery read FResultQuery write FResultQuery;
  end;


implementation

uses FR_Utils, FR_Class;


{ TfrQBADOEngine }

constructor TfrQBADOEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResultQuery := nil;
end;

destructor TfrQBADOEngine.Destroy;
begin
  CloseResultQuery;
  inherited Destroy;
end;

procedure TfrQBADOEngine.UpdateTableList;
begin
  ReadTableList;
end;

function TfrQBADOEngine.SelectDatabase: Boolean;
begin
  Result := False;
end;

procedure TfrQBADOEngine.ReadTableList;
var
  fDb: TADOConnection;
begin
  TableList.Clear;
  fDb := TADOConnection(frFindComponent(frDialogForm, DatabaseName));
  if fDB <> nil then
    fDb.GetTableNames(TableList);
end;

procedure TfrQBADOEngine.ReadFieldList(const ATableName: String);
var
  i: Integer;
  Temp: TADOTable;
begin
  Temp := nil;
  try
    Temp := TADOTable.Create(frDialogForm);
    Temp.Connection := FResultQuery.Connection;
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

procedure TfrQBADOEngine.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TfrQBADOEngine.SetQuerySQL(const Value: String);
begin
  FResultQuery.SQL.Text := Value;
end;

function TfrQBADOEngine.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TfrQBADOEngine.OpenResultQuery;
begin
  FResultQuery.Active := True;
end;

procedure TfrQBADOEngine.CloseResultQuery;
begin
  FResultQuery.Active := False;
end;

procedure TfrQBADOEngine.SaveResultQueryData;
begin
  ShowMessage('Operation non supported.');
end;


end.

