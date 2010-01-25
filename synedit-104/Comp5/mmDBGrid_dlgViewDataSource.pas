
unit mmDBGrid_dlgViewDataSource;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, mBitButton, mmCheckBoxEx, gsMultilingualSupport;

type
  TdlgViewDataSource = class(TForm)
    chbxEditSQL: TmmCheckBoxEx;
    btnOk: TmBitButton;
    Panel1: TPanel;
    Memo: TMemo;
    gsMultilingualSupport1: TgsMultilingualSupport;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgViewDataSource: TdlgViewDataSource;

implementation

{$R *.DFM}

initialization
  dlgViewDataSource := nil;
end.
