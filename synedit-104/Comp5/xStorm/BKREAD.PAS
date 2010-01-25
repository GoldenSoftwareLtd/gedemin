unit BkRead;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Gauges, ExtCtrls, xWorld;

type
  TReadDlg = class(TForm)
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    Gauge1: TGauge;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Terminate: Boolean;
  end;

var
  ReadDlg: TReadDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TReadDlg.CancelBtnClick(Sender: TObject);
begin
  Terminate := true;
end;

procedure TReadDlg.FormActivate(Sender: TObject);
begin
  Label1.Caption := Phrases[lnCurrentFile];
  Edit1.Text := Phrases[lnReading];
  CancelBtn.Caption := Phrases[lnTerminate];
end;

end.
