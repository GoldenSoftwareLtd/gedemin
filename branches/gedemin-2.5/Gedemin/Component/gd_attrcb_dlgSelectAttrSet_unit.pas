 {++
   Project ADDRESSBOOK
   Copyright � 2000- by Golden Software

   ������

     dlgSelectAttrSet_unit

   ��������

     ���� ��� ������ �������� ��������� ��� ���������

   �����

     Shadevsky Andrey

   �������

     ver    date    who    what
     1.00 - 14.06.2000 - jkl - ������ ������

 --}

unit gd_attrcb_dlgSelectAttrSet_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, IBQuery, ComCtrls, ExtCtrls, StdCtrls,
  Menus, ActnList, gd_security, IBSQL, ImgList;

const
  TreeLeftBorder = 'LB';
  TreeRightBorder = 'RB';
  ViewCount = 50;

type
  TdlgSelectAttrSet = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edName: TEdit;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    ActionList1: TActionList;
    btnOk: TButton;
    btnCancel: TButton;
    ibqryFind: TIBQuery;
    actFind: TAction;
    cbCondition: TComboBox;
    Label2: TLabel;
    Button6: TButton;
    actTo: TAction;
    actFrom: TAction;
    Button7: TButton;
    tvAttrSet: TTreeView;
    Button3: TButton;
    actNext: TAction;
    ibsqlTarget: TIBSQL;
    tvTarget: TTreeView;
    ImageList1: TImageList;
    Button4: TButton;
    Button5: TButton;
    Button8: TButton;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure edNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actToExecute(Sender: TObject);
    procedure actFromExecute(Sender: TObject);
    procedure tvAttrSetDblClick(Sender: TObject);
    procedure lvTargetDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
  private
    FIsTree: Boolean;
    FAttrKey: Integer;
    FParentList: TList;
    FValueList: TStringList;

    procedure ShowAttrSet;
    procedure ShowFind(Qry: Boolean);
    procedure ShowTargetList(SL: TStrings);
    function CheckValue(StartP, EndP, Value: Integer): Integer;
    procedure Draw500Item;
  public
    function GetElements(AttrKey: Integer; SetList: TStrings): Boolean;
  end;

var
  dlgSelectAttrSet: TdlgSelectAttrSet;

  function ValueListCompare(List: TStringList; Index1, Index2: Integer): Integer;

implementation

uses
  gd_dlgAttrElement_unit;

{$R *.DFM}

procedure TdlgSelectAttrSet.Draw500Item;
var
  L: TTreeNode;
  I: Integer;
begin
  I := 0;
  while not ibqryFind.Eof and (I < ViewCount) do
  begin
    if ibqryFind.FieldByName('parent').IsNull then
      FParentList.Clear
    else
      while (FParentList.Count > 0) and
       (ibqryFind.FieldByName('parent').AsInteger <>
       Integer(TTreeNode(FParentList.Items[FParentList.Count - 1]).Data)) do
        FParentList.Delete(FParentList.Count - 1);
    if FParentList.Count = 0 then
      L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName('name').AsString)
    else
    begin
      L := tvAttrSet.Items.AddChild(TTreeNode(FParentList.Items[FParentList.Count - 1]),
       ibqryFind.FieldByName('name').AsString);
      FIsTree := True;
    end;
    FParentList.Add(L);

    L.Data := Pointer(ibqryFind.FieldByName('id').AsInteger);

    Inc(I);
    ibqryFind.Next;
  end;
end;

procedure TdlgSelectAttrSet.ShowTargetList(SL: TStrings);
var
  L: TTreeNode;
  I: Integer;
  TempList: TStrings;
  TargetParentList: TList;
begin
  if SL.Count = 0 then
  begin
    tvTarget.Items.BeginUpdate;
    tvTarget.Items.Clear;
    tvTarget.Items.EndUpdate;
    Exit;
  end;

  // ���������� ����������� ���������� ������
  ibsqlTarget.Close;
  ibsqlTarget.SQL.Clear;

  ibsqlTarget.SQL.Text := 'SELECT DISTINCT(gg2.id), 0 isinclude, gg2.lb, gg2.name, gg2.parent '
   + 'FROM gd_attrset gg1, gd_attrset gg2 WHERE gg1.attrkey = ' + IntToStr(FAttrKey)
   + ' AND gg2.attrkey = gg1.attrkey AND gg1.id IN(';
  TempList := TStringList.Create;
  try
    for I := 0 to SL.Count - 1 do
    begin
      TempList.Add(IntToStr(Integer(SL.Objects[I])));
      TempList.Add(',');
    end;
    TempList.Strings[TempList.Count - 1] := ')';
    ibsqlTarget.SQL.AddStrings(TempList);

    ibsqlTarget.SQL.Add('AND gg2.lb < gg1.lb AND gg2.rb >= gg1.rb');
    ibsqlTarget.SQL.Add('AND gg2.id NOT IN (');
    ibsqlTarget.SQL.AddStrings(TempList);
    ibsqlTarget.SQL.Add('UNION');
    ibsqlTarget.SQL.Add('SELECT gg1.id, 1 isinclude, gg1.lb, gg1.name, gg1.parent '
     + ' FROM gd_attrset gg1 ');
    ibsqlTarget.SQL.Add('WHERE gg1.attrkey = ' + IntToStr(FAttrKey) + ' AND gg1.id IN(');
    ibsqlTarget.SQL.AddStrings(TempList);
    ibsqlTarget.SQL.Add('ORDER BY 3');
  finally
    TempList.Free;
  end;
  ibsqlTarget.ExecQuery;

  TargetParentList := TList.Create;
  try
    // ���������� �����������
    tvTarget.Items.BeginUpdate;
    tvTarget.Items.Clear;

    while not ibsqlTarget.Eof do
    begin
      if ibsqlTarget.FieldByName('parent').IsNull then
        TargetParentList.Clear
      else
        while (TargetParentList.Count > 0) and
         (ibsqlTarget.FieldByName('parent').AsInteger <>
         Integer(TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]).Data)) do
          TargetParentList.Delete(TargetParentList.Count - 1);
      if TargetParentList.Count = 0 then
        L := tvTarget.Items.Add(nil, ibsqlTarget.FieldByName('name').AsString)
      else
      begin
        L := tvTarget.Items.AddChild(TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]),
         ibsqlTarget.FieldByName('name').AsString);
        FIsTree := True;
      end;
      TargetParentList.Add(L);

      L.Data := Pointer(ibsqlTarget.FieldByName('id').AsInteger);
      L.ImageIndex := ibsqlTarget.FieldByName('isinclude').AsInteger;
      L.SelectedIndex := ibsqlTarget.FieldByName('isinclude').AsInteger + 2;

      ibsqlTarget.Next;
    end;
  finally
    tvAttrSet.ShowLines := FIsTree;
    tvTarget.ShowLines := FIsTree;

    TargetParentList.Free;
    tvTarget.FullExpand;
    tvTarget.Items.EndUpdate;
  end;
end;

procedure TdlgSelectAttrSet.ShowAttrSet;
begin
  // ����� ���� ���������
  // ������
  ibqryFind.Close;
  ibqryFind.SQL.Clear;
  ibqryFind.SQL.Text := 'SELECT * FROM gd_attrset WHERE attrkey = ' + IntToStr(FAttrKey);
  ibqryFind.SQL.Add('ORDER BY lb');
  ibqryFind.Open;

  // ���������� �����������
  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  ibqryFind.First;
  Draw500Item;

  tvAttrSet.ShowLines := FIsTree;
  tvTarget.ShowLines := FIsTree;
  tvAttrSet.Items.EndUpdate;
end;

procedure TdlgSelectAttrSet.ShowFind(Qry: Boolean);
begin
  // ����� ������
  // ���������� �������
  if Qry then
  begin
    ibqryFind.Close;
    ibqryFind.SQL.Clear;
    ibqryFind.SQL.Text := 'SELECT DISTINCT(gg2.id), gg2.name, gg2.parent FROM gd_attrset gg1, '
      + 'gd_attrset gg2 WHERE gg1.attrkey = ' + IntToStr(FAttrKey)
      + {' AND gg2.attrkey = ' + IntToStr(FAttrKey) + }' AND ';

    case cbCondition.ItemIndex of
    0: ibqryFind.SQL.Add('UPPER(gg1.name) LIKE '''
     + AnsiUpperCase(edName.Text) + '%''');
    1: ibqryFind.SQL.Add('gg1.name CONTAINING ''' + edName.Text + '''');
    2: ibqryFind.SQL.Add('UPPER(gg1.name) LIKE ''%'
     + AnsiUpperCase(edName.Text) + '''');
    end;
    ibqryFind.SQL.Add('AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb ORDER BY gg2.lb');
    ibqryFind.Open;
  end;

  // ���������� �����������
  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  ibqryFind.First;
  Draw500Item;

  tvAttrSet.ShowLines := FIsTree;
  tvTarget.ShowLines := FIsTree;

  tvAttrSet.FullExpand;
  tvAttrSet.Items.EndUpdate;
end;

function TdlgSelectAttrSet.CheckValue(StartP, EndP, Value: Integer): Integer;
var
  Posit: Integer;
begin
  // ������� ��������� ������ � ������
  if StartP > EndP then
  begin
    Result := -1;
    Exit;
  end;
  Posit := StartP + (EndP - StartP) div 2;
  Result := Value - Integer(FValueList.Objects[Posit]);
  if Result = 0 then
    Result := Posit
  else
    if Result > 0 then
      Result := CheckValue(Posit + 1, EndP, Value)
    else
      if Result < 0 then
        Result := CheckValue(StartP, Posit - 1, Value);
end;

function TdlgSelectAttrSet.GetElements(AttrKey: Integer; SetList: TStrings): Boolean;
begin
  FAttrKey := AttrKey;

  FIsTree := False;
  // �������� ������� �����
  // ������� ��������� ������

  FValueList.Assign(SetList);
  FValueList.CustomSort(ValueListCompare);

  ShowTargetList(FValueList);
  Result := False;

  //ShowAttrSet;
  if ShowModal = mrOk then
  begin
    Result := True;
    SetList.Assign(FValueList);
  end;
end;

//�������� ���� ������
procedure TdlgSelectAttrSet.Button2Click(Sender: TObject);
begin
  ShowAttrSet;
  edName.Text := '';
end;

procedure TdlgSelectAttrSet.FormCreate(Sender: TObject);
begin
  cbCondition.ItemIndex := 0;
  FParentList := TList.Create;
  FValueList := TStringList.Create;
end;

procedure TdlgSelectAttrSet.actFindExecute(Sender: TObject);
begin
  ShowFind(True);
end;

procedure TdlgSelectAttrSet.actFindUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := edName.Text > '';
end;

procedure TdlgSelectAttrSet.edNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    actFind.Execute;
    Key := 0;
  end;
end;

procedure TdlgSelectAttrSet.actToExecute(Sender: TObject);
var
  I: Integer;
  Flag: Boolean;
begin
  Flag := False;
  // ������� ���������� ��������� � ������ �����
  for I := 0 to tvAttrSet.Items.Count - 1 do
    if tvAttrSet.Items[I].Selected then
      if CheckValue(0, FValueList.Count - 1,
       Integer(tvAttrSet.Items[I].Data)) = -1 then
      begin
        FValueList.AddObject(tvAttrSet.Items[I].Text, tvAttrSet.Items[I].Data);
        Flag := True;
        FValueList.CustomSort(ValueListCompare);
        {L := lvTarget.Items.Add;
        L.Caption := tvAttrSet.Items[I].Text;
        L.Data := tvAttrSet.Items[I].Data;}
      end;
  if Flag then
    ShowTargetList(FValueList);
end;

function ValueListCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  // ������� ����������
  Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index2]);
end;

procedure TdlgSelectAttrSet.actFromExecute(Sender: TObject);
var
  I, J: Integer;
  Flag: Boolean;
begin
  Flag := False;
  // �������� �� ������ �����
  for I := tvTarget.Items.Count - 1 downto 0 do
    if tvTarget.Items[I].Selected then
    begin
      J := CheckValue(0, FValueList.Count - 1, Integer(tvTarget.Items[I].Data));
      if J <> -1 then
      begin
        FValueList.Delete(J);
        Flag := True;
      end;
    end;
  if Flag then
    ShowTargetList(FValueList);
end;

procedure TdlgSelectAttrSet.tvAttrSetDblClick(Sender: TObject);
begin
  actTo.Execute;
end;

procedure TdlgSelectAttrSet.lvTargetDblClick(Sender: TObject);
begin
  actFrom.Execute;
end;

procedure TdlgSelectAttrSet.FormDestroy(Sender: TObject);
begin
  FParentList.Free;
  FValueList.Free;
end;

procedure TdlgSelectAttrSet.actNextExecute(Sender: TObject);
begin
  Draw500Item;
end;

procedure TdlgSelectAttrSet.actNextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not ibqryFind.Eof;
end;

procedure TdlgSelectAttrSet.actAddExecute(Sender: TObject);
begin
  with Tgd_dlgAttrElement.Create(Self) do
  try             
    SetDatabase(ibqryFind.Database, ibqryFind.Transaction);
    if AddElement(FAttrKey) then
      tvAttrSet.Items.Clear;
  finally
    Free;
  end;
end;

procedure TdlgSelectAttrSet.actEditExecute(Sender: TObject);
begin
  if tvAttrSet.Selected = nil then
    Exit;
  with Tgd_dlgAttrElement.Create(Self) do
  try
    SetDatabase(ibqryFind.Database, ibqryFind.Transaction);
    if EditElement(Integer(tvAttrSet.Selected.Data)) then
      tvAttrSet.Selected.Text := dbeName.Text;
  finally
    Free;
  end;
end;

procedure TdlgSelectAttrSet.actDeleteExecute(Sender: TObject);
begin
  if tvAttrSet.Selected = nil then
    Exit;
  with Tgd_dlgAttrElement.Create(Self) do
  try
    SetDatabase(ibqryFind.Database, ibqryFind.Transaction);
    if DeleteElement(Integer(tvAttrSet.Selected.Data)) then
      tvAttrSet.Selected.Delete;
  finally
    Free;
  end;
end;

procedure TdlgSelectAttrSet.actEditUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := tvAttrSet.Selected <> nil;
end;

end.

