
unit UserAddUserDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, StdCtrls, Mask, DBCtrls, DBTables, mmLabel, mBitButton, xLabel, UserLogin,
  Grids, DBGrids, mmDBGrid, gsMultilingualSupport;

type
  TUserAddUserDialog = class(TForm)
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    xLabel: TxLabel;
    qryList: TQuery;
    mmDBGrid1: TmmDBGrid;
    DataSource1: TDataSource;
    mBitButton3: TmBitButton;
    ListBox1: TListBox;
    mBitButton4: TmBitButton;
    qryListCOLUMN1: TIntegerField;
    qryListUSERKEY: TIntegerField;
    qryListNAME: TStringField;
    gsMultilingualSupport: TgsMultilingualSupport;
    procedure FormCreate(Sender: TObject);
    procedure mBitButton1Click(Sender: TObject);
    procedure mBitButton2Click(Sender: TObject);
    procedure mBitButton3Click(Sender: TObject);
    procedure mBitButton4Click(Sender: TObject);
    procedure qryListFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure FormDestroy(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); reintroduce;
  end;

var
  UserAddUserDialog: TUserAddUserDialog;

implementation

{$R *.DFM}

uses
  Ternaries;

constructor TUserAddUserDialog.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
end;

procedure TUserAddUserDialog.FormCreate(Sender: TObject);
begin
  qryList.Open;
end;

procedure TUserAddUserDialog.mBitButton1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TUserAddUserDialog.mBitButton2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TUserAddUserDialog.mBitButton3Click(Sender: TObject);
var
  I: Integer;
begin
  I := ListBox1.Items.Add(qryList.FieldByName('name').AsString);
  if qryList.Fields[0].AsInteger = 0 then
    ListBox1.Items.Objects[I] := TSecItem.Create(qryList.Fields[1].AsInteger, -1)
  else
    ListBox1.Items.Objects[I] := TSecItem.Create(-1, qryList.Fields[1].AsInteger);
  qryList.Close;
  qryList.Open;
end;

procedure TUserAddUserDialog.mBitButton4Click(Sender: TObject);
begin
  ListBox1.Items.Objects[ListBox1.ItemIndex].Free;
  ListBox1.Items.Delete(ListBox1.ItemIndex);
end;

procedure TUserAddUserDialog.qryListFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I: Integer;
begin
  Accept := True;

  if ListBox1 = nil then
    exit;

  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    if ListBox1.Items.Objects[I] <> nil then
    begin
      with ListBox1.Items.Objects[I] as TSecItem do
        Accept := not (((DataSet.Fields[0].AsInteger = 0) and (UserKey = DataSet.Fields[1].AsInteger))
          or ((DataSet.Fields[0].AsInteger = 1) and (UserGroupKey = DataSet.Fields[1].AsInteger)));
      if not Accept then
        break;
    end;
  end;
end;

procedure TUserAddUserDialog.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    if ListBox1.Items.Objects[I] <> nil then
      (ListBox1.Items.Objects[I] as TSecItem).Free;
  end;
end;

end.

