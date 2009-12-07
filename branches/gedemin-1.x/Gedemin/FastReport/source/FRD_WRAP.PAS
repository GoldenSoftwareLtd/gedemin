
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{       Wrapper for TTable & TQuery        }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_Wrap;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, Dialogs, StdCtrls,
  DB, FR_Class, FR_Pars, FR_DSet, FR_DBSet
{$IFDEF IBX}, IBTable, IBQuery, IBDatabase{$ENDIF}
{$IFDEF ADO}, ADODB, ADOInt{$ENDIF}
{$IFDEF BDE}, DBTables{$ENDIF};

type
  TfrQuery = class;
  TfrParamKind = (pkValue, pkVariable, pkAsk, pkAssignFromMaster);

  TfrQueryParams = class(TObject)
  private
    FQuery: TfrQuery;
    function GetCount: Integer;
    function GetName(Index: Integer): String;
    function GetValue(Index: Integer): Variant;
    function GetKind(Index: Integer): TfrParamKind;
    function GetType(Index: Integer): TFieldType;
    function GetVariable(Index: Integer): String;
    function GetText(Index: Integer): String;
    procedure SetValue(Index: Integer; Value: Variant);
    procedure SetKind(Index: Integer; Value: TfrParamKind);
    procedure SetType(Index: Integer; Value: TFieldType);
    procedure SetVariable(Index: Integer; Value: String);
    procedure SetText(Index: Integer; Value: String);
  public
    function ParamIndex(ParName: String): Integer;
    property Count: Integer read GetCount;
    property ParamName[Index: Integer]: String read GetName;
    property ParamValue[Index: Integer]: Variant read GetValue write SetValue;
    property ParamKind[Index: Integer]: TfrParamKind read GetKind write SetKind;
    property ParamType[Index: Integer]: TFieldType read GetType write SetType;
    property ParamVariable[Index: Integer]: String read GetVariable write SetVariable;
    property ParamText[Index: Integer]: String read GetText write SetText;
  end;

  TfrDatabase =
{$IFDEF IBX}class(TIBDatabase){$ENDIF}
{$IFDEF ADO}class(TADOConnection){$ENDIF}
{$IFDEF BDE}class(TDatabase){$ENDIF}
   private
     function GetDatabase: String;
     procedure SetDatabase(Value: String);
     function GetDriver: String;
     procedure SetDriver(Value: String);
{$IFDEF ADO}
     function GetParams: TStringList;
{$ENDIF}
   public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     property frDatabaseName: String read GetDatabase write SetDatabase;
     property frDriver: String read GetDriver write SetDriver;
{$IFDEF ADO}
     property Params: TStringList read GetParams;
{$ENDIF}
  end;

  TfrQuery =
{$IFDEF IBX}class(TIBQuery){$ENDIF}
{$IFDEF ADO}class(TADOQuery){$ENDIF}
{$IFDEF BDE}class(TQuery){$ENDIF}
   private
     FParams: TfrQueryParams;
     function GetDatabase: String;
     procedure SetDatabase(Value: String);
   public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     property frDatabaseName: String read GetDatabase write SetDatabase;
     property frParams: TfrQueryParams read FParams;
  end;

  TfrTable =
{$IFDEF IBX}class(TIBTable){$ENDIF}
{$IFDEF ADO}class(TADOTable){$ENDIF}
{$IFDEF BDE}class(TTable){$ENDIF}
   private
     function GetDatabase: String;
     procedure SetDatabase(Value: String);
   public
     property frDatabaseName: String read GetDatabase write SetDatabase;
  end;


var
  frSpecialParams: TfrVariables;

implementation

uses FR_Utils
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{-----------------------------------------------------------------------------}
function TfrQueryParams.GetCount: Integer;
begin
{$IFDEF ADO}
   Result := FQuery.Parameters.Count;
{$ELSE}
   Result := FQuery.Params.Count;
{$ENDIF}
end;

function TfrQueryParams.GetName(Index: Integer): String;
begin
{$IFDEF ADO}
   Result := FQuery.Parameters[Index].Name;
{$ELSE}
   Result := FQuery.Params[Index].Name;
{$ENDIF}
end;

function TfrQueryParams.GetValue(Index: Integer): Variant;
begin
{$IFDEF ADO}
   Result := FQuery.Parameters[Index].Value;
{$ELSE}
   Result := FQuery.Params[Index].Value;
{$ENDIF}
end;

function TfrQueryParams.GetKind(Index: Integer): TfrParamKind;
begin
{$IFDEF ADO}
  if not (paNullable in FQuery.Parameters[Index].Attributes) then
    Result := pkAssignFromMaster
  else if paLong in FQuery.Parameters[Index].Attributes then
    if frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]) <> -1 then
      Result := pkVariable else
      Result := pkAsk
  else
    Result := pkValue;
{$ELSE}
  if not FQuery.Params[Index].Bound then
    Result := pkAssignFromMaster
  else if FQuery.Params[Index].IsNull then
    if frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]) <> -1 then
      Result := pkVariable else
      Result := pkAsk
  else
    Result := pkValue;
{$ENDIF}
end;

procedure TfrQueryParams.SetValue(Index: Integer; Value: Variant);
begin
{$IFDEF ADO}
   FQuery.Parameters[Index].Value := Value;
{$ELSE}
   FQuery.Params[Index].Value := Value;
{$ENDIF}
end;

procedure TfrQueryParams.SetKind(Index: Integer; Value: TfrParamKind);
{$IFDEF ADO}
var
  v: Variant;
{$ENDIF}
begin
{$IFDEF ADO}
  case Value of
    pkValue:
      begin
        FQuery.Parameters[Index].Attributes := [paNullable];
        frSpecialParams.Delete(
          frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]));
      end;
    pkVariable:
      begin
        FQuery.Parameters[Index].Attributes := [paNullable, paLong];
        frSpecialParams[FQuery.Name + '.' + ParamName[Index]] := '';
      end;
    pkAsk:
      begin
        FQuery.Parameters[Index].Attributes := [paNullable, paLong];
        frSpecialParams.Delete(
          frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]));
      end;
    pkAssignFromMaster:
      begin
        FQuery.Parameters[Index].Attributes := [];
        frSpecialParams.Delete(
          frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]));
      end;
  end;
  case FQuery.Parameters[Index].DataType of
    ftBoolean: v := False;
    ftBCD, ftCurrency, ftInteger, ftFloat, ftSmallint, ftWord: v := 0;
    ftDate, ftDateTime, ftTime: v := Now;
    ftString: v := '';
  end;
  FQuery.Parameters[Index].Value := v;
{$ELSE}
  case Value of
    pkValue:
      begin
        FQuery.Params[Index].Bound := True;
        frSpecialParams.Delete(
          frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]));
      end;
    pkVariable:
      begin
        FQuery.Params[Index].Clear;
        FQuery.Params[Index].Bound := True;
        frSpecialParams[FQuery.Name + '.' + ParamName[Index]] := '';
      end;
    pkAsk:
      begin
        FQuery.Params[Index].Clear;
        FQuery.Params[Index].Bound := True;
        frSpecialParams.Delete(
          frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]));
      end;
    pkAssignFromMaster:
      begin
        FQuery.Params[Index].Clear;
        FQuery.Params[Index].Bound := False;
        frSpecialParams.Delete(
          frSpecialParams.IndexOf(FQuery.Name + '.' + ParamName[Index]));
      end;
  end;
{$ENDIF}
end;

function TfrQueryParams.GetType(Index: Integer): TFieldType;
begin
{$IFDEF ADO}
   Result := FQuery.Parameters[Index].DataType;
{$ELSE}
   Result := FQuery.Params[Index].DataType;
{$ENDIF}
end;

procedure TfrQueryParams.SetType(Index: Integer; Value: TFieldType);
begin
{$IFDEF ADO}
   FQuery.Parameters[Index].DataType := Value;
{$ELSE}
   FQuery.Params[Index].DataType := Value;
{$ENDIF}
end;

function TfrQueryParams.GetVariable(Index: Integer): String;
begin
  if ParamKind[Index] = pkVariable then
    Result := frSpecialParams[FQuery.Name + '.' + ParamName[Index]] else
    Result := '';
end;

procedure TfrQueryParams.SetVariable(Index: Integer; Value: String);
begin
  if ParamKind[Index] = pkVariable then
    frSpecialParams[FQuery.Name + '.' + ParamName[Index]] := Value;
end;

function TfrQueryParams.GetText(Index: Integer): String;
begin
{$IFDEF ADO}
  if FQuery.Parameters[Index].Value <> Null then
    case FQuery.Parameters[Index].DataType of
      ftBoolean:
        if ParamValue[Index] then
          Result := 'True' else
          Result := 'False';
      ftDateTime, ftDate, ftTime:
        Result := VarFromDateTime(ParamValue[Index])
      else
        Result := ParamValue[Index];
    end
  else
    Result := ''
{$ELSE}
  Result := FQuery.Params[Index].AsString;
{$ENDIF}
end;

procedure TfrQueryParams.SetText(Index: Integer; Value: String);
begin
{$IFDEF ADO}
   FQuery.Parameters[Index].Value := Value;
{$ELSE}
   FQuery.Params[Index].Text := Value;
{$ENDIF}
end;

function TfrQueryParams.ParamIndex(ParName: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if AnsiCompareText(ParamName[i], ParName) = 0 then
    begin
      Result := i;
      Exit;
    end;
end;


{-----------------------------------------------------------------------------}
constructor TfrDatabase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF IBX}
  DefaultTransaction := TIBTransaction.Create(AOwner);
  DefaultTransaction.DefaultDatabase := Self;
{$ENDIF}
end;

destructor TfrDatabase.Destroy;
begin
{$IFDEF IBX}
  if DefaultTransaction <> nil then
    DefaultTransaction.Free;
{$ENDIF}
  inherited Destroy;
end;

function TfrDatabase.GetDatabase: String;
begin
{$IFNDEF ADO}
  Result := DatabaseName;
{$ELSE}
  Result := ConnectionString;
{$ENDIF}
end;

procedure TfrDatabase.SetDatabase(Value: String);
begin
//  Connected := False;
{$IFNDEF ADO}
  DatabaseName := Value;
{$ELSE}
  ConnectionString := Value;
{$ENDIF}
//  Connected := True;
end;

function TfrDatabase.GetDriver: String;
begin
{$IFDEF BDE}
  Result := DriverName;
{$ELSE}
  Result := '';
{$ENDIF}
end;

procedure TfrDatabase.SetDriver(Value: String);
begin
{$IFDEF BDE}
  DriverName := Value;
{$ENDIF}
end;

{$IFDEF ADO}
function TfrDatabase.GetParams: TStringList;
begin
  Result := nil;
end;
{$ENDIF}

constructor TfrQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParams := TfrQueryParams.Create;
  FParams.FQuery := Self;
end;

destructor TfrQuery.Destroy;
begin
  FParams.Free;
  inherited Destroy;
end;

function TfrQuery.GetDatabase: String;
begin
  Result := '';
{$IFDEF BDE}
  Result := DatabaseName;
{$ENDIF}
{$IFDEF IBX}
  if Database <> nil then
    Result := Database.Owner.Name + '.' + Database.Name;
{$ENDIF}
{$IFDEF ADO}
  if Connection <> nil then
    Result := Connection.Owner.Name + '.' + Connection.Name;
{$ENDIF}
end;

procedure TfrQuery.SetDatabase(Value: String);
begin
{$IFDEF BDE}
  DatabaseName := Value;
{$ENDIF}
{$IFDEF IBX}
  Database := TIBDataBase(frFindComponent(Owner, Value));
{$ENDIF}
{$IFDEF ADO}
  Connection := TADOConnection(frFindComponent(Owner, Value));
{$ENDIF}
end;


function TfrTable.GetDatabase: String;
begin
  Result := '';
{$IFDEF BDE}
  Result := DatabaseName;
{$ENDIF}
{$IFDEF IBX}
  if Database <> nil then
    Result := Database.Owner.Name + '.' + Database.Name;
{$ENDIF}
{$IFDEF ADO}
  if Connection <> nil then
    Result := Connection.Owner.Name + '.' + Connection.Name;
{$ENDIF}
end;

procedure TfrTable.SetDatabase(Value: String);
begin
{$IFDEF BDE}
  DatabaseName := Value;
{$ENDIF}
{$IFDEF IBX}
  Database := TIBDataBase(frFindComponent(Owner, Value));
{$ENDIF}
{$IFDEF ADO}
  Connection := TADOConnection(frFindComponent(Owner, Value));
{$ENDIF}
end;


initialization
  frSpecialParams := TfrVariables.Create;

finalization
  frSpecialParams.Free;

end.

