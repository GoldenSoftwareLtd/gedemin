unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, ContNrs, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids,
  DBGrids, gsDBGrid, ActnList, gdcBaseInterface, gdcBase, DBCtrls, Buttons,
  gd_createable_form, ExtCtrls, IBSQL, at_dlgToNamespaceInterface;

type
  TdlgToNamespace = class(TCreateableForm, Iat_dlgToNamespace)
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
    Pnl: TPanel;
    FNS: TIBSQL;

    procedure DoCheckClick(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddObject(const AnObjID: Integer;
      const AnObjectName: String;
      const AClassName: String;
      const ASubType: String;
      const ARUID: TRUID;
      const AEditionDate: TDateTime;
      const AHeadObjectKey: Integer;
      const ANamespace: String;
      const AKind: TgsNSObjectKind);
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
  const ASubType: String;
  const ARUID: TRUID;
  const AEditionDate: TDateTime;
  const AHeadObjectKey: Integer;
  const ANamespace: String;
  const AKind: TgsNSObjectKind);
const
  Padding        = 20;
  NameWidth      = 360;
  LineHeight     = 21;
  ScrollBarWidth = 20;
var
  NS: String;
  ChBx: TCheckBox;
  Lbl: TLabel;
  CurrPnl: TPanel;
  FY: Integer;
begin
  Assert((AKind <> nskLinked) or (Pnl <> nil));

  FNS.ParamByName('xid').AsInteger := ARUID.XID;
  FNS.ParamByName('dbid').AsInteger := ARUID.DBID;
  FNS.ExecQuery;
  if FNS.EOF then
    NS := ''
  else
    NS := FNS.Fields[0].AsString;
  FNS.Close;

  if AKind = nskLinked then
  begin
    CurrPnl := TPanel.Create(Self);
    CurrPnl.Parent := Pnl;
    CurrPnl.Top := Pnl.Height + 1;
    Pnl.Height := Pnl.Height + LineHeight + 2;
    CurrPnl.Left := Padding;
    CurrPnl.Width := Pnl.Width - Padding - 1;
    CurrPnl.Height := LineHeight;
    CurrPnl.Caption := '';
    CurrPnl.BorderStyle := bsNone;
    CurrPnl.BevelOuter := bvNone;
    CurrPnl.BevelInner := bvNone;
  end else
  begin
    if Pnl <> nil then
      FY := Pnl.Top + Pnl.Height + 1
    else
      FY := 1;

    Pnl := TPanel.Create(Self);
    Pnl.Parent := SB;
    Pnl.Top := FY;
    Pnl.Left := 0;
    Pnl.Width := SB.Width - ScrollBarWidth;
    Pnl.Height := LineHeight;
    Pnl.Caption := '';
    CurrPnl := Pnl;
  end;

  ChBx := TCheckBox.Create(Self);
  ChBx.Parent := CurrPnl;
  ChBx.Alignment := taRightJustify;
  ChBx.Left := 2;
  ChBx.Top := 2;
  ChBx.Width := NameWidth - CurrPnl.Left;
  ChBx.Checked := True;
  ChBx.Tag := AnObjID;
  ChBx.Hint := RUIDToStr(ARUID);
  ChBx.OnClick := DoCheckClick;
  if AHeadObjectKey > -1 then
    ChBx.Font.Color := clBlue
  else
    ChBx.Font.Color := clBlack;
  ChBx.Caption := AnObjectName + ' (' + AClassName + ASubType + ')';

  NS := 'test, test, test';

  if NS > '' then
  begin
    Lbl := TLabel.Create(Self);
    Lbl.Parent := CurrPnl;
    Lbl.Top := 2;
    Lbl.Left := NameWidth + 12 - CurrPnl.Left;
    Lbl.AutoSize := True;
    Lbl.Font.Style := [fsItalic];
    Lbl.Font.Color := clMaroon;
    Lbl.Caption := NS;
  end;

  ChBx := TCheckBox.Create(Self);
  ChBx.Parent := CurrPnl;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := CurrPnl.Width - 21 * 3;
  ChBx.Width := 16;
  ChBx.Checked := False;

  ChBx := TCheckBox.Create(Self);
  ChBx.Parent := CurrPnl;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := CurrPnl.Width - 21 * 2;
  ChBx.Width := 16;
  ChBx.Checked := False;

  ChBx := TCheckBox.Create(Self);
  ChBx.Parent := CurrPnl;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := CurrPnl.Width - 21;
  ChBx.Width := 16;
  ChBx.Checked := False;
end;

procedure TdlgToNamespace.DoCheckClick(Sender: TObject);

  {
  procedure SyncChecked(const AnObjID: TID; const AChecked: Boolean);
  var
    I, J: Integer;
  begin
    for I := 0 to NSRecordCount - 1 do
    begin
      if NSRecords[I].ID = AnObjID then
        NSRecords[I].Checked := AChecked;
      for J := 0 to NSRecords[I].LinkedCount - 1 do
      begin
        if NSRecords[I].Linked[J].ID = AnObjID then
          NSRecords[I].Linked[J].Checked := AChecked;
      end;
    end;
  end;

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
          SyncChecked((AParent.Controls[I] as TCheckBox).Tag, AChecked);
        end;
      end
      else if AParent.Controls[I] is TWinControl then
        SetChecks(AnObjID, AParent.Controls[I] as TWinControl, AChecked);
  end;
  }

begin
  {
  SyncChecked((Sender as TCheckBox).Tag, (Sender as TCheckBox).Checked);
  SetChecks(-1, (Sender as TCheckBox).Parent,
    (Sender as TCheckBox).Checked);
  SetChecks((Sender as TCheckBox).Tag, SB,
    (Sender as TCheckBox).Checked);
  }  
end;

end.
