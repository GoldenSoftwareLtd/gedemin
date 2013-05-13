unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, dmDatabase_unit, gdcBaseInterface, gdcBase,
  DBCtrls, Buttons, gd_createable_form, xSpin, ExtCtrls;

type
  TdlgToNamespace = class(TCreateableForm)
    cdsLink: TClientDataSet;
    dsMain: TDataSource;
    ActionList: TActionList;
    actShowLink: TAction;
    actOK: TAction;
    actCancel: TAction;
    actClear: TAction;
    pnlGrid: TPanel;
    dbgrListLink: TgsDBGrid;
    pnlTop: TPanel;
    cbIncludeSiblings: TCheckBox;
    cbDontRemove: TCheckBox;
    cbAlwaysOverwrite: TCheckBox;
    lkup: TgsIBLookupComboBox;
    lMessage: TLabel;
    pnlButtons: TPanel;
    Label1: TLabel;
    btnDelete: TBitBtn;
    Panel1: TPanel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    IBTransaction: TIBTransaction;
    Label2: TLabel;
    edObjectName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure actShowLinkExecute(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure lkupChange(Sender: TObject);
    procedure actShowLinkUpdate(Sender: TObject);
    
  private
    FgdcObject: TgdcBase;
    FIsAdded: Boolean;
    FClearId: Integer;
    FBL: TBookmarkList;

    procedure DeleteObjects;
    procedure AddObjects;

  protected
    procedure CreateFields;

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

const
  DefCount = 60;

procedure TdlgToNamespace.FormCreate(Sender: TObject);
begin
  IBTransaction.DefaultDatabase := dmDatabase.ibdbGAdmin;
  CreateFields;

  cdsLink.CreateDataSet;
  cdsLink.FieldByName('id').Visible := False;
  cdsLink.FieldByName('class').Visible := True;
  cdsLink.FieldByName('class').DisplayWidth := 24;
  cdsLink.FieldByName('subtype').Visible := True;
  cdsLink.FieldByName('subtype').DisplayWidth := 24;
  cdsLink.FieldByName('name').Visible := True;
  cdsLink.FieldByName('name').DisplayWidth := 40;
  cdsLink.FieldByName('namespace').Visible := True;
  cdsLink.FieldByName('namespace').DisplayWidth := 40;
  cdsLink.FieldByName('namespacekey').Visible := False;
  cdsLink.FieldByName('headobject').Visible := False;
  cdsLink.FieldByName('displayname').Visible := False;
  cdsLink.FieldByName('displayname').DisplayLabel := 'Класс/Имя объекта/Пространство имен';
  cdsLink.Open;

  cbAlwaysOverwrite.Checked := True;
  cbDontRemove.Checked := False;
  cbIncludeSiblings.Checked := False;
end;

procedure TdlgToNamespace.CreateFields;
begin
  cdsLink.FieldDefs.Add('id', ftInteger, 0, True);
  cdsLink.FieldDefs.Add('displayname', ftString, 255, False);
  cdsLink.FieldDefs.Add('class', ftString, 60, True);
  cdsLink.FieldDefs.Add('subtype', ftString, 60, False);
  cdsLink.FieldDefs.Add('name', ftString, 60, False);
  cdsLink.FieldDefs.Add('namespace', ftString, 255, False);
  cdsLink.FieldDefs.Add('namespacekey', ftInteger, 0, False);
  cdsLink.FieldDefs.Add('headobject', ftString, 21, False);
end;

procedure TdlgToNamespace.SetupParams(AnObject: TgdcBase; BL: TBookmarkList);
var
  q: TIBSQL;
  KSA: TgdKeyStringAssoc;
begin
  Assert(gdcBaseManager <> nil);
  Assert(not AnObject.EOF);

  FgdcObject := AnObject;
  FBL := BL;

  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  FIsAdded := False;
  FClearId := -1;

  KSA := TgdKeyStringAssoc.Create;
  try
    TgdcNamespace.SetNamespaceForObject(FgdcObject, KSA, IBTransaction);
    if KSA.Count > 0 then
    begin
      FIsAdded := True;
      lkup.CurrentKeyInt := KSA[0];
      q := TIBSQL.Create(nil);
      try
        q.Transaction := IBTransaction;
        q.SQL.Text := 'SELECT * FROM at_object WHERE xid = :xid AND dbid = :dbid';
        q.ParamByName('xid').AsInteger := FgdcObject.GetRuid.XID;
        q.ParamByName('dbid').AsInteger := FgdcObject.GetRuid.DBID;
        q.ExecQuery;

        if not q.EOF then
        begin
          cbAlwaysOverwrite.Checked := q.FieldByName('alwaysoverwrite').AsInteger = 1;
          cbDontRemove.Checked := q.FieldByName('dontremove').AsInteger = 1;
          cbIncludeSiblings.Checked := q.FieldByName('includesiblings').AsInteger = 1;
        end;
      finally
        q.Free;
      end;
    end;
  finally
    KSA.Free;
  end;

  actShowLink.Execute;

  if FgdcObject <> nil then
  begin
    edObjectName.Text := FgdcObject.ObjectName + ' ('
      + FgdcObject.GetDisplayName(FgdcObject.SubType) + ')';
    if (BL <> nil) and (BL.Count > 1) then
      edObjectName.Text := edObjectName.Text + ' и еще ' +
        IntToStr(BL.Count - 1) + ' объект(а, ов)';
  end;
end;

procedure TdlgToNamespace.DeleteObjects;
var 
  gdcNamespace: TgdcNamespace;
begin
  gdcNamespace := TgdcNamespace.Create(nil);
  try
    gdcNamespace.Transaction := IBTransaction;
    gdcNamespace.SubSet := 'ByID';
    gdcNamespace.ID := lkup.CurrentKeyInt;
    gdcNamespace.Open;

    if not gdcNamespace.Eof then
      gdcNamespace.DeleteObject(FgdcObject.GetRUID.XID, FgdcObject.GetRUID.DBID);
  finally
    gdcNamespace.Free;
  end;
end;

procedure TdlgToNamespace.AddObjects;
var
  I: Integer;  
  Bm: String;
  InstObj: TgdcBase;
  InstClass: TPersistentClass;
  gdcNamespace: TgdcNamespace;
  OL: TObjectList;
begin
  gdcNamespace := TgdcNamespace.CreateSingularByID(nil,
    IBTransaction.DefaultDatabase, IBTransaction, lkup.CurrentKeyInt) as TgdcNamespace;
  OL := TObjectList.Create(True);
  try
    for I := dbgrListLink.CheckBox.CheckList.Count - 1 downto 0 do
    begin
      if cdsLink.Locate('id', dbgrListLink.CheckBox.CheckList[I], []) then
      begin
         InstClass := GetClass(cdsLink.FieldByName('class').AsString);
         if (InstClass <> nil) and InstClass.InheritsFrom(TgdcBase) then
         begin
           InstObj := CgdcBase(InstClass).CreateSubType(nil,
             cdsLink.FieldByName('subtype').AsString, 'ByID');
           try
             InstObj.ID := cdsLink.FieldByName('id').AsInteger;
             InstObj.Open;
             if not InstObj.EOF then
             begin
               gdcNamespace.AddObject2(InstObj, OL,
                 cdsLink.FieldByName('headobject').AsString,
                 Integer(cbAlwaysOverwrite.Checked),
                 Integer(cbDontRemove.Checked),
                 Integer(cbIncludeSiblings.Checked));
             end;
           finally
             InstObj.Free;
           end;
         end;
      end;
    end;

    if (FgdcObject.State in [dsEdit, dsInsert]) or (FBL = nil) then
      gdcNamespace.AddObject2(FgdcObject, OL, '',
        Integer(cbAlwaysOverwrite.Checked),
        Integer(cbDontRemove.Checked),
        Integer(cbIncludeSiblings.Checked))
    else begin
      Bm := FgdcObject.Bookmark;
      FgdcObject.DisableControls;
      try
        if FBL <> nil then
        begin
          FBL.Refresh;
          for I := 0 to FBL.Count - 1 do
          begin
            FgdcObject.Bookmark := FBL[I];
            gdcNamespace.AddObject2(FgdcObject, OL, '',
              Integer(cbAlwaysOverwrite.Checked),
              Integer(cbDontRemove.Checked),
              Integer(cbIncludeSiblings.Checked));
          end;
        end else
        begin
          gdcNamespace.AddObject2(FgdcObject, OL, '',
            Integer(cbAlwaysOverwrite.Checked),
            Integer(cbDontRemove.Checked),
            Integer(cbIncludeSiblings.Checked));
        end;
      finally
        FgdcObject.Bookmark := Bm;
        FgdcObject.EnableControls;
      end;
    end;
  finally
    OL.Free;
    gdcNamespace.Free;
  end;
end;

procedure TdlgToNamespace.actShowLinkExecute(Sender: TObject);
var
  I: Integer;
  Bm: String;
begin
  cdsLink.DisableControls;
  try
    cdsLink.EmptyDataSet;

    if (FgdcObject.State in [dsEdit, dsInsert]) or (FBL = nil) then
      TgdcNamespace.SetObjectLink(FgdcObject, cdsLink, IBTransaction)
    else begin
      Bm := FgdcObject.Bookmark;
      FgdcObject.DisableControls;
      try
        if Assigned(FBL) then
        begin
          FBL.Refresh;
          for I := 0 to FBL.Count - 1 do
          begin
            FgdcObject.Bookmark := FBL[I];
            TgdcNamespace.SetObjectLink(FgdcObject, cdsLink, IBTransaction);
          end;
        end else
          TgdcNamespace.SetObjectLink(FgdcObject, cdsLink, IBTransaction);
      finally
        FgdcObject.Bookmark := Bm;
        FgdcObject.EnableControls;
      end;
    end;

    if cdsLink.Active then
      cdsLink.First;
  finally
    cdsLink.EnableControls;
  end;
end;

procedure TdlgToNamespace.actOKExecute(Sender: TObject);
begin
  if lkup.CurrentKey > '' then
    AddObjects
  else
    if FIsAdded then
      DeleteObjects;

  if IBTransaction.InTransaction then
    IBTransaction.Commit;
  ModalResult := mrOk;
end;

procedure TdlgToNamespace.actCancelExecute(Sender: TObject);
begin
  if IBTransaction.InTransaction then
    IBTransaction.Rollback;
  ModalResult := mrCancel;
end;

procedure TdlgToNamespace.actClearExecute(Sender: TObject);
begin
  if lkup.CurrentKey > '' then
    FClearId := lkup.CurrentKeyInt;
  lkup.CurrentKey := '';
end;

procedure TdlgToNamespace.lkupChange(Sender: TObject);
begin
  if lkup.Currentkey > '' then
    FClearId := -1;
end;

procedure TdlgToNamespace.actShowLinkUpdate(Sender: TObject);
begin
  actShowLink.Enabled := (FgdcObject <> nil)
    and FgdcObject.Active
    and (not FgdcObject.EOF);
end;

end.
