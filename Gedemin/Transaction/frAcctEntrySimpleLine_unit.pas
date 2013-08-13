
unit frAcctEntrySimpleLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frAcctAnalytics_unit, StdCtrls,
  xCalculatorEdit, gsIBLookupComboBox, ExtCtrls, gdvParamPanel, IBDatabase,
  Db, gdcAcctEntryRegister, dmDataBase_unit, at_classes, IBSQL, gdcbaseInterface,
  gdcBase, frAcctEntrySimpleLineQuantity_unit, gd_security, Storages, gsStorage_CompPath;

type
  TfrAcctEntrySimpleLine = class(TFrame)
    Transaction: TIBTransaction;
    DataSource: TDataSource;
    Panel1: TPanel;
    ppMain: TgdvParamPanel;
    Panel5: TPanel;
    lAccount: TLabel;
    lSum: TLabel;
    lCurr: TLabel;
    lRate: TLabel;
    lSumCurr: TLabel;
    cbAccount: TgsIBLookupComboBox;
    cSum: TxDBCalculatorEdit;
    cbCurrency: TgsIBLookupComboBox;
    cRate: TxCalculatorEdit;
    cCurrSum: TxDBCalculatorEdit;
    frAcctAnalytics: TfrAcctAnalytics;
    frQuantity: TfrEntrySimpleLineQuantity;
    lEQ: TLabel;
    cEQSum: TxDBCalculatorEdit;
    cbRounded: TCheckBox;
    procedure cbAccountChange(Sender: TObject);
    procedure cRateChange(Sender: TObject);
    procedure cSumChange(Sender: TObject);
    procedure cCurrSumChange(Sender: TObject);
    procedure cbCurrencyChange(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure ppMainResize(Sender: TObject);
    procedure cbAccountExit(Sender: TObject);

  private
    FAccountPart: string;
    FDataSet: TDataSet;
    FFocused: Boolean;
    FOnChange: TNotifyEvent;
    FOffBalance: Boolean;
    FMultyCurr: Boolean;
    FEQ: boolean;
    FDisableCount: Integer;
    FgdcObject: TgdcBase;

    procedure SetAccountPart(const Value: string);

    procedure UpdateCaption;
    procedure UpdateControls;
    procedure SetDataSet(const Value: TDataSet);
    function GetId: Integer;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure OnValueChange(Sender: TObject);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure DoChange(Sender: TObject);
    procedure SetOffBalance(const Value: Boolean);
    procedure SetMultyCurr(const Value: Boolean);
    function CurrRate(CurrKey: Integer): Currency;
    function ControlEnabled: Boolean;
    procedure CalcCurrency(isCurrency: Boolean);
    procedure SetgdcObject(const Value: TgdcBase);
    procedure CheckEditMode;
    function GetCRate: Currency;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DisableControls;
    procedure EnableControls;
    procedure SaveAnalytic;
    procedure LoadAnalytic;
    procedure SetCurrRate(CurrKey: Integer; Rate: Currency);
    property AccountPart: string read FAccountPart write SetAccountPart;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property Id: Integer read GetId;
    property IsFocused: Boolean read FFocused;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property MultyCurr: Boolean read FMultyCurr write SetMultyCurr;
    property BalanceOff: Boolean read FOffBalance write SetoffBalance;
    property gdcObject: TgdcBase read FgdcObject write SetgdcObject;
    property zRate: Currency read GetCRate;
  end;

implementation

{$R *.DFM}

const
  cMinHeight = 49; 
  cEQHeight = 23;
  cMaxHeight = 117;

procedure TfrAcctEntrySimpleLine.cbAccountChange(Sender: TObject);
begin
  if ControlEnabled then
  begin
    DoChange(Sender);
  end;  
end;

procedure TfrAcctEntrySimpleLine.SetAccountPart(const Value: string);
begin
  if FAccountPart <> Value then
  begin
    FAccountPart := Value;
    if FAccountPart = 'D' then
    begin
      cSum.DataField := 'DEBITNCU';
      cCurrSum.DataField := 'DEBITCURR';
      cEQSum.DataField := 'DEBITEQ';
    end else
    begin
      cSum.DataField := 'CREDITNCU';
      cCurrSum.DataField := 'CREDITCURR';
      cEQSum.DataField := 'CREDITEQ';
    end;
  end;
end;

procedure TfrAcctEntrySimpleLine.UpdateCaption;
var
  SQL: TIBSQL;
  S: string;
begin
  if cbAccount.CurrentKey > '' then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQl.SQL.Text := 'SELECT alias, name FROM ac_account WHERE id = :id';
      SQl.ParamByName('id').AsInteger := cbAccount.CurrentKeyInt;
      SQl.ExecQuery;

      S := SQl.FieldByName('Alias').AsString;
      if S > '' then S := S + ' ';
      S := S + SQl.FieldByName('name').AsString;
      ppMain.Caption := S;
    finally
      SQL.free;
    end;
  end else
    ppMain.Caption := '';
end;

procedure TfrAcctEntrySimpleLine.UpdateControls;
var
  L: TList;
  SQL: TIBSQL;
  ComponentPath: String;
const
  HeightArray: array[False..True, False..True] of Integer = ((cMinHeight, cMinHeight + cEQHeight), (cMaxHeight, cMaxHeight + cEQHeight));
begin
  if (FDataSet <> nil) and (FDataSet.Active) then
  begin
    L := TList.Create;
    try
      L.Add(Pointer(cbAccount.CurrentKeyInt));
      frAcctAnalytics.UpdateAnalyticsList(L, False, False);
      frQuantity.UpdateQuantityList(L);
    finally
      L.Free;
    end;

    if Assigned(GlobalStorage) and Assigned(IBLogin)
        and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_EQ_ID, GD_POL_EQ_MASK, False) and IBLogin.InGroup) = 0) then begin
      FEQ:= False;
    end
    else begin
      FEQ:= True;
    end;

    if cbAccount.CurrentKeyInt > 0 then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQL.SQL.Text := 'select multycurr, offbalance from ac_account where id = :id';
        SQL.ParamByName('id').AsInteger := cbAccount.CurrentKeyInt;
        SQL.ExecQuery;

        FMultyCurr := SQL.FieldByName('multycurr').AsInteger > 0;
        FOffBalance := SQL.FieldByName('offbalance').AsInteger > 0;
      finally
        SQL.Free;
      end;
    end else
    begin
      FMultyCurr := False;
      FOffBalance := False;
    end;

    lEQ.Visible:= FEQ;
    cEQSum.Visible:= FEQ;
    if FEQ then begin
      lCurr.Top:= lEQ.Top + cEQHeight;
      cbCurrency.Top:= cEQSum.Top + cEQHeight;
    end
    else begin
      lCurr.Top:= lEQ.Top;
      cbCurrency.Top:= cEQSum.Top;
    end;
    lRate.Top:= lCurr.Top + cEQHeight;
    cRate.Top:= cbCurrency.Top + cEQHeight;
    lSumCurr.Top:= lRate.Top + cEQHeight;
    cCurrSum.Top:= cRate.Top + cEQHeight;
    lCurr.Enabled := FMultyCurr;                   
    cbCurrency.Enabled := FMultyCurr;
    lRate.Enabled := FMultyCurr;
    cRate.Enabled := FMultyCurr;
    lSumCurr.Enabled := FMultyCurr;
    cCurrSum.Enabled := FMultyCurr;
    if not FMultyCurr then
    begin
      cbCurrency.CurrentKey := '';
      cRate.Value := 0;
      cCurrSum.Value := 0;
    end
    else
    begin
      ComponentPath := BuildComponentPath(Self);
      cbRounded.Checked := CompanyStorage.ReadBoolean(ComponentPath, 'Rounded', True);
    end;
    Panel5.Height := HeightArray[FMultyCurr][FEQ];

    frAcctAnalytics.Visible := frAcctAnalytics.AnalyticsCount > 0;
    if frAcctAnalytics.Visible then
      frAcctAnalytics.FrameResize(frAcctAnalytics);
    frAcctAnalytics.Top := Panel5.Top + Panel5.Height;
    frQuantity.Visible := frQuantity.QuantityCount > 0;
    frQuantity.Top := fracctAnalytics.Top + fracctAnalytics.Height;
    ppMain.ClientHeight := frAcctAnalytics.Top + frAcctAnalytics.Height;
    Panel1.ClientHeight := ppMain.Height;
    ClientHeight := Panel1.Height;
  end;

end;

procedure TfrAcctEntrySimpleLine.cRateChange(Sender: TObject);
begin
  if ControlEnabled then
  begin
    CalcCurrency(False);
    DoChange(Sender);
  end;
end;

procedure TfrAcctEntrySimpleLine.cSumChange(Sender: TObject);
begin
  if ControlEnabled then
  begin
    CalcCurrency(False);
    DoChange(Sender);
  end;
end;

procedure TfrAcctEntrySimpleLine.cCurrSumChange(Sender: TObject);
begin
  if ControlEnabled then
  begin
    CalcCurrency(True);
    DoChange(cSum);    
    DoChange(Sender);
  end;
end;

constructor TfrAcctEntrySimpleLine.Create(AOwner: TComponent);
begin
  inherited;

  Transaction.DefaultDatabase := dmDatabase.ibdbGAdmin;

  Panel5.Height := cMinHeight;
  frAcctAnalytics.Visible := False;
  frQuantity.Visible := False;
  ppMain.ClientHeight := Panel5.Height;
  Panel1.ClientHeight := ppMain.Height;
  ClientHeight := Panel1.Height;
end;

procedure TfrAcctEntrySimpleLine.SetDataSet(const Value: TDataSet);
begin
  DisableControls;
  try
    FDataSet := Value;
    DataSource.DataSet := DataSet;
    if Value <> nil then
    begin
      Value.FreeNotification(Self);
      AccountPart := Value.FieldByName('accountpart').AsString;
    end;
    if cCurrSum.Value > 0 then
      cRate.Value := cSum.Value / cCurrSum.Value;

  finally
    EnableControls;
  end;
end;

function TfrAcctEntrySimpleLine.GetId: Integer;
begin
  Result := -1;
  if FDataSet <> nil then
  begin
    Result := FDataSet.FieldByName('id').AsInteger;
  end;
end;

procedure TfrAcctEntrySimpleLine.WMPaint(var Message: TWMPaint);
begin
  inherited;

end;

procedure TfrAcctEntrySimpleLine.CMFocusChanged(
  var Message: TCMFocusChanged);
var
  I: Integer;
  B: Boolean;
  L: TList;
begin
  inherited;

  B := FFocused;
  L := TList.Create;
  try
    GetTabOrderList(L);
    for I := 0 to L.Count - 1 do
    begin
      FFocused := (TObject(L.Items[I]) is TWinControl) and
        (Message.Sender = L.Items[I]);
      if FFocused then break;
    end;
  finally
    L.Free;
  end;

  if B <> FFocused then
  begin
    if FFocused then
      Panel1.Color := clRed
    else
      Panel1.Color := $00E9E9E9;
  end;
end;

procedure TfrAcctEntrySimpleLine.LoadAnalytic;
var
  I: Integer;
  R: TatRelation;
  atF: TatRelationField;
  F: TField;
  S: TStrings;
begin
  if FDataSet <> nil then
  begin
    frAcctAnalytics.OnValueChange := nil;
    frQuantity.OnValueChange := nil;

    UpdateCaption;
    UpdateControls;

    S := TStringList.Create;
    try
      R := atDatabase.Relations.ByRelationName('ac_entry');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        atF := R.RelationFields[I];
        if atF.IsUserDefined then
        begin
          F := FDataSet.FindField(atF.FieldName);
          if (F <> nil) and not F.IsNull then
          begin
            S.Add(F.FieldName + '=' + F.AsString);
          end;
        end;
      end;
      frAcctAnalytics.Values := S.Text;
    finally
      S.Free;
    end;

    if FDataSet is TgdcAcctEntryLine then
    begin
      S := TStringList.Create;
      try
        with FDataSet as TgdcAcctEntryLine do
        begin
          //gdcQuantity.Cancel;
          gdcQuantity.First;
          while not gdcQuantity.Eof do
          begin
            S.Add(gdcQuantity.FieldByName('valuekey').AsString + '=' +
              gdcQuantity.FieldByName('quantity').AsString);
            gdcQuantity.Next;
          end;

          frQuantity.Values := S.Text;
        end;
      finally
        S.Free;
      end;;
    end;

    frQuantity.OnValueChange := OnValueChange;
    frAcctAnalytics.OnValueChange := OnValueChange;
  end;
end;

procedure TfrAcctEntrySimpleLine.SaveAnalytic;
var
  I, iYear, iMonth, iDay: Integer;
  R: TatRelation;
  atF: TatRelationField;
  F: TField;
  S: TStrings;
  V, sTmp: string;
begin
  if FDataSet <> nil then
  begin
    if FDataSet.FieldByName('accountkey').AsInteger = 0 then Exit;
    CheckEditMode;
    S := TStringList.Create;
    try
      S.Text := frAcctAnalytics.Values;
      R := atDatabase.Relations.ByRelationName('ac_entry');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        atF := R.RelationFields[I];
        if atF.IsUserDefined then
        begin
          F := FDataSet.FindField(atF.FieldName);
          if (F <> nil) then
          begin
            F.Clear;
            if S.IndexOfName(F.FieldName) > - 1 then
            begin
              V := S.Values[F.FieldName];
              if F.DataType in [ftDateTime, ftDate, ftTime, ftWord, ftSmallint, ftInteger, ftLargeint, ftFloat, ftString, ftBCD] then begin
                if V[1] = '''' then
                  V:= Copy(V, 2, Length(V) - 2);
                if F.DataType in [ftDateTime, ftDate] then begin
                  iYear:= StrToInt(Copy(V, 1, 4));
                  iMonth:= StrToInt(Copy(V, 6, 2));
                  iDay:= StrToInt(Copy(V, 9, 2));
                  sTmp:= '';
                  if F.DataType = ftDateTime then
                    STmp:= Copy(V, 11, Length(V) - 10);
                  V:= DateToStr(EncodeDate(iYear, iMonth, iDay)) + STmp;
                end;
              end;
              F.AsString:= V;
            end;
          end;
        end;
      end;
    finally
      S.Free;
    end;

    if FDataSet is TgdcAcctEntryLine then
    begin
      with FDataSet as TgdcAcctEntryLine do
      begin
        gdcQuantity.Cancel;
        gdcQuantity.First;
        while not gdcQuantity.Eof do
          gdcQuantity.Delete;

        S := TStringList.Create;
        try
          S.Text := frQuantity.Values;
          for I := 0 to S.Count - 1 do
          begin
            gdcQuantity.Insert;
            gdcQuantity.FieldByName('valuekey').AsString := S.Names[I];
            gdcQuantity.FieldByName('quantity').AsString := S.Values[S.Names[I]];
            gdcQuantity.Post;
          end;
        finally
          S.Free;
        end;
     end;
    end;
  end;
end;

procedure TfrAcctEntrySimpleLine.OnValueChange(Sender: TObject);
begin
  if FDataSet <> nil then
  begin
    if not (FDataSet.State in [dsEdit, dsInsert]) then
      FDataSet.Edit;

    FDataSet.FieldByName('id').Value := FDataSet.FieldByName('id').Value
  end;
  DoChange(Sender);
end;

procedure TfrAcctEntrySimpleLine.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TfrAcctEntrySimpleLine.DoChange(Sender: TObject);
begin
  if Assigned(OnChange) then
    OnChange(Sender);
end;

procedure TfrAcctEntrySimpleLine.cbCurrencyChange(Sender: TObject);
begin
  if ControlEnabled then
  begin
    cRate.Value := CurrRate(cbCurrency.CurrentKeyInt);
    DoChange(Sender);
  end;  
end;

procedure TfrAcctEntrySimpleLine.SetOffBalance(const Value: Boolean);
begin
  FOffBalance := Value;
end;

procedure TfrAcctEntrySimpleLine.SetMultyCurr(const Value: Boolean);
begin
  FMultyCurr := Value;
end;

function TfrAcctEntrySimpleLine.CurrRate(CurrKey: Integer): Currency;
var
  ibsql: TIBSQL;
  NCUCurrKey: Integer;
begin
  Result := 0;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT isncu FROM gd_curr where id = :id';
    ibsql.ParamByName('id').AsInteger := CurrKey;
    ibsql.ExecQuery;
    if ibsql.FieldByName('isncu').AsInteger = 0 then
    begin
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT id FROM gd_curr where isncu = 1';
      ibsql.ExecQuery;
      NCUCurrKey := ibsql.FieldByName('id').AsInteger;
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT coeff FROM gd_currrate WHERE fromcurr = :fc and ' +
        ' tocurr = :tc and fordate = (SELECT MAX(fordate) FROM gd_currrate WHERE fromcurr = :fc and ' +
        ' tocurr = :tc and fordate <= :de) ';
      ibsql.ParamByName('fc').AsInteger := CurrKey;
      ibsql.ParamByName('tc').AsInteger := NCUCurrKey;
      ibsql.ParamByName('de').AsDateTime := gdcObject.FieldByName('recorddate').AsDateTime;
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
        Result := ibsql.FieldByName('coeff').AsCurrency;
      ibsql.Close
    end;
  finally
    ibsql.Free;
  end;
end;

procedure TfrAcctEntrySimpleLine.DisableControls;
begin
  Inc(FDisableCount)
end;

procedure TfrAcctEntrySimpleLine.EnableControls;
begin
  if FDisableCount > 0 then
    Dec(FDisableCount);
end;

function TfrAcctEntrySimpleLine.ControlEnabled: Boolean;
begin
  Result := FDisableCount = 0;
end;

procedure TfrAcctEntrySimpleLine.CalcCurrency(isCurrency: Boolean);
begin
  if FDataSet <> nil then
  begin
    DisableControls;
    try
      if (cRate.value > 0) and not IsCurrency then
      begin
        CheckEditMode;
        FdataSet.FieldByName(cCurrSum.DataField).AsCurrency := cSum.Value / cRate.Value;
      end else
      if (cRate.Value > 0) then
      begin
        CheckEditMode;

        if not cbRounded.Checked then
          FdataSet.FieldByName(cSum.DataField).AsCurrency := cCurrSum.Value * cRate.Value
        else
          FdataSet.FieldByName(cSum.DataField).AsCurrency := Round(cCurrSum.Value * cRate.Value + 1/10000);

      end;
    finally
      EnableControls;
    end;
  end
end;

procedure TfrAcctEntrySimpleLine.SetgdcObject(const Value: TgdcBase);
begin
  FgdcObject := Value;
end;

procedure TfrAcctEntrySimpleLine.CheckEditMode;
begin
  if FdataSet <> nil then
  begin
    if not (FDataSet.State in [dsInsert, dsEdit]) then
    begin
      FDataSet.Edit;
    end;
  end;
end;

procedure TfrAcctEntrySimpleLine.FrameResize(Sender: TObject);
begin
  Panel1.Width := ClientWidth;
end;

procedure TfrAcctEntrySimpleLine.Panel1Resize(Sender: TObject);
begin
  ppMain.Width := Panel1.ClientWidth;
end;

procedure TfrAcctEntrySimpleLine.ppMainResize(Sender: TObject);
begin
  Panel5.Width := ppMain.ClientWidth;
  frAcctAnalytics.Width := ppMain.ClientWidth;
  frQuantity.Width := ppMain.ClientWidth;
end;

procedure TfrAcctEntrySimpleLine.cbAccountExit(Sender: TObject);
begin
  UpdateCaption;
  UpdateControls;
end;

destructor TfrAcctEntrySimpleLine.Destroy;
begin
  try
    if CompanyStorage <> nil then
      CompanyStorage.WriteBoolean(BuildComponentPath(Self), 'Rounded', cbRounded.Checked);
  except
    on E: Exception do
      Application.ShowException(E);
  end;

  inherited;
end;

procedure TfrAcctEntrySimpleLine.SetCurrRate(CurrKey: Integer;
  Rate: Currency);
begin
  if cbCurrency.Visible and (cbCurrency.CurrentKeyInt = CurrKey) and (zRate <> Rate) then
    cRate.Value := Rate;
end;

function TfrAcctEntrySimpleLine.GetCRate: Currency;
begin
  Result := cRate.Value;
end;

end.
