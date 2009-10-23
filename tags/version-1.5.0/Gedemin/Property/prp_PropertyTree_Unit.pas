unit prp_PropertyTree_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dockform, ComCtrls, prp_DOCKFORM_unit, Menus, ActnList, ExtCtrls;

type
  Tprp_PropertyTree = class(TDockableForm)
    TreeView1: TTreeView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  prp_PropertyTree: Tprp_PropertyTree;

implementation

{$R *.DFM}

end.
