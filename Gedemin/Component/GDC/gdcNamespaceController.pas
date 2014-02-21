unit gdcNamespaceController;

interface

uses
  DB, IBDatabase, IBCustomDataSet, gdcBase, DBGrids, gd_KeyAssoc;

type
  TgdcNamespaceController = class(TObject)
  private
    FIBTransaction: TIBTransaction;
    FibdsLink: TIBDataSet;
    FPrevNSID: Integer;
    FPrevNSName: String;
    FCurrentNSID: Integer;
    FAlwaysOverwrite: Boolean;
    FDontRemove: Boolean;
    FIncludeSiblings: Boolean;
    FIncludeLinked: Boolean;
    FObjects: TgdKeyArray;
    FNamespaces: TgdKeyStringAssoc;
    FgdcFullClass: TgdcFullClass;

    procedure DeleteFromNamespace;
    procedure MoveBetweenNamespaces;
    procedure AddToNamespace;
    function GetEnabled: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    function Include: Boolean;
    function ShowDialog: Boolean;

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
  Classes, Windows, StdCtrls, ExtCtrls, SysUtils, IBSQL, gdcBaseInterface,
  gdcNamespace, at_dlgNamespaceOp_unit, at_dlgToNamespace_unit, flt_sql_parser,
  gdcMetaData;

type
  TIterateProc = procedure of object;

{ TgdcNamespaceController }

procedure TgdcNamespaceController.AddToNamespace;
{var
  gdcNamespaceObject: TgdcNamespaceObject;}
begin
{  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
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
  end;}
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
    //'   od.reflevel, '#13#10 +
    //'  (od.refobjectname || '' - '' || od.refclassname || od.refsubtype) as displayname, '#13#10 +
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

  FObjects := TgdKeyArray.Create;
  FNamespaces := TgdKeyStringAssoc.Create;
end;

procedure TgdcNamespaceController.DeleteFromNamespace;
{var
  gdcNamespaceObject: TgdcNamespaceObject;}
begin
{  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
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
  end;}
end;

destructor TgdcNamespaceController.Destroy;
begin
  FObjects.Free;
  FNamespaces.Free;
  FibdsLink.Free;
  FIBTransaction.Free;
  inherited;
end;

function TgdcNamespaceController.GetEnabled: Boolean;
begin
  Result := FIBTransaction.InTransaction and FibdsLink.Active;
end;

function TgdcNamespaceController.Include: Boolean;

  {
  procedure IterateBL(AnIterateProc: TIterateProc);
  var
    I: Integer;
    Bm: String;
  begin
    if (FBL = nil) then
      AnIterateProc
    else begin
      Bm := FgdcObject.Bookmark;
      FgdcObject.DisableControls;
      try
        for I := 0 to FBL.Count - 1 do
        begin
          FgdcObject.Bookmark := FBL[I];
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
  }
begin
  Assert(FIBTransaction.InTransaction);

  {
  if (FPrevNSID > -1) and (FCurrentNSID = -1) then
    IterateBL(DeleteFromNamespace)
  else if (FPrevNSID > -1) and (FCurrentNSID > -1) and (FPrevNSID <> FCurrentNSID) then
    IterateBL(MoveBetweenNamespaces)
  else if (FPrevNSID = -1) and (FCurrentNSID > -1) then
  begin
    IterateBL(AddToNamespace);

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
        gdcNamespaceObject.ParamByName('xid').AsInteger := FgdcObject.GetRUID.XID;
        gdcNamespaceObject.ParamByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
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
  }
  Result := True;
end;

procedure TgdcNamespaceController.MoveBetweenNamespaces;
{var
  gdcNamespaceObject: TgdcNamespaceObject;
  q: TIBSQL;}
begin
{  q := TIBSQL.Create(nil);
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
  end;}
end;

procedure TgdcNamespaceController.Setup(AnObject: TgdcBase; ABL: TBookmarkList);
var
  q: TIBSQL;
  I: Integer;
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.EOF);

  FgdcFullClass.gdClass := CgdcBase(AnObject.ClassType);
  FgdcFullClass.SubType := AnObject.SubType;
  FObjects.Clear;
  FNamespaces.Clear;

  if ABL <> nil then
  begin
    ABL.Refresh;

    for I := 0 to ABL.Count - 1 do
      FObjects.Add(AnObject.GetIDForBookmark(ABL[I]));
  end;

  FObjects.Add(AnObject.ID, True);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FIBTransaction;

    q.SQL.Text :=
      'SELECT n.id, n.name ' +
      'FROM at_object o ' +
      '  JOIN gd_ruid r ON r.xid = o.xid AND r.dbid = o.dbid ' +
      '  JOIN at_namespace n ON n.id = o.namespacekey ' +
      'WHERE r.id IN (' + FObjects.CommaText + ') ';
    q.ExecQuery;

    while not q.EOF do
    begin
      FNamespaces.ValuesByIndex[FNamespaces.Add(q.FieldByName('id').AsInteger)] :=
        q.FieldByName('name').AsString;
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

function TgdcNamespaceController.ShowDialog: Boolean;
var
  Obj, CompoundObj: TgdcBase;
  I, J: Integer;
  Dlg: TdlgToNamespace;
  FSessionID, FSessionID2: Integer;
  TL: TStringList;
  //IDs: TgdKeyArray;
begin
  Assert(FgdcFullClass.gdClass <> nil);

  Result := False;

  if (FObjects.Count >= 1) and (FNamespaces.Count = 0) then
  begin
    Obj := FgdcFullClass.gdClass.Create(nil);
    try
      Obj.Transaction := FIBTransaction;
      Obj.SubType := FgdcFullClass.SubType;
      Obj.SubSet := 'ByID';

      //IDs := TgdKeyArray.Create;
      Dlg := TdlgToNamespace.Create(nil);
      try
        Dlg.chbxAlwaysOverwrite.Checked := FAlwaysOverwrite;
        Dlg.chbxDontRemove.Checked := FDontRemove;
        Dlg.chbxIncludeSiblings.Checked := FIncludeSiblings;

        for I := 0 to FObjects.Count - 1 do
        begin
          {if IDs.IndexOf(FObjects[I]) > -1 then
            continue
          else
            IDs.Add(FObjects[I]);}

          Obj.Close;
          Obj.ID := FObjects[I];
          Obj.Open;

          if not Obj.EOF then
          begin
            Dlg.AddObject(Obj.ID, Obj.ObjectName, Obj.ClassName + Obj.SubType,
              RUIDToStr(Obj.GetRUID), '', False, False);

            FSessionID := gdcBaseManager.GetNextID;
            Obj.GetDependencies(FIBTransaction, FSessionID, False, ';EDITORKEY;CREATORKEY;');

            FibdsLink.Close;
            FibdsLink.ParamByName('sid').AsInteger := FSessionID;
            FibdsLink.Open;

            while not FibdsLink.EOF do
            begin
              {if IDs.IndexOf(FibdsLink.FieldByName('id').AsInteger) = -1 then
              begin
                IDs.Add(FibdsLink.FieldByName('id').AsInteger);}
                Dlg.AddObject(
                  FibdsLink.FieldByName('id').AsInteger,
                  FibdsLink.FieldByName('name').AsString,
                  FibdsLink.FieldByName('class').AsString + FibdsLink.FieldByName('subtype').AsString,
                  FibdsLink.FieldByName('xid').AsString + '_' + FibdsLink.FieldByName('dbid').AsString,
                  '', True, False);
              {end;}
              FibdsLink.Next;
            end;

            for J := 0 to Obj.CompoundClassesCount - 1 do
            begin
              CompoundObj := Obj.CompoundClasses[J].gdClass.Create(nil);
              try
                CompoundObj.Transaction := FIBTransaction;
                CompoundObj.SubType := Obj.CompoundClasses[J].SubType;
                CompoundObj.SubSet := 'All';
                CompoundObj.Prepare;

                TL := TStringList.Create;
                try
                  ExtractTablesList(CompoundObj.SelectSQL.Text, TL);
                  if TL.IndexOfName(Obj.CompoundClasses[J].LinkRelationName) > -1 then
                  begin
                    CompoundObj.ExtraConditions.Add(
                      TL.Values[Obj.CompoundClasses[J].LinkRelationName] +
                      Obj.CompoundClasses[J].LinkFieldName +
                      '=:LinkID');
                    CompoundObj.ParamByName('LinkID').AsInteger := Obj.ID;
                    CompoundObj.Open;
                    while not CompoundObj.EOF do
                    begin
                      {if IDs.IndexOf(CompoundObj.ID) = -1 then
                      begin
                        IDs.Add(CompoundObj.ID);}
                        if (not (CompoundObj is TgdcMetaBase))
                          or ((not TgdcMetaBase(CompoundObj).IsDerivedObject)
                            and (TgdcMetaBase(CompoundObj).IsUserDefined)) then
                        begin
                          Dlg.AddObject(CompoundObj.ID, CompoundObj.ObjectName,
                            CompoundObj.ClassName + CompoundObj.SubType,
                            RUIDToStr(CompoundObj.GetRUID), '', False, True);

                          FSessionID2 := gdcBaseManager.GetNextID;
                          CompoundObj.GetDependencies(FIBTransaction, FSessionID2, False, ';EDITORKEY;CREATORKEY;');

                          FibdsLink.Close;
                          FibdsLink.ParamByName('sid').AsInteger := FSessionID2;
                          FibdsLink.Open;

                          while not FibdsLink.EOF do
                          begin
                            {if IDs.IndexOf(FibdsLink.FieldByName('id').AsInteger) = -1 then
                            begin
                              IDs.Add(FibdsLink.FieldByName('id').AsInteger);}
                              if FibdsLink.FieldByName('id').AsInteger <> Obj.ID then
                              begin
                                Dlg.AddObject(
                                  FibdsLink.FieldByName('id').AsInteger,
                                  FibdsLink.FieldByName('name').AsString,
                                  FibdsLink.FieldByName('class').AsString + FibdsLink.FieldByName('subtype').AsString,
                                  FibdsLink.FieldByName('xid').AsString + '_' + FibdsLink.FieldByName('dbid').AsString,
                                  '', True, True);
                              end;    
                            {end;}
                            FibdsLink.Next;
                          end;
                        end;
                      {end;}
                      CompoundObj.Next;
                    end;
                  end;
                finally
                  TL.Free;
                end;
              finally
                CompoundObj.Free;
              end;
            end;
          end;
        end;

        Dlg.ShowModal;
      finally
        //IDs.Free;
        Dlg.Free;
      end;
    finally
      Obj.Free;
    end;
  end
  else if (FObjects.Count > 1) and (FNamespaces.Count > 1) then
  begin
    MessageBox(0,
      'Можно редактировать группу объектов только если они входят в одно ПИ и имеют одинаковые параметры.',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end
  else begin
    begin
      with Tat_dlgNamespaceOp.Create(nil) do
      try
        ShowModal;
      finally
        Free;
      end;
    end;
  end;
end;

end.