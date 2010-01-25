
{******************************************}
{                                          }
{             FastReport v2.53             }
{              About window                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_About;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FR_Const;

type
  TfrAboutForm = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    lbUrl: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    lbEMail: TLabel;
    lbEMail2: TLabel;
    Image1: TImage;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lbUrlClick(Sender: TObject);
    procedure lbUrlMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbUrlMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbUrlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure WMNCHitTest(var Message :TWMNCHitTest); message WM_NCHITTEST;
  private
    { Private declarations }
    FDown: Boolean;
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Utils, ShellApi;

{$R *.DFM}

procedure TfrAboutForm.Localize;
begin
  Caption := frLoadStr(frRes + 540);
  Button1.Caption := frLoadStr(SOk);
end;

procedure TfrAboutForm.WMNCHitTest(var Message: TWMNCHitTest);
begin
     inherited;
     if  Message.Result = htClient then
      Message.Result := htCaption;
end;

procedure TfrAboutForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrAboutForm.lbUrlClick(Sender: TObject);
begin
  case TLabel(Sender).Tag of
    1: ShellExecute(GetDesktopWindow, 'open',
       PChar('mailto:' + TLabel(Sender).Caption), nil, nil, sw_ShowNormal);
    2: ShellExecute(GetDesktopWindow, 'open',
       PChar(TLabel(Sender).Caption), nil, nil, sw_ShowNormal);
    3: ShellExecute(GetDesktopWindow, 'open','http://www.fastreport.org/en/aboutvcl.php', nil, nil, sw_ShowNormal);
  end;
end;

procedure TfrAboutForm.lbUrlMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if ssLeft in Shift then
 begin
    with TWinControl(Sender) do
      SetBounds(Left + 1, Top + 1, Width, Height);
    FDown := True;
 end;
end;

procedure TfrAboutForm.lbUrlMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDown then
  begin
    with TWinControl(Sender) do
      SetBounds(Left - 1, Top - 1, Width, Height);
    FDown := False;
  end;
end;

procedure TfrAboutForm.lbUrlMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 with (Sender as TLabel) do
  begin
    Font.Style := [fsUnderline];
  end;
end;

procedure TfrAboutForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  lbUrl.Font.Style := [];
  lbEMail.Font.Style := [];
  lbEMail2.Font.Style := [];
end;

end.

