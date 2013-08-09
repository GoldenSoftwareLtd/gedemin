unit gdcNamescapeController;

interface

uses
  IBDatabase, IBCustomDataSet, gdcBase, DBGrids;

type
  TgdcNamespaceController = class(TObject)
  private
    FIBTransaction: TIBTransaction;
    FibdsLink: TIBDataSet;
    FgdcObject: TgdcBase;
    FPrevNSID: Integer;
    FSessionID: Integer;
    FAlwaysOverwrite: Boolean;
    FDontRemove: Boolean;
    FIncludeSiblings: Boolean;
    FObjectName: String;

  public
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcObject; ABL: TBookmarkList);
  end;

implementation

uses
  IBSQL, gdcBaseInterface;

{ TgdcNamespaceController }

destructor TgdcNamespaceController.Destroy;
begin
  FibdsLink.Free;
  FIBTransaction.Free;
  inherited;
end;

procedure TgdcNamespaceController.Setup(AnObject: TgdcObject;
  ABL: TBookmarkList);
var
  q: TIBSQL;
  I: Integer;
  Bm: String;
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.EOF);
  Assert(FIBTransaction = nil);
  Assert(FibdsLink = nil);
  Assert(gdcBaseManager <> nil);

  FIBTransaction := TIBTransaction.Create(nil);
  FIBTransaction.Params.CommaText := 'read_committed,rec_version,nowait';
  FIBTransaction.DefaultDatabase := gdcBaseManager.Database;
  FIBTransaction.StartTransaction;

  FibdsLink := TIBDataSet.Create(nil);
  FibdsLink.ReadTransaction := FIBTransaction;
  FibdsLink.Transaction := FIBTransaction;
  FibdsLink.SelectSQL.Text :=
    'SELECT '#13#10 +
    '  od.refobjectid as id, '#13#10 +
    '  r.xid as xid, '#13#10 +
    '  r.dbid as dbid, '#13#10 +
    '  od.reflevel, '#13#10 +
    '  (od.refclassname || od.refsubtype || '' - '' || od.refobjectname || '#13#10 +
    '    iif(n.id IS NULL, '''', '' ('' || n.name || '')'')) as displayname, '#13#10 +
    '  od.refsubtype as subtype, '#13#10 +
    '  od.refobjectname as name, '#13#10 +
    '  n.name as namespace, '#13#10 +
    '  n.id as namespacekey, '#13#10 +
    '  o.headobjectkey as headobject, '#13#10 +
    '  od.refeditiondate as editiondate '#13#10 +
    'FROM '#13#10 +
    '  gd_object_dependencies od '#13#10 +
    '  LEFT JOIN gd_p_getruid(od.refobjectid) r '#13#10 +
    '    ON 1=1 '#13#10 +
    '  LEFT JOIN at_object o '#13#10 +
    '    ON o.xid = r.xid AND o.dbid = r.dbid '#13#10 +
    '  LEFT JOIN at_namespace n '#13#10 +
    '    ON n.id = o.namespacekey '#13#10 +
    'WHERE '#13#10 +
    '  od.sessionid = :sid ';

  FPrevNSID := -1;
  FgdcObject := AnObject;
  FBL := BL;

  if FBL <> nil then
  begin
    FBL.Refresh;
    if FBL.Count = 0 then
      FBL := nil;
  end;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FIBTransaction;
    q.SQL.Text :=
      'SELECT n.id, o.alwaysoverwrite, o.dontremove, o.includesiblings ' +
      'FROM at_object o JOIN at_namespace n ON n.id = o.namespacekey ' +
      'WHERE o.xid = :xid AND o.dbid = :dbid';
    q.ParamByName('xid').AsInteger := FgdcObject.GetRuid.XID;
    q.ParamByName('dbid').AsInteger := FgdcObject.GetRuid.DBID;
    q.ExecQuery;

    if not q.EOF then
    begin
      FPrevNSID := q.FieldByName('id').AsInteger;
      FAlwaysOverwrite := q.FieldByName('alwaysoverwrite').AsInteger <> 0;
      FDontRemove := q.FieldByName('dontremove').AsInteger <> 0;
      FIncludeSiblings := q.FieldByName('includesiblings').AsInteger <> 0;
    end;
  finally
    q.Free;
  end;

  FSessionID := AnObject.GetNextID;

  if (FgdcObject.State in [dsEdit, dsInsert]) or (FBL = nil) or (FBL.Count = 0) then
    FgdcObject.GetDependencies(FIBTransaction, FSessionID, False, ';EDITORKEY;CREATORKEY;')
  else begin
    FgdcObject.DisableControls;
    try
      Bm := FgdcObject.Bookmark;
      for I := 0 to FBL.Count - 1 do
      begin
        FgdcObject.Bookmark := FBL[I];
        FgdcObject.GetDependencies(FIBTransaction, FSessionID, False, ';EDITORKEY;CREATORKEY;');
      end;
      FgdcObject.Bookmark := Bm;
    finally
      FgdcObject.EnableControls;
    end;
  end;

  FibdsLink.ParamByName('sid').AsInteger := FSessionID;
  FibdsLink.Open;

  FibdsLink.FieldByName('id').Visible := False;
  FibdsLink.FieldByName('reflevel').Visible := False;
  FibdsLink.FieldByName('class').Visible := False;
  FibdsLink.FieldByName('subtype').Visible := False;
  FibdsLink.FieldByName('name').Visible := False;
  FibdsLink.FieldByName('namespacekey').Visible := False;
  FibdsLink.FieldByName('namespace').Visible := False;
  FibdsLink.FieldByName('headobject').Visible := False;
  FibdsLink.FieldByName('editiondate').Visible := False;
  FibdsLink.FieldByName('displayname').DisplayLabel := 'Класс - Имя объекта (Пространство имен)';

  FObjectName := FgdcObject.ObjectName + ' ('
    + FgdcObject.GetDisplayName(FgdcObject.SubType) + ')';
  if (FBL <> nil) and (FBL.Count > 1) then
    FObjectName := FObjectName + ' и еще ' +
      IntToStr(FBL.Count - 1) + ' объект(а, ов)';
end;

end.