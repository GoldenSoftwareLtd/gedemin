unit gdv_frAcctSum_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gsIBLookupComboBox, StdCtrls, ExtCtrls, gdvParamPanel, gd_common_functions,
  AcctUtils;

type
  TfrAcctSum = class(TFrame)
    ppMain: TgdvParamPanel;
    pnlEQ: TPanel;                                                           
    pnlQuantity: TPanel;                                 
    pnlTop: TPanel;
    cbInNcu: TCheckBox;
    Label5: TLabel;
    cbNcuDecDigits: TComboBox;
    Label6: TLabel;
    cbNcuScale: TComboBox;
    cbInCurr: TCheckBox;
    Label11: TLabel;
    cbCurrdecDigits: TComboBox;
    Label18: TLabel;
    cbCurrScale: TComboBox;
    Label12: TLabel;
    gsiblCurrKey: TgsIBLookupComboBox;
    cbInEQ: TCheckBox;
    Label1: TLabel;
    cbEQdecDigits: TComboBox;
    Label2: TLabel;
    cbEQScale: TComboBox;
    lblInQuantity: TLabel;
    Label3: TLabel;
    cbQuantityDecDigits: TComboBox;
    Label4: TLabel;
    cbQuantityScale: TComboBox;
    procedure cbNcuScaleKeyPress(Sender: TObject; var Key: Char);
    procedure ppMainResize(Sender: TObject);
    procedure cbNcuScaleExit(Sender: TObject);
    procedure gsiblCurrKeyChange(Sender: TObject);
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
    function GetQuantityDecDigits: Integer;
    function GetQuantityScale: Integer;
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
    procedure SetQuantityDecDigits(const Value: Integer);
    procedure SetQuantityScale(const Value: Integer);
    { Private declarations }
    function LocalStrToInt(Text: string; DefValue: Integer): Integer;
    procedure UpdatePanelVisibility;
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
    property QuantityDecDigits: Integer read GetQuantityDecDigits write SetQuantityDecDigits;
    property NcuScale: Integer read GetNcuScale write SetNcuScale;
    property CurrScale: Integer read GetCurrScale write SetCurrScale;
    property EQScale: Integer read GetEQScale write SetEQScale;
    property QuantityScale: Integer read GetQuantityScale write SetQuantityScale;
    property Currkey: Integer read GetCurrkey write SetCurrkey;
    procedure SetEQVisible(bV: boolean);
    procedure SetQuantityVisible(bV: boolean);
  end;

implementation

{$R *.DFM}

const
  StreamVersion4 = 4;

{ TfrAcctSum }

function TfrAcctSum.GetCurrDecDigits: Integer;
begin
  Result := LocalStrToInt(cbCurrDecDigits.Text, 4);
end;

function TfrAcctSum.GetCurrkey: Integer;
begin
  Result := gsiblCurrKey.CurrentKeyInt;
end;

function TfrAcctSum.GetCurrScale: Integer;
begin
  Result := LocalStrToInt(cbCurrScale.Text, 1);
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
  Result := LocalStrToInt(cbNcuDecDigits.Text, 4);
end;

function TfrAcctSum.GetNcuScale: Integer;
begin
  Result := LocalStrToInt(cbNcuScale.Text, 1);
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

function TfrAcctSum.LocalStrToInt(Text: string; DefValue: Integer): Integer;
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
var
  SV: Byte;
  OldPosition: Integer;
begin
  OldPosition := Stream.Position;
  Stream.Read(SV, Sizeof(SV));
  if SV <> StreamVersion4 then
  begin
    Stream.Position := OldPosition;
    InNcu := ReadBooleanFromStream(Stream);
    InCurr := ReadBooleanFromStream(Stream);
    NcuDecDigits := ReadIntegerFromStream(Stream);
    CurrDecDigits := ReadIntegerFromStream(Stream);
    NcuScale := ReadIntegerFromStream(Stream);
    CurrScale := ReadIntegerFromStream(Stream);
    Currkey := ReadIntegerFromStream(Stream);
  end else
  begin
    InCurr := ReadBooleanFromStream(Stream);
    NcuDecDigits := ReadIntegerFromStream(Stream);
    CurrDecDigits := ReadIntegerFromStream(Stream);
    NcuScale := ReadIntegerFromStream(Stream);
    CurrScale := ReadIntegerFromStream(Stream);
    Currkey := ReadIntegerFromStream(Stream);
    InEQ := ReadBooleanFromStream(Stream);
    EQDecDigits := ReadIntegerFromStream(Stream);
    EQScale := ReadIntegerFromStream(Stream);
    QuantityDecDigits := ReadIntegerFromStream(Stream);
    QuantityScale := ReadIntegerFromStream(Stream);
    InNcu := ReadBooleanFromStream(Stream);
  end;
end;

procedure TfrAcctSum.SaveToStream(const Stream: TStream);
var
  SV: Byte;
begin
  SV := StreamVersion4;
  Stream.Write(SV, SizeOf(SV));
  SaveBooleanToStream(InCurr, Stream);
  SaveIntegerToStream(NcuDecDigits, Stream);
  SaveIntegerToStream(CurrDecDigits, Stream);
  SaveIntegerToStream(NcuScale, Stream);
  SaveIntegerToStream(CurrScale, Stream);
  SaveIntegerToStream(Currkey, Stream);
  SaveBooleanToStream(InEQ, Stream);
  SaveIntegerToStream(EQDecDigits, Stream);
  SaveIntegerToStream(EQScale, Stream);
  SaveIntegerToStream(QuantityDecDigits, Stream);
  SaveIntegerToStream(QuantityScale, Stream);
  SaveBooleanToStream(InNcu, Stream);
end;

procedure TfrAcctSum.cbNcuScaleExit(Sender: TObject);
begin
  if LocalStrToInt(TComboBox(Sender).Text, 1) = 0 then
  begin
    Beep;
    ShowMessage('Масштаб должен быть больше нуля');
    TComboBox(Sender).SetFocus;
  end;
end;

function TfrAcctSum.GetEQDecDigits: Integer;
begin
  Result := LocalStrToInt(cbEqDecDigits.Text, 4);
end;

function TfrAcctSum.GetEQScale: Integer;
begin
  Result := LocalStrToInt(cbEqScale.Text, 1);
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
  pnlEQ.Visible := bV;
  UpdatePanelVisibility;
end;


function TfrAcctSum.GetQuantityDecDigits: Integer;
begin
  Result := LocalStrToInt(cbQuantityDecDigits.Text, 4);
end;

function TfrAcctSum.GetQuantityScale: Integer;
begin
  Result := LocalStrToInt(cbQuantityScale.Text, 1);
  if Result = 0 then
    Result := 1;
end;

procedure TfrAcctSum.SetQuantityDecDigits(const Value: Integer);
begin
  cbQuantityDecDigits.Text := IntToStr(Value);
end;

procedure TfrAcctSum.SetQuantityScale(const Value: Integer);
begin
  cbQuantityScale.Text := IntToStr(Value);
end;

procedure TfrAcctSum.SetQuantityVisible(bV: boolean);
begin
  pnlQuantity.Visible := bV;
  UpdatePanelVisibility;
end;

procedure TfrAcctSum.UpdatePanelVisibility;
begin
  if pnlEQ.Visible then
  begin
    if pnlQuantity.Visible then
      ppMain.Height:= 280
    else
      ppMain.Height:= 220;
  end
  else
  begin
    if pnlQuantity.Visible then
      ppMain.Height:= 220
    else
      ppMain.Height:= 160;
  end;
end;

procedure TfrAcctSum.gsiblCurrKeyChange(Sender: TObject);
begin
  //cbCurrdecDigits.Text :=
  //  IntToStr(AcctUtils.GetCurrDecDigits((Sender as TgsIBLookupComboBox).Text));
end;

end.
