// ShlTanya, 27.02.2019

unit rp_frmParamLineSE_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, prm_ParamFunctions_unit, ComCtrls;

type
  TfrmParamLineSE = class(TFrame)
    Panel1: TPanel;
    pcParam: TPageControl;
    tsParam: TTabSheet;
    edDisplayName: TEdit;
    cbParamType: TComboBox;
    edHint: TEdit;
    chbxRequired: TCheckBox;
    tsValuesList: TTabSheet;
    edValuesList: TEdit;
    tsLink: TTabSheet;
    edTableName: TEdit;
    edDisplayField: TEdit;
    edPrimaryField: TEdit;
    lblName: TLabel;
    lblComment: TLabel;
    lblExample: TLabel;
    tsLink2: TTabSheet;
    edConditionScript: TEdit;
    cbLanguage: TComboBox;
    cbSortOrder: TComboBox;
    lblTable: TLabel;
    lblDisplay: TLabel;
    lblPrimary: TLabel;
    lblCondition: TLabel;
    lblLanguage: TLabel;
    lblSort: TLabel;
    tsLink3: TTabSheet;
    btnTemplate: TButton;
    lblTempl: TLabel;
    procedure cbParamTypeChange(Sender: TObject);
    procedure edDisplayNameChange(Sender: TObject);
    procedure chbxRequiredClick(Sender: TObject);
    procedure btnTemplateClick(Sender: TObject);

  private
    FOriginalName: String;
    FOnParamChange: TNotifyEvent;
    FValuesList: String;

    procedure DoChange(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;

    procedure SetParam(const AnParam: TgsParamData);
    function GetParam(const AnParam: TgsParamData): Boolean;
    property OnParamChange: TNotifyEvent read FOnParamChange write FOnParamChange;
    property ValuesList: String read FValuesList write FValuesList;
  end;

implementation

{$R *.DFM}

uses
  frmParamTemplate_unit
  {$IFDEF LOCALIZATION}
  {must be placed after Windows unit!}
  ,gd_localization_stub
  {$ENDIF}
  ;

{ TfrmParamLineSE }

procedure TfrmParamLineSE.SetParam(const AnParam: TgsParamData);
var
  I: Integer;
begin
  FOriginalName := AnParam.RealName;
  tsParam.Caption := AnParam.RealName;
  if AnParam.DisplayName = '' then
    edDisplayName.Text := AnParam.RealName
  else
    edDisplayName.Text := AnParam.DisplayName;
  edHint.Text := AnParam.Comment;
  chbxRequired.Checked := AnParam.Required;
  edTableName.Text := AnParam.LinkTableName;
  edDisplayField.Text := AnParam.LinkDisplayField;
  edPrimaryField.Text := AnParam.LinkPrimaryField;
  edConditionScript.Text := AnParam.LinkConditionFunction;
  edValuesList.Text := AnParam.ValuesList;
  cbLanguage.ItemIndex := 0;
  for I := 0 to cbLanguage.Items.Count - 1 do
    if AnsiUpperCase(Trim(cbLanguage.Items[I])) = AnsiUpperCase(Trim(AnParam.LinkFunctionLanguage)) then
    begin
      cbLanguage.ItemIndex := I;
      Break;
    end;
  if AnParam.SortField > '' then
    cbSortOrder.Text := AnParam.SortField
  else
    cbSortOrder.ItemIndex := AnParam.SortOrder;
  // Данный кусок кода менять только с текстом ComboBox и кодом ниже
  case AnParam.ParamType of
    prmInteger:         cbParamType.ItemIndex := 0; // Число целое
    prmFloat:           cbParamType.ItemIndex := 1; // Число дробное
    prmDate:            cbParamType.ItemIndex := 2; // Дата
    prmDateTime:        cbParamType.ItemIndex := 3; // Дата и время
    prmTime:            cbParamType.ItemIndex := 4; // Время
    prmString:          cbParamType.ItemIndex := 5; // Строка
    prmBoolean:         cbParamType.ItemIndex := 6; // Логический
    prmLinkElement:     cbParamType.ItemIndex := 7; // Ссылка на элемент
    prmLinkSet:         cbParamType.ItemIndex := 8; // Ссылка на множество
    prmNoQuery:         cbParamType.ItemIndex := 9; // Не запрашивается
    prmPeriod:          cbParamType.ItemIndex := 10; //Период
    prmList:            cbParamType.ItemIndex := 11; //Список
    prmRadioButtons:    cbParamType.ItemIndex := 12; //Набор радио кнопок
    prmCheckBoxs:       cbParamType.ItemIndex := 13; //Набор чекбоксов
  else
    Assert(False, 'Данный тип параметра д.о. не поддерживается');
  end;
  cbParamTypeChange(cbParamType);
end;

procedure TfrmParamLineSE.cbParamTypeChange(Sender: TObject);
begin
  tsValuesList.TabVisible := (Sender as TComboBox).ItemIndex in [11, 12, 13];
  tsLink.TabVisible := (Sender as TComboBox).ItemIndex in [7, 8];
  tsLink2.TabVisible := tsLink.TabVisible;
  tsLink3.TabVisible := tsLink.TabVisible;
  DoChange(Sender);
end;

function TfrmParamLineSE.GetParam(const AnParam: TgsParamData): Boolean;
begin
  Result := True;
  AnParam.RealName := FOriginalName;
  AnParam.DisplayName := edDisplayName.Text;
  AnParam.Comment := edHint.Text;
  AnParam.Required := chbxRequired.Checked;

  // Данный кусок кода менять только с текстом ComboBox и кодом ниже
  case cbParamType.ItemIndex of
    0:  AnParam.ParamType := prmInteger;        // Число целое
    1:  AnParam.ParamType := prmFloat;          // Число дробное
    2:  AnParam.ParamType := prmDate;           // Дата
    3:  AnParam.ParamType := prmDateTime;       // Дата и время
    4:  AnParam.ParamType := prmTime;           // Время
    5:  AnParam.ParamType := prmString;         // Строка
    6:  AnParam.ParamType := prmBoolean;        // Логический
    7:  AnParam.ParamType := prmLinkElement;    // Ссылка на элемент
    8:  AnParam.ParamType := prmLinkSet;        // Ссылка на множество
    9:  AnParam.ParamType := prmNoQuery;        // Не запрашиается в диалоге
    10: AnParam.ParamType := prmPeriod;         //Период
    11: AnParam.ParamType := prmList;           //Список
    12: AnParam.ParamType := prmRadioButtons;   //Набор радио кнопок
    13: AnParam.ParamType := prmCheckBoxs;      //Набор xtr,jrcjd
  else
    Assert(False, 'Данный тип параметра д.о. не поддерживается');
  end;

  if AnParam.ParamType in [prmList, prmRadioButtons, prmCheckBoxs] then
     AnParam.ValuesList := edValuesList.Text
  else
     AnParam.ValuesList := '';

  if AnParam.ParamType in [prmLinkElement, prmLinkSet] then
  begin
    AnParam.LinkTableName := edTableName.Text;
    AnParam.LinkDisplayField := edDisplayField.Text;
    AnParam.LinkPrimaryField := edPrimaryField.Text;
    AnParam.LinkConditionFunction := edConditionScript.Text;
    if cbLanguage.ItemIndex > 0 then
      AnParam.LinkFunctionLanguage := cbLanguage.Text
    else
      AnParam.LinkFunctionLanguage := '';
    if cbSortOrder.Items.IndexOf(cbSortOrder.Text) > -1 then
    begin
      AnParam.SortField := '';
      AnParam.SortOrder := cbSortOrder.Items.IndexOf(cbSortOrder.Text);
    end else
    begin
      AnParam.SortOrder := 0;
      AnParam.SortField := Trim(cbSortOrder.Text);
    end;
    Result := (AnParam.LinkTableName > '') and (AnParam.LinkDisplayField > '') and
     (AnParam.LinkPrimaryField > '');
    if not Result then
    begin
      MessageBox(Handle,
        'Условие ссылка заполнено не верно!',
        'Внимание',
        MB_OK or MB_ICONWARNING or MB_TASKMODAL);
      if edTableName.CanFocus then
        edTableName.SetFocus;
    end;
  end else
  begin
    AnParam.LinkTableName := '';
    AnParam.LinkDisplayField := '';
    AnParam.LinkPrimaryField := '';
  end;
end;

constructor TfrmParamLineSE.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TfrmParamLineSE.edDisplayNameChange(Sender: TObject);
begin
  DoChange(Sender);
end;

procedure TfrmParamLineSE.DoChange(Sender: TObject);
begin
  if Assigned(FOnParamChange) then
    FOnParamChange(Sender);
end;

procedure TfrmParamLineSE.chbxRequiredClick(Sender: TObject);
begin
  DoChange(Sender);
end;

procedure TfrmParamLineSE.btnTemplateClick(Sender: TObject);
begin
  with TfrmParamTemplate.Create(nil) do
  try
    if (ShowModal = mrOk) and (GetParam <> nil) then
    begin
      edDisplayName.Text := GetParam.DisplayName;
      edHint.Text := GetParam.Comment;
      edTableName.Text := GetParam.LinkTableName;
      edDisplayField.Text := GetParam.LinkDisplayField;
      edPrimaryField.Text := GetParam.LinkPrimaryField;
      edConditionScript.Text := GetParam.LinkConditionFunction;
      if GetParam.SortField > '' then
        cbSortOrder.Text := GetParam.SortField
      else
        cbSortOrder.ItemIndex := GetParam.SortOrder;
      cbLanguage.ItemIndex := cbLanguage.Items.IndexOf(GetParam.LinkFunctionLanguage);
      
      pcParam.ActivePageIndex := 0;
    end;
  finally
    Free;
  end;
end;

end.

