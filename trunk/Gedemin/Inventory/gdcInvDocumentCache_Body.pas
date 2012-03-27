
unit gdcInvDocumentCache_Body;

interface

uses
  Classes, gdcInvDocumentCache_unit, gd_KeyAssoc, gdcBaseInterface;

type
  TgdcInvDocumentCache = class(TInterfacedObject, IgdcInvDocumentCache)
  private
    CachedDBID: TID;
    CachedSubTypeList: TgdKeyStringAssoc;
    Link: TStringList;

    function DoCache(const K: Integer; const IsClassName: Boolean;
      SubTypeList: TStrings): Boolean;
    procedure CheckDBID;
    function IntToKey(const I: Integer): Integer;
    function StringToKey(const S: String): Integer;

  public
    constructor Create;
    destructor Destroy; override;

    function GetSubTypeList(const InvDocumentTypeBranchKey: TID;
      SubTypeList: TStrings): Boolean;
    function GetSubTypeList2(const ClassName: String;
      SubTypeList: TStrings): Boolean;

    procedure Clear;
  end;

implementation

uses
  SysUtils,
  gd_security,
  IBSQL,
  gdcInvDocument_unit,
  Windows
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure TgdcInvDocumentCache.CheckDBID;
begin
  if CachedDBID <> IBLogin.DBID then
  begin
    Link.Clear;
    CachedSubTypeList.Clear;
    CachedDBID := IBLogin.DBID;
  end;
end;

procedure TgdcInvDocumentCache.Clear;
begin
  CachedDBID := -1;
  CachedSubTypeList.Clear;
  Link.Clear;
end;

constructor TgdcInvDocumentCache.Create;
begin
  CachedDBID := -1;
  CachedSubTypeList := TgdKeyStringAssoc.Create;
  Link := TStringList.Create;
  Link.Sorted := False;
  Link.Duplicates := dupError;
end;

destructor TgdcInvDocumentCache.Destroy;
begin
  Link.Free;
  CachedSubTypeList.Free;
  inherited;
end;

function TgdcInvDocumentCache.DoCache(const K: Integer;
  const IsClassName: Boolean; SubTypeList: TStrings): Boolean;

  function CheckSubTypeName(const S: String): String;
  begin
    if Pos('=', S) > 0 then
      raise Exception.Create('SubType name can not contain = sign. Value: ' + S);
    Result := S;
  end;

var
  ibsql: TIBSQL;
  DidActivate: Boolean;
  I: Integer;
begin
  if (not Assigned(gdcBaseManager))
    or (not Assigned(IBLogin)) then
  begin
    Result := False;
    exit;
  end;

  I := CachedSubTypeList.IndexOf(K);

  if I <> -1 then
  begin
    SubTypeList.CommaText := CachedSubTypeList.ValuesByIndex[I];
  end else
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;

      DidActivate := not ibsql.Transaction.InTransaction;
      if DidActivate then
        ibsql.Transaction.StartTransaction;

      try
        if IsClassName and (Link[K] <> 'TgdcInvBaseRemains') then
        begin
          ibsql.SQL.Text := 'SELECT NAME, RUID FROM GD_DOCUMENTTYPE WHERE CLASSNAME = :CN AND ' +
            ' DOCUMENTTYPE = ''D''';
          ibsql.ParamByName('CN').AsString := Link[K];
        end
        else if IsClassName and (Link[K] = 'TgdcInvBaseRemains') then
        begin
          ibsql.SQL.Text := 'SELECT dt1.name, dt1.ruid FROM gd_documenttype dt1 JOIN gd_documenttype dt ON dt1.LB >= dt.lb AND dt1.rb <= dt.rb WHERE dt.id = :ID ' +
            ' AND dt1.documenttype = ''D''';
          ibsql.ParamByName('id').AsInteger := TgdcInvDocumentType.InvDocumentTypeBranchKey;
        end else
        begin
          ibsql.SQL.Text := 'SELECT dt1.name, dt1.ruid FROM gd_documenttype dt1 JOIN gd_documenttype dt ON dt1.LB >= dt.lb AND dt1.rb <= dt.rb WHERE dt.id = :ID ' +
            ' AND dt1.documenttype = ''D''';
          ibsql.ParamByName('id').AsString := Link[K];
        end;

        ibsql.ExecQuery;

        SubTypeList.Clear;

        while not ibsql.EOF do
        begin
          if SubTypeList.IndexOfName(ibsql.FieldByName('name').AsString) = -1 then
          begin
            SubTypeList.Add(
              CheckSubTypeName(ibsql.FieldByName('name').AsString) + '=' +
              ibsql.FieldByName('ruid').AsString);
          end else
          begin
            MessageBox(
              0,
              PChar('Дублируется наименование типа документа: ' + ibsql.FieldByName('name').AsString + #13#10 +
              'Возможно некорректное функционирование системы.'),
              'Внимание',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST);
          end;    

          ibsql.Next;
        end;

        ibsql.Close;

        if IsClassName then
        begin
          if Link[K] = 'TgdcInvBaseRemains' then
          begin
            ibsql.SQL.Text :=
              'SELECT NAME, RUID FROM INV_BALANCEOPTION';
            ibsql.ExecQuery;
            while not ibsql.EOF do
            begin
              SubTypeList.Add(
                CheckSubTypeName(ibsql.FieldByName('NAME').AsString) + '=' +
                ibsql.FieldByName('RUID').AsString);
              ibsql.Next;
            end;
            ibsql.Close;
          end;
        end;

        CachedSubTypeList.ValuesByIndex[CachedSubTypeList.Add(K)] :=
          SubTypeList.CommaText;
      finally
        if DidActivate then
          ibsql.Transaction.Commit;
      end;
    finally
      ibsql.Free;
    end;
  end;

  Result := SubTypeList.Count > 0;
end;

function TgdcInvDocumentCache.GetSubTypeList(const InvDocumentTypeBranchKey: TID;
  SubTypeList: TStrings): Boolean;
begin
  CheckDBID;
  Result := DoCache(IntToKey(InvDocumentTypeBranchKey), False, SubTypeList);
end;


function TgdcInvDocumentCache.GetSubTypeList2(const ClassName: String;
  SubTypeList: TStrings): Boolean;
begin
  CheckDBID;
  Result := DoCache(StringToKey(ClassName), True, SubTypeList);
end;

function TgdcInvDocumentCache.IntToKey(const I: Integer): Integer;
begin
  Result := Link.IndexOf(IntToStr(I));
  if Result = -1 then
    Result := Link.Add(IntToStr(I));
end;

function TgdcInvDocumentCache.StringToKey(const S: String): Integer;
begin
  Result := Link.IndexOf(S);
  if Result = -1 then
    Result := Link.Add(S);
end;

initialization
  gdcInvDocumentCache := TgdcInvDocumentCache.Create;

finalization
  gdcInvDocumentCache := nil;
end.
