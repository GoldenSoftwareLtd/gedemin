unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, dmDatabase_unit, gdcBaseInterface, gdcBase,
  DBCtrls, Buttons, gd_createable_form, xSpin, ExtCtrls, IBCustomDataSet,
  gdcNamespaceController;

type
  TdlgToNamespace = class(TCreateableForm)
    dsLink: TDataSource;
    ActionList: TActionList;
    actOK: TAction;
    actCancel: TAction;
    actClear: TAction;
    pnlGrid: TPanel;
    dbgrListLink: TgsDBGrid;
    pnlTop: TPanel;
    chbxIncludeSiblings: TCheckBox;
    chbxDontRemove: TCheckBox;
    chbxAlwaysOverwrite: TCheckBox;
    lkupNS: TgsIBLookupComboBox;
    lMessage: TLabel;
    pnlButtons: TPanel;
    pnlRightBottom: TPanel;
    ibtr: TIBTransaction;
    Label2: TLabel;
    edObjectName: TEdit;
    btnClear: TButton;
    btnOk: TButton;
    Button2: TButton;
    ibdsLink: TIBDataSet;
    chbxIncludeLinked: TCheckBox;
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);

  private
    FgdcObject: TgdcBase;
    FPrevNSID, FSessionID: Integer;
    FBL: TBookmarkList;

  public
    procedure SetupParams(AnObject: TgdcBase; BL: TBookmarkList);
  end;

var
  dlgToNamespace: TdlgToNamespace;

implementation

uses
  at_classes, gd_security, at_sql_parser, IBSQL, Storages, gdcNamespace, gd_KeyAssoc,
  contnrs;

{$R *.DFM}

procedure TdlgToNamespace.SetupParams(AnObject: TgdcBase; BL: TBookmarkList);
var
  q: TIBSQL;
  I: Integer;
  Bm: String;
begin
  Assert(AnObject <> nil);
  Assert(not AnObject.EOF);
  Assert(ibdsLink.State = dsInactive);
  Assert(not ibtr.InTransaction);

  ibtr.StartTransaction;

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
    q.Transaction := ibtr;
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
      lkupNS.CurrentKeyInt := q.FieldByName('id').AsInteger;
      chbxAlwaysOverwrite.Checked := q.FieldByName('alwaysoverwrite').AsInteger <> 0;
      chbxDontRemove.Checked := q.FieldByName('dontremove').AsInteger <> 0;
      chbxIncludeSiblings.Checked := q.FieldByName('includesiblings').AsInteger <> 0;
    end;
  finally
    q.Free;
  end;

  FSessionID := AnObject.GetNextID;

  if (FgdcObject.State in [dsEdit, dsInsert]) or (FBL = nil) or (FBL.Count = 0) then
    FgdcObject.GetDependencies(ibtr, FSessionID, False, ';EDITORKEY;CREATORKEY;')
  else begin
    FgdcObject.DisableControls;
    try
      Bm := FgdcObject.Bookmark;
      for I := 0 to FBL.Count - 1 do
      begin
        FgdcObject.Bookmark := FBL[I];
        FgdcObject.GetDependencies(ibtr, FSessionID, False, ';EDITORKEY;CREATORKEY;');
      end;
      FgdcObject.Bookmark := Bm;
    finally
      FgdcObject.EnableControls;
    end;
  end;

  dsLink.DataSet := nil;

  ibdsLink.ParamByName('sid').AsInteger := FSessionID;
  ibdsLink.Open;

  ibdsLink.FieldByName('id').Visible := False;
  ibdsLink.FieldByName('reflevel').Visible := False;
  ibdsLink.FieldByName('class').Visible := False;
  ibdsLink.FieldByName('subtype').Visible := False;
  ibdsLink.FieldByName('name').Visible := False;
  ibdsLink.FieldByName('namespacekey').Visible := False;
  ibdsLink.FieldByName('namespace').Visible := False;
  ibdsLink.FieldByName('headobject').Visible := False;
  ibdsLink.FieldByName('editiondate').Visible := False;
  ibdsLink.FieldByName('displayname').DisplayLabel := 'Класс - Имя объекта (Пространство имен)';

  dsLink.DataSet := ibdsLink;

  edObjectName.Text := FgdcObject.ObjectName + ' ('
    + FgdcObject.GetDisplayName(FgdcObject.SubType) + ')';
  if (FBL <> nil) and (FBL.Count > 1) then
    edObjectName.Text := edObjectName.Text + ' и еще ' +
      IntToStr(FBL.Count - 1) + ' объект(а, ов)';
end;

procedure TdlgToNamespace.actOKExecute(Sender: TObject);
var
  gdcNamespaceObject: TgdcNamespaceObject;
  HeadObjectKey, HeadObjectPos: Integer;
  q: TIBSQL;
begin
  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  try
    gdcNamespaceObject.ReadTransaction := ibtr;
    gdcNamespaceObject.Transaction := ibtr;

    if (FPrevNSID > -1) and (lkupNS.CurrentKeyInt = -1) then
    begin
      gdcNamespaceObject.SubSet := 'ByObject';
      gdcNamespaceObject.ParamByName('namespacekey').AsInteger := FPrevNSID;
      gdcNamespaceObject.ParamByName('xid').AsInteger := FgdcObject.GetRUID.XID;
      gdcNamespaceObject.ParamByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
      gdcNamespaceObject.Open;
      if not gdcNamespaceObject.EOF then
        gdcNamespaceObject.Delete;
    end
    else if (FPrevNSID > -1) and (lkupNS.CurrentKeyInt > -1)
      and (FPrevNSID <> lkupNS.CurrentKeyInt) then
    begin
      gdcNamespaceObject.SubSet := 'ByObject';
      gdcNamespaceObject.ParamByName('namespacekey').AsInteger := FPrevNSID;
      gdcNamespaceObject.ParamByName('xid').AsInteger := FgdcObject.GetRUID.XID;
      gdcNamespaceObject.ParamByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
      gdcNamespaceObject.Open;
      if not gdcNamespaceObject.EOF then
      begin
        gdcNamespaceObject.Edit;
        gdcNamespaceObject.FieldByName('namespacekey').AsInteger := lkupNS.CurrentKeyInt;
        gdcNamespaceObject.Post;
      end;
    end
    else if (FPrevNSID = -1) and (lkupNS.CurrentKeyInt > -1) then
    begin
      gdcNamespaceObject.SubSet := 'All';
      gdcNamespaceObject.Open;
      gdcNamespaceObject.Insert;
      gdcNamespaceObject.FieldByName('namespacekey').AsInteger := lkupNS.CurrentKeyInt;
      gdcNamespaceObject.FieldByName('objectname').AsString := FgdcObject.ObjectName;
      gdcNamespaceObject.FieldByName('objectclass').AsString := FgdcObject.ClassName;
      gdcNamespaceObject.FieldByName('subtype').AsString := FgdcObject.SubType;
      gdcNamespaceObject.FieldByName('xid').AsInteger := FgdcObject.GetRUID.XID;
      gdcNamespaceObject.FieldByName('dbid').AsInteger := FgdcObject.GetRUID.DBID;
      gdcNamespaceObject.FieldByName('objectpos').Clear;
      if chbxAlwaysOverwrite.Checked then
        gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 1
      else
        gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 0;
      if chbxDontRemove.Checked then
        gdcNamespaceObject.FieldByName('dontremove').AsInteger := 1
      else
        gdcNamespaceObject.FieldByName('dontremove').AsInteger := 0;
      if chbxIncludeSiblings.Checked then
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

      HeadObjectKey := gdcNamespaceObject.ID;
      HeadObjectPos := gdcNamespaceObject.FieldByName('objectpos').AsInteger;

      ibdsLink.Close;
      ibdsLink.Open;

      q := TIBSQL.Create(nil);
      try
        q.Transaction := ibtr;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey) ' +
          '  VALUES (:nsk, :uk) ' +
          '  MATCHING (namespacekey, useskey) ';
        q.ParamByName('nsk').AsInteger := lkupNS.CurrentKeyInt;

        ibdsLink.Last;
        while not ibdsLink.BOF do
        begin
          if ibdsLink.FieldByName('namespacekey').IsNull then
          begin
            gdcNamespaceObject.Insert;
            gdcNamespaceObject.FieldByName('namespacekey').AsInteger := lkupNS.CurrentKeyInt;
            gdcNamespaceObject.FieldByName('objectname').AsString := ibdsLink.FieldByName('name').AsString;
            gdcNamespaceObject.FieldByName('objectclass').AsString := ibdsLink.FieldByName('class').AsString;
            gdcNamespaceObject.FieldByName('subtype').AsString := ibdsLink.FieldByName('subtype').AsString;
            gdcNamespaceObject.FieldByName('xid').AsInteger := ibdsLink.FieldByName('xid').AsInteger;
            gdcNamespaceObject.FieldByName('dbid').AsInteger := ibdsLink.FieldByName('dbid').AsInteger;
            gdcNamespaceObject.FieldByName('objectpos').AsInteger := HeadObjectPos;
            if chbxAlwaysOverwrite.Checked then
              gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 1
            else
              gdcNamespaceObject.FieldByName('alwaysoverwrite').AsInteger := 0;
            if chbxDontRemove.Checked then
              gdcNamespaceObject.FieldByName('dontremove').AsInteger := 1
            else
              gdcNamespaceObject.FieldByName('dontremove').AsInteger := 0;
            if chbxIncludeSiblings.Checked then
              gdcNamespaceObject.FieldByName('includesiblings').AsInteger := 1
            else
              gdcNamespaceObject.FieldByName('includesiblings').AsInteger := 0;
            gdcNamespaceObject.FieldByName('headobjectkey').AsInteger := HeadObjectKey;
            if ibdsLink.FieldByName('editiondate').IsNull then
            begin
              gdcNamespaceObject.FieldByName('modified').AsDateTime := Now;
              gdcNamespaceObject.FieldByName('curr_modified').AsDateTime := Now;
            end else
            begin
              gdcNamespaceObject.FieldByName('modified').AsDateTime :=
                ibdsLink.FieldByName('editiondate').AsDateTime;
              gdcNamespaceObject.FieldByName('curr_modified').AsDateTime :=
                ibdsLink.FieldByName('editiondate').AsDateTime;
            end;
            gdcNamespaceObject.Post;
          end
          else if ibdsLink.FieldByName('namespacekey').AsInteger <> lkupNS.CurrentKeyInt then
          begin
            q.ParamByName('uk').AsInteger := ibdsLink.FieldByName('namespacekey').AsInteger;
            q.ExecQuery;
          end;

          ibdsLink.Prior;
        end;
      finally
        q.Free;
      end;
    end;
  finally
    gdcNamespaceObject.Free;
  end;

  if ibtr.InTransaction then
    ibtr.Commit;

  ModalResult := mrOk;
end;

procedure TdlgToNamespace.actCancelExecute(Sender: TObject);
begin
  if ibtr.InTransaction then
    ibtr.Rollback;

  ModalResult := mrCancel;
end;

procedure TdlgToNamespace.actClearExecute(Sender: TObject);
begin
  lkupNS.CurrentKey := '';
end;

procedure TdlgToNamespace.actClearUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lkupNS.CurrentKey > '';
end;

procedure TdlgToNamespace.actOKUpdate(Sender: TObject);
begin
  actOk.Enabled := lkupNS.CurrentKeyInt <> FPrevNSID;
end;

end.
