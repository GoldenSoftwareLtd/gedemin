unit Convform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, DB, DBTables,
  MemTable, SplitBar, DBGrids, Xbkini, Xtable, xCalend;

type
  TfrmConvert = class(TForm)
    odInfoFile: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    SplitBar1: TSplitBar;
    Panel5: TPanel;
    lblFileName: TLabel;
    edFileName: TEdit;
    bList: TButton;
    Button1: TButton;
    Button2: TButton;
    dsMemTable: TDataSource;
    MemTable: TMemTable;
    MemTableListNum: TStringField;
    MemTableDays: TStringField;
    MemTableHours: TStringField;
    BitBtn1: TBitBtn;
    MemTableFullName: TStringField;
    xTable: TxTable;
    xBookkeepIni: TxBookkeepIni;
    BitBtn2: TBitBtn;
    lbCipher: TListBox;
    MemTable1: TMemTable;
    MemTable1ListNum: TStringField;
    MemTable1FullName: TStringField;
    MemTable1Days: TStringField;
    MemTable1Hours: TStringField;
    MemTable1Days1: TStringField;
    MemTable1Hours1: TStringField;
    Panel6: TPanel;
    Label1: TLabel;
    Panel7: TPanel;
    Label2: TLabel;
    xCalendarCombo: TxCalendarCombo;
    Label3: TLabel;
    Employee: TTable;
    procedure bListClick(Sender: TObject);
    procedure bConvertDoClick(Sender: TObject);
    procedure lbCipherClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn2Click(Sender: TObject);

  public
    OrderNum: String;
  end;

var
  frmConvert: TfrmConvert;
  SourceFile: TStringList;

implementation

uses
  orkl, EmplRef;

{$R *.DFM}

{ FORM_CREATE }
procedure TfrmConvert.FormCreate(Sender: TObject);
begin
  OrderNum := '';
  SourceFile := TStringList.Create;
  MemTable.Open;
end;

{ FORM_DESTROY }
procedure TfrmConvert.FormDestroy(Sender: TObject);
begin
  SourceFile.Free;
end;

{ B_LIST__CLICK}
procedure TfrmConvert.bListClick(Sender: TObject);
begin
  if odInfoFile.Execute then begin
    edFileName.Text := odInfoFile.FileName;
  end;
end;

{ B_CONVERT_DO__CLICK }
procedure TfrmConvert.bConvertDoClick(Sender: TObject);
var
  FF: TextFile;
  St, Cipher: String;
  I: Integer;
  FirstLine: Boolean;
begin
  if not FileExists(edFileName.Text) then
  begin
    MessageBox(HANDLE, 'Такого файла не суещствует!',
      'Ошибка!', MB_ICONSTOP or MB_OK);
    exit;
  end;

  SourceFile.Clear;
  lbCipher.Clear;

  AssignFile(FF, edFileName.Text);
  Reset(FF);
  FirstLine := True;
  while not EOF(FF) do
  begin
    ReadLn(FF, St);
    if not FirstLine then
      SourceFile.Add(St)
    else
      FirstLine := False;
  end;

  CloseFile(FF);

  for I := 0 to SourceFile.Count - 1 do
  begin
    Cipher := Copy(SourceFile.Strings[I], 1, Pos(';', SourceFile.Strings[I]) - 1);
    if lbCipher.Items.IndexOf(Cipher) = -1 then
      lbCipher.Items.Add(Cipher);
  end;

  lbCipher.SetFocus;
  lbCipher.ItemIndex := 0;
  lbCipherClick(Sender);
end;

{ LB_CIPHER__CLICK}
procedure TfrmConvert.lbCipherClick(Sender: TObject);
var
  St, S: String;
  I: Integer;
begin
  MemTable.Close;
  MemTable.Open;

  for I := 0 to SourceFile.Count - 1 do
  begin
    S := SourceFile.Strings[I];
    St := Copy(S, 1, Pos(';', S) - 1);

    if St = lbCipher.Items[lbCipher.ItemIndex] then
    begin
      Delete(S, 1, Length(St) + 1);

      MemTable.Append;

      (* табельный номер *)
      St := Copy(S, 1, Pos(';', S) - 1);

      MemTableListNum.Value := St;
      Delete(S, 1, Length(St) + 1);

      (* ФИО работника *)
      St := Copy(S, 1, Pos(';', S) - 1);
      MemTableFullName.Value := St;
      Delete(S, 1, Length(St) + 1);

      (* кол-во дней *)
      St := Copy(S, 1, Pos(';', S) - 1);
      MemTableDays.Value := St;
      Delete(S, 1, Length(St) + 1);

      MemTableHours.Value := S;
      MemTable.Post;
    end;
  end;
end;

procedure TfrmConvert.Button1Click(Sender: TObject);
begin
  OrderNum := '';
  if lbCipher.Items.Count > 0 then OrderNum := lbCipher.Items[lbCipher.ItemIndex];
end;

procedure TfrmConvert.FormClose(Sender: TObject; var Action: TCloseAction);
var
  A, B: Array [0..255] of char;
  S: string;
  ExistOrder: Boolean;
begin
  ExistOrder := False;

  if ModalResult = mrOk then
  begin
    StrPCopy(A, ExtractFilePath(Application.ExeName) + 'netwage.ini');
    GetPrivateProfileString('Golden Prime System', 'OrderReference',
      'IndExp.db', B, SizeOf(B), A);

    xTable.DatabaseName := xBookkeepIni.MainDir;
    xTable.TableName := StrPas(B);
    xTable.Open;
    xTable.IndexFieldNames := xTable.Fields[1].FieldName;

    try
      xTable.First;
      while not xTable.EOF do
      begin
        if xTable.Fields[1].Text = lbCipher.Items[lbCipher.ItemIndex] then
        begin
          ExistOrder := True;
          Break;
        end;

        xTable.Next;
      end;
    finally
      xTable.Close;
    end;

    if not ExistOrder then
    begin
      MessageBox(Handle, 'Такого заказа нет в справочнике!',
        'Внимание!', mb_IconInformation);
      Abort;
    end;
  end;
end;

procedure TfrmConvert.BitBtn2Click(Sender: TObject);
var
  I: Integer;
  Exist: Boolean;
  xEmplRefForm: TEmplRefForm;
  xOtklForm: TOtklForm;
begin
  (* Суммируем данные *)
  MemTable1.Close;
  MemTable1.Open;

  for I := 0 to lbCipher.Items.Count - 1 do
  begin
    lbCipher.ItemIndex := I;
    lbCipherClick(Sender);

    MemTable.First;
    while not MemTable.EOF do
    begin
      Exist := False;

      MemTable1.First;
      while not MemTable1.EOF do
      begin
        if MemTableListNum.Value = MemTable1ListNum.Value then
        begin
          Exist := True;

          MemTable1.Edit;

          MemTable1Days1.AsFloat := MemTable1Days1.AsFloat + MemTableDays.AsFloat;
          MemTable1Hours1.AsFloat := MemTable1Hours1.AsFloat + MemTableHours.AsFloat;

          MemTable1.Post;

          Break;
        end;

        MemTable1.Next;
      end;

      if not Exist then
      begin
        MemTable1.Append;
        MemTable1ListNum.Value := MemTableListNum.Value;
        MemTable1FullName.Value := MemTableFullName.Value;

        MemTable1Days.AsFloat := 0;
        MemTable1Hours.AsFloat := 0;

        MemTable1Days1.AsFloat := MemTableDays.AsFloat;
        MemTable1Hours1.AsFloat := MemTableHours.AsFloat;

        MemTable1.Post;
      end;

      MemTable.Next;
    end;
  end;

  (* Проверяем плановое время *)
  xEmplRefForm := TemplRefForm.Create(Self);
  try
    xEmplRefForm.WorkDate := xCalendarCombo.Date;
    Employee.Open;

    MemTable1.First;
    while not MemTable1.EOF do
    begin
      MemTable1.Edit;

      if Employee.FindKey([MemTable1ListNum.Value]) then
      begin
        xEmplRefForm.EmplKey := Employee.FieldByName('EmplKey').AsInteger;

        MemTable1Days.AsFloat := xEmplRefForm.Days;
        MemTable1Hours.AsFloat := xEmplRefForm.Hours;
      end;

      MemTable1.Post;

      MemTable1.Next;
    end;
  finally
    xEmplRefForm.Free;
  end;

  (* Переносим только те, у которых отклонение *)
  xOtklForm := TOtklForm.Create(Self);
  try
    xOtklForm.MemTable.Close;
    xOtklForm.MemTable.Open;

    MemTable1.First;
    while not MemTable1.EOF do
    begin
      if (MemTable1Days.Value <> MemTable1Days1.Value) or
        (MemTable1Hours.Value <> MemTable1Hours1.Value) then
      begin
        xOtklForm.MemTable.Append;

        xOtklForm.MemTableListNum.Value := MemTable1ListNum.Value;
        xOtklForm.MemTableFullname.Value := MemTable1FullName.Value;

        xOtklForm.MemTableDays.Value := MemTable1Days.Value;
        xOtklForm.MemTableHours.Value := MemTable1Hours.Value;

        xOtklForm.MemTableDays1.Value := MemTable1Days1.Value;
        xOtklForm.MemTableHours1.Value := MemTable1Hours1.Value;

        xOtklForm.MemTable.Post;
      end;

      MemTable1.Next;
    end;

    xOtklForm.ShowModal;
  finally
    xOtklForm.Free;
  end;

  MemTable1.Close;
end;

end.
