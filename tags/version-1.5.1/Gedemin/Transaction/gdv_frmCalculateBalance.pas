unit gdv_frmCalculateBalance;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Mask, xDateEdits, gd_createable_form, gd_ClassList,
  ComCtrls, IBDatabase;

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
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure SetProcessText(AText: String);
  end;

var
  frmCalculateBalance: TfrmCalculateBalance;

implementation

uses
  IBSQL, AcctUtils, at_classes, gdcBaseInterface, gdClosingPeriod;

{$R *.DFM}

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
  lblProgress.Caption := '';
  lblTime.Caption := '';
end;

procedure TfrmCalculateBalance.btnCalculateClick(Sender: TObject);
var
  StartTime: TDateTime;
  gdClosingPeriodObject: TgdClosingPeriod;
  WriteTransaction: TIBTransaction;
begin
  if Assigned(atDatabase.Relations.ByRelationName('AC_ENTRY_BALANCE'))
     and (xdeCurrentDate.Date > 0) then
  begin
    btnCalculate.Enabled := False;
    btnClose.Enabled := False;
    StartTime := Time;
    lblTime.Caption := '������ ����� � ' + TimeToStr(StartTime);

    WriteTransaction := TIBTransaction.Create(nil);
    try
      WriteTransaction.DefaultDatabase := gdcBaseManager.Database;
      WriteTransaction.StartTransaction;

      gdClosingPeriodObject := TgdClosingPeriod.Create(WriteTransaction);
      try
        try
          gdClosingPeriodObject.ProgressBar := Self.pbMain;
          gdClosingPeriodObject.ProgressBarLabel := Self.lblProgress;

          gdClosingPeriodObject.CloseDate := xdeCurrentDate.Date;
          gdClosingPeriodObject.CalculateEntryBalance;
          // ���������� ����������
          if WriteTransaction.InTransaction then
            WriteTransaction.Commit;
        except
          on E: Exception do
          begin
            // ������� ����������
            if WriteTransaction.InTransaction then
              WriteTransaction.Rollback;
            Self.SetProcessText('��������� ������! ������ �������. (' + E.Message + ')');
            btnCalculate.Enabled := True;
            btnClose.Enabled := True;
          end;
        end;
      finally
        gdClosingPeriodObject.Free;
      end;
    finally
      WriteTransaction.Free;
    end;

    lblTime.Caption := '������ ����� � ' + TimeToStr(StartTime) +
      ', ����������� ' + TimeToStr(Time - StartTime);
    btnCalculate.Enabled := True;
    btnClose.Enabled := True;
  end;
end;

procedure TfrmCalculateBalance.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmCalculateBalance.SetProcessText(AText: String);
begin
  lblProgress.Caption := AText;
  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

initialization
  RegisterClass(TfrmCalculateBalance);
finalization
  UnRegisterClass(TfrmCalculateBalance);

end.
