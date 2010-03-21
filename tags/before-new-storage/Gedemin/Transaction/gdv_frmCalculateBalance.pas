unit gdv_frmCalculateBalance;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Mask, xDateEdits, gd_createable_form, gd_ClassList,
  ComCtrls, IBDatabase, gdClosingPeriod;

type
  TfrmCalculateBalance = class(TCreateableForm)
    pnlMain: TPanel;
    gbMain: TGroupBox;
    lblCurrentDate: TLabel;
    xdeCurrentDate: TxDateEdit;
    btnClose: TButton;
    lblPreviousDate: TLabel;
    xdePreviousDate: TxDateEdit;
    pbMain: TProgressBar;
    btnCalculate: TButton;
    lblProgress: TLabel;
    lblTime: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnCalculateClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FStartTime: TDateTime;

    FClosingPeriodObject: TgdClosingPeriod;
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure SetProcessText(AText: String);

    property StartTime: TDateTime read FStartTime write FStartTime;
  end;

var
  frmCalculateBalance: TfrmCalculateBalance;

implementation

uses
  IBSQL, AcctUtils, at_classes, gdcBaseInterface;

{$R *.DFM}

var
  InnerFormVariable: TfrmCalculateBalance;

procedure DoBeforeClosingProcess;
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.btnCalculate.Enabled := False;
    InnerFormVariable.btnClose.Enabled := False;
    InnerFormVariable.StartTime := Time;
    InnerFormVariable.lblTime.Caption := 'Расчет начат в ' + TimeToStr(InnerFormVariable.StartTime);
  end;
end;

procedure DoAfterClosingProcess;
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.lblTime.Caption := 'Расчет начат в ' + TimeToStr(InnerFormVariable.StartTime) +
      ', продолжался ' + TimeToStr(Time - InnerFormVariable.StartTime);
    InnerFormVariable.btnCalculate.Enabled := True;
    InnerFormVariable.btnClose.Enabled := True;
  end;
end;

procedure DoOnClosingProcessInterruption(const AErrorMessage: String);
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.SetProcessText(TimeToStr(Time) + ': Критическая ошибка:'#13#10 + AErrorMessage + #13#10'Процесс закрытия прерван!');
  end;
end;

procedure DoOnProcessMessage(const APosition, AMaxPosition: Integer; const AMessage: String);
begin
  if Assigned(InnerFormVariable) then
  begin
    if (APosition >= 0) and (InnerFormVariable.pbMain.Position <> APosition) then
      InnerFormVariable.pbMain.Position := APosition;
    if (AMaxPosition >= 0) and (InnerFormVariable.pbMain.Max <> AMaxPosition) then
      InnerFormVariable.pbMain.Max := AMaxPosition;

    // Если текущий прогресс превысил максималный, увеличим максимальный
    if APosition > InnerFormVariable.pbMain.Max then
      InnerFormVariable.pbMain.Max := InnerFormVariable.pbMain.Max * 2;

    // лейбл под прогресс баром  
    InnerFormVariable.lblProgress.Caption :=
      IntToStr(InnerFormVariable.pbMain.Position) + ' / ' + IntToStr(InnerFormVariable.pbMain.Max);
      
    if AMessage <> '' then
      InnerFormVariable.SetProcessText(TimeToStr(Time) + ': ' + AMessage);
  end;
end;

{ TfrmCalculateBalance }

class function TfrmCalculateBalance.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmCalculateBalance) then
    frmCalculateBalance := TfrmCalculateBalance.Create(AnOwner);
  Result := frmCalculateBalance;
end;

procedure TfrmCalculateBalance.FormShow(Sender: TObject);
var
  PreviousBalanceDate: TDate;
  Year, Month, Day: Word;
begin
  PreviousBalanceDate := GetCalculatedBalanceDate;
  // Если сальдо уже рассчитывалось, то текущий расчет будем производить на месяц позже
  if PreviousBalanceDate > 0 then
  begin
    xdePreviousDate.Date := PreviousBalanceDate;
    xdeCurrentDate.Date := IncMonth(PreviousBalanceDate, 1);
  end
  else
  begin
    // ...иначе на начало текущего месяца
    DecodeDate(Date, Year, Month, Day);
    xdePreviousDate.Clear;
    xdeCurrentDate.Date := EncodeDate(Year, Month, 1);
  end;

  pbMain.Position := 0;
  lblProgress.Caption := '';
  lblTime.Caption := '';
end;

procedure TfrmCalculateBalance.btnCalculateClick(Sender: TObject);
begin
  if Assigned(atDatabase.Relations.ByRelationName('AC_ENTRY_BALANCE'))
     and (xdeCurrentDate.Date > 0) then
  begin
    FClosingPeriodObject.CloseDate := xdeCurrentDate.Date;
    FClosingPeriodObject.DoCalculateEntryBalance := True;

    FClosingPeriodObject.DoClosePeriod;
  end;
end;

procedure TfrmCalculateBalance.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmCalculateBalance.SetProcessText(AText: String);
begin
  lblProgress.Caption := AText;
end;

procedure TfrmCalculateBalance.FormCreate(Sender: TObject);
begin
  InnerFormVariable := Self;

  FClosingPeriodObject := TgdClosingPeriod.Create;
  FClosingPeriodObject.OnBeforeProcessRoutine := DoBeforeClosingProcess;
  FClosingPeriodObject.OnAfterProcessRoutine := DoAfterClosingProcess;
  FClosingPeriodObject.OnProcessInterruptionRoutine := DoOnClosingProcessInterruption;
  FClosingPeriodObject.OnProcessMessageRoutine := DoOnProcessMessage;
end;

procedure TfrmCalculateBalance.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FClosingPeriodObject);

  InnerFormVariable := nil;
end;

initialization
  RegisterClass(TfrmCalculateBalance);
finalization
  UnRegisterClass(TfrmCalculateBalance);

end.
