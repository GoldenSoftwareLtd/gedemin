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
    Pnl, Pnl2: TPanel;
    ChBx: TCheckBox;
    Lbl: TLabel;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddObject(const AnObjID: Integer; const AnObjectName: String);
    procedure AddLinkedObject(const AnObjID: Integer; const AnObjectName: String);
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
  const AnObjectName: String);
begin
  Pnl := TPanel.Create(Self);
  Pnl.Name := 'pnlObj' + IntToStr(AnObjID);
  Pnl.Parent := SB;
  Pnl.Top := FY;
  Pnl.Left := 0;
  Pnl.Width := SB.ClientWidth;
  Pnl.Height := 21;
  Pnl.Caption := '';

  ChBx := TCheckBox.Create(Self);
  ChBx.Name := 'chbxObj' + IntToStr(AnObjID);
  ChBx.Parent := Pnl;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := 2;
  ChBx.Width := 16;

  Lbl := TLabel.Create(Self);
  Lbl.Name := 'lblObj' + IntToStr(AnObjID);
  Lbl.Parent := Pnl;
  Lbl.Left := 20;
  Lbl.Top := 2;
  Lbl.AutoSize := True;
  Lbl.Caption := AnObjectName;

  Inc(FY, Pnl.Height);
end;

procedure TdlgToNamespace.AddLinkedObject(const AnObjID: Integer;
  const AnObjectName: String);
begin
  Assert(Pnl <> nil);

  Pnl2 := TPanel.Create(Self);
  Pnl2.Name := 'pnlLinkedObj' + IntToStr(AnObjID);
  Pnl2.Parent := Pnl;
  Pnl2.Top := Pnl.Height;
  Pnl.Height := Pnl.Height + 21;
  Pnl2.Left := 24;
  Pnl2.Width := Pnl.Width - 24;
  Pnl2.Height := 21;
  Pnl2.Caption := '';

  ChBx := TCheckBox.Create(Self);
  ChBx.Name := 'chbxLinkedObj' + IntToStr(AnObjID);
  ChBx.Parent := Pnl2;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := 2;
  ChBx.Width := 16;

  Lbl := TLabel.Create(Self);
  Lbl.Name := 'lblLinkedObj' + IntToStr(AnObjID);
  Lbl.Parent := Pnl2;
  Lbl.Left := 20;
  Lbl.Top := 2;
  Lbl.AutoSize := True;
  Lbl.Caption := AnObjectName;

  Inc(FY, Pnl2.Height);
end;

end.
