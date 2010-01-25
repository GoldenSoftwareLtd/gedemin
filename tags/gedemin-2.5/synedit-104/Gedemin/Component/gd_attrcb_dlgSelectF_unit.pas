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

unit gd_attrcb_dlgSelectF_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, IBQuery, ComCtrls, ExtCtrls, StdCtrls,
  Menus, ActnList, gd_security, IBSQL;

const
  TreeLeftBorder = 'LB';
  TreeRightBorder = 'RB';
  ViewCount = 50;

type
  TdlgSelectF = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edName: TEdit;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Image1: TImage;
    ibqryFind: TIBQuery;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    Panel4: TPanel;
    lItemsCount: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    actFind: TAction;
    cbCondition: TComboBox;
    Label2: TLabel;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    ibsqlTree: TIBSQL;
    tvAttrSet: TTreeView;
    Button3: TButton;
    actNext: TAction;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure edNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvAttrSetDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
  private
    OkEn: Boolean;
    FTableName: String;
    FFieldName: String;
    FPrimaryName: String;
    FIsTree: Boolean;
    FParentList: TList;

    procedure ShowAttrSet;
    procedure ShowFind(Qry: Boolean);
    procedure Draw500Item;
  public
    function GetElement(const NameOfTable, NameOfField,
     NameOfPrimary: String; var SetName: String): Integer;
  end;

var
  dlgSelectF: TdlgSelectF;

implementation

{$R *.DFM}

// ����� ���� ���������
procedure TdlgSelectF.ShowAttrSet;
begin
  // ���������� �������
  ibqryFind.Close;
  ibqryFind.SQL.Clear;
  ibqryFind.SQL.Text := 'SELECT * FROM ' + FTableName;
  if FIsTree then
    ibqryFind.SQL.Add('ORDER BY lb');
  ibqryFind.Open;

  // ���������� �����������
  
  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  ibqryFind.First;
  Draw500Item;

  tvAttrSet.Items.EndUpdate;
end;

// ����� ���������� ������
procedure TdlgSelectF.ShowFind(Qry: Boolean);
begin
  // ���������� �������
  if Qry then
  begin
    ibqryFind.Close;                            
    ibqryFind.SQL.Clear;
    if not FIsTree then
      ibqryFind.SQL.Text := 'SELECT gg1.* FROM ' + FTableName + ' gg1 WHERE '
    else
      ibqryFind.SQL.Text := 'SELECT DISTINCT(gg2.id), gg2.* FROM ' + FTableName + ' gg1, '
        + FTableName + ' gg2 WHERE ';

    case cbCondition.ItemIndex of
    0: ibqryFind.SQL.Add('UPPER(gg1.' + FFieldName + ') LIKE '''
     + AnsiUpperCase(edName.Text) + '%''');
    1: ibqryFind.SQL.Add('gg1.' + FFieldName + ' CONTAINING ''' + edName.Text + '''');
    2: ibqryFind.SQL.Add('UPPER(gg1.' + FFieldName + ') LIKE ''%'
     + AnsiUpperCase(edName.Text) + '''');
    end;
    if FIsTree then
      ibqryFind.SQL.Add('AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb ORDER BY gg2.lb');
    ibqryFind.Open;
  end;

  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  // ���������� �����������
  ibqryFind.First;
  FParentList.Clear;

  Draw500Item;

  tvAttrSet.FullExpand;
  tvAttrSet.Items.EndUpdate;
end;

procedure TdlgSelectF.Draw500Item;
var
  L: TTreeNode;
  I: Integer;
begin
  I := 0;
  while not ibqryFind.Eof and (I < ViewCount) do
  begin
    if not FIsTree then
      L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString)
    else
    begin
      if ibqryFind.FieldByName('parent').IsNull then
        FParentList.Clear
      else
        while (FParentList.Count > 0) and
         (ibqryFind.FieldByName('parent').AsInteger <>
         Integer(TTreeNode(FParentList.Items[FParentList.Count - 1]).Data)) do
          FParentList.Delete(FParentList.Count - 1);
      if FParentList.Count = 0 then
        L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString)
      else
        L := tvAttrSet.Items.AddChild(TTreeNode(FParentList.Items[FParentList.Count - 1]),
         ibqryFind.FieldByName(FFieldName).AsString);
      FParentList.Add(L);
    end;
    L.Data := Pointer(ibqryFind.FieldByName(FPrimaryName).AsInteger);

    Inc(I);
    ibqryFind.Next;
  end;
end;

// �������� ������� �������
function TdlgSelectF.GetElement(const NameOfTable, NameOfField,
 NameOfPrimary: String; var SetName: String): Integer;
begin
  FIsTree := False;
  Result := -1;
  FTableName := Trim(NameOfTable);
  FFieldName := Trim(NameOfField);
  FPrimaryName := Trim(NameOfPrimary);
  edName.Text := SetName;

  ibsqlTree.Close;
  ibsqlTree.Params[0].AsString := AnsiUpperCase(FTableName);
  try
    ibsqlTree.ExecQuery;
    FIsTree := ibsqlTree.Fields[0].AsInteger = 1;
  except
  end;
  tvAttrSet.ShowLines := FIsTree;
  // ���� �������� ������ �� �����
  if SetName = '' then
  begin
    //ShowAttrSet;
    // ���������
    if ShowModal = mrOk then
    begin
      if tvAttrSet.Selected <> nil then
      begin
        Result := Integer(tvAttrSet.Selected.Data);
        SetName := tvAttrSet.Selected.Text;
      end;
    end
  end else begin
    // ���� �������� ������ �����
    // , �� �����
    cbCondition.ItemIndex := 1;
    ibqryFind.Close;
    ibqryFind.SQL.Text := 'SELECT * FROM ' + FTableName + ' WHERE ';
    ibqryFind.SQL.Add(FFieldName + ' CONTAINING ''' + edName.Text + '''');
    ibqryFind.Open;

    // ���� ������ �� �������
    ibqryFind.First;
    if ibqryFind.Eof then
    begin
      if (ShowModal = mrOk) then
        if tvAttrSet.Selected <> nil then
        begin
          Result := Integer(tvAttrSet.Selected.Data);
          SetName := tvAttrSet.Selected.Text;
        end;
    end else
    begin
      ibqryFind.Next;
      // ���� ������� ������ ����� ������
      if (not ibqryFind.Eof) then
      begin
        ShowFind(FIsTree);
        if (ShowModal = mrOk) then
          if tvAttrSet.Selected <> nil then
          begin
            Result := Integer(tvAttrSet.Selected.Data);
            SetName := tvAttrSet.Selected.Text;
          end;
      // ���� ������� ���� ������
      end else begin
        Result := ibqryFind.FieldByName(Trim(FPrimaryName)).AsInteger;
        SetName := ibqryFind.FieldByName(Trim(FFieldName)).AsString;
      end;
    end;
  end;
end;

// ������� ��� ��������
procedure TdlgSelectF.Button2Click(Sender: TObject);
begin
  ShowAttrSet;
  edName.Text := '';
end;

procedure TdlgSelectF.FormCreate(Sender: TObject);
begin
  OkEn := False;
  cbCondition.ItemIndex := 0;
  FParentList := TList.Create;
end;

procedure TdlgSelectF.actFindExecute(Sender: TObject);
begin
  ShowFind(True);
end;

procedure TdlgSelectF.actFindUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := edName.Text > '';
  btnOk.Enabled := OkEn or (tvAttrSet.Selected <> nil);
end;

procedure TdlgSelectF.edNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    actFind.Execute;
    Key := 0;
  end;
end;

procedure TdlgSelectF.tvAttrSetDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgSelectF.FormDestroy(Sender: TObject);
begin
  FParentList.Free;
end;

procedure TdlgSelectF.actNextExecute(Sender: TObject);
begin
  Draw500Item;
end;

procedure TdlgSelectF.actNextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not ibqryFind.Eof;
end;

end.
