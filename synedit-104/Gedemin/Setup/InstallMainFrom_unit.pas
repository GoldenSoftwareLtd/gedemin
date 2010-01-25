unit InstallMainFrom_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, gsGedeminInstall, ActnList, jpeg, OleCtrls,
  SHDocVw, Buttons;

type
  TInstallMainFrom = class(TForm)
    Panel1: TPanel;
    PageControl: TPageControl;
    GedeminInstall: TGedeminInstall;
    tsPath: TTabSheet;
    tsInstallType: TTabSheet;
    tsInstallModules: TTabSheet;
    tsLog: TTabSheet;       
    mmLog: TMemo;
    ActionList: TActionList;
    actNext: TAction;
    actPrior: TAction;
    tsFinish: TTabSheet;
    Panel7: TPanel;
    mmPath: TMemo;
    Panel8: TPanel;
    Panel9: TPanel;
    rgInstallType: TRadioGroup;
    mmType: TMemo;
    Panel5: TPanel;
    Panel3: TPanel;
    Bevel2: TBevel;
    Panel10: TPanel;
    Panel11: TPanel;
    cbServer: TCheckBox;
    cbClient: TCheckBox;
    cbReportServer: TCheckBox;
    mmModules: TMemo;
    mmFinish: TMemo;
    lblPathLabel: TLabel;
    Label1: TLabel;
    Bevel1: TBevel;
    Bevel3: TBevel;
    cbStart: TCheckBox;
    tsActions: TTabSheet;
    Panel16: TPanel;
    Memo3: TMemo;
    Memo2: TMemo;
    Memo1: TMemo;
    Panel17: TPanel;
    Image6: TImage;
    rbInstall: TRadioButton;
    rbUpdate: TRadioButton;
    rbUninstall: TRadioButton;
    Image7: TImage;
    Image8: TImage;
    actBreak: TAction;
    eIBPath: TEdit;
    eGDPath: TEdit;
    btnPrior: TButton;
    btnNext: TButton;
    btnCancel: TButton;
    btnIBPath: TButton;
    btnGDPath: TButton;
    btnHelp: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GedeminInstallInstallLog(const AnMessage: String);
    procedure btnIBPathClick(Sender: TObject);
    procedure btnGDPathClick(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPriorExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actPriorUpdate(Sender: TObject);
    procedure GedeminInstallInstallFinish(AnSuccess: Boolean;
      AnErrorMessage: String);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actBreakUpdate(Sender: TObject);
    procedure actBreakExecute(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    FPriorEnabled, FNextEnabled: Boolean;
    FParamsInstall: Boolean;
    FTypeRead, FModulesRead: Boolean;
    FIniType: TInstallType;
    FIniModules: TInstallModules;
//    FGedeminInstall: TGedeminInstall;
    procedure StartInstall;
    procedure ReadIni;
  public
    { Public declarations }
  end;

var
  InstallMainFrom: TInstallMainFrom;

implementation

uses
  gsSysUtils, {inst_OpenDir_unit, }inst_const, inst_var, FileCtrl, ShellApi,
  inst_string_const;

const
  c10000 = 10000;

{$R *.DFM}

procedure TInstallMainFrom.FormCreate(Sender: TObject);
var
  LInfo, TempStr: String;
//  Vrnt, Vrnt2: OleVariant;
begin
{  WebBrowser1.Navigate('c:\temp\1.html');
  Vrnt := WebBrowser1.Application;
  GetMembers(Vrnt);
  Vrnt2 := Vrnt.Body;}
{      SelStart := L;
      SelLength := M - SelStart;
      SelAttributes.Color := C;

      SelLength := 0;
      SelStart := M;

      SelAttributes.Color := clBlack;
      SelAttributes.Charset := RUSSIAN_CHARSET;}

  Memo1.WordWrap := True;
  Memo2.WordWrap := True;
  Memo3.WordWrap := True;

  rbInstall.Enabled := GedeminInstall.YetInstalledModules = [];
  rbInstall.Checked := rbInstall.Enabled;
//  rbInstall.Flat := not rbInstall.Enabled;
  rbUpdate.Enabled := not rbInstall.Enabled;
//  �bUpdate.Flat := not �bUpdate.Enabled;
  rbUninstall.Enabled := not rbInstall.Enabled;
//  rbUninstall.Flat := not rbUninstall.Enabled;

  mmPath.Lines.Text := cFirstPage;
  LInfo := '';

  mmModules.Lines.Text := Format(mmModules.Lines.Text, [vServerName, vServerVersion, vServerName]);
  lblPathLabel.Caption := '���� ��� ��������� ������� ' + vServerName;
  FParamsInstall := True;
  FPriorEnabled := True;
  FNextEnabled := True;
  FTypeRead := False;
  FModulesRead := False;
  ReadIni;
  PageControl.ActivePage := tsActions;
  cbServer.Checked := (cServerFlags * GedeminInstall.YetInstalledModules) = cServerFlags;
  cbClient.Checked := (cClientFlags * GedeminInstall.YetInstalledModules) = cClientFlags;
{  cbReportServer.Checked := (cReportFlags * GedeminInstall.YetInstalledModules) = cReportFlags; sty}

  // ���� ���� �����������, ���������� �� ��������� ��� ����� � ��������� �� �������� �������
  if (GedeminInstall.ProgramPath <> '') and
     (GedeminInstall.InterbasePath <> '') and
     (GedeminInstall.YetInstalledModules <> []) {and
   FileExists(GedeminInstall.ProgramPath + vMainGedeminFile)} then
  begin
    LInfo := Format('�� ����� ���������� � ����� "%s" ���������� ��������� ����������� ������ ��������� �������: ',
     [GedeminInstall.ProgramPath]);
    if cbServer.Checked then
      LInfo := LInfo + '��������� �����, ';
    if cbClient.Checked then
      LInfo := LInfo + '���������� �����, ';
{    if cbReportServer.Checked then
      LInfo := LInfo + '������ �������. '; sty}
    // ������ ����� � ���������� ��������� �� ������
    if Length(LInfo) > 1 then
      LInfo[Length(LInfo) - 1] := '.';
    LInfo := LInfo + '�� ������ �������� ��������� ������ ';
    if not (cbClient.Checked {and cbReportServer.Checked sty}) then
    begin
      TempStr := '';
      if not cbClient.Checked then
        TempStr := '���������� ����� ';
{      if not cbReportServer.Checked then
      begin
        if TempStr <> '' then
          TempStr := TempStr + '� ';
        TempStr := TempStr + '������ ������� ';
      end; sty}
      LInfo := LInfo + '�/��� ���������� ' + TempStr + '������� ����������� ������ ��������. ';
      LInfo := LInfo + '����� ������ ������� ������ "������" ��� �����������. ';
    end else
      LInfo := LInfo + '�������� �� ������ "������". ';

//    if not cbServer.Checked then
//      LInfo := LInfo + '��������� ����� �� �������� �.�. ���� ������ ��������� �� ������ ����������. ';

    mmModules.Lines.Insert(0, LInfo + #13#10);
//    cbServer.Enabled := cbServer.Checked;
//    PageControl.ActivePage := tsInstallModules;
  end else
    begin
      if GedeminInstall.YetInstalledModules = [] then
        PageControl.ActivePageIndex := 1;        // ��������� ����� �� ����. �������� (����)
    end;

  if LInfo > '' then
    mmModules.ScrollBars := ssVertical;
  mmModules.WordWrap := True;

{ DONE -oYuri : Program Files - ��� �� �����������. �������� ����� ����������. }
  if GedeminInstall.InterbasePath = '' then
    GedeminInstall.InterbasePath := {ExtractFileDrive(SystemDirectory) + '\Program Files\' + } GetProgramFilesString + '\' + vServerName
  else begin
    btnIBPath.Enabled := False;
    eIBPath.Enabled := False;
  end;
  if GedeminInstall.ProgramPath = '' then
    GedeminInstall.ProgramPath := {ExtractFileDrive(SystemDirectory) + '\Program Files} GetProgramFilesString + '\Golden Software\Gedemin'
  else begin
    btnGDPath.Enabled := False;
    eGDPath.Enabled := False;
  end;
  mmLog.Clear;
  eIBPath.Text := GedeminInstall.InterbasePath;
  eGDPath.Text := GedeminInstall.ProgramPath;
{  lblIBPath.Caption := GedeminInstall.InterbasePath;
  lblGDPath.Caption := GedeminInstall.ProgramPath;}

  // ���� ������ � ����������� ������� ��� ���������� �������� �� ���������
  if ParamCount > 0 then
    Exit;
                                     
  // �� ��������� ��������������������� ���������
  rgInstallType.ItemIndex := 1;
  // �� ��������� ������ ������ ���������� �����
  if GedeminInstall.YetInstalledModules = [] then
    cbClient.Checked := True;

{  if not FileExists(GetSourceMainPath + cFilesIni) then
    Close;}

//  else
//    FPriorEnabled := False;
end;

procedure TInstallMainFrom.FormDestroy(Sender: TObject);
var
  FileName: String;
begin
  if mmLog.Lines.Count > 0 then
  begin
    FileName := GedeminInstall.LogFileName;
    GedeminInstall.CreateDirectory(ExtractFileDir(FileName));
    mmLog.Lines.SaveToFile(FileName);
  end;
end;

procedure TInstallMainFrom.GedeminInstallInstallLog(
  const AnMessage: String);
begin
  mmLog.Lines.Add(AnMessage);
end;

procedure TInstallMainFrom.btnIBPathClick(Sender: TObject);
var
  Path: String;
begin                                                      
  if SelectDirectory('������� ����� ��� ��������� ������� �� ' + cServerName, '', Path) then
    eIBPath.Text := Path;
//    lblIBPath.Caption := Path;
{var
  S: String;
begin
  if SelectDirectory('�������� ���� ����������� ' + cServerName, '', S) then
    lblIBPath.Caption := S;}
{begin
  with TOpenDir.Create(nil) do
  try
    if Execute(lblIBPath.Caption) then
      lblIBPath.Caption := Directory;
  finally
    Free;
  end; sty}
end;

procedure TInstallMainFrom.btnGDPathClick(Sender: TObject);
var
  Path: String;
begin
  if SelectDirectory('������� ����� ', '', Path) then
    eGDPath.Text := Path;
//    lblGDPath.Caption := Path;
{  with TOpenDir.Create(nil) do
  try
    if Execute(lblGDPath.Caption) then
      lblGDPath.Caption := Directory;
  finally
    Free;
  end; sty}
end;

procedure TInstallMainFrom.actNextExecute(Sender: TObject);
var
  S: String;

  procedure InstallModulesExecute;
  begin
    GedeminInstall.InstallModules := [];
    if cbServer.Checked then
      GedeminInstall.InstallModules := cServerFlags;
    if cbClient.Checked then
      GedeminInstall.InstallModules := GedeminInstall.InstallModules + cClientFlags;
{    if cbReportServer.Checked then
      GedeminInstall.InstallModules := GedeminInstall.InstallModules + cReportFlags;}
    if GedeminInstall.InstallModules = [] then
      S := '���������� ������� ������ ��� ���������!';
  end; 

  procedure InstallTypeExecute;
  begin
    if rgInstallType.ItemIndex = -1 then
      S := '�� ������ ��� ���������.'
    else
    begin
      case rgInstallType.ItemIndex of
        0:
        begin
          GedeminInstall.InstallType := itLocal;
          GedeminInstall.InstallModules := cServerFlags + cClientFlags;
          PageControl.ActivePage := tsInstallModules;
        end;
        1:
        begin
          GedeminInstall.InstallType := itMulti;
          if FModulesRead then
          begin
            PageControl.ActivePage := tsInstallModules;
            cbServer.Checked := cServerFlags * FIniModules = cServerFlags;
            cbClient.Checked := cClientFlags * FIniModules = cClientFlags;
{            cbReportServer.Checked := cReportFlags * FIniModules = cReportFlags; sty}
            InstallModulesExecute;
          end;
        end;
      else
        raise Exception.Create('����������� ���');
      end;
    end;
  end;
begin
  S := '';
  if PageControl.ActivePage = tsActions then
  begin
    if rbInstall.Checked then
    begin
      if (GedeminInstall.YetInstalledModules <> []) then
        raise Exception.Create('���������� ��������� ��������� ���������. ��������� ��� �����������.')
    end else
      if rbUpdate.Checked then
      begin
        if GedeminInstall.InstallType = itLocal then
        begin
          PageControl.ActivePage := tsInstallModules;
          InstallModulesExecute;
        end else
          PageControl.ActivePage := tsInstallType;
      end else     // �� rbUpdate.Checked  
        if rbUninstall.Checked then
        begin
          GedeminInstall.StartUninstall;
          mmFinish.Lines.Add('');
          mmFinish.Lines.Add('������� �������� �������� ������ � �����: ' +
            GedeminInstall.ProgramPath + '\install.log');
          cbStart.Visible := False;
          PageControl.ActivePage := tsFinish;
          FPriorEnabled := False;
          Exit;
        end else
          S := '�� ������� ��������.';
  end else         // ActivePage <> tsActions
    if PageControl.ActivePage = tsPath then
    begin
      if (Trim(eIBPath.Text) = '') or
         (Trim(eGDPath.Text) = '') then
        S := '�� ������ ���� ��� ���������.'
      else begin
                           
        if not DirectoryExists(eIBPath.Text) and
           (eIBPath.Text <> GedeminInstall.InterbasePath) then
        begin
          if MessageBox(Handle, PChar(Format(cPathDoesNotExistsQuest, [eIBPath.Text])),
            '��������', MB_YESNO or MB_ICONQUESTION) = IDYES then
          begin
            if ForceDirectories(eIBPath.Text) then
              GedeminInstall.InterbasePath := eIBPath.Text
            else begin
              S := '����� ' + eIBPath.Text + ' �� �������!';
              MessageBox(Handle, @S[1], '��������', MB_ICONSTOP or MB_OK);
              Exit;
            end
          end else
            Exit;
//            S := '���������� ������� ���� ��� ���������!';
        end;

        if not DirectoryExists(eGDPath.Text) and
          (eGDPath.Text <> GedeminInstall.ProgramPath) then
        begin
          if MessageBox(Handle, PChar(Format(cPathDoesNotExistsQuest, [eGDPath.Text])), '��������', MB_YESNO or MB_ICONQUESTION) = IDYES then
          begin
            if ForceDirectories(eGDPath.Text) then
              GedeminInstall.ProgramPath := eGDPath.Text
            else begin
              S := '����� ' + eGDPath.Text + ' �� �������!';    
              MessageBox(Handle, @S[1], '��������', MB_ICONSTOP or MB_OK);
              Exit;
            end;
          end else
            Exit;//S := '���������� ������� ���� ��� ���������!';
        end;

      end;
      if S = '' then
      begin
        if GedeminInstall.YetInstalledModules <> [] then
          PageControl.ActivePage := tsInstallType;
        if FTypeRead and (PageControl.ActivePage = tsPath) then
        begin
          PageControl.ActivePage := tsInstallType;
          if FIniType = itLocal then
            rgInstallType.ItemIndex := 0
          else
            rgInstallType.ItemIndex := 1;
          InstallTypeExecute;
        end;
      end;
    end else       // ActivePage <> tsPath
      if PageControl.ActivePage = tsInstallType then
      begin
        InstallTypeExecute;
      end else
        if PageControl.ActivePage = tsInstallModules then
        begin
          if not cbClient.Checked then
            cbStart.Visible := False;
          InstallModulesExecute;
        end;

  if S = '' then
    PageControl.ActivePageIndex := PageControl.ActivePageIndex + 1
  else begin                
    MessageBox(Handle, @S[1], '��������', MB_ICONWARNING or MB_OK);
    Exit;
  end;
  StartInstall;
end;

procedure TInstallMainFrom.actPriorExecute(Sender: TObject);
var
  I: Integer;                     
begin
  I := 1;
  if FTypeRead and (PageControl.ActivePage = tsInstallModules) then
  begin
    if btnIBPath.Enabled or btnGDPath.Enabled then
      I := 2
    else
      I := 3;
  end;
  PageControl.ActivePageIndex := PageControl.ActivePageIndex - I;
end;

procedure TInstallMainFrom.actNextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (PageControl.PageCount > PageControl.ActivePageIndex + 1) and
    FNextEnabled;
end;

procedure TInstallMainFrom.actPriorUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (PageControl.ActivePageIndex > 0) and FPriorEnabled;
end;

procedure TInstallMainFrom.GedeminInstallInstallFinish(AnSuccess: Boolean;
  AnErrorMessage: String);
begin
  mmLog.Lines.Add('');
  mmLog.Lines.Add(AnErrorMessage);
  mmFinish.Lines.Clear;
  if AnSuccess then
    MessageBox(Handle, PChar(AnErrorMessage), '��������', MB_OK or MB_ICONINFORMATION)
  else begin  
    MessageBox(Handle, PChar(AnErrorMessage), '������', MB_OK or MB_ICONERROR);
    cbStart.Visible := False;
  end;
  mmFinish.Lines.Add(AnErrorMessage);
  btnCancel.Caption := '�������';
end;

procedure TInstallMainFrom.FormActivate(Sender: TObject);
begin
  // ���� ����������� ����������� �������, �� ���������� ������
  if ParamCount > 0 then
  begin
    PageControl.ActivePage := tsLog;
    Application.ProcessMessages;
    StartInstall;
  end;
end;

procedure TInstallMainFrom.btnCancelClick(Sender: TObject);
begin
  Close;
end;
                                         
procedure TInstallMainFrom.StartInstall;
begin
  if (PageControl.ActivePage = tsLog) and FParamsInstall then
  begin
    FParamsInstall := False;
    mmLog.Clear;
    GedeminInstall.InterbasePath := eIBPath.Text;
    GedeminInstall.ProgramPath := eGDPath.Text;
{    GedeminInstall.InterbasePath := lblIBPath.Caption;
    GedeminInstall.ProgramPath := lblGDPath.Caption;}
    FPriorEnabled := False;
    FNextEnabled := False;
    GedeminInstall.StartInstall;
    mmFinish.Lines.Add('');
    mmFinish.Lines.Add('������� ��������� �������� ������ � �����: ' +
      GedeminInstall.ProgramPath + '\install.log');
    PageControl.ActivePage := tsFinish;
  end;
end;

procedure TInstallMainFrom.ReadIni;
const
  IniName = 'install.ini';
var
  IniFile: String;
  ResultValue: String;

  function ReadValue(AnKeyName: String): String;
  var
    Size: Integer;
  begin
    Result := '';
    Size := 255;
    SetLength(Result, Size);
    Size := GetPrivateProfileString('OPTIONS', PChar(AnKeyName), nil, @Result[1], Size, PChar(IniFile));
    SetLength(Result, Size);
  end;
begin
  IniFile := ExtractFilePath(Application.ExeName) + IniName;
  if FileExists(IniFile) then
  begin                             
    FTypeRead := True;
    ResultValue := AnsiUpperCase(ReadValue('InstallType'));
    if ResultValue = 'LOCAL' then
    begin
//      rgInstallType.ItemIndex := 0
      FIniType := itLocal;
      GedeminInstall.InstallType := itLocal;
    end else
      if ResultValue = 'MULTI' then
      begin
//        rgInstallType.ItemIndex := 1
        FIniType := itMulti;
        GedeminInstall.InstallType := itMulti;
      end else
        FTypeRead := False;

    FIniModules := [];
    ResultValue := AnsiUpperCase(ReadValue('InstallModules'));
{    cbServer.Checked := Pos('SERVER', ResultValue) > 0;
    cbClient.Checked := Pos('CLIENT', ResultValue) > 0;
    cbReportServer.Checked := Pos('REPORT', ResultValue) > 0;}
    if Pos('SERVER', ResultValue) > 0 then
      FIniModules := cServerFlags;
    if Pos('CLIENT', ResultValue) > 0 then
      FIniModules := FIniModules + cClientFlags;
{    if Pos('REPORT', ResultValue) > 0 then
      FIniModules := FIniModules + cReportFlags; sty}
    FModulesRead := FIniModules <> [];
//    FModulesRead := cbServer.Checked or cbClient.Checked or cbReportServer.Checked;
  end;
end;

procedure TInstallMainFrom.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
  SL: TStrings;
  S: String;
begin
  if PageControl.ActivePage = tsFinish then
  begin
    CanClose := True;
    if cbStart.Checked then
    begin
      for I := 0 to vGedeminListCount - 1 do
      begin
        if Pos(AnsiUpperCase(vMainGedeminFile), AnsiUpperCase(vGedeminList[I].FileName)) > 0 then
        begin
          S := GedeminInstall.GetTargetFileName(vGedeminList[I]);
          Break;
        end;
      end;
      if not FileExists(S) then
      begin
        SL := TStringList.Create;
        try
          GedeminInstall.FindFile(ExtractFileName(S), SL);
          if SL.Count > 0 then
            S := SL[0];
        finally
          SL.Free;
        end;
      end;
      ShellExecute(0, 'open', PChar(S), nil, nil, SW_SHOW);
    end;
  end else
    CanClose := MessageBox(Handle, '�� ������������� ������ �������� ���������?', '��������!',
     MB_YESNO or MB_ICONQUESTION) = IDYES;
end;


// ������ ������� - ����������� �� ��������� ������ �������.

procedure TInstallMainFrom.actBreakUpdate(Sender: TObject);
begin
  PageControl.ActivePage := tsLog;
end;

procedure TInstallMainFrom.actBreakExecute(Sender: TObject);
begin
  GedeminInstall.DoBreak;
end;

procedure TInstallMainFrom.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(PageControl.ActivePage.HelpContext);
end;

{
��� ��������� ��������� ������, ���������� �������
��������� � ���������� �����. ��� ��������� �������
������ ���������� ��������� ��������� ��������� �����
��������� �� ���� �� ����������� (���������� ������
������). ����� ���������� ���������� ����� �� ��
����������, �� ������� ����� �������� � ����������.

��������� ����� - ������������� �� ��������� %s ������
%s, � ����� ���� ������. ��� ��������� �����������
���������� ���������� ���� ������.

���������� ����� - ������������� �� ��������� %s
������, ����������� ����� ��������� ������� �
����������� ��� ������ �������.
}
{
������� ����������� �������� �������. �������� ���� ������������� ����������� ���������.

�������� ����������� �������� �������. ���������� ������������� ����������� ���������. ��� ���������� ���������� ������ ��������, ����������� � ��������� ���������.

���������� ����������� �������� �������. ����� ����������� � ��������� ��������� �� ���������. ����� ������� ��������� �/��� ��������� ����� ���������.
}

end.
