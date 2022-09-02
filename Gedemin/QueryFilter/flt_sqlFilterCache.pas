// ShlTanya, 10.03.2019

unit flt_sqlFilterCache;

interface

uses
  gd_KeyAssoc, gdcBaseInterface;

function GetLastFilterKey(const AComponentKey: TID): TID;
procedure SetLastFilterKey(const AComponentKey, AFilterKey: TID);
procedure SaveCacheToDatabase(const AClear: Boolean = False);

implementation

uses
  SysUtils, IBDatabase, IBSQL, gd_security;

var
  sqlFilterCache_UserKey: TID;
  Cache: TgdKeyIntAssoc;
  Changed: Boolean;

procedure LoadCacheFromDatabase;
var
  q: TIBSQL;
begin
  Assert(Assigned(IBLogin));
  Assert(Assigned(gdcBaseManager));
  Assert(gdcBaseManager.Database.Connected);
  Assert(Cache <> nil);

  Cache.Clear;
  sqlFilterCache_UserKey := IBLogin.UserKey;
  Changed := False;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT componentkey, lastfilter ' +
      'FROM flt_lastfilter ' +
      'WHERE userkey = :UK';
    SetTID(q.ParamByName('UK'), sqlFilterCache_UserKey);
    q.ExecQuery;
    while not q.EOF do
    begin
      Cache.ValuesByIndex[Cache.Add(GetTID(q.FieldByName('componentkey')))] :=
        GetTID(q.FieldByName('lastfilter'));
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

procedure SaveCacheToDatabase(const AClear: Boolean = False);
var
  q: TIBSQL;
  Tr: TIBTransaction;
  I: Integer;
begin
  Assert(Assigned(gdcBaseManager));
  Assert(gdcBaseManager.Database.Connected);

  if Cache = nil then
    exit;

  if Changed and (sqlFilterCache_UserKey > -1) then
  begin
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q.SQL.Text := 'DELETE FROM flt_lastfilter WHERE userkey = :UK';
      SetTID(q.ParamByName('UK'), sqlFilterCache_UserKey);
      q.ExecQuery;

      q.SQL.Text :=
        'INSERT INTO flt_lastfilter (userkey, componentkey, lastfilter) ' +
        'VALUES (:UK, :CK, :LF) ';
      SetTID(q.ParamByName('UK'), sqlFilterCache_UserKey);

      for I := Cache.Count - 1 downto 0 do
      try
        if Cache.ValuesByIndex[I] > 0 then
        begin
          SetTID(q.ParamByName('CK'), Cache[I]);
          SetTID(q.ParamByName('LF'), Cache.ValuesByIndex[I]);
          q.ExecQuery;
        end;
      except
        // между загрузкой кэша и его сохранением
        // компонента или фильтр могли быть удалены
        // ничего страшного. проигнорируем исключение.
        Cache.Delete(I);
      end;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;

  if AClear then
  begin
    FreeAndNil(Cache);
    sqlFilterCache_UserKey := -1;
  end;
end;

procedure CheckIt;
begin
  Assert(Assigned(IBLogin));

  if Cache = nil then
  begin
    Cache := TgdKeyIntAssoc.Create;
    sqlFilterCache_UserKey := -1;
  end;

  if IBLogin.UserKey <> sqlFilterCache_UserKey then
  begin
    LoadCacheFromDatabase;
  end;
end;

function GetLastFilterKey(const AComponentKey: TID): TID;
begin
  CheckIt;

  if IBLogin.UserKey = -1 then
  begin
    Result := -1;
    exit;
  end;

  Result := Cache.IndexOf(AComponentKey);
  if Result > -1 then
  begin
    Result := Cache.ValuesByIndex[Result];
  end;
end;

procedure SetLastFilterKey(const AComponentKey, AFilterKey: TID);
var
  Idx: Integer;
begin
  CheckIt;

  Idx := Cache.IndexOf(AComponentKey);
  if AFilterKey > 0 then
  begin
    if Idx = -1 then
    begin
      Idx := Cache.Add(AComponentKey);
      Changed := True;
    end;
    if Cache.ValuesByIndex[Idx] <> AFilterKey then
    begin
      Cache.ValuesByIndex[Idx] := AFilterKey;
      Changed := True;
    end;
  end else
  begin
    if Idx > -1 then
    begin
      Cache.Delete(Idx);
      Changed := True;
    end;
  end;
end;

initialization
  sqlFilterCache_UserKey := -1;
  Cache := nil;
  Changed := False;

finalization
  FreeAndNil(Cache);
end.
