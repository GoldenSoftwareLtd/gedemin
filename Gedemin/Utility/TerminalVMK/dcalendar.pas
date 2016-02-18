unit DCalendar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtDlgs,
  EditBtn, StdCtrls, LMessages, Calendar, Windows, ProjectCommon;

type

  { TDCalendar }

  TDCalendar = class(TForm)
    Calendar1: TCalendar;
    lInfo: TLabel;
  procedure FormCreate(Sender: TObject);
  procedure FormShow(Sender: TObject);
  procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
     FData: TDateTime;
  public
    { public declarations }
   class function Execute3: Boolean;
   procedure Enter;
   procedure SetDate;
  // property Data: TDateTime read FData write FData;
  end;

{var
  DCalendar: TDCalendar;  }

implementation

{$R *.lfm}
{ TDCalendar }

procedure TDCalendar.FormCreate(Sender: TObject);
begin
  inherited;
  BorderStyle := bsNone;
  WindowState := wsNormal;
  Calendar1.DateTime := date;
end;

class function TDCalendar.Execute3: boolean;

begin
  with TDCalendar.Create(nil) do
  try
    Result := ShowModal = mrOk;
    if Result then
      begin
        SetDate;
      end;
  finally
    Free;
  end;
end;

procedure TDCalendar.Enter;
begin
    FData := Calendar1.DateTime;
    ModalResult := mrOk;
end;

procedure TDCalendar.SetDate;
var  win_time: tsystemtime;
begin
   DateTimeToSystemTime(FData, win_time);
   SetSystemTime(win_time);
end;

procedure TDCalendar.FormShow(Sender: TObject);
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

procedure TDCalendar.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: Enter;
    VK_ESCAPE: ModalResult := mrCancel;
  end;
end;



end.

