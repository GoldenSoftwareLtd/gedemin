unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, gdcBaseInterface, gdcBase, DBCtrls, Buttons,
  gd_createable_form, ExtCtrls;

type
  TdlgToNamespace = class(TCreateableForm)
    dsLink: TDataSource;
    ActionList: TActionList;
    actOK: TAction;
    pnlGrid: TPanel;
    pnlTop: TPanel;
    chbxIncludeSiblings: TCheckBox;
    chbxDontRemove: TCheckBox;
    chbxAlwaysOverwrite: TCheckBox;
    lkupNS: TgsIBLookupComboBox;
    lMessage: TLabel;
    pnlButtons: TPanel;
    pnlRightBottom: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Tr: TIBTransaction;
    sb: TScrollBox;
    procedure actOKExecute(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    FY: Integer;
    Pnl: TPanel;

    procedure DoCheckClick(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddObject(const AnObjID: Integer;
      const AnObjectName: String;
      const AClassName: String;
      const ARUID: String;
      const ANamespace: String;
      const ALinked: Boolean;
      const ACompound: Boolean);
  end;

var
  dlgToNamespace: TdlgToNamespace;

implementation

{$R *.DFM}

procedure TdlgToNamespace.actOKExecute(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TdlgToNamespace.actOKUpdate(Sender: TObject);
begin
  actOk.Enabled := lkupNS.CurrentKeyInt > -1;
end;

destructor TdlgToNamespace.Destroy;
begin
  inherited;
end;

constructor TdlgToNamespace.Create(AnOwner: TComponent);
begin
  inherited;
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

procedure TdlgToNamespace.AddObject(const AnObjID: Integer;
  const AnObjectName: String;
  const AClassName: String;
  const ARUID: String;
  const ANamespace: String;
  const ALinked: Boolean;
  const ACompound: Boolean);
var
  Prefix: String;
  ChBx: TCheckBox;
  Lbl: TLabel;
  Pnl2: TPanel;
begin
  if ALinked then
  begin
    Assert(Pnl <> nil);
    Prefix := 'LinkedObj';
    Pnl2 := TPanel.Create(Self);
    //Pnl2.Name := 'pnl' + Prefix + IntToStr(AnObjID);
    Pnl2.Parent := Pnl;
    Pnl2.Top := Pnl.Height;
    Pnl.Height := Pnl.Height + 21;
    Pnl2.Left := 24;
    Pnl2.Width := Pnl.Width - 24;
    Pnl2.Height := 21;
    Pnl2.Caption := '';
    Pnl2.ParentColor := False;
    Pnl2.Color := clWhite;
  end else
  begin
    Prefix := 'Obj';
    Pnl := TPanel.Create(Self);
    //Pnl.Name := 'pnl' + Prefix + IntToStr(AnObjID);
    Pnl.Parent := SB;
    Pnl.Top := FY;
    Pnl.Left := 0;
    Pnl.Width := SB.Width - 21;
    Pnl.Height := 21;
    Pnl.Caption := '';
    Pnl2 := Pnl;
  end;

  ChBx := TCheckBox.Create(Self);
  //ChBx.Name := 'chbx' + Prefix + IntToStr(AnObjID);
  ChBx.Parent := Pnl2;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := 2;
  ChBx.Width := 16;
  ChBx.Checked := True;
  ChBx.Tag := AnObjID;
  ChBx.OnClick := DoCheckClick;

  Lbl := TLabel.Create(Self);
  //Lbl.Name := 'lbl' + Prefix + IntToStr(AnObjID);
  Lbl.Parent := Pnl2;
  Lbl.Left := 20;
  Lbl.Top := 2;
  Lbl.Width := 280;
  Lbl.AutoSize := False;
  Lbl.Hint := ARUID;
  Lbl.ShowHint := True;
  if ACompound then
    Lbl.Font.Color := clBlue
  else
    Lbl.Font.Color := clBlack;
  Lbl.Caption := AnObjectName;

  Lbl := TLabel.Create(Self);
  //Lbl.Name := 'lbl' + Prefix + 'Class' + IntToStr(AnObjID);
  Lbl.Parent := Pnl2;
  Lbl.Left := 308;
  Lbl.Top := 2;
  Lbl.AutoSize := True;
  Lbl.Font.Color := clMaroon;
  Lbl.Caption := AClassName;

  if ANamespace > '' then
  begin
    Lbl := TLabel.Create(Self);
    //Lbl.Name := 'lbl' + Prefix + 'NS' + IntToStr(AnObjID);
    Lbl.Parent := Pnl2;
    Lbl.Left := 420;
    Lbl.Top := 2;
    Lbl.AutoSize := True;
    Lbl.Font.Color := clNavy;
    Lbl.Caption := ANamespace;
  end;

  if ALinked then
    Inc(FY, Pnl2.Height)
  else
    Inc(FY, Pnl.Height);
end;

procedure TdlgToNamespace.DoCheckClick(Sender: TObject);

  procedure SetChecks(const AnObjID: Integer; AParent: TWinControl;
    const AChecked: Boolean);
  var
    I: Integer;
  begin
    for I := 0 to AParent.ControlCount - 1 do
      if AParent.Controls[I] is TCheckBox then
      begin
        if ((AParent.Controls[I] as TCheckBox).Tag = AnObjID)
          or (AnObjID = -1) then
        begin
          (AParent.Controls[I] as TCheckBox).Checked := AChecked;
        end;
      end
      else if AParent.Controls[I] is TWinControl then
        SetChecks(AnObjID, AParent.Controls[I] as TWinControl, AChecked);
  end;

begin
  SetChecks(-1, (Sender as TCheckBox).Parent,
    (Sender as TCheckBox).Checked);
  SetChecks((Sender as TCheckBox).Tag, SB,
    (Sender as TCheckBox).Checked);
end;

end.
