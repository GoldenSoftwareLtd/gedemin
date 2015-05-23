unit tr_dlgEditEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, tr_type_unit, ActnList, gsIBLookupComboBox, IBDatabase;

type
  TdlgEditEntry = class(TForm)
    sgrEntry: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    sbAnalyze: TScrollBox;
    Label1: TLabel;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actNext: TAction;
    Button4: TButton;
    actPrev: TAction;
    Button5: TButton;
    actNewLine: TAction;
    actDelete: TAction;
    Button6: TButton;
    IBTransaction: TIBTransaction;
    procedure actNextUpdate(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure sgrEntrySelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actNewLineExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FPositionTransaction: TPositionTransaction;
    FCurrentEntry: Integer;
    FOldRow: Integer;

    procedure SetCurrentEntry;
    procedure SetAnalyzeControl;
    function SaveEntry: Boolean;
    procedure ChangeAnalyze(Sender: TObject);
  public
    { Public declarations }
    procedure SetupDialog(aPositionTransaction: TPositionTransaction);
    property PositionTransaction: TPositionTransaction read FPositionTransaction;
  end;

var
  dlgEditEntry: TdlgEditEntry;

implementation

{$R *.DFM}

uses
  at_classes
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ TdlgEditEntry }

procedure TdlgEditEntry.SetCurrentEntry;
var
  i, Num: Integer;
begin
  if not FPositionTransaction.RealEntry[FCurrentEntry].IsCurrencyEntry then
    sgrEntry.ColCount := 3
  else
    sgrEntry.ColCount := 5;

  sgrEntry.RowCount := FPositionTransaction.RealEntry[FCurrentEntry].DebitCount +
    FPositionTransaction.RealEntry[FCurrentEntry].CreditCount + 1;

  for i:= 0 to FPositionTransaction.RealEntry[FCurrentEntry].DebitCount - 1 do
  begin
    sgrEntry.Cells[0, i + 1] := FPositionTransaction.RealEntry[FCurrentEntry].Debit[i].Alias;
    sgrEntry.Cells[1, i + 1] :=
      FloatToStr(TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Debit[i]).SumNCU);
      
    if FPositionTransaction.RealEntry[FCurrentEntry].IsCurrencyEntry then
      sgrEntry.Cells[3, i + 1] :=
        FloatToStr(TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Debit[i]).SumCurr);
    sgrEntry.Cells[2, i + 1] := '';
    if FPositionTransaction.RealEntry[FCurrentEntry].IsCurrencyEntry then
      sgrEntry.Cells[4, i + 1] := '';
  end;

  Num := FPositionTransaction.RealEntry[FCurrentEntry].DebitCount + 1;

  for i:= 0 to FPositionTransaction.RealEntry[FCurrentEntry].CreditCount - 1 do
  begin
    sgrEntry.Cells[0, i + Num] := FPositionTransaction.RealEntry[FCurrentEntry].Credit[i].Alias;
    sgrEntry.Cells[1, i + Num] := '';
    if FPositionTransaction.RealEntry[FCurrentEntry].IsCurrencyEntry then
      sgrEntry.Cells[3, i + Num] := '';
    sgrEntry.Cells[2, i + Num] :=
      FloatToStr(TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Credit[i]).SumNCU);
    if FPositionTransaction.RealEntry[FCurrentEntry].IsCurrencyEntry then
      sgrEntry.Cells[4, i + Num] :=
        FloatToStr(TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Credit[i]).SumCurr);
  end;

  sgrEntry.Col := 1;
  sgrEntry.Row := 1;
  FOldRow := -1;  

  SetAnalyzeControl;

end;

procedure TdlgEditEntry.SetupDialog(
  aPositionTransaction: TPositionTransaction);
begin
  FPositionTransaction := TPositionTransaction.Create;
  FPositionTransaction.Assign(aPositionTransaction);


  FCurrentEntry := 0;
  Assert((FCurrentEntry < FPositionTransaction.RealEntryCount), 'Нет проводок для редактирования');

  sgrEntry.Cells[0, 0] := 'Счет';
  sgrEntry.Cells[1, 0] := 'Дебет НДЕ';
  sgrEntry.Cells[2, 0] := 'Кредит НДЕ';  
  sgrEntry.Cells[3, 0] := 'Дебет вал.';
  sgrEntry.Cells[4, 0] := 'Кредит вал.';

  SetCurrentEntry;
end;

procedure TdlgEditEntry.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := FCurrentEntry < FPositionTransaction.RealEntryCount - 1;
end;

procedure TdlgEditEntry.actPrevExecute(Sender: TObject);
begin
  if SaveEntry then
  begin
    Dec(FCurrentEntry);
    SetCurrentEntry;
  end;
end;

procedure TdlgEditEntry.actNextExecute(Sender: TObject);
begin
  if SaveEntry then
  begin
    Inc(FCurrentEntry);
    SetCurrentEntry;
  end;  
end;

procedure TdlgEditEntry.actPrevUpdate(Sender: TObject);
begin
  actPrev.Enabled := FCurrentEntry > 0;
end;

function TdlgEditEntry.SaveEntry: Boolean;
var
  i, Num: Integer;
begin
  try
    for i:= 0 to FPositionTransaction.RealEntry[FCurrentEntry].DebitCount - 1 do
    begin
      if sgrEntry.Cells[1, i + 1] > '' then
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Debit[i]).SumNCU :=
           StrToFloat(sgrEntry.Cells[1, i + 1])
      else
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Debit[i]).SumNCU := 0;

      if sgrEntry.Cells[3, i + 1] > '' then
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Debit[i]).SumCurr :=
           StrToFloat(sgrEntry.Cells[3, i + 1])
      else
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Debit[i]).SumCurr := 0;
    end;

    Num := FPositionTransaction.RealEntry[FCurrentEntry].DebitCount + 1;

    for i:= 0 to FPositionTransaction.RealEntry[FCurrentEntry].CreditCount - 1 do
    begin
      if sgrEntry.Cells[2, i + Num] > '' then
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Credit[i]).SumNCU :=
           StrToFloat(sgrEntry.Cells[2, i + Num])
      else
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Credit[i]).SumNCU := 0;

      if sgrEntry.Cells[4, i + Num] > '' then
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Credit[i]).SumCurr :=
           StrToFloat(sgrEntry.Cells[4, i + Num])
      else
        TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Credit[i]).SumCurr := 0;
    end;

    Result := FPositionTransaction.RealEntry[FCurrentEntry].CheckBalans;
    
    if not Result then
      MessageBox(HANDLE, 'По проводке не идет баланс!', 'Внимание', mb_Ok or mb_IconInformation);
      
  except
    Result := False;
  end;
end;

procedure TdlgEditEntry.SetAnalyzeControl;
var
  Num: Integer;

procedure SetControl(aAccount: TAccount);
var
  i: Integer;
  lab: TLabel;
  gsiblc: TgsIBLookupComboBox;
  H: Integer;
  R: TatRelation;
begin
  for i:= 0 to sbAnalyze.ControlCount - 1 do
    sbAnalyze.Controls[0].Free;

  H := 2;  
  for i:= 0 to aAccount.CountAnalyze - 1 do
  begin
    R := atDatabase.Relations.ByRelationName(TAnalyze(aAccount.AnalyzeItem[i]).ReferencyName);
    if Assigned(R) then
    begin
      lab := TLabel.Create(Owner);
      lab.Name := Format('USRLabel%d', [i]);
      sbAnalyze.InsertControl(lab);
      lab.Left := 5;
      lab.Top := H + 4;
      lab.Caption := R.LName;

      gsiblc := TgsIBLookupComboBox.Create(Owner);
      gsiblc.Name := Format('USRgsIBLookupComboBox_%d', [i]);
      gsiblc.Text := '';
      gsiblc.Transaction := IBTransaction;
      sbAnalyze.InsertControl(gsiblc);

      gsiblc.OnChange := ChangeAnalyze;

      gsiblc.Left := 10 + lab.Canvas.TextWidth(lab.Caption);
      gsiblc.Top := H;
      gsiblc.Width := sbAnalyze.Width - gsiblc.Left - 10;
      gsiblc.ListTable := R.RelationName;
      gsiblc.KeyField := R.PrimaryKey.ConstraintFields[0].FieldName;
      gsiblc.ListField := R.ListField.FieldName;

      if TAnalyze(aAccount.AnalyzeItem[i]).ValueAnalyze > 0 then
        gsiblc.CurrentKeyInt := TAnalyze(aAccount.AnalyzeItem[i]).ValueAnalyze;

      H := H + gsiblc.Height + 5;
    end;
  end;
end;

begin
  if FOldRow > 0 then
    Num := FOldRow
  else
    Num := sgrEntry.Row;

  if Num > FPositionTransaction.RealEntry[FCurrentEntry].DebitCount then
  begin
    Num := Num - FPositionTransaction.RealEntry[FCurrentEntry].DebitCount - 1;
    SetControl(FPositionTransaction.RealEntry[FCurrentEntry].Credit[Num]);
  end
  else
  begin
    Num := Num - 1;
    SetControl(FPositionTransaction.RealEntry[FCurrentEntry].Debit[Num]);
  end;  
end;

procedure TdlgEditEntry.ChangeAnalyze(Sender: TObject);
var
  Nom, Nom1: Integer;
  S: String;
  Account: TAccount;
begin
  S := (Sender as TComponent).Name;
  Nom := StrToInt(copy(S, Pos('_', S) + 1, 255));

  if FOldRow > 0 then
    Nom1 := FOldRow
  else
    Nom1 := sgrEntry.Row;  
  if Nom1 > FPositionTransaction.RealEntry[FCurrentEntry].DebitCount then
  begin
    Nom1 := Nom1 - FPositionTransaction.RealEntry[FCurrentEntry].DebitCount - 1;
    Account := FPositionTransaction.RealEntry[FCurrentEntry].Credit[Nom1];
  end
  else
  begin
    Nom1 := Nom1 - 1;
    Account := FPositionTransaction.RealEntry[FCurrentEntry].Debit[Nom1];
  end;

  if Nom < Account.CountAnalyze then
  begin
    if (Sender as TgsIBLookupComboBox).CurrentKey > '' then
      Account.AnalyzeItem[Nom].ValueAnalyze :=
         (Sender as TgsIBLookupComboBox).CurrentKeyInt
    else
      Account.AnalyzeItem[Nom].ValueAnalyze := -1;
  end;

end;

procedure TdlgEditEntry.sgrEntrySelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if aRow <> FOldRow then
  begin
    FOldRow := aRow;
    SetAnalyzeControl;
  end;
end;

procedure TdlgEditEntry.actOkExecute(Sender: TObject);
begin
  if SaveEntry then
    ModalResult := mrOk;
end;

procedure TdlgEditEntry.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgEditEntry.actNewLineExecute(Sender: TObject);
var
  isCredit: Boolean;
  Account: TRealAccount;
  Row: Integer;
  i, j: Integer;
begin
  Row := sgrEntry.Row;
  if Row > FPositionTransaction.RealEntry[FCurrentEntry].DebitCount then
  begin
    Row := Row - FPositionTransaction.RealEntry[FCurrentEntry].DebitCount - 1;
    Account := TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Credit[Row]);
    isCredit := True;
  end
  else
  begin
    isCredit := False;
    Row := Row - 1;
    Account := TRealAccount(FPositionTransaction.RealEntry[FCurrentEntry].Debit[Row]);
  end;

  if (not isCredit and (FPositionTransaction.RealEntry[FCurrentEntry].CreditCount = 1)) or
     (isCredit and (FPositionTransaction.RealEntry[FCurrentEntry].DebitCount = 1))
  then
  begin

    FPositionTransaction.RealEntry[FCurrentEntry].AddEntryLine(
        TRealAccount.Create(Account), not isCredit, '');
    sgrEntry.RowCount := sgrEntry.RowCount + 1;
    if not isCredit then
    begin
      for i:= sgrEntry.RowCount - 1 downto sgrEntry.Row + 1 do
        for j:= 0 to sgrEntry.ColCount - 1 do
          sgrEntry.Cells[j, i] := sgrEntry.Cells[j, i - 1];
      Row := sgrEntry.Row + 1;
    end
    else
      Row := sgrEntry.RowCount - 1;

    sgrEntry.Cells[0, Row] := Account.Alias;
    sgrEntry.Row := Row;

  end;  
end;

procedure TdlgEditEntry.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if IBTransaction.InTransaction then
    IBTransaction.Commit;
end;

end.
