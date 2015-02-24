unit xp_frmCalcDropDown_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xp_frmDropDown_unit, ActnList, XPButton, StdCtrls;

type
  TCalcOperation = (coNone, coAdd, coSub, coMul, coDiv, coInv);

  TfrmCalcDropDown = class(TfrmDropDown)
    bMC: TXPButton;
    bMR: TXPButton;
    bMS: TXPButton;
    bMPlus: TXPButton;
    actMC: TAction;
    actMR: TAction;
    actMS: TAction;
    actMPlus: TAction;
    b7: TXPButton;
    b4: TXPButton;
    b1: TXPButton;
    b0: TXPButton;
    b8: TXPButton;
    b5: TXPButton;
    b2: TXPButton;
    XPButton12: TXPButton;
    b9: TXPButton;
    b6: TXPButton;
    b3: TXPButton;
    bPoint: TXPButton;
    bDiv: TXPButton;
    bMul: TXPButton;
    bSub: TXPButton;
    bAdd: TXPButton;
    bSqrt: TXPButton;
    bPercent: TXPButton;
    bInv: TXPButton;
    bEqual: TXPButton;
    bBack: TXPButton;
    bCE: TXPButton;
    bC: TXPButton;
    act1: TAction;
    act2: TAction;
    act3: TAction;
    act4: TAction;
    act5: TAction;
    act6: TAction;
    act7: TAction;
    act8: TAction;
    act9: TAction;
    act0: TAction;
    actBack: TAction;
    actCe: TAction;
    actC: TAction;
    actPlusMinus: TAction;
    actPoint: TAction;
    actPlus: TAction;
    actDiv: TAction;
    actMul: TAction;
    actMinus: TAction;
    actSqrt: TAction;
    actPerc: TAction;
    actInv: TAction;
    acEqu: TAction;
    stMemo: TStaticText;
    procedure act1Execute(Sender: TObject);
    procedure act2Execute(Sender: TObject);
    procedure act3Execute(Sender: TObject);
    procedure act4Execute(Sender: TObject);
    procedure act5Execute(Sender: TObject);
    procedure act6Execute(Sender: TObject);
    procedure act7Execute(Sender: TObject);
    procedure act8Execute(Sender: TObject);
    procedure act9Execute(Sender: TObject);
    procedure act0Execute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actPointExecute(Sender: TObject);
    procedure actBackExecute(Sender: TObject);
    procedure actCeExecute(Sender: TObject);
    procedure actCExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure actPlusExecute(Sender: TObject);
    procedure actDivExecute(Sender: TObject);
    procedure actMulExecute(Sender: TObject);
    procedure actMinusExecute(Sender: TObject);
    procedure acEquExecute(Sender: TObject);
    procedure actPlusMinusExecute(Sender: TObject);
    procedure actInvExecute(Sender: TObject);
    procedure actSqrtExecute(Sender: TObject);
    procedure actMCExecute(Sender: TObject);
    procedure actMPlusExecute(Sender: TObject);
    procedure actMSExecute(Sender: TObject);
    procedure actMRExecute(Sender: TObject);
    procedure actPercExecute(Sender: TObject);
  private
    FEditWindow: HWND;
    FrA, FrB, FMR: string;
    FOperation: TCalcOperation;
    FReset: Boolean;
    FPush: Boolean;
    procedure SetEditWindow(const Value: HWND);

    procedure ShowValue;
    procedure NumberPressed(S: Char);
    procedure Reset;
    procedure Push;

    procedure CalcOperation;
    function GetNumber(var S: string): Extended;
    procedure UpdateIndicator;
  protected
    function GetInitBounds(ALeft, ATop, AWidth, AHeight: Integer; FirstTime:Boolean): TRect; override;
    procedure SetValue(const Value: Variant); override;
    function GetValue: Variant; override;
  public

    property EditWindow: HWND read FEditWindow write SetEditWindow;
  end;

var
  frmCalcDropDown: TfrmCalcDropDown;

implementation

{$R *.dfm}

{ TfrmCalcDropDown }

procedure TfrmCalcDropDown.SetEditWindow(const Value: HWND);
begin
  FEditWindow := Value;
end;

procedure TfrmCalcDropDown.act1Execute(Sender: TObject);
begin
  NumberPressed('1');
end;

procedure TfrmCalcDropDown.act2Execute(Sender: TObject);
begin
  NumberPressed('2');
end;

procedure TfrmCalcDropDown.act3Execute(Sender: TObject);
begin
  NumberPressed('3');
end;

procedure TfrmCalcDropDown.act4Execute(Sender: TObject);
begin
  NumberPressed('4');
end;

procedure TfrmCalcDropDown.act5Execute(Sender: TObject);
begin
  NumberPressed('5');
end;

procedure TfrmCalcDropDown.act6Execute(Sender: TObject);
begin
  NumberPressed('6');
end;

procedure TfrmCalcDropDown.act7Execute(Sender: TObject);
begin
  NumberPressed('7');
end;

procedure TfrmCalcDropDown.act8Execute(Sender: TObject);
begin
  NumberPressed('8');
end;

procedure TfrmCalcDropDown.act9Execute(Sender: TObject);
begin
  NumberPressed('9');
end;

procedure TfrmCalcDropDown.act0Execute(Sender: TObject);
begin
  NumberPressed('0');
end;

function TfrmCalcDropDown.GetInitBounds(ALeft, ATop, AWidth,
  AHeight: Integer; FirstTime:Boolean): TRect;
begin
  Result := Rect(0, 0 , 263, 127);
end;

procedure TfrmCalcDropDown.ShowValue;
var
  L: Integer;
begin
  Windows.SetWindowText(FEditWindow, PChar(FrA));
  L := Length(FrA);
  SendMessage(FEditWindow, EM_SETSEL, L, L);
  SendMessage(FEditWindow, EM_SCROLLCARET, 0, 0);
end;

procedure TfrmCalcDropDown.NumberPressed(S: Char);
var
  _S: string;
begin
  Reset;
  Push;
  
  _S := FrA;
  if _S = '0' then
    _S := S
  else
    _S := _S + S;
    
  try
    StrToFloat(_S);
  except
    Beep;
    Exit;
  end;

  FrA := _S;
  ShowValue;
end;

function TfrmCalcDropDown.GetValue: Variant;
begin
  Result := FrA;
end;

procedure TfrmCalcDropDown.SetValue(const Value: Variant);
begin
  if VarIsNull(Value) then
    FrA := '0'
  else
    FrA := Value;
  FReset := True;
end;

procedure TfrmCalcDropDown.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    CalcOperation;
    ModalResult := mrOk;
    Key := 0;
  end else
    inherited;
end;

procedure TfrmCalcDropDown.Reset;
begin
  if FReset then
  begin
    FrA := '0';
    FrB := '0';
    FOperation := coNone;
    FReset := False;
  end;  
end;

procedure TfrmCalcDropDown.actPointExecute(Sender: TObject);
begin
  NumberPressed(',');
end;

procedure TfrmCalcDropDown.actBackExecute(Sender: TObject);
var
  S: string;
  L: Integer;
begin
  Reset;
  
  S := FrA;
  if (S > '') and (S <> '0') then
  begin
    L := Length(S);
    SetLength(S, L - 1);
    if S > '' then
    begin
      Dec(L);
      if S[L] = ',' then
      begin
        SetLength(S, L - 1);
      end;
    end else
      S := '0';
  end;
  FrA := S;
  ShowValue;
end;

procedure TfrmCalcDropDown.actCeExecute(Sender: TObject);
begin
  FrA := '0';
  ShowValue;
end;

procedure TfrmCalcDropDown.actCExecute(Sender: TObject);
begin
  FReset := True;
  Reset;
  ShowValue;
end;

type
  TCrackControl = class(TControl);

procedure TfrmCalcDropDown.FormKeyPress(Sender: TObject; var Key: Char);
var
  BName: string;
  I: Integer;
  C: TControl;
const
  cButtonNamePref = 'b';
begin
  BName := cButtonNamePref + Key;
  C := nil;
  for I := 0 to ControlCount - 1 do
  begin
    if Controls[I].Name = BName then
    begin
      C := Controls[I];
    end;
  end;

  case Key of
    ',', '.': C := bPoint;
    '+': C := bAdd;
    '-': C := bSub;
    '/': C := bDiv;
    '*': C := bMul;
    '=': C := bEqual;
    '@': C := bSqrt;
  end;

  if C <> nil then
  begin
    TCrackControl(C).Click;
    Key := #0;
  end else
    inherited;
end;

procedure TfrmCalcDropDown.CalcOperation;
var
  N1, N2: Extended;
  S: Extended;
begin
  if FOperation <> coNone then
  begin
    try
      N1 := GetNumber(FrA);
      N2 := GetNumber(FrB);
      S := N1;
      case FOperation of
        coAdd: S := n1 + n2;
        coSub: S := n2 - n1;
        coDiv: S := n2 / n1;
        coMul: S := n1 * n2;
      end;

      FrA := FloatToStr(S);
      FrB := '0';
      ShowValue;
    except
      Beep;
    end;
  end  
end;

function TfrmCalcDropDown.GetNumber(var S: string): Extended;
begin
  if S = '' then S := '0';
  try
    Result := StrToFloat(S);
  except
    S := '0';
    Result := 0;
  end;
end;

procedure TfrmCalcDropDown.actPlusExecute(Sender: TObject);
begin
  CalcOperation;
  FOperation := coAdd;
  FReset := False;
  FPush := True;
end;

procedure TfrmCalcDropDown.actDivExecute(Sender: TObject);
begin
  CalcOperation;
  FOperation := coDiv;
  FReset := False;
  FPush := True;
end;

procedure TfrmCalcDropDown.actMulExecute(Sender: TObject);
begin
  CalcOperation;
  FOperation := coMul;
  FReset := False;
  FPush := True;
end;

procedure TfrmCalcDropDown.actMinusExecute(Sender: TObject);
begin
  CalcOperation;
  FOperation := coSub;
  FReset := False;
  FPush := True;
end;

procedure TfrmCalcDropDown.acEquExecute(Sender: TObject);
begin
  CalcOperation;
  FReset := True;
  FOperation := coNone;
end;

procedure TfrmCalcDropDown.actPlusMinusExecute(Sender: TObject);
var
  N: Extended;
begin
  N := GetNumber(FrA);
  N := - N;
  FrA := FloatTostr(N);
  ShowValue;
end;

procedure TfrmCalcDropDown.Push;
begin
  if FPush then
  begin
    frB := frA;
    frA := '0';
    FPush := False;
  end;
end;

procedure TfrmCalcDropDown.actInvExecute(Sender: TObject);
var
  N: Extended;
begin
  N := GetNumber(FrA);
  try
    N := 1 /N;
    FrA := FloatToStr(N);
    ShowValue;
    FReset := True;
  except
    Beep;
  end;
end;

procedure TfrmCalcDropDown.actSqrtExecute(Sender: TObject);
var
  N: Extended;
begin
  N := GetNumber(FrA);
  try
    N := SQRT(N);
    FrA := FloatToStr(N);
    ShowValue;
    FReset := True;
  except
    Beep;
  end;
end;

procedure TfrmCalcDropDown.actMCExecute(Sender: TObject);
begin
  FMR := '0';
  UpdateIndicator;
  FReset := True;
end;

procedure TfrmCalcDropDown.actMPlusExecute(Sender: TObject);
var
  N1, N2: Extended;
begin
  N1 := GetNumber(FrA);
  N2 := GetNumber(FMR);
  try
    FMR := FloatToStr(N1 + N2);
    UpdateIndicator;
    FReset := True;
  except
    Beep;
  end;
end;

procedure TfrmCalcDropDown.UpdateIndicator;
begin
  if (FMR = '') or (FMR = '0') then
  begin
    stMemo.Caption := '';
  end else
    stMemo.Caption := 'M';
end;

procedure TfrmCalcDropDown.actMSExecute(Sender: TObject);
begin
  FMR := FrA;
  UpdateIndicator;
  FReset := True;
end;

procedure TfrmCalcDropDown.actMRExecute(Sender: TObject);
begin
  FrA := FMR;
  ShowValue;
  FReset := True;
end;

procedure TfrmCalcDropDown.actPercExecute(Sender: TObject);
var
  N1, N2: Extended;
begin
  N1 := GetNumber(FrA);
  N2 := GetNumber(FrB);
  try
    N1 := N2 * (n1 / 100);
    FrA := FloatToStr(N1);
    ShowValue;
    FReset := True; 
  except
    Beep;
  end;
end;

end.
