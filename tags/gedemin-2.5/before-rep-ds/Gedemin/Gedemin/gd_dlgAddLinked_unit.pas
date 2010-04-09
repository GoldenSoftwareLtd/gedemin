unit gd_dlgAddLinked_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gsIBLookupComboBox, StdCtrls, ActnList, ComCtrls, dmDatabase_unit,
  IBDatabase, gdcBase;

type
  Tgd_dlgAddLinked = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    ActionList1: TActionList;
    pc: TPageControl;
    tsFile: TTabSheet;
    tsObject: TTabSheet;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    Label1: TLabel;
    edFileName: TEdit;
    Button4: TButton;
    actBrowse: TAction;
    actViewFile: TAction;
    Button5: TButton;
    Label2: TLabel;
    Label3: TLabel;
    cbClasses: TComboBox;
    iblkupObject: TgsIBLookupComboBox;
    od: TOpenDialog;
    Label4: TLabel;
    Label5: TLabel;
    edLinkedName: TEdit;
    edUserType: TEdit;
    ibtr: TIBTransaction;
    Label6: TLabel;
    cbSubTypes: TComboBox;
    Button6: TButton;
    actCreateName: TAction;
    chbxClassFirst: TCheckBox;
    iblkupFolder: TgsIBLookupComboBox;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure actBrowseExecute(Sender: TObject);
    procedure actViewFileExecute(Sender: TObject);
    procedure actViewFileUpdate(Sender: TObject);
    procedure iblkupObjectEnter(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure cbClassesChange(Sender: TObject);
    procedure actCreateNameExecute(Sender: TObject);
    procedure cbSubTypesChange(Sender: TObject);
    procedure chbxClassFirstClick(Sender: TObject);

  private
    procedure FillListBox;

  public
    { Public declarations }
  end;

var
  gd_dlgAddLinked: Tgd_dlgAddLinked;

implementation

{$R *.DFM}

uses
  gd_ClassList, ShellAPI, IBSQL, gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgd_dlgAddLinked.FormCreate(Sender: TObject);
begin
  ibtr.DefaultDatabase := dmDatabase.ibdbGAdmin;
  ibtr.StartTransaction;

  FillListBox;

  iblkupObject.Transaction := ibtr;
  iblkupFolder.Transaction := ibtr;
end;

procedure Tgd_dlgAddLinked.actBrowseExecute(Sender: TObject);
begin
  od.FileName := edFileName.Text;
  if od.Execute then
  begin
    edFileName.Text := od.FileName;
  end;
end;

procedure Tgd_dlgAddLinked.actViewFileExecute(Sender: TObject);
var
  Directory: array[0..254] of Char;
  Operation: array[0..4] of Char;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  R: Cardinal;
  AppSt: array[0..1023] of Char;
begin
  StrPCopy(Directory, ExtractFilePath(edFileName.Text));
  StrPCopy(AppSt, '');

  FindExecutable(PChar(edFileName.Text), Directory , AppSt);

  if AppSt = '' then
  begin
    if MessageBox(Self.Handle,
      'С файлами указанного типа не связано ни одного приложения.'#13#10 +
      'Использовать блокнот (notepad.exe) для просмотра?',
      'Внимание',
      MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
    begin
      exit;
    end else
    begin
      AppSt := 'notepad.exe';
    end;
  end;

  StrPCopy(AppSt, PChar('"' + String(AppSt) + '"'));

  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

  FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWDEFAULT;

  StrCat(AppSt, PChar(' "' + edFileName.Text + '"'));

  if True{NeedExit} then
  begin
    MessageBox(Self.Handle, 'Для того чтобы продолжить работать с Гедымином, закройте файл после просмотра.',
      'Просмотр файла', MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
  end;

  try
    if not CreateProcess(nil, AppSt, nil, nil, False,
      NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
    begin
      StrPCopy(Operation, 'open');
      {Попытаемся открыть через ShellExecute.
       Команда FindExecuteable некорректно обрабатывает строку, если в ней есть пробелы,
       и при этом она не заключена в ковычки}
      if ShellExecute(Self.Handle, Operation, @edFileName.Text[1], nil, Directory, SW_SHOW) <= 32 then
      begin
        MessageBox(Self.Handle,
          PChar(Format('Невозможно открыть файл %s.', [edFileName.Text])),
          'Внимание', MB_OK or MB_ICONEXCLAMATION);
      end else
      begin
        MessageBox(Self.Handle,
          PChar(Format('Все изменения, сделанные в файле %s, не будут сохранены в базу!',
            [edFileName.Text])),
            'Внимание', MB_OK or MB_ICONEXCLAMATION);
      end;
    end else

    if True{NeedExit} then
    begin
      Application.Minimize;
      Application.ProcessMessages;

      if not Application.Terminated then
      begin
        while GetExitCodeProcess(ProcessInfo.hProcess,R)
          and (R = STILL_ACTIVE) do
        begin
          Sleep(700);
        end;
        Application.Restore;
      end;  
    end;
  finally
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;

procedure Tgd_dlgAddLinked.actViewFileUpdate(Sender: TObject);
begin
  actViewFile.Enabled := FileExists(edFileName.Text);
end;

procedure Tgd_dlgAddLinked.iblkupObjectEnter(Sender: TObject);
begin
  if cbClasses.ItemIndex > -1 then
  begin
    iblkupObject.CurrentKey := '';
    iblkupObject.ListTable := '';
    iblkupObject.ListField := '';
    iblkupObject.KeyField := '';
    iblkupObject.Condition := '';
    iblkupObject.Fields := '';
    iblkupObject.SubType := '';
    iblkupObject.gdClassName :=
      CgdcBase(cbClasses.Items.Objects[cbClasses.ItemIndex]).ClassName;
    iblkupObject.SubType := cbSubTypes.Text;
  end;

  iblkupObject.Enabled := iblkupObject.ListTable > '';
end;

procedure Tgd_dlgAddLinked.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgd_dlgAddLinked.actOkExecute(Sender: TObject);
var
  q: TIBSQL;
begin
  if edLinkedName.Text = '' then
  begin
    actCreateName.Execute;
  end;

  if pc.ActivePage = tsFile then
  begin
    if iblkupFolder.CurrentKey = '' then
    begin
      MessageBox(Handle,
        'Пожалуйста, укажите папку!',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      exit;
    end;

    if edFileName.Text > '' then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := gdcBaseManager.ReadTransaction;
        q.SQL.Text := 'SELECT id FROM gd_file WHERE parent=:P and UPPER(name)=:N';
        q.ParamByName('P').AsInteger := iblkupFolder.CurrentKeyInt;
        q.ParamByName('N').AsString := AnsiUpperCase(ExtractFileName(edFileName.Text));
        q.ExecQuery;
        if not q.EOF then
        begin
          MessageBox(Handle,
            'Файл с таким именем уже занесен в базу данных!',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          exit;
        end;
      finally
        q.Free;
      end;
    end;
  end;

  ModalResult := mrOk;
end;

procedure Tgd_dlgAddLinked.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled :=
    ((pc.ActivePage = tsFile) and FileExists(edFileName.Text))
    or
    ((pc.ActivePage = tsObject) and
      ((iblkupObject.CurrentKey > '') and (cbClasses.Text > '')));
end;

procedure Tgd_dlgAddLinked.cbClassesChange(Sender: TObject);
var
  SL: TStringList;
  C: CgdcBase;
  I: Integer;
begin
  if cbClasses.ItemIndex > -1 then
  begin
    cbSubTypes.Items.Clear;
    cbSubTypes.Text := '';
    SL := TStringList.Create;
    try
      C := CgdcBase(cbClasses.Items.Objects[cbClasses.ItemIndex]);
      C.GetSubTypeList(SL);
      for I := 0 to SL.Count - 1 do
        cbSubTypes.Items.Add(SL.Values[SL.Names[I]]);
    finally
      SL.Free;
    end;
    iblkupObject.Enabled := True;
    iblkupObject.CurrentKey := '';
  end;
end;

procedure Tgd_dlgAddLinked.actCreateNameExecute(Sender: TObject);
begin
  if pc.ActivePage = tsObject then
  begin
    if iblkupObject.gdClass <> nil then
    begin
      edLinkedName.Text :=
        iblkupObject.gdClass.GetDisplayName(iblkupObject.SubType) +
        ' - ' + iblkupObject.Text;
    end;
  end else
  begin
    edLinkedName.Text := ExtractFileName(edFileName.Text);
  end;
end;

procedure Tgd_dlgAddLinked.cbSubTypesChange(Sender: TObject);
begin
  iblkupObject.Enabled := True;
  iblkupObject.CurrentKey := '';
end;

procedure Tgd_dlgAddLinked.FillListBox;
var
  I: Integer;
begin
  cbClasses.Clear;
  for I := 0 to gdcClassList.Count - 1 do
  begin
    if chbxClassFirst.Checked then
      cbClasses.Items.AddObject(gdcClassList[I].ClassName + ' - '
        + gdcClassList[I].GetDisplayName(''),
        Pointer(gdcClassList[I]))
    else
      cbClasses.Items.AddObject(gdcClassList[I].GetDisplayName('') + ' - '
        + gdcClassList[I].ClassName,
        Pointer(gdcClassList[I]));
  end;

  cbSubTypes.Clear;
end;

procedure Tgd_dlgAddLinked.chbxClassFirstClick(Sender: TObject);
begin
  FillListBox;
end;

end.
