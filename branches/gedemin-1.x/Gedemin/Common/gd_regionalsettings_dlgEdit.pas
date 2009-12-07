
unit gd_regionalsettings_dlgEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ActnList, gd_createable_form;

type
  TdlgRegionalSettings = class(TCreateableForm)
    pcRegion: TPageControl;
    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    tsCurrency: TTabSheet;
    tsDate: TTabSheet;
    tsTime: TTabSheet;
    tsNumber: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    cbDecimalSeparator: TComboBox;
    cbNumberDecimals: TComboBox;
    cbThousandSeparator: TComboBox;
    cbNumberGroupCount: TComboBox;
    cbNegativeChar: TComboBox;
    cbNegativeFormat: TComboBox;
    cbLeadingZero: TComboBox;
    cbListSeparator: TComboBox;
    GroupBox1: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    stNegNum: TStaticText;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    cbCurrencyString: TComboBox;
    cbCurrencyFormat: TComboBox;
    cbNegCurrFormat: TComboBox;
    cbCurrSeparator: TComboBox;
    cbCurrencyDecimals: TComboBox;
    cbCurrThousandSeparator: TComboBox;
    cbCurrGroup: TComboBox;
    GroupBox2: TGroupBox;
    Label19: TLabel;
    Label20: TLabel;
    stCurr: TStaticText;
    stNegCurr: TStaticText;
    Label18: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    cbShortTimeFormat: TComboBox;
    cbTimeSeparator: TComboBox;
    cbAMString: TComboBox;
    cbPMString: TComboBox;
    GroupBox3: TGroupBox;
    Label28: TLabel;
    stTime: TStaticText;
    GroupBox4: TGroupBox;
    Label26: TLabel;
    stDate: TStaticText;
    Label24: TLabel;
    Label25: TLabel;
    cbShortDateFormat: TComboBox;
    cbDateSeparator: TComboBox;
    GroupBox5: TGroupBox;
    Label27: TLabel;
    Label29: TLabel;
    stLongDate: TStaticText;
    cbLongDateFormat: TComboBox;
    stNum: TStaticText;
    alRegion: TActionList;
    chbUseSystemSettings: TCheckBox;
    aOK: TAction;
    aCancel: TAction;
    aApply: TAction;
    Button1: TButton;
    
    procedure FormCreate(Sender: TObject);
    procedure aApplyExecute(Sender: TObject);
    procedure aApplyUpdate(Sender: TObject);
    procedure cbDecimalSeparatorChange(Sender: TObject);
    procedure aOKExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
    procedure chbUseSystemSettingsClick(Sender: TObject);

  private
    ApplyActive: Boolean;
    function DoApply: Boolean;
    function TestCorrect: Boolean;
    procedure SetExample;
    procedure LoadRegionalSettings;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  dlgRegionalSettings: TdlgRegionalSettings;

const
  TestValue = 123456789.123456789;

implementation

{$R *.DFM}

uses
  dmDatabase_unit, gd_regionalsettings, registry, Storages, gd_ClassList,
  gsStorage
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

class function TdlgRegionalSettings.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlgRegionalSettings) then
    dlgRegionalSettings := TdlgRegionalSettings.Create(AnOwner);
  dlgRegionalSettings.LoadRegionalSettings;
  dlgRegionalSettings.ApplyActive := False;
  dlgRegionalSettings.SetExample;
  dlgRegionalSettings.pcRegion.ActivePageIndex := 0;
  Result := dlgRegionalSettings;
end;

function TdlgRegionalSettings.TestCorrect: Boolean;
  function Test(CB: TComboBox): Boolean;
  begin
    Result := Cb.Text > '';

    if not Result then
    begin
      SetFocusedControl(CB);
      MessageBox(Handle, PChar('В Строке "'+ cb.Hint +'" присутствует один или несколько недопустимых символов.'), 'Внимание!', MB_OK or MB_ICONEXCLAMATION);
    end;
  end;
begin
  Result := False;

  if not Test(cbThousandSeparator) then exit;

  if not Test(cbDecimalSeparator) then exit;
  if not Test(cbDateSeparator) then exit;
  if not Test(cbTimeSeparator) then exit;
  if not Test(cbListSeparator) then exit;
  if not Test(cbNegativeChar) then exit;
  if not Test(cbCurrSeparator) then exit;
  if not Test(cbCurrThousandSeparator) then exit;

  Result := True;
end;

//Загрузка региональных установок на форму
procedure TdlgRegionalSettings.LoadRegionalSettings;
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(st_rs_RegionalSettingsPath, True, True);
  with F do
  try
    if ReadBoolean(st_rs_UseSystemSettings) then
    begin
      //Если использовать системные загружаем системные
      cbCurrencyString.Text := CurrencyString;
      cbCurrencyFormat.ItemIndex := CurrencyFormat;
      cbNegCurrFormat.ItemIndex := NegCurrFormat;
      cbThousandSeparator.Text := ThousandSeparator;
      cbDecimalSeparator.text := DecimalSeparator;
      cbCurrencyDecimals.ItemIndex := CurrencyDecimals;
      cbDateSeparator.Text := DateSeparator;
      cbShortDateFormat.Text := ShortDateFormat;
      cbLongDateFormat.Text := LongDateFormat;
      cbTimeSeparator.Text := TimeSeparator;
      cbAMString.Text := TimeAMString;
      cbPMString.Text := TimePMString;
      cbShortTimeFormat.Text := ShortTimeFormat;
      cbListSeparator.Text := ListSeparator;
      chbUseSystemSettings.Checked := True;
    end
    else
    begin
      // Число
      //Иначе считаем из GlobalStorage
      cbDecimalSeparator.text := ReadString(st_rs_DecimalSeparator);
      cbThousandSeparator.Text := ReadString(st_rs_ThousandSeparator);
      cbListSeparator.Text := ReadString(st_rs_ListSeparator);

      // Денежная единица
      cbCurrencyString.Text := ReadString(st_rs_CurrencyString);
      cbCurrencyFormat.ItemIndex := ReadInteger(st_rs_CurrencyFormat);
      cbNegCurrFormat.ItemIndex := ReadInteger(st_rs_NegCurrFormat);
      cbCurrencyDecimals.ItemIndex := ReadInteger(st_rs_CurrencyDecimals);

      // Дата
      cbShortDateFormat.Text := ReadString(st_rs_ShortDateFormat);
      cbDateSeparator.Text := ReadString(st_rs_DateSeparator);
      cbLongDateFormat.Text := ReadString(st_rs_LongDateFormat);

      // Время
      cbShortTimeFormat.Text := ReadString(st_rs_ShortTimeFormat);
      cbTimeSeparator.Text := ReadString(st_rs_TimeSeparator);
      cbAMString.Text := ReadString(st_rs_TimeAMString);
      cbPMString.Text := ReadString(st_rs_TimePMString);

      chbUseSystemSettings.Checked := False;
    end;

    cbNumberDecimals.ItemIndex := ReadInteger(st_rs_NumberDecimals);
    cbNumberGroupCount.ItemIndex := ReadInteger(st_rs_NumberGroupCount);
    cbNegativeChar.Text := ReadString(st_rs_NegativeChar, Def_NegativeChar);
    cbNegativeFormat.ItemIndex := ReadInteger(st_rs_NegativeFormat, -1);
    cbLeadingZero.ItemIndex := ReadInteger(st_rs_LeadingZero, -1);
    cbCurrSeparator.Text := ReadString(st_rs_CurrSeparator, Def_CurrSeparator);
    cbCurrThousandSeparator.Text := ReadString(st_rs_CurrThousandSeparator,
      Def_CurrThousandSeparator);
    cbCurrGroup.ItemIndex := ReadInteger(st_rs_CurrGroup);
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure TdlgRegionalSettings.SetExample;
var
  S: String;
begin
  //Установка примеров данных
  stNum.Caption := FloatToStrF(TestValue, ffNumber, 15 , 3);
  stNegNum.Caption := FloatToStrF(-TestValue, ffNumber, 15, 3);
  stCurr.Caption := CurrToStrF(TestValue, ffCurrency, CurrencyDecimals);
  stNegCurr.Caption := CurrToStrF(-TestValue, ffCurrency, CurrencyDecimals);

  DateTimeToString(S, ShortDateFormat, Date);
  stDate.Caption := S;
  DateTimeToString(S, LongDateFormat, Date);
  stLongDate.Caption := S;
  DateTimeToString(S, ShortTimeFormat, Time);
  stTime.Caption := S;
end;

procedure TdlgRegionalSettings.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  //Заполнение списков константами
  cbCurrencyFormat.Clear;
  for I := 0 to CurrencyFormatCount - 1 do
  begin
    cbCurrencyFormat.Items.Add(CurrencyFormatConstants[I]);
  end;

  cbNegCurrFormat.Clear;
  for I := 0 to NegCurrencyFormatCount - 1 do
  begin
    cbNegCurrFormat.Items.Add(NegCurrencyFormatConstants[I]);
  end;
end;

procedure TdlgRegionalSettings.aApplyExecute(Sender: TObject);
begin
  DoApply;
end;

procedure TdlgRegionalSettings.aApplyUpdate(Sender: TObject);
begin
  aApply.Enabled := ApplyActive;
end;

procedure TdlgRegionalSettings.cbDecimalSeparatorChange(Sender: TObject);
begin
  ApplyActive := True;
  chbUseSystemSettings.Checked := False;
end;

procedure TdlgRegionalSettings.aOKExecute(Sender: TObject);
begin
  if DoApply then
    Close;
end;

procedure TdlgRegionalSettings.aCancelExecute(Sender: TObject);
begin
  Close;
end;

procedure TdlgRegionalSettings.chbUseSystemSettingsClick(Sender: TObject);
begin
  ApplyActive := True;
end;

function TdlgRegionalSettings.DoApply: Boolean;
var
  F: TgsStorageFolder;
begin
  Result := False;
  //Сохранение изменений настроек
  if not chbUseSystemSettings.Checked then
  begin
    if not TestCorrect then
      Exit;
    Application.UpdateFormatSettings := False;
    Application.UpdateMetricSettings := False;

    CurrencyString := cbCurrencyString.Text;
    CurrencyFormat := cbCurrencyFormat.ItemIndex;
    NegCurrFormat := cbNegCurrFormat.ItemIndex;
    if Length(cbThousandSeparator.Text) > 0 then
      ThousandSeparator := cbThousandSeparator.Text[1];
    if Length(cbDecimalSeparator.Text) > 0 then
      DecimalSeparator := cbDecimalSeparator.Text[1];
    CurrencyDecimals := cbCurrencyDecimals.ItemIndex;
    if Length(cbDateSeparator.Text) > 0 then
      DateSeparator := cbDateSeparator.Text[1];
    ShortDateFormat := cbShortDateFormat.Text;
    LongDateFormat := cbLongDateFormat.Text;
    if Length(cbTimeSeparator.Text) > 0 then
      TimeSeparator := cbTimeSeparator.Text[1];
    TimeAMString := cbAMString.Text;
    TimePMString := cbPMString.Text;
    ShortTimeFormat := cbShortTimeFormat.Text ;
    if Length(cbListSeparator.Text) > 0 then
      ListSeparator := cbListSeparator.Text[1];
    NumberDecimals := cbNumberDecimals.ItemIndex;
    NumberGroupCount := cbNumberGroupCount.ItemIndex;
    if Length(cbNegativeChar.Text) > 0 then
      NegativeChar := cbNegativeChar.Text[1];
    NegativeFormat := cbNegativeFormat.ItemIndex;
    LeadingZero := cbLeadingZero.ItemIndex;
    if Length(cbCurrSeparator.Text) > 0 then
      CurrSeparator := cbCurrSeparator.Text[1];
    if Length(cbCurrThousandSeparator.Text) > 0 then
      CurrThousandSeparator := cbCurrThousandSeparator.Text[1];
    CurrGroup := cbCurrGroup.ItemIndex;
  end
  else
  begin
    Application.UpdateFormatSettings := True;
    Application.UpdateMetricSettings := True;
    LoadSystemLocalSettingsIntoDelphiVars;
  end;

  F := GlobalStorage.OpenFolder(st_rs_RegionalSettingsPath, True, True);
  with F do
  try
    WriteString(st_rs_CurrencyString, CurrencyString);
    WriteInteger(st_rs_CurrencyFormat, CurrencyFormat);
    WriteInteger(st_rs_NegCurrFormat, NegCurrFormat);
    WriteString(st_rs_ThousandSeparator, ThousandSeparator);
    WriteString(st_rs_DecimalSeparator, DecimalSeparator);
    WriteInteger(st_rs_CurrencyDecimals, CurrencyDecimals);
    WriteString(st_rs_DateSeparator, DateSeparator);
    WriteString(st_rs_ShortDateFormat, ShortDateFormat);
    WriteString(st_rs_LongDateFormat, LongDateFormat);
    WriteString(st_rs_TimeSeparator, TimeSeparator);
    WriteString(st_rs_TimeAMString, TimeAMString);
    WriteString(st_rs_TimePMString, TimePMString);
    WriteString(st_rs_ShortTimeFormat, ShortTimeFormat);
    WriteString(st_rs_ListSeparator, ListSeparator);

    WriteBoolean(st_rs_UseSystemSettings, chbUseSystemSettings.Checked);

    WriteInteger(st_rs_NumberDecimals, NumberDecimals);
    WriteInteger(st_rs_NumberGroupCount, NumberGroupCount);
    WriteString(st_rs_NegativeChar, NegativeChar);
    WriteInteger(st_rs_NegativeFormat, NegativeFormat);
    WriteInteger(st_rs_LeadingZero, LeadingZero);
    WriteString(st_rs_CurrSeparator, CurrSeparator);
    WriteString(st_rs_CurrThousandSeparator, CurrThousandSeparator);
    WriteInteger(st_rs_CurrGroup, CurrGroup);

  finally
    GlobalStorage.CloseFolder(F);
  end;


  LoadRegionalSettings;
  SetExample;
  ApplyActive := False;
  Result := True;
end;

initialization
  //RegisterFrmClass(TdlgRegionalSettings);
  RegisterClass(TdlgRegionalSettings);

finalization
  //UnRegisterFrmClass(TdlgRegionalSettings);
  UnRegisterClass(TdlgRegionalSettings);

end.
