unit gd_security_dlgSetClassRight_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, ExtCtrls, ComCtrls, TB2Dock, TB2Toolbar;

type
  Tgd_security_dlgSetClassRight = class(TCreateableForm)
    StatusBar1: TStatusBar;
    TBDock1: TTBDock;
    TBDock2: TTBDock;
    TBDock3: TTBDock;
    TBToolbar1: TTBToolbar;
    lvClasses: TListView;
    Splitter1: TSplitter;
    ListView2: TListView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_security_dlgSetClassRight: Tgd_security_dlgSetClassRight;

implementation

{$R *.DFM}

end.
