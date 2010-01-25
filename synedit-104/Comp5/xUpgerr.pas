unit Xupgerr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, xYellabl, xBulbBtn, xStrList;

type
  TfrmErrorUpgrade = class(TForm)
    xylErrorInfo: TxYellowLabel;
    xBulbButton1: TxBulbButton;
    xStrList: TxStrList;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  frmErrorUpgrade: TfrmErrorUpgrade;

implementation

{$R *.DFM}

end.
