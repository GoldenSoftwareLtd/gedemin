
unit gdcInvDocumentCache_Body;

interface

uses
  Classes, gdcInvDocumentCache_unit, gd_KeyAssoc, gdcBaseInterface;

type
  TgdcInvDocumentCache = class(TInterfacedObject, IgdcInvDocumentCache)
  private
    CachedDBID: TID;
    CachedSubTypeList: TgdKeyStringAssoc;
    CachedSubTypeListOD: TgdKeyStringAssoc;
    CachedSubTypeListST: TgdKeyStringAssoc;
    CachedSubTypeListODST: TgdKeyStringAssoc;
    Link: TStringList;

    CachedParentSubTypeList: TStringList;

    function DoCache(const K: Integer; const IsClassName: Boolean;
      SubTypeList: TStrings; SubType: string; OnlyDirect: Boolean): Boolean;
    procedure CheckDBID;
//    function IntToKey(const I: Integer): Integer;
    function StringToKey(const S: String): Integer;
    procedure FillParentSubTypeList;
  public
    constructor Create;
    destructor Destroy; override;

    function GetSubTypeList(const InvDocumentTypeBranchKey: TID;
      SubTypeList: TStrings; SubType: string = ''; OnlyDirect: Boolean = False): Boolean;
    function GetSubTypeList2(const ClassName: String;
      SubTypeList: TStrings; Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
    function ClassParentSubtype(SubType: string): string;
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
    CachedSubTypeListOD.Clear;
    CachedSubTypeListST.Clear;
    CachedSubTypeListODST.Clear;
    CachedDBID := IBLogin.DBID;
  end;
end;

procedure TgdcInvDocumentCache.Clear;
begin
  CachedDBID := -1;
  CachedSubTypeList.Clear;
  CachedSubTypeListOD.Clear;
  CachedSubTypeListST.Clear;
  CachedSubTypeListODST.Clear;
  Link.Clear;
end;

constructor TgdcInvDocumentCache.Create;
begin
  CachedDBID := -1;
  CachedSubTypeList := TgdKeyStringAssoc.Create;
  CachedSubTypeListOD := TgdKeyStringAssoc.Create;
  CachedSubTypeListST := TgdKeyStringAssoc.Create;
  CachedSubTypeListODST := TgdKeyStringAssoc.Create;
  Link := TStringList.Create;
  Link.Sorted := False;
  Link.Duplicates := dupError;

  CachedParentSubTypeList := TStringList.Create;
  CachedParentSubTypeList.Sorted := False;
  CachedParentSubTypeList.Duplicates := dupError;
  if Assigned(CachedParentSubTypeList) then
    FillParentSubTypeList;
end;

destructor TgdcInvDocumentCache.Destroy;
begin
  Link.Free;
  CachedSubTypeList.Free;
  CachedSubTypeListOD.Free;
  CachedSubTypeListST.Free;
  CachedSubTypeListODST.Free;
  CachedParentSubTypeList.Free;
  inherited;
end;

function TgdcInvDocumentCache.DoCache(const K: Integer;
  const IsClassName: Boolean; SubTypeList: TStrings; SubType: string; OnlyDirect: Boolean): Boolean;
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
  if OnlyDirect then
    if Subtype <> '' then
      I := CachedSubTypeListODST.IndexOf(K)
    else
      I := CachedSubTypeListOD.IndexOf(K)
  else
    if Subtype <> '' then
      I := CachedSubTypeListST.IndexOf(K)
    else
      I := CachedSubTypeList.IndexOf(K);

  if I <> -1 then
  begin
    if OnlyDirect then
      if Subtype <> '' then
        SubTypeList.CommaText := CachedSubTypeListODST.ValuesByIndex[I]
      else
        SubTypeList.CommaText := CachedSubTypeListOD.ValuesByIndex[I]
    else
      if Subtype <> '' then
        SubTypeList.CommaText := CachedSubTypeListST.ValuesByIndex[I]
      else
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
        if OnlyDirect and (Subtype > '') then
        begin
          //непосредственные наследники от SubType
          ibsql.SQL.Text :=
            'SELECT '#13#10 +
            '  dt.name, '#13#10 +
            '  dt.ruid '#13#10 +
            'FROM gd_documenttype dt '#13#10 +
            '  JOIN gd_documenttype dt1 '#13#10 +
            '    ON dt.parent = dt1.id '#13#10 +
            'WHERE dt1.ruid = :ruid '#13#10 +
            '  AND dt.documenttype = ''D''';
          ibsql.ParamByName('RUID').AsString := SubType;
        end
        else if OnlyDirect and (Subtype = '') and (IsClassName) then
        begin
          //непосредственные наследники класса
          if Link[K] = 'TgdcInvBaseRemains' then
          begin
            ibsql.SQL.Text :=
              'SELECT '#13#10 +
              '  dt.name, '#13#10 +
              '  dt.ruid, '#13#10 +
              '  dt.parent '#13#10 +
              'FROM gd_documenttype dt '#13#10 +
              '  JOIN gd_documenttype dt1 '#13#10 +
              '    ON dt.LB >= dt1.lb '#13#10 +
              '      AND dt.rb <= dt1.rb '#13#10 +
              '  JOIN gd_documenttype dt2 '#13#10 +
              '    ON dt.parent = dt2.id '#13#10 +
              '      AND dt2.documenttype = ''B'' '#13#10 +
              'WHERE dt1.id = :id '#13#10 +
              '  AND dt.documenttype = ''D''';
            ibsql.ParamByName('id').AsInteger :=
              TgdcInvDocumentType.InvDocumentTypeBranchKey;
          end
          else
          begin
            ibsql.SQL.Text :=
              'SELECT '#13#10 +
              '  dt.name, '#13#10 +
              '  dt.ruid '#13#10 +
              'FROM gd_documenttype dt '#13#10 +
              '  JOIN gd_documenttype dt1 '#13#10 +
              '    ON dt.parent = dt1.id '#13#10 +
              '      AND dt1.documenttype = ''B'' '#13#10 +
              'WHERE dt.classname = :CN '#13#10 +
              '  AND dt.documenttype = ''D''';
            ibsql.ParamByName('CN').AsString := Link[K];
          end;
        end
        else if OnlyDirect and (Subtype = '') and (not IsClassName) then
        begin
          //непосредственные наследники ветви
          ibsql.SQL.Text :=
            'SELECT '#13#10 +
            '  dt.name, '#13#10 +
            '  dt.ruid, '#13#10 +
            '  dt.parent '#13#10 +
            'FROM gd_documenttype dt '#13#10 +
            '  JOIN gd_documenttype dt1 '#13#10 +
            '    ON dt.LB >= dt1.lb '#13#10 +
            '      AND dt.rb <= dt1.rb '#13#10 +
            '  JOIN gd_documenttype dt2 '#13#10 +
            '    ON dt.parent = dt2.id '#13#10 +
            '      AND dt2.documenttype = ''B'' '#13#10 +
            'WHERE dt1.id = :id '#13#10 +
            '  AND dt.documenttype = ''D''';
          ibsql.ParamByName('id').AsString := Link[K];
        end
        else if (not OnlyDirect) and (Subtype > '') then
        begin
          //вся иерархия наследников от Subtype
          ibsql.SQL.Text :=
            'SELECT '#13#10 +
            '  dt.name, '#13#10 +
            '  dt.ruid '#13#10 +
            'FROM gd_documenttype dt '#13#10 +
            '  JOIN gd_documenttype dt1 '#13#10 +
            '    ON dt.lb > dt1.lb '#13#10 +
            '      AND dt.rb < dt1.rb '#13#10 +
            'WHERE dt1.ruid = :ruid '#13#10 +
            '  AND dt.documenttype = ''D''';
          ibsql.ParamByName('RUID').AsString := SubType;
        end
        else if (not OnlyDirect) and (Subtype = '') and IsClassName then
        begin
          //вся иерархия наследников класса
          if Link[K] = 'TgdcInvBaseRemains' then
          begin
            ibsql.SQL.Text :=
              'SELECT '#13#10 +
              '  dt.name, '#13#10 +
              '  dt.ruid, '#13#10 +
              '  dt.parent '#13#10 +
              'FROM gd_documenttype dt '#13#10 +
              '  JOIN gd_documenttype dt1 '#13#10 +
              '    ON dt.LB >= dt1.lb '#13#10 +
              '      AND dt.rb <= dt1.rb '#13#10 +
              'WHERE dt1.id = :id '#13#10 +
              '  AND dt.documenttype = ''D''';
            ibsql.ParamByName('id').AsInteger :=
              TgdcInvDocumentType.InvDocumentTypeBranchKey;
          end
          else
          begin
            ibsql.SQL.Text :=
              'SELECT '#13#10 +
              '  name, ruid '#13#10 +
              'FROM gd_documenttype '#13#10 +
              'WHERE classname = :CN '#13#10 +
              '  AND documenttype = ''D''';
            ibsql.ParamByName('CN').AsString := Link[K];
          end;
        end
        else if (not OnlyDirect) and (Subtype = '') and (not IsClassName) then
        begin
          //вся иерархия наследников ветви
          ibsql.SQL.Text :=
            'SELECT '#13#10 +
            '  dt.name, '#13#10 +
            '  dt.ruid, '#13#10 +
            '  dt.parent '#13#10 +
            'FROM gd_documenttype dt '#13#10 +
            '  JOIN gd_documenttype dt1 '#13#10 +
            '    ON dt.LB >= dt1.lb '#13#10 +
            '      AND dt.rb <= dt1.rb '#13#10 +
            'WHERE dt1.id = :id '#13#10 +
            '  AND dt.documenttype = ''D''';
          ibsql.ParamByName('id').AsString := Link[K];
        end;

        ibsql.ExecQuery;

        SubTypeList.Clear;

        while not ibsql.EOF do
        begin
          if SubTypeList.IndexOfName(ibsql.FieldByName('name').AsString) = -1 then
          begin
            SubTypeList.Add(
              ibsql.FieldByName('name').AsString + '=' +
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

        if IsClassName and (Subtype = '') then
        begin
          if Link[K] = 'TgdcInvBaseRemains' then
          begin
            ibsql.SQL.Text :=
              'SELECT NAME, RUID FROM INV_BALANCEOPTION';
            ibsql.ExecQuery;
            while not ibsql.EOF do
            begin
              SubTypeList.Add(
                ibsql.FieldByName('NAME').AsString + '=' +
                ibsql.FieldByName('RUID').AsString);
              ibsql.Next;
            end;
            ibsql.Close;
          end;
        end;

        if OnlyDirect then
          if Subtype <> '' then
            CachedSubTypeListODST.ValuesByIndex[CachedSubTypeListODST.Add(K)] :=
              SubTypeList.CommaText
          else
            CachedSubTypeListOD.ValuesByIndex[CachedSubTypeListOD.Add(K)] :=
              SubTypeList.CommaText
        else
          if Subtype <> '' then
            CachedSubTypeListST.ValuesByIndex[CachedSubTypeListST.Add(K)] :=
              SubTypeList.CommaText
          else
            CachedSubTypeList.ValuesByIndex[CachedSubTypeList.Add(K)] :=
              SubTypeList.CommaText

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
  SubTypeList: TStrings; SubType: string = ''; OnlyDirect: Boolean = False): Boolean;
begin
  CheckDBID;
  Result := DoCache(StringToKey(IntToStr(InvDocumentTypeBranchKey) + Subtype), False, SubTypeList, SubType, OnlyDirect);
end;


function TgdcInvDocumentCache.GetSubTypeList2(const ClassName: String;
  SubTypeList: TStrings; Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
begin
  CheckDBID;
  Result := DoCache(StringToKey(ClassName + Subtype), True, SubTypeList, Subtype, OnlyDirect);
end;

//function TgdcInvDocumentCache.IntToKey(const I: Integer): Integer;
//begin
//  Result := Link.IndexOf(IntToStr(I));
//  if Result = -1 then
//    Result := Link.Add(IntToStr(I));
//end;

function TgdcInvDocumentCache.StringToKey(const S: String): Integer;
begin
  Result := Link.IndexOf(S);
  if Result = -1 then
    Result := Link.Add(S);
end;

procedure TgdcInvDocumentCache.FillParentSubTypeList;
var
  ibsql: TIBSQL;
begin
  CachedParentSubTypeList.Clear;

  if (not Assigned(gdcBaseManager))
    or (not Assigned(IBLogin)) then
  begin
//    Result := False;
    exit;
  end;

  ibsql := TIBSQL.Create(nil);
  ibsql.Transaction := gdcBaseManager.ReadTransaction;
  try
    ibsql.Close;
    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  dt.ruid AS SubType, '#13#10 +
      '  dt1.ruid AS ParentSubType '#13#10 +
      'FROM gd_documenttype dt '#13#10 +
      '  JOIN gd_documenttype dt1 '#13#10 +
      '    ON dt1.id = dt.parent '#13#10 +
      '      AND dt1.documenttype = ''D'' '#13#10 +
      'Where dt1.documenttype = ''D''';
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      CachedParentSubTypeList.Values[ibsql.Fields[0].AsString] := ibsql.Fields[1].AsString;
      ibsql.Next;
    end;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvDocumentCache.ClassParentSubtype(SubType: string): string;
begin
  Result := '';
  if CachedParentSubTypeList.Count = 0 then
  begin
    FillParentSubTypeList;
    Result := CachedParentSubTypeList.Values[SubType];
  end
  else
  begin
    Result := CachedParentSubTypeList.Values[SubType];
    if Result = '' then
    begin
      FillParentSubTypeList;
      Result := CachedParentSubTypeList.Values[SubType];
    end;
  end;
end;

initialization
  gdcInvDocumentCache := TgdcInvDocumentCache.Create;

finalization
  gdcInvDocumentCache := nil;
end.
