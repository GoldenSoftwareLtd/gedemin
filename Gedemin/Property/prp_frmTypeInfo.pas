// ShlTanya, 25.02.2019

unit prp_frmTypeInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, contnrs, prp_frmClassesInspector_unit, prp_DOCKFORM_unit;

type
  TfrmTypeInfo = class(TDockableForm, IprpClassesFrm)
    tvTypeInfo: TTreeView;
    lblVariable: TLabel;
    edVariable: TEdit;
    mmDescription: TMemo;
    mmFullFunction: TMemo;
    procedure tvTypeInfoDblClick(Sender: TObject);
    procedure tvTypeInfoChange(Sender: TObject; Node: TTreeNode);
  private
    FItemList: TObjectList;
    FLibArray: TResList;
    FInterfacesNode: TTreeNode;

    function GetLibArray: TResList;
    function GetItemList: TObjectList;
    function GetClassesTree: TTreeView;
    function GetInterfacesNode: TTreeNode;
    function IsShowInherited: boolean;

    function GetClassesInspector: TfrmClassesInspector;

    procedure Reset;

    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure ShowTypeInfo(const Variable: Variant; const VariableName, TypeName: String);
  end;

var
  frmTypeInfo: TfrmTypeInfo;

implementation


{$R *.DFM}

procedure TfrmTypeInfo.ShowTypeInfo(const Variable: Variant;
  const VariableName, TypeName: String);
var
  Node: TTreeNode;
begin
  Reset;
  edVariable.Text := VariableName;
  if prpClassesInspector = nil then Exit;

  Node := tvTypeInfo.Items.AddFirst(nil, TypeName);
  if (VarType(Variable) = varDispatch) and (IDispatch(Variable) <> nil) then
  begin
    FInterfacesNode:= tvTypeInfo.Items.AddChild(Node, 'Интерфейсы');
    AddItemData(FInterfacesNode, ciParentTypeFolder, 'Интерфейсы, возвращаемые методами и свойствами ' + TypeName, self);
    try
      prpClassesInspector.AddItemsByDispath(Node, IDispatch(Variable), Self);
    finally
      FInterfacesNode := nil;
    end;
  end;

  Show;
end;

procedure TfrmTypeInfo.tvTypeInfoDblClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  case GetItemType(tvTypeInfo.Selected) of
    ciMethod, ciMethodGet, ciPropertyR, ciPropertyW, ciPropertyRW:
    begin
      with tvTypeInfo.Selected do
        if TWithResultItem(Data).ResultNodeRef <> nil then
        begin
          Node := TWithResultItem(Data).ResultNodeRef;
          Node.Selected := True;
          while (Node <> nil) and (not Node.Expanded) do
          begin
            Node.Expand(False);
            Node := Node.Parent;
          end;
          TWithResultItem(Data).ResultNodeRef.Focused := True;
        end;
    end;
  end;
end;

procedure TfrmTypeInfo.tvTypeInfoChange(Sender: TObject; Node: TTreeNode);
begin
  if Node.Data <> nil then
    mmDescription.Lines.Text := TInspectorItem(Node.Data).Description;

  case GetItemType(Node) of
    ciMethod, ciMethodGet, ciPropertyR, ciPropertyW, ciPropertyRW:
      mmFullFunction.Lines.Text := Node.Text;
  end;
end;

constructor TfrmTypeInfo.Create(AOwner: TComponent);
begin
  inherited;

  FLibArray := TResList.Create;
  FItemList := TObjectList.Create(True);
end;

destructor TfrmTypeInfo.Destroy;
begin
  FItemList.Free;
  FLibArray.Free;

  inherited;
  if frmTypeInfo = Self then
    frmTypeInfo := nil;
end;

function TfrmTypeInfo.GetItemList: TObjectList;
begin
  Result := FItemList;
end;

procedure TfrmTypeInfo.Reset;
begin
  if FItemList <> nil then
    FItemList.Clear;
  if FLibArray <> nil then
    FLibArray.Clear;

  tvTypeInfo.Items.Clear;
end;

function TfrmTypeInfo.GetClassesTree: TTreeView;
begin
  Result := tvTypeInfo;
end;

function TfrmTypeInfo.GetClassesInspector: TfrmClassesInspector;
begin
  raise Exception.Create('Форма не является "Инспектором классов"');
end;

function TfrmTypeInfo.GetLibArray: TResList;
begin
  Result := FLibArray;
end;

function TfrmTypeInfo.GetInterfacesNode: TTreeNode;
begin
  Result := FInterfacesNode;
end;

function TfrmTypeInfo.IsShowInherited: boolean;
begin
  Result:= True;
end;

end.
