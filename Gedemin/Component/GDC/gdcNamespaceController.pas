unit gdcNamespaceController;

interface

uses
  DB, ContNrs, IBDatabase, IBSQL, gdcBase, DBGrids, gd_KeyAssoc,
  at_dlgToNamespace_unit;

type
  TgdcNamespaceController = class(TObject)
  private
    FIBTransaction: TIBTransaction;
    FqLink, FqNSList: TIBSQL;
    FPrevNSID: Integer;
    FPrevNSName: String;
    FCurrentNSID: Integer;
    FAlwaysOverwrite: Boolean;
    FDontRemove: Boolean;
    FIncludeSiblings: Boolean;
    FObjects: TgdKeyArray;
    FNamespaces: TgdKeyStringAssoc;
    FgdcFullClass: TgdcFullClass;

    procedure DeleteFromNamespace;
    procedure MoveBetweenNamespaces;
    procedure _AddToNamespace;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    function Include(ANSRecord: TNSRecord): Boolean;
    function ShowDialog: Boolean;

    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
    property IncludeSiblings: Boolean read FIncludeSiblings write FIncludeSiblings;
    property PrevNSID: Integer read FPrevNSID write FPrevNSID;
    property CurrentNSID: Integer read FCurrentNSID write FCurrentNSID;
  end;

implementation

uses
  Classes, Windows, Controls, StdCtrls, ExtCtrls, SysUtils, gdcBaseInterface,
  gdcNamespace, at_dlgNamespaceOp_unit, flt_sql_parser, gdcMetaData;

procedure TgdcNamespaceController._AddToNamespace;
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

  FIBTransaction := TIBTransaction.Create(nil);
  FIBTransaction.Params.CommaText := 'read_committed,rec_version,nowait';
  FIBTransaction.DefaultDatabase := gdcBaseManager.Database;
  FIBTransaction.StartTransaction;

  FqLink := TIBSQL.Create(nil);
  FqLink.Transaction := FIBTransaction;
  FqLink.SQL.Text :=
    'SELECT DISTINCT '#13#10 +
    '  od.refobjectid as id, '#13#10 +
    '  r.xid as xid, '#13#10 +
    '  r.dbid as dbid, '#13#10 +
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

  FqNSList := TIBSQL.Create(nil);
  FqNSList.Transaction := FIBTransaction;
  FqNSList.SQL.Text :=
    'SELECT LIST(n.name, ''^''), LIST(n.id, ''^'') FROM at_namespace n ' +
    '  JOIN at_object o ON o.namespacekey = n.id ' +
    'WHERE o.xid = :xid AND o.dbid = :dbid ';

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
  FqLink.Free;
  FqNSList.Free;
  FIBTransaction.Free;
  inherited;
end;

function TgdcNamespaceController.Include(ANSRecord: TNSRecord): Boolean;
var
  gdcNamespaceObject: TgdcNamespaceObject;
  NSKey: Integer;
  q: TIBSQL;
begin
  Assert(FIBTransaction.InTransaction);

  NSKey := -1;

  try
    FqNSList.ParamByName('xid').AsInteger := ANSRecord.RUID.XID;
    FqNSList.ParamByName('dbid').AsInteger := ANSRecord.RUID.DBID;
    FqNSList.ExecQuery;

    if not FqNSList.EOF then
    begin
      NSKey := StrToIntDef(FqNSList.Fields[1].AsString, -1);

      if NSKey = -1 then
      begin
        if MessageBox(0,
          PChar('Объект "' + ANSRecord.ObjectClass +
          ANSRecord.SubType + ' - ' +
          ANSRecord.ObjectName + '"'#13#10 +
          'входит в пространства имен:'#13#10#13#10 +
          StringReplace(FqNSList.Fields[0].AsString, '^', #13#10, [rfReplaceAll]) + #13#10#13#10 +
          'Добавить ПИ в список зависимости?'),
          'Внимание',
          MB_OKCANCEL or MB_ICONQUESTION or MB_TASKMODAL) = IDOK then
        begin
          repeat
            NSKey := TgdcNamespace.SelectObject(
              'Выберите ПИ из предложенного списка:', 'Внимание', 0,
              'id IN (SELECT o.namespacekey FROM at_object o WHERE o.xid = ' +
              IntToStr(ANSRecord.RUID.XID) +
              ' AND o.dbid = ' +
              IntToStr(ANSRecord.RUID.DBID) +
              ' AND o.namespacekey <> ' + IntToStr(FCurrentNSID) +
              ')');
           until NSKey <> -1;
        end else
        begin
          MessageBox(0,
            'Процесс добавления объекта прерван пользователем.',
            'Внимание',
            MB_OK or MB_TASKMODAL or MB_ICONEXCLAMATION);
          Result := False;
          exit;
        end;
      end;
    end;
  finally
    FqNSList.Close;
  end;

  if NSKey > -1 then
  begin
    if NSKey <> FCurrentNSID then
    begin
      try
        q.Transaction := FIBTransaction;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey) ' +
          '  VALUES (:nsk, :uk) ' +
          '  MATCHING (namespacekey, useskey) ';
        q.ParamByName('nsk').AsInteger := FCurrentNSID;
        q.ParamByName('uk').AsInteger := NSKey;
        q.ExecQuery;
      finally
        q.Free;
      end;
    end;

    Result := True;
    exit;
  end;

  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  try
    gdcNamespaceObject.ReadTransaction := FIBTransaction;
    gdcNamespaceObject.Transaction := FIBTransaction;
    gdcNamespaceObject.SubSet := 'All';
    gdcNamespaceObject.Open;

    gdcNamespaceObject.Insert;
    gdcNamespaceObject.FieldByName('namespacekey').AsInteger := FCurrentNSID;
    gdcNamespaceObject.FieldByName('objectname').AsString := ANSRecord.ObjectName;
    gdcNamespaceObject.FieldByName('objectclass').AsString := ANSRecord.ObjectClass;
    gdcNamespaceObject.FieldByName('subtype').AsString := ANSRecord.SubType;
    gdcNamespaceObject.FieldByName('xid').AsInteger := ANSRecord.RUID.XID;
    gdcNamespaceObject.FieldByName('dbid').AsInteger := ANSREcord.RUID.DBID;
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
    if ANSRecord.HeadObjectKey > -1 then
      gdcNamespaceObject.FieldByName('headobjectkey').AsInteger := ANSRecord.HeadObjectKey
    else
      gdcNamespaceObject.FieldByName('headobjectkey').Clear;
    gdcNamespaceObject.FieldByName('modified').AsDateTime := ANSRecord.EditionDate;
    gdcNamespaceObject.FieldByName('curr_modified').AsDateTime := ANSRecord.EditionDate;
    gdcNamespaceObject.Post;
  finally
    gdcNamespaceObject.Free;
  end;

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

      Dlg := TdlgToNamespace.Create(nil);
      try
        Dlg.chbxAlwaysOverwrite.Checked := FAlwaysOverwrite;
        Dlg.chbxDontRemove.Checked := FDontRemove;
        Dlg.chbxIncludeSiblings.Checked := FIncludeSiblings;

        for I := 0 to FObjects.Count - 1 do
        begin
          Obj.Close;
          Obj.ID := FObjects[I];
          Obj.Open;

          if (not Obj.EOF) and
            (
              (not (Obj is TgdcMetaBase))
              or
              (not TgdcMetaBase(Obj).IsDerivedObject)
            ) then
          begin
            Dlg.AddObject(Obj.ID, Obj.ObjectName, Obj.ClassName, Obj.SubType,
              Obj.GetRUID, Obj.EditionDate, -1, '', False);

            FSessionID := gdcBaseManager.GetNextID;
            Obj.GetDependencies(FIBTransaction, FSessionID, False, ';EDITORKEY;CREATORKEY;');

            FqLink.Close;
            FqLink.ParamByName('sid').AsInteger := FSessionID;
            FqLink.ExecQuery;

            while not FqLink.EOF do
            begin
              Dlg.AddObject(
                FqLink.FieldByName('id').AsInteger,
                FqLink.FieldByName('name').AsString,
                FqLink.FieldByName('class').AsString,
                FqLink.FieldByName('subtype').AsString,
                RUID(FqLink.FieldByName('xid').AsInteger, FqLink.FieldByName('dbid').AsInteger),
                FqLink.FieldByName('editiondate').AsDateTime,
                -1,
                '', True);
              FqLink.Next;
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
                      if (not (CompoundObj is TgdcMetaBase))
                        or ((not TgdcMetaBase(CompoundObj).IsDerivedObject)
                          and (TgdcMetaBase(CompoundObj).IsUserDefined)) then
                      begin
                        Dlg.AddObject(CompoundObj.ID, CompoundObj.ObjectName,
                          CompoundObj.ClassName, CompoundObj.SubType,
                          CompoundObj.GetRUID, CompoundObj.EditionDate,
                          Obj.ID,
                          '', False);

                        FSessionID2 := gdcBaseManager.GetNextID;
                        CompoundObj.GetDependencies(FIBTransaction, FSessionID2, False, ';EDITORKEY;CREATORKEY;');

                        FqLink.Close;
                        FqLink.ParamByName('sid').AsInteger := FSessionID2;
                        FqLink.ExecQuery;

                        while not FqLink.EOF do
                        begin
                          if FqLink.FieldByName('id').AsInteger <> Obj.ID then
                          begin
                            Dlg.AddObject(
                              FqLink.FieldByName('id').AsInteger,
                              FqLink.FieldByName('name').AsString,
                              FqLink.FieldByName('class').AsString,
                              FqLink.FieldByName('subtype').AsString,
                              RUID(FqLink.FieldByName('xid').AsInteger, FqLink.FieldByName('dbid').AsInteger),
                              FqLink.FieldByName('editiondate').AsDateTime,
                              -1,
                              '', True);
                          end;
                          FqLink.Next;
                        end;
                      end;
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

        if Dlg.ShowModal = mrOk then
        begin
          FAlwaysOverwrite := Dlg.chbxAlwaysOverwrite.Checked;
          FDontRemove := Dlg.chbxDontRemove.Checked;
          FIncludeSiblings := Dlg.chbxIncludeSiblings.Checked;
          FCurrentNSID := Dlg.lkupNS.CurrentKeyInt;

          for I := 0 to Dlg.NSRecordCount - 1 do
          begin
            if Dlg.NSRecords[I].Checked then
            begin
              for J := 0 to Dlg.NSRecords[I].LinkedCount - 1 do
              begin
                if Dlg.NSRecords[I].Linked[J].Checked then
                begin
                end;
              end;
            end;
          end;
        end;
      finally
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
