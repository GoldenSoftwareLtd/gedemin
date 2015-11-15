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

    procedure DeleteFromNamespace;
    procedure MoveBetweenNamespaces;
    procedure AddToNamespace;
    function GetEnabled: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    function Include: Boolean;

    property ObjectName: String read FObjectName;
    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
    property IncludeSiblings: Boolean read FIncludeSiblings write FIncludeSiblings;
    property IncludeLinked: Boolean read FIncludeLinked write FIncludeLinked;
    property PrevNSID: Integer read FPrevNSID write FPrevNSID;
    property CurrentNSID: Integer read FCurrentNSID write FCurrentNSID;
    property ibdsLink: TIBDataSet read FibdsLink;
    property Enabled: Boolean read GetEnabled;
  end;

implementation

uses
  Windows, SysUtils, IBSQL, gdcBaseInterface, gdcNamespace, gdcClasses;

type
  TIterateProc = procedure of object;

{ TgdcNamespaceController }

procedure TgdcNamespaceController.AddToNamespace;
var
  gdcNamespaceObject: TgdcNamespaceObject;
begin
  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  try
    gdcNamespaceObject.ReadTransaction := FIBTransaction;
    gdcNamespaceObject.Transaction := FIBTransaction;
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
  finally
    gdcNamespaceObject.Free;
  end;
end;

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
    '  (od.refclassname || od.refsubtype || '' - '' || od.refobjectname) as displayname, '#13#10 +
    '  od.refclassname as class, '#13#10 +
    '  od.refsubtype as subtype, '#13#10 +
    '  od.refobjectname as name, '#13#10 +
    '  od.refeditiondate as editiondate '#13#10 +
    'FROM '#13#10 +
    '  gd_object_dependencies od '#13#10 +
    '  LEFT JOIN gd_p_getruid(od.refobjectid) r '#13#10 +
    '    ON 1=1 '#13#10 +
    'WHERE '#13#10 +
    '  od.sessionid = :sid '#13#10 +
    'ORDER BY '#13#10 +
    '  od.reflevel DESC';
end;

procedure TgdcNamespaceController.DeleteFromNamespace;
var
  gdcNamespaceObject: TgdcNamespaceObject;
begin
  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  try
    gdcNamespaceObject.ReadTransaction := FIBTransaction;
    gdcNamespaceObject.Transaction := FIBTransaction;
    gdcNamespaceObject.SubSet := 'ByObject';
    gdcNamespaceObject.ParamByName('namespacekey').AsInteger := FPrevNSID;
    gdcNamespaceObject.ParamByName('xid').AsInteger := FgdcObject.GetRUID.XID;
    gdcNamespaceObject.ParamByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
    gdcNamespaceObject.Open;
    if not gdcNamespaceObject.EOF then
      gdcNamespaceObject.Delete;
  finally
    gdcNamespaceObject.Free;
  end;
end;

destructor TgdcNamespaceController.Destroy;
begin
  FibdsLink.Free;
  FIBTransaction.Free;
  inherited;
end;

function TgdcNamespaceController.GetEnabled: Boolean;
begin
  Result := FIBTransaction.InTransaction and FibdsLink.Active;
end;

function TgdcNamespaceController.Include: Boolean;

  procedure IterateBL(AnIterateProc: TIterateProc; var AFirstRUID: TRUID);
  var
    I: Integer;
    Bm: String;
  begin
    if (FBL = nil) then
    begin
      AFirstRUID := FgdcObject.GetRUID;
      AnIterateProc;
    end else
    begin
      Bm := FgdcObject.Bookmark;
      FgdcObject.DisableControls;
      try
        for I := 0 to FBL.Count - 1 do
        begin
          FgdcObject.Bookmark := FBL[I];
          if I = 0 then
            AFirstRUID := FgdcObject.GetRUID;
          AnIterateProc;
        end;
      finally
        FgdcObject.Bookmark := Bm;
        FgdcObject.EnableControls;
      end;
    end;
  end;

var
  gdcNamespaceObject: TgdcNamespaceObject;
  HeadObjectKey, HeadObjectPos, NSKey: Integer;
  q, qNSList, qFind: TIBSQL;
  FirstRUID: TRUID;
begin
  Assert(FIBTransaction.InTransaction);

  FirstRUID.XID := -1;
  FirstRUID.DBID := -1;

  if (FPrevNSID > -1) and (FCurrentNSID = -1) then
    IterateBL(DeleteFromNamespace, FirstRUID)
  else if (FPrevNSID > -1) and (FCurrentNSID > -1) and (FPrevNSID <> FCurrentNSID) then
    IterateBL(MoveBetweenNamespaces, FirstRUID)
  else if (FPrevNSID = -1) and (FCurrentNSID > -1) then
  begin
    IterateBL(AddToNamespace, FirstRUID);

    if FIncludeLinked then
    begin
      q := TIBSQL.Create(nil);
      qNSList := TIBSQL.Create(nil);
      qFind := TIBSQL.Create(nil);
      gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
      try
        gdcNamespaceObject.ReadTransaction := FIBTransaction;
        gdcNamespaceObject.Transaction := FIBTransaction;

        gdcNamespaceObject.SubSet := 'ByObject';
        gdcNamespaceObject.ParamByName('namespacekey').AsInteger := FCurrentNSID;
        gdcNamespaceObject.ParamByName('xid').AsInteger := FirstRUID.XID;
        gdcNamespaceObject.ParamByName('dbid').AsInteger := FirstRUID.DBID;
        gdcNamespaceObject.Open;

        if gdcNamespaceObject.EOF then
          raise Exception.Create('Invalid object.');

        HeadObjectKey := gdcNamespaceObject.ID;
        HeadObjectPos := gdcNamespaceObject.FieldByName('objectpos').AsInteger;

        gdcNamespaceObject.Close;
        gdcNamespaceObject.SubSet := 'All';
        gdcNamespaceObject.Open;

        q.Transaction := FIBTransaction;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey) ' +
          '  VALUES (:nsk, :uk) ' +
          '  MATCHING (namespacekey, useskey) ';
        q.ParamByName('nsk').AsInteger := FCurrentNSID;

        qNSList.Transaction := FIBTransaction;
        qNSList.SQL.Text :=
          'SELECT LIST(n.name, ''^''), LIST(n.id, ''^'') FROM at_namespace n ' +
          '  JOIN at_object o ON o.namespacekey = n.id ' +
          'WHERE o.xid = :xid AND o.dbid = :dbid ' +
          '  AND o.namespacekey <> :CurrNS';
        qNSList.ParamByName('CurrNS').AsInteger := FCurrentNSID;

        qFind.Transaction := FIBTransaction;
        qFind.SQL.Text :=
          'SELECT id FROM at_object WHERE namespacekey = :CurrNS ' +
          '  AND xid = :xid AND dbid = :dbid';
        qFind.ParamByName('CurrNS').AsInteger := FCurrentNSID;

        FibdsLink.Close;
        FibdsLink.Open;

        FibdsLink.Last;
        while not FibdsLink.BOF do
        begin
          NSKey := -1;

          if (not FibdsLink.FieldByName('xid').IsNull)
            and (not FibdsLink.FieldByName('dbid').IsNull) then
          begin
            qNSList.Close;
            qNSList.ParamByName('xid').AsInteger := FibdsLink.FieldByName('xid').AsInteger;
            qNSList.ParamByName('dbid').AsInteger := FibdsLink.FieldByName('dbid').AsInteger;
            qNSList.ExecQuery;

            if (not qNSList.EOF) and (qNSList.Fields[0].AsString > '') then
            begin
              NSKey := StrToIntDef(qNSList.Fields[1].AsString, -1);

              if NSKey = -1 then
              begin
                if MessageBox(0,
                  PChar('Объект "' + FibdsLink.FieldByName('class').AsString +
                  FibdsLink.FieldByName('subtype').AsString + ' - ' +
                  FibdsLink.FieldByName('name').AsString + '"'#13#10 +
                  'входит в пространства имен:'#13#10#13#10 +
                  StringReplace(qNSList.Fields[0].AsString, '^', #13#10, [rfReplaceAll]) + #13#10#13#10 +
                  'Добавить ПИ в список зависимости?'),
                  'Внимание',
                  MB_OKCANCEL or MB_ICONQUESTION or MB_TASKMODAL) = IDOK then
                begin
                  repeat
                    NSKey := TgdcNamespace.SelectObject(
                      'Выберите ПИ из предложенного списка:', 'Внимание', 0,
                      'id IN (SELECT o.namespacekey FROM at_object o WHERE o.xid = ' +
                      FibdsLink.FieldByName('xid').AsString +
                      ' AND o.dbid = ' +
                      FibdsLink.FieldByName('dbid').AsString +
                      ' AND o.namespacekey <> ' + IntToStr(FCurrentNSID) +
                      ')');
                   until NSKey <> -1;
                end else
                begin
                  MessageBox(0,
                    'Процесс добавления объекта прерван пользователем.',
                    'Внимание',
                    MB_OK or MB_TASKMODAL or MB_ICONEXCLAMATION);
                  FIBTransaction.Rollback;
                  Result := False;
                  exit;
                end;
              end;  
            end;
          end;

          if NSKey = -1 then
          begin
            if Pos('RDB$', FibdsLink.FieldByName('name').AsString) <> 1 then
            begin
              qFind.Close;
              qFind.ParamByName('xid').AsInteger := FibdsLink.FieldByName('xid').AsInteger;
              qFind.ParamByName('dbid').AsInteger := FibdsLink.FieldByName('dbid').AsInteger;
              qFind.ExecQuery;

              if qFind.EOF then
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
            end;
          end
          else if NSKey <> FCurrentNSID then
          begin
            q.ParamByName('uk').AsInteger := NSKey;
            q.ExecQuery;
          end;

          FibdsLink.Prior;
        end;
      finally
        q.Free;
        qNSList.Free;
        qFind.Free;
        gdcNamespaceObject.Free;
      end;
    end;
  end;

  FIBTransaction.Commit;
  Result := True;
end;

procedure TgdcNamespaceController.MoveBetweenNamespaces;
var
  gdcNamespaceObject: TgdcNamespaceObject;
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
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
      gdcNamespaceObject.ReadTransaction := FIBTransaction;
      gdcNamespaceObject.Transaction := FIBTransaction;
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
    gdcNamespaceObject.Free;
  end;
end;

procedure TgdcNamespaceController.Setup(AnObject: TgdcBase; ABL: TBookmarkList);
var
  q: TIBSQL;
  I: Integer;
  Bm: String;
  FSessionID: Integer;
  LimitLevel: Integer;
begin
  Assert(AnObject <> nil);
  { Состояние EOF объект получает не только при пустой таблице, но и в случае
    попытки перехода на следующую запись с последней записи в таблице
  Assert(not AnObject.EOF);                                           }
  Assert(not AnObject.IsEmpty);
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

  if AnObject is TgdcDocument then
    LimitLevel := 0
  else
    LimitLevel := MAXINT;

  if (FgdcObject.State in [dsEdit, dsInsert]) or (FBL = nil) or (FBL.Count = 0) then
    FgdcObject.GetDependencies(FIBTransaction, FSessionID, False,
      '"GD_DOCUMENT"."TRANSACTIONKEY";"GD_DOCUMENT"."DOCUMENTTYPEKEY";EDITORKEY;CREATORKEY;',
      LimitLevel)
  else begin
    FgdcObject.DisableControls;
    try
      Bm := FgdcObject.Bookmark;
      for I := 0 to FBL.Count - 1 do
      begin
        FgdcObject.Bookmark := FBL[I];
        FgdcObject.GetDependencies(FIBTransaction, FSessionID, False,
          '"GD_DOCUMENT"."TRANSACTIONKEY";"GD_DOCUMENT"."DOCUMENTTYPEKEY";EDITORKEY;CREATORKEY;',
          LimitLevel);
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
  FibdsLink.FieldByName('editiondate').Visible := False;
  FibdsLink.FieldByName('displayname').DisplayLabel := 'Класс - Имя объекта';

  FObjectName := FgdcObject.ObjectName + ' ('
    + FgdcObject.GetDisplayName(FgdcObject.SubType) + ')';
  if (FBL <> nil) and (FBL.Count > 1) then
    FObjectName := FObjectName + ' и еще ' +
      IntToStr(FBL.Count - 1) + ' объект(а, ов)';
end;

end.