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
    mProgress: TMemo;
    procedure FormShow(Sender: TObject);
    procedure btnCalculateClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FClosingPeriodObject: TgdClosingPeriod;
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure SetProcessText(AText: String);
    procedure EnableControls(const AIsEnable: Boolean);
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
    InnerFormVariable.EnableControls(False);
  end;
end;

procedure DoAfterClosingProcess;
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.EnableControls(True);
  end;
end;

procedure DoOnClosingProcessInterruption(const AErrorMessage: String);
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.SetProcessText(TimeToStr(Time) +
      ': ����������� ������:'#13#10 + AErrorMessage + #13#10'������� �������� �������!');
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

    // ���� ������� �������� �������� �����������, �������� ������������
    if APosition > InnerFormVariable.pbMain.Max then
      InnerFormVariable.pbMain.Max := InnerFormVariable.pbMain.Max * 2;
      
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
  // ���� ������ ��� ��������������, �� ������� ������ ����� ����������� �� ����� �����
  if PreviousBalanceDate > 0 then
  begin
    xdePreviousDate.Date := PreviousBalanceDate;
    xdeCurrentDate.Date := IncMonth(PreviousBalanceDate, 1);
  end
  else
  begin
    // ...����� �� ������ �������� ������
    DecodeDate(Date, Year, Month, Day);
    xdePreviousDate.Clear;
    xdeCurrentDate.Date := EncodeDate(Year, Month, 1);
  end;

  pbMain.Position := 0;
  mProgress.Clear;
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

procedure TfrmCalculateBalance.EnableControls(const AIsEnable: Boolean);
begin
  btnCalculate.Enabled := AIsEnable;
  btnClose.Enabled := AIsEnable;
  xdeCurrentDate.Enabled := AIsEnable;
end;

procedure TfrmCalculateBalance.SetProcessText(AText: String);
begin
  mProgress.Lines.Add(AText);
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
