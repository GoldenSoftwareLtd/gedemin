unit at_SetEditor_dlgChoose;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, ToolWin,
  ImgList, Db, IBCustomDataSet, IBQuery, IBDatabase, IBUpdateSQL,
  at_sql_parser, at_sql_setup, flt_sqlFilter, Menus, at_Classes, at_SetEditor,
  ActnList, Buttons;

type
  TdlgChoose = class(TForm)
    pnlBottom: TPanel;
    Panel2: TPanel;
    Cancel: TButton;
    Ok: TButton;
    Label1: TLabel;
    Label2: TLabel;
    grdResult: TgsIBGrid;
    dsReference: TDataSource;
    dsResult: TDataSource;
    qryResult: TIBQuery;
    qryReference: TIBQuery;
    ImageList1: TImageList;
    updResult: TIBUpdateSQL;
    qfReference: TgsQueryFilter;
    PopupMenu1: TPopupMenu;
    grdReference: TgsIBGrid;
    alSet: TActionList;
    actAdd: TAction;
    actAddAll: TAction;
    actDelete: TAction;
    actDeleteAll: TAction;
    actOk: TAction;
    actCancel: TAction;
    Bevel2: TBevel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;

    procedure actAddExecute(Sender: TObject);
    procedure actAddAllExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteAllExecute(Sender: TObject);

    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure qryReferenceAfterOpen(DataSet: TDataSet);
    procedure qryResultAfterOpen(DataSet: TDataSet);

  private
    FSetEditor: TatSetEditor;
    FTable, FCrossTable, FSetTable: TatRelation;
    FEditKey: String;
    FValue: String;

    function GetReferenceKey: TField;
    function GetReferenceText: TField;
    function GetResultFirstID: TField;
    function GetResultSecondID: TField;
    function GetResultText: TField;

  protected
    property ReferenceKey: TField read GetReferenceKey;
    property ReferenceText: TField read GetReferenceText;

    property ResultFirstID: TField read GetResultFirstID;
    property ResultSecondID: TField read GetResultSecondID;
    property ResultText: TField read GetResultText;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function ShowModal: Integer; override;

    property TheSetEditor: TatSetEditor read FSetEditor write FSetEditor;

    property Table: TatRelation read FTable write FTable;
    property CrossTable: TatRelation read FCrossTable write FCrossTable;
    property SetTable: TatRelation read FSetTable write FSetTable;
    property EditKey: String read FEditKey write FEditKey;
    property Value: String read FValue;

  end;

var
  dlgChoose: TdlgChoose;

implementation

{$R *.DFM}

{ TdlgChoose }

constructor TdlgChoose.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FSetEditor := nil;

  FTable := nil;
  FCrossTable := nil;
  FSetTable := nil;
  FEditKey := '';
  FValue := '';
end;

destructor TdlgChoose.Destroy;
begin
  inherited Destroy;
end;

function TdlgChoose.ShowModal: Integer;
begin
  qryReference.Open;
  qryResult.Open;
  Result := inherited ShowModal;
end;

function TdlgChoose.GetReferenceKey: TField;
begin
  Result := qryReference.FieldByName(FSetTable.PrimaryKey.
    ConstraintFields[0].FieldName);
end;

function TdlgChoose.GetReferenceText: TField;
begin
  Result := qryReference.FieldByName(FTable.RelationFields.ByFieldName(
    FSetEditor.DataField).CrossRelationFieldName);
end;

function TdlgChoose.GetResultFirstID: TField;
begin
  Result := qryResult.FieldByName(FCrossTable.PrimaryKey.
    ConstraintFields[0].FieldName);
end;

function TdlgChoose.GetResultSecondID: TField;
begin
  Result := qryResult.FieldByName(FCrossTable.PrimaryKey.
    ConstraintFields[1].FieldName);
end;

function TdlgChoose.GetResultText: TField;
begin
  Result := qryResult.FieldByName(FTable.RelationFields.ByFieldName(
    FSetEditor.DataField).CrossRelationFieldName);
end;

procedure TdlgChoose.actAddExecute(Sender: TObject);
var
  I: Integer;
  Mark: TBookmark;
begin
  if qryReference.IsEmpty then
    exit;

  Mark := qryReference.GetBookmark;
  qryResult.DisableControls;
  qryReference.DisableControls;

  try
    for I := 0 to grdReference.SelectedRows.Count - 1 do
    begin
      qryReference.GotoBookmark(TBookMark(grdReference.SelectedRows[I]));

      if qryResult.Locate(ResultSecondID.FieldName, ReferenceKey.AsString, []) then
        Continue;

      qryResult.Insert;
      try
        ResultFirstID.AsString := EditKey;
        ResultSecondID.AsString := ReferenceKey.AsString;
        ResultText.AsString := ReferenceText.AsString;

        qryResult.Post;
      except
        qryResult.Cancel;
        raise;
      end;
    end;

    grdReference.SelectedRows.Clear;
  finally
    if qryReference.BookmarkValid(Mark) then
    begin
      qryReference.GotoBookmark(Mark);
      qryReference.FreeBookmark(Mark);
    end;

    qryResult.EnableControls;
    qryReference.EnableControls;
  end;
end;

procedure TdlgChoose.actAddAllExecute(Sender: TObject);
var
  I: Integer;
  Mark: TBookmark;
begin
  if qryReference.IsEmpty then
    exit;

  Mark := qryReference.GetBookmark;

  qryResult.DisableControls;
  qryReference.DisableControls;

  try
    qryReference.First;
    I := 1;

    while not qryReference.EOF do
    begin
      if qryResult.Locate(ResultSecondID.FieldName, ReferenceKey.AsString, []) then
      begin
        qryReference.Next;
        Continue;
      end;

      qryResult.Insert;
      try
        ResultFirstID.AsString := EditKey;
        ResultSecondID.AsString := ReferenceKey.AsString;
        ResultText.AsString := ReferenceText.AsString;

        qryResult.Post;
      except
        qryResult.Cancel;
        raise;
      end;
      qryReference.Next;

      if I mod 300 = 0 then
        if
          MessageBox(
            Handle,
            PChar(Format('Перенесено %d записей. Продолжить?', [I])),
            '',
            MB_ICONQUESTION or MB_YESNO
          ) = ID_NO
        then
          Break;

      Inc(I);
    end;

    grdReference.SelectedRows.Clear;
  finally
    if qryReference.BookmarkValid(Mark) then
    begin
      qryReference.GotoBookmark(Mark);
      qryReference.FreeBookmark(Mark);
    end;

    qryResult.EnableControls;
    qryReference.EnableControls;
  end;
end;

procedure TdlgChoose.actDeleteExecute(Sender: TObject);
begin
  if qryResult.IsEmpty then
    exit;

  grdResult.SelectedRows.Delete;
  grdResult.SelectedRows.Clear;
end;

procedure TdlgChoose.actDeleteAllExecute(Sender: TObject);
begin
  qryResult.DisableControls;
  while qryResult.RecordCount > 0 do qryResult.Delete;
  qryResult.EnableControls;
end;

procedure TdlgChoose.actOkExecute(Sender: TObject);
begin
  FValue := '';

  qryResult.DisableControls;
  qryResult.First;

  while not qryResult.EOF do
  begin
    if FValue > '' then FValue := FValue + ' ';
    FValue := FValue + ResultText.DisplayText;
    qryResult.Next;
  end;

  qryResult.EnableControls;

  qryResult.ApplyUpdates;
end;

procedure TdlgChoose.actCancelExecute(Sender: TObject);
begin
  qryResult.CancelUpdates;
end;

procedure TdlgChoose.qryReferenceAfterOpen(DataSet: TDataSet);
var
  I: Integer;
begin
  qryReference.DisableControls;
  for I := 0 to qryReference.Fields.Count - 1 do
  begin
    qryReference.Fields[I].Required := False;
    qryReference.Fields[I].Visible := qryReference.Fields[I].DataType in [ftString];
  end;
  qryReference.EnableControls;
end;

procedure TdlgChoose.qryResultAfterOpen(DataSet: TDataSet);
var
  I: Integer;
begin
  qryResult.DisableControls;
  for I := 0 to qryResult.Fields.Count - 1 do
  begin
    qryResult.Fields[I].Required := False;
    qryResult.Fields[I].Visible := qryResult.Fields[I].DataType in [ftString];
  end;
  qryResult.EnableControls;
end;

end.

