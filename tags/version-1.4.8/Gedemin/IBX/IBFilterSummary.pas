{*******************************************************
 Classes:     TIBFilterDialog, TfrmIBFilterDialog,
              TIBFieldInfo, TIBVariable
 Created      9/1998.
 Author:      Jeffrey P Overcash
 CopyRight:   Jeffrey P Overcash 1998 all rights reserved
 Description: This is a filter dialog component that allows the runtime
              Filtering of IBDataSet's.

 Version:     1.0.0.40 beta
 Status:      FreeWare
 Disclaimer:  This is provided as is, expressly without a
              warranty of any kind.
              You use it at your own risc.

 *******************************************************}
 
unit IBFilterSummary;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls;

type
  TfrmIBFilterSummary = class(TForm)
    lstSummary: TListView;
    btnOk: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

end.
