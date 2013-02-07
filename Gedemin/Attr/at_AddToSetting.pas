
unit at_AddToSetting;

interface

uses
  DBGrids, gdcBase;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);

implementation

uses
  Windows, IBDatabase, IBSQL, gdcBaseInterface, at_dlgToSetting_unit,
  at_dlgToNamespace_unit, gdcNamespace;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);
{var
  Tr: TIBTransaction;
  q: TIBSQL;
  I: Integer;
  NamespaceID, SelectedID, XID, DBID: TID;
  FC: TgdcFullClass;}
begin
  Assert(gdcBaseManager <> nil);
  Assert(gdcBaseManager.Database <> nil);
  Assert(AgdcObject <> nil);
  Assert(not AgdcObject.Eof);

  if MessageBox(0,
    'Добавить в настройку? (Нет -- добавление в пространство имен)',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
  begin
    with TdlgToSetting.Create(nil) do
    try
      Setup(FromStorage, ABranchName, AValueName, AgdcObject, BL);
      ShowModal;
    finally
      Free;
    end;
  end else
  begin
    with TdlgToNamespace.Create(nil) do
    try
      Setup(AgdcObject);
      ShowModal;
    finally
      Free;
    end;

    {Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      if (BL <> nil) and (BL.Count > 0) then
        gdcBaseManager.GetRUIDByID(AgdcObject.GetIDForBookmark(BL[0]), XID, DBID, Tr)
      else
        gdcBaseManager.GetRUIDByID(AgdcObject.ID, XID, DBID, Tr);

      q.Transaction := Tr;
      q.SQL.Text :=
        'SELECT o.namespacekey FROM at_object o ' +
        'WHERE o.xid = :XID AND o.dbid = :DBID';
      q.ParamByName('XID').AsInteger := XID;
      q.ParamByName('DBID').AsInteger := DBID;
      q.ExecQuery;

      if q.EOF then
        NamespaceID := -1
      else
        NamespaceID := q.Fields[0].AsInteger;

      SelectedID := TgdcNamespace.SelectObject('Выберите пространство имен:',
        'Добавление объекта в пространство имен', 0, '', NamespaceID);

      if SelectedID >= 0 then
      begin
        FC := AgdcObject.GetCurrRecordClass;

        q.Close;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO at_object ' +
          '  (namespacekey, objectname, objectclass, subtype, xid, dbid) ' +
          'VALUES (:NSK, :ON, :OC, :ST, :XID, :DBID) ' +
          'MATCHING (xid, dbid) ';
        q.ParamByName('NSK').AsInteger := SelectedID;
        q.ParamByName('ON').AsString := AgdcObject.ObjectName;
        q.ParamByName('OC').AsString := FC.gdClass.ClassName;
        q.ParamByName('ST').AsString := FC.SubType;
        q.ParamByName('XID').AsInteger := XID;
        q.ParamByName('DBID').AsInteger := DBID;
        q.ExecQuery;

        if BL <> nil then
        begin
          for I := 1 to BL.Count - 1 do
          begin
            gdcBaseManager.GetRUIDByID(AgdcObject.GetIDForBookmark(BL[I]), XID, DBID, Tr);
            q.ParamByName('XID').AsInteger := XID;
            q.ParamByName('DBID').AsInteger := DBID;
            q.ExecQuery;
          end;
        end;
      end;

      q.Close;
      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;}
  end;
end;

end.
