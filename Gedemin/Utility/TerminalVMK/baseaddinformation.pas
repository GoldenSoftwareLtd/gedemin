unit BaseAddInformation; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, LMessages, Windows, ProjectCommon;

type
  { TBaseAddInformation }

  TBaseAddInformation = class(TForm)
    eInfo: TEdit;
    lInfo: TLabel;
    procedure eInfoEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations}
    FData: String;
    procedure WM_BARCODE(var Message: TMessage); message WM_SCAN_DATA;
  protected
    procedure Enter; virtual;
    function CheckCode(const ACode: String): boolean;  virtual; abstract;
  public
    { public declarations }
    IsReading: Boolean;
    procedure ScanRead;   virtual;
    class function Execute(AMsg: String): String; virtual;
    property Data: String read FData write FData;
  end;

  {TBarcodeType = record
   bMC_UPCA: byte;
   bMC_UPCA_ADDON: byte;
   bMC_UPCE: byte;
   bMC_EAN13: byte;
   bMC_EAN13_ADDON: byte;
   bMC_BOOKLAND: byte;
   bMC_EAN8: byte;
   bMC_CODE39: byte;
   bMC_CODE32: byte;
   bMC_PZN: byte;
   bMC_CODE128: byte;
   bMC_UCCEAN128: byte;
   bMC_CODE93: byte;
   bMC_CODE35: byte;
   bMC_CODE11: byte;
   bMC_I2OF5: byte;
   bMC_CODE25_ITF14: byte;
   bMC_CODE25_MATRIX: byte;
   bMC_CODE25_DLOGIC: byte;
   bMC_CODE25_INDUSTRY: byte;
   bMC_CODE25_IATA: byte;
   bMC_CODABAR: byte;
   bMC_COUPON: byte;
   bMC_MSI: byte;
   bMC_PLESSEY: byte;
   bMC_GS1: byte;
   bMC_GS1_LIMITED: byte;
   bMC_GS1_EXPANDED: byte;
   bMC_TELEPEN: byte;
  end; }

  function MCScanInit: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanInit';

  function MCScanRead: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanRead';

  function MCScanReadCancel: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanReadCancel';

  function MCScanClose: Integer;
    stdcall; external 'MCSSLib.dll' name 'MCScanClose';

  procedure MCRegisterWindow(hWnd: HWND);
    stdcall; external 'MCSSLib.dll' name 'MCRegisterWindow';

  procedure MCGetScanDataByte(szBarData: pbyte; szBarType: pbyte);
    stdcall; external 'MCSSLib.dll' name 'MCGetScanDataByte';

  procedure MCGetBarCodeType(szBarType: pointer);
    stdcall; external 'MCSSLib.dll' name 'MCGetBarCodeType';

  procedure MCSetBarCodeType(szBarType: pointer);
    stdcall; external 'MCSSLib.dll' name 'MCSetBarCodeType';

implementation

{$R *.lfm}

{ TBaseAddInformation }

procedure TBaseAddInformation.FormCreate(Sender: TObject);

begin
  inherited;
  BorderStyle := bsNone;
  WindowState := wsNormal;

  eInfo.Font.Size := 13;
  eInfo.Text := '';
  lInfo.Caption := '';
 // IsReading := false;
  //Init();

end;

procedure TBaseAddInformation.eInfoEnter(Sender: TObject);
begin
  eInfo.SelLength := 0;
  eInfo.SelStart := Length(eInfo.Text);
end;

procedure TBaseAddInformation.FormDestroy(Sender: TObject);
begin
 // MCScanClose();
end;



procedure TBaseAddInformation.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: Enter;
    VK_ESCAPE: ModalResult := mrCancel;
    133:
    begin
      ScanRead();
      Sleep(50);
     // MCScanReadCancel();
    end;
  end;


end;


procedure TBaseAddInformation.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  // Application.MessageBox(PChar(IntToStr(Key)), '', 0);
  if Key = 133 then
  begin
   Sleep(50);
   MCScanReadCancel();

  end;
end;


procedure TBaseAddInformation.FormShow(Sender: TObject);
var
  ScreenWidth, ScreenHeight: Integer;
  TaskBarWnd: THandle;
begin
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, ScreenWidth, ScreenHeight, 0);
  TaskBarWnd := FindWindow('HHTaskBar', '');
  if (TaskBarWnd <> 0) then
    SetWindowPos(TaskBarWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE);
end;

procedure TBaseAddInformation.WM_BARCODE(var Message: TMessage);
var

  Str: array [0..100] of byte;
  T: array [0..100] of byte;
  i: integer;
  Result: string;

begin

   for i := 0 to 100 do
   Str[i] := 0;
   MCGetScanDataByte(@Str, @T);

   MCScanReadCancel();
   Sleep(10);
   Result := '';

   for i := 0 to 100 do
     if Str[i] <> 0 then
       Result := Result + Chr(Str[i]);

   eInfo.Text := Result;
   beep();
   IsReading := false;

end;

class function TBaseAddInformation.Execute(AMsg: String): String;
begin
  Result := '';
  with TBaseAddInformation.Create(nil) do
  try
    lInfo.Caption := AMsg;
    ShowModal;
    Result := FData;
  finally
    Free;
  end;
end;

procedure TBaseAddInformation.Enter;
begin
  FData := Trim(eInfo.Text);
  ModalResult := mrOk;
end;


procedure TBaseAddInformation.ScanRead;
var inres:integer;
begin
   if IsReading then
   begin
      inres := MCScanReadCancel();
      // Reading already in progress, now cancel it.

   end;
   IsReading := true;
   inres := MCScanRead();
   if inres < 0 then
   begin
     Application.MessageBox(PChar(IntToStr(inres)), '', 0);
     IsReading := false;
   end;
end;
end.

