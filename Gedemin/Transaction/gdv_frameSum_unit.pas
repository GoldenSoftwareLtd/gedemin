// ShlTanya, 09.03.2019

unit gdv_frameSum_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, ExtCtrls, gdcBaseInterface;

type
  TframeSum = class(TFrame)
    gbSum: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label10: TLabel;
    Bevel2: TBevel;
    gsiblCurrKey: TgsIBLookupComboBox;
    cbInNcu: TCheckBox;
    cbInCurr: TCheckBox;
    cbNcuDecDigits: TComboBox;
    cbNcuScale: TComboBox;
    cbCurrScale: TComboBox;
    cbCurrDecDigits: TComboBox;
    cbInEQ: TCheckBox;
    Label1: TLabel;
    Bevel5: TBevel;
    cbEQScale: TComboBox;
    Label2: TLabel;
    cbEQDecDigits: TComboBox;
    bvl1: TBevel;
    Label3: TLabel;
    cbQuantityDecDigits: TComboBox;
    Label4: TLabel;
    cbQuantityScale: TComboBox;
    lblInQuantity: TLabel;
    procedure cbNcuScaleKeyPress(Sender: TObject; var Key: Char);
  private
    procedure SetCurrDecDigits(const Value: Integer);
    procedure SetCurrkey(const Value: TID);
    procedure SetCurrScale(const Value: Integer);
    procedure SetInCurr(const Value: Boolean);
    procedure SetInNcu(const Value: Boolean);
    procedure SetNcuDecDigits(const Value: Integer);
    procedure SetNcuScale(const Value: Integer);
    function GetCurrDecDigits: Integer;
    function GetCurrkey: TID;
    function GetCurrScale: Integer;
    function GetInCurr: Boolean;
    function GetInNcu: Boolean;
    function GetNcuDecDigits: Integer;
    function GetNcuScale: Integer;

    function LocalStrToInt(Text: string; DefValue: Integer): Integer;
    function GetEQDecDigits: Integer;
    function GetEQScale: Integer;
    function GetInEQ: Boolean;
    procedure SetEQDecDigits(const Value: Integer);
    procedure SetEQScale(const Value: Integer);
    procedure SetInEQ(const Value: Boolean);

    procedure SetQuantityDecDigits(const Value: Integer);
    procedure SetQuantityScale(const Value: Integer);
    function GetQuantityDecDigits: Integer;
    function GetQuantityScale: Integer;
  public
    { Public declarations }
    property InNcu: Boolean read GetInNcu write SetInNcu;
    property InCurr: Boolean read GetInCurr write SetInCurr;
    property NcuDecDigits: Integer read GetNcuDecDigits write SetNcuDecDigits;
    property CurrDecDigits: Integer read GetCurrDecDigits write SetCurrDecDigits;
    property NcuScale: Integer read GetNcuScale write SetNcuScale;
    property CurrScale: Integer read GetCurrScale write SetCurrScale;
    property Currkey: TID read GetCurrkey write SetCurrkey;

    property InEQ: Boolean read GetInEQ write SetInEQ;
    property EQDecDigits: Integer read GetEQDecDigits write SetEQDecDigits;
    property EQScale: Integer read GetEQScale write SetEQScale;

    property QuantityDecDigits: Integer read GetQuantityDecDigits write SetQuantityDecDigits;
    property QuantityScale: Integer read GetQuantityScale write SetQuantityScale;
  end;

implementation

{$R *.DFM}

{ TframeSum }

function TframeSum.GetCurrDecDigits: Integer;
begin
  Result := LocalStrToInt(cbCurrDecDigits.Text, 4);
end;

function TframeSum.GetCurrkey: TID;
begin
  Result := gsiblCurrKey.CurrentKeyInt;
end;

function TframeSum.GetCurrScale: Integer;
begin
  Result := LocalStrToInt(cbCurrScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

function TframeSum.GetInCurr: Boolean;
begin
  Result := cbInCurr.Checked;
end;

function TframeSum.GetInNcu: Boolean;
begin
  Result := cbInNcu.Checked;
end;

function TframeSum.GetNcuDecDigits: Integer;
begin
  Result := LocalStrToInt(cbNcuDecDigits.Text, 4);
end;

function TframeSum.GetNcuScale: Integer;
begin
  Result := LocalStrToInt(cbNcuScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

procedure TframeSum.SetCurrDecDigits(const Value: Integer);
begin
  cbCurrDecDigits.Text := IntToStr(Value);
end;

procedure TframeSum.SetCurrkey(const Value: TID);
begin
  gsiblCurrKey.CurrentKeyInt := Value;
end;

procedure TframeSum.SetCurrScale(const Value: Integer);
begin
  cbCurrScale.Text := IntToStr(Value);
end;

procedure TframeSum.SetInCurr(const Value: Boolean);
begin
  cbInCurr.Checked := Value;
end;

procedure TframeSum.SetInNcu(const Value: Boolean);
begin
  cbInNcu.Checked := Value;
end;

procedure TframeSum.SetNcuDecDigits(const Value: Integer);
begin
  cbNcuDecDigits.Text := IntToStr(Value);
end;

procedure TframeSum.SetNcuScale(const Value: Integer);
begin
  cbNcuScale.Text := IntToStr(Value);
end;

function TframeSum.LocalStrToInt(Text: string; DefValue: Integer): Integer;
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

procedure TframeSum.cbNcuScaleKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8, #13]) then
  begin
    Beep;
    Key := #0;
  end;
end;

function TframeSum.GetEQDecDigits: Integer;
begin
  Result := LocalStrToInt(cbEQDecDigits.Text, 4);
end;

function TframeSum.GetEQScale: Integer;
begin
  Result := LocalStrToInt(cbEQScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

function TframeSum.GetInEQ: Boolean;
begin
  Result := cbInEQ.Checked;
end;

procedure TframeSum.SetEQDecDigits(const Value: Integer);
begin
  cbEQDecDigits.Text := IntToStr(Value);
end;

procedure TframeSum.SetEQScale(const Value: Integer);
begin
  cbEQScale.Text := IntToStr(Value);
end;

procedure TframeSum.SetInEQ(const Value: Boolean);
begin
  cbInEQ.Checked := Value;
end;

function TframeSum.GetQuantityDecDigits: Integer;
begin
  Result := LocalStrToInt(cbQuantityDecDigits.Text, 4);
end;

function TframeSum.GetQuantityScale: Integer;
begin
  Result := LocalStrToInt(cbQuantityScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

procedure TframeSum.SetQuantityDecDigits(const Value: Integer);
begin
  cbQuantityDecDigits.Text := IntToStr(Value);
end;

procedure TframeSum.SetQuantityScale(const Value: Integer);
begin
  cbQuantityScale.Text := IntToStr(Value);
end;

end.
