unit gsFDBConvertController_unit;

interface

uses
  gsFDBConvert_unit, Windows, Forms, classes, gsFDBConvertHelper_unit;

type
  TgsFDBConvertController = class(TObject)
  private
    FProcessForm: TForm;
    FFDBConvert: TgsFDBConvert;
    FWasConvertingProcess: Boolean;

    procedure SetProcessForm(const Value: TForm);
  public
    constructor Create(AnOwner: TObject);
    destructor Destroy; override;

    procedure SetupDialogForm;

    procedure LoadLanguage(const ALanguageName: String);

    // ���������� ���������� � ����������� ��������
    procedure ViewPreProcessInformation;
    // ���������� ���������� � ����������� ��������
    procedure ViewAfterProcessInformation;
    // ���������� ���������� � ���������� ��-�� ������ (��� �������������) ��������
    procedure ViewInterruptedProcessInformation(const AErrorMessage: String);
    // ���������� ����������� ��������� ����������� ��
    procedure SetProcessParameters;
    // ��������� ������������ ��������� ���������� �����������
    procedure CheckProcessParams;

    procedure ClearConvertParams;
    // ��������� ������� ����������� ��
    procedure DoConvertDatabase;

    property ProcessForm: TForm read FProcessForm write SetProcessForm;
    property ModelObject: TgsFDBConvert read FFDBConvert write FFDBConvert;
  end;

implementation

uses
  Sysutils,
  stdctrls,
  gsFDBConvertConsoleView_unit,
  gsFDBConvertFormView_unit,
  gs_frmFunctionEdit_unit,
  jclStrings,
  IBDatabase, IB,
  gsFDBConvertLocalization_unit;

type
  TgsConvertThread = class(TThread)
  protected
    FMessage: String;
    FController: TgsFDBConvertController;
    FIsRestoringMetadata: Boolean;

    FgsFunctionEditor: TgsMetadataEditor;
    FMetadataMaxProgress, FMetadataCurrentProgress: Integer;
    FMetadataName, FMetadataParams, FMetadataText, FMetadataError: String;
    FEditMetadataType: TgsMetadataType;

    procedure DoEditMetadata;

    procedure ProcessProcedures;
    procedure ProcessTriggers;
    procedure ProcessViewsAndComputedFields;

    procedure OnMetadataEditError;
    procedure OnInterruptedProcess;
  public
    procedure Execute; override;

    property Controller: TgsFDBConvertController read FController write FController;
  end;

  EgsInterruptConvertProcess = class(Exception);

{ TgsFDBConvertController }

constructor TgsFDBConvertController.Create(AnOwner: TObject);
begin
  if Assigned(AnOwner) and (AnOwner is TgsFDBConvertFormView) then
    FProcessForm := TForm(AnOwner);
  FFDBConvert := TgsFDBConvert.Create;

  FWasConvertingProcess := False;
end;

destructor TgsFDBConvertController.Destroy;
begin
  inherited;
  FreeAndNil(FFDBConvert);
end;

procedure TgsFDBConvertController.SetupDialogForm;
var
  SubstituteList: TStringList;
  StringCounter: Integer;
  CharsetIndex: Integer;
begin
  if Assigned(FProcessForm) then
  begin
    with (FProcessForm as TgsFDBConvertFormView) do
    begin
      // �������� ������ �����������
      TgsConfigFileManager.GetLanguageList(cbLanguage.Items);
      // ������� ������ ���� �� ������ (������� ���� �� ��������� ������ ���� ������ � �����)
      if cbLanguage.Items.Count > 0 then
      begin
        cbLanguage.ItemIndex := 0;
        cbLanguage.OnChange(cbLanguage);
      end;
      // �������� ������ ������� �������
      TgsConfigFileManager.GetCodePageList(cbCharacterSet.Items);
      // ������� ������� �������� �� ���������
      CharsetIndex := cbCharacterSet.Items.IndexOf(DefaultCharacterSet);
      if CharsetIndex > -1 then
        cbCharacterSet.ItemIndex := CharsetIndex
      else
        cbCharacterSet.ItemIndex := cbCharacterSet.Items.Add(DefaultCharacterSet);
      // �������� ������ ���������� �������
      SubstituteList := TStringList.Create;
      try
        TgsConfigFileManager.GetSubstituteFunctionList(SubstituteList);
        for StringCounter := 0 to SubstituteList.Count - 1 do
        begin
          sgSubstituteList.Cells[0, StringCounter] := SubstituteList.Names[StringCounter];
          sgSubstituteList.Cells[1, StringCounter] := SubstituteList.Values[SubstituteList.Names[StringCounter]];
        end;
      finally
        FreeAndNil(SubstituteList);
      end;
      // �������� �������� ��� ����������� �� ���������
      cbPageSize.Text := IntToStr(TgsConfigFileManager.GetDefaultPageSize);
      eBufferSize.Text := IntToStr(TgsConfigFileManager.GetDefaultNumBuffers);
    end;
  end
  else
    raise Exception.Create('Dialog form is not assigned!');
end;

procedure TgsFDBConvertController.LoadLanguage(const ALanguageName: String);
begin
  // �������������� ������ � ����� ������������
  LoadLanguageStrings(ALanguageName);
end;

procedure TgsFDBConvertController.SetProcessParameters;
var
  SubstituteList: TStringList;
  StringCounter: Integer;
  ConnectInfo: TgsConnectionInformation;
  ParameterValue: String;
begin
  if not FWasConvertingProcess then
  begin
    // ���� �� � ������� ����������
    if Assigned(FProcessForm) then
    begin
      with (FProcessForm as TgsFDBConvertFormView) do
      begin
        // ���� ����� ���� �� �������� "2/8 - ����� ����� ���� ������"
        if pcMain.ActivePage = tbs02 then
        begin
          // ������� ��� ��
          FFDBConvert.DatabaseName := eDatabaseName.Text;
          FFDBConvert.DatabaseOriginalName := eDatabaseName.Text;

          // ���������� �������� ������� ��
          FFDBConvert.ServiceProgressRoutine := FormServiceProgressRoutine;
          // ���������� ����������� ��
          FFDBConvert.CopyProgressRoutine := FormCopyProgressRoutine;
          // ���������� ��������������� ����������
          FFDBConvert.MetadataProgressRoutine := FormMetadataProgressRoutine;
        end
        else
        begin
          // ����� ����� ��� ���������� ����������
          // ���� � ����� ��
          FFDBConvert.DatabaseCopyName := eTempDatabaseName.Text;
          // ���� � ������ ��
          FFDBConvert.DatabaseBackupName := eBackupName.Text;

          ConnectInfo.PageSize := StrToInt(cbPageSize.Text);
          ConnectInfo.NumBuffers := StrToInt(eBufferSize.Text);
          ConnectInfo.CharacterSet := Trim(cbCharacterSet.Text);
          FFDBConvert.ConnectionInformation := ConnectInfo;

          // �������� ��������� ���������� �������
          SubstituteList := TStringList.Create;
          try
            for StringCounter := 0 to sgSubstituteList.RowCount - 1 do
            begin
              if (sgSubstituteList.Cells[0, StringCounter] <> '')
                 and (sgSubstituteList.Cells[1, StringCounter] <> '') then
                SubstituteList.Add(sgSubstituteList.Cells[0, StringCounter] + '=' + sgSubstituteList.Cells[1, StringCounter]);
            end;
            // ��������� ������ � �����
            TgsConfigFileManager.SaveSubstituteFunctionList(SubstituteList);
          finally
            FreeAndNil(SubstituteList);
          end;
        end;
      end;
    end
    else
    begin
      // ��������� ���� � ��� ���� ������ � ������������ (���� �� �������� � ����������)
      ParameterValue := GetConsoleParamValue('DB');
      while ParameterValue = '' do
      begin
        ParameterValue := Trim(GetInputString(GetLocalizedString(lsEnterDatabasePath)));
        ParameterValue := StringReplace(ParameterValue, '"', '', [rfReplaceAll]);
        if StrUpper(StrLeft(ParameterValue, 1)) = 'Q' then
          Halt(1);
      end;
      FFDBConvert.DatabaseName := ParameterValue;
      FFDBConvert.DatabaseOriginalName := ParameterValue;

      // ������� �������� ����� ��
      ParameterValue := GetConsoleParamValue('COPY');
      if ParameterValue = '' then
        ParameterValue := TgsFileSystemHelper.GetDefaultDatabaseCopyName(FFDBConvert.DatabaseName);
      FFDBConvert.DatabaseCopyName := ParameterValue;

      // ������� �������� ������ ��
      ParameterValue := GetConsoleParamValue('BACKUP');
      if ParameterValue = '' then
        ParameterValue := TgsFileSystemHelper.GetDefaultBackupName(FFDBConvert.DatabaseName);
      FFDBConvert.DatabaseBackupName := ParameterValue;

      // ��� ����������� �� ������� ��������� ����������� �� ��� (���� �� �������� ������),
      //  ��� ����������� ������ ������� ��������� �� ���������
      if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseName) then
      begin
        FFDBConvert.ServerType := CONVERT_SERVER_VERSION;
        FFDBConvert.Connect;
        try
          // ������� ������ ��������
          ParameterValue := GetConsoleParamValue('PAGE');
          if ParameterValue = '' then
            ConnectInfo.PageSize := FFDBConvert.DatabaseInfo.PageSize
          else
            ConnectInfo.PageSize := StrToInt(ParameterValue);

          // ������� ���-�� �������
          ParameterValue := GetConsoleParamValue('BUFF');
          if ParameterValue = '' then
            ConnectInfo.NumBuffers := FFDBConvert.DatabaseInfo.NumBuffers
          else
            ConnectInfo.NumBuffers := StrToInt(ParameterValue);

          // ���������
          ParameterValue := GetConsoleParamValue('CHARSET');
          if ParameterValue = '' then
            ConnectInfo.CharacterSet := FFDBConvert.GetDatabaseCharacterSet
          else
            ConnectInfo.CharacterSet := ParameterValue;
        finally
          FFDBConvert.Disconnect;
        end;
      end
      else
      begin
        // ������� ������ ��������
        ParameterValue := GetConsoleParamValue('PAGE');
        if ParameterValue = '' then
          ConnectInfo.PageSize := DefaultPageSize
        else
          ConnectInfo.PageSize := StrToInt(ParameterValue);

        // ������� ���-�� �������
        ParameterValue := GetConsoleParamValue('BUFF');
        if ParameterValue = '' then
          ConnectInfo.NumBuffers := DefaultNumBuffers
        else
          ConnectInfo.NumBuffers := StrToInt(ParameterValue);

        // ���������
        ParameterValue := GetConsoleParamValue('CHARSET');
        if ParameterValue = '' then
          ConnectInfo.CharacterSet := DefaultCharacterSet
        else
          ConnectInfo.CharacterSet := ParameterValue;
      end;

      FFDBConvert.ConnectionInformation := ConnectInfo;

      // ���������� �������� ������� ��
      FFDBConvert.ServiceProgressRoutine := ConsoleServiceProgressRoutine;
      // ���������� ����������� ��
      FFDBConvert.CopyProgressRoutine := ConsoleCopyProgressRoutine;
      // ���������� ��������������� ����������
      FFDBConvert.MetadataProgressRoutine := ConsoleMetadataProgressRoutine;
    end;
  end;
end;

procedure TgsFDBConvertController.ViewPreProcessInformation;
var
  CharsetIndex: Integer;
  CurrentCharset: String;
begin
  if not FWasConvertingProcess then
  begin
    // ����������� � �� � ������� FB 2.5 � ������� ��������� ���������� (���� ��� �������� �� �����)
    if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseName) then
    begin
      FFDBConvert.ServerType := CONVERT_SERVER_VERSION;
      FFDBConvert.Connect;
    end;

    try
      // ���� �� � ������� ����������
      if Assigned(FProcessForm) then
      begin
        with FProcessForm as TgsFDBConvertFormView do
        begin
          if pcMain.ActivePage = tbs02 then
          begin
            eOriginalDatabase.Text := FFDBConvert.DatabaseName;
            // ���� ������� �� �����
            if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseName) then
            begin
              eOriginalDBVersion.Text := GetTextDBVersion(FFDBConvert.GetDatabaseVersion);
              eOriginalServerVersion.Text := GetTextServerVersion(GetServerVersionByDBVersion(FFDBConvert.GetDatabaseVersion));
            end
            else
            begin
              eOriginalDBVersion.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);
              eOriginalServerVersion.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);
            end;

            eNewServerVersion.Text := GetTextServerVersion(CONVERT_SERVER_VERSION);
            eTempDatabaseName.Text := TgsFileSystemHelper.GetDefaultDatabaseCopyName(FFDBConvert.DatabaseName);

            // ���� ������� �� �����
            if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseName) then
            begin
              eBackupName.Text := TgsFileSystemHelper.GetDefaultBackupName(FFDBConvert.DatabaseName);
              actBrowseBackupFile.Enabled := True;
              cbPageSize.Text := IntToStr(FFDBConvert.DatabaseInfo.PageSize);
              eBufferSize.Text := IntToStr(FFDBConvert.DatabaseInfo.NumBuffers);
              // ������� ��������� ��
              CurrentCharset := FFDBConvert.GetDatabaseCharacterSet;
              if CurrentCharset <> '' then
              begin
                CharsetIndex := cbCharacterSet.Items.IndexOf(CurrentCharset);
                if CharsetIndex > -1 then
                  cbCharacterSet.ItemIndex := CharsetIndex
                else
                  cbCharacterSet.ItemIndex := cbCharacterSet.Items.Add(CurrentCharset);
              end;
            end
            else
            begin
              eBackupName.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);
              eBackupName.ReadOnly := True;
              actBrowseBackupFile.Enabled := False;

              cbPageSize.Text := IntToStr(DefaultPageSize);
              eBufferSize.Text := IntToStr(DefaultNumBuffers);
            end;
          end;

          // ������� ���� ����� � ����
          mProcessInformation.Clear;
          mProcessInformation.Lines.Add(lblOriginalDatabase.Caption + ' ' + eOriginalDatabase.Text);
          mProcessInformation.Lines.Add(lblOriginalDBVersion.Caption + ' ' + eOriginalDBVersion.Text);
          mProcessInformation.Lines.Add(lblOriginalServerVersion.Caption + ' ' + eOriginalServerVersion.Text);
          mProcessInformation.Lines.Add(lblNewServerVersion.Caption + ' ' + eNewServerVersion.Text);

          mProcessInformation.Lines.Add(lblBackupName.Caption + ' ' + eBackupName.Text);
          mProcessInformation.Lines.Add(lblTempDatabaseName.Caption + ' ' + eTempDatabaseName.Text);
          mProcessInformation.Lines.Add(lblPageSize.Caption + ' ' + cbPageSize.Text + ' ' + lblPageSize_02.Caption);
          mProcessInformation.Lines.Add(lblBufferSize.Caption + ' ' + eBufferSize.Text + ' ' + lblBufferSize_02.Caption);
          mProcessInformation.Lines.Add(lblCharacterSet.Caption + ' ' + cbCharacterSet.Text);
        end;
      end
      else
      begin
        // ���� ������� �� �����
        WriteToConsoleLn(GetLocalizedString(lsDatabasePreprocessInformation));
        if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseName) then
        begin
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalDatabase),
            FFDBConvert.DatabaseName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalDBVersion),
            GetTextDBVersion(FFDBConvert.GetDatabaseVersion)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalServerVersion),
            GetTextServerVersion(GetServerVersionByDBVersion(FFDBConvert.GetDatabaseVersion))]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsNewServerVersion),
            GetTextServerVersion(CONVERT_SERVER_VERSION)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsBackupName),
            TgsFileSystemHelper.GetDefaultBackupName(FFDBConvert.DatabaseName)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsTempDatabaseName),
            TgsFileSystemHelper.GetDefaultDatabaseCopyName(FFDBConvert.DatabaseName)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsPageSize),
            FFDBConvert.DatabaseInfo.PageSize, GetLocalizedString(lsPageSize_02)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsBufferSize),
            FFDBConvert.DatabaseInfo.NumBuffers, GetLocalizedString(lsBufferSize_02)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsCharacterSet),
            FFDBConvert.GetDatabaseCharacterSet]));
        end
        else
        begin
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalBackup),
            FFDBConvert.DatabaseName]));
          WriteToConsoleLn(Format('  %0:s < %1:s >', [GetLocalizedString(lsOriginalServerVersion),
            GetLocalizedString(lsUnknownParameterValue)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsNewServerVersion),
            GetTextServerVersion(CONVERT_SERVER_VERSION)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsResultDatabaseName),
            TgsFileSystemHelper.GetDefaultDatabaseCopyName(FFDBConvert.DatabaseName)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsPageSize),
            FFDBConvert.DatabaseInfo.PageSize, GetLocalizedString(lsPageSize_02)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsBufferSize),
            FFDBConvert.DatabaseInfo.NumBuffers, GetLocalizedString(lsBufferSize_02)]));
          WriteToConsoleLn(Format('  %0:s < %1:s >', [GetLocalizedString(lsCharacterSet),
            GetLocalizedString(lsUnknownParameterValue)]));
        end;
      end;
    finally
      if FFDBConvert.Connected then
        FFDBConvert.Disconnect;
    end;
  end;  
end;

procedure TgsFDBConvertController.ViewAfterProcessInformation;
begin
  // ���� �� � ������� ����������
  if Assigned(FProcessForm) then
  begin
    with FProcessForm as TgsFDBConvertFormView do
    begin
      mAfterProcessInformation.Clear;
      mAfterProcessInformation.Lines.Add(GetLocalizedString(lsProcessSuccessfullEnd));
      if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseOriginalName) then
      begin
        mAfterProcessInformation.Lines.Add(GetLocalizedString(lsOriginalDatabaseNameFinalMessage));
        mAfterProcessInformation.Lines.Add('  ' + FFDBConvert.FinishOriginalDatabaseName);
      end;
      mAfterProcessInformation.Lines.Add(GetLocalizedString(lsNewDatabaseNameFinalMessage));
      mAfterProcessInformation.Lines.Add('  ' + FFDBConvert.FinishConvertedDatabaseName);
      // �������� �� �������� � ������������� ����������� � ����������� ��������
      pcMain.ActivePage := tbs07;
    end;
  end
  else
  begin
    WriteToConsoleLn(GetLocalizedString(lsProcessSuccessfullEnd));
    if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseOriginalName) then
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalDatabaseNameFinalMessage));
      WriteToConsoleLn('  ' + FFDBConvert.FinishOriginalDatabaseName);
    end;
    WriteToConsoleLn(GetLocalizedString(lsNewDatabaseNameFinalMessage));
    WriteToConsoleLn('  ' + FFDBConvert.FinishConvertedDatabaseName);
  end;
end;

procedure TgsFDBConvertController.ViewInterruptedProcessInformation(const AErrorMessage: String);
begin
  // ���� �� � ������� ����������
  if Assigned(FProcessForm) then
  begin
    with FProcessForm as TgsFDBConvertFormView do
    begin
      mAfterProcessInformation.Clear;
      mAfterProcessInformation.Lines.Add(GetLocalizedString(lsProcessInterruptedEnd));
      mAfterProcessInformation.Lines.Add(AErrorMessage);
      if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseOriginalName) then
      begin
        mAfterProcessInformation.Lines.Add(GetLocalizedString(lsOriginalDatabaseNameInterruptMessage));
        mAfterProcessInformation.Lines.Add('  ' + FFDBConvert.DatabaseOriginalName);
      end
      else
      begin
        mAfterProcessInformation.Lines.Add(GetLocalizedString(lsOriginalBackupNameInterruptMessage));
        mAfterProcessInformation.Lines.Add('  ' + FFDBConvert.DatabaseOriginalName);
      end;

      // �������� �� �������� � ������������� ����������� � ���������� ��������
      pcMain.ActivePage := tbs07;
    end;
  end
  else
  begin
    WriteToConsoleLn(GetLocalizedString(lsProcessInterruptedEnd));
    WriteToConsoleLn(AErrorMessage);
    if not TgsFileSystemHelper.IsBackupFile(FFDBConvert.DatabaseOriginalName) then
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalDatabaseNameInterruptMessage));
      WriteToConsoleLn('  ' + FFDBConvert.DatabaseOriginalName);
    end
    else
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalBackupNameInterruptMessage));
      WriteToConsoleLn('  ' + FFDBConvert.DatabaseOriginalName);
    end;
  end;
end;

procedure TgsFDBConvertController.SetProcessForm(const Value: TForm);
begin
  if Value is TgsFDBConvertFormView then
    FProcessForm := Value
  else
    raise Exception.Create(Format('TgsFDBConvertController.SetProcessForm:'#13#10 +
      '  Unknown form type, want %0:s, get %1:s', [TgsFDBConvertFormView.Classname, Value.Classname]));
end;

procedure TgsFDBConvertController.DoConvertDatabase;
var
  InputString: String;
begin
  // ���� ������ ��������� �� �������
  if not Assigned(FProcessForm) then
  begin
    InputString := GetInputString(GetLocalizedString(lsStartConvertQuestion) + '(Y/N)?');
    if StrUpper(Trim(InputString)) <> 'Y' then
      Exit;
  end;

  // ���� True ������ ������� ��� ��� ��������,
  //  �� ����� ��������� ��� ����� ���� �� ����� ������� ClearConvertParams
  if not FWasConvertingProcess then
  begin
    // �������� ��� ������� ��� �������
    FWasConvertingProcess := True;

    // �������� ���� ����������� ��� ��������� ����������� �� �������� �������� � ��������
    with TgsConvertThread.Create(True) do
    begin
      Controller := Self;

      FreeOnTerminate := True;
      Priority := tpLower;
      Resume;

      // ���� ������ ��������� �� �������, ������ ����� ����� ���� �� ���������� ����
      if not Assigned(FProcessForm) then
        while not Terminated do
          Sleep(500);
    end;
  end;
end;

procedure TgsFDBConvertController.ClearConvertParams;
begin
  FWasConvertingProcess := False;
end;

procedure TgsFDBConvertController.CheckProcessParams;
var
  ProcessedFileSize: Int64;
begin
  // ���� ����� �� � ����� �� ����� �����
  if ExtractFileDrive(ModelObject.DatabaseCopyName) = ExtractFileDrive(ModelObject.DatabaseBackupName) then
  begin
    // �������� ��������� ����� ��� ����� �� � ������ ��
    ProcessedFileSize := Round(TgsFileSystemHelper.GetFileSize(ModelObject.DatabaseName) * FREE_SPACE_MULTIPLIER);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseCopyName, ProcessedFileSize) > 0 then
      raise Exception.Create(GetLocalizedString(lsNoDiskSpaceForTempFiles) + #13#10 +
        Format(GetLocalizedString(lsWantDiskSpace), [ProcessedFileSize div BYTE_IN_MB]));
  end
  else
  begin
    // �������� ��������� ����� ��� ����� ��
    ProcessedFileSize := TgsFileSystemHelper.GetFileSize(ModelObject.DatabaseName);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseCopyName, ProcessedFileSize) > 0 then
      raise Exception.Create(GetLocalizedString(lsNoDiskSpaceForDBCopy) + #13#10 +
        Format('  %s'#13#10 + GetLocalizedString(lsWantDiskSpace), [ModelObject.DatabaseCopyName, ProcessedFileSize div BYTE_IN_MB]));
    // �������� ��������� ����� ��� ������ ��
    ProcessedFileSize := ProcessedFileSize div 2;
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseBackupName, ProcessedFileSize) > 0 then
      raise Exception.Create(GetLocalizedString(lsNoDiskSpaceForBackup) + #13#10 +
        Format('  %s'#13#10 + GetLocalizedString(lsWantDiskSpace), [ModelObject.DatabaseBackupName, ProcessedFileSize div BYTE_IN_MB]));
  end;
end;

{ TgsConvertThread }

procedure TgsConvertThread.DoEditMetadata;
begin
  Controller.ModelObject.Connect;
  try
    FgsFunctionEditor := TgsMetadataEditor.Create(Controller.ModelObject.Database);
    // �������� ������ ���������� �������
    try
      TgsConfigFileManager.GetSubstituteFunctionList(FgsFunctionEditor.SubstituteFunctionList);
    except
      on E: EgsConfigFileReadError do
      begin
        Controller.ModelObject.ServiceProgressRoutine(E.Message);
        Exit;
      end;
    end;

    try
      try
        if not FIsRestoringMetadata then
        begin
          // ��� ��������\���������������� ����������, ������� �������������� ��������\���������,
          //  � ����� ������ �������������\���. ����
          ProcessProcedures;
          ProcessTriggers;
          ProcessViewsAndComputedFields;
        end
        else
        begin
          // ��� �������������� ���������� ������� ����������� �������������\���. ����,
          //  � ����� �������������� ��������\���������
          ProcessViewsAndComputedFields;
          ProcessProcedures;
          ProcessTriggers;
        end;
      except
        on E: EgsInterruptConvertProcess do
        begin
          raise;
        end;

        on E: Exception do
        begin
          Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsEditingMetadataError)]),
            FMetadataMaxProgress, FMetadataCurrentProgress);
          Controller.ModelObject.MetadataProgressRoutine(E.Message, FMetadataMaxProgress, FMetadataCurrentProgress);
        end;
      end;
    finally
      FreeAndNil(FgsFunctionEditor);
    end;
  finally
    Controller.ModelObject.Disconnect;
  end;
end;

procedure TgsConvertThread.Execute;
begin
  // ��������� ��������� ������������ ������ �����
  if Assigned(Controller.ProcessForm) then
  begin
    // ���� �� � ������� ����������, �� ����������� ������
    Synchronize((Controller.ProcessForm as TgsFDBConvertFormView).DisableControls);
    Controller.ModelObject.ServiceProgressRoutine := FormServiceProgressRoutine;
    Controller.ModelObject.MetadataProgressRoutine := FormMetadataProgressRoutine;
    Controller.ModelObject.CopyProgressRoutine := FormCopyProgressRoutine;
  end
  else
  begin
    Controller.ModelObject.ServiceProgressRoutine := ConsoleServiceProgressRoutine;
    Controller.ModelObject.MetadataProgressRoutine := ConsoleMetadataProgressRoutine;
    Controller.ModelObject.CopyProgressRoutine := ConsoleCopyProgressRoutine;
  end;

  try
    try
      // ���� ������� ����� - ���������� ��� �� ��������� ����
      if TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseName) then
      begin
        // ������� ������������ �� ����������� ��������� ������
        try
          Controller.ModelObject.ServiceProgressRoutine(Format('%s %s',
            [GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svYaffil)]));
          Controller.ModelObject.ServerType := svYaffil;
          Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
        except
          try
            Controller.ModelObject.ServiceProgressRoutine(Format('%s %s',
              [GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svFirebird_20)]));
            Controller.ModelObject.ServerType := svFirebird_20;
            Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
          except
            try
              Controller.ModelObject.ServiceProgressRoutine(Format('%s %s',
                [GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svFirebird_25)]));
              Controller.ModelObject.ServerType := svFirebird_25;
              Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
            except
              on E: Exception do
              begin
                // TODO: ���������� �������� ������������� �������������� ������
                raise Exception.Create(E.Message);
              end;
            end;
          end;
        end;
        // ������� ����� ��� ��� ������ ��� ����������� ��������� backup-restore
        Controller.ModelObject.DatabaseBackupName := TgsFileSystemHelper.GetDefaultBackupName(Controller.ModelObject.DatabaseCopyName);
      end
      else
      begin
        // ����� ����� ���� � �������� �� ��������� ����
        Controller.ModelObject.CopyDatabaseFile(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
      end;

      // ����� ����� �������� � ������ ��
      Controller.ModelObject.DatabaseName := Controller.ModelObject.DatabaseCopyName;

      // ������� ������ ������� ������������ ��
      Controller.ModelObject.ServerType := CONVERT_SERVER_VERSION;
      Controller.ModelObject.Connect;
      try
        Controller.ModelObject.ServerType := GetServerVersionByDBVersion(Controller.ModelObject.GetDatabaseVersion);
        // �������� ������ ������������� �������, ����� �������������� � ModelObject.RestoreDatabase
        Controller.ModelObject.OriginalServerType := Controller.ModelObject.ServerType;
      finally
        Controller.ModelObject.Disconnect;
      end;

      // �������� ����������� ��
      Controller.ModelObject.CheckDatabaseIntegrity(Controller.ModelObject.DatabaseName);

      // �������� ��������� ������� ��� ����������
      Controller.ModelObject.Connect;
      try
        Controller.ModelObject.CreateConvertHelpMetadata;
      finally
        Controller.ModelObject.Disconnect;
      end;

      // ������������ ����������
      FIsRestoringMetadata := False;
      Self.DoEditMetadata;

      // ����� ����� �������� � ����� ��������
      Controller.ModelObject.ServerType := CONVERT_SERVER_VERSION;

      // �����
      Controller.ModelObject.BackupDatabase(Controller.ModelObject.DatabaseName,
        Controller.ModelObject.DatabaseBackupName);

      // ������
      Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseBackupName,
        Controller.ModelObject.DatabaseName);

      FIsRestoringMetadata := True;
      Self.DoEditMetadata;

      // ������ ��������� ������� ��� ����������
      Controller.ModelObject.Connect;
      try
        Controller.ModelObject.DestroyConvertHelpMetadata;
      finally
        Controller.ModelObject.Disconnect;
      end;

      // ���� ������� �� �����
      if not TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseOriginalName) then
      begin
        try
          // ����������� ������ �� � *.BAK
          Controller.ModelObject.FinishOriginalDatabaseName :=
            TgsFileSystemHelper.DoRenameFile(Controller.ModelObject.DatabaseOriginalName,
              TgsFileSystemHelper.ChangeExtention(Controller.ModelObject.DatabaseOriginalName, OLD_DATABASE_EXTENSION));
          // ����������� ����� �� � ������
          Controller.ModelObject.FinishConvertedDatabaseName :=
            TgsFileSystemHelper.DoRenameFile(Controller.ModelObject.DatabaseCopyName,
              Controller.ModelObject.DatabaseOriginalName);
        except
          on E: Exception do
            Controller.ModelObject.ServiceProgressRoutine(E.Message);
        end;
      end
      else
      begin
        // ��� ������������ �� (������)
        Controller.ModelObject.FinishOriginalDatabaseName := Controller.ModelObject.DatabaseOriginalName;
        // ��� ���������������� ��
        Controller.ModelObject.FinishConvertedDatabaseName := Controller.ModelObject.DatabaseCopyName;
      end;

      // ��������� ���������� � ����������� ��������
      Synchronize(Controller.ViewAfterProcessInformation);
    except
      on E: Exception do
      begin
        Controller.ModelObject.ServiceProgressRoutine(E.Message);
        // ��������� ���������� � ���������� ��������
        FMessage := E.Message;
        Synchronize(OnInterruptedProcess);
      end;
    end;
  finally
    // ���������� �� ��
    Controller.ModelObject.Disconnect;
    // ������ ��������� �����
    if not TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseOriginalName) then
      TgsFileSystemHelper.DoDeleteFile(Controller.ModelObject.DatabaseCopyName);
    TgsFileSystemHelper.DoDeleteFile(Controller.ModelObject.DatabaseBackupName);

    // ���� �� � ������� ����������, �� ������������ ������
    if Assigned(Controller.ProcessForm) then
      Synchronize((Controller.ProcessForm as TgsFDBConvertFormView).EnableControls);

    // ��� ������ �� �������, ����� ������������ �� Terminated,
    //  ������� ����� ��������� ���������� ��������� ��� � True
    Terminate;
  end;
end;

procedure TgsConvertThread.OnMetadataEditError;
var
  NewFunctionText, NewParamText: String;
  DialogResult: TModalResult;
begin
  // ���� �������� � ������� �����������, �� ����� ������������ ��������� �������
  if Assigned(Controller.ProcessForm) then
  begin
    try
      with TfrmFunctionEdit.Create(Controller.ProcessForm) do
      begin
        case FEditMetadataType of
          // ��������� ������ ��� �������������� �������� ���������
          mtProcedure:
          begin
            // ������� ������ �������������� ��� �������� ���������
            DialogResult := ShowForProcedure(FMetadataName, FMetadataParams, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                NewParamText := SynEditParamText;
                // �������� ���������� ���������
                FgsFunctionEditor.SetProcedureText(FMetadataName, NewFunctionText, NewParamText);
                // ������������ ��������
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsProcedureModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create(GetLocalizedString(lsProcessInterruptedEnd));
              end;
            else
              // ������������ ��������
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsProcedureSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;

          // ��������� ������ ��� �������������� ��������
          mtTrigger:
          begin
            // ������� ������ �������������� ��� ��������
            DialogResult := ShowForTrigger(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // �������� ���������� �������
                FgsFunctionEditor.SetTriggerText(FMetadataName, NewFunctionText);
                // ������������ ��������
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsTriggerModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create(GetLocalizedString(lsProcessInterruptedEnd));
              end;
            else
              // ������������ ��������
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsTriggerSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;

          // ��������� ������ ��� �������������� �������������
          mtView:
          begin
            // ������� ������ �������������� ��� ��������
            DialogResult := ShowForView(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // �������� ���������� �������
                FgsFunctionEditor.SetViewText(FMetadataName, NewFunctionText);
                // ������������ ��������
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsViewModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create(GetLocalizedString(lsProcessInterruptedEnd));
              end;
            else
              // ������������ ��������
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsViewSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;

          // ��������� ������ ��� �������������� ������������ ����
          mtComputedField:
          begin

          end;
        end;
      end;
    except
      // ��� �������������� ����� �������� ������ - ����� ��������� ������ ��������������
      on E: EIBInterbaseError do
      begin
        FMetadataText := NewFunctionText;
        FMetadataParams := NewParamText;
        FMetadataError := E.Message;
        Synchronize(OnMetadataEditError);
      end;
    end;
  end
  else
  begin
    case FEditMetadataType of
      mtProcedure:
        WriteToConsoleLn(Format('%s %s. %s', [GetLocalizedString(lsProcedureError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]));
      mtTrigger:
        WriteToConsoleLn(Format('%s %s. %s', [GetLocalizedString(lsTriggerError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]));
      mtView:
        WriteToConsoleLn(Format('%s %s. %s', [GetLocalizedString(lsViewError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]));
    end;
  end;
end;

procedure TgsConvertThread.ProcessProcedures;
var
  FunctionList: TStringList;
  FunctionText: String;
  MetadataCounter: Integer;
begin
  FunctionList := TStringList.Create;
  try
    // ������ ��� ���� �������������� �������� ��������
    FEditMetadataType := mtProcedure;
    // ��������������\�������������� ���������
    FgsFunctionEditor.GetProcedureList(FunctionList);
    // ������������ ��������
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;
    if not FIsRestoringMetadata then
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcedureProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress)
    else
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcedureProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);

    // ������� �� ������ ��������
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // ������������ ��������
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // ��������������\�������������� ���� ��������� FunctionList[MetadataCounter]
        FunctionText := FgsFunctionEditor.GetProcedureText(FunctionList[MetadataCounter]);
        // � ����������� �� �������������� ����� ����� ��������������, ��� �� ������� �����������
        if not FIsRestoringMetadata then
        begin
          if FgsFunctionEditor.CommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetProcedureText(FunctionList[MetadataCounter], FunctionText);
        end
        else
        begin
          // ������� ������ ������� �� �����
          if FgsFunctionEditor.ReplaceSubstituteUDFFunction(FunctionText) then
            FgsFunctionEditor.SetProcedureText(FunctionList[MetadataCounter], FunctionText);
          // �������������� ���������
          if FgsFunctionEditor.UncommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetProcedureText(FunctionList[MetadataCounter], FunctionText);
        end;
      except
        on E: Exception do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataText := FunctionText;
          FMetadataParams := FgsFunctionEditor.GetProcedureParamText(FunctionList[MetadataCounter]);
          FMetadataError := E.Message;
          Synchronize(OnMetadataEditError);
        end;
      end;
    end;
    // ������������ ��������
    FMetadataMaxProgress := FMetadataCurrentProgress;
    if not FIsRestoringMetadata then
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress)
    else
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
  finally
    FreeAndNil(FunctionList);
  end;
end;

procedure TgsConvertThread.ProcessTriggers;
var
  FunctionList: TStringList;
  FunctionText: String;
  MetadataCounter: Integer;
begin
  FunctionList := TStringList.Create;
  try
    // ������ ��� ���� �������������� ���������
    FEditMetadataType := mtTrigger;
    // ��������������\�������������� ��������
    FgsFunctionEditor.GetTriggerList(FunctionList);
    // ������������ ��������
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;
    if not FIsRestoringMetadata then
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsTriggerProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress)
    else
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsTriggerProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
    // ������� �� ������ ���������
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // ������������ ��������
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // ��������������\�������������� ���� �������� FunctionList[MetadataCounter]
        FunctionText := FgsFunctionEditor.GetTriggerText(FunctionList[MetadataCounter]);
        // � ����������� �� �������������� ����� ����� ��������������, ��� �� ������� �����������
        if not FIsRestoringMetadata then
        begin
          if FgsFunctionEditor.CommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionList[MetadataCounter], FunctionText);
        end
        else
        begin
          // ������� ������ ������� �� �����
          if FgsFunctionEditor.ReplaceSubstituteUDFFunction(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionList[MetadataCounter], FunctionText);
          // �������������� �������
          if FgsFunctionEditor.UncommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionList[MetadataCounter], FunctionText);
        end;
      except
        on E: Exception do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataText := FunctionText;
          FMetadataError := E.Message;
          Synchronize(OnMetadataEditError);
        end;
      end;
    end;
    // ������������ ��������
    FMetadataMaxProgress := FMetadataCurrentProgress;
    if not FIsRestoringMetadata then
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress)
    else
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
  finally
    FreeAndNil(FunctionList);
  end;
end;

procedure TgsConvertThread.ProcessViewsAndComputedFields;
var
  FunctionList: TStringList;
  MetadataText: String;
  MetadataCounter, DelimeterPos: Integer;
  ComputedTableName, ComputedFieldName: String;
begin
  // ���������\����������� ������������� � ����������� ����
  FunctionList := TStringList.Create;
  try
    if not FIsRestoringMetadata then
      FgsFunctionEditor.GetViewAndComputedFieldList(FunctionList)
    else
      FgsFunctionEditor.GetBackupViewAndComputedFieldList(FunctionList);

    // ������������ ��������
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;
    if not FIsRestoringMetadata then
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress)
    else
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);

    // ������� �� ������ ������������� � ����������� �����
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // ������������ ��������
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // ��������� ��� �� ������� ������, ������������� ��� ���. ����
        DelimeterPos := AnsiPos(',', FunctionList[MetadataCounter]);
        if DelimeterPos = 0 then
        begin
          // ������ ��� ���� �������������� �������������
          FEditMetadataType := mtView;
          // ���� ���� ��������� ����������
          if not FIsRestoringMetadata then
          begin
            FgsFunctionEditor.BackupView(FunctionList[MetadataCounter]);
            FgsFunctionEditor.DeleteView(FunctionList[MetadataCounter]);
          end
          else
          begin
            MetadataText := FgsFunctionEditor.GetBackupViewText(FunctionList[MetadataCounter]);
            FgsFunctionEditor.SetViewText(FunctionList[MetadataCounter], MetadataText);
          end;
        end
        else
        begin
          // ������ ��� ���� �������������� ����������� �����
          FEditMetadataType := mtComputedField;
          // ������� ��� ������� � ��� ������������ ����
          ComputedTableName := StrLeft(FunctionList[MetadataCounter], DelimeterPos - 1);
          ComputedFieldName := StrRight(FunctionList[MetadataCounter], StrLength(FunctionList[MetadataCounter]) - DelimeterPos);
          // ���� ���� ��������� ����������
          if not FIsRestoringMetadata then
          begin
            FgsFunctionEditor.BackupComputedField(ComputedTableName, ComputedFieldName);
            FgsFunctionEditor.DeleteComputedField(ComputedTableName, ComputedFieldName);
          end
          else
          begin
            FgsFunctionEditor.RestoreComputedField(ComputedTableName, ComputedFieldName);
          end;
        end;
      except
        on E: Exception do
        begin
          // ������������ ��������
          if not FIsRestoringMetadata then
            Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s %s%s%s',
              [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessStartError), FunctionList[MetadataCounter], #13#10, E.Message]),
              FMetadataMaxProgress, FMetadataCurrentProgress)
          else
            Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s %s%s%s',
              [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessFinishError), FunctionList[MetadataCounter], #13#10, E.Message]),
              FMetadataMaxProgress, FMetadataCurrentProgress)
        end;
      end;
    end;
    // ������������ ��������
    FMetadataMaxProgress := FMetadataCurrentProgress;
    if not FIsRestoringMetadata then
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress)
    else
      Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
  finally
    FreeAndNil(FunctionList);
  end;
end;

procedure TgsConvertThread.OnInterruptedProcess;
begin
  if FMessage <> '' then
    Controller.ViewInterruptedProcessInformation(FMessage);
  FMessage := '';
end;

end.
