// ShlTanya, 09.03.2019

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
    FOnValueChange: TNotifyEvent;
    FNeedNull: Boolean;
    FNeedSet: Boolean;
    FContext: String;

    procedure SortLine;
    function GetAnalyticsCount: Integer;
    function GetAnalytics(Index: Integer): TfrAcctAnalyticLine;
    function GetValues: string;
    procedure SetValues(const Value: string);
    procedure ClearValues;
    function IndexOf(FieldName: string): Integer;
    procedure SetOnValueChange(const Value: TNotifyEvent);
    procedure OnFrameResize(Sender: TObject);
    function GetDescription: String;

  public
    destructor Destroy; override;
    procedure UpdateAnalyticsList(AIDList: TList; const ANeedNull: boolean = True; const ANeedSet: boolean = True; const ShowAddAnaliseLines: boolean = True);
    procedure SaveToStream(const Stream: TStream);
    procedure LoadFromStream(const Stream: TStream);

    property AnalyticsCount: Integer read GetAnalyticsCount;
    property Analytics[Index: Integer]: TfrAcctAnalyticLine read GetAnalytics; default;
    property Values: string read GetValues write SetValues;
    property OnValueChange: TNotifyEvent read FOnValueChange write SetOnValueChange;
    property NeedNull: Boolean read FNeedNull write FNeedNull;
    property NeedSet: Boolean read FNeedSet write FNeedSet;
    property Description: String read GetDescription;
    property Context: String write FContext;
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
        if (TfrAcctAnalyticLine(FAnalyticsLineList[I]).Field.FieldName <> 'DOCUMENTTYPEKEY')
          and (TfrAcctAnalyticLine(FAnalyticsLineList[I]).Field.FieldName <> 'CURRKEY')
        then
          S.AddObject(TfrAcctAnalyticLine(FAnalyticsLineList[I]).lAnaliticName.Caption,
            FAnalyticsLineList[I]);
      end;
      S.Sort;

      for I := 0 to FAnalyticsLineList.Count - 1 do
      begin
        if (TfrAcctAnalyticLine(FAnalyticsLineList[I]).Field.FieldName = 'DOCUMENTTYPEKEY')
          or (TfrAcctAnalyticLine(FAnalyticsLineList[I]).Field.FieldName = 'CURRKEY')
        then
          S.AddObject(TfrAcctAnalyticLine(FAnalyticsLineList[I]).lAnaliticName.Caption,
            FAnalyticsLineList[I]);
      end;

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

procedure TfrAcctAnalytics.UpdateAnalyticsList(AIDList: TList; const ANeedNull: boolean = True; const ANeedSet: boolean = True;
const ShowAddAnaliseLines: boolean = True);
var
  I, Index: Integer;
  SQL: TIBSQl;
  Line: TfrAcctAnalyticLine;
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
    if ShowAddAnaliseLines then
      GetAnalyticsFields(FAnalyticsFieldList)
    else
      GetAnalyticsFieldsWithoutAddAnaliseLines(FAnalyticsFieldList);
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
      if AIDList.Count > 0 then
      begin
        for I := 0 to FAnalyticsFieldList.Count - 1 do
        begin
          if ((TatRelationField(FAnalyticsFieldList[i]).FieldName) <> 'DOCUMENTTYPEKEY')
            and ((TatRelationField(FAnalyticsFieldList[i]).FieldName) <> 'CURRKEY') then
          begin
            if SQL.SQL.Count > 0 then
              SQL.SQL.Add(', ');
            SQL.SQL.Add(Format('SUM(%s)', [TatRelationField(FAnalyticsFieldList[i]).FieldName]));
          end;
        end;

        if FAnalyticsFieldList.Count > 0 then
        begin
          SQL.SQL.Insert(0, 'SELECT ');
          SQL.SQL.Add('FROM ac_account ');
          SQL.SQL.Add(Format('WHERE id IN (%s)', [AcctUtils.IdList(AIdList, FContext)]));
          SQL.ExecQuery;
        end;
      end;
      for I := 0 to FAnalyticsFieldList.Count - 1 do
      begin
        if (AIDList.Count > 0)
          and ((TatRelationField(FAnalyticsFieldList[i]).FieldName) <> 'DOCUMENTTYPEKEY')
          and ((TatRelationField(FAnalyticsFieldList[i]).FieldName) <> 'CURRKEY')
        then
          C := SQL.Fields[i].AsInteger
        else
          C := 0;
        try
          if (C = AIDList.Count)
            or (TatRelationField(FAnalyticsFieldList[i]).FieldName = 'ACCOUNTKEY')
            or (TatRelationField(FAnalyticsFieldList[i]).FieldName = 'CURRKEY')
            or (TatRelationField(FAnalyticsFieldList[i]).FieldName = 'DOCUMENTTYPEKEY')
            then
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
              FAnalyticsLineList.Add(LAnaliseLines[Index]);
              LAnaliseLines.Extract(LAnaliseLines[Index]);
            end;
          end;
        finally
          SQL.Close;
        end;
      end;
      if FAnalyticsLineList <> nil then
      begin
        P := ppAnalytics.ClientRect.Top;
        for I := 0 to FAnalyticsLineList.Count - 1 do
          P := P + (FAnalyticsLineList[I] as TfrAcctAnalyticLine).Height;

        ppAnalytics.UpdateHeight(Max(P + 4, cMinUnwrapedHeight));
        ClientHeight := ppAnalytics.Height;
      end;
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

function TfrAcctAnalytics.GetDescription: String;
var
  I: Integer;
begin
  Result := '';

  if FAnalyticsLineList <> nil then
  begin
    for I := 0 to FAnalyticsLineList.Count - 1 do
    begin
      if (FAnalyticsLineList[I] as TfrAcctAnalyticLine).Description > '' then
        Result := Result + (FAnalyticsLineList[I] as TfrAcctAnalyticLine).Description + '; ';
    end;
    if Result > '' then
      SetLength(Result, Length(Result) - 2);
  end;
end;

end.
