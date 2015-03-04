unit wiz_frAnalytics_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, AcctUtils, IBSQL, gdcBaseInterface, wiz_FunctionBlock_unit,
  at_Classes, contnrs, gdc_frmAnalyticsSel_unit, wiz_frAnalyticLine_unit,
  Math;

type
  TfrAnalytics = class(TFrame)
    Panel: TPanel;
    sbAnalytics: TScrollBox;
  private
    FAvailAnalyticFields: TList;
    FAccountKey: Integer;

    FAccountAnalyticFields: TList;
    FBlock: TVisualBlock;
    FReadAnalytics: String;

    procedure SetAccountKey(const Value: Integer);
    procedure SetBlock(const Value: TVisualBlock);
  protected
    FAnalyticLines: TObjectList;
    function GetAnalytics: string; virtual;
    procedure SetAnalytics(const Value: string); virtual;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateAnalytics;
    property Analytics: string read GetAnalytics write SetAnalytics;
    property AccountKey: Integer read FAccountKey write SetAccountKey;
    property Block: TVisualBlock read FBlock write SetBlock;
    property ReadAnalytics: String read FReadAnalytics write FReadAnalytics;
  end;

implementation

{$R *.DFM}

function LNameSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareText(Trim(TatRelationField(item1).LName), Trim(TatRelationField(item2).LName));
end;

{ TfrAnalytics }

constructor TfrAnalytics.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TfrAnalytics.Destroy;
begin
  if Assigned(FAvailAnalyticFields) then
    FreeAndNil(FAvailAnalyticFields);
  if Assigned(FAccountAnalyticFields) then
    FreeAndNil(FAccountAnalyticFields);
  if Assigned(FAnalyticLines) then
    FreeandNil(FAnalyticLines);

  inherited;
end;

function TfrAnalytics.GetAnalytics: string;
var
  S: TStrings;
  I: Integer;
begin
  Result := '';
  if (FAnalyticLines <> nil) and (FAnalyticLines.Count > 0) then
  begin
    S := TStringList.Create;
    try
      for I := 0 to FAnalyticLines.Count - 1 do
      begin
        if TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text > '' then
        begin
          if (TfrAnalyticLine(FAnalyticLines[I]).Field.ReferencesField <> nil) and
            (TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey > 0) then
          begin
            S.Add(TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
              '=' + gdcBaseManager.GetRUIDStringById(TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey))
          end else
            S.Add(TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
              '=' + TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text);
        end;
      end;
      Result := S.Text;
    finally
      S.Free;
    end;
  end;
end;

procedure TfrAnalytics.SetAccountKey(const Value: Integer);
begin
  FAccountKey := Value;
end;

procedure TfrAnalytics.SetAnalytics(const Value: string);
var
  SQL: TIBSQL;
  S: TStrings;
  FieldName: string;
  Id, I, J: Integer;
begin
  Update;

  if (FAnalyticLines <> nil) and (FAnalyticLines.Count > 0) then
  begin
    SQL := TIBSQL.Create(nil);
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    S := TStringList.Create;
    try
      S.Text := Value;
      for I := 0 to S.Count - 1 do
      begin
        FieldName := S.Names[I];
        for J := 0 to FAnalyticLines.Count - 1 do
        begin
          if TfrAnalyticLine(FAnalyticLines[J]).Field.FieldName = FieldName then
          begin
            id := 0;
            if TfrAnalyticLine(FAnalyticLines[J]).Field.ReferencesField <> nil then
            begin
              try
                if CheckRuid(S.Values[FieldName]) then
                  id := gdcBaseManager.GetIDByRUIDString(S.Values[FieldName])
                else
                  id := 0;
              except
                Id := 0;
              end;
            end;

            if id > 0 then
            begin
              SQL.SQl.Text := Format('SELECT %s FROM %s WHERE %s = %d',
                [TfrAnalyticLine(FAnalyticLines[J]).Field.References.ListField.FieldName,
                TfrAnalyticLine(FAnalyticLines[J]).Field.References.RelationName,
                TfrAnalyticLine(FAnalyticLines[J]).Field.ReferencesField.FieldName,
                id]);
              SQL.ExecQuery;
              try
                TfrAnalyticLine(FAnalyticLines[J]).eAnalytic.Text := SQL.Fields[0].AsString;
                TfrAnalyticLine(FAnalyticLines[J]).AnalyticKey := Id;
              finally
                SQL.Close;
              end;
            end else
              TfrAnalyticLine(FAnalyticLines[J]).eAnalytic.Text := S.Values[FieldName];
          end;
        end;
      end;
    finally
      S.Free;
      SQL.Free;
    end;
  end;
end;

procedure TfrAnalytics.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
end;

procedure TfrAnalytics.UpdateAnalytics;
var
  I, J: Integer;
  SQL: TIBSQL;
  SelectClause: string;
  Line: TfrAnalyticLine;
  W, T: Integer;
  Lines: TObjectList;
  S, FAddList: TStringList;
  FieldName: string;
  FToAdd: Boolean;
begin
  if FAvailAnalyticFields = nil then
  begin
    FAvailAnalyticFields := TList.Create;
    GetAnalyticsFields(FAvailAnalyticFields);
  end;

  if FAccountAnalyticFields = nil then
    FAccountAnalyticFields := TList.Create;

  FAccountAnalyticFields.Clear;

  if FAccountKey = 0 then
  begin
    for I := 0 to FAvailAnalyticFields.Count - 1 do
    begin
      FAccountAnalyticFields.Add(FAvailAnalyticFields[i]);
    end;
  end else
  begin
    SQL := TIBSQL.Create(nil);
    FAddList := TStringList.Create;
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;

      SelectClause := '';
      for I := 0 to FAvailAnalyticFields.Count - 1 do
      begin
        if SelectClause > '' then
          SelectClause := SelectClause + ',';
        SelectClause := SelectClause + Format('Sum(a.%s) AS %s',
          [TatRelationField(FAvailAnalyticFields[I]).FieldName,
          TatRelationField(FAvailAnalyticFields[I]).FieldName]);
      end;

      if SelectClause > '' then
      begin
        { TODO : Нужно подумать с планом счетов }
        SQL.SQL.Text := Format('SELECT %s FROM ac_account a JOIN ac_account c ' +
          ' ON c.lb <= a.lb AND c.rb >= c.rb AND c.accounttype = ''C'' WHERE a.id = %d '+
          ' AND c.id = %d', [SelectClause, FAccountKey,
          gdcBaseManager.GetIdByRUIDString(MainFunction.CardOfAccountsRUID)]);
        SQL.ExecQuery;
        if SQL.RecordCount > 0 then
        begin
          for I := 0 to SQL.Current.Count - 1 do
          begin
            if SQL.Current[I].AsInteger > 0 then
            begin
              for J := 0 to FAvailAnalyticFields.Count - 1 do
              begin
                if TatRelationField(FAvailAnalyticFields[J]).FieldName = SQL.Current[I].Name then
                begin
                  FAccountAnalyticFields.Add(FAvailAnalyticFields[J]);
                  FAddList.Add(SQL.Current[I].Name);
                end;
              end;
            end;
          end;
        end;
      end;

      S := TStringList.Create;
      try
        S.Text := FReadAnalytics;
        CheckAnalyticsList(S);

        for I := 0 to FAvailAnalyticFields.Count - 1 do
        begin
          FToAdd := False;
          for J := 0 to S.Count - 1 do
          begin
            FieldName := S.Names[J];
            if TatRelationField(FAvailAnalyticFields[I]).FieldName = FieldName then
            begin
              if FAddList.IndexOf(FieldName) = -1 then
                FToAdd := True;
              break;
            end;
          end;
          
          if FToAdd then
            FAccountAnalyticFields.Add(FAvailAnalyticFields[I]);
        end;
      finally
        S.Free;
      end;
    finally
      SQL.Free;
      FAddList.Free;
    end;
  end;

  if FAnalyticLines = nil then
    FAnalyticLines := TObjectList.Create;

  Lines := TObjectList.Create;
  try
    for i := FAnalyticLines.Count - 1 downto 0 do
    begin
      Line := TfrAnalyticLine(FAnalyticLines[i]);
      FAnalyticLines.Extract(Line);
      Lines.Add(Line);
      Line.Parent := nil;
    end;
    FAnalyticLines.Clear;

    W := 0;
    FAccountAnalyticFields.Sort(LNameSortCompare);
    for I := 0 to FAccountAnalyticFields.Count - 1 do
    begin
      Line := nil;
      for J := Lines.Count - 1 downto 0 do
      begin
        if TfrAnalyticLine(Lines[J]).Field = TatRelationField(FAccountAnalyticFields[I]) then
        begin
          Line := TfrAnalyticLine(Lines[J]);
          Lines.Extract(Line);
          FAnalyticLines.Add(Line);
        end;
      end;

      if Line = nil then
      begin
        Line := TfrAnalyticLine.Create(nil);
        FAnalyticLines.Add(Line);
        Line.Field := TatRelationField(FAccountAnalyticFields[I]);
        Line.Block := FBlock;
      end;
      Line.Parent := sbAnalytics;
      W := Max(W, Line.lName.Width + Line.lName.Left);
    end;

    T := 0;
    for i := 0 to FAnalyticLines.Count - 1 do
    begin
      Line := TfrAnalyticLine(FAnalyticLines[i]);
      Line.Top := T;
      Line.TabOrder := i;
      Line.eAnalytic.Left := W + 3;
      Line.eAnalytic.Width := Line.Width - Line.eAnalytic.Left - 3;
      T := Line.Height + T;
    end;
  finally
    Lines.Free;
  end;
end;

end.
