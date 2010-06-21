unit Bkexec;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xWorld;

type
  TExecuteDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    GroupBox1: TGroupBox;
    OCreate: TRadioButton;
    OExtract: TRadioButton;
    OList: TRadioButton;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExecuteDlg: TExecuteDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TExecuteDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHBackup];
  OCreate.Caption := Phrases[lnPack];
  OExtract.Caption := Phrases[lnExtract];
  OList.Caption := Phrases[lnList];
  GroupBox1.Caption := Phrases[lnOperation];
  GroupBox1.SetFocus;
end;

end.
