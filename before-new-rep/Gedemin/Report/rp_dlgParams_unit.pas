unit rp_dlgParams_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgParams = class(TForm)
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgParams: TdlgParams;

implementation

{$R *.DFM}

end.
