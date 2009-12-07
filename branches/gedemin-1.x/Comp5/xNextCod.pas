{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection                    }
{                                                       }
{       Copyright (c) 1995-97 Stefan Bother             }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xnextcod.pas

  Abstract

    DB non-visual component.

  Author

    Mikle Shoihet (March 1996)

  Contact address

  Revisions history

    1.00    17-jun-96    mikle    Initial version.
    1.01    02-apr-97    mikle    Check of active state before initialization
                                  added.
    1.02    09-apr-97    mikle    Minor change.

--}

unit xNextCod;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, DbCtrls;

type
  TxDBNextCode = class(TComponent)
  private
    FDataLink: TFieldDataLink;
    FLinkDataSource: TDataSource;
    OldChangeState: TNotifyEvent;
    OldOnCreate: TNotifyEvent;

    function GetNewCode: String;
    function GetLastCode: String;
    function GetDataField: String;
    procedure SetDataField(const Value: String);
    function GetDataSource: TDataSource;
    procedure SetDataSource(aDataSource: TDataSource);
    procedure SetLinkDataSource(aDataSource: TDataSource);
    procedure DoOnCreate(Sender: TObject);
    procedure MakeOnChangeState(Sender: TObject);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure Loaded;
      override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    property NewCode: String read GetNewCode;

  published
    property DataField: String read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property LinkDataSource: TDataSource read FLinkDataSource write SetLinkDataSource;
    property LastCode: String read GetLastCode;
  end;

procedure Register;

function GetNextAlphaCode(const S: String; Len: Integer): String;

implementation

function GetNextAlphaCode(const S: String; Len: Integer): String;
var
  i: Integer;
begin
  Result:= S;

  if S = '' then
  begin
    for i:= 1 to Len do
      Result := Result + '@';
    exit;
  end;

{  if Len < Length(S) then
    Len:= Length(S);}

  for i:= Len downto 1 do
    if Ord(Result[i]) = 122 then
      Result[i]:= Chr(64)
    else begin
      if Chr(Ord(Result[i]) + 1) = '\' then
        Result[i]:= Chr(Ord(Result[i]) + 2)
      else
        Result[i]:= Chr(Ord(Result[i]) + 1);
      Break;
    end;

end;

{ TxDBNextCode -------------------------------------------}

constructor TxDBNextCode.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FDataLink := TFieldDataLink.Create;
end;

destructor TxDBNextCode.Destroy;
begin
  FDataLink.Free;
{  (Owner as TForm).OnCreate:= OldOnCreate; }
  inherited Destroy;
end;

procedure TxDBNextCode.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) and (DataSource <> nil) and
     (DataSource.DataSet <> nil)
  then begin
    OldChangeState:= DataSource.OnStateChange;
    DataSource.OnStateChange:= MakeOnChangeState;

    if Owner is TForm then
    begin
      OldOnCreate:= (Owner as TForm).OnCreate;
      (Owner as TForm).OnCreate:= DoOnCreate;
    end;
    if Owner is TDataModule then
    begin
      OldOnCreate:= (Owner as TDataModule).OnCreate;
      (Owner as TDataModule).OnCreate:= DoOnCreate;
    end;
  end;
end;

procedure TxDBNextCode.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
  if (Operation = opRemove) and (AComponent = LinkDataSource) then
    LinkDataSource:= nil;
end;

function TxDBNextCode.GetNewCode: String;
var
  IntNum: Longint;
begin
  LinkDataSource.DataSet.Active:= false;
  repeat { until successful or Cancel button is pressed }
    try
      TTable(LinkDataSource.DataSet).Exclusive := True; { See if it will open }
      LinkDataSource.DataSet.Active := True;
      Break; { If no error, exit the loop }
    except
      on EDatabaseError do
        Continue;
    end;
  until False;
  TTable(LinkDataSource.DataSet).Edit;
  if TTable(LinkDataSource.DataSet).Fields[0].DataType = ftString then
    Result:= GetNextAlphaCode(TTable(LinkDataSource.DataSet).Fields[0].AsString,
      TTable(LinkDataSource.DataSet).Fields[0].Size)
  else begin
    IntNum:= TTable(LinkDataSource.DataSet).Fields[0].AsInteger + 1;
    Result:= IntToStr(IntNum);
  end;

  TTable(LinkDataSource.DataSet).Fields[0].AsString:= Result;
  TTable(LinkDataSource.DataSet).Post;
  LinkDataSource.DataSet.Active:= false;
  TTable(LinkDataSource.DataSet).Exclusive:= false;
end;

function TxDBNextCode.GetDataField: string;
begin
  Result:= FDataLink.FieldName;
end;

function TxDBNextCode.GetLastCode: string;
begin
  TTable(LinkDataSource.DataSet).Active:= false;
  repeat { until successful or Cancel button is pressed }
    try
      TTable(LinkDataSource.DataSet).Exclusive := True;
      LinkDataSource.DataSet.Active := True;
      Break; { If no error, exit the loop }
    except
      on EDatabaseError do
        Continue;
    end;
  until False;
  Result:= TTable(LinkDataSource.DataSet).Fields[0].AsString;
  LinkDataSource.DataSet.Active := False;
  TTable(LinkDataSource.DataSet).Exclusive := False;
end;

procedure TxDBNextCode.SetDataField(const Value: string);
begin
  FDataLink.FieldName:= Value;
end;

function TxDBNextCode.GetDataSource: TDataSource;
begin
  Result:= FDataLink.DataSource;
end;

procedure TxDBNextCode.SetDataSource(aDataSource: TDataSource);
begin
  FDataLink.DataSource:= aDataSource;
end;

procedure TxDBNextCode.SetLinkDataSource(aDataSource: TDataSource);
begin
  FLinkDataSource:= aDataSource;
end;

procedure TxDBNextCode.DoOnCreate(Sender: TObject);
begin
  if Assigned(OldOnCreate) then
    OldOnCreate(Sender);
  if LinkDataSource.DataSet.Active then
    raise Exception.Create('Should be not active at Create');
end;

procedure TxDBNextCode.MakeOnChangeState(Sender: TObject);
begin
  if Assigned(OldChangeState) then OldChangeState(Self);
  if (DataSource = nil) or (DataField = '') then exit;
  if (DataSource.State in [dsInsert]) then
    DataSource.DataSet.FieldByName(DataField).AsString:= NewCode;
end;

{ Registration -------------------------------------------}

{$IFNDEF xTool} {$I xLic.Inc} {$ENDIF}

procedure Register;
begin
  {$IFNDEF xTool} Check('TxDBNextCode'); {$ENDIF}
  RegisterComponents('xTool', [TxDBNextCode]);
end;

end.
