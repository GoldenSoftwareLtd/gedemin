unit gd_dlgEditMemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, ActnList, Grids;

type
  TdlgEditMemo = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Memo: TMemo;
  private
  public
  end;

var
  dlgEditMemo: TdlgEditMemo;

implementation

{$R *.DFM}

end.
