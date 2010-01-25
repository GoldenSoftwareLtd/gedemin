unit Bkprecr;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Spin, xWorld;

type
  TPreCreateDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    GroupBox1: TGroupBox;
    LZW: TRadioButton;
    NoPack: TRadioButton;
    SubDirs: TCheckBox;
    GroupBox2: TGroupBox;
    MemoIn: TMemo;
    GroupBox3: TGroupBox;
    MemoEx: TMemo;
    GroupBox4: TGroupBox;
    VolSize: TSpinEdit;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PreCreateDlg: TPreCreateDlg;

implementation

{$R *.DFM}

uses
  backup;

procedure TPreCreateDlg.FormActivate(Sender: TObject);
begin
  Caption := Phrases[lnHOptions];
  LZW.Caption := Phrases[lnLZW];
  NoPack.Caption := Phrases[lnNoPack];
  SubDirs.Caption := Phrases[lnRecurse];
  GroupBox4.Caption := Phrases[lnVolSize];
  GroupBox2.Caption := Phrases[lnIncludeMask];
  GroupBox3.Caption := Phrases[lnExcludeMask];
  GroupBox1.SetFocus;
end;

end.
