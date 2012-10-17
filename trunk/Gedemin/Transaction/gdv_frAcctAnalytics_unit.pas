
unit gdv_frAcctAnalytics_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, gdvParamPanel, contnrs, IBSQL, AcctUtils, gdv_frAcctAnalyticLine_unit,
  at_classes, gdcBaseInterface, gd_common_functions, AcctStrings;

type
  TfrAcctAnalytics = class(TFrame)
    ppAnalytics: TgdvParamPanel;
    procedure FrameResize(Sender: TObject);

  private
    FAnalyticsLineList: TObjectList;
    FAnalyticsFieldList: TList;
    FAlias: string;
    FOnValueChange: TNotifyEvent;
    FNeedNull: Boolean;
    FNeedSet: Boolean;

    procedure SortLine;
    function GetAnalyticsCount: Integer;
    function GetAnalytics(Index: Integer): TfrAcctAnalyticLine;
    function GetValues: string;
    procedure SetAlias(const Value: string);
    procedure SetValues(const Value: string);
    procedure ClearValues;
    function IndexOf(FieldName: string): Integer;
    function GetCondition: string;
    procedure SetOnValueChange(const Value: TNotifyEvent);
    procedure OnFrameResize(Sender: TObject);

  public
    destructor Destroy; override;
    procedure UpdateAnalyticsList(AIDList: TList; const ANeedNull: boolean = True; const ANeedSet: boolean = True);
    procedure SaveToStream(const Stream: TStream);
    procedure LoadFromStream(const Stream: TStream);

    property AnalyticsCount: Integer read GetAnalyticsCount;
    property Analytics[Index: Integer]: TfrAcctAnalyticLine read GetAnalytics; default;

    property Alias:  string read FAlias write SetAlias;
    property Values: string read GetValues write SetValues;
    property Condition: string read GetCondition;
    property OnValueChange: TNotifyEvent read FOnValueChange write SetOnValueChange;
    property NeedNull: Boolean read FNeedNull write FNeedNull;
    property NeedSet: Boolean read FNeedSet write FNeedSet;
  end;

implementation

uses Math;

{$R *.DFM}

{ TfrAcctAnalytics }

procedure TfrAcctAnalytics.ClearValues;
var
  I: Integer;
begin
  if FAnalyticsLineList <> nil then
    for I := 0 to FAnalyticsLineList.Count - 1 do
      Analytics[I].Clear;
end;

destructor TfrAcctAnalytics.Destroy;
begin
  FAnalyticsLineList.Free;
  FAnalyticsFieldList.Free;

  inherited;
end;

function TfrAcctAnalytics.GetAnalytics(
  Index: Integer): TfrAcctAnalyticLine;
begin
  Result := nil;
  if FAnalyticsLineList <> nil then
    Result := TfrAcctAnalyticLine(FAnalyticsLineList[Index]);
end;

function TfrAcctAnalytics.GetAnalyticsCount: Integer;
begin
  Result := 0;
  if FAnalyticsLineList <> nil then
    Result := FAnalyticsLineList.Count;
end;

function TfrAcctAnalytics.GetCondition: string;
var
  I: Integer;
  Line: TfrAcctAnalyticLine;
  F: TatRelationField;
begin
  Result := '';
  if FAnalyticsLineList <> nil then
  begin
    for I := 0 to FAnalyticsLineList.Count - 1 do
    begin
      Line := Analytics[I];
      F := Line.Field;
      if not Line.IsEmpty then
      begin
        if Result > '' then
          Result := Result + ' AND '#13#10;
        Result := Result + Format('%s.%s IN (%s)', [FAlias, F.FieldName, Line.Value]);
      end
      else begin
        if FNeedNull and Line.IsNull then begin
          if Result > '' then
            Result := Result + ' AND '#13#10;
          Result := Result + FAlias + '.' + F.FieldName + ' IS NULL ';
        end;
      end;
    end;
  end;
end;

function TfrAcctAnalytics.GetValues: string;
var
  I: Integer;
  Line: TfrAcctAnalyticLine;
begin
  Result := '';
  if FAnalyticsLineList <> nil then
  begin
    for I := 0 to FAnalyticsLineList.Count - 1 do
    begin
      Line := Analytics[I];
      if not Line.IsEmpty then
      begin
        if Result > '' then
          Result := Result + #13#10;
        Result := Result + Line.Field.FieldName + '=' + Line.Value;
      end
      else
        if Line.IsNull then begin
          if Result > '' then
            Result := Result + #13#10;
          Result := Result + Line.Field.FieldName + '=NULL';
        end;
    end;
  end;
end;

function TfrAcctAnalytics.IndexOf(FieldName: string): Integer;
var
  I: Integer;
  F: TatRelationField;
begin
  Result := -1;
  if FAnalyticsLineList <> nil then
    for I := 0 to FAnalyticsLineList.Count -1 do
    begin
      F := Analytics[I].Field;
      if F.FieldName = UpperCase(FieldName) then
      begin
        Result := I;
        Exit;
      end;
    end;
end;

procedure TfrAcctAnalytics.SetAlias(const Value: string);
begin
  FAlias := Value;
end;

procedure TfrAcctAnalytics.SetValues(const Value: string);
var
  S: TStrings;
  I: Integer;
  Index: Integer;
  Line: TfrAcctAnalyticLine;
begin
  ClearValues;
  S := TStringList.Create;
  try
    S.Text := Value;
    for I := 0 to S.Count - 1 do
    begin
      if S.Values[S.Names[I]] <> cInputParam then
      begin
        Index := IndexOf(S.Names[I]);
        if Index > - 1 then
        begin
          Line := Analytics[Index];
          Line.Value := S.Values[S.Names[I]];
        end;
      end;
    end;
  finally
    S.Free;
  end;
end;

procedure TfrAcctAnalytics.SortLine;
var
  S: TStringList;
  I: Integer;
  T: Integer;
begin
  if FAnalyticsLineList.Count > 0 then
  begin
    S := TStringList.Create;
    try
      for I := 0 to FAnalyticsLineList.Count - 1 do
      begin
        S.AddObject(TfrAcctAnalyticLine(FAnalyticsLineList[I]).lAnaliticName.Caption,
          FAnalyticsLineList[I]);
      end;
      S.Sort;

      T := ppAnalytics.ClientRect.Top;
      for I := 0 to S.Count - 1 do
      begin
        TfrAcctAnalyticLine(S.Objects[I]).Top := T;
        T := T + TfrAcctAnalyticLine(S.Objects[I]).Height;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure TfrAcctAnalytics.UpdateAnalyticsList(AIDList: TList; const ANeedNull: boolean = True; const ANeedSet: boolean = True);
var
  I, Index: Integer;
  SQL: TIBSQl;
  Line: TfrAcctAnalyticLine;
  H: Integer;
  P, C: Integer;
  LAnaliseLines: TObjectList;

  function IndexOf(Field: TatRelationField): Integer;
  var
    I: Integer;
  begin
    Result := - 1;
    for I := 0 to LAnaliseLines.Count - 1 do
    begin
      if TfrAcctAnalyticLine(LAnaliseLines[I]).Field = Field then
      begin
        Result := I;
        Break;
      end;
    end
  end;

begin
  if FAnalyticsLineList = nil then
    FAnalyticsLineList := TObjectList.Create;

  if FAnalyticsFieldList = nil then
  begin
    FAnalyticsFieldList := TList.Create;
    GetAnalyticsFields(FAnalyticsFieldList);
  end;

  NeedNull:= ANeedNull;
  LAnaliseLines := TObjectList.Create(True);
  try
    for I := FAnalyticsLineList.Count - 1 downto 0 do
    begin
      LAnaliseLines.Add(FAnalyticsLineList[I]);
      FAnalyticsLineList.Extract(FAnalyticsLineList[I]);
    end;

    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      P := ppAnalytics.ClientRect.Top;
      if AIDList.Count > 0 then begin
        for I := 0 to FAnalyticsFieldList.Count - 1 do begin
          if SQL.SQL.Count > 0 then
            SQL.SQL.Add(', ');

          SQL.SQL.Add(Format('Sum(%s)', [TatRelationField(FAnalyticsFieldList[i]).FieldName]));
        end;
        if FAnalyticsFieldList.Count > 0 then
        begin
          SQL.SQL.Insert(0, 'SELECT ');
          SQL.SQL.Add('FROM ac_account ');
          SQL.SQL.Add(Format('WHERE id IN (%s)', [AcctUtils.IdList(AIdList)]));
          SQL.ExecQuery;
        end;
      end;

      for I := 0 to FAnalyticsFieldList.Count - 1 do
      begin

        if AIDList.Count > 0 then
          C := SQL.Fields[i].AsInteger
        else
          C := 0;

        try
          if (C = AIDList.Count)
            or (TatRelationField(FAnalyticsFieldList[i]).FieldName = 'ACCOUNTKEY')
            or (TatRelationField(FAnalyticsFieldList[i]).FieldName = 'CURRKEY') then
          begin
            Index := IndexOf(TatRelationField(FAnalyticsFieldList[i]));
            if Index = - 1 then
            begin
              Line := TfrAcctAnalyticLine.Create(Self);
              Line.NeedNull := ANeedNull;
              Line.NeedSet := ANeedSet;
              FAnalyticsLineList.Add(Line);
              with Line do
              begin
                Name := 'frAcctAnaliticLine_' + StringReplace(TatRelationField(FAnalyticsFieldList[i]).FieldName, '$', '_', [rfReplaceAll]);
                Field := TatRelationField(FAnalyticsFieldList[i]);
                Parent := ppAnalytics;
                Color := ppAnalytics.FillColor;
                Align := alTop;
              end;
              Line.OnValueChange := OnValueChange;
              Line.OnResize := OnFrameResize;
            end else
            begin
              Line := TfrAcctAnalyticLine(LAnaliseLines[Index]);
              FAnalyticsLineList.Add(LAnaliseLines[Index]);
              LAnaliseLines.Extract(LAnaliseLines[Index]);
            end;
            with Line do
            begin
              H := Height;
              Top := P;
            end;
            P := P + H;
          end;
        finally
          SQL.Close;
        end;
      end;
      ppAnalytics.UpdateHeight(Max(P + 4, cMinUnwrapedHeight));
    finally
      SQL.Free;
    end;

  finally
    LAnaliseLines.Free;
  end;
  
  SortLine;
  UpdateTabOrder(ppAnalytics);
end;

procedure TfrAcctAnalytics.LoadFromStream(const Stream: TStream);
begin
  Values := ReadStringFromStream(Stream);
end;

procedure TfrAcctAnalytics.SaveToStream(const Stream: TStream);
begin
  SaveStringToStream(Values, Stream);
end;

procedure TfrAcctAnalytics.SetOnValueChange(const Value: TNotifyEvent);
var
  I: Integer;
begin
  FOnValueChange := Value;
  if FAnalyticsLineList <> nil then
  begin
    for I := 0 to FAnalyticsLineList.Count - 1 do
    begin
      TfrAcctAnalyticLine(FAnalyticsLineList[I]).OnValueChange := Value;
    end;
  end;
end;

procedure TfrAcctAnalytics.FrameResize(Sender: TObject);
var
  I: Integer;
begin
  ppAnalytics.Width := ClientWidth;
  if FAnalyticsLineList <> nil then
  begin
    for I := 0 to FAnalyticsLineList.Count - 1 do
      (FAnalyticsLineList[I] as TfrAcctAnalyticLine).ResizeControls;
  end;
end;

procedure TfrAcctAnalytics.OnFrameResize(Sender: TObject);
var
  I, P: Integer;
  Line: TfrAcctAnalyticLine;
begin
  if FAnalyticsLineList <> nil then
  begin
    P := ppAnalytics.ClientRect.Top;
    for I := FAnalyticsLineList.Count - 1 downto 0 do
    begin
      Line :=  FAnalyticsLineList[I] as TfrAcctAnalyticLine;
      P := P + Line.Height;
    end;
    ppAnalytics.UpdateHeight(Max(P + 4, cMinUnwrapedHeight));
  end; 
end;

end.
