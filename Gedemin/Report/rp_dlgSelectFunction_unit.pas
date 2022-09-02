// ShlTanya, 27.02.2019

unit rp_dlgSelectFunction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, ImgList, ComCtrls, ToolWin, ExtCtrls, Db, IBCustomDataSet,
  IBQuery;

type
  TdlgSelectFunction = class(TForm)
    pnlTop: TPanel;
    pnlCenter: TPanel;
    ListView3: TListView;
    IBQuery1: TIBQuery;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton9: TToolButton;
    TreeView1: TTreeView;
    ImageList1: TImageList;
    ActionList1: TActionList;
    actAddFunction: TAction;
    actEditFunction: TAction;
    actDelFunction: TAction;
    actMoveLeft: TAction;
    actMoveRigth: TAction;
    ToolButton8: TToolButton;
    IBQuery2: TIBQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgSelectFunction: TdlgSelectFunction;

implementation

{$R *.DFM}

end.
