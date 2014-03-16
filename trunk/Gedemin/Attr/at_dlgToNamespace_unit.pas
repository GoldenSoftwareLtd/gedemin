unit at_dlgToNamespace_unit;

interface

uses
  Windows, Messages, ContNrs, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Db, DBClient, StdCtrls, IBDatabase, gsIBLookupComboBox, Grids,
  DBGrids, gsDBGrid, ActnList, gdcBaseInterface, gdcBase, DBCtrls, Buttons,
  gd_createable_form, ExtCtrls, IBSQL;

type
  TNSRecord = class(TObject)
  private
    FID: TID;
    FObjectName: String;
    FObjectClass: String;
    FSubType: String;
    FRUID: TRUID;
    FEditionDate: TDateTime;
    FHeadObjectKey: TID;
    FChecked: Boolean;
    FLinked: TObjectList;
    function GetLinked(Index: Integer): TNSRecord;
    function GetLinkedCount: Integer;

  public
    constructor Create(
      const AnID: TID;
      const AnObjectName: String;
      const AObjectClass: String;
      const ASubType: String;
      const ARUID: TRUID;
      const AEditionDate: TDateTime;
      const AHeadObjectKey: TID);
    destructor Destroy; override;

    procedure AddLinked(ANSR: TNSRecord);

    property ID: TID read FID;
    property ObjectName: String read FObjectName;
    property ObjectClass: String read FObjectClass;
    property SubType: String read FSubType;
    property RUID: TRUID read FRUID;
    property EditionDate: TDateTime read FEditionDate;
    property HeadObjectKey: TID read FHeadObjectKey;
    property Checked: Boolean read FChecked write FChecked;
    property LinkedCount: Integer read GetLinkedCount;
    property Linked[Index: Integer]: TNSRecord read GetLinked;
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
    Pnl: TPanel;
    FNS: TIBSQL;
    FNSRecords: TObjectList;

    procedure DoCheckClick(Sender: TObject);
    function GetNSRecordCount: Integer;
    function GetNSRecords(Index: Integer): TNSRecord;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddObject(const AnObjID: Integer;
      const AnObjectName: String;
      const AClassName: String;
      const ASubType: String;
      const ARUID: TRUID;
      const AEditionDate: TDateTime;
      const AHeadObjectKey: TID;
      const ANamespace: String;
      const ALinked: Boolean);

    property NSRecordCount: Integer read GetNSRecordCount;
    property NSRecords[Index: Integer]: TNSRecord read GetNSRecords;
  end;

var
  dlgToNamespace: TdlgToNamespace;

implementation

{$R *.DFM}

procedure TNSRecord.AddLinked(ANSR: TNSRecord);
begin
  FLinked.Add(ANSR);
end;

constructor TNSRecord.Create(
  const AnID: TID;
  const AnObjectName: String;
  const AObjectClass: String;
  const ASubType: String;
  const ARUID: TRUID;
  const AEditionDate: TDateTime;
  const AHeadObjectKey: TID);
begin
  FID := AnID;
  FObjectName := AnObjectName;
  FObjectClass := AObjectClass;
  FSubType := ASubType;
  FRUID := ARUID;
  FEditionDate := AEditionDate;
  FHeadObjectKey := AHeadObjectKey;
  FChecked := True;
  FLinked := TObjectList.Create(True);
end;

destructor TNSRecord.Destroy;
begin
  FLinked.Free;
  inherited;
end;

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
  FNSRecords.Free;
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
  FNSRecords := TObjectList.Create(True);
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
  const AHeadObjectKey: TID;
  const ANamespace: String;
  const ALinked: Boolean);
var
  NS: String;
  ChBx: TCheckBox;
  Lbl: TLabel;
  CurrPnl: TPanel;
  FY: Integer;
begin
  Assert((not ALinked) or (FNSRecords.Count > 0));
  Assert((not ALinked) or (Pnl <> nil));

  FNS.ParamByName('xid').AsInteger := ARUID.XID;
  FNS.ParamByName('dbid').AsInteger := ARUID.DBID;
  FNS.ExecQuery;
  if FNS.EOF then
    NS := ''
  else
    NS := FNS.Fields[0].AsString;
  FNS.Close;

  if ALinked then
  begin
    CurrPnl := TPanel.Create(Self);
    CurrPnl.Parent := Pnl;
    CurrPnl.Top := Pnl.Height;
    Pnl.Height := Pnl.Height + 21 + 1;
    CurrPnl.Left := 24;
    CurrPnl.Width := Pnl.Width - 24 - 1;
    CurrPnl.Height := 21;
    CurrPnl.Caption := '';
    CurrPnl.BorderStyle := bsNone;
    CurrPnl.BevelOuter := bvNone;
    CurrPnl.BevelInner := bvNone;
    NSRecords[NSRecordCount - 1].AddLinked(TNSRecord.Create(AnObjID, AnObjectName, AClassName,
      ASubType, ARUID, AEditionDate, AHeadObjectKey));
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
    Pnl.Width := SB.Width - 20;
    Pnl.Height := 21;
    Pnl.Caption := '';
    CurrPnl := Pnl;
    FNSRecords.Add(TNSRecord.Create(AnObjID, AnObjectName, AClassName,
      ASubType, ARUID, AEditionDate, AHeadObjectKey));
  end;

  ChBx := TCheckBox.Create(Self);
  ChBx.Parent := CurrPnl;
  ChBx.Caption := '';
  ChBx.Top := 2;
  ChBx.Left := 2;
  ChBx.Width := 16;
  ChBx.Checked := True;
  ChBx.Tag := AnObjID;
  ChBx.Hint := RUIDToStr(ARUID);
  ChBx.OnClick := DoCheckClick;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := CurrPnl;
  Lbl.Left := 20;
  Lbl.Top := 2;
  Lbl.Width := 300;
  Lbl.AutoSize := False;
  Lbl.Hint := AClassName;
  Lbl.ShowHint := True;
  if AHeadObjectKey > -1 then
    Lbl.Font.Color := clBlue
  else
    Lbl.Font.Color := clBlack;
  Lbl.Caption := Copy(AnObjectName, 1, 47);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := CurrPnl;
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
    Lbl.Caption := AClassName + ASubType;
  end;
end;

procedure TdlgToNamespace.DoCheckClick(Sender: TObject);

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

begin
  SyncChecked((Sender as TCheckBox).Tag, (Sender as TCheckBox).Checked);
  SetChecks(-1, (Sender as TCheckBox).Parent,
    (Sender as TCheckBox).Checked);
  SetChecks((Sender as TCheckBox).Tag, SB,
    (Sender as TCheckBox).Checked);
end;

function TdlgToNamespace.GetNSRecordCount: Integer;
begin
  Result := FNSRecords.Count;
end;

function TdlgToNamespace.GetNSRecords(Index: Integer): TNSRecord;
begin
  Result := FNSRecords[Index] as TNSRecord;
end;

function TNSRecord.GetLinked(Index: Integer): TNSRecord;
begin
  Result := FLinked[Index] as TNSRecord;
end;

function TNSRecord.GetLinkedCount: Integer;
begin
  Result := FLinked.Count;
end;

end.
