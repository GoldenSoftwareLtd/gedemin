
unit xDBTreeView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, DB;

type
  PxDBTreeNode = ^TxDBTreeNode;
  TxDBTreeNode = record
    IsLeaf: Boolean;
    Key: Integer;
  end;

type
  TxDBTreeView = class(TTreeView)
  private
    FKeyFieldName: String;
    FParentKeyFieldName: String;
    FTextFieldName: String;
    FDataSource: TDataSource;
    FLeafTextFieldName: String;
    FLeafLinkFieldName: String;
    FLeafDataSet: TDataSet;
    FLeafKeyFieldName: String;
    FAutoRebuild: Boolean;
    OldOnDataChange: TDataChangeEvent;
    FLeafFilter: String;

    procedure SetDataSource(const Value: TDataSource);
    procedure SetKeyFieldName(const Value: String);
    procedure SetParentKeyFieldName(const Value: String);
    procedure SetTextFieldName(const Value: String);
    function GetDataSet: TDataSet;
    procedure SetDataSet(const Value: TDataSet);
    procedure SetLeafDataSet(const Value: TDataSet);
    procedure SetLeafLinkFieldName(const Value: String);
    procedure SetLeafTextFieldName(const Value: String);
    procedure SetLeafKeyFieldName(const Value: String);
    procedure DoOnDataChange(Sender: TObject; Field: TField);

  protected
    procedure Loaded; override;

    property DataSet: TDataSet read GetDataSet write SetDataSet;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure Build(const PreserveState: Boolean = False);
    procedure GotoNode(const Key: Integer; const IsLeaf: Boolean);

  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property KeyFieldName: String read FKeyFieldName write SetKeyFieldName;
    property ParentKeyFieldName: String read FParentKeyFieldName write SetParentKeyFieldName;
    property TextFieldName: String read FTextFieldName write SetTextFieldName;
    property LeafDataSet: TDataSet read FLeafDataSet write SetLeafDataSet;
    property LeafTextFieldName: String read FLeafTextFieldName write SetLeafTextFieldName;
    property LeafLinkFieldName: String read FLeafLinkFieldName write SetLeafLinkFieldName;
    property LeafKeyFieldName: String read FLeafKeyFieldName write SetLeafKeyFieldName;
    property AutoRebuild: Boolean read FAutoRebuild write FAutoRebuild default True;
    property LeafFilter: String read FLeafFilter write FLeafFilter;
  end;

function IsLeaf(P: Pointer): Boolean; overload;
function IsLeaf(N: TTreeNode): Boolean; overload;
function IsLeaf(T: TTreeView): Boolean; overload;
function GetKey(P: Pointer): Integer; overload;
function GetKey(N: TTreeNode): Integer; overload;
function GetKey(T: TTreeView): Integer; overload;

procedure Register;

implementation

var
  _List: TList;

// Global routines

function IsLeaf(P: Pointer): Boolean; overload;
begin
  Assert(P <> nil);
  Result := PxDBTreeNode(P)^.IsLeaf;
end;

function IsLeaf(N: TTreeNode): Boolean; overload;
begin
  Assert(N <> nil);
  Result := IsLeaf(N.Data);
end;

function IsLeaf(T: TTreeView): Boolean; overload;
begin
  Assert(T <> nil);
  Result := IsLeaf(T.Selected);
end;

function GetKey(P: Pointer): Integer; overload;
begin
  Assert(P <> nil);
  Result := PxDBTreeNode(P)^.Key;
end;

function GetKey(N: TTreeNode): Integer; overload;
begin
  Assert(N <> nil);
  Result := GetKey(N.Data);
end;

function GetKey(T: TTreeView): Integer; overload;
begin
  Assert(T <> nil);
  Result := GetKey(T.Selected);
end;

{ TxDBTreeView }

constructor TxDBTreeView.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  HideSelection := False;
  FAutoRebuild := True;
end;

procedure TxDBTreeView.Build;

  procedure DoRecur(TN: TTreeNode = nil);
  var
    Arr: array of TTreeNode;
    Count: Integer;
    Node: PxDBTreeNode;
  begin
    if TN = nil then
      DataSet.Filter := FParentKeyFieldName + '=NULL'
    else begin
      DataSet.Filter := Format('%s=%d', [FParentKeyFieldName, PxDBTreeNode(TN.Data)^.Key]);
    end;

    DataSet.Open;
    SetLength(Arr, DataSet.RecordCount);
    Count := 0;
    DataSet.First;
    while not DataSet.EOF do
    begin
      GetMem(Node, SizeOf(TxDBTreeNode));
      _List.Add(Node);
      Node^.Key := DataSet.FieldByName(FKeyFieldName).AsInteger;
      Node^.IsLeaf := False;
      Arr[Count] := Items.AddChildObject(TN, DataSet.FieldByName(FTextFieldName).AsString,
        Node);
      Count := Count + 1;
      DataSet.Next;
    end;
///
    if (TN <> nil) and Assigned(FLeafDataSet) then
    begin
      FLeafDataSet.Filter := FLeafLinkFieldName + '=' + Format('%d', [PxDBTreeNode(TN.Data)^.Key]);
      if FLeafFilter > '' then
        FLeafDataSet.Filter := FLeafDataSet.Filter + ' AND (' + FLeafFilter + ')';
      FLeafDataSet.Filtered := True;
      FLeafDataSet.Open;
      FLeafDataSet.First;
      while not FLeafDataSet.EOF do
      begin
        GetMem(Node, SizeOf(TxDBTreeNode));
        _List.Add(Node);
        Node^.Key := FLeafDataSet.FieldByName(FLeafKeyFieldName).AsInteger;
        Node^.IsLeaf := True;
        Items.AddChildObject(TN, FLeafDataSet.FieldByName(FLeafTextFieldName).AsString,
          Node);
        FLeafDataSet.Next;
      end;
      FLeafDataSet.Filtered := False;
    end;
///
    while Count > 0 do
    begin
      Count := Count - 1;
      DoRecur(Arr[Count]);
    end;
  end;

var
  StatesArray: array of array of Integer;
  I, J: Integer;

begin
  Assert(Assigned(FDataSource) and Assigned(FDataSource.DataSet));

  // сохраняем конфигурацию дерева
  if PreserveState then
  begin
    SetLength(StatesArray, Items.Count, 3);
    for I := 0 to Items.Count - 1 do
    begin
      StatesArray[I, 0] := PxDBTreeNode(Items[I].Data)^.Key;
      StatesArray[I, 1] := Integer(PxDBTreeNode(Items[I].Data)^.IsLeaf);
      StatesArray[I, 2] := Integer(Items[I].Expanded);
    end;
  end;

  Items.BeginUpdate;
  Items.Clear;

  DataSet.Filtered := True;
  DoRecur;

  // восстанавливаем конфигурацию дерева
  if PreserveState then
  begin
    for I := 0 to Items.Count - 1 do
    begin
      for J := Low(StatesArray) to High(StatesArray) do
        if (StatesArray[J, 0] = PxDBTreeNode(Items[I].Data)^.Key) and
          (StatesArray[J, 1] = Integer(PxDBTreeNode(Items[I].Data)^.IsLeaf)) then
          Items[I].Expanded := Boolean(StatesArray[J, 2]);
    end;
  end;

  DataSet.Filtered := False;
  Items.EndUpdate;
end;

procedure TxDBTreeView.GotoNode(const Key: Integer; const IsLeaf: Boolean);
var
  I: Integer;
begin
  if (DataSource.DataSet <> nil) and (DataSource.DataSet.Active) then
  begin
    Build;
    for I := 0 to Items.Count - 1 do
      if (PxDBTreeNode(Items.Item[I].Data)^.IsLeaf = IsLeaf) and
        (PxDBTreeNode(Items.Item[I].Data)^.Key = Key) then
      begin
        Items.Item[I].Selected := True;
        break;
      end;
  end;
end;

function TxDBTreeView.GetDataSet: TDataSet;
begin
  Result := FDataSource.DataSet;
end;

procedure TxDBTreeView.SetDataSet(const Value: TDataSet);
begin
  FDataSource.DataSet.Assign(Value);
end;

procedure TxDBTreeView.SetDataSource(const Value: TDataSource);
begin
  FDataSource := Value;
end;

procedure TxDBTreeView.SetKeyFieldName(const Value: String);
begin
  FKeyFieldName := Value;
end;

procedure TxDBTreeView.SetParentKeyFieldName(const Value: String);
begin
  FParentKeyFieldName := Value;
end;

procedure TxDBTreeView.SetTextFieldName(const Value: String);
begin
  FTextFieldName := Value;
end;

procedure TxDBTreeView.SetLeafDataSet(const Value: TDataSet);
begin
  FLeafDataSet := Value;
end;

procedure TxDBTreeView.SetLeafLinkFieldName(const Value: String);
begin
  FLeafLinkFieldName := Value;
end;

procedure TxDBTreeView.SetLeafTextFieldName(const Value: String);
begin
  FLeafTextFieldName := Value;
end;

procedure TxDBTreeView.SetLeafKeyFieldName(const Value: String);
begin
  FLeafKeyFieldName := Value;
end;

// Registration -------------------------------------------

procedure Register;
begin
  RegisterComponents('x-DataBase', [TxDBTreeView]);
end;

var
  I: Integer;

procedure TxDBTreeView.DoOnDataChange(Sender: TObject; Field: TField);
begin
  if (not (csDestroying in ComponentState) and not (csDesigning in ComponentState)) and (not (csLoading in ComponentState)) then
  begin
    if Assigned(OldOnDataChange) then
      OldOnDataChange(Sender, Field);

//    if FAutoRebuild then
//      Build(True);
  end;      
end;

procedure TxDBTreeView.Loaded;
begin
  inherited Loaded;
  if Assigned(FDataSource) then
  begin
    OldOnDataChange := FDataSource.OnDataChange;
    FDataSource.OnDataChange := DoOnDataChange;
  end;
end;

initialization

  _List := TList.Create;

finalization
  for I := 0 to _List.Count - 1 do
    if _List[I] <> nil then
      FreeMem(_List[I], SizeOf(TxDBTreeNode));
  _List.Free;
end.

