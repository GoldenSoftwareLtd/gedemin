unit flt_msgBeforeFilter_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TmsgBeforeFilter = class(TForm)
    cbVisible: TCheckBox;
    btnClose: TButton;
    mmText: TMemo;
    Image1: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  msgBeforeFilter: TmsgBeforeFilter;

implementation

{$R *.DFM}

end.
