
unit dlgAnalyzeOperation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, xBulbBtn, ExtCtrls, gsMultilingualSupport;

type
  TfrmReturnAddress2 = class(TForm)
    btnOk: TxBulbButton;
    btnCancel: TxBulbButton;
    memReturnAddress: TMemo;
    gsMultilingualSupport1: TgsMultilingualSupport;
  end;

var
  frmReturnAddress2: TfrmReturnAddress2;

implementation

{$R *.DFM}

end.

