unit Xrtffff;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Grids, ExtCtrls;

type
  TxRTFFFForm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Grid: TStringGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  xRTFFFForm: TxRTFFFForm;

implementation

{$R *.DFM}

end.
