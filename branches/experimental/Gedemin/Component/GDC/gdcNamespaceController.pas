unit gdcNamespaceController;

interface

uses
  DB, ContNrs, IBDatabase, IBSQL, gdcBase, DBGrids, gd_KeyAssoc, gsNSObjects,
  at_dlgToNamespace_unit;

type
  TgdcNamespaceController = class(TObject)
  private
    FPrevNSID: Integer;
    FPrevNSName: String;
    FCurrentNSID: Integer;
    FAlwaysOverwrite: Boolean;
    FDontRemove: Boolean;
    FIncludeSiblings: Boolean;
    FNSObjects: TgsNSObjects;

    procedure DeleteFromNamespace;
    procedure MoveBetweenNamespaces;
    procedure _AddToNamespace;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Setup(AnObject: TgdcBase; ABL: TBookmarkList);
    //function Include(ANSRecord: TNSRecord): Boolean;
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
  FNSObjects := TgsNSObjects.Create;
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
  FNSObjects.Free;
  inherited;
end;

{
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
      q := TIBSQL.Create(nil);
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
}

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
begin
  FNSObjects.Setup(AnObject, ABL);
end;

function TgdcNamespaceController.ShowDialog: Boolean;
var
  Dlg: TdlgToNamespace;
begin
  Result := False;

  if (FNSObjects.NSList.ObjectCount >= 1) and (FNSObjects.GetNamespaceCount = 0) then
  begin
    Dlg := TdlgToNamespace.Create(nil);
    try
      Dlg.chbxAlwaysOverwrite.Checked := FAlwaysOverwrite;
      Dlg.chbxDontRemove.Checked := FDontRemove;
      Dlg.chbxIncludeSiblings.Checked := FIncludeSiblings;

      FNSObjects.InitView(Dlg);

      if Dlg.ShowModal = mrOk then
      begin
        FAlwaysOverwrite := Dlg.chbxAlwaysOverwrite.Checked;
        FDontRemove := Dlg.chbxDontRemove.Checked;
        FIncludeSiblings := Dlg.chbxIncludeSiblings.Checked;
        FCurrentNSID := Dlg.lkupNS.CurrentKeyInt;
      end;
    finally
      Dlg.Free;
    end;
  end
  else if (FNSObjects.NSList.ObjectCount > 1) and (FNSObjects.GetNamespaceCount > 1) then
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
