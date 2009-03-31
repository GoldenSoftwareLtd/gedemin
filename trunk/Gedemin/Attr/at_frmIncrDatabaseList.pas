unit at_frmIncrDatabaseList;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, gsDBGrid, gsIBGrid, Db, IBCustomDataSet, gdcBase,
  gdcAttrUserDefined, TB2Dock, TB2Toolbar, TB2Item;

type
  TfrmIncrDatabaseList = class(TFrame)
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    gdcDatabases: TgdcAttrUserDefined;
    dsDatabases: TDataSource;
    ibgrDatabases: TgsIBGrid;
    TBItem1: TTBItem;
    TBItem3: TTBItem;
    procedure TBItem3Click(Sender: TObject);
    procedure TBItem1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
                
implementation

uses
  dmImages_unit;

{$R *.DFM}

procedure TfrmIncrDatabaseList.TBItem3Click(Sender: TObject);
begin
  if gdcDatabases.Active then
    gdcDatabases.Insert;
end;

procedure TfrmIncrDatabaseList.TBItem1Click(Sender: TObject);
begin
  if gdcDatabases.Active and (not gdcDatabases.IsEmpty) then
  begin
    if Application.MessageBox('Удалить базу данных из списка?'#13#10 +
       'Это удалит все записи об отправленных на эту базу данных.', 'Внимание!',
       MB_YESNO or MB_ICONWARNING or MB_TOPMOST or MB_SYSTEMMODAL) = IDYES then
      gdcDatabases.Delete;
  end;
end;

end.
