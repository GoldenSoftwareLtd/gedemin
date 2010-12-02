unit gsScaner;

interface

uses Windows, Classes, ExtCtrls, SysUtils, Forms, Dialogs;

type
  TgsScanerHook = class(TComponent)
  private
    FBeforeChar: Word;
    FAfterChar: Word;
    FBarCode: String;
    FTestCode: String;
    FStartScaner: Boolean;
    FUseCtrlCode: Boolean;
    FUseCtrlCodeAfter: Boolean;
    FEnabled: Boolean;
    FOnChange: TNotifyEvent;
    FTimer: TTimer;
//    OldScanerHook: TgsScanerHook;

    procedure SetStartScaner(aValue: Boolean);
    procedure DoOnTimer(Sender: TObject);
    procedure SetUseControlCode(const Value: Boolean);
  protected

    procedure DoOnChange; virtual;
//    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property StartScaner: Boolean read FStartScaner write SetStartScaner;
    property TestCode: String read FTestCode write FTestCode;
    property Enabled: Boolean read FEnabled write {Set}FEnabled default False;

    procedure InitScaner(const aEnabled: Boolean = False);
  published
    property BeforeChar: Word read FBeforeChar write FBeforeChar default 2;
    property AfterChar: Word read FAfterChar write FAfterChar default 3;
    property UseCtrlCode: Boolean read FUseCtrlCode write SetUseControlCode;
    property UseCtrlCodeAfter: Boolean read FUseCtrlCodeAfter write FUseCtrlCodeAfter;
    property BarCode: String read FBarCode write FBarCode;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

var
  gsScanerHook: TgsScanerHook;
  ActiveScanerHook: TgsScanerHook;

implementation

var
  KeyboardHook: HHook;

const
  Flag: Boolean = False;
  isKeyboard: Boolean = False;

function KeyboardProc(Code: Integer; WParam, LParam: Longint): Longint; stdcall;
var
  i: Integer;
begin
  if Code < 0 then
  begin
    Result := CallNextHookEx(KeyBoardHook, Code, WParam, LParam);
    exit;
  end;

  Result := 1;

  if Flag then
    Exit;

  Flag := True;
  try
    if (gsScanerHook <> nil) and
       not (csDesigning in gsScanerHook.ComponentState) and
//       (gsScanerHook.Owner as TForm).Active and  // только если форма активна
       ( LParam and (1 shl 31) = 0) then
    begin

        if GetKeyState(VK_CONTROL) and $8000 <> 0 then
          gsScanerHook.TestCode := gsScanerHook.TestCode + #254;
        gsScanerHook.TestCode := gsScanerHook.TestCode + Format('%d-', [wParam]);

        if (wParam = $11) or (wParam = $9) then
        begin
        end
        else
          if wParam = gsScanerHook.BeforeChar then
          begin

            if not gsScanerHook.UseCtrlCode or
               (GetKeyState(VK_CONTROL) and $8000 <> 0) then
            begin
              ActiveScanerHook := nil;
              for i := 0 to Screen.ActiveForm.ComponentCount - 1 do
                if Screen.ActiveForm.Components[i] is TgsScanerHook then
                begin
                  ActiveScanerHook := Screen.ActiveForm.Components[i] as TgsScanerHook;
                  Break;
                end;
              if Assigned(ActiveScanerHook) then // есть ScanerHook
              begin
                isKeyboard := True;
                gsScanerHook.StartScaner := True;
              end;
              Exit;
            end;
          end
          else
            if gsScanerHook.StartScaner then
            begin
              if (wParam = gsScanerHook.AfterChar) and
                 (  not gsScanerHook.UseCtrlCodeAfter or
                    (GetKeyState(VK_CONTROL) and $8000 <> 0) ) then
              begin
                isKeyboard := False;
                gsScanerHook.StartScaner := False;

                ActiveScanerHook.BarCode := gsScanerHook.BarCode;
                if ActiveScanerHook.Enabled then
                begin                                                                                      
                  Flag := False; // Yuri - позволяем пользователю вводить данные с клавиатуры во время выполнения DoOnChange
                  ActiveScanerHook.DoOnChange;
                end;
  
                Exit;
              end;

              if gsScanerHook.Enabled and    // "прячем" считывание
                 IsCharAlphaNumeric(Chr(wParam)) and
                 (GetKeyState(VK_CONTROL) and $8000 = 0) then
                gsScanerHook.BarCode := gsScanerHook.BarCode + Chr(wParam);

              if Length(gsScanerHook.BarCode) > 60 then
              begin
                isKeyboard := False;
                gsScanerHook.StartScaner := False;
              end;
              Exit;

            end

    end;

    if (gsScanerHook <> nil) and
       not (csDesigning in gsScanerHook.ComponentState) and
       ( LParam and (1 shl 31) <> 0) and
       (wParam = gsScanerHook.AfterChar) and
       (  not gsScanerHook.UseCtrlCodeAfter or
          (GetKeyState(VK_CONTROL) and $8000 <> 0) ) then
    begin
      isKeyboard := False;
      gsScanerHook.StartScaner := False;
      Exit;
    end;

    if (gsScanerHook <> nil) and
       not (csDesigning in gsScanerHook.ComponentState) and
       isKeyboard then
      Exit;

    Result := CallNextHookEx(KeyboardHook, Code, WParam, LParam);
  finally
    Flag := False;
  end;
                        
end;     // KeyboardProc


constructor TgsScanerHook.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FBeforeChar := $42;
  FAfterChar := $43;
  FBarCode := '';
  FStartScaner := False;
  FUseCtrlCode := True;
  FUseCtrlCodeAfter := True;

  FOnChange := nil;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 1200;
  FTimer.OnTimer := DoOnTimer;

end;

procedure TgsScanerHook.DoOnChange;
begin
  try
    if Assigned(FOnChange) then FOnChange(Self);
  except
  end;
end;

destructor TgsScanerHook.Destroy;
begin
  if gsScanerHook = Self then
    gsScanerHook := nil;

  if FTimer <> nil then
    FreeAndNil(FTimer);

  inherited Destroy;
end;

procedure TgsScanerHook.SetStartScaner(aValue: Boolean);
begin
  if FStartScaner <> aValue then
  begin
    FStartScaner := aValue;
    if FStartScaner then
    begin
      FBarCode := '';
      FTimer.Enabled := True;
    end
    else
      FTimer.Enabled := False;
{    if not FStartScaner and (FBarCode <> '') then
      DoOnChange;}
  end;
end;

{procedure TgsScanerHook.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if AComponent.ClassName = 'TgsScanerHook' then
    if Operation = opRemove then
      if not (csDestroying in AComponent.ComponentState) then // !!! - ?
        OldScanerHook := nil;
end;}

procedure TgsScanerHook.DoOnTimer(Sender: TObject);
begin
  isKeyboard := False;
  StartScaner := False;
  FTimer.Enabled := False;
end;

procedure TgsScanerHook.InitScaner(const aEnabled: Boolean = False);
begin
  gsScanerHook := Self;
  Enabled := aEnabled;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsScanerHook]);
end;


procedure TgsScanerHook.SetUseControlCode(const Value: Boolean);
begin
  FUseCtrlCode := Value;
  FUseCtrlCodeAfter := Value;
end;

initialization

  gsScanerHook := nil;

  KeyboardHook := SetWindowsHookEx(WH_Keyboard, @KeyboardProc,
    hInstance, GetCurrentThreadid);

finalization

{  if Assigned(gsScanerHook) then
    FreeAndNil(gsScanerHook);}
  gsScanerHook := nil;

  UnHookWindowsHookEx(KeyboardHook);

end.
