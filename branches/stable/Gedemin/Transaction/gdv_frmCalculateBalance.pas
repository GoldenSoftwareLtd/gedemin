unit gdv_frmCalculateBalance;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Mask, xDateEdits, gd_createable_form, gd_ClassList,
  ComCtrls, IBDatabase, gdClosingPeriod, ActnList, TB2Item, TB2Dock,
  TB2Toolbar, dmImages_unit;

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
    lblPreviousDontBalanceAnalytic: TLabel;
    ePreviousDontBalanceAnalytic: TEdit;
    lblDontBalanceAnalytic: TLabel;
    eDontBalanceAnalytic: TEdit;
    alMain: TActionList;
    actClose: TAction;
    actCalculate: TAction;
    actTestAnalyticList: TAction;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCalculateExecute(Sender: TObject);
    procedure actTestAnalyticListExecute(Sender: TObject);
    procedure actTestAnalyticListUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FClosingPeriodObject: TgdClosingPeriod;

    function ValidateFieldString(const AFieldList: String): String;
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure SetProcessText(AText: String);
    procedure EnableControls(const AIsEnable: Boolean);
  end;

var
  frmCalculateBalance: TfrmCalculateBalance;

implementation

uses
  IBSQL,                AcctUtils,              AcctStrings,
  at_classes,           gdcBaseInterface,       gd_KeyAssoc,
  gdcMetaData;

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
      ': Критическая ошибка:'#13#10 + AErrorMessage + #13#10'Процесс закрытия прерван!');
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
  // Выбранные аналитики по которым не велся учет сальдо
  ePreviousDontBalanceAnalytic.Text := GetDontBalanceAnalyticList;
  eDontBalanceAnalytic.Text := ePreviousDontBalanceAnalytic.Text;

  pbMain.Position := 0;
  mProgress.Clear;
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

procedure TfrmCalculateBalance.actCloseExecute(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmCalculateBalance.actCalculateExecute(Sender: TObject);
begin
  if Assigned(atDatabase.Relations.ByRelationName('AC_ENTRY_BALANCE'))
     and (xdeCurrentDate.Date > 0) then
  begin
    // Установим параметры закрытия
    FClosingPeriodObject.CloseDate := xdeCurrentDate.Date;
    // Приведем список аналитик в необходимый формат
    FClosingPeriodObject.DontBalanceAnalytic := ValidateFieldString(eDontBalanceAnalytic.Text);;
    FClosingPeriodObject.DoCalculateEntryBalance := True;
    // Запустим бух. закрытие
    FClosingPeriodObject.DoClosePeriod;
  end;
end;

function TfrmCalculateBalance.ValidateFieldString(const AFieldList: String): String;
var
  ibsqlFields: TIBSQL;
  UpperFieldList: String;
begin
  Result := '';
  UpperFieldList := AnsiUpperCase(AFieldList);

  ibsqlFields := TIBSQL.Create(Self);
  try
    ibsqlFields.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlFields.SQL.Text :=
      'SELECT ' +
      '  r.fieldname AS fieldname ' +
      'FROM ' +
      '  at_relation_fields r ' +
      'WHERE ' +
      '  r.relationname = ''AC_ENTRY'' ' +
      '  AND r.fieldname STARTING WITH ''USR$'' ';
    ibsqlFields.ExecQuery;

    // Пройдем по вытянутым полям и будем искать их в переданной строке
    //  Сформируем строку типа ;FIELD1;FIELD2;FIELD3;
    while not ibsqlFields.Eof do
    begin
      if AnsiPos(ibsqlFields.FieldByName('FIELDNAME').AsString, UpperFieldList) > 0 then
        Result := Result + Trim(ibsqlFields.FieldByName('FIELDNAME').AsString) + ';';
      ibsqlFields.Next;
    end;

    if Result <> '' then
      Result := ';' + Result;
  finally
    FreeAndNil(ibsqlFields);
  end;
end;

procedure TfrmCalculateBalance.actTestAnalyticListExecute(Sender: TObject);
begin
  eDontBalanceAnalytic.Text := ValidateFieldString(eDontBalanceAnalytic.Text);
end;

procedure TfrmCalculateBalance.actTestAnalyticListUpdate(Sender: TObject);
begin
  actTestAnalyticList.Enabled := (eDontBalanceAnalytic.Text <> '');
end;

procedure TfrmCalculateBalance.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if FClosingPeriodObject.ProcessState = psWorking then
  begin
    CanClose := False;
    Application.MessageBox('Дождитесь окончания процесса.', 'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_APPLMODAL);
  end;
end;

initialization
  RegisterClass(TfrmCalculateBalance);
finalization
  UnRegisterClass(TfrmCalculateBalance);

end.
