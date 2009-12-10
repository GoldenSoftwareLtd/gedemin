

{ MasterDetail Horz layout }

unit gd_frmMDV_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, ToolWin, dmImages_unit, ActnList, 
  gd_frmMDH_unit, StdCtrls, Menus, flt_sqlFilter, Db, IBCustomDataSet,
  IBDatabase,  gsReportManager, gdcBase, gdcConst;

type
  Tgd_frmMDV = class(Tgd_frmMDH)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_frmMDV: Tgd_frmMDV;

implementation

{$R *.DFM}

end.
