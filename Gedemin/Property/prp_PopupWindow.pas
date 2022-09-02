// ShlTanya, 26.02.2019

unit prp_PopupWindow;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TPopupWindow = class(TForm)
    lMessage: TLabel;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    FIndex: Integer;
    FLb: string;
    procedure SetLb(const Value: string);
  public
    { Public declarations }
    property Lb: string read FLb write SetLb;
  end;

var
  PopupWindow: TPopupWindow;

implementation

{$R *.DFM}

procedure TPopupWindow.SetLb(const Value: string);
begin
  FLb := Value;
  lMessage.Caption := value;
end;

procedure TPopupWindow.TimerTimer(Sender: TObject);
const
  ColorPalette : Array[1..13] of TColor = (clBlack, clMaroon, clRed,
    clGreen, clLime, clOlive, {clYellow,} clNavy, clBlue, clPurple,
    clFuchsia, clTeal, clAqua, clGray);
begin
  Inc(FIndex);
//  if FIndex > 13 then
//    FIndex := 1;
//  lMessage.Font.Color := ColorPalette[FIndex];
  lMessage.Caption := Format('Загрузка (%d)', [FIndex]);
end;

end.
