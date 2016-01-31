unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, gdcBaseInterface, gdcBase, DBCtrls, Buttons,
  gd_createable_form, ExtCtrls, gdcNamespaceController, Tabs, Menus;

type
  TdlgToNamespace = class(TCreateableForm)
    dsLink: TDataSource;
    ActionList: TActionList;
    actOK: TAction;
    pnlGrid: TPanel;
    pnlButtons: TPanel;
    pnlRightBottom: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Tr: TIBTransaction;
    pm: TPopupMenu;
    actAddSelected: TAction;
    N1: TMenuItem;
    btnHelp: TButton;
    actHelp: TAction;
    pnlObj: TPanel;
    pnlState: TPanel;
    pnlTop: TPanel;
    lMessage: TLabel;
    chbxIncludeSiblings: TCheckBox;
    chbxDontRemove: TCheckBox;
    chbxAlwaysOverwrite: TCheckBox;
    lkupNS: TgsIBLookupComboBox;
    chbxIncludeLinked: TCheckBox;
    chbxDontModify: TCheckBox;
    pnlInfo: TPanel;
    mInfo: TMemo;
    Panel2: TPanel;
    rbDelete: TRadioButton;
    rbMove: TRadioButton;
    rbChangeProp: TRadioButton;
    actDelete: TAction;
    pnlDependencies: TPanel;
    dbgrListLink: TgsDBGrid;
    tsObjects: TTabSet;
    actMove: TAction;
    rbPickOut: TRadioButton;
    rbAdd: TRadioButton;
    actIncludeLinked: TAction;
    actAdd: TAction;
    actChangeProperties: TAction;
    actPickOut: TAction;
    rbUpdate: TRadioButton;
    actUpdate: TAction;
    actDontModify: TAction;
    bvlDontModify: TBevel;
    procedure actOKExecute(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tsObjectsChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure actAddSelectedUpdate(Sender: TObject);
    procedure actAddSelectedExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actMoveUpdate(Sender: TObject);
    procedure actMoveExecute(Sender: TObject);
    procedure actIncludeLinkedExecute(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actChangePropertiesUpdate(Sender: TObject);
    procedure actChangePropertiesExecute(Sender: TObject);
    procedure actPickOutUpdate(Sender: TObject);
    procedure actUpdateUpdate(Sender: TObject);
    procedure actUpdateExecute(Sender: TObject);
    procedure actPickOutExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actDontModifyUpdate(Sender: TObject);
    procedure actDontModifyExecute(Sender: TObject);

  private
    FgdcNamespaceController: TgdcNamespaceController;
    FSubObjectAdded: Boolean;

  public
    procedure SetupController(NSC: TgdcNamespaceController);
  end;

var
  dlgToNamespace: TdlgToNamespace;

implementation

{$R *.DFM}

uses
  ShellAPI;

procedure TdlgToNamespace.SetupController;
begin
  FgdcNamespaceController := NSC;

  tsObjects.Tabs.Assign(FgdcNamespaceController.Tabs);
  tsObjects.TabIndex := 0;

  chbxDontModify.Checked := FgdcNamespaceController.DontModify;
  chbxAlwaysOverwrite.Checked := FgdcNamespaceController.AlwaysOverwrite;
  chbxDontRemove.Checked := FgdcNamespaceController.DontRemove;
  chbxIncludeSiblings.Checked := FgdcNamespaceController.IncludeSiblings;
  chbxIncludeLinked.Checked := FgdcNamespaceController.IncludeLinked;
  lkupNS.CurrentKeyInt := FgdcNamespaceController.PrevNSID;

  mInfo.Lines.Clear;
  mInfo.Lines.Add(FgdcNamespaceController.ObjectName);
  if FgdcNamespaceController.PrevNSID = -1 then
  begin
    if FgdcNamespaceController.MultipleObjects > 1 then
      mInfo.Lines.Add('Не входят в ПИ')
    else
      mInfo.Lines.Add('Не входит в ПИ');
  end
  else
  begin
    if FgdcNamespaceController.MultipleObjects > 1 then
      mInfo.Lines.Add('Входят в ПИ: ' +
        FgdcNamespaceController.PrevNSName)
    else
      mInfo.Lines.Add('Входит в ПИ: ' +
        FgdcNamespaceController.PrevNSName);
  end;

  if FgdcNamespaceController.HeadObjectName > '' then
    mInfo.Lines.Add('Главный объект: ' + FgdcNamespaceController.HeadObjectName);

  pnlTop.Visible := False;
  pnlDependencies.Visible := False;  
end;

procedure TdlgToNamespace.actOKExecute(Sender: TObject);
begin
  FgdcNamespaceController.DontModify := chbxDontModify.Checked;
  FgdcNamespaceController.AlwaysOverwrite := chbxAlwaysOverwrite.Checked;
  FgdcNamespaceController.DontRemove := chbxDontRemove.Checked;
  FgdcNamespaceController.IncludeSiblings := chbxIncludeSiblings.Checked;
  FgdcNamespaceController.IncludeLinked := chbxIncludeLinked.Checked;
  FgdcNamespaceController.CurrentNSID := lkupNS.CurrentKeyInt;
  ModalResult := mrOk;
end;

procedure TdlgToNamespace.actOKUpdate(Sender: TObject);
begin
  actOk.Enabled := FgdcNamespaceController.Enabled
    and
    (not FSubObjectAdded)
    and
    (
      (
        (FgdcNamespaceController.SelectedOp = nopAdd)
        and
        (lkupNS.CurrentKeyint > -1)
      )
      or
      (
        FgdcNamespaceController.SelectedOp = nopDel
      )
      or
      (
        (FgdcNamespaceController.SelectedOp = nopMove)
        and
        (lkupNS.CurrentKeyInt > -1)
        and
        (lkupNS.CurrentKeyInt <> FgdcNamespaceController.PrevNSID)
      )
      or
      (
        FgdcNamespaceController.SelectedOp = nopChangeProp
      )
      or
      (
        FgdcNamespaceController.SelectedOp = nopPickOut
      )
      or
      (
        FgdcNamespaceController.SelectedOp = nopUpdate
      )
    );
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

procedure TdlgToNamespace.actAddSelectedUpdate(Sender: TObject);
begin
  actAddSelected.Enabled := (dsLink.DataSet <> nil)
    and (dsLink.DataSet.RecordCount > 0);
end;

procedure TdlgToNamespace.actAddSelectedExecute(Sender: TObject);
begin
  FgdcNamespaceController.AddSubObject;
  FSubObjectAdded := True;
end;

procedure TdlgToNamespace.actHelpExecute(Sender: TObject);
var
  S: String;
begin
  S := 'http://gsbelarus.com/gs/wiki/index.php/%D0%94%D0%BE%D0%B1%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5/';
  S := S + '%D0%BF%D0%B5%D1%80%D0%B5%D0%BC%D0%B5%D1%89%D0%B5%D0%BD%D0%B8%D0%B5/%D1%83%D0%B4%D0%B0%D0%BB%D0%B5';
  S := S + '%D0%BD%D0%B8%D0%B5_%D0%BE%D0%B1%D1%8A%D0%B5%D0%BA%D1%82%D0%B0_%D0%BF%D1%80%D0%BE%D1%81%D1%82%D1%80';
  S := S + '%D0%B0%D0%BD%D1%81%D1%82%D0%B2%D0%B0_%D0%B8%D0%BC%D0%B5%D0%BD_%28%D0%B4%D0%B8%D0%B0%D0%BB%D0%BE%D0%B3%29';
  ShellExecute(Handle,
    'open',
    PChar(S),
    nil,
    nil,
    SW_SHOW);
end;

procedure TdlgToNamespace.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := (FgdcNamespaceController <> nil)
    and (nopDel in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actDeleteExecute(Sender: TObject);
begin
  FgdcNamespaceController.SelectedOp := nopDel;
  pnlDependencies.Visible := False;
  pnlTop.Visible := False;
end;

procedure TdlgToNamespace.actMoveUpdate(Sender: TObject);
begin
  actMove.Enabled := (FgdcNamespaceController <> nil)
    and (nopMove in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actMoveExecute(Sender: TObject);
begin
  FgdcNamespaceController.SelectedOp := nopMove;
  pnlTop.Visible := True;
  lMessage.Visible := True;
  lkupNS.Visible := True;
  pnlDependencies.Visible := False;
  chbxIncludeLinked.Visible := False;
  chbxIncludeSiblings.Visible := False;
  chbxDontRemove.Visible := False;
  chbxAlwaysOverwrite.Visible := False;
  chbxDontModify.Visible := False;
  bvlDontModify.Visible := False;
end;

procedure TdlgToNamespace.actIncludeLinkedExecute(Sender: TObject);
begin
  pnlDependencies.Visible := chbxIncludeLinked.Checked;
end;

procedure TdlgToNamespace.actAddUpdate(Sender: TObject);
begin
  actAdd.Enabled := (FgdcNamespaceController <> nil)
    and (nopAdd in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actChangePropertiesUpdate(Sender: TObject);
begin
  actChangeProperties.Enabled := (FgdcNamespaceController <> nil)
    and (nopChangeProp in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actChangePropertiesExecute(Sender: TObject);
begin
  FgdcNamespaceController.SelectedOp := nopChangeProp;
  pnlTop.Visible := True;
  lMessage.Visible := False;
  lkupNS.Visible := False;
  chbxDontModify.Checked := False;
  chbxDontModify.Visible := False;
  bvlDontModify.Visible := False;
  chbxIncludeSiblings.Visible := True;
  chbxDontRemove.Visible := True;
  chbxAlwaysOverwrite.Visible := True;
  pnlDependencies.Visible := True;
  chbxIncludeLinked.Visible := True;
end;

procedure TdlgToNamespace.actPickOutUpdate(Sender: TObject);
begin
  actPickOut.Enabled := (FgdcNamespaceController <> nil)
    and (nopPickOut in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actUpdateUpdate(Sender: TObject);
begin
  actUpdate.Enabled := (FgdcNamespaceController <> nil)
    and (nopUpdate in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actUpdateExecute(Sender: TObject);
begin
  FgdcNamespaceController.SelectedOp := nopUpdate;
  pnlTop.Visible := True;
  lMessage.Visible := False;
  lkupNS.Visible := False;
  pnlDependencies.Visible := True;
  chbxIncludeLinked.Visible := False;
  chbxIncludeSiblings.Visible := True;
  chbxDontRemove.Visible := True;
  chbxAlwaysOverwrite.Visible := True;
  chbxDontModify.Checked := True;
  chbxDontModify.Visible := False;
  bvlDontModify.Visible := False;
end;

procedure TdlgToNamespace.actPickOutExecute(Sender: TObject);
begin
  FgdcNamespaceController.SelectedOp := nopPickOut;
  pnlDependencies.Visible := False;
  pnlTop.Visible := False;
end;

procedure TdlgToNamespace.actAddExecute(Sender: TObject);
begin
  FgdcNamespaceController.SelectedOp := nopAdd;
  pnlTop.Visible := True;
  lMessage.Visible := True;
  lkupNS.Visible := True;
  pnlDependencies.Visible := True;
  chbxIncludeLinked.Visible := True;
  chbxIncludeSiblings.Visible := True;
  chbxDontRemove.Visible := True;
  chbxAlwaysOverwrite.Visible := True;
  chbxDontModify.Visible := True;
  bvlDontModify.Visible := True;
end;

procedure TdlgToNamespace.actDontModifyUpdate(Sender: TObject);
begin
  actDontModify.Visible := (FgdcNamespaceController <> nil)
    and (nopAdd in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actDontModifyExecute(Sender: TObject);
begin
  //
end;

end.
