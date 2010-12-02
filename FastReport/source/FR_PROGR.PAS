
{******************************************}
{                                          }
{             FastReport v2.54             }
{             Progress dialog              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_progr;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Const, ExtCtrls;

{$IFNDEF Delphi9}
const
  CM_BeforeModal = WM_USER + 1;
{$ENDIF}

type
  TfrProgressForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FDoc: Pointer;
    FOnBeforeModal: TNotifyEvent;
{$IFDEF Delphi9}
    procedure CMBeforeModal(Sender: TObject);
{$ELSE}
    procedure CMBeforeModal(var Message: TMessage); message CM_BeforeModal;
{$ENDIF}
    procedure Localize;
  public
    { Public declarations }
    FirstCaption: String;
{$IFDEF Delphi9}
    Timer: TTimer;
{$ENDIF}
    property OnBeforeModal: TNotifyEvent read FOnBeforeModal write FOnBeforeModal;
    function Show_Modal(Doc: Pointer): Word;
  end;


implementation

uses FR_Class, FR_Utils;

{$R *.DFM}

function TfrProgressForm.Show_Modal(Doc: Pointer): Word;
begin
  Localize;
  FDoc := Doc;
  Label2.Caption := '';
{$IFDEF Delphi9}
  Timer := TTimer.Create(nil);
  Timer.Interval := 200;
  Timer.OnTimer := CMBeforeModal;
  Timer.Enabled := True;
{$ELSE}
  PostMessage(Handle, CM_BeforeModal, 0, 0);
{$ENDIF}
  Result := ShowModal;
{$IFDEF Delphi9}
  Timer.Free;
{$ENDIF}
end;

procedure TfrProgressForm.Button1Click(Sender: TObject);
begin
  TfrReport(FDoc).Terminated := True;
  ModalResult := mrCancel;
end;

{$IFDEF Delphi9}
procedure TfrProgressForm.CMBeforeModal(Sender: TObject);
begin
  Timer.Enabled := False;
  if Assigned(FOnBeforeModal) then
    FOnBeforeModal(Self);
end;
{$ELSE}
procedure TfrProgressForm.CMBeforeModal(var Message: TMessage);
begin
  if Assigned(FOnBeforeModal) then
    FOnBeforeModal(Self);
end;
{$ENDIF}

procedure TfrProgressForm.Localize;
begin
  Button1.Caption := frLoadStr(SCancel);
end;

end.

