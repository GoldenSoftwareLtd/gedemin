unit gdv_frAcctSum_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gsIBLookupComboBox, StdCtrls, ExtCtrls, gdvParamPanel, gd_common_functions;

type
  TfrAcctSum = class(TFrame)
    ppMain: TgdvParamPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label18: TLabel;
    cbInNcu: TCheckBox;
    cbNcuDecDigits: TComboBox;
    cbNcuScale: TComboBox;
    cbInCurr: TCheckBox;
    cbCurrdecDigits: TComboBox;
    cbCurrScale: TComboBox;
    gsiblCurrKey: TgsIBLookupComboBox;
    cbInEQ: TCheckBox;
    Label1: TLabel;
    cbEQdecDigits: TComboBox;
    Label2: TLabel;
    cbEQScale: TComboBox;
    procedure cbNcuScaleKeyPress(Sender: TObject; var Key: Char);
    procedure ppMainResize(Sender: TObject);
    procedure cbNcuScaleExit(Sender: TObject);
  private
    function GetCurrDecDigits: Integer;
    function GetCurrkey: Integer;
    function GetCurrScale: Integer;
    function GetInCurr: Boolean;
    function GetInNcu: Boolean;
    function GetInEQ: Boolean;
    function GetNcuDecDigits: Integer;
    function GetNcuScale: Integer;
    function GetEQDecDigits: Integer;
    function GetEQScale: Integer;
    procedure SetCurrDecDigits(const Value: Integer);
    procedure SetCurrkey(const Value: Integer);
    procedure SetCurrScale(const Value: Integer);
    procedure SetInCurr(const Value: Boolean);
    procedure SetInNcu(const Value: Boolean);
    procedure SetInEQ(const Value: Boolean);
    procedure SetNcuDecDigits(const Value: Integer);
    procedure SetNcuScale(const Value: Integer);
    procedure SetEQDecDigits(const Value: Integer);
    procedure SetEQScale(const Value: Integer);
    { Private declarations }
    function StrToInt(Text: string; DefValue: Integer): Integer;
  public
    procedure SaveToStream(const Stream: TStream);
    procedure LoadFromStream(const Stream: TStream);
    { Public declarations }
    property InNcu: Boolean read GetInNcu write SetInNcu;
    property InCurr: Boolean read GetInCurr write SetInCurr;
    property InEQ: Boolean read GetInEQ write SetInEQ;
    property NcuDecDigits: Integer read GetNcuDecDigits write SetNcuDecDigits;
    property CurrDecDigits: Integer read GetCurrDecDigits write SetCurrDecDigits;
    property EQDecDigits: Integer read GetEQDecDigits write SetEQDecDigits;
    property NcuScale: Integer read GetNcuScale write SetNcuScale;
    property CurrScale: Integer read GetCurrScale write SetCurrScale;
    property EQScale: Integer read GetEQScale write SetEQScale;
    property Currkey: Integer read GetCurrkey write SetCurrkey;
    procedure SetEQVisible(bV: boolean);
  end;

implementation

{$R *.DFM}

{ TfrAcctSum }

function TfrAcctSum.GetCurrDecDigits: Integer;
begin
  Result := StrToInt(cbCurrDecDigits.Text, 4);
end;

function TfrAcctSum.GetCurrkey: Integer;
begin
  Result := gsiblCurrKey.CurrentKeyInt;
end;

function TfrAcctSum.GetCurrScale: Integer;
begin
  Result := StrToInt(cbCurrScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

function TfrAcctSum.GetInCurr: Boolean;
begin
  Result := cbInCurr.Checked;
end;

function TfrAcctSum.GetInNcu: Boolean;
begin
  Result := cbInNcu.Checked;
end;

function TfrAcctSum.GetNcuDecDigits: Integer;
begin
  Result := StrToInt(cbNcuDecDigits.Text, 4);
end;

function TfrAcctSum.GetNcuScale: Integer;
begin
  Result := StrToInt(cbNcuScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

procedure TfrAcctSum.SetCurrDecDigits(const Value: Integer);
begin
  cbCurrDecDigits.Text := IntToStr(Value);
end;

procedure TfrAcctSum.SetCurrkey(const Value: Integer);
begin
  gsiblCurrKey.CurrentKeyInt := Value;
end;

procedure TfrAcctSum.SetCurrScale(const Value: Integer);
begin
  cbCurrScale.Text := IntToStr(Value);
end;

procedure TfrAcctSum.SetInCurr(const Value: Boolean);
begin
  cbInCurr.Checked := Value;
end;

procedure TfrAcctSum.SetInNcu(const Value: Boolean);
begin
  cbInNcu.Checked := Value;
end;

procedure TfrAcctSum.SetNcuDecDigits(const Value: Integer);
begin
  cbNcuDecDigits.Text := IntToStr(Value);
end;

procedure TfrAcctSum.SetNcuScale(const Value: Integer);
begin
  cbNcuScale.Text := IntToStr(Value);
end;

function TfrAcctSum.StrToInt(Text: string; DefValue: Integer): Integer;
begin
  if Text = '' then
    Result := DefValue
  else
    try
      Result := Sysutils.StrToInt(Text);
      if Result < 0 then
        Result := DefValue;
    except
      Result := DefValue;
    end;
end;

procedure TfrAcctSum.cbNcuScaleKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8, #13]) then
  begin
    Beep;
    Key := #0;
  end;
end;

procedure TfrAcctSum.ppMainResize(Sender: TObject);
begin
  SetBounds(Left, Top, ppMain.Width, ppMain.Height);
end;

procedure TfrAcctSum.LoadFromStream(const Stream: TStream);
begin
  InNcu := ReadBooleanFromStream(Stream);
  InCurr := ReadBooleanFromStream(Stream);
  NcuDecDigits := ReadIntegerFromStream(Stream);
  CurrDecDigits := ReadIntegerFromStream(Stream);
  NcuScale := ReadIntegerFromStream(Stream);
  CurrScale := ReadIntegerFromStream(Stream);
  Currkey := ReadIntegerFromStream(Stream);

end;

procedure TfrAcctSum.SaveToStream(const Stream: TStream);
begin
  SaveBooleanToStream(InNcu, Stream);
  SaveBooleanToStream(InCurr, Stream);
  SaveIntegerToStream(NcuDecDigits, Stream);
  SaveIntegerToStream(CurrDecDigits, Stream);
  SaveIntegerToStream(NcuScale, Stream);
  SaveIntegerToStream(CurrScale, Stream);
  SaveIntegerToStream(Currkey, Stream);
end;

procedure TfrAcctSum.cbNcuScaleExit(Sender: TObject);
begin
  if StrToInt(TComboBox(Sender).Text, 1) = 0 then
  begin
    Beep;
    ShowMessage('Масштаб должен быть больше нуля');
    TComboBox(Sender).SetFocus;
  end;
end;

function TfrAcctSum.GetEQDecDigits: Integer;
begin
  Result := StrToInt(cbEqDecDigits.Text, 4);
end;

function TfrAcctSum.GetEQScale: Integer;
begin
  Result := StrToInt(cbEqScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

function TfrAcctSum.GetInEQ: Boolean;
begin
  Result := cbInEq.Checked;
end;

procedure TfrAcctSum.SetEQDecDigits(const Value: Integer);
begin
  cbEqDecDigits.Text := IntToStr(Value);
end;

procedure TfrAcctSum.SetEQScale(const Value: Integer);
begin
  cbEqScale.Text := IntToStr(Value);
end;

procedure TfrAcctSum.SetInEQ(const Value: Boolean);
begin
  cbInEq.Checked := Value;
end;

procedure TfrAcctSum.SetEQVisible(bV: boolean);
begin
  cbInEQ.Visible:= bV;
  Label1.Visible:= bV;
  Label2.Visible:= bV;
  cbEQdecDigits.Visible:= bV;
  cbEQScale.Visible:= bV;
  if bV then
    ppMain.Height:= 225
  else
    ppMain.Height:= 160;
end;

end.
