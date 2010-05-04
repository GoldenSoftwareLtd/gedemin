{************************************************************************}
{                                                                        }
{       Borland Delphi Visual Component Library                          }
{       InterBase Express core components                                }
{                                                                        }
{       Copyright (c) 1998-2001 Borland Software Corporation             }
{                                                                        }
{    InterBase Express is based in part on the product                   }
{    Free IB Components, written by Gregory H. Deatz for                 }
{    Hoagland, Longo, Moran, Dunst & Doukas Company.                     }
{    Free IB Components is used under license.                           }
{                                                                        }
{    The contents of this file are subject to the InterBase              }
{    Public License Version 1.0 (the "License"); you may not             }
{    use this file except in compliance with the License. You may obtain }
{    a copy of the License at http://www.borland.com/interbase/IPL.html  }
{    Software distributed under the License is distributed on            }
{    an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either              }
{    express or implied. See the License for the specific language       }
{    governing rights and limitations under the License.                 }
{    The Original Code was created by InterBase Software Corporation     }
{       and its successors.                                              }
{    Portions created by Borland Software Corporation are Copyright      }
{       (C) Borland Software Corporation. All Rights Reserved.           }
{    Contributor(s): Jeff Overcash                                       }
{                                                                        }
{************************************************************************}

unit IBQuery;

interface

uses Classes, DB, IBHeader, IB, IBDatabase, IBCustomDataSet, IBSQL;

type

{ TIBQuery }

  TIBQuery = class(TIBCustomDataSet)
  private
    FSQL: TStrings;
    FPrepared: Boolean;
    FParams: TParams;
    FText: string;
    FRowsAffected: Integer;
    FCheckRowsAffected: Boolean;
    FGenerateParamNames: Boolean;
    function GetRowsAffected: Integer;
    procedure PrepareSQL(Value: PChar);
    procedure QueryChanged(Sender: TObject);
    procedure ReadParamData(Reader: TReader);
    procedure SetQuery(Value: TStrings);
    procedure SetParamsList(Value: TParams);
    procedure SetParams;
    procedure SetParamsFromCursor;
    procedure SetPrepared(Value: Boolean);
    procedure SetPrepare(Value: Boolean);
    procedure WriteParamData(Writer: TWriter);
    function GetStmtHandle: TISC_STMT_HANDLE;
    function ParseSQL(SQL: String; DoCreate: Boolean): String;

  protected
    { IProviderSupport }
    procedure PSExecute; override;
    function PSGetParams: TParams; override;
    function PSGetTableName: string; override;
    procedure PSSetCommandText(const CommandText: string); override;
    procedure PSSetParams(AParams: TParams); override;

    procedure DefineProperties(Filer: TFiler); override;
    procedure InitFieldDefs; override;
    procedure InternalOpen; override;
    procedure Disconnect; override;
    function GetParamsCount: Word;
    function GenerateQueryForLiveUpdate : Boolean;
    procedure SetFiltered(Value: Boolean); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BatchInput(InputObject: TIBBatchInput);
    procedure BatchOutput(OutputObject: TIBBatchOutput);
    procedure ExecSQL;
    procedure GetDetailLinkFields(MasterFields, DetailFields: TList); override;
    function ParamByName(const Value: string): TParam;
    procedure Prepare;
    procedure UnPrepare;
    property LiveMode;
    property Prepared: Boolean read FPrepared write SetPrepare;
    property ParamCount: Word read GetParamsCount;
    property StmtHandle: TISC_STMT_HANDLE read GetStmtHandle;
    property StatementType;
    property Text: string read FText;
    property RowsAffected: Integer read GetRowsAffected;
    property GenerateParamNames: Boolean read FGenerateParamNames write FGenerateParamNames;
    
  published
    property Active;
    property BufferChunks;
    property CachedUpdates;
    property DataSource read GetDataSource write SetDataSource;
    property Constraints stored ConstraintsStored;
    property ParamCheck;
    property SQL: TStrings read FSQL write SetQuery;
    property Params: TParams read FParams write SetParamsList stored False;
    property UniDirectional default False;
    property UpdateObject;
    property Filtered;
    property GeneratorField;

    property BeforeDatabaseDisconnect;
    property AfterDatabaseDisconnect;
    property DatabaseFree;
    property BeforeTransactionEnd;
    property AfterTransactionEnd;
    property TransactionFree;
    property OnFilterRecord;
end;

implementation

uses
  ContNrs, SysUtils;

{ TIBQuery }

constructor TIBQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSQL := TStringList.Create;
  TStringList(SQL).OnChange := QueryChanged;
  FParams := TParams.Create(Self);
  ParamCheck := True;
  FGenerateParamNames := False;
  FRowsAffected := -1;
end;

destructor TIBQuery.Destroy;
begin
  Destroying;
  Disconnect;
  SQL.Free;
  FParams.Free;
  inherited Destroy;
end;

procedure TIBQuery.InitFieldDefs;
begin
  inherited InitFieldDefs;
end;

procedure TIBQuery.InternalOpen;
begin
  ActivateConnection();
  ActivateTransaction;
  QSelect.GenerateParamNames := FGenerateParamNames;
  SetPrepared(True);
  if DataSource <> nil then
    SetParamsFromCursor;
  SetParams;
  inherited InternalOpen;
end;

procedure TIBQuery.Disconnect;
begin
  Close;
  UnPrepare;
end;

procedure TIBQuery.SetPrepare(Value: Boolean);
begin
  if Value then
    Prepare
  else
    UnPrepare;
end;

procedure TIBQuery.Prepare;
begin
  SetPrepared(True);
end;

procedure TIBQuery.UnPrepare;
begin
  SetPrepared(False);
end;

procedure TIBQuery.SetQuery(Value: TStrings);
begin
  if SQL.Text <> Value.Text then
  begin
    Disconnect;
    SQL.BeginUpdate;
    try
      SQL.Assign(Value);
    finally
      SQL.EndUpdate;
    end;
  end;
end;

procedure TIBQuery.QueryChanged(Sender: TObject);
begin
  if not (csReading in ComponentState) then
  begin
    Disconnect;
    if ParamCheck or (csDesigning in ComponentState) then
      FText := ParseSQL(SQL.Text, True)
    else
      FText := SQL.Text;
    DataEvent(dePropertyChange, 0);
  end else
    FText := ParseSQL(SQL.Text, False);
  SelectSQL.Assign(SQL);
end;

procedure TIBQuery.SetParamsList(Value: TParams);
begin
  FParams.AssignValues(Value);
end;

function TIBQuery.GetParamsCount: Word;
begin
  Result := FParams.Count;
end;

procedure TIBQuery.DefineProperties(Filer: TFiler);

  function WriteData: Boolean;
  begin
    if Filer.Ancestor <> nil then
      Result := not FParams.IsEqual(TIBQuery(Filer.Ancestor).FParams) else
      Result := FParams.Count > 0;
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('ParamData', ReadParamData, WriteParamData, WriteData); {do not localize}
end;

procedure TIBQuery.ReadParamData(Reader: TReader);
begin
  Reader.ReadValue;
  Reader.ReadCollection(FParams);
end;

procedure TIBQuery.WriteParamData(Writer: TWriter);
begin
  Writer.WriteCollection(Params);
end;

procedure TIBQuery.SetPrepared(Value: Boolean);
begin
  CheckDatasetClosed;
  if Value <> Prepared then
  begin
    if Value then
    begin
      FRowsAffected := -1;
      FCheckRowsAffected := True;
      if Length(Text) > 1 then PrepareSQL(PChar(Text))
      else IBError(ibxeEmptySQLStatement, [nil]);
    end
    else
    begin
      if FCheckRowsAffected then
        FRowsAffected := RowsAffected;
      InternalUnPrepare;
    end;
    FPrepared := Value;
  end;
end;

procedure TIBQuery.SetParamsFromCursor;
var
  I: Integer;
  DataSet: TDataSet;

  procedure CheckRequiredParams;
  var
    I: Integer;
  begin
    for I := 0 to FParams.Count - 1 do
    with FParams[I] do
      if not Bound then
        IBError(ibxeRequiredParamNotSet, [nil]);
  end;

begin
  if DataSource <> nil then
  begin
    DataSet := DataSource.DataSet;
    if DataSet <> nil then
    begin
      DataSet.FieldDefs.Update;
      for I := 0 to FParams.Count - 1 do
        with FParams[I] do
          if not Bound then
          begin
            AssignField(DataSet.FieldByName(Name));
            Bound := False;
          end;
    end
    else
      CheckRequiredParams;
  end
  else
    CheckRequiredParams;
end;


function TIBQuery.ParamByName(const Value: string): TParam;
begin
  Result := FParams.ParamByName(Value);
end;

procedure TIBQuery.BatchInput(InputObject: TIBBatchInput);
begin
  InternalBatchInput(InputObject);
end;

procedure TIBQuery.BatchOutput(OutputObject: TIBBatchOutput);
begin
  InternalBatchOutput(OutputObject);
end;

procedure TIBQuery.ExecSQL;
var
  DidActivate: Boolean;
begin
  CheckInActive;
  if SQL.Count <= 0 then
  begin
    FCheckRowsAffected := False;
    IBError(ibxeEmptySQLStatement, [nil]);
  end;
  ActivateConnection();
  DidActivate := ActivateTransaction;
  try
    SetPrepared(True);
    if DataSource <> nil then SetParamsFromCursor;
    if FParams.Count > 0 then SetParams;
    InternalExecQuery;
  finally
    if DidActivate then
      DeactivateTransaction;
    FCheckRowsAffected := True;
  end;
end;

procedure TIBQuery.SetParams;

var
i : integer;
Buffer: Pointer;

begin
  for I := 0 to FParams.Count - 1 do
  begin
    if Params[i].IsNull then
      SQLParams[i].IsNull := True
    else begin
      SQLParams[i].IsNull := False;
      case Params[i].DataType of
        ftBytes:
        begin
          GetMem(Buffer,Params[i].GetDataSize);
          try
            Params[i].GetData(Buffer);
            SQLParams[i].AsPointer := Buffer;
          finally
            FreeMem(Buffer);
          end;
        end;
        ftString, ftFixedChar:
          SQLParams[i].AsString := Params[i].AsString;
        ftBoolean, ftSmallint, ftWord:
          SQLParams[i].AsShort := Params[i].AsSmallInt;
        ftInteger:
          SQLParams[i].AsLong := Params[i].AsInteger;
{        ftLargeInt:
          SQLParams[i].AsInt64 := Params[i].AsLargeInt;  }
        ftFloat:
         SQLParams[i].AsDouble := Params[i].AsFloat;
        ftBCD, ftCurrency:
          SQLParams[i].AsCurrency := Params[i].AsCurrency;
        ftDate:
          SQLParams[i].AsDate := Params[i].AsDateTime;
        ftTime:
          SQLParams[i].AsTime := Params[i].AsDateTime;
        ftDateTime:
          SQLParams[i].AsDateTime := Params[i].AsDateTime;
        ftBlob, ftMemo:
          SQLParams[i].AsString := Params[i].AsString;
        else
          IBError(ibxeNotSupported, [nil]);
      end;
    end;
  end;
end;

procedure TIBQuery.PrepareSQL(Value: PChar);
begin
  QSelect.GenerateParamNames := FGenerateParamNames;
  InternalPrepare;
end;

function TIBQuery.GetRowsAffected: Integer;
begin
  Result := -1;
  if Prepared then
   Result := QSelect.RowsAffected
end;

procedure TIBQuery.GetDetailLinkFields(MasterFields, DetailFields: TList);

  function AddFieldToList(const FieldName: string; DataSet: TDataSet;
    List: TList): Boolean;
  var
    Field: TField;
  begin
    Field := DataSet.FindField(FieldName);
    if (Field <> nil) then
      List.Add(Field);
    Result := Field <> nil;
  end;

var
  i: Integer;
begin
  MasterFields.Clear;
  DetailFields.Clear;
  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    for i := 0 to Params.Count - 1 do
      if AddFieldToList(Params[i].Name, DataSource.DataSet, MasterFields) then
        AddFieldToList(Params[i].Name, Self, DetailFields);
end;

function TIBQuery.GetStmtHandle: TISC_STMT_HANDLE;
begin
  Result := SelectStmtHandle;
end;

function TIBQuery.GenerateQueryForLiveUpdate : Boolean;
begin
  Result := False;
end;

procedure TIBQuery.SetFiltered(Value: Boolean);
begin
  //!!!b
  {
  //!!!e
  if(Filtered <> Value) then
  begin
    inherited SetFiltered(value);
    if Active then
    begin
      Close;
      Open;
    end;
  end
  else
  //!!!b
  }
  //!!!e
    inherited SetFiltered(value);
end;

{ TIBQuery IProviderSupport }

function TIBQuery.PSGetParams: TParams;
begin
  Result := Params;
end;

procedure TIBQuery.PSSetParams(AParams: TParams);
begin
  if AParams.Count <> 0 then
    Params.Assign(AParams);
  Close;
end;

function TIBQuery.PSGetTableName: string;
begin
  Result := inherited PSGetTableName;
end;

procedure TIBQuery.PSExecute;
begin
  ExecSQL;
end;

procedure TIBQuery.PSSetCommandText(const CommandText: string);
begin
  if CommandText <> '' then
    SQL.Text := CommandText;
end;

function TIBQuery.ParseSQL(SQL: String; DoCreate: Boolean): String;
const
  Literals = ['''', '"', '`'];
var
  Value, CurPos, StartPos: PChar;
  CurChar, NextChar, LiteralChar: Char;
  Literal: Boolean;
  EmbeddedLiteral: Boolean;
  Name: String;
  L: TParams;
  I: Integer;
  P: TParam;

  function NameDelimiter: Boolean;
  begin
    Result := CurChar in [' ', ',', ';', ')', #13, #10];
  end;

  function IsLiteral: Boolean;
  begin
    Result := CurChar in Literals;
  end;

  function StripLiterals(Buffer: PChar): string;
  var
    Len: Word;
    TempBuf: PChar;

    procedure StripChar;
    begin
      if TempBuf^ in Literals then
        StrMove(TempBuf, TempBuf + 1, Len - 1);
      if TempBuf[StrLen(TempBuf) - 1] in Literals then
        TempBuf[StrLen(TempBuf) - 1] := #0;
    end;

  begin
    Len := StrLen(Buffer) + 1;
    TempBuf := AllocMem(Len);
    Result := '';
    try
      StrCopy(TempBuf, Buffer);
      StripChar;
      Result := StrPas(TempBuf);
    finally
      FreeMem(TempBuf, Len);
    end;
  end;

begin
  Result := SQL;
  Value := PChar(Result);
  CurPos := Value;
  Literal := False;
  LiteralChar := #0;
  EmbeddedLiteral := False;
  if DoCreate then
    L := TParams.Create(Self)
  else
    L := nil;
  try
    repeat
      {ƒело в том, что компоненты IBX на этапе подготовки запроса к выполнению
       создают дл€ себ€ список параметров. ≈сли до по€влени€ Execute block параметр
       определ€лс€ однозначно - символьное им€ начинающеес€ с ':' или '?', то
       теперь такие последовательности символов могут встретитьс€ в теле оператора
       Execute block (локальные переменные) и они не должны интерпретироватьс€ как
       параметры.}
      if (CurPos[0] in [#32, #9, #10, #13]) and
         (CurPos[1] in ['b', 'B']) and
         (CurPos[2] in ['e', 'E']) and
         (CurPos[3] in ['g', 'G']) and
         (CurPos[4] in ['i', 'I']) and
         (CurPos[5] in ['n', 'N']) and
         (CurPos[6] in [#32, #9, #10, #13]) then
        Break;

      CurChar := CurPos^;

      if CurChar <> #0 then
        NextChar := (CurPos + 1)^
      else
        NextChar := #0;
      if (CurChar = ':') and not Literal and ((CurPos + 1)^ <> ':') then
      begin
        StartPos := CurPos;
        while (CurChar <> #0) and (Literal or not NameDelimiter) do
        begin
          Inc(CurPos);
          CurChar := CurPos^;
          if IsLiteral then
          begin
            Literal := Literal xor True;
            if CurPos = StartPos + 1 then EmbeddedLiteral := True;
          end;
        end;
        CurPos^ := #0;
        if EmbeddedLiteral then
        begin
          Name := StripLiterals(StartPos + 1);
          EmbeddedLiteral := False;
        end
        else Name := StrPas(StartPos + 1);
        if DoCreate then
          TParam(L.Add).Name := Name;
        CurPos^ := CurChar;
        StartPos^ := '?';
        Inc(StartPos);
        StrMove(StartPos, CurPos, StrLen(CurPos) + 1);
        CurPos := StartPos;
      end
      else if (CurChar = ':') and not Literal and ((CurPos + 1)^ = ':') then
        StrMove(CurPos, CurPos + 1, StrLen(CurPos) + 1)
      else if IsLiteral then
      begin
        if Literal and (CurChar = LiteralChar) then
        begin
          Literal := False;
          LiteralChar := #0;
        end else
        if not Literal then
        begin
          Literal := True;
          LiteralChar := CurChar;
        end;
      end
      else if (CurChar = '-') and (NextChar = '-') and (not Literal) then
      begin
        repeat
          Inc(CurPos);
        until (CurPos + 1)^ in [#0, #13, #10];
      end
      else if (CurChar = '/') and (NextChar = '*') and (not Literal) then
      begin
        repeat
          Inc(CurPos);
        until ((CurPos + 1)^ = #0) or ((CurPos + 2)^ = #0)
          or (((CurPos + 1)^ = '*') and ((CurPos + 2)^ = '/'));
      end;
      Inc(CurPos);
    until CurChar = #0;

    if DoCreate then
    begin
      for I := 0 to L.Count - 1 do
      begin
        P := FParams.FindParam(L[I].Name);
        if P <> nil then
          L[I].Assign(P);
      end;
      FParams.Assign(L);
    end;
  finally
    L.Free;
  end;
end;

end.
