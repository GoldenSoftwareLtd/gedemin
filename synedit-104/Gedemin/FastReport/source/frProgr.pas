
{******************************************}
{                                          }
{             FastReport v2.53             }
{                Progress                  }
{         Copyright (c) 1998-2004          }
{           by Fast Reports Inc.           }
{                                          }
{******************************************}

unit frProgr;

interface

{$I fr.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls;

type
  TfrProgress = class(TForm)
    Panel1: TPanel;
    LMessage: TLabel;
    Bar: TProgressBar;
    CancelBtn: TButton;
    procedure WMNCHitTest(var Message :TWMNCHitTest); message WM_NCHITTEST;
    procedure FormCreate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    FTerminated: Boolean;
    FMax: Integer;
    FMin: Integer;
    FPosition: Integer;
    FMessage: String;
    FProgress: Boolean;
    procedure SetPosition(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure SetMin(Value: Integer);
    procedure SetMessage(Value: String);
    procedure SetTerminated(Value: boolean);
    procedure SetProgress(Value: boolean);
  public
    procedure Reset;
    procedure Execute(MaxValue: Integer; Mess: String; Canceled: Boolean; Progress: Boolean);
    procedure Tick;
    procedure ShowMessage(Msg: String);
    property Terminated: Boolean read FTerminated write SetTerminated;
    property Max: Integer read FMax write SetMax;
    property Min: Integer read FMin write SetMin;
    property Position: Integer read FPosition write SetPosition;
    property ShowProgress: Boolean read FProgress write SetProgress;
    property Message: String read FMessage write SetMessage;
  end;

implementation

{$R *.DFM}

procedure TfrProgress.WMNCHitTest(var Message: TWMNCHitTest);
begin
  inherited;
  if Message.Result = htClient then
    Message.Result := htCaption;
end;

procedure TfrProgress.FormCreate(Sender: TObject);
begin
  Min := 0;
  Max := 100;
  Position := 0;
end;

procedure TfrProgress.Reset;
begin
  Position := Min;
end;

procedure TfrProgress.SetPosition(Value: Integer);
begin
  FPosition := Value;
  Bar.Position := Value;
  BringToFront;
  Application.ProcessMessages;
end;

procedure TfrProgress.SetMax(Value: Integer);
begin
  FMax := Value;
  Bar.Max := Value;
end;

procedure TfrProgress.SetMin(Value: Integer);
begin
  FMin := Value;
  Bar.Min := Value;
end;

procedure TfrProgress.Execute(MaxValue: Integer; Mess: String; Canceled: Boolean; Progress: Boolean);
begin
  Terminated := False;
  CancelBtn.Visible := Canceled;
  ShowProgress := Progress;
  Reset;
  Max := MaxValue;
  Message := Mess;
  Show;
  Application.ProcessMessages;
end;

procedure TfrProgress.Tick;
begin
  Position := Position + 1;
end;

procedure TfrProgress.SetMessage(Value: String);
begin
  FMessage := Value;
  LMessage.Caption := Value;
  LMessage.Refresh;
end;

procedure TfrProgress.CancelBtnClick(Sender: TObject);
begin
  Terminated := True;
end;

procedure TfrProgress.SetTerminated(Value: boolean);
begin
  FTerminated := Value;
  if Value then Close;
end;

procedure TfrProgress.SetProgress(Value: boolean);
begin
  Bar.Visible := Value;
  FProgress := Value;
  if Value then
    LMessage.Top := 15
  else
    LMessage.Top := 35;
end;

procedure TfrProgress.ShowMessage(Msg: String);
begin
  Message := Msg;
end;

end.
