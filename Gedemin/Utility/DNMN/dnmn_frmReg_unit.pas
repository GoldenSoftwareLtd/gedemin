unit dnmn_frmReg_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  Tdnmn_frmReg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edCode: TEdit;
    Label3: TLabel;
    Button1: TButton;
    m: TMemo;
  private                  
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dnmn_frmReg: Tdnmn_frmReg;

implementation

{$R *.DFM}

end.                                              
