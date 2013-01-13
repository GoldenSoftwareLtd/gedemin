unit at_frmSyncNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, gd_createable_form, TB2ExtItems, TB2Item, ActnList, Db,
  Grids, DBGrids, gsDBGrid, TB2Dock, TB2Toolbar, ComCtrls, DBClient,
  StdCtrls;

type
  Tat_frmSyncNamespace = class(TCreateableForm)
    cds: TClientDataSet;
    ds: TDataSource;
    sb: TStatusBar;
    TBDock: TTBDock;
    TBToolbar: TTBToolbar;
    gsDBGrid1: TgsDBGrid;
    cdsNamespacekey: TIntegerField;
    cdsNamespaceName: TStringField;
    cdsNamespaceVersion: TStringField;
    cdsNamespaceTimeStamp: TDateTimeField;
    cdsOperation: TStringField;
    cdsFileName: TStringField;
    cdsFileTimeStamp: TDateTimeField;
    cdsFileVersion: TStringField;
    cdsFileSize: TIntegerField;
    ActionList: TActionList;
    actChooseDir: TAction;
    TBItem1: TTBItem;
    tbedPath: TTBEditItem;
    actCompare: TAction;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    cdsFileName2: TStringField;
    TBSeparatorItem2: TTBSeparatorItem;
    tbedName: TTBEditItem;
    TBControlItem1: TTBControlItem;
    Label1: TLabel;
    procedure actChooseDirExecute(Sender: TObject);
    procedure actCompareUpdate(Sender: TObject);
    procedure actCompareExecute(Sender: TObject);
    procedure cdsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  at_frmSyncNamespace: Tat_frmSyncNamespace;

implementation

{$R *.DFM}

uses
  FileCtrl, gdcNamespace;

procedure Tat_frmSyncNamespace.actChooseDirExecute(Sender: TObject);
var
  Dir: String;
begin
  if SelectDirectory('Корневая папка с файлами пространств имен:', '', Dir) then
  begin
    tbedPath.Text := Dir;
  end;
end;

procedure Tat_frmSyncNamespace.actCompareUpdate(Sender: TObject);
begin
  actCompare.Enabled := DirectoryExists(tbedPath.Text);
end;

procedure Tat_frmSyncNamespace.actCompareExecute(Sender: TObject);
begin
  cds.EmptyDataSet;
  TgdcNamespace.ScanDirectory(cds, tbedPath.Text);
end;

procedure Tat_frmSyncNamespace.cdsFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept := True;
end;

initialization
  RegisterClass(Tat_frmSyncNamespace);

finalization
  UnRegisterClass(Tat_frmSyncNamespace);
end.
