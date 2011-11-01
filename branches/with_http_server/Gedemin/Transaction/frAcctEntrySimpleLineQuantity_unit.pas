unit frAcctEntrySimpleLineQuantity_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, gdvParamPanel, frAcctQuantityLine_unit, contnrs, AcctUtils, IBSQL,
  gdcBaseInterface, Math;

type
  TfrEntrySimpleLineQuantity = class(TFrame)
    ppMain: TgdvParamPanel;
    procedure FrameResize(Sender: TObject);
  private
    FAnalyticsLineList: TObjectList;

    FOnValueChange: TNotifyEvent;
    function GetQuantityLine(Index: Integer): TfrAcctQuantityLine;
    function GetValues: string;
    procedure SetOnValueChange(const Value: TNotifyEvent);
    procedure SetValues(const Value: string);
    procedure SortLine;
    function GetQuantityCount: Integer;
  public
    destructor Destroy; override;
    procedure UpdateQuantityList(AIDList: TList);

    property QuantityCount: Integer read GetQuantityCount;
    property Quantities[Index: Integer]: TfrAcctQuantityLine read GetQuantityLine; default;
    property Values: string read GetValues write SetValues;
    property OnValueChange: TNotifyEvent read FOnValueChange write SetOnValueChange;
  end;

implementation

{$R *.DFM}

{ TfrEntrySimpleLineQuantity }


function TfrEntrySimpleLineQuantity.GetQuantityCount: Integer;
begin
  Result := 0;
  if FAnalyticsLineList <> nil then
    Result := FAnalyticsLineList.Count;
end;

function TfrEntrySimpleLineQuantity.GetQuantityLine(
  Index: Integer): TfrAcctQuantityLine;
begin
  Result := nil;
  if FAnalyticsLineList <> nil then
    Result := TfrAcctQuantityLine(FAnalyticsLineList[Index])
end;

function TfrEntrySimpleLineQuantity.GetValues: string;
var
  I: Integer;
  L: TfrAcctQuantityLine;
  S: TStrings;
begin
  Result := '';
  if FAnalyticsLineList <> nil then
  begin
    S := TStringList.Create;
    try
      for I := 0 to FAnalyticsLineList.Count - 1 do
      begin
        L := TfrAcctQuantityLine(FAnalyticsLineList[i]);

        if not L.IsEmpty then
        begin
          S.Add(Format('%d=%f', [L.ValueId, L.Value]));
        end;
      end;

      Result := S.Text;
    finally
      S.Free;
    end;
  end;
end;

procedure TfrEntrySimpleLineQuantity.SetOnValueChange(
  const Value: TNotifyEvent);
var
  I: Integer;
begin
  FOnValueChange := Value;
  if FAnalyticsLineList <> nil then
  begin
    for I := 0 to FAnalyticsLineList.Count - 1 do
    begin
      TfrAcctQuantityLine(FAnalyticsLineList[I]).OnValueChange := Value;
    end;
  end;
end;

procedure TfrEntrySimpleLineQuantity.SetValues(const Value: string);
var
  I: Integer;
  S: TStrings;
  L: TfrAcctQuantityLine;
  N: String;
begin
  if FAnalyticsLineList <> nil then
  begin
    S := TStringList.Create;
    try
      S.Text := Value;
      for I := 0 to FAnalyticsLineList.Count - 1 do
      begin
        L := TfrAcctQuantityLine(FAnalyticsLineList[i]);
        L.Value := 0;
        N := IntToStr(L.ValueId);
        if S.IndexOfName(N) > - 1 then
        begin
          L.Value := StrToFloat(S.Values[N]);
        end;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure TfrEntrySimpleLineQuantity.SortLine;
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
        S.AddObject(TfrAcctQuantityLine(FAnalyticsLineList[I]).lName.Caption,
          FAnalyticsLineList[I]);
      end;
      S.Sort;

      T := ppMain.ClientRect.Top;
      for I := 0 to S.Count - 1 do
      begin
        TfrAcctQuantityLine(S.Objects[I]).Top := T;
        T := T + TfrAcctQuantityLine(S.Objects[I]).Height;
      end;
    finally
      S.Free;
    end;
  end;
end;


procedure TfrEntrySimpleLineQuantity.UpdateQuantityList(AIDList: TList);
var
  I, Index: Integer;
  SQL: TIBSQl;
  Line: TfrAcctQuantityLine;
  H, W: Integer;
  P: Integer;
  LAnaliseLines: TObjectList;

  function IndexOf(id: Integer): Integer;
  var
    I: Integer;
  begin
    Result := - 1;
    for I := 0 to LAnaliseLines.Count - 1 do
    begin
      if TfrAcctQuantityLine(LAnaliseLines[I]).ValueId = Id then
      begin
        Result := I;
        Break;
      end;
    end
  end;
begin
  if FAnalyticsLineList = nil then
    FAnalyticsLineList := TObjectList.Create;

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
      P := ppMain.ClientRect.Top;
      SQL.SQL.Text := 'SELECT v.id, v.name FROM AC_ACCVALUE av LEFT JOIN gd_value v ON v.id = av.valuekey ';
      if AIDList.Count > 0 then
         SQL.SQL.Add(Format(' WHERE av.accountkey IN (%s)', [AcctUtils.IdList(AIdList)]));
      SQL.ExecQuery;
      while not SQL.Eof do
      begin
        Index := IndexOf(SQL.FieldByName('id').AsInteger);
        if Index = - 1 then
        begin
          Line := TfrAcctQuantityLine.Create(Self);
          FAnalyticsLineList.Add(Line);
          with Line do
          begin
            Name := 'frAcctQuantityLine_' + SQL.FieldByName('id').AsString;
            Parent := ppMain;
            Color := ppMain.FillColor;
            Align := alTop;
            lName.Caption := SQL.FieldByName('name').AsString;
            ValueId := SQL.FieldByName('id').AsInteger;
          end;
          Line.OnValueChange := OnValueChange;
        end else
        begin
          Line := TfrAcctQuantityLine(LAnaliseLines[Index]);
          FAnalyticsLineList.Add(LAnaliseLines[Index]);
          LAnaliseLines.Extract(LAnaliseLines[Index]);
        end;
        with Line do
        begin
          H := Height;
          Top := P;
        end;
        P := P + H;

        SQL.Next;
      end;

      ppMain.UpdateHeight(Max(P + 4, cMinUnwrapedHeight));
    finally
      SQL.Free;
    end;
  finally
    LAnaliseLines.Free;
  end;

  W := 0;
  for I := 0 to ppMain.ControlCount - 1 do
  begin
    W := Max(TfrAcctQuantityLine(ppMain.Controls[i]).lName.Left +
      TfrAcctQuantityLine(ppMain.Controls[i]).lName.Width, W);
  end;
  W := W + 5;
  for I := 0 to ppMain.ControlCount - 1 do
  begin
    TfrAcctQuantityLine(ppMain.Controls[i]).eCalc.Left := W;
    TfrAcctQuantityLine(ppMain.Controls[i]).eCalc.Width := TfrAcctQuantityLine(ppMain.Controls[i]).ClientWidth - 2 - W;
  end;
  SortLine;
  UpdateTabOrder(ppMain);
  Realign;
end;

procedure TfrEntrySimpleLineQuantity.FrameResize(Sender: TObject);
begin
  ppMain.Width := ClientWidth;
end;

destructor TfrEntrySimpleLineQuantity.Destroy;
begin
  FreeAndNil(FAnalyticsLineList);

  inherited;
end;

end.
