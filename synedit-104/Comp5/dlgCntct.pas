
{ v. 1.00 21-May-99 }
{ v. 1.01 22-May-99 }
{ v. 1.02 06-Dec-00 }

unit Dlgcntct;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, xLCDLbl, ExtCtrls, StdCtrls, xBulbBtn;

type
  TdlgContactInformation = class(TForm)
    Memo: TMemo;
    Image: TImage;
    Timer: TTimer;
    xbbClose: TxBulbButton;
    Shape: TShape;
    Panel1: TPanel;
    xLCDLabel: TxLCDLabel;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure xbbCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowContactInformation(Owner: TComponent; const AColor: TColor = clBtnFace);

var
  dlgContactInformation: TdlgContactInformation;

implementation

{$R *.DFM}

procedure ShowContactInformation(Owner: TComponent; const AColor: TColor = clBtnFace);
begin
  with TdlgContactInformation.Create(Owner) do
  try
    Color := AColor;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TdlgContactInformation.TimerTimer(Sender: TObject);
begin
  xLCDLabel.RelMove(2);
end;

procedure TdlgContactInformation.FormCreate(Sender: TObject);
begin
  Randomize;
  case Random(10) of
    0: xLCDLabel.ChangeColors([clLime], [clYellow]);
    1: xLCDLabel.ChangeColors([clLime], [$9090FF]);
    2: xLCDLabel.ChangeColors([clLime], [clAqua]);
    3: xLCDLabel.ChangeColors([clLime], [$FF9090]);
    4: xLCDLabel.ChangeColors([clLime], [clFuchsia]);
    5: xLCDLabel.ChangeColors([clLime], [clWhite]);
  else
    ;
  end;

end;

procedure TdlgContactInformation.xbbCloseClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
