{
  Индикатор прохождения какого либо процесса
}

unit frmRunningBoy_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, xProgr, StdCtrls;

type
  TfrmRunningBoy = class(TForm)
    lblName: TLabel;
    xRunMan: TxRunningMan;
  private
  public
  end;

var
  frmRunningBoy: TfrmRunningBoy;

implementation

{$R *.DFM}

end.
