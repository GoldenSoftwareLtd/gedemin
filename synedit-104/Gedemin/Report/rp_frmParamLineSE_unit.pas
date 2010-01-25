unit rp_frmParamLineSE_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, prm_ParamFunctions_unit;

type
  TfrmParamLineSE = class(TFrame)
    Panel1: TPanel;
    pnlSimple: TPanel;
    lblParamName: TLabel;
    edDisplayName: TEdit;
    cbParamType: TComboBox;
    edHint: TEdit;
    pnlLink: TPanel;
    edTableName: TEdit;
    edDisplayField: TEdit;
    edPrimaryField: TEdit;
    edConditionScript: TEdit;
    cbLanguage: TComboBox;
    Bevel1: TBevel;
    cbSortOrder: TComboBox;
    chbxRequired: TCheckBox;
    procedure cbParamTypeChange(Sender: TObject);
    procedure edDisplayNameChange(Sender: TObject);
    procedure chbxRequiredClick(Sender: TObject);
  private
    FOriginalName: String;
    FRealHeight: Integer;
    FOnParamChange: TNotifyEvent;

    procedure DoChange(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    procedure SetParam(const AnParam: TgsParamData);
    function GetParam(const AnParam: TgsParamData): Boolean;
    property OnParamChange: TNotifyEvent read FOnParamChange write FOnParamChange;
  end;

implementation

{$R *.DFM}

  {$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub
  ;
  {$ENDIF}

{ TfrmParamLineSE }

procedure TfrmParamLineSE.SetParam(const AnParam: TgsParamData);
var
  I: Integer;
begin
  FOriginalName := AnParam.RealName;
  lblParamName.Caption := '��������: ' + AnParam.RealName;
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
  else
    Assert(False, '������ ��� ��������� �.�. �� ��������������');
  end;
  cbParamTypeChange(cbParamType);
end;

procedure TfrmParamLineSE.cbParamTypeChange(Sender: TObject);
begin
  pnlLink.Visible := (Sender as TComboBox).ItemIndex in [7, 8];
  if (Sender as TComboBox).ItemIndex = 9 then
  begin
    edHint.Visible := False;
    Height := 2 * cbParamType.Height;
  end else
    begin
      edHint.Visible := True;
      Height := FRealHeight;
    end;
  if pnlLink.Visible then
  begin
    Height := FRealHeight;
  end else
    Height := FRealHeight - pnlLink.Height;
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
  else
    Assert(False, '������ ��� ��������� �.�. �� ��������������');
  end;
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

  FRealHeight := Height;
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

end.

