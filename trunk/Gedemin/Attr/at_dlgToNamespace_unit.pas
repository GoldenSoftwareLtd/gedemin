unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, dmDatabase_unit, gdcBaseInterface, gdcBase,
  DBCtrls, Buttons, gd_createable_form, xSpin, ExtCtrls, IBCustomDataSet;

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
    cbIncludeSiblings: TCheckBox;
    cbDontRemove: TCheckBox;
    cbAlwaysOverwrite: TCheckBox;
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
      cbAlwaysOverwrite.Checked := q.FieldByName('alwaysoverwrite').AsInteger <> 0;
      cbDontRemove.Checked := q.FieldByName('dontremove').AsInteger <> 0;
      cbIncludeSiblings.Checked := q.FieldByName('includesiblings').AsInteger <> 0;
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
begin
  gdcNamespaceObject := TgdcNamespaceObject.Create(nil);
  try
    gdcNamespaceObject.ReadTransaction := ibtr;
    gdcNamespaceObject.Transaction := ibtr;
    gdcNamespaceObject.SubSet := 'ByObject';

    if (FPrevNSID > -1) and (lkupNS.CurrentKeyInt = -1) then
    begin
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
      ibdsLink.Close;
      ibdsLink.Open;

      ibdsLink.First;
      while not ibdsLink.EOF do
      begin
        ibdsLink.Next;
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
