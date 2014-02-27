unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids, DBGrids,
  gsDBGrid, ActnList, gdcBaseInterface, gdcBase, DBCtrls, Buttons,
  gd_createable_form, ExtCtrls, IBSQL;

type
  TNSRecord = record
    ObjectName: String;
    ClassName: String;
    RUID: String;
    Checked: Boolean;
    Compound: Boolean;
    Linked: Boolean;
  end;

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
    FNS: TIBSQL;
    FCurrent: Integer;
    FCurrentLinked: Integer;

    procedure DoCheckClick(Sender: TObject);
    function FillNSRecord(APnl: TPanel): TNSRecord;

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

    function EOF: Boolean;
    function GetNSRecord: TNSRecord;
    procedure Next;

    function LinkedEOF: Boolean;
    function GetLinkedNSRecord: TNSRecord;
    procedure LinkedNext;
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
  FNS.Free;
  inherited;
end;

constructor TdlgToNamespace.Create(AnOwner: TComponent);
begin
  inherited;
  FNS := TIBSQL.Create(nil);
  FNS.Transaction := gdcBaseManager.ReadTransaction;
  FNS.SQL.Text :=
    'SELECT LIST(n.name, '', '') FROM at_namespace n ' +
    '  JOIN at_object o ON o.namespacekey = n.id ' +
    'WHERE o.xid = :xid AND o.dbid = :dbid';
  FCurrent := 0;
  FCurrentLinked := 3;
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
  NS: String;
  ChBx: TCheckBox;
  Lbl: TLabel;
  Pnl2: TPanel;
begin
  FNS.ParamByName('xid').AsInteger := StrToRUID(ARUID).XID;
  FNS.ParamByName('dbid').AsInteger := StrToRUID(ARUID).DBID;
  FNS.ExecQuery;
  if FNS.EOF then
    NS := ''
  else
    NS := FNS.Fields[0].AsString;
  FNS.Close;

  if ALinked then
  begin
    Assert(Pnl <> nil);
    Pnl2 := TPanel.Create(Self);
    Pnl2.Parent := Pnl;
    Pnl2.Top := Pnl.Height;
    Pnl.Height := Pnl.Height + 21;
    Pnl2.Left := 24;
    Pnl2.Width := Pnl.Width - 24;
    Pnl2.Height := 21;
    Pnl2.Caption := '';
    Pnl2.ParentColor := False;
    Pnl2.Color := clWhite;
    Pnl2.Tag := 1;
  end else
  begin
    Pnl := TPanel.Create(Self);
    Pnl.Parent := SB;
    Pnl.Top := FY;
    Pnl.Left := 0;
    Pnl.Width := SB.Width - 21;
    Pnl.Height := 21;
    Pnl.Caption := '';
    Pnl2 := Pnl;
    if ACompound then
      Pnl2.Tag := 2
    else
      Pnl2.Tag := 0;
  end;

  ChBx := TCheckBox.Create(Self);
  ChBx.Parent := Pnl2;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := 2;
  ChBx.Width := 16;
  ChBx.Checked := True;
  ChBx.Tag := AnObjID;
  ChBx.Hint := ARUID;
  ChBx.OnClick := DoCheckClick;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Pnl2;
  Lbl.Left := 20;
  Lbl.Top := 2;
  Lbl.Width := 300;
  Lbl.AutoSize := False;
  Lbl.Hint := AClassName;
  Lbl.ShowHint := True;
  if ACompound then
    Lbl.Font.Color := clBlue
  else
    Lbl.Font.Color := clBlack;
  Lbl.Caption := Copy(AnObjectName, 1, 47);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Pnl2;
  Lbl.Left := 328;
  Lbl.Top := 2;
  Lbl.AutoSize := True;

  if NS > '' then
  begin
    Lbl.Font.Style := [fsItalic];
    Lbl.Font.Color := clMaroon;
    Lbl.Caption := NS;
  end else
  begin
    Lbl.Caption := AClassName;
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

function TdlgToNamespace.EOF: Boolean;
begin
  Result := FCurrent >= SB.ControlCount;
end;

function TdlgToNamespace.GetLinkedNSRecord: TNSRecord;
begin
  Result := FillNSRecord((SB.Controls[FCurrent] as TPanel).Controls[FCurrentLinked] as TPanel);
end;

function TdlgToNamespace.GetNSRecord: TNSRecord;
begin
  Result := FillNSRecord(SB.Controls[FCurrent] as TPanel);
end;

function TdlgToNamespace.LinkedEOF: Boolean;
begin
  Result := EOF or
    (FCurrentLinked >= (SB.Controls[FCurrent] as TPanel).ControlCount);
end;

procedure TdlgToNamespace.LinkedNext;
begin
  if not LinkedEOF then
    Inc(FCurrentLinked);
end;

procedure TdlgToNamespace.Next;
begin
  if not EOF then
  begin
    Inc(FCurrent);
    FCurrentLinked := 3;
  end;
end;

function TdlgToNamespace.FillNSRecord(APnl: TPanel): TNSRecord;
begin
  Result.Checked := (APnl.Controls[0] as TCheckBox).Checked;
  Result.RUID := (APnl.Controls[0] as TCheckBox).Hint;
  Result.ObjectName := (APnl.Controls[1] as TLabel).Caption;
  Result.ClassName := (APnl.Controls[1] as TLabel).Hint;
  Result.Compound := APnl.Tag = 2;
  Result.Linked := APnl.Tag = 1;
end;

end.
