unit prp_dlg_PropertySettings_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Registry, gd_directories_const,
  prp_PropertySettings, gd_i_ScriptFactory, Spin, ActnList, StdActns,
  XPBevel;

type
  TdlgPropertySettings = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Button1: TButton;
    Button3: TButton;
    cbAutoSaveChanges: TCheckBox;
    Bevel1: TxpBevel;
    cbShowUserSf: TCheckBox;
    cbShowVBClassSF: TCheckBox;
    cbShowMacrosSF: TCheckBox;
    cbShowReportSf: TCheckBox;
    cbShowMethodSF: TCheckBox;
    cbShowEventSf: TCheckBox;
    Bevel2: TxpBevel;
    cbAutoSaveOnExecute: TCheckBox;
    TabSheet3: TTabSheet;
    Bevel3: TxpBevel;
    cbUseDebugInfo: TCheckBox;
    cbAutoSaveCaretPos: TCheckBox;
    TabSheet4: TTabSheet;
    Label1: TLabel;
    Bevel4: TxpBevel;
    cbOnlySpecEvent: TCheckBox;
    cbfoClass: TComboBox;
    eClassName: TEdit;
    Label2: TLabel;
    cbfoMethod: TComboBox;
    eMethodName: TEdit;
    Label3: TLabel;
    cbfoObject: TComboBox;
    eObjectName: TEdit;
    z: TLabel;
    cbfoEvent: TComboBox;
    eEventName: TEdit;
    cbFullClassName: TCheckBox;
    cbNoticeTreeRefresh: TCheckBox;
    cbOnlyDisabled: TCheckBox;
    TabSheet5: TTabSheet;
    Bevel5: TxpBevel;
    cbStopOnDelphiException: TCheckBox;
    cbStopOnException: TCheckBox;
    cbSaveErrorLog: TCheckBox;
    pnlErrLog: TPanel;
    spErrorLines: TSpinEdit;
    cbLimitLines: TCheckBox;
    Label4: TLabel;
    cbErrorLogFile: TComboBox;
    cbRuntimeSave: TCheckBox;
    cbShowEntrySf: TCheckBox;
    cbRestoreDeskTop: TCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbfoClassChange(Sender: TObject);
    procedure cbfoMethodChange(Sender: TObject);
    procedure cbfoObjectChange(Sender: TObject);
    procedure cbfoEventChange(Sender: TObject);
    procedure cbOnlySpecEventClick(Sender: TObject);
    procedure cbStopOnExceptionClick(Sender: TObject);
    procedure cbLimitLinesClick(Sender: TObject);
    procedure cbSaveErrorLogClick(Sender: TObject);
    procedure cbErrorLogFileExit(Sender: TObject);
    procedure WindowCloseExecute(Sender: TObject);
  private
    FEnabledChildPnlErrLog: array of Boolean;
//    procedure ChangeEnabledChildPnlErrLog(const Enabled: Boolean);
    procedure CheckLogFileName;
  protected
    function CheckChanges: Boolean;
  end;

var
  dlgPropertySettings: TdlgPropertySettings;

implementation

uses
  FileCtrl, JclFileUtils, Masks
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure TdlgPropertySettings.FormDestroy(Sender: TObject);
begin
  FEnabledChildPnlErrLog := nil;
  if ModalResult = mrOk then
    SaveSettings(PropertySettings);
end;

procedure TdlgPropertySettings.FormCreate(Sender: TObject);
begin
  SetLength(FEnabledChildPnlErrLog, pnlErrLog.ControlCount);
  with PropertySettings do
  begin
    cbAutoSaveChanges.Checked := GeneralSet.AutoSaveChanges;
    cbAutoSaveOnExecute.Checked := GeneralSet.AutoSaveOnExecute;
    cbAutoSaveCaretPos.Checked := GeneralSet.AutoSaveCaretPos;
    cbFullClassName.Checked := GeneralSet.FullClassName;
    cbNoticeTreeRefresh.Checked := generalSet.NoticeTreeRefresh;
    cbRestoreDeskTop.Checked := GeneralSet.RestoreDeskTop;
    
    cbStopOnException.Checked := Exceptions.Stop;
    cbStopOnDelphiException.Checked := Exceptions.StopOnInside;
    cbErrorLogFile.Text := Exceptions.FileName;
    cbLimitLines.Checked := Exceptions.LimitLines;
    spErrorLines.Value := Exceptions.LinesCount;
//    ChangeEnabledChildPnlErrLog(False);
    cbSaveErrorLog.Checked := Exceptions.SaveErrorLog;
    if Assigned(ScriptFactory) then
    begin
      ScriptFactory.ExceptionFlags := Exceptions;
      ScriptFactory.Reset;
    end;
    cbShowUserSF.Checked := ViewSet.SFSet.ShowUserSF;
    cbShowVBClassSF.Checked := ViewSet.SFSet.ShowVBClassSF;
    cbShowMacrosSF.Checked := ViewSet.SFSet.ShowMacrosSF;
    cbShowReportSF.Checked := ViewSet.SFSet.ShowReportSF;
    cbShowMethodSF.Checked := ViewSet.SFSet.ShowMethodSF;
    cbShowEventSF.Checked := ViewSet.SFSet.ShowEventSF;
    cbShowEntrySf.Checked := ViewSet.SFSet.ShowEntrySF;
    cbUseDebugInfo.Checked := DebugSet.UseDebugInfo;
    cbRuntimeSave.Checked := DebugSet.RuntimeSave;
    //filter
    cbOnlySpecEvent.Checked := Filter.OnlySpecEvent;
    cbOnlyDisabled.Checked := Filter.OnlyDisabled;
    cbOnlySpecEventClick(nil);
    eClassName.Text := Filter.ClassName;
    eMethodName.Text := Filter.MethodName;
    eObjectName.Text := Filter.ObjectName;
    eEventName.Text := Filter.EventName;
    cbfoClass.ItemIndex := Filter.foClass;
    cbfoMethod.ItemIndex := Filter.foMethod;
    cbfoObject.ItemIndex := Filter.foObject;
    cbfoEvent.ItemIndex := Filter.foEvent;
    cbfoClassChange(cbfoClass);
    cbfoMethodChange(cbfoMethod);
    cbfoObjectChange(cbfoObject);
    cbfoEventChange(cbfoEvent);
  end;
  cbStopOnDelphiException.Enabled := cbStopOnException.Checked;
  spErrorLines.Enabled := cbLimitLines.Checked;
  BuildFileList(ExtractFileDir(Application.ExeName) + '\*.log',
    faAnyFile, cbErrorLogFile.Items);
//  ChangeEnabledChildPnlErrLog(cbSaveErrorLog.Checked);
end;

procedure TdlgPropertySettings.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//  cbErrorLogFile.change
  if (ModalResult = mrOk) then
  begin
    if CheckChanges then
    begin
      with PropertySettings do
      begin
        GeneralSet.AutoSaveChanges := cbAutoSaveChanges.Checked;
        GeneralSet.AutoSaveOnExecute := cbAutoSaveOnExecute.Checked;
        GeneralSet.AutoSaveCaretPos := cbAutoSaveCaretPos.Checked;
        GeneralSet.FullClassName := cbFullClassName.Checked;
        GeneralSet.NoticeTreeRefresh := cbNoticeTreeRefresh.Checked;
        GeneralSet.RestoreDeskTop := cbRestoreDeskTop.Checked;

        Exceptions.Stop := cbStopOnException.Checked;
        Exceptions.StopOnInside := cbStopOnDelphiException.Checked;
        Exceptions.SaveErrorLog := cbSaveErrorLog.Checked;
        Exceptions.FileName := cbErrorLogFile.Text;
        Exceptions.LimitLines := cbLimitLines.Checked;
        Exceptions.LinesCount := spErrorLines.Value;
        if Assigned(ScriptFactory) then
        begin
          ScriptFactory.ExceptionFlags := Exceptions;
        end;
        ViewSet.SFSet.ShowUserSF := cbShowUserSF.Checked;
        ViewSet.SFSet.ShowVBClassSF := cbShowVBClassSF.Checked;
        ViewSet.SFSet.ShowMacrosSF := cbShowMacrosSF.Checked;
        ViewSet.SFSet.ShowReportSF := cbShowReportSF.Checked;
        ViewSet.SFSet.ShowMethodSF := cbShowMethodSF.Checked;
        ViewSet.SFSet.ShowEventSF := cbShowEventSF.Checked;
        ViewSet.SFSet.ShowEntrySF := cbShowEntrySf.Checked;
        DebugSet.UseDebugInfo := cbUseDebugInfo.Checked;
        DebugSet.RuntimeSave := cbRuntimeSave.Checked;
        //filter
        Filter.OnlySpecEvent := cbOnlySpecEvent.Checked;
        Filter.OnlyDisabled := cbOnlyDisabled.Checked;
        Filter.foClass := cbfoClass.ItemIndex;
        Filter.foMethod := cbfoMethod.ItemIndex;
        Filter.foObject := cbfoObject.ItemIndex;
        Filter.foEvent := cbfoEvent.ItemIndex;
        Filter.ClassName := eClassName.Text;
        Filter.MethodName := eMethodName.Text;
        Filter.ObjectName := eObjectName.Text;
        Filter.EventName := eEventName.Text;
      end;
    end else
      Modalresult := mrCancel;
  end;
  CanClose := True;
end;

function TdlgPropertySettings.CheckChanges: Boolean;
begin
  Result := False;
  with PropertySettings do
  begin
    if not Result then
      Result := GeneralSet.RestoreDeskTop <> cbRestoreDeskTop.Checked;
    if not Result then
      Result := GeneralSet.AutoSaveChanges <> cbAutoSaveChanges.Checked;
    if not Result then
      Result := GeneralSet.AutoSaveOnExecute <> cbAutoSaveOnExecute.Checked;
    if not Result then
      Result := GeneralSet.AutoSaveCaretPos <> cbAutoSaveCaretPos.Checked;
    if not Result then
      Result := GeneralSet.FullClassName <> cbFullClassName.Checked;
    if not Result then
      Result := GeneralSet.NoticeTreeRefresh <> cbNoticeTreeRefresh.Checked;
    if not Result then
      Result := ViewSet.SFSet.ShowUserSF <> cbShowUserSF.Checked;
    if not Result then
      Result := ViewSet.SFSet.ShowVBClassSF <> cbShowVBClassSF.Checked;
    if not Result then
      Result := ViewSet.SFSet.ShowMacrosSF <> cbShowMacrosSF.Checked;
    if not Result then
      Result := ViewSet.SFSet.ShowReportSF <> cbShowReportSF.Checked;
    if not Result then
      Result := ViewSet.SFSet.ShowMethodSF <> cbShowMethodSF.Checked;
    if not Result then
      Result := ViewSet.SFSet.ShowEntrySF <> cbShowEntrySF.Checked;
    if not Result then
      Result := ViewSet.SFSet.ShowEventSF <> cbShowEventSF.Checked;
    if not Result then
      Result := DebugSet.UseDebugInfo <> cbUseDebugInfo.Checked;
    if not Result then
      Result := DebugSet.RuntimeSave <> cbRuntimeSave.Checked;
    //filter
    if not Result then
      Result := Filter.OnlySpecEvent <> cbOnlySpecEvent.Checked;
    if not Result then
      Result := Filter.OnlyDisabled <> cbOnlyDisabled.Checked;
    if not Result then
      Result := Filter.OnlySpecEvent <> cbOnlySpecEvent.Checked;
    if not Result then
      Result := Filter.foClass <> cbfoClass.ItemIndex;
    if not Result then
      Result := Filter.foMethod <> cbfoMethod.ItemIndex;
    if not Result then
      Result := Filter.foObject <> cbfoObject.ItemIndex;
    if not Result then
      Result := Filter.foEvent <> cbfoEvent.ItemIndex;
    if not Result then
      Result := Filter.ClassName <> eClassName.Text;
    if not Result then
      Result := Filter.MethodName <> eMethodName.Text;
    if not Result then
      Result := Filter.ObjectName <> eObjectName.Text;
    if not Result then
      Result := Filter.EventName <> eEventName.Text;
    // exception
    if not Result then
      Result := Exceptions.Stop <> cbStopOnException.Checked;
    if not Result then
      Result := Exceptions.StopOnInside <> cbStopOnDelphiException.Checked;
    if not Result then
      Result := Exceptions.SaveErrorLog <> cbSaveErrorLog.Checked;
    if not Result then
    begin
      Result := Exceptions.FileName <> cbErrorLogFile.Text;
      if Result then
        CheckLogFileName;
    end;
    if not Result then
      Result := Exceptions.LimitLines <> cbLimitLines.Checked;
    if not Result then
      Result := Exceptions.LinesCount <> spErrorLines.Value;
  end;
end;

procedure TdlgPropertySettings.cbfoClassChange(Sender: TObject);
begin
  if TComboBox(Sender).ItemIndex = - 1 then
    TComboBox(Sender).ItemIndex := 0;
  eClassName.Enabled := TComboBox(Sender).ItemIndex > 0;
end;

procedure TdlgPropertySettings.cbfoMethodChange(Sender: TObject);
begin
  if TComboBox(Sender).ItemIndex = - 1 then
    TComboBox(Sender).ItemIndex := 0;
  eMethodName.Enabled := TComboBox(Sender).ItemIndex > 0;
end;

procedure TdlgPropertySettings.cbfoObjectChange(Sender: TObject);
begin
  if TComboBox(Sender).ItemIndex = - 1 then
    TComboBox(Sender).ItemIndex := 0;
  eObjectName.Enabled := TComboBox(Sender).ItemIndex > 0;
end;

procedure TdlgPropertySettings.cbfoEventChange(Sender: TObject);
begin
  if TComboBox(Sender).ItemIndex = - 1 then
    TComboBox(Sender).ItemIndex := 0;
  eEventName.Enabled := TComboBox(Sender).ItemIndex > 0;
end;

procedure TdlgPropertySettings.cbOnlySpecEventClick(Sender: TObject);
begin
  cbOnlyDisabled.Enabled := cbOnlySpecEvent.Checked;
  if not cbOnlySpecEvent.Checked then
    cbOnlyDisabled.Checked := False;
end;

procedure TdlgPropertySettings.cbStopOnExceptionClick(Sender: TObject);
begin
  inherited;
  cbStopOnDelphiException.Enabled := cbStopOnException.Checked;
end;

procedure TdlgPropertySettings.cbLimitLinesClick(Sender: TObject);
begin
  inherited;
  spErrorLines.Enabled := cbLimitLines.Checked;
end;

procedure TdlgPropertySettings.cbSaveErrorLogClick(Sender: TObject);

  procedure ChangeEnabledChildPnlErrLog(const Enabled: Boolean);
  var
    i: Integer;
  begin
    pnlErrLog.Enabled := Enabled;
    for i := 0 to pnlErrLog.ControlCount - 1 do
    begin
      if Enabled then
        pnlErrLog.Controls[i].Enabled := FEnabledChildPnlErrLog[i]
      else
        begin
          FEnabledChildPnlErrLog[i] := pnlErrLog.Controls[i].Enabled;
          pnlErrLog.Controls[i].Enabled := Enabled;
        end;
    end;
  end;
begin
  inherited;
  ChangeEnabledChildPnlErrLog(cbSaveErrorLog.Checked);
end;

procedure TdlgPropertySettings.cbErrorLogFileExit(Sender: TObject);
begin
  CheckLogFileName;
end;

procedure TdlgPropertySettings.CheckLogFileName;
var
  LFileName: String;
  FullFileName: String;
begin
  LFileName := Trim(ExtractFileName(cbErrorLogFile.Text));
  if not MatchesMask(LFileName, '*.log') then
    LFileName := LFileName + '.log';
  FullFileName := ExtractFileDir(Application.ExeName) + '\' + LFileName;
  if FileExists(FullFileName) then
    cbErrorLogFile.Text := LFileName
  else
    begin
      if FileCreate(FullFileName) <> -1 then
      begin
        DeleteFile(FullFileName);
        cbErrorLogFile.Text := LFileName;
      end else
        begin
          MessageBox(0, PChar('Не возможно создать файл с именем ' +
            cbErrorLogFile.Text + #13#10 + 'Файлу дано стандартное имя ErrScript.log'),
            PChar('Ошибка сохранения свойств'), MB_OK or MB_ICONERROR or MB_TASKMODAL);
          cbErrorLogFile.Text := 'ErrScript.log';
        end;
    end;
end;

procedure TdlgPropertySettings.WindowCloseExecute(Sender: TObject);
begin
  ModalResult := mrCancel
end;

end.
