// ShlTanya, 20.02.2019

unit gsRadioButtons;

interface

uses
  Classes, Windows, Controls, Graphics, ExtCtrls, Messages, StdCtrls,
  Dialogs, Buttons, forms,ComObj, registry, SysUtils;

type
  TgsSelectBase = class(TPanel)

  protected
    FItems: TStringList;
    FRequired: Boolean;

    function GetItems: String;
    procedure SetItems(const Value: String);
    function GetValue: Variant; virtual; abstract;
    procedure SetValue(const Value: Variant); virtual; abstract;
    procedure SetRequired(const Value: Boolean);

    procedure Clear; virtual;
    procedure CreateControls; virtual; abstract;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property Items: String read GetItems write SetItems;
    property Value: Variant read GetValue write SetValue;
    property Required: Boolean read FRequired write SetRequired;
  end;

  TgsRadioButtons = class(TgsSelectBase)
  protected
    procedure CreateControls; override;
    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;
  end;

  TgsCheckBoxes = class(TgsSelectBase)
  private
    procedure OnClickCB(Sender: TObject);

  protected
    procedure CreateControls; override;
    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;
  end;

  TgsList = class(TgsSelectBase)
  private
    FComboBox: TComboBox;

  protected
    procedure Clear; override;
    procedure CreateControls; override;
    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;
  end;

implementation

procedure TgsRadioButtons.CreateControls;
const
  RBHeight  = 20;
  LeftPad   = 0;
var
  I, Y: Integer;
  RB: TRadioButton;
begin
  Y := 0;
  Height := FItems.Count * RBHeight;
  for I := 0 to FItems.Count - 1 do
  begin
    RB := TRadioButton.Create(nil);
    RB.Parent := Self;
    RB.Top := Y;
    RB.Left := LeftPad;
    RB.Width := Width - RB.Left;
    RB.Height := RBHeight;
    RB.Caption := FItems.Names[I];
    RB.Tag := I;
    RB.Checked := I = 0;
    Inc(Y, RBHeight);

    Assert(FItems.Objects[I] = nil);
    FItems.Objects[I] := RB;
  end;
end;

function TgsRadioButtons.GetValue: Variant;
var
  I: Integer;
  RB: TRadioButton;
begin
  Result := Unassigned;
  for I := 0 to FItems.Count - 1 do
  begin
    if FItems.Objects[I] is TRadioButton then
    begin
      RB := FItems.Objects[I] as TRadioButton;
      if RB.Checked then
      begin
        Result := FItems.Values[RB.Caption];
        break;
      end;
    end;
  end;
  Assert(not VarIsEmpty(Result));
end;

{ TgsSelectBase }

procedure TgsSelectBase.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    FItems.Objects[I].Free;
  FItems.Clear;
end;

constructor TgsSelectBase.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  BevelInner := bvNone;
  BevelOuter := bvNone;

  Height := 4;

  FItems := TStringList.Create;
end;

destructor TgsSelectBase.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TgsSelectBase.GetItems: String;
begin
  Result := FItems.CommaText;
end;

procedure TgsSelectBase.SetItems(const Value: String);
var
  I: Integer;
begin
  Clear;
  FItems.CommaText := Value;
  for I := 0 to FItems.Count - 1 do
    if Pos('=', FItems[I]) = 0 then
      FItems[I] := FItems[I] + '=' + FItems[I];
  CreateControls;
end;

procedure TgsSelectBase.SetRequired(const Value: Boolean);
begin
  FRequired := Value;
end;

{ TgsCheckBoxes }

procedure TgsCheckBoxes.CreateControls;
const
  CBHeight  = 20;
  LeftPad   = 0;
var
  I, Y: Integer;
  CB: TCheckBox;
begin
  Y := 0;
  Height := FItems.Count * CBHeight;
  for I := 0 to FItems.Count - 1 do
  begin
    CB := TCheckBox.Create(nil);
    CB.Parent := Self;
    CB.Top := Y;
    CB.Left := LeftPad;
    CB.Width := Width - CB.Left;
    CB.Height := CBHeight;
    CB.Caption := FItems.Names[I];
    CB.Tag := I;
    CB.Checked := FRequired and (I = 0);
    CB.OnClick := OnClickCB;
    Inc(Y, CBHeight);

    FItems.Objects[I].Free;
    FItems.Objects[I] := CB;
  end;
end;

function TgsCheckBoxes.GetValue: Variant;
var
  I: Integer;
  CB: TCheckBox;
begin
  Result := Unassigned;
  for I := 0 to FItems.Count - 1 do
  begin
    if FItems.Objects[I] is TCheckBox then
    begin
      CB := FItems.Objects[I] as TCheckBox;
      if CB.Checked then
      begin
        if VarIsEmpty(Result) then
          Result := VarArrayCreate([0, 0], varVariant)
        else
          VarArrayRedim(Result, VarArrayHighBound(Result, 1) + 1);
        Result[VarArrayHighBound(Result, 1)] := FItems.Values[CB.Caption];
      end;
    end;
  end;
  if FRequired then
    Assert(not VarIsEmpty(Result));
end;

procedure TgsRadioButtons.SetValue(const Value: Variant);
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    if FItems.Values[FItems.Names[I]] = Value then
    begin
      if FItems.Objects[I] is TRadioButton then
        (FItems.Objects[I] as TRadioButton).Checked := True;
      break;
    end;
  end;
end;

procedure TgsCheckBoxes.OnClickCB(Sender: TObject);
var
  I: Integer;
  F: Boolean;
begin
  if FRequired and (not (Sender as TCheckBox).Checked) then
  begin
    F := False;
    for I := 0 to ControlCount - 1 do
    begin
      if (Controls[I] is TCheckBox) and TCheckBox(Controls[I]).Checked then
      begin
        F := True;
        break;
      end;
    end;

    if not F then
      (Sender as TCheckBox).Checked := True;
  end;
end;

procedure TgsCheckBoxes.SetValue(const Value: Variant);
var
  I, J: Integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    if FItems.Objects[I] is TCheckBox then
    begin
      (FItems.Objects[I] as TCheckBox).Checked := False;
      if VarIsArray(Value) then
      begin
        for J := 0 to VarArrayHighBound(Value, 1) do
        begin
          if FItems.Values[FItems.Names[I]] = Value[J] then
          begin
            (FItems.Objects[I] as TCheckBox).Checked := True;
            break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TgsList.CreateControls;
var
  I: Integer;
begin
  Assert(FComboBox = nil);
  FComboBox := TComboBox.Create(nil);
  FComboBox.Parent := Self;
  FComboBox.Style := csDropDownList;
  FComboBox.Top := 0;
  for I := 0 to FItems.Count - 1 do
    FComboBox.Items.Add(FItems.Names[I]);
  if not FRequired then
    FComboBox.Items.Add('');
  FComboBox.Align := alClient;
  FComboBox.Sorted := True;
  if FRequired then
    FComboBox.ItemIndex := 0;
  Height := FComboBox.Height;
end;


function TgsList.GetValue: Variant;
begin
  Result := Unassigned;
  if (FComboBox <> nil) and (FComboBox.ItemIndex >= 0) and (FComboBox.Text > '') then
    Result := FItems.Values[FComboBox.Text];
end;

procedure TgsList.SetValue(const Value: Variant);
var
  I: Integer;
begin
  if FComboBox <> nil then
  begin
    if VarIsEmpty(Value) then
    begin
      if FRequired then
        FComboBox.ItemIndex := 0
      else
        FComboBox.ItemIndex := FComboBox.Items.IndexOf('');
    end else
    begin
      for I := 0 to FItems.Count - 1 do
      begin
        if FItems.Values[FItems.Names[I]] = Value then
        begin
          FComboBox.ItemIndex := FComboBox.Items.IndexOf(FItems.Names[I]);
          break;
        end;
      end;

      if FRequired and (FComboBox.ItemIndex < 0) then
        FComboBox.ItemIndex := 0;
    end;
  end;
end;

procedure TgsList.Clear;
begin
  inherited;
  FreeAndNil(FComboBox);
end;

end.
