{
  Form file for RTF files viewing components (xRTF unit).
  Copyright c) 1996 - 97 by Golden Software
  Author: Vladimir Belyi
}

unit xRTFPrgF;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, xProgr, ExtCtrls, Buttons, xMemo, xWorld,
  xBulbBtn, xYellabl, gsMultilingualSupport;

type
  TRTFProgress = class(TForm)
    xWorld1: TxWorld;
    TerminateBtn: TxBulbButton;
    Progress: TxProgressBar;
    ProgressLabel: TLabel;
    Comment: TxYellowLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    TerminateQuestion: string;
    DefaultProgressStr: string;

    UpdateStep: Integer;
    LastValue: Integer;

    openingDepth: Integer;
  public
    { Public declarations }
    Terminated: Boolean;

    procedure Start(AComment: string; AProgressStr: string;
      ATerminateQuestion: string; MaxValue: Integer);
    procedure Update(Value: Integer; const ProgressStr: string); reintroduce;
    procedure Stop;
    procedure UpdateMaxValue(NewMaxValue: Integer);
  end;

var
  RTFProgress: TRTFProgress;

implementation

uses
  xRTFSubs;

{$R *.DFM}

procedure TRTFProgress.Button1Click(Sender: TObject);
begin
  if MessageDlg( TerminateQuestion,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
   Terminated := true;
end;

procedure TRTFProgress.FormCreate(Sender: TObject);
begin
  Terminated := false;
  OpeningDepth := 0;
end;

procedure TRTFProgress.Start(AComment: string; AProgressStr: string;
  ATerminateQuestion: string; MaxValue: Integer);
begin
  AComment := TranslateText(AComment);
  ATerminateQuestion := TranslateText(ATerminateQuestion);
  AProgressStr := TranslateText(AProgressStr);
  inc(OpeningDepth);
  if OpeningDepth = 1 then
    Show;

  Comment.Caption := AComment;
  DefaultProgressStr := AProgressStr;
  ProgressLabel.Caption := DefaultProgressStr;

  TerminateQuestion := ATerminateQuestion;
  TerminateBtn.Enabled := Trim(TerminateQuestion) <> '';

  UpdateMaxValue(MaxValue);
end;

procedure TRTFProgress.UpdateMaxValue(NewMaxValue: Integer);
begin
  Progress.Max := NewMaxValue;
  Progress.Min := 0;
  Progress.Value := 0;

  UpdateStep := NewMaxValue div 20;
  LastValue := 0;
end;

procedure TRTFProgress.Update(Value: Integer; const ProgressStr: string);
begin
  if Value - LastValue >= UpdateStep then
   begin
     if ProgressStr <> '' then
       ProgressLabel.Caption := ProgressStr;
     Progress.Value := Value;
     LastValue := Value;

     Application.ProcessMessages;
   end;
end;

procedure TRTFProgress.Stop;
begin
  dec(OpeningDepth);
  if OpeningDepth = 0 then hide;
  if OpeningDepth < 0 then
    raise ExRTF.create('wrong command');
  Terminated := false;
end;

initialization
  RTFProgress := TRTFProgress.Create(nil);

finalization
  RTFProgress.Free;

end.
