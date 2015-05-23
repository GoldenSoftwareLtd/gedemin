unit Bksave;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Gauges, ExtCtrls, xWorld;

type
  TSaveDlg = class(TForm)
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    Gauge1: TGauge;
    Label2: TLabel;
    Gauge2: TGauge;
    Bevel2: TBevel;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Terminate: Boolean;
  end;

var
  SaveDlg: TSaveDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TSaveDlg.CancelBtnClick(Sender: TObject);
begin
  Terminate := true;
end;

procedure TSaveDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHCreating];
  Label1.Caption := Phrases[lnCurrentFile];
  Label2.Caption := Phrases[lnTotallyCopied];
  CancelBtn.Caption := Phrases[lnTerminate];
end;

procedure TSaveDlg.FormShow(Sender: TObject);
begin
  Edit1.Text := Phrases[lnScaning];
end;

end.
