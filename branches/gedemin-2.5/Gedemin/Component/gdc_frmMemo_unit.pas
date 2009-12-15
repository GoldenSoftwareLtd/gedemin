unit gdc_frmMemo_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  Tgdc_frmMemo = class(TForm)
    Memo: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmMemo: Tgdc_frmMemo;

implementation

{$R *.DFM}

end.
