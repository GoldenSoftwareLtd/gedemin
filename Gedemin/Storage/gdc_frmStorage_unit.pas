unit gdc_frmStorage_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, IBCustomDataSet, gdcBase, gdcTree, gdcStorage,
  gsIBLookupComboBox;

type
  Tgdc_frmStorage = class(Tgdc_frmMDVTree)
    gdcStorageFolder: TgdcStorageFolder;
    gdcStorageValue: TgdcStorageValue;
    lkupStorage: TgsIBLookupComboBox;
    TBControlItem1: TTBControlItem;
    actDeleteUnused: TAction;
    TBItem1: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBControlItem2: TTBControlItem;
    lblStorage: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lkupStorageChange(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actDeleteUnusedExecute(Sender: TObject);
    procedure lkupStorageCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
  end;

var
  gdc_frmStorage: Tgdc_frmStorage;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface, IBDatabase, IBSQL;

const
  SelSQL =
    'SELECT s.id FROM gd_storage_data s LEFT JOIN gd_user u ' +
    '  ON u.id = s.int_data ' +
    'WHERE s.parent IS NULL AND s.data_type = ''U'' AND u.id IS NULL ' +
    'UNION ALL ' +
    'SELECT s.id FROM gd_storage_data s LEFT JOIN gd_contact c ' +
    '  ON c.id = s.int_data ' +
    'WHERE s.parent IS NULL AND s.data_type = ''O'' AND c.id IS NULL ' +
    'UNION ALL ' +
    'SELECT s.id FROM gd_storage_data s LEFT JOIN gd_desktop d ' +
    '  ON d.id = s.int_data ' +
    'WHERE s.parent IS NULL AND s.data_type = ''T'' AND d.id IS NULL ';

procedure Tgdc_frmStorage.FormCreate(Sender: TObject);
var
  q: TIBSQL;
begin
  gdcObject := gdcStorageFolder;
  gdcDetailObject := gdcStorageValue;

  inherited;

  lkupStorage.Transaction := gdcBaseManager.ReadTransaction;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT id FROM gd_storage_data WHERE parent IS NULL AND data_type = ''G'' ';
    q.ExecQuery;
    if not q.EOF then
      lkupStorage.CurrentKeyInt := q.Fields[0].AsInteger;

    q.Close;
    q.SQL.Text := SelSQL;
    q.ExecQuery;

    if q.EOF then
      actDeleteUnused.Visible := False
    else begin
      actDeleteUnused.Visible := True;
      actDeleteUnused.Caption := 'Удалить неиспользуемые хранилища...';
    end;
  finally
    q.Free;
  end;
end;

procedure Tgdc_frmStorage.lkupStorageChange(Sender: TObject);
begin
  gdcStorageFolder.Close;
  gdcStorageFolder.ParamByName('Parent').AsInteger := lkupStorage.CurrentKeyInt;
  gdcStorageFolder.Open;
end;

procedure Tgdc_frmStorage.actNewUpdate(Sender: TObject);
begin
  if gdcObject.IsEmpty then
    actNew.Enabled := False
  else
    inherited;
end;

procedure Tgdc_frmStorage.actDeleteUnusedExecute(Sender: TObject);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := Tr;
      q.SQL.Text := 'DELETE FROM gd_storage_data WHERE id IN (' + SelSQL + ')';
      q.ExecQuery;
    finally
      q.Free;
    end;
    Tr.Commit;
  finally
    Tr.Free;
  end;

  lkupStorage.CurrentKeyInt := lkupStorage.CurrentKeyInt;

  actDeleteUnused.Visible := False;
end;

procedure Tgdc_frmStorage.lkupStorageCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
begin
  MessageBox(Handle,
    'Объект хранилища нельзя создать непосредственно.',
    'Внимание',
    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  ANewObject.Cancel;
end;

initialization
  RegisterFrmClass(Tgdc_frmStorage);

finalization
  UnRegisterFrmClass(Tgdc_frmStorage);
end.
