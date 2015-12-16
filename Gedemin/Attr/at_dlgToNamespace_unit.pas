unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, gdcBaseInterface, gdcBase, DBCtrls, Buttons,
  gd_createable_form, ExtCtrls, gdcNamespaceController, Tabs;

type
  TdlgToNamespace = class(TCreateableForm)
    dsLink: TDataSource;
    ActionList: TActionList;
    actOK: TAction;
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
    Label2: TLabel;
    edObjectName: TEdit;
    btnClear: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    chbxIncludeLinked: TCheckBox;
    Tr: TIBTransaction;
    tsObjects: TTabSet;
    procedure actOKExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tsObjectsChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);

  private
    FgdcNamespaceController: TgdcNamespaceController;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupObject(AnObject: TgdcBase; ABL: TBookmarkList);
  end;

var
  dlgToNamespace: TdlgToNamespace;

implementation

{$R *.DFM}

procedure TdlgToNamespace.SetupObject(AnObject: TgdcBase; ABL: TBookmarkList);
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    FgdcNamespaceController.Setup(AnObject, ABL);
  finally
    Screen.Cursor := OldCursor;
  end;

  tsObjects.Tabs.Assign(FgdcNamespaceController.Tabs);
  tsObjects.TabIndex := 0;

  chbxAlwaysOverwrite.Checked := FgdcNamespaceController.AlwaysOverwrite;
  chbxDontRemove.Checked := FgdcNamespaceController.DontRemove;
  chbxIncludeSiblings.Checked := FgdcNamespaceController.IncludeSiblings;
  chbxIncludeLinked.Checked := FgdcNamespaceController.IncludeLinked;
  edObjectName.Text := FgdcNamespaceController.ObjectName;
  lkupNS.CurrentKeyInt := FgdcNamespaceController.PrevNSID;
end;

procedure TdlgToNamespace.actOKExecute(Sender: TObject);
begin
  FgdcNamespaceController.AlwaysOverwrite := chbxAlwaysOverwrite.Checked;
  FgdcNamespaceController.DontRemove := chbxDontRemove.Checked;
  FgdcNamespaceController.IncludeSiblings := chbxIncludeSiblings.Checked;
  FgdcNamespaceController.IncludeLinked := chbxIncludeLinked.Checked;
  FgdcNamespaceController.CurrentNSID := lkupNS.CurrentKeyInt;
  if FgdcNamespaceController.Include then
    ModalResult := mrOk
  else
    ModalResult := mrCancel;
end;

procedure TdlgToNamespace.actClearExecute(Sender: TObject);
begin
  lkupNS.CurrentKey := '';
end;

procedure TdlgToNamespace.actClearUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FgdcNamespaceController.Enabled
    and (lkupNS.CurrentKey > '');
end;

procedure TdlgToNamespace.actOKUpdate(Sender: TObject);
begin
  actOk.Enabled := FgdcNamespaceController.Enabled
    and (lkupNS.CurrentKeyInt <> FgdcNamespaceController.PrevNSID);
end;

destructor TdlgToNamespace.Destroy;
begin
  FgdcNamespaceController.Free;
  inherited;
end;

constructor TdlgToNamespace.Create(AnOwner: TComponent);
begin
  inherited;
  FgdcNamespaceController := TgdcNamespaceController.Create;
end;

procedure TdlgToNamespace.FormCreate(Sender: TObject);
begin
  Assert(gdcBaseManager <> nil);
  Tr.DefaultDatabase := gdcBaseManager.Database;
  Tr.StartTransaction;
end;

procedure TdlgToNamespace.FormDestroy(Sender: TObject);
begin
  if Tr.InTransaction then
    Tr.Commit;
end;

procedure TdlgToNamespace.tsObjectsChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  dsLink.DataSet := FgdcNamespaceController.SetupDS(NewTab);
end;

end.
