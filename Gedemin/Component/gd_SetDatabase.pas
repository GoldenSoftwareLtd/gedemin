unit gd_SetDatabase;

interface

uses
  Forms, IBDatabase;

type
  TDnIntArray = array of Integer;
  TDnByteArray = array of Byte;

  procedure SetDatabase(const AnForm: TForm; const AnDatabase: TIBDatabase;
   const IsTransaction: Boolean = True);
  procedure SetDatabaseAndTransaction(const AnForm: TForm; const AnDatabase: TIBDatabase;
   const AnTransaction: TIBTransaction);
  function GetUniqueKey(const AnDatabase: TIBDatabase;
   const AnTransaction: TIBTransaction): Integer;
  function rpGetTempFileName(const Prefix: string): string;

implementation

uses
  IBCustomDataSet, IBSQL, SysUtils, Windows
{$IFDEF GEDEMIN}
  , gdcBaseInterface
{$ENDIF}
  ;

procedure SetDatabase(const AnForm: TForm; const AnDatabase: TIBDatabase;
 const IsTransaction: Boolean = True);
var
  I: Integer;
begin
  for I := 0 to AnForm.ComponentCount - 1 do
  begin
    if IsTransaction and (AnForm.Components[I] is TIBTransaction) then
      (AnForm.Components[I] as TIBTransaction).DefaultDatabase := AnDatabase;
    if AnForm.Components[I] is TIBCustomDataSet then
      (AnForm.Components[I] as TIBCustomDataSet).Database := AnDatabase;
    if AnForm.Components[I] is TIBSQL then
      (AnForm.Components[I] as TIBSQL).Database := AnDatabase;
  end;
end;

procedure SetDatabaseAndTransaction(const AnForm: TForm; const AnDatabase: TIBDatabase;
 const AnTransaction: TIBTransaction);
var
  I: Integer;
begin
  for I := 0 to AnForm.ComponentCount - 1 do
  begin
    if AnForm.Components[I] is TIBCustomDataSet then
    begin
      (AnForm.Components[I] as TIBCustomDataSet).Database := AnDatabase;
      (AnForm.Components[I] as TIBCustomDataSet).Transaction := AnTransaction;
    end;
    if AnForm.Components[I] is TIBSQL then
    begin
      (AnForm.Components[I] as TIBSQL).Database := AnDatabase;
      (AnForm.Components[I] as TIBSQL).Transaction := AnTransaction;
    end;
  end;
end;

function GetUniqueKey(const AnDatabase: TIBDatabase;
 const AnTransaction: TIBTransaction): Integer;
{$IFNDEF GEDEMIN}
var
  ibsqlUniqueKey: TIBSQL;
  StateTr, StateDb: Boolean;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  Assert(gdcBaseManager <> nil);
  Result := gdcBaseManager.GetNextID;
{$ELSE}
  Assert(((AnDatabase <> nil) and (AnTransaction <> nil)), 'Database or Transaction not assigned.');
  ibsqlUniqueKey := TIBSQL.Create(nil);
  try
    StateDb := AnDatabase.Connected;
    StateTr := AnTransaction.InTransaction;
    ibsqlUniqueKey.Database := AnDatabase;
    ibsqlUniqueKey.Transaction := AnTransaction;
    if not StateDb then
      AnDatabase.Connected := True;
    if not StateTr then
      AnTransaction.StartTransaction;
    ibsqlUniqueKey.SQL.Text := 'SELECT GEN_ID(GD_G_UNIQUE, 1) + GEN_ID(gd_g_offset, 0) FROM RDB$DATABASE';
    ibsqlUniqueKey.ExecQuery;
    Result := ibsqlUniqueKey.Fields[0].AsInteger;
    if not StateTr then
      AnTransaction.Commit;
    if not StateDb then
      AnDatabase.Connected := False;
  finally
    ibsqlUniqueKey.Free;
  end;
{$ENDIF}
end;

function rpGetTempFileName(const Prefix: string): string;
var
  Buffer: array[0..MAX_PATH] of Char;
  Path: string;
begin
  Result := 'reportserver.log';
  GetTempPath(MAX_PATH, Buffer);
  Path := Buffer;
  GetTempFileName(PChar(Path), PChar(Prefix), 0, Buffer);
  DeleteFile(Buffer);
  Result := Buffer;
  Result := Copy(Result, 1, Length(Result) - Length(ExtractFileExt(Result))) + '.rtf';
end;

end.

