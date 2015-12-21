unit gdcNamespaceController;

interface

uses
  Classes, DB, IBDatabase, IBCustomDataSet, gdcBase, DBGrids;

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
    FTabs: TStringList;
    FSessionID: Integer;

    procedure DeleteFromNamespace;
    procedure MoveBetweenNamespaces;
    procedure AddToNamespace;
    function GetEnabled: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    function Include: Boolean;
    function SetupDS(const ATab: Integer): TDataSet;

    property ObjectName: String read FObjectName;
    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
    property IncludeSiblings: Boolean read FIncludeSiblings write FIncludeSiblings;
    property IncludeLinked: Boolean read FIncludeLinked write FIncludeLinked;
    property PrevNSID: Integer read FPrevNSID write FPrevNSID;
    property CurrentNSID: Integer read FCurrentNSID write FCurrentNSID;
    property ibdsLink: TIBDataSet read FibdsLink;
    property Enabled: Boolean read GetEnabled;
    property Tabs: TStringList read FTabs;
  end;

implementation

uses
  Windows, SysUtils, IBSQL, gdcBaseInterface, gdcNamespace, gdcClasses, gdcStorage,
  gdcEvent, gdcReport, gdcMacros, gdcAcctTransaction, gdcInvDocumentOptions,
  gdcMetaData, gdcDelphiObject, gdcClasses_Interface, gd_KeyAssoc, ContNrs,
  at_Classes, gd_ClassList;

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
    'SELECT '#13#10 +
    '  od.seqid, ' +
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
    '  od.seqid DESC';

  FTabs := TStringList.Create;
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
  FTabs.Free;
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
  HeadObjectKey, HeadObjectPos, NSKey, ObjCount, J, TempPos: Integer;
  q, qNSList, qFind, qMove, qDelete: TIBSQL;
  FirstRUID: TRUID;
  DS: TDataSet;
  ShouldAdd: Boolean;
  CEExist, CENew: TgdClassEntry;
begin
  Assert(FIBTransaction.InTransaction);

  FirstRUID.XID := -1;
  FirstRUID.DBID := -1;
  ObjCount := 0;

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
      qMove := TIBSQL.Create(nil);
      qDelete := TIBSQL.Create(nil);
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
          'SELECT * FROM at_object WHERE namespacekey = :CurrNS ' +
          '  AND xid = :xid AND dbid = :dbid';
        qFind.ParamByName('CurrNS').AsInteger := FCurrentNSID;

        qMove.Transaction := FIBTransaction;
        qMove.SQL.Text :=
          'UPDATE at_object SET objectpos = :objectpos WHERE id = :id';

        qDelete.Transaction := FIBTransaction;
        qDelete.SQL.Text :=
          'DELETE FROM at_object WHERE id = :id';

        for J := 0 to FTabs.Count - 1 do
        begin
          DS := SetupDS(J);
          DS.Last;
          while not DS.BOF do
          begin
            NSKey := -1;

            if (not DS.FieldByName('xid').IsNull)
              and (not DS.FieldByName('dbid').IsNull) then
            begin
              qNSList.Close;
              qNSList.ParamByName('xid').AsInteger := DS.FieldByName('xid').AsInteger;
              qNSList.ParamByName('dbid').AsInteger := DS.FieldByName('dbid').AsInteger;
              qNSList.ExecQuery;

              if (not qNSList.EOF) and (qNSList.Fields[0].AsString > '') then
              begin
                NSKey := StrToIntDef(qNSList.Fields[1].AsString, -1);

                if NSKey = -1 then
                begin
                  if MessageBox(0,
                    PChar('Объект "' + DS.FieldByName('class').AsString +
                    DS.FieldByName('subtype').AsString + ' - ' +
                    DS.FieldByName('name').AsString + '"'#13#10 +
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
                        DS.FieldByName('xid').AsString +
                        ' AND o.dbid = ' +
                        DS.FieldByName('dbid').AsString +
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
              if Pos('RDB$', DS.FieldByName('name').AsString) <> 1 then
              begin
                TempPos := -1;

                qFind.Close;
                qFind.ParamByName('xid').AsInteger := DS.FieldByName('xid').AsInteger;
                qFind.ParamByName('dbid').AsInteger := DS.FieldByName('dbid').AsInteger;
                qFind.ExecQuery;

                if qFind.EOF then
                  ShouldAdd := True
                else begin
                  CEExist := gdClassList.Get(TgdClassEntry, qFind.FieldByName('objectclass').AsString,
                    qFind.FieldbyName('subtype').AsString);
                  CENew := gdClassList.Get(TgdClassEntry, DS.FieldByName('class').AsString,
                    DS.FieldByName('subtype').AsString);

                  if qFind.FieldByName('objectpos').AsInteger > HeadObjectPos then
                  begin
                    if (CEExist = CENew) or CEExist.InheritsFromCE(CENew) then
                    begin
                      qMove.ParamByName('id').AsInteger := qFind.FieldByName('id').AsInteger;
                      qMove.ParamByName('objectpos').AsInteger := HeadObjectPos;
                      qMove.ExecQuery;
                      ShouldAdd := False;
                    end else
                    begin
                      qDelete.ParamByName('id').AsInteger := qFind.FieldByName('id').AsInteger;
                      qDelete.ExecQuery;
                      ShouldAdd := True;
                    end;
                  end else
                  begin
                    if (CEExist = CENew) or CEExist.InheritsFromCE(CENew) then
                      ShouldAdd := False
                    else begin
                      TempPos := qFind.FieldByName('objectpos').AsInteger;
                      qDelete.ParamByName('id').AsInteger := qFind.FieldByName('id').AsInteger;
                      qDelete.ExecQuery;
                      ShouldAdd := True;
                    end;
                  end;
                end;

                if ShouldAdd then
                begin
                  gdcNamespaceObject.Insert;
                  gdcNamespaceObject.FieldByName('namespacekey').AsInteger := FCurrentNSID;
                  gdcNamespaceObject.FieldByName('objectname').AsString := DS.FieldByName('name').AsString;
                  gdcNamespaceObject.FieldByName('objectclass').AsString := DS.FieldByName('class').AsString;
                  gdcNamespaceObject.FieldByName('subtype').AsString := DS.FieldByName('subtype').AsString;
                  gdcNamespaceObject.FieldByName('xid').AsInteger := DS.FieldByName('xid').AsInteger;
                  gdcNamespaceObject.FieldByName('dbid').AsInteger := DS.FieldByName('dbid').AsInteger;
                  if TempPos = -1 then
                    gdcNamespaceObject.FieldByName('objectpos').AsInteger := HeadObjectPos
                  else
                    gdcNamespaceObject.FieldByName('objectpos').AsInteger := TempPos;
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
                  if DS.FieldByName('editiondate').IsNull then
                  begin
                    gdcNamespaceObject.FieldByName('modified').AsDateTime := Now;
                    gdcNamespaceObject.FieldByName('curr_modified').AsDateTime := Now;
                  end else
                  begin
                    gdcNamespaceObject.FieldByName('modified').AsDateTime :=
                      DS.FieldByName('editiondate').AsDateTime;
                    gdcNamespaceObject.FieldByName('curr_modified').AsDateTime :=
                      DS.FieldByName('editiondate').AsDateTime;
                  end;
                  gdcNamespaceObject.Post;
                  Inc(ObjCount);
                end;
              end;
            end
            else if NSKey <> FCurrentNSID then
            begin
              q.ParamByName('uk').AsInteger := NSKey;
              q.ExecQuery;
            end;

            DS.Prior;
          end;

          HeadObjectPos := HeadObjectPos + ObjCount + 1;
          ObjCount := 0;
        end;
      finally
        q.Free;
        qNSList.Free;
        qFind.Free;
        qMove.Free;
        qDelete.Free;
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
  Count: Integer;

  procedure GetDep(AnObject: TgdcBase; const ASessionID: Integer;
    const AnIncludeSelf: Boolean; const ALimitLevel: Integer = MAXINT;
    const AnIgnoreFields: String = '');
  var
    MasterID: Integer;
  begin
    if AnIncludeSelf then
      MasterID := FgdcObject.ID
    else
      MasterID := -1;

    AnObject.GetDependencies(FIBTransaction, ASessionID, Count, False,
      '"GD_DOCUMENT"."TRANSACTIONKEY";"GD_DOCUMENT"."DOCUMENTTYPEKEY";EDITORKEY;CREATORKEY;' + AnIgnoreFields,
      'GD_LASTNUMBER',
      ALimitLevel,
      False,
      MasterID);
  end;

  procedure AddObjects(C: CgdcBase; const ASessionID: Integer;
    const AParam: String; const AnSQL: String;
    const AnIgnoreFields: String = '');
  var
    qObj: TIBSQL;
    Obj: TgdcBase;
  begin
    Obj := C.Create(nil);
    qObj := TIBSQL.Create(nil);
    try
      Obj.SubSet := 'ByID';
      Obj.Transaction := FIBTransaction;

      qObj.Transaction := FIBTransaction;
      qObj.SQL.Text := AnSQL;
      qObj.ParamByName('N').AsString := AParam;
      qObj.ExecQuery;

      while not qObj.EOF do
      begin
        Obj.ID := qObj.FieldByName('id').AsInteger;
        Obj.Open;
        if not Obj.EOF then
          GetDep(Obj, ASessionID, True, MAXINT, AnIgnoreFields);
        Obj.Close;
        qObj.Next;
      end;
    finally
      qObj.Free;
      Obj.Free;
    end;
  end;

  procedure AddDocumentLines(const AHeaderID: Integer; const ASessionID: Integer);
  var
    qObj: TIBSQL;
    Obj: TgdcBase;
  begin
    Obj := TgdcDocument.Create(nil);
    qObj := TIBSQL.Create(nil);
    try
      Obj.SubSet := 'ByID';
      Obj.Transaction := FIBTransaction;

      qObj.Transaction := FIBTransaction;
      qObj.SQL.Text := 'SELECT id FROM gd_document WHERE parent = :P';
      qObj.ParamByName('P').AsInteger := AHeaderID;
      qObj.ExecQuery;

      while not qObj.EOF do
      begin
        Obj.ID := qObj.FieldByName('id').AsInteger;
        Obj.Open;
        if not Obj.EOF then
          GetDep(Obj, ASessionID, True, MAXINT);
        Obj.Close;
        qObj.Next;
      end;
    finally
      qObj.Free;
      Obj.Free;
    end;
  end;

  procedure ProcessObject;
  var
    LimitLevel, SessionID2, K: Integer;
    IgnoreFields: String;
    OL: TObjectList;
    FC: TgdcFullClass;
    OneToOneObj: TgdcBase;
  begin
    LimitLevel := MAXINT;
    IgnoreFields := '';
    SessionID2 := FSessionID;

    if FgdcObject is TgdcDocument then
    begin
      if (FgdcObject as TgdcDocument).GetDocumentClassPart = dcpHeader then
      begin
        Inc(SessionID2);
        FTabs.AddObject('Позиции документа', Pointer(SessionID2));
        AddDocumentLines(FgdcObject.ID, SessionID2);
      end;
    end
    else if FgdcObject is TgdcRelation then
    begin
      Inc(SessionID2);
      FTabs.AddObject('Поля', Pointer(SessionID2));
      AddObjects(TgdcRelationField, SessionID2, IntToStr(FgdcObject.ID),
        'SELECT '#13#10 +
        '  rf.id '#13#10 +
        'FROM '#13#10 +
        '  at_relation_fields rf '#13#10 +
        'WHERE '#13#10 +
        '  rf.fieldname LIKE ''USR$%'' AND rf.relationkey = :N');

      Inc(SessionID2);
      FTabs.AddObject('Хранилище', Pointer(SessionID2));
      AddObjects(TgdcStorage, SessionID2,
        StringReplace(FgdcObject.FieldByName('relationname').AsString, 'USR$', 'USR_', []),
        'SELECT '#13#10 +
        '  v.id '#13#10 +
        'FROM '#13#10 +
        '  gd_storage_data usr '#13#10 +
        '  JOIN gd_storage_data frm '#13#10 +
        '    ON frm.parent = usr.id '#13#10 +
        '  JOIN gd_storage_data ibgr '#13#10 +
        '    ON ibgr.parent = frm.id '#13#10 +
        '  JOIN gd_storage_data v '#13#10 +
        '    ON v.parent = ibgr.id '#13#10 +
        'WHERE '#13#10 +
        '  usr.id = 990010 '#13#10 +
        '  AND frm.name CONTAINING :N '#13#10 +
        '  AND ibgr.name LIKE ''ibgr%'' '#13#10 +
        '  AND v.name = ''data'' '#13#10 +
        '  AND v.data_type = ''B''');

      AddObjects(TgdcStorage, SessionID2, FgdcObject.FieldbyName('relationname').AsString,
        'SELECT '#13#10 +
        '  v.id '#13#10 +
        'FROM '#13#10 +
        '  gd_storage_data glbl '#13#10 +
        '  JOIN gd_storage_data dfm '#13#10 +
        '    ON dfm.parent = glbl.id AND dfm.name = ''DFM'' '#13#10 +
        '  JOIN gd_storage_data frm_class '#13#10 +
        '    ON frm_class.parent = dfm.id '#13#10 +
        '  JOIN gd_storage_data v '#13#10 +
        '    ON v.parent = frm_class.id '#13#10 +
        'WHERE '#13#10 +
        '  glbl.name = ''GLOBAL'' AND glbl.data_type = ''G'' '#13#10 +
        '  AND v.name = :N AND v.data_type = ''B'' ');

      Inc(SessionID2);
      FTabs.AddObject('Скрипт-объекты', Pointer(SessionID2));
      AddObjects(TgdcEvent, SessionID2,
        StringReplace(FgdcObject.FieldByName('relationname').AsString, 'USR$', 'USR_', []),
        'SELECT '#13#10 +
        '  ev.id '#13#10 +
        'FROM '#13#10 +
        '  evt_objectevent ev '#13#10 +
        '  JOIN evt_object o ON o.id = ev.objectkey '#13#10 +
        '  JOIN evt_object p ON p.id = o.parent '#13#10 +
        'WHERE '#13#10 +
        '  p.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  p.name LIKE ''%'' || :N' +
        ' '#13#10 +
        'UNION ALL '#13#10 +
        ' '#13#10 +
        'SELECT '#13#10 +
        '  ev.id '#13#10 +
        'FROM '#13#10 +
        '  evt_objectevent ev '#13#10 +
        '  JOIN evt_object o ON o.id = ev.objectkey '#13#10 +
        '  JOIN evt_object r ON r.lb < o.lb AND r.rb >= o.rb '#13#10 +
        'WHERE '#13#10 +
        '  r.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  r.NAME = ''TgdcBase'' '#13#10 +
        '  AND '#13#10 +
        '  o.name LIKE ''%'' || :N '#13#10 +
        ' '#13#10 +
        'UNION ALL '#13#10 +
        ' '#13#10 +
        'SELECT '#13#10 +
        '  ev.id '#13#10 +
        'FROM '#13#10 +
        '  evt_objectevent ev '#13#10 +
        '  JOIN evt_object o ON o.id = ev.objectkey '#13#10 +
        '  JOIN evt_object r ON r.lb < o.lb AND r.rb >= o.rb '#13#10 +
        'WHERE '#13#10 +
        '  r.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  r.NAME = ''TgdcCreateableForm'' '#13#10 +
        '  AND '#13#10 +
        '  o.name LIKE ''%'' || :N');

      AddObjects(TgdcMacros, SessionID2,
        StringReplace(FgdcObject.FieldByName('relationname').AsString, 'USR$', 'USR_', []),
        'SELECT '#13#10 +
        '  ml.id '#13#10 +
        'FROM '#13#10 +
        '  evt_macroslist ml '#13#10 +
        '  JOIN evt_macrosgroup mg ON ml.MACROSGROUPKEY = mg.id '#13#10 +
        '  JOIN evt_macrosgroup mgp ON mgp.lb <= mg.LB AND mgp.rb >= mg.rb '#13#10 +
        '  JOIN evt_object p ON p.MACROSGROUPKEY = mgp.id '#13#10 +
        'WHERE '#13#10 +
        '  p.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  p.name LIKE ''%'' || :N');

      AddObjects(TgdcDelphiObject, SessionID2,
        StringReplace(FgdcObject.FieldByName('relationname').AsString, 'USR$', 'USR_', []),
        'SELECT '#13#10 +
        '  id '#13#10 +
        'FROM '#13#10 +
        '  evt_object '#13#10 +
        'WHERE '#13#10 +
        '  name LIKE ''%'' || :N '#13#10 +
        '  AND '#13#10 +
        '  parent IS NOT NULL');

      AddObjects(TgdcDelphiObject, SessionID2,
        StringReplace(FgdcObject.FieldByName('relationname').AsString, 'USR$', 'USR_', []),
        'SELECT '#13#10 +
        '  id '#13#10 +
        'FROM '#13#10 +
        '  evt_object '#13#10 +
        'WHERE '#13#10 +
        '  name LIKE ''%'' || :N '#13#10 +
        '  AND '#13#10 +
        '  parent IS NULL');

      Inc(SessionID2);
      FTabs.AddObject('Отчеты', Pointer(SessionID2));
      AddObjects(TgdcReport, SessionID2, FgdcObject.FieldByName('relationname').AsString,
        'SELECT '#13#10 +
        '  l.id '#13#10 +
        'FROM '#13#10 +
        '  rp_reportgroup gr '#13#10 +
        '  JOIN rp_reportlist l ON l.REPORTGROUPKEY = gr.id '#13#10 +
        'WHERE '#13#10 +
        '  gr.usergroupname LIKE ''%'' || :N ');

      AddObjects(TgdcReport, SessionID2,
        StringReplace(FgdcObject.FieldByName('relationname').AsString, 'USR$', 'USR_', []),
        'SELECT '#13#10 +
        '  l.id '#13#10 +
        'FROM '#13#10 +
        '  evt_object ev '#13#10 +
        '  JOIN rp_reportgroup gr ON ev.reportgroupkey = gr.parent '#13#10 +
        '  JOIN rp_reportlist l ON l.REPORTGROUPKEY = gr.id '#13#10 +
        'WHERE '#13#10 +
        '  ev.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  ev.name LIKE ''%'' || :N ' +
        'UNION ALL ' +
        'SELECT '#13#10 +
        '  l.id '#13#10 +
        'FROM '#13#10 +
        '  evt_object ev '#13#10 +
        '  JOIN rp_reportgroup gr ON ev.reportgroupkey = gr.id '#13#10 +
        '  JOIN rp_reportlist l ON l.REPORTGROUPKEY = gr.id '#13#10 +
        'WHERE '#13#10 +
        '  ev.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  ev.name LIKE ''%'' || :N ');
    end
    else if FgdcObject is TgdcBaseDocumentType then
    begin
      IgnoreFields := 'HEADERRELKEY;LINERELKEY';

      Inc(SessionID2);
      FTabs.AddObject('Хранилище', Pointer(SessionID2));
      AddObjects(TgdcStorage, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  v.id '#13#10 +
        'FROM '#13#10 +
        '  gd_storage_data glbl '#13#10 +
        '  JOIN gd_storage_data dfm '#13#10 +
        '    ON dfm.parent = glbl.id AND dfm.name = ''DFM'' '#13#10 +
        '  JOIN gd_storage_data frm_class '#13#10 +
        '    ON frm_class.parent = dfm.id '#13#10 +
        '  JOIN gd_storage_data v '#13#10 +
        '    ON v.parent = frm_class.id '#13#10 +
        'WHERE '#13#10 +
        '  glbl.name = ''GLOBAL'' AND glbl.data_type = ''G'' '#13#10 +
        '  AND v.name = :N AND v.data_type = ''B'' '#13#10 +
        'UNION ALL '#13#10 +
        'SELECT '#13#10 +
        '  v.id '#13#10 +
        'FROM '#13#10 +
        '  gd_storage_data usr '#13#10 +
        '  JOIN gd_storage_data frm '#13#10 +
        '    ON frm.parent = usr.id '#13#10 +
        '  JOIN gd_storage_data ibgr '#13#10 +
        '    ON ibgr.parent = frm.id '#13#10 +
        '  JOIN gd_storage_data v '#13#10 +
        '    ON v.parent = ibgr.id '#13#10 +
        'WHERE '#13#10 +
        '  usr.id = 990010 '#13#10 +
        '  AND frm.name CONTAINING :N '#13#10 +
        '  AND ibgr.name LIKE ''ibgr%'' '#13#10 +
        '  AND v.name = ''data'' '#13#10 +
        '  AND v.data_type = ''B''');

      Inc(SessionID2);
      FTabs.AddObject('Скрипт-объекты', Pointer(SessionID2));
      AddObjects(TgdcEvent, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  ev.id '#13#10 +
        'FROM '#13#10 +
        '  evt_objectevent ev '#13#10 +
        '  JOIN evt_object o ON o.id = ev.objectkey '#13#10 +
        '  JOIN evt_object p ON p.id = o.parent '#13#10 +
        'WHERE '#13#10 +
        '  p.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  p.name LIKE ''%'' || :N' +
        ' '#13#10 +
        'UNION ALL '#13#10 +
        ' '#13#10 +
        'SELECT '#13#10 +
        '  ev.id '#13#10 +
        'FROM '#13#10 +
        '  evt_objectevent ev '#13#10 +
        '  JOIN evt_object o ON o.id = ev.objectkey '#13#10 +
        '  JOIN evt_object r ON r.lb < o.lb AND r.rb >= o.rb '#13#10 +
        'WHERE '#13#10 +
        '  r.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  r.NAME = ''TgdcBase'' '#13#10 +
        '  AND '#13#10 +
        '  o.name LIKE ''%'' || :N '#13#10 +
        ' '#13#10 +
        'UNION ALL '#13#10 +
        ' '#13#10 +
        'SELECT '#13#10 +
        '  ev.id '#13#10 +
        'FROM '#13#10 +
        '  evt_objectevent ev '#13#10 +
        '  JOIN evt_object o ON o.id = ev.objectkey '#13#10 +
        '  JOIN evt_object r ON r.lb < o.lb AND r.rb >= o.rb '#13#10 +
        'WHERE '#13#10 +
        '  r.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  r.NAME = ''TgdcCreateableForm'' '#13#10 +
        '  AND '#13#10 +
        '  o.name LIKE ''%'' || :N');

      AddObjects(TgdcMacros, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  ml.id '#13#10 +
        'FROM '#13#10 +
        '  evt_macroslist ml '#13#10 +
        '  JOIN evt_macrosgroup mg ON ml.MACROSGROUPKEY = mg.id '#13#10 +
        '  JOIN evt_macrosgroup mgp ON mgp.lb <= mg.LB AND mgp.rb >= mg.rb '#13#10 +
        '  JOIN evt_object p ON p.MACROSGROUPKEY = mgp.id '#13#10 +
        'WHERE '#13#10 +
        '  p.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  p.name LIKE ''%'' || :N');

      AddObjects(TgdcAcctTransactionEntry, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  tr.id '#13#10 +
        'FROM '#13#10 +
        '  ac_trrecord tr '#13#10 +
        '  JOIN gd_documenttype dt ON dt.id = tr.documenttypekey '#13#10 +
        'WHERE '#13#10 +
        '  dt.ruid = :N');

      AddObjects(TgdcDelphiObject, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  id '#13#10 +
        'FROM '#13#10 +
        '  evt_object '#13#10 +
        'WHERE '#13#10 +
        '  name LIKE ''%'' || :N '#13#10 +
        '  AND '#13#10 +
        '  parent IS NOT NULL');

      AddObjects(TgdcDelphiObject, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  id '#13#10 +
        'FROM '#13#10 +
        '  evt_object '#13#10 +
        'WHERE '#13#10 +
        '  name LIKE ''%'' || :N '#13#10 +
        '  AND '#13#10 +
        '  parent IS NULL');

      Inc(SessionID2);
      FTabs.AddObject('Отчеты', Pointer(SessionID2));
      AddObjects(TgdcReport, SessionID2, RUIDToStr(FgdcObject.GetRUID), 
        'SELECT '#13#10 +
        '  l.id '#13#10 +
        'FROM '#13#10 +
        '  rp_reportgroup gr '#13#10 +
        '  JOIN rp_reportlist l ON l.REPORTGROUPKEY = gr.id '#13#10 +
        'WHERE '#13#10 +
        '  gr.usergroupname LIKE ''%'' || :N ');

      AddObjects(TgdcReport, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  l.id '#13#10 +
        'FROM '#13#10 +
        '  evt_object ev '#13#10 +
        '  JOIN rp_reportgroup gr ON ev.reportgroupkey = gr.parent '#13#10 +
        '  JOIN rp_reportlist l ON l.REPORTGROUPKEY = gr.id '#13#10 +
        'WHERE '#13#10 +
        '  ev.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  ev.name LIKE ''%'' || :N ' +
        'UNION ALL ' +
        'SELECT '#13#10 +
        '  l.id '#13#10 +
        'FROM '#13#10 +
        '  evt_object ev '#13#10 +
        '  JOIN rp_reportgroup gr ON ev.reportgroupkey = gr.id '#13#10 +
        '  JOIN rp_reportlist l ON l.REPORTGROUPKEY = gr.id '#13#10 +
        'WHERE '#13#10 +
        '  ev.parent IS NULL '#13#10 +
        '  AND '#13#10 +
        '  ev.name LIKE ''%'' || :N ' +
        'UNION ALL ' +
        'SELECT '#13#10 +
        '  l.id '#13#10 +
        'FROM '#13#10 +
        '  gd_documenttype dt '#13#10 +
        '  JOIN rp_reportgroup gr ON dt.reportgroupkey = gr.id '#13#10 +
        '  JOIN rp_reportlist l ON l.REPORTGROUPKEY = gr.id '#13#10 +
        'WHERE '#13#10 +
        '  dt.ruid = :N');

      Inc(SessionID2);
      FTabs.AddObject('Параметры документа', Pointer(SessionID2));
      AddObjects(TgdcInvDocumentTypeOptions, SessionID2, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  o.id '#13#10 +
        'FROM '#13#10 +
        '  gd_documenttype_option o '#13#10 +
        '  JOIN gd_documenttype dt ON dt.id = o.DTKEY '#13#10 +
        '  JOIN gd_documenttype dth ON dth.LB >= dt.LB AND dth.rb <= dt.rb '#13#10 +
        'WHERE '#13#10 +
        '  dth.ruid = :N',
        'DTKEY');

      AddObjects(TgdcRelationField, FSessionID, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  rf.id '#13#10 +
        'FROM '#13#10 +
        '  at_relation_fields rf '#13#10 +
        '  JOIN gd_documenttype dt ON dt.linerelkey = rf.relationkey '#13#10 +
        'WHERE '#13#10 +
        '  dt.ruid = :N AND rf.fieldname LIKE ''USR$%'' ');

      AddObjects(TgdcRelation, FSessionID, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  r.id '#13#10 +
        'FROM '#13#10 +
        '  at_relations r '#13#10 +
        '  JOIN gd_documenttype dt ON dt.linerelkey = r.id '#13#10 +
        'WHERE '#13#10 +
        '  dt.ruid = :N');

      AddObjects(TgdcRelationField, FSessionID, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  rf.id '#13#10 +
        'FROM '#13#10 +
        '  at_relation_fields rf '#13#10 +
        '  JOIN gd_documenttype dt ON dt.headerrelkey = rf.relationkey '#13#10 +
        'WHERE '#13#10 +
        '  dt.ruid = :N AND rf.fieldname LIKE ''USR$%'' ');

      AddObjects(TgdcRelation, FSessionID, RUIDToStr(FgdcObject.GetRUID),
        'SELECT '#13#10 +
        '  r.id '#13#10 +
        'FROM '#13#10 +
        '  at_relations r '#13#10 +
        '  JOIN gd_documenttype dt ON dt.headerrelkey = r.id '#13#10 +
        'WHERE '#13#10 +
        '  dt.ruid = :N');
    end;

    OL := TObjectList.Create(False);
    try
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
        FgdcObject.GetListTable(FgdcObject.SubType), OL, False,
        True, False);
      for K := 0 to OL.Count - 1 do
      begin
        if (TatForeignKey(OL[K]).ConstraintFields.Count = 1) and
          (TatForeignKey(OL[K]).ConstraintFields[0].FieldName = 'ID') then
        begin
          FC := GetBaseClassForRelationByID(TatForeignKey(OL[K]).Relation.RelationName,
            FgdcObject.ID, FIBTransaction);
          if FC.gdClass <> nil then
          begin
            OneToOneObj := FC.gdClass.Create(nil);
            try
              OneToOneObj.Transaction := FIBTransaction;
              OneToOneObj.SubType := FC.SubType;
              OneToOneObj.SubSet := 'ByID';
              OneToOneObj.ID := FgdcObject.ID;
              OneToOneObj.Open;
              if not OneToOneObj.EOF then
              begin
                Inc(SessionID2);
                FTabs.AddObject(OneToOneObj.GetDisplayName(OneToOneObj.SubType),
                  Pointer(SessionID2));
                GetDep(OneToOneObj, SessionID2, False, LimitLevel, 'ID');
              end;
            finally
              OneToOneObj.Free;
            end;
          end;
        end;
      end;
    finally
      OL.Free;
    end;

    GetDep(FgdcObject, FSessionID, False, LimitLevel, IgnoreFields);
  end;

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

    FSessionID := AnObject.GetNextID;
    FTabs.Clear;
    FTabs.AddObject('Зависимости', Pointer(FSessionID));
    Count := 0;

    if (FgdcObject.State in [dsEdit, dsInsert]) or (FBL = nil) or (FBL.Count = 0) then
      ProcessObject
    else begin
      FgdcObject.DisableControls;
      try
        Bm := FgdcObject.Bookmark;
        for I := 0 to FBL.Count - 1 do
        begin
          FgdcObject.Bookmark := FBL[I];
          ProcessObject;
        end;
        FgdcObject.Bookmark := Bm;
      finally
        FgdcObject.EnableControls;
      end;
    end;

    q.Close;
    q.SQL.Text :=
      'EXECUTE BLOCK '#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE sessionid dintkey; '#13#10 +
      '  DECLARE VARIABLE seqid dintkey; '#13#10 +
      '  DECLARE VARIABLE refobjectid dintkey; '#13#10 +
      '  DECLARE VARIABLE refclassname dname; '#13#10 +
      'BEGIN '#13#10 +
      '  FOR '#13#10 +
      '    SELECT sessionid, seqid, refobjectid, refclassname '#13#10 +
      '    FROM gd_object_dependencies '#13#10 +
      '    ORDER BY sessionid, seqid DESC'#13#10 +
      '    INTO :sessionid, :seqid, :refobjectid, :refclassname '#13#10 +
      '  DO BEGIN '#13#10 +
      '    DELETE FROM gd_object_dependencies '#13#10 +
      '    WHERE sessionid = :sessionid '#13#10 +
      '      AND seqid < :seqid '#13#10 +
      '      AND refobjectid = :refobjectid AND refclassname = :refclassname; '#13#10 +
      '  END '#13#10 +
      'END';
    q.ExecQuery;
  finally
    q.Free;
  end;

  SetupDS(0);

  FObjectName := FgdcObject.ObjectName + ' ('
    + FgdcObject.GetDisplayName(FgdcObject.SubType) + ')';
  if (FBL <> nil) and (FBL.Count > 1) then
    FObjectName := FObjectName + ' и еще ' +
      IntToStr(FBL.Count - 1) + ' объект(а, ов)';
end;

function TgdcNamespaceController.SetupDS(const ATab: Integer): TDataSet;
begin
  FibdsLink.Close;
  FibdsLink.ParamByName('sid').AsInteger := Integer(FTabs.Objects[ATab]);
  FibdsLink.Open;

  FibdsLink.FieldByName('id').Visible := False;
  FibdsLink.FieldByName('reflevel').Visible := False;
  FibdsLink.FieldByName('class').Visible := False;
  FibdsLink.FieldByName('subtype').Visible := False;
  FibdsLink.FieldByName('name').Visible := False;
  FibdsLink.FieldByName('editiondate').Visible := False;
  FibdsLink.FieldByName('seqid').Visible := False;
  FibdsLink.FieldByName('displayname').DisplayLabel := 'Класс - Имя объекта';

  Result := FibdsLink;
end;

end.