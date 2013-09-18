unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, gdcBaseInterface, gdcBase, DBCtrls, Buttons,
  gd_createable_form, ExtCtrls, gdcNamespaceController;

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
    procedure actOKExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

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
begin
  FgdcNamespaceController.Setup(AnObject, ABL);

  chbxAlwaysOverwrite.Checked := FgdcNamespaceController.AlwaysOverwrite;
  chbxDontRemove.Checked := FgdcNamespaceController.DontRemove;
  chbxIncludeSiblings.Checked := FgdcNamespaceController.IncludeSiblings;
  chbxIncludeLinked.Checked := FgdcNamespaceController.IncludeLinked;
  edObjectName.Text := FgdcNamespaceController.ObjectName;
  dsLink.DataSet := FgdcNamespaceController.ibdsLink;
  lkupNS.CurrentKeyInt := FgdcNamespaceController.PrevNSID;
end;

procedure TdlgToNamespace.actOKExecute(Sender: TObject);
begin
  FgdcNamespaceController.AlwaysOverwrite := chbxAlwaysOverwrite.Checked;
  FgdcNamespaceController.DontRemove := chbxDontRemove.Checked;
  FgdcNamespaceController.IncludeSiblings := chbxIncludeSiblings.Checked;
  FgdcNamespaceController.IncludeLinked := chbxIncludeLinked.Checked;
  FgdcNamespaceController.CurrentNSID := lkupNS.CurrentKeyInt;
  FgdcNamespaceController.Include;
  ModalResult := mrOk;
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
  actOk.Enabled := lkupNS.CurrentKeyInt <> FgdcNamespaceController.PrevNSID;
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

end.
