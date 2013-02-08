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
    bShowLink: TButton;
    lLimit: TLabel;
    cbIncludeSiblings: TCheckBox;
    cbDontRemove: TCheckBox;
    cbAlwaysOverwrite: TCheckBox;
    lkup: TgsIBLookupComboBox;
    lMessage: TLabel;
    pnlButtons: TPanel;
    Label1: TLabel;
    eLimit: TxSpinEdit;
    btnDelete: TBitBtn;
    Panel1: TPanel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    IBTransaction: TIBTransaction;
    procedure FormCreate(Sender: TObject);
    procedure actShowLinkExecute(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure lkupChange(Sender: TObject);
  private
    FgdcObject: TgdcBase;
    FIsAdded: Boolean;
    FClearId: Integer; 

    procedure DeleteObjects;
    procedure AddObjects;
    procedure OnChecked(Sender: TObject; CheckID: String;
      var Checked: Boolean);

  protected
    procedure CreateFields;

  public
    procedure Setup(AnObject: TObject); override;
  end;

var
  dlgToNamespace: TdlgToNamespace;

implementation

uses
  at_classes, gd_security, at_sql_parser, IBSQL, Storages, gdcNamespace, gd_KeyAssoc;

{$R *.DFM}

const
  DefCount = 60;

procedure TdlgToNamespace.FormCreate(Sender: TObject);
begin
  CreateFields;

  cdsLink.CreateDataSet;
  cdsLink.Open;
  cdsLink.EmptyDataSet;

  dbgrListLink.CheckBox.CheckBoxEvent := OnChecked;
  cbAlwaysOverwrite.Checked := True;
  cbDontRemove.Checked := False;
  cbIncludeSiblings.Checked := False;
end;

procedure TdlgToNamespace.CreateFields;
begin
  cdsLink.FieldDefs.Add('ID', ftInteger, 0, True);
  cdsLink.FieldDefs.Add('Name', ftString, 60, False);
  cdsLink.FieldDefs.Add('Class', ftString, 40, True);
  cdsLink.FieldDefs.Add('SubType', ftString, 60, False);
  cdsLink.FieldDefs.Add('Namespacekey', ftInteger, 0, False);
  cdsLink.FieldDefs.Add('Namespace', ftString, 255, False);
end;

procedure TdlgToNamespace.Setup(AnObject: TObject);
var
  q: TIBSQL;
  KSA: TgdKeyStringAssoc;
begin
  Assert(gdcBaseManager <> nil);
  Assert(AnObject is TgdcBase);
  Assert(not (AnObject as TgdcBase).EOF);

  FgdcObject := AnObject as TgdcBase;

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
end;

procedure TdlgToNamespace.DeleteObjects;
var
  I: Integer;
  KA: TgdKeyArray;
begin
  KA := TgdKeyArray.Create;
  try
    KA.Add(FgdcObject.ID);
    for I := 0 to dbgrListLink.CheckBox.CheckList.Count - 1 do
      KA.Add(StrToInt(dbgrListLink.CheckBox.CheckList[I]));

    TgdcNamespace.DeleteObjectsFromNamespace(lkup.Currentkeyint, KA, IBTransaction);
  finally
    KA.Free;
  end;
end;

procedure TdlgToNamespace.AddObjects;
var
  I: Integer;
  q: TIBSQL;
  XID, DBID: TID;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := IBTransaction;
    q.SQL.Text :=
      'UPDATE OR INSERT INTO at_object ' +
      '  (namespacekey, objectname, objectclass, subtype, xid, dbid, ' +
      '  alwaysoverwrite, dontremove, includesiblings) ' +
      'VALUES (:NSK, :ON, :OC, :ST, :XID, :DBID, :OW, :DR, :IS) ' +
      'MATCHING (xid, dbid, namespacekey)';
    q.ParamByName('NSK').AsInteger := lkup.CurrentKeyInt;
    q.ParamByName('ON').AsString := FgdcObject.FieldByName(FgdcObject.GetListField(FgdcObject.SubType)).AsString;
    q.ParamByName('OC').AsString := FgdcObject.ClassName;
    q.ParamByName('ST').AsString := FgdcObject.SubType;
    gdcBaseManager.GetRUIDByID(FgdcObject.ID, XID, DBID, IBTransaction);
    q.ParamByName('XID').AsInteger := XID;;
    q.ParamByName('DBID').AsInteger := DBID;
    q.ParamByName('OW').AsInteger := Integer(cbAlwaysOverwrite.Checked);
    q.ParamByName('DR').AsInteger := Integer(cbDontRemove.Checked);
    q.ParamByName('IS').AsInteger := Integer(cbIncludeSiblings.Checked);
    q.ExecQuery;

    q.Close;

    for I := 0 to dbgrListLink.CheckBox.CheckList.Count - 1 do
    begin
      if cdsLink.Locate('id', StrToInt(dbgrListLink.CheckBox.CheckList[I]), []) then
      begin
        q.ParamByName('NSK').AsInteger := lkup.CurrentKeyInt;
        q.ParamByName('ON').AsString := cdsLink.FieldByName('name').AsString;
        q.ParamByName('OC').AsString := cdsLink.FieldByName('class').AsString;
        q.ParamByName('ST').AsString := cdsLink.FieldByName('subtype').AsString;
        gdcBaseManager.GetRUIDByID(cdsLink.FieldByName('id').AsInteger, XID, DBID, IBTransaction);

        q.ParamByName('XID').AsInteger := XID;
        q.ParamByName('DBID').AsInteger := DBID;
        q.ExecQuery;
        q.Close;
      end;
    end;
  finally
    q.Free;
  end;
end;

procedure TdlgToNamespace.actShowLinkExecute(Sender: TObject);
begin
  cdsLink.DisableControls;
  try
    cdsLink.EmptyDataSet;
    TgdcNamespace.SetObjectLink(FgdcObject, cdsLink, IBTransaction);
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

procedure TdlgToNamespace.OnChecked(Sender: TObject; CheckID: String;
  var Checked: Boolean);
begin
  if not cdsLink.FieldByName('namespacekey').IsNull and not FIsAdded then
  begin
    Checked := False;
    Application.MessageBox(PChar('Нельзя добавить объект!'#13#10 +
      'Объект уже входит в пространство имен ''' + cdsLink.FieldByName('namespace').AsString + '''!'),
      'Внимание',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
  end;
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

end.
