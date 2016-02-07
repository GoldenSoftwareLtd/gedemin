unit gd_dlgClassList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ActnList, TB2Dock, TB2Toolbar, ExtCtrls, gd_ClassList,
  StdCtrls, TB2Item, gdcBaseInterface;

type
  Tgd_dlgClassList = class(TForm)
    pnlBottom: TPanel;
    TBDock: TTBDock;
    TBToolbar: TTBToolbar;
    ActionList: TActionList;
    lvClasses: TListView;
    TBItem1: TTBItem;
    actOk: TAction;
    actCancel: TAction;
    actForm: TAction;
    Label1: TLabel;
    TBControlItem1: TTBControlItem;
    lblClassesCount: TLabel;
    TBSeparatorItem1: TTBSeparatorItem;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    TBControlItem2: TTBControlItem;
    Label2: TLabel;
    TBSeparatorItem2: TTBSeparatorItem;
    edFilter: TEdit;
    TBControlItem3: TTBControlItem;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure actFormUpdate(Sender: TObject);
    procedure actFormExecute(Sender: TObject);
    procedure lvClassesDblClick(Sender: TObject);

  private
    FFullClass: TgdcFullClassName;

    function BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
    procedure RefreshList;

  public
    function SelectModal(const AFilter: String;
      var AFullClass: TgdcFullClassName): Boolean; overload;
    function SelectModal(const AFilter: String): TgdClassEntry; overload;
  end;

var
  gd_dlgClassList: Tgd_dlgClassList;

implementation

uses
  gdcBase, jclStrings;

{$R *.DFM}

{ Tgd_dlgClassList }

function Tgd_dlgClassList.BuildClassTree(ACE: TgdClassEntry;
  AData1: Pointer; AData2: Pointer): Boolean;
var
  LI: TListItem;
  CE: TgdBaseEntry;
begin
  if ACE is TgdBaseEntry then
  begin
    CE := ACE as TgdBaseEntry;

    if (edFilter.Text = '')
      or (StrIPos(edFilter.Text, CE.TheClass.ClassName) > 0)
      or
      (
        CE.gdcClass.IsAbstractClass
        and
        (StrIPos(edFilter.Text, '<Абстрактный базовый класс>') > 0)
      )
      or
      (
        (not CE.gdcClass.IsAbstractClass)
        and
        (StrIPos(edFilter.Text, CE.SubType) > 0)
      )
      or (StrIPos(edFilter.Text, CE.gdcClass.GetDisplayName(CE.SubType)) > 0)
      or (StrIPos(edFilter.Text, CE.gdcClass.GetListTable(CE.SubType)) > 0)
      or (StrIPos(edFilter.Text, CE.DistinctRelation) > 0) then
    begin
      LI := lvClasses.Items.Add;
      LI.Caption := CE.TheClass.ClassName;

      if CE.gdcClass.IsAbstractClass then
        LI.SubItems.Add('<Абстрактный базовый класс>')
      else
        LI.SubItems.Add(CE.SubType);

      LI.SubItems.Add(CE.gdcClass.GetDisplayName(CE.SubType));
      LI.SubItems.Add(CE.gdcClass.GetListTable(CE.SubType));

      LI.Selected := (LI.Caption = FFullClass.gdClassName)
        and (LI.SubItems[0] = FFullClass.SubType);
    end;
    Result := True;
  end else
    Result := False;
end;

function Tgd_dlgClassList.SelectModal(const AFilter: String;
  var AFullClass: TgdcFullClassName): Boolean;
begin
  edFilter.Text := AFilter;
  FFullClass := AFullClass;
  RefreshList;
  Result := ShowModal = mrOk;
  if Result then
  begin
    if lvClasses.Selected <> nil then
    begin
      AFullClass.gdClassName := lvClasses.Selected.Caption;
      if lvClasses.Selected.SubItems[0] = '<Абстрактный базовый класс>' then
        AFullClass.SubType := ''
      else
        AFullClass.SubType := lvClasses.Selected.SubItems[0];
    end else
    begin
      AFullClass.gdClassName := '';
      AFullClass.SubType := '';
    end;
  end;
end;

procedure Tgd_dlgClassList.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgd_dlgClassList.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgd_dlgClassList.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := lvClasses.Selected <> nil;
end;

procedure Tgd_dlgClassList.RefreshList;
begin
  lvClasses.Items.BeginUpdate;
  try
    lvClasses.Items.Clear;
    if edFilter.Text > '' then
    begin
      lvClasses.Color := clInfoBk;
      edFilter.Color := clInfoBk;
    end else
    begin
      lvClasses.Color := clWindow;
      edFilter.Color := clWindow;
    end;
    gdClassList.Traverse(TgdcBase, '', BuildClassTree, nil, nil);
    lblClassesCount.Caption := ' Бизнес-классов: ' + IntToStr(lvClasses.Items.Count);
    if lvClasses.Selected <> nil then
      lvClasses.Selected.MakeVisible(False);
  finally
    lvClasses.Items.EndUpdate;
  end;
end;

procedure Tgd_dlgClassList.edFilterChange(Sender: TObject);
begin
  RefreshList;
end;

procedure Tgd_dlgClassList.actFormUpdate(Sender: TObject);
begin
  actForm.Enabled := lvClasses.Selected <> nil;
end;

procedure Tgd_dlgClassList.actFormExecute(Sender: TObject);

  function CreateCurrClassBusinessObject(out Obj: TgdcBase): Boolean;
  var
    C: TPersistentClass;
  begin
    Obj := nil;
    C := GetClass(lvClasses.Selected.Caption);

    if (C <> nil) and C.InheritsFrom(TgdcBase) then
    begin
      Obj := CgdcBase(C).Create(nil);
      if Pos('<', lvClasses.Selected.SubItems[0]) = 0 then
        Obj.SubType := lvClasses.Selected.SubItems[0];
    end;

    Result := Obj <> nil;
  end;

var
  Obj: TgdcBase;
  F: TCustomForm;
begin
  if CreateCurrClassBusinessObject(Obj) then
  try
    F := Obj.CreateViewForm(Application.MainForm, '', Obj.SubType, True);
    if F <> nil then
    begin
      F.ShowModal;
      F.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure Tgd_dlgClassList.lvClassesDblClick(Sender: TObject);
begin
  actOk.Execute;
end;

function Tgd_dlgClassList.SelectModal(const AFilter: String): TgdClassEntry;
var
  FC: TgdcFullClassName;
begin
  if SelectModal(AFilter, FC) then
    Result := gdClassList.Find(FC.gdClassName, FC.SubType)
  else
    Result := nil;
end;

end.
