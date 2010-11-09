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
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    tsLink2: TTabSheet;
    edConditionScript: TEdit;
    cbLanguage: TComboBox;
    cbSortOrder: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    tsLink3: TTabSheet;
    Button1: TButton;
    Label10: TLabel;
    procedure cbParamTypeChange(Sender: TObject);
    procedure edDisplayNameChange(Sender: TObject);
    procedure chbxRequiredClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);

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
  cbSortOrder.ItemIndex := AnParam.SortOrder;
  // ������ ����� ���� ������ ������ � ������� ComboBox � ����� ����
  case AnParam.ParamType of
    prmInteger:         cbParamType.ItemIndex := 0; // ����� �����
    prmFloat:           cbParamType.ItemIndex := 1; // ����� �������
    prmDate:            cbParamType.ItemIndex := 2; // ����
    prmDateTime:        cbParamType.ItemIndex := 3; // ���� � �����
    prmTime:            cbParamType.ItemIndex := 4; // �����
    prmString:          cbParamType.ItemIndex := 5; // ������
    prmBoolean:         cbParamType.ItemIndex := 6; // ����������
    prmLinkElement:     cbParamType.ItemIndex := 7; // ������ �� �������
    prmLinkSet:         cbParamType.ItemIndex := 8; // ������ �� ���������
    prmNoQuery:         cbParamType.ItemIndex := 9; // �� �������������
    prmPeriod:          cbParamType.ItemIndex := 10; //������
    prmList:            cbParamType.ItemIndex := 11; //������
    prmRadioButtons:    cbParamType.ItemIndex := 12; //����� ����� ������
    prmCheckBoxs:       cbParamType.ItemIndex := 13; //����� ���������
  else
    Assert(False, '������ ��� ��������� �.�. �� ��������������');
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

  // ������ ����� ���� ������ ������ � ������� ComboBox � ����� ����
  case cbParamType.ItemIndex of
    0:  AnParam.ParamType := prmInteger;        // ����� �����
    1:  AnParam.ParamType := prmFloat;          // ����� �������
    2:  AnParam.ParamType := prmDate;           // ����
    3:  AnParam.ParamType := prmDateTime;       // ���� � �����
    4:  AnParam.ParamType := prmTime;           // �����
    5:  AnParam.ParamType := prmString;         // ������
    6:  AnParam.ParamType := prmBoolean;        // ����������
    7:  AnParam.ParamType := prmLinkElement;    // ������ �� �������
    8:  AnParam.ParamType := prmLinkSet;        // ������ �� ���������
    9:  AnParam.ParamType := prmNoQuery;        // �� ������������ � �������
    10: AnParam.ParamType := prmPeriod;         //������
    11: AnParam.ParamType := prmList;           //������
    12: AnParam.ParamType := prmRadioButtons;   //����� ����� ������
    13: AnParam.ParamType := prmCheckBoxs;      //����� xtr,jrcjd
  else
    Assert(False, '������ ��� ��������� �.�. �� ��������������');
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
    AnParam.SortOrder := cbSortOrder.ItemIndex;
    Result := (AnParam.LinkTableName > '') and (AnParam.LinkDisplayField > '') and
     (AnParam.LinkPrimaryField > '');
    if not Result then
    begin
      MessageBox(Handle,
        '������� ������ ��������� �� �����!',
        '��������',
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

procedure TfrmParamLineSE.Button1Click(Sender: TObject);
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
      cbSortOrder.ItemIndex := GetParam.SortOrder;
      cbLanguage.ItemIndex := cbLanguage.Items.IndexOf(GetParam.LinkFunctionLanguage);
      
      pcParam.ActivePageIndex := 0;
    end;
  finally
    Free;
  end;
end;

end.

