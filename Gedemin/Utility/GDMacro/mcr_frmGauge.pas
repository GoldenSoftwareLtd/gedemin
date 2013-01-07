unit mcr_frmGauge;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gauges;

type
  TfrmGauge = class(TForm)
    ggMcr: TGauge;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGauge: TfrmGauge;

implementation

{$R *.DFM}

end.
