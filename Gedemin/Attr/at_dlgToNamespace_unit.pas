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
    rbAdd: TRadioButton;
    actDelete: TAction;
    pnlDependencies: TPanel;
    dbgrListLink: TgsDBGrid;
    tsObjects: TTabSet;
    actMove: TAction;
    rbPickOut: TRadioButton;
    RadioButton1: TRadioButton;
    actIncludeLinked: TAction;
    actAdd: TAction;
    actChangeProperties: TAction;
    actPickUp: TAction;
    rbComplete: TRadioButton;
    actComplete: TAction;
    actDontModify: TAction;
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

  if FgdcNamespaceController.PrevNSID = -1 then
  begin
    mInfo.Lines.Add('1) Выберите из списка ПИ для добавления объекта(ов): ' +
      FgdcNamespaceController.ObjectName);
    mInfo.Lines.Add('2) Установите параметры, которые будут ' +
      'присвоены всем добавляемым записям');
    mInfo.Lines.Add('3) Параметры существующих записей ' +
      'изменяться не будут');
    rbAdd.Checked := True;
    chbxDontModify.Checked := True;
    chbxDontModify.Visible := False;
  end
  else if (FgdcNamespaceController.PrevNSID <> -1) and (FgdcNamespaceController.HeadObjectKey = -1) then
  begin
    mInfo.Lines.Add('Объект(ы) "' + FgdcNamespaceController.ObjectName + '" входит в ПИ "' +
      FgdcNamespaceController.PrevNSName + '". Выберите действие:');
  end;
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
      ((lkupNS.Text = '') and (lkupNS.CurrentKeyInt = -1) and (FgdcNamespaceController.PrevNSID <> -1))
      or
      (lkupNS.CurrentKeyInt > -1)
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
  actDelete.Visible := (FgdcNamespaceController <> nil)
    and (nopDel in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actDeleteExecute(Sender: TObject);
begin
  pnlDependencies.Visible := not rbDelete.Checked;
  pnlTop.Visible := not rbDelete.Checked;
end;

procedure TdlgToNamespace.actMoveUpdate(Sender: TObject);
begin
  actMove.Visible := (FgdcNamespaceController <> nil)
    and (nopMove in FgdcNamespaceController.Ops);
end;

procedure TdlgToNamespace.actMoveExecute(Sender: TObject);
begin
  pnlTop.Visible := rbMove.Checked;
  pnlDependencies.Visible := not rbMove.Checked;
  chbxIncludeLinked.Visible := not rbMove.Checked;
  chbxIncludeSiblings.Visible := not rbMove.Checked;
  chbxDontRemove.Visible := not rbMove.Checked;
  chbxAlwaysOverwrite.Visible := not rbMove.Checked;
  chbxDontModify.Visible := not rbMove.Checked;
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

end.
