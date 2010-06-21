unit flt_msgShowMessage_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls;

type
  TmsgShowMessage = class(TForm)
    Label1: TLabel;
    Animate1: TAnimate;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  msgShowMessage: TmsgShowMessage;

implementation

{$R *.DFM}

end.
