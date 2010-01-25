unit gd_security_dlgChangeRigth;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, ComCtrls, Db, IBCustomDataSet, IBQuery, CheckLst;

type
  TdlgChangeRight = class(TForm)
    edName: TEdit;
    Label1: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    pcFull: TPageControl;
    tsFull: TTabSheet;
    tsChag: TTabSheet;
    tsView: TTabSheet;
    ibqryWork: TIBQuery;
    actShow: TAction;
    clbFull: TCheckListBox;
    clbChag: TCheckListBox;
    clbView: TCheckListBox;
    procedure actShowExecute(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure clbFullClickCheck(Sender: TObject);
    procedure clbChagClickCheck(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    AFull: Integer;
    AChag: Integer;
    AView: Integer;
    ARight: Byte;
  end;

var
  dlgChangeRight: TdlgChangeRight;

implementation

{$R *.DFM}

procedure TdlgChangeRight.actShowExecute(Sender: TObject);
var
  II: Integer;
begin
  ibqryWork.Open;
  clbFull.Enabled := ARight and 1 <> 0;
  if not clbFull.Enabled then
    AFull := 0;
  clbChag.Enabled := ARight and 2 <> 0;
  if not clbChag.Enabled then
    AChag := 0;
  clbView.Enabled := ARight and 4 <> 0;
  if not clbView.Enabled then
    AView := 0;
  while not ibqryWork.Eof do
  begin
    II := clbFull.Items.AddObject(ibqryWork.FieldByName('name').AsString,
     Pointer(ibqryWork.FieldByName('id').AsInteger));
    clbFull.Checked[II] := (AFull and (1 shl (ibqryWork.FieldByName('id').AsInteger - 1)) <> 0);

    II := clbChag.Items.AddObject(ibqryWork.FieldByName('name').AsString,
     Pointer(ibqryWork.FieldByName('id').AsInteger));
    clbChag.ItemEnabled[II] := (AFull and (1 shl (ibqryWork.FieldByName('id').AsInteger - 1)) = 0);
    if not clbChag.Enabled or clbChag.ItemEnabled[II] then
      clbChag.Checked[II] := (AChag and (1 shl (ibqryWork.FieldByName('id').AsInteger - 1)) <> 0)
    else
      clbChag.Checked[II] := True;

    II := clbView.Items.AddObject(ibqryWork.FieldByName('name').AsString,
     Pointer(ibqryWork.FieldByName('id').AsInteger));
    clbView.ItemEnabled[II] := ((AFull and (1 shl (ibqryWork.FieldByName('id').AsInteger - 1)))
     or (AChag and (1 shl (ibqryWork.FieldByName('id').AsInteger - 1))) = 0);
    if not clbView.Enabled or clbView.ItemEnabled[II] then
      clbView.Checked[II] := (AView and (1 shl (ibqryWork.FieldByName('id').AsInteger - 1)) <> 0)
    else
      clbView.Checked[II] := True;

    ibqryWork.Next;
  end;
end;

procedure TdlgChangeRight.btnOkClick(Sender: TObject);
var
  I: Integer;
begin
  try
    AFull := 0;
    for I := 0 to clbFull.Items.Count - 1 do
      if clbFull.Checked[I] then
        AFull := AFull or (1 shl (Integer(clbFull.Items.Objects[I]) - 1));
    AChag := 0;
    for I := 0 to clbChag.Items.Count - 1 do
      if clbChag.Checked[I] then
        AChag := AChag or (1 shl (Integer(clbChag.Items.Objects[I]) - 1));
    AView := 0;
    for I := 0 to clbView.Items.Count - 1 do
      if clbView.Checked[I] then
        AView := AView or (1 shl (Integer(clbView.Items.Objects[I]) - 1));
    {if AFull = 0 then
    begin
      ShowMessage('Полный доступ должен быть присвоен хотя бы одной группе');
      ModalResult := mrNone;
    end;}
    AFull := AFull or 1;
  except
    ModalResult := mrNone;
  end;
end;

procedure TdlgChangeRight.FormCreate(Sender: TObject);
begin
  AFull := 0;
  AChag := 0;
  AView := 0;
  ARight := 0;
end;

procedure TdlgChangeRight.clbFullClickCheck(Sender: TObject);
begin
  if clbFull.Checked[clbFull.ItemIndex] {or
   (MessageBox(Self.Handle, 'Удалить права доступа для изменения и просмотра?', 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES){} then
  begin
    if clbChag.Enabled then
      clbChag.Checked[clbFull.ItemIndex] := clbFull.Checked[clbFull.ItemIndex];
    if clbView.Enabled then
      clbView.Checked[clbFull.ItemIndex] := clbFull.Checked[clbFull.ItemIndex];
  end;
  if clbChag.Enabled then
    clbChag.ItemEnabled[clbFull.ItemIndex] := not clbFull.Checked[clbFull.ItemIndex];
  if clbView.Enabled then
    clbView.ItemEnabled[clbFull.ItemIndex] := not clbChag.Checked[clbFull.ItemIndex]
     and not clbFull.Checked[clbFull.ItemIndex];
end;

procedure TdlgChangeRight.clbChagClickCheck(Sender: TObject);
begin
  if clbChag.Checked[clbChag.ItemIndex] {or
   (MessageBox(Self.Handle, 'Удалить права доступа для просмотра?', 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES){} then
  begin
    if clbView.Enabled then
      clbView.Checked[clbChag.ItemIndex] := clbChag.Checked[clbChag.ItemIndex];
  end;
  if clbView.Enabled then
    clbView.ItemEnabled[clbChag.ItemIndex] := not clbChag.Checked[clbChag.ItemIndex];
end;

end.
