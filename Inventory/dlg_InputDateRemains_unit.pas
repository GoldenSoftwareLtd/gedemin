unit dlg_InputDateRemains_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, xDateEdits;

type
  Tdlg_InputDateRemains = class(TForm)
    Label1: TLabel;
    xdeDateRemains: TxDateEdit;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlg_InputDateRemains: Tdlg_InputDateRemains;

implementation

{$R *.DFM}

end.
