unit xpDBComboBox;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, DBCtrls, XPEdit, XPComboBox, Graphics,
  Messages, Windows, XPButton, IBCustomDataSet, IBDataBase, xp_frmDropDown_unit,
  xp_DBComboBoxResouceSring_unit;

type
  TxpDBComboBox = class(TDBComboBox)
  private
    FDisabledBorderWidth: Integer;
    FEnabledBorderWidth: Integer;
    FEnabledBorderColor: TColor;
    FDisabledBorderColor: TColor;
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetDisabledBorderWidth(const Value: Integer);
    procedure SetEnabledBorderColor(const Value: TColor);
    procedure SetEnabledBorderWidth(const Value: Integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure HookMouseEnter; dynamic;
    procedure HookMouseLeave; dynamic;
  public
    DrawState: TOwnerDrawState;
    constructor Create(AOwner: TComponent); override;
  published
    property EnabledBorderColor: TColor read FEnabledBorderColor write SetEnabledBorderColor default BORDER_ENABLED;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default BORDER_DISABLED;
    property EnabledBorderWidth: Integer read FEnabledBorderWidth write SetEnabledBorderWidth default ENABLED_WIDTH;
    property DisabledBorderWidth: Integer read FDisabledBorderWidth write SetDisabledBorderWidth default DISABLED_WIDTH;
  end;

  TxpCustomFramedDBComboBox = class(TxpDBComboBox)
  private
  protected
    FDropDownForm: TfrmDropDown;
    procedure DropDown; override;
    procedure InitDropDown; virtual;
    procedure CloseUp; override;

    function GetDropDownFormClass: TfrmDropDownClass; virtual;
    procedure InitDropDownBounds(ChangeClientRect: Boolean); virtual;
  public
    destructor Destroy; override;
  end;

  TxpFKLookupComboBox = class(TxpCustomFramedDBComboBox)
  private
    FListTable: string;
    FKeyField: string;
    FTransaction: TIBTransaction;

    FDataSet: TIBDataSet;
    FDidActivate: Boolean;
    FInitSQL: boolean;

    procedure SetKeyField(const Value: string);
    procedure SetListTable(const Value: string);
    procedure SetTransaction(const Value: TIBTransaction);
  protected
    procedure DropDown; override;
    procedure CloseUp; override;
    function GetDropDownFormClass: TfrmDropDownClass; override;
    procedure InitDropDown; override;
  public
    destructor Destroy; override;
  published
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property ListTable: string read FListTable write SetListTable;
    property KeyField: string read FKeyField write SetKeyField;
  end;

  TxpCalcDBComboBox = class(TxpCustomFramedDBComboBox)
  private
  protected
    procedure DropDown; override;
    procedure InitDropDown; override;
    function GetDropDownFormClass: TfrmDropDownClass; override;
  public
  published
  end;

  TxpMemoDbComboBox = class(TxpCustomFramedDBComboBox)
  protected
    function GetDropDownFormClass: TfrmDropDownClass; override;
  end;

  TxpDateTimeDbComboBox = class(TxpCustomFramedDBComboBox)
  protected
    function GetDropDownFormClass: TfrmDropDownClass; override;
  end;

  TxpBlobDbComboBox = class(TxpCustomFramedDBComboBox)
  protected
//    function GetDropDownFormClass: TfrmDropDownClass; override;
  end;

procedure Register;

implementation

uses TypInfo, xp_frmFKDropDown_unit, xp_frmCalcDropDown_unit, xp_frmMemoDropDown_unit,
  xp_frmDateTimeDropDown_unit;

procedure Register;
begin
  RegisterComponents('XP Data Control', [TxpDBComboBox, TxpFKLookupComboBox, TxpCalcDBComboBox]);
end;
{ TxpDBComboBox }

procedure TxpDBComboBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  HookMouseEnter;
end;

procedure TxpDBComboBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  HookMouseLeave;
end;

procedure TxpDBComboBox.CNCommand(var Message: TWMCommand);
begin
  inherited;
  case Message.NotifyCode of
    CBN_SETFOCUS:
    begin
      Invalidate;
    end;
    CBN_KILLFOCUS:
    begin
      Invalidate;
    end;
  end;
end;

constructor TxpDBComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FEnabledBorderColor := BORDER_ENABLED;
  FDisabledBorderColor := BORDER_DISABLED;
  FEnabledBorderWidth := ENABLED_WIDTH;
  FDisabledBorderWidth := DISABLED_WIDTH;
end;

procedure TxpDBComboBox.HookMouseEnter;
begin
  Include(DrawState, odHotLight);
  Invalidate;
end;

procedure TxpDBComboBox.HookMouseLeave;
begin
  Exclude(DrawState, odHotLight);
  Invalidate;
end;

procedure TxpDBComboBox.SetDisabledBorderColor(const Value: TColor);
begin
  FDisabledBorderColor := Value;
end;

procedure TxpDBComboBox.SetDisabledBorderWidth(const Value: Integer);
begin
  FDisabledBorderWidth := Value;
end;

procedure TxpDBComboBox.SetEnabledBorderColor(const Value: TColor);
begin
  FEnabledBorderColor := Value;
end;

procedure TxpDBComboBox.SetEnabledBorderWidth(const Value: Integer);
begin
  FEnabledBorderWidth := Value;
end;

procedure TxpDBComboBox.WMPaint(var Message: TWMPaint);
var
  R: TRect;
  Canvas: TControlCanvas;
begin
  inherited;
  if not (csPaintCopy in ControlState) then
  begin
    Canvas := TControlCanvas.Create;
    Canvas.Control:=Self;
    try
      GetWindowRect(Handle, R);
      OffsetRect(R, -R.Left, -R.Top);
      if Enabled then
        Frame3D(Canvas, R, EnabledBorderColor, EnabledBorderColor, EnabledBorderWidth)
      else
        Frame3D(Canvas, R, DisabledBorderColor, DisabledBorderColor, DisabledBorderWidth);

      if not FIsFocused then
      begin
        if (odHotLight in DrawState) then
          Frame3D(Canvas, R, XP_BTN_BDR_MOUSE_END, XP_BTN_BDR_MOUSE_END, 1)
        else
          Frame3D(Canvas, R, Color, Color, 1);
      end else
        Frame3D(Canvas, R, XP_BTN_BDR_NOMOUSE_START, XP_BTN_BDR_NOMOUSE_START, 1);

      R.Left := R.Right - (R.Bottom - R.Top);
      if Style <> csSimple then
      begin
        if DroppedDown then
          DrawFrameControl(Canvas.Handle, R, DFC_SCROLL, DFCS_FLAT or DFCS_SCROLLCOMBOBOX)
        else
          DrawFrameControl(Canvas.Handle, R, DFC_SCROLL, DFCS_FLAT or DFCS_SCROLLCOMBOBOX);
      end;
    finally
      Canvas.Free;
    end;
  end;
end;

{ TxpFKLookupComboBox }

procedure TxpFKLookupComboBox.CloseUp;
begin

  inherited;
end;

destructor TxpFKLookupComboBox.Destroy;
begin
  FreeAndNil(FDataSet);
  inherited;
end;

procedure TxpFKLookupComboBox.DropDown;
begin
  if FDataSet = nil then
  begin
    FDataSet := TIBDataSet.Create(nil);
    FDataSet.Transaction := FTransaction;
  end;

  if FTransaction <> nil then
  begin
    FDidActivate := not FTransaction.InTransaction;
    if FDidActivate then
      FTransaction.StartTransaction;
  end;

  if FInitSQl then
  begin
    if FDataSet.Active then
      FDataSet.Close;

    FDataSet.SelectSQL.Text := Format('SELECT * FROM %s', [FListTable]);
    FDataSet.Open;  
  end;

  inherited;
end;

function TxpFKLookupComboBox.GetDropDownFormClass: TfrmDropDownClass;
begin
  Result := TfrmFKDropDown;
  
end;

procedure TxpFKLookupComboBox.InitDropDown;
begin
  inherited;
  with FDropDownForm as TfrmFKDropDown do
  begin
    DataSet := FDataSet;
    KeyField := Self.FKeyField;
    pCaption.Caption := ' ' + Format(DataOF, [FListTable]);
  end;
end;

procedure TxpFKLookupComboBox.SetKeyField(const Value: string);
begin
  FKeyField := Value;
end;

procedure TxpFKLookupComboBox.SetListTable(const Value: string);
begin
  if FListtable <> value then
  begin
    FListTable := Value;
    FInitSQl := True;
  end;
end;

procedure TxpFKLookupComboBox.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
end;

{ TxpCustomFramedDBComboBox }

procedure TxpCustomFramedDBComboBox.CloseUp;
begin
  inherited;
end;

destructor TxpCustomFramedDBComboBox.Destroy;
begin

  inherited;
end;

procedure TxpCustomFramedDBComboBox.DropDown;
var
  DataLink: TFieldDataLink;
  I: Integer;
begin
  I := SendMessage(Self.Handle, CM_GETDATALINK, 0, 0);
  DataLink := TFieldDataLink(I);

  if FDropDownForm = nil then
  begin
    FDropDownForm := GetDropDownFormClass.Create(Self);
    InitDropDown;
    InitDropDownBounds(True);
  end else
    InitDropDownBounds(False);

  inherited;
  FDropDownForm.Value := DataLink.Field.Value;
  if FDropDownForm.ShowModal = mrOk then
  begin
    DataLink.Edit;
    DataLink.Field.Value := FDropDownForm.Value;
    Update;
  end;
end;

function TxpCustomFramedDBComboBox.GetDropDownFormClass: TfrmDropDownClass;
begin
  Result := TfrmDropDown;
end;

procedure TxpCustomFramedDBComboBox.InitDropDown;
begin

end;

procedure TxpCustomFramedDBComboBox.InitDropDownBounds(ChangeClientRect: Boolean);
var
  R: TRect;
begin
  R := GetClientRect;
  R.TopLeft := ClientToScreen(R.TopLeft);
  R.BottomRight := ClientToScreen(R.BottomRight);

  FDropDownForm.InitBounds(R.left, R.Top, R.Right - R.Left, R.Bottom - R.Top, ChangeClientRect);
end;

{ TxpCalcDBComboBox }

procedure TxpCalcDBComboBox.DropDown;
begin
  inherited;
end;

function TxpCalcDBComboBox.GetDropDownFormClass: TfrmDropDownClass;
begin
  Result := TfrmCalcDropDown;
end;

procedure TxpCalcDBComboBox.InitDropDown;
begin
  inherited;
  TfrmCalcDropDown(FDropDownForm).EditWindow := FEditHandle;
end;

{ TxpMemoDbComboBox }

function TxpMemoDbComboBox.GetDropDownFormClass: TfrmDropDownClass;
begin
  Result := TfrmMemoDropDown
end;

{ TxpDateTimeDbComboBox }

function TxpDateTimeDbComboBox.GetDropDownFormClass: TfrmDropDownClass;
begin
  Result := TfrmDateTimeDropDown
end;

end.
