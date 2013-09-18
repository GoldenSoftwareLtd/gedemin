unit gdcNamespaceController;

interface

uses
  DB, IBDatabase, IBCustomDataSet, gdcBase, DBGrids;

type
  TgdcNamespaceController = class(TObject)
  private
    FIBTransaction: TIBTransaction;
    FibdsLink: TIBDataSet;
    FgdcObject: TgdcBase;
    FBL: TBookmarkList;
    FPrevNSID: Integer;
    FCurrentNSID: Integer;
    FAlwaysOverwrite: Boolean;
    FDontRemove: Boolean;
    FIncludeSiblings: Boolean;
    FIncludeLinked: Boolean;
    FObjectName: String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    procedure Include;

    property ObjectName: String read FObjectName;
    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
    property IncludeSiblings: Boolean read FIncludeSiblings write FIncludeSiblings;
    property IncludeLinked: Boolean read FIncludeLinked write FIncludeLinked;
    property PrevNSID: Integer read FPrevNSID write FPrevNSID;
    property CurrentNSID: Integer read FCurrentNSID write FCurrentNSID;
    property ibdsLink: TIBDataSet read FibdsLink;
  end;

implementation

uses
  SysUtils, IBSQL, gdcBaseInterface, gdcNamespace;

{ TgdcNamespaceController }

constructor TgdcNamespaceController.Create;
begin
  inherited;

  FPrevNSID := -1;
  FCurrentNSID := -1;
  FIncludeLinked := True;

  FIBTransaction := TIBTransaction.Create(nil);
  FIBTransaction.Params.CommaText := 'read_committed,rec_version,nowait';
  FIBTransaction.DefaultDatabase := gdcBaseManager.Database;
  FIBTransaction.StartTransaction;

  FibdsLink := TIBDataSet.Create(nil);
  FibdsLink.ReadTransaction := FIBTransaction;
  FibdsLink.Transaction := FIBTransaction;
  FibdsLink.SelectSQL.Text :=
    'SELECT DISTINCT '#13#10 +
    '  od.refobjectid as id, '#13#10 +
    '  r.xid as xid, '#13#10 +
    '  r.dbid as dbid, '#13#10 +
    '  od.reflevel, '#13#10 +
    '  (od.refclassname || od.refsubtype || '' - '' || od.refobjectname || '#13#10 +
    '    iif(n.id IS NULL, '''', '' ('' || n.name || '')'')) as displayname, '#13#10 +
    '  od.refclassname as class, '#13#10 +
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
    '  od.sessionid = :sid '#13#10 +
    'ORDER BY '#13#10 +
    '  od.reflevel DESC';
end;

destructor TgdcNamespaceController.Destroy;
begin
  FibdsLink.Free;
  FIBTransaction.Free;
  inherited;
end;

procedure TgdcNamespaceController.Include;
var
  gdcNamespaceObject: TgdcNamespaceObject;
  HeadObjectKey, HeadObjectPos: Integer;
  q: TIBSQL;
begin
  Assert(FIBTransaction.InTransaction);

  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  try
    gdcNamespaceObject.ReadTransaction := FIBTransaction;
    gdcNamespaceObject.Transaction := FIBTransaction;

    if (FPrevNSID > -1) and (FCurrentNSID = -1) then
    begin
      gdcNamespaceObject.SubSet := 'ByObject';
      gdcNamespaceObject.ParamByName('namespacekey').AsInteger := FPrevNSID;
      gdcNamespaceObject.ParamByName('xid').AsInteger := FgdcObject.GetRUID.XID;
      gdcNamespaceObject.ParamByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
      gdcNamespaceObject.Open;
      if not gdcNamespaceObject.EOF then
        gdcNamespaceObject.Delete;
    end
    else if (FPrevNSID > -1) and (FCurrentNSID > -1)
      and (FPrevNSID <> FCurrentNSID) then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := FIBTransaction;
        q.SQL.Text :=
          'SELECT o.id FROM at_object o ' +
          'WHERE o.namespacekey = :nk and o.xid = :xid and o.dbid = :dbid';
        q.ParamByName('nk').AsInteger := FCurrentNSID;
        q.ParamByName('xid').AsInteger := FgdcObject.GetRUID.XID;
        q.ParamByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
        q.ExecQuery;

        if q.EOF then
        begin
          gdcNamespaceObject.SubSet := 'ByObject';
          gdcNamespaceObject.ParamByName('namespacekey').AsInteger := FPrevNSID;
          gdcNamespaceObject.ParamByName('xid').AsInteger := FgdcObject.GetRUID.XID;
          gdcNamespaceObject.ParamByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
          gdcNamespaceObject.Open;
          if not gdcNamespaceObject.EOF then
          begin
            gdcNamespaceObject.Edit;
            gdcNamespaceObject.FieldByName('namespacekey').AsInteger := FCurrentNSID;
            gdcNamespaceObject.Post;
          end;
        end;
      finally
        q.Free;
      end;
    end
    else if (FPrevNSID = -1) and (FCurrentNSID > -1) then
    begin
      gdcNamespaceObject.SubSet := 'All';
      gdcNamespaceObject.Open;
      gdcNamespaceObject.Insert;
      gdcNamespaceObject.FieldByName('namespacekey').AsInteger := FCurrentNSID;
      gdcNamespaceObject.FieldByName('objectname').AsString := FgdcObject.ObjectName;
      gdcNamespaceObject.FieldByName('objectclass').AsString := FgdcObject.GetCurrRecordClass.gdClass.ClassName;
      gdcNamespaceObject.FieldByName('subtype').AsString := FgdcObject.GetCurrRecordClass.SubType;
      gdcNamespaceObject.FieldByName('xid').AsInteger := FgdcObject.GetRUID.XID;
      gdcNamespaceObject.FieldByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
      gdcNamespaceObject.FieldByName('objectpos').Clear;
      if FAlwaysOverwrite then
        gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 1
      else
        gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 0;
      if FDontRemove then
        gdcNamespaceObject.FieldByName('dontremove').AsInteger := 1
      else
        gdcNamespaceObject.FieldByName('dontremove').AsInteger := 0;
      if FIncludeSiblings then
        gdcNamespaceObject.FieldByName('includesiblings').AsInteger := 1
      else
        gdcNamespaceObject.FieldByName('includesiblings').AsInteger := 0;
      gdcNamespaceObject.FieldByName('headobjectkey').Clear;
      if FgdcObject.FindField('editiondate') <> nil then
      begin
        gdcNamespaceObject.FieldByName('modified').AsDateTime :=
          FgdcObject.FieldByName('editiondate').AsDateTime;
        gdcNamespaceObject.FieldByName('curr_modified').AsDateTime :=
          FgdcObject.FieldByName('editiondate').AsDateTime;
      end else
      begin
        gdcNamespaceObject.FieldByName('modified').AsDateTime := Now;
        gdcNamespaceObject.FieldByName('curr_modified').AsDateTime := Now;
      end;
      gdcNamespaceObject.Post;

      if FIncludeLinked then
      begin
        HeadObjectKey := gdcNamespaceObject.ID;
        HeadObjectPos := gdcNamespaceObject.FieldByName('objectpos').AsInteger;

        FibdsLink.Close;
        FibdsLink.Open;

        q := TIBSQL.Create(nil);
        try
          q.Transaction := FIBTransaction;
          q.SQL.Text :=
            'UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey) ' +
            '  VALUES (:nsk, :uk) ' +
            '  MATCHING (namespacekey, useskey) ';
          q.ParamByName('nsk').AsInteger := FCurrentNSID;

          FibdsLink.Last;
          while not FibdsLink.BOF do
          begin
            if FibdsLink.FieldByName('namespacekey').IsNull then
            begin
              if Pos('RDB$', FibdsLink.FieldByName('name').AsString) <> 1 then
              begin
                gdcNamespaceObject.Insert;
                gdcNamespaceObject.FieldByName('namespacekey').AsInteger := FCurrentNSID;
                gdcNamespaceObject.FieldByName('objectname').AsString := FibdsLink.FieldByName('name').AsString;
                gdcNamespaceObject.FieldByName('objectclass').AsString := FibdsLink.FieldByName('class').AsString;
                gdcNamespaceObject.FieldByName('subtype').AsString := FibdsLink.FieldByName('subtype').AsString;
                gdcNamespaceObject.FieldByName('xid').AsInteger := FibdsLink.FieldByName('xid').AsInteger;
                gdcNamespaceObject.FieldByName('dbid').AsInteger := FibdsLink.FieldByName('dbid').AsInteger;
                gdcNamespaceObject.FieldByName('objectpos').AsInteger := HeadObjectPos;
                if FAlwaysOverwrite then
                  gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 1
                else
                  gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 0;
                if FDontRemove then
                  gdcNamespaceObject.FieldByName('dontremove').AsInteger := 1
                else
                  gdcNamespaceObject.FieldByName('dontremove').AsInteger := 0;
                if FIncludeSiblings then
                  gdcNamespaceObject.FieldByName('includesiblings').AsInteger := 1
                else
                  gdcNamespaceObject.FieldByName('includesiblings').AsInteger := 0;
                gdcNamespaceObject.FieldByName('headobjectkey').AsInteger := HeadObjectKey;
                if FibdsLink.FieldByName('editiondate').IsNull then
                begin
                  gdcNamespaceObject.FieldByName('modified').AsDateTime := Now;
                  gdcNamespaceObject.FieldByName('curr_modified').AsDateTime := Now;
                end else
                begin
                  gdcNamespaceObject.FieldByName('modified').AsDateTime :=
                    FibdsLink.FieldByName('editiondate').AsDateTime;
                  gdcNamespaceObject.FieldByName('curr_modified').AsDateTime :=
                    FibdsLink.FieldByName('editiondate').AsDateTime;
                end;
                gdcNamespaceObject.Post;
              end;  
            end
            else if FibdsLink.FieldByName('namespacekey').AsInteger <> FCurrentNSID then
            begin
              q.ParamByName('uk').AsInteger := FibdsLink.FieldByName('namespacekey').AsInteger;
              q.ExecQuery;
            end;

            FibdsLink.Prior;
          end;
        finally
          q.Free;
        end;
      end;
    end;
  finally
    gdcNamespaceObject.Free;
  end;

  FIBTransaction.Commit;
end;

procedure TgdcNamespaceController.Setup(AnObject: TgdcBase; ABL: TBookmarkList);
var
  q: TIBSQL;
  I: Integer;
  Bm: String;
  FSessionID: Integer;
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.EOF);
  Assert(FibdsLink.State = dsInactive);

  FgdcObject := AnObject;
  FBL := ABL;

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