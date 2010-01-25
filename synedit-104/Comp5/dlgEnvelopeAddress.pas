
unit dlgEnvelopeAddress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, xBulbBtn, ExtCtrls, gsMultilingualSupport;

type
  TfrmReturnAddress = class(TForm)
    btnOk: TxBulbButton;
    btnCancel: TxBulbButton;
    memReturnAddress: TMemo;
    gsMultilingualSupport1: TgsMultilingualSupport;
  end;

var
  frmReturnAddress: TfrmReturnAddress;

implementation

{$R *.DFM}

end.

