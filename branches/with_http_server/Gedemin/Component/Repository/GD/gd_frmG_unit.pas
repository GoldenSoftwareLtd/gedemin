

{ generic form }

unit gd_frmG_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, ComCtrls,  dmImages_unit, ActnList,
  ToolWin, ExtCtrls, StdCtrls, Menus, flt_sqlFilter, Db, IBCustomDataSet,
  IBDatabase,  gsReportManager;

type
  Tgd_frmG = class(TCreateableForm)
    sbMain: TStatusBar;
    alMain: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actDuplicate: TAction;
    actFilter: TAction;
    pnlMain: TPanel;
    cbMain: TControlBar;
    tbMain: TToolBar;
    tbtNew: TToolButton;
    tbtEdit: TToolButton;
    tbtDelete: TToolButton;
    tbtDuplicate: TToolButton;
    tbtFilter: TToolButton;
    actHlp: TAction;
    tbHlp: TToolButton;
    tbnSpace7: TToolButton;
    actPrint: TAction;
    tbtPrint: TToolButton;
    pmMainReport: TPopupMenu;
    pmMain: TPopupMenu;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    tbtCopy: TToolButton;
    tbtCut: TToolButton;
    tbtPaste: TToolButton;
    tbnSpace5: TToolButton;
    tbnSpace6: TToolButton;
    actCopy1: TMenuItem;
    actCut1: TMenuItem;
    actPaste1: TMenuItem;
    actUnDo: TAction;
    tbtUnDo: TToolButton;
    tbnSpace1: TToolButton;
    MainMenu: TMainMenu;
    mN1: TMenuItem;
    mN2: TMenuItem;
    procedure actFilterExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_frmG: Tgd_frmG;

implementation

{$R *.DFM}

procedure Tgd_frmG.actFilterExecute(Sender: TObject);
begin
  //...
end;

procedure Tgd_frmG.actPrintExecute(Sender: TObject);
begin
  //...
end;

end.
