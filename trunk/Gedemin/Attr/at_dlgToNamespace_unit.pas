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
    procedure actShowLinkUpdate(Sender: TObject);
    procedure lkupChange(Sender: TObject);
    
  private
    FgdcObject: TgdcBase;
    FClearId: Integer;
    FBL: TBookmarkList;
    FCheckList: TStringList;

    procedure DeleteObject;
    procedure AddObjects;
    procedure CheckLink;
    procedure DeleteLinkObject;
  protected
    procedure CreateFields;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    
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

constructor TdlgToNamespace.Create(AnOwner: TComponent);
begin
  inherited;
  FCheckList := TStringList.Create;
end;

destructor TdlgToNamespace.Destroy;
begin
  FCheckList.Free;
  inherited;
end;

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
  cdsLink.FieldByName('displayname').DisplayLabel := '�����/��� �������/������������ ����';
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

  FClearId := -1;

  KSA := TgdKeyStringAssoc.Create;
  try
    TgdcNamespace.SetNamespaceForObject(FgdcObject, KSA, IBTransaction);
    if KSA.Count > 0 then
    begin  
      lkup.CurrentKeyInt := KSA[0];
      FClearId := KSA[0];
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
      edObjectName.Text := edObjectName.Text + ' � ��� ' +
        IntToStr(BL.Count - 1) + ' ������(�, ��)';
  end;
end;

procedure TdlgToNamespace.DeleteObject;
var
  gdcNamespace: TgdcNamespace; 
begin
  gdcNamespace := TgdcNamespace.Create(nil);
  try
    gdcNamespace.Transaction := IBTransaction;
    gdcNamespace.SubSet := 'ByID';
    gdcNamespace.ID := FClearID;
    gdcNamespace.Open;

    if not gdcNamespace.Eof then
      gdcNamespace.DeleteObject(FgdcObject.GetRUID.XID, FgdcObject.GetRUID.DBID, False);
  finally
    gdcNamespace.Free;
  end;
end;

procedure TdlgToNamespace.DeleteLinkObject;
var
  gdcNamespace: TgdcNamespace;
  RUID: String;
  I: Integer;
begin   
  gdcNamespace := TgdcNamespace.Create(nil);
  try
    gdcNamespace.Transaction := IBTransaction;
    gdcNamespace.SubSet := 'ByID';
    gdcNamespace.ID := lkup.CurrentKeyInt;
    gdcNamespace.Open;

    if not gdcNamespace.Eof then
    begin
      for I := 0 to FCheckList.Count - 1 do
      begin
        if dbgrListLink.CheckBox.CheckList.IndexOf(FCheckList[I]) = -1 then
        begin
          RUID := gdcBaseManager.GetRUIDStringByID(StrToInt(FCheckList[I]), IBTransaction);
          gdcNamespace.DeleteObject(StrToRUID(RUID).XID, StrToRUID(RUID).DBID, False);
        end;
      end;
    end;
  finally
    gdcNamespace.Free;
  end;
end;

procedure TdlgToNamespace.CheckLink;
begin
  cdsLink.DisableControls;
  try
    dbgrListLink.CheckBox.Clear;
    FCheckList.Clear;

    cdsLink.First;
    while not cdsLink.Eof do
    begin
      if not cdsLink.FieldByName('namespacekey').IsNull
        and (dbgrListLink.CheckBox.CheckList.IndexOf(cdsLink.FieldByName('id').AsString) = -1)
        and (lkup.CurrentKey = cdsLink.FieldByName('namespacekey').AsString)
      then
      begin
        dbgrListLink.CheckBox.AddCheck(cdsLink.FieldByName('id').AsString);
        FCheckList.Add(cdsLink.FieldByName('id').AsString);
      end;
      cdsLink.Next;
    end;
  finally
    cdsLink.First;
    cdsLink.EnableControls;
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
    begin
      cdsLink.First;
      CheckLink;
    end;   
  finally
    cdsLink.EnableControls;
  end;
end;

procedure TdlgToNamespace.actOKExecute(Sender: TObject);
begin
  if lkup.CurrentKey > '' then
  begin
    AddObjects;
    if (FCheckList.Count > 0) then
      DeleteLinkObject;
  end else
    if FClearId > -1 then
      DeleteObject;

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

procedure TdlgToNamespace.actShowLinkUpdate(Sender: TObject);
begin
  actShowLink.Enabled := (FgdcObject <> nil)
    and FgdcObject.Active
    and (not FgdcObject.EOF);
end;

procedure TdlgToNamespace.lkupChange(Sender: TObject);
begin
  if lkup.CurrentKey > '' then
    CheckLink;
end;

end.
