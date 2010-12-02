

{ MasterDetail Horz layout }

unit gd_frmMDH_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, ToolWin, dmImages_unit, ActnList,
  gd_frmG_unit, StdCtrls, Menus, flt_sqlFilter, Db, IBCustomDataSet,
  IBDatabase,  gsReportManager, gdcBase, gdcConst;

type
  Tgd_frmMDH = class(Tgd_frmG)
    splMain: TSplitter;
    pnlDetail: TPanel;
    cbDetail: TControlBar;
    tbDetail: TToolBar;
    tbtNewDetail: TToolButton;
    tbtEditDetail: TToolButton;
    tbtDeleteDetail: TToolButton;
    tbtDuplicateDetail: TToolButton;
    tbtFilterDetail: TToolButton;
    actNewDetail: TAction;
    actEditDetail: TAction;
    actDeleteDetail: TAction;
    actDuplicateDetail: TAction;
    actFilterDetail: TAction;
    tbtPrintDetail: TToolButton;
    actPrintDetail: TAction;
    pmDetailReport: TPopupMenu;
    pmDetail: TPopupMenu;
    actCopyDetail: TAction;
    actCutDetail: TAction;
    actPasteDetail: TAction;
    tbtCopyDetail: TToolButton;
    tbtCutDetail: TToolButton;
    tbtPasteDetail: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure actPrintDetailExecute(Sender: TObject);
  end;

var
  gd_frmMDH: Tgd_frmMDH;

implementation

{$R *.DFM}

procedure Tgd_frmMDH.actPrintDetailExecute(Sender: TObject);
begin
  //...
end;

end.
