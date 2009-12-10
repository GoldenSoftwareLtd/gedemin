unit xUpPos;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, Gauges,
  xWorld, xProgr;

type
  TProgress = class(TForm)
    OKBtn: TBitBtn;
    Notebook: TNotebook;
    Bevel3: TBevel;
    Label6: TLabel;
    TableName1: TLabel;
    Label8: TLabel;
    Status: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
    Label1: TLabel;
    TableName: TEdit;
    RecNo: TEdit;
    Panel2: TPanel;
    Panel3: TPanel;
    Label5: TLabel;
    TotalErrCount: TLabel;
    TotalWarCount: TLabel;
    Label7: TLabel;
    Panel4: TPanel;
    Label2: TLabel;
    ErrCount: TLabel;
    WarCount: TLabel;
    Label3: TLabel;
    xProgress: TxProgressBar;
    procedure OKBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CanHide: Boolean;
    Continue: Boolean;
  end;

var
  Progress: TProgress;

implementation

{$R *.DFM}

uses
  xUpgrade;

procedure TProgress.OKBtnClick(Sender: TObject);
begin
  if CanHide then
    Visible := false
  else
    if MessageDlg(Phrases[lnTerminateQuery], mtConfirmation,
       [mbYes, mbNo], 0) = mrYes then Continue := false;
end;

procedure TProgress.FormActivate(Sender: TObject);
begin
  Label6.Caption := Phrases[ lnCurrentTable ];
  Label4.Caption := Phrases[ lnCurrentTable ];
  Label1.Caption := Phrases[ lnCurrentRecord ];
  Label2.Caption := Phrases[ lnErrors ];
  Label5.Caption := Phrases[ lnTotalErrors ];
  Label3.Caption := Phrases[ lnWarnings ];
  Label7.Caption := Phrases[ lnTotalWarnings ];
  OkBtn.Caption := Phrases[ lnTerminate ];
  Label8.Caption := Phrases[ lnStatus ];

end;

end.
