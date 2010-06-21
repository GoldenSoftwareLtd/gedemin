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
    FInConvertingProcess: Boolean;

    procedure SetProcessForm(const Value: TForm);

    procedure ProcessSubstituteList;
    // ���������, �������� �� ���� ��� ������.  ���� ������ �������� �� ����������, ��������� ���������
    procedure CheckDiskWriteAbility(const InFormMode: Boolean);
    // �������� �� ������� � �������� ����� ��������� � ����������
    procedure CheckProcessPathes;
  public
    constructor Create(AnOwner: TObject);
    destructor Destroy; override;

    procedure SetupDialogForm;

    procedure LoadLanguage(const ALanguageName: String);

    procedure SetCurrentStepMessage(const AStepMessage: String);

    // ���������� ���������� � ����������� ��������
    procedure ViewPreProcessInformation;
    // ���������� ���������� � ����������� ��������
    procedure ViewAfterProcessInformation;
    // ���������� ���������� � ���������� ��-�� ������ (��� �������������) ��������
    procedure ViewInterruptedProcessInformation(const AErrorMessage: String);
    // ���������� ����������� ��������� ����������� ��
    procedure SetProcessParameters;
    // ��������� ������������ ��������� ���������� �����������
    procedure CheckProcessParams(const RespondToForm: Boolean = False);

    procedure ClearConvertParams;
    // ��������� ������� ����������� ��
    procedure DoConvertDatabase;

    property ProcessForm: TForm read FProcessForm write SetProcessForm;
    property ModelObject: TgsFDBConvert read FFDBConvert write FFDBConvert;

    property InConvertingProcess: Boolean read FInConvertingProcess write FInConvertingProcess;
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
  gsFDBConvertLocalization_unit,
  Graphics;

type
  TgsConvertThread = class(TThread)
  protected
    FMessage: String;
    FController: TgsFDBConvertController;
    FIsRestoringMetadata: Boolean;

    FgsFunctionEditor: TgsMetadataEditor;
    FMetadataMaxProgress, FMetadataCurrentProgress: Integer;
    FMetadataName, FMetadataText, FMetadataError: String;
    FEditMetadataType: TgsMetadataType;

    procedure SynchronizeMethod(Method: TThreadMethod);

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
  
  EgsNeedFreeSpace = class(Exception);
  EgsUnknownServerVersion = class(Exception);

{ TgsFDBConvertController }

constructor TgsFDBConvertController.Create(AnOwner: TObject);
begin
  // ���������, �������� �� ���� ��� ������
  //  ���� ������ �������� �� ����������, ��������� ���������
  CheckDiskWriteAbility(Assigned(AnOwner));

  FFDBConvert := TgsFDBConvert.Create;

  if Assigned(AnOwner) and (AnOwner is TgsFDBConvertFormView) then
  begin
    FProcessForm := TForm(AnOwner);
    // ��������� ��������� ������������ ������ �����
    ModelObject.ServiceProgressRoutine := FormServiceProgressRoutine;
    ModelObject.MetadataProgressRoutine := FormMetadataProgressRoutine;
    ModelObject.CopyProgressRoutine := FormCopyProgressRoutine;
  end
  else
  begin
    // ��������� ��������� ������������ ������ �����
    ModelObject.ServiceProgressRoutine := ConsoleServiceProgressRoutine;
    ModelObject.MetadataProgressRoutine := ConsoleMetadataProgressRoutine;
    ModelObject.CopyProgressRoutine := ConsoleCopyProgressRoutine;
  end;

  FWasConvertingProcess := False;
end;

destructor TgsFDBConvertController.Destroy;
begin
  inherited;
  FreeAndNil(FFDBConvert);

  TgsFileSystemHelper.DeleteTempFiles;
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
      // ���� �� ������ ��������� ���� �� ��������� ��������� ����������, ��
      // ������� ������ ���� �� ������ (������� ���� �� ��������� ������ ���� ������ � �����)
      if (cbLanguage.Items.Count > 0) then
      begin
        if LanguageLoadedOnStartup <> '' then
        begin
          cbLanguage.ItemIndex := cbLanguage.Items.IndexOf(LanguageLoadedOnStartup);
        end
        else
        begin
          cbLanguage.ItemIndex := 0;
          cbLanguage.OnChange(cbLanguage);
        end;
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

procedure TgsFDBConvertController.ProcessSubstituteList;
var
  SubstituteList: TStringList;
  StringCounter: Integer;
begin
  with (FProcessForm as TgsFDBConvertFormView) do
  begin
    // �������� ��������� ���������� �������
    SubstituteList := TStringList.Create;
    try
      for StringCounter := 0 to sgSubstituteList.RowCount - 1 do
      begin
        // ��������� ������ ��������� ��������� ������
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

procedure TgsFDBConvertController.SetProcessParameters;
var
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
          ModelObject.DatabaseName := eDatabaseName.Text;
          ModelObject.DatabaseOriginalName := eDatabaseName.Text;

          if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
          begin
            // ��� ������������ �� (������)
            ModelObject.FinishOriginalDatabaseName :=
              TgsFileSystemHelper.ChangeExtention(ModelObject.DatabaseOriginalName, OLD_DATABASE_EXTENSION);
            // ��� ���������������� ��
            ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseOriginalName;
          end
          else
          begin
            // ��� ������������ �� (������)
            ModelObject.FinishOriginalDatabaseName := ModelObject.DatabaseOriginalName;
            // ��� ���������������� ��
            ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseCopyName;
          end;

          // ���� � ����� ��
          ModelObject.DatabaseCopyName := TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName);
          // ���� � ������ ��
          ModelObject.DatabaseBackupName := TgsFileSystemHelper.GetDefaultBackupName(ModelObject.DatabaseName);;

          // ���������� �������� ������� ��
          ModelObject.ServiceProgressRoutine := FormServiceProgressRoutine;
          // ���������� ����������� ��
          ModelObject.CopyProgressRoutine := FormCopyProgressRoutine;
          // ���������� ��������������� ����������
          ModelObject.MetadataProgressRoutine := FormMetadataProgressRoutine;
        end
        else
        begin
          // ����� ����� ��� ���������� ����������
          // ���� � ����� ��
          ModelObject.DatabaseCopyName := eTempDatabaseName.Text;
          // ���� � ������ ��
          ModelObject.DatabaseBackupName := eBackupName.Text;

          if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
          begin
            // ����������� ��������� ������� �������� ��� FB 2.5 �������� 4096
            if StrToInt(cbPageSize.Text) >= MINIMAL_PAGE_SIZE then
              ConnectInfo.PageSize := StrToInt(cbPageSize.Text)
            else
              ConnectInfo.PageSize := MINIMAL_PAGE_SIZE;
            ConnectInfo.NumBuffers := StrToInt(eBufferSize.Text);
            ConnectInfo.CharacterSet := Trim(cbCharacterSet.Text);
          end
          else
          begin
            ConnectInfo.PageSize := -1;
            ConnectInfo.NumBuffers := -1;
            ConnectInfo.CharacterSet := '';
          end;
          ModelObject.ConnectionInformation := ConnectInfo;
        end;

        // ���������� ��������� ���������� �������
        if pcMain.ActivePage = tbs04 then
          ProcessSubstituteList;
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
      ModelObject.DatabaseName := ParameterValue;
      ModelObject.DatabaseOriginalName := ParameterValue;

      // ������� �������� ����� ��
      ParameterValue := GetConsoleParamValue('COPY');
      if ParameterValue = '' then
        ParameterValue := TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName);
      ModelObject.DatabaseCopyName := ParameterValue;

      // ������� �������� ������ ��
      ParameterValue := GetConsoleParamValue('BACKUP');
      if ParameterValue = '' then
        ParameterValue := TgsFileSystemHelper.GetDefaultBackupName(ModelObject.DatabaseName);
      ModelObject.DatabaseBackupName := ParameterValue;

      // ��� ����������� �� ������� ��������� ����������� �� ��� (���� �� �������� ������),
      //  ��� ����������� ������ ������� ��������� �� ���������
      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
      begin
        // ��� ������������ �� (������)
        ModelObject.FinishOriginalDatabaseName :=
          TgsFileSystemHelper.ChangeExtention(ModelObject.DatabaseOriginalName, OLD_DATABASE_EXTENSION);
        // ��� ���������������� ��
        ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseOriginalName;

        ModelObject.ServerType := CONVERT_SERVER_VERSION;
        ModelObject.Connect;
        try
          // ������� ������ ��������
          ParameterValue := GetConsoleParamValue('PAGE');
          if ParameterValue = '' then
            ConnectInfo.PageSize := ModelObject.DatabaseInfo.PageSize
          else
            ConnectInfo.PageSize := StrToInt(ParameterValue);
          // ����������� ��������� ������� �������� ��� FB 2.5 �������� 4096
          if ConnectInfo.PageSize < MINIMAL_PAGE_SIZE then
            ConnectInfo.PageSize := MINIMAL_PAGE_SIZE;

          // ������� ���-�� �������
          ParameterValue := GetConsoleParamValue('BUFF');
          if ParameterValue = '' then
            ConnectInfo.NumBuffers := ModelObject.DatabaseInfo.NumBuffers
          else
            ConnectInfo.NumBuffers := StrToInt(ParameterValue);

          // ���������
          ParameterValue := GetConsoleParamValue('CHARSET');
          if ParameterValue = '' then
            ConnectInfo.CharacterSet := ModelObject.GetDatabaseCharacterSet
          else
            ConnectInfo.CharacterSet := ParameterValue;
        finally
          ModelObject.Disconnect;
        end;
      end
      else
      begin
        // ��� ������������ �� (������)
        ModelObject.FinishOriginalDatabaseName := ModelObject.DatabaseOriginalName;
        // ��� ���������������� ��
        ModelObject.FinishConvertedDatabaseName := ModelObject.DatabaseCopyName;

        // ������� ������ ��������
        ParameterValue := GetConsoleParamValue('PAGE');
        if ParameterValue = '' then
          ConnectInfo.PageSize := DefaultPageSize
        else
          ConnectInfo.PageSize := StrToInt(ParameterValue);
        // ����������� ��������� ������� �������� ��� FB 2.5 �������� 4096
        if ConnectInfo.PageSize < MINIMAL_PAGE_SIZE then
          ConnectInfo.PageSize := MINIMAL_PAGE_SIZE;

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

      ModelObject.ConnectionInformation := ConnectInfo;

      // ���������� �������� ������� ��
      ModelObject.ServiceProgressRoutine := ConsoleServiceProgressRoutine;
      // ���������� ����������� ��
      ModelObject.CopyProgressRoutine := ConsoleCopyProgressRoutine;
      // ���������� ��������������� ����������
      ModelObject.MetadataProgressRoutine := ConsoleMetadataProgressRoutine;
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
    if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
    begin
      ModelObject.ServerType := CONVERT_SERVER_VERSION;
      ModelObject.Connect;
      // ���� ������� �� �����
      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
      begin
        // �������� ������ ������������� �������, ����� �������������� � ModelObject.RestoreDatabase
        ModelObject.OriginalServerType := GetServerVersionByDBVersion(ModelObject.GetDatabaseVersion);
      end;  
    end;

    try
      // ���� �� � ������� ����������
      if Assigned(FProcessForm) then
      begin
        with FProcessForm as TgsFDBConvertFormView do
        begin
          if pcMain.ActivePage = tbs02 then
          begin
            eOriginalDatabase.Text := ModelObject.DatabaseName;
            eNewServerVersion.Text := GetTextServerVersion(CONVERT_SERVER_VERSION);
            eTempDatabaseName.Text := ModelObject.DatabaseCopyName;
            eBackupName.Text := ModelObject.DatabaseBackupName;

            // ���� ������� �� �����
            if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
            begin
              eBAKDatabaseCopy.Text := ModelObject.FinishOriginalDatabaseName;
              eOriginalDBVersion.Text := GetTextDBVersion(ModelObject.GetDatabaseVersion);
              eOriginalServerVersion.Text := GetTextServerVersion(ModelObject.OriginalServerType);

              // ���������� ����������: ���-�� �������, ������ ��������, ���������
              pnlDBProperties.Visible := True;
              // ����������� ��������� ������� �������� ��� FB 2.5 �������� 4096
              if ModelObject.DatabaseInfo.PageSize >= MINIMAL_PAGE_SIZE then
                cbPageSize.Text := IntToStr(ModelObject.DatabaseInfo.PageSize)
              else
                cbPageSize.Text := IntToStr(MINIMAL_PAGE_SIZE);
              eBufferSize.Text := IntToStr(ModelObject.DatabaseInfo.NumBuffers);
              // ������� ��������� ��
              CurrentCharset := ModelObject.GetDatabaseCharacterSet;
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
              eBAKDatabaseCopy.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);
              eOriginalDBVersion.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);
              eOriginalServerVersion.Text := Format('< %0:s >', [GetLocalizedString(lsUnknownParameterValue)]);

              // ������ ���� ����� (���-�� �������, ������ ��������, ���������) ��� ������ ������
              pnlDBProperties.Visible := False;
            end;
          end;

          // ������� ���� ����� � ����
          mProcessInformation.Clear;
          mProcessInformation.Lines.Add(lblOriginalDatabase.Caption + ' ' + eOriginalDatabase.Text);
          mProcessInformation.Lines.Add(lblBAKDatabaseCopy.Caption + ' ' + eBAKDatabaseCopy.Text);
          mProcessInformation.Lines.Add(lblOriginalDBVersion.Caption + ' ' + eOriginalDBVersion.Text);
          mProcessInformation.Lines.Add(lblOriginalServerVersion.Caption + ' ' + eOriginalServerVersion.Text);
          mProcessInformation.Lines.Add(lblNewServerVersion.Caption + ' ' + eNewServerVersion.Text);

          mProcessInformation.Lines.Add(lblBackupName.Caption + ' ' + eBackupName.Text);
          mProcessInformation.Lines.Add(lblTempDatabaseName.Caption + ' ' + eTempDatabaseName.Text);
          if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
          begin
            mProcessInformation.Lines.Add(lblPageSize.Caption + ' ' + cbPageSize.Text + ' ' + lblPageSize_02.Caption);
            mProcessInformation.Lines.Add(lblBufferSize.Caption + ' ' + eBufferSize.Text + ' ' + lblBufferSize_02.Caption);
            mProcessInformation.Lines.Add(lblCharacterSet.Caption + ' ' + cbCharacterSet.Text);
          end;
        end;
      end
      else
      begin
        WriteToConsoleLn(GetLocalizedString(lsDatabasePreprocessInformation));
        // ���� ������� �� �����
        if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
        begin
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalDatabase),
            ModelObject.DatabaseName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsBAKDatabaseCopy),
            ModelObject.FinishOriginalDatabaseName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalDBVersion),
            GetTextDBVersion(ModelObject.GetDatabaseVersion)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalServerVersion),
            GetTextServerVersion(GetServerVersionByDBVersion(ModelObject.GetDatabaseVersion))]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsNewServerVersion),
            GetTextServerVersion(CONVERT_SERVER_VERSION)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsBackupName),
            ModelObject.DatabaseBackupName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsTempDatabaseName),
            TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsPageSize),
            ModelObject.DatabaseInfo.PageSize, GetLocalizedString(lsPageSize_02)]));
          WriteToConsoleLn(Format('  %0:s %1:d %2:s', [GetLocalizedString(lsBufferSize),
            ModelObject.DatabaseInfo.NumBuffers, GetLocalizedString(lsBufferSize_02)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsCharacterSet),
            ModelObject.GetDatabaseCharacterSet]));
        end
        else
        begin
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsOriginalBackup),
            ModelObject.DatabaseName]));
          WriteToConsoleLn(Format('  %0:s < %1:s >', [GetLocalizedString(lsOriginalServerVersion),
            GetLocalizedString(lsUnknownParameterValue)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsNewServerVersion),
            GetTextServerVersion(CONVERT_SERVER_VERSION)]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsBackupName),
            ModelObject.DatabaseBackupName]));
          WriteToConsoleLn(Format('  %0:s %1:s', [GetLocalizedString(lsResultDatabaseName),
            TgsFileSystemHelper.GetDefaultDatabaseCopyName(ModelObject.DatabaseName)]));
        end;
      end;
    finally
      ModelObject.Disconnect;
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
      AddMessage(' ');
      AddMessage(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessSuccessfullEnd)]));
      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
      begin
        AddMessage(GetLocalizedString(lsOriginalDatabaseNameFinalMessage));
        AddMessage('  ' + ModelObject.FinishOriginalDatabaseName);
      end;
      AddMessage(GetLocalizedString(lsNewDatabaseNameFinalMessage));
      AddMessage('  ' + ModelObject.FinishConvertedDatabaseName);
      AddMessage(LOG_DIVIDER);
      Animate.Visible := False;
    end;
  end
  else
  begin
    WriteToConsoleLn(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessSuccessfullEnd)]));
    if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalDatabaseNameFinalMessage));
      WriteToConsoleLn('  ' + ModelObject.FinishOriginalDatabaseName);
    end;
    WriteToConsoleLn(GetLocalizedString(lsNewDatabaseNameFinalMessage));
    WriteToConsoleLn('  ' + ModelObject.FinishConvertedDatabaseName);
  end;
end;

procedure TgsFDBConvertController.ViewInterruptedProcessInformation(const AErrorMessage: String);
begin
  // ���� �� � ������� ����������
  if Assigned(FProcessForm) then
  begin
    with FProcessForm as TgsFDBConvertFormView do
    begin
      AddMessage(' ');
      // ������� �� ������
      if AErrorMessage <> '' then
      begin
        AddMessage(Format('%s: %s', [TimeToStr(Time), AErrorMessage]));
        AddMessage(' ');
        AddMessage(GetLocalizedString(lsProcessInterruptedEnd));
      end
      else
        AddMessage(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessInterruptedEnd)]));

      AddMessage(' ');

      if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
      begin
        AddMessage(GetLocalizedString(lsOriginalDatabaseNameInterruptMessage));
        AddMessage('  ' + ModelObject.DatabaseOriginalName);
      end
      else
      begin
        AddMessage(GetLocalizedString(lsOriginalBackupNameInterruptMessage));
        AddMessage('  ' + ModelObject.DatabaseOriginalName);
      end;
      
      AddMessage(LOG_DIVIDER);
      // ������ ��������
      Animate.Visible := False;
      // ������� ��������-���
      SetCurrentStep('');
    end;
  end
  else
  begin
    // ������� �� ������
    if AErrorMessage <> '' then
    begin
      WriteToConsoleLn(Format('%s: %s', [TimeToStr(Time), AErrorMessage]));
      WriteToConsoleLn(GetLocalizedString(lsProcessInterruptedEnd));
    end
    else
      WriteToConsoleLn(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcessInterruptedEnd)]));

    if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseOriginalName) then
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalDatabaseNameInterruptMessage));
      WriteToConsoleLn('  ' + ModelObject.DatabaseOriginalName);
    end
    else
    begin
      WriteToConsoleLn(GetLocalizedString(lsOriginalBackupNameInterruptMessage));
      WriteToConsoleLn('  ' + ModelObject.DatabaseOriginalName);
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
    // ���� �� ������� ��������� ��� ��������� ����-�����������
    if FindConsoleParam('S') = -1 then
    begin
      InputString := GetInputString(GetLocalizedString(lsStartConvertQuestion) + '(Y/N)?');
      if StrUpper(Trim(InputString)) <> 'Y' then
        Exit;
    end;
  end;

  // ���� True ������ ������� ��� ��� ��������,
  //  �� ����� ��������� ��� ����� ���� �� ����� ������� ClearConvertParams
  if not FWasConvertingProcess then
  begin
    // �������� ��� ������� ��� �������
    FWasConvertingProcess := True;

    // �������� �������� 
    if Assigned(FProcessForm) then
      with FProcessForm as TgsFDBConvertFormView do
        Animate.Visible := True;

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

procedure TgsFDBConvertController.CheckProcessParams(const RespondToForm: Boolean = False);
var
  ProcessedFileSize, ProcessedDBFileSize, ProcessedBKFileSize: Int64;
  NeedFreeSpace: Boolean;
  MessageStr: String;
  FreeSpaceMultiplier: Real;

  function FileSizeToStr(const AFileSize: Int64): String;
  var
    SizeInMB: Int64;
  begin
    SizeInMB := AFileSize div BYTE_IN_MB;
    if SizeInMB >= 1 then
      Result := IntToStr(SizeInMB)
    else
      Result := '<1';
  end;

begin
  NeedFreeSpace := False;
  MessageStr := '';

  // ���� �� ����� ��, �� ����� ���������� ����� � FREE_SPACE_MULTIPLIER ������ ��� ������ �������� �����,
  //  ���� ����� - � FREE_SPACE_MULTIPLIER_FOR_BK
  if not TgsFileSystemHelper.IsBackupFile(ModelObject.DatabaseName) then
  begin
    if (ModelObject.OriginalServerType = svUnknown) and not RespondToForm then
      raise EgsUnknownServerVersion.Create(GetLocalizedString(lsUnknownServerType));
    FreeSpaceMultiplier := FREE_SPACE_MULTIPLIER;
  end
  else
  begin
    FreeSpaceMultiplier := FREE_SPACE_MULTIPLIER_FOR_BK;
  end;

  // ���-�� ���������� ����� ��� ��������� �����
  ProcessedFileSize := Round(TgsFileSystemHelper.GetFileSize(ModelObject.DatabaseName) * FreeSpaceMultiplier);

  // �������� ������� ���������� ����� �� �����
  // ���� ����� �� � ����� �� ����� �����
  if UpperCase(ExtractFileDrive(ModelObject.DatabaseCopyName)) =
    UpperCase(ExtractFileDrive(ModelObject.DatabaseBackupName)) then
  begin
    // �������� ��������� ����� ��� ����� �� � ������ ��
    MessageStr := Format('%s %s %s',
      [UpperCase(ExtractFileDrive(ModelObject.DatabaseCopyName)), FileSizeToStr(ProcessedFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseCopyName, ProcessedFileSize) > 0 then
    begin
      NeedFreeSpace := True;
      if not (RespondToForm and Assigned(FProcessForm)) then
        raise EgsNeedFreeSpace.Create(GetLocalizedString(lsNoDiskSpaceForTempFiles) + #13#10#13#10 +
          Format('%s %s %s',
            [GetLocalizedString(lsWantDiskSpace), FileSizeToStr(ProcessedFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]));
    end;
  end
  else
  begin
    // �������� ��������� ����� ��� ������ ��
    ProcessedBKFileSize := Round(ProcessedFileSize * (1 / 3));
    MessageStr := Format('%s %s %s',
      [UpperCase(ExtractFileDrive(ModelObject.DatabaseBackupName)), FileSizeToStr(ProcessedBKFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseBackupName, ProcessedBKFileSize) > 0 then
    begin
      NeedFreeSpace := True;
      if not (RespondToForm and Assigned(FProcessForm)) then
        raise EgsNeedFreeSpace.Create(GetLocalizedString(lsNoDiskSpaceForBackup) + #13#10 +
          ModelObject.DatabaseBackupName + #13#10#13#10 +
          Format('%s %s %s',
            [GetLocalizedString(lsWantDiskSpace), FileSizeToStr(ProcessedBKFileSize),
             GetLocalizedString(lsDiskSpaceQuantifier)]));
    end;

    // �������� ��������� ����� ��� ����� ��
    ProcessedDBFileSize := Round(ProcessedFileSize * (2 / 3));
    MessageStr := MessageStr + Format(', %s %s %s',
      [UpperCase(ExtractFileDrive(ModelObject.DatabaseCopyName)), FileSizeToStr(ProcessedDBFileSize), GetLocalizedString(lsDiskSpaceQuantifier)]);
    if TgsFileSystemHelper.CheckForFreeDiskSpace(ModelObject.DatabaseCopyName, ProcessedDBFileSize) > 0 then
    begin
      NeedFreeSpace := True;
      if not (RespondToForm and Assigned(FProcessForm)) then
        raise EgsNeedFreeSpace.Create(GetLocalizedString(lsNoDiskSpaceForDBCopy) + #13#10 +
          ModelObject.DatabaseCopyName + #13#10#13#10 +
          Format('%s %s %s',
            [GetLocalizedString(lsWantDiskSpace), FileSizeToStr(ProcessedDBFileSize),
             GetLocalizedString(lsDiskSpaceQuantifier)]));
    end;
  end;

  if RespondToForm then
  begin
    if Assigned(FProcessForm) then
    begin
      if NeedFreeSpace then
        MessageStr := MessageStr + ' - ' + GetLocalizedString(lsNoDiskSpaceForTempFiles);
      (FProcessForm as TgsFDBConvertFormView).eNeedFreeSpace.Text := MessageStr;
    end;
  end
  else
  begin
    // �������� ������� ��������� �����, � �������� ���� ����
    CheckProcessPathes;
  end;
end;

procedure TgsFDBConvertController.SetCurrentStepMessage(const AStepMessage: String);
begin
  if Assigned(FProcessForm) then
    (FProcessForm as TgsFDBConvertFormView).SetCurrentStep(AStepMessage);
end;

procedure TgsFDBConvertController.CheckDiskWriteAbility(const InFormMode: Boolean);
begin
  try
    // �������� ��������������� ���� ������������ �������
    TgsFileSystemHelper.ChangeFirebirdRootDirectory(TgsFileSystemHelper.GetPathToServerDirectory(svFirebird_25));
  except
    // ���� �������� �� � �������
    if InFormMode then
    begin
      // ������� ��������� �� ������
      Application.MessageBox(
        PChar(GetLocalizedString(lsDirectoryNotWritable)),
        PChar(GetLocalizedString(lsInformationDialogCaption)),
        MB_OK or MB_ICONERROR or MB_APPLMODAL);
      Application.Terminate;
    end
    else
    begin
      WriteToConsoleLn(GetLocalizedString(lsDirectoryNotWritable));
      Halt;
    end;
  end;
end;

procedure TgsFDBConvertController.CheckProcessPathes;
begin
  TgsFileSystemHelper.CheckPathExistence(ModelObject.DatabaseCopyName);
  TgsFileSystemHelper.CheckPathExistence(ModelObject.DatabaseBackupName);
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
          ProcessTriggers;
          ProcessProcedures;
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
var
  ConnectInfo: TgsConnectionInformation;
  OriginalIsBackup: Boolean;
begin
  // ������ ����������� ��� ������� ���������
  Controller.InConvertingProcess := True;

  // ���� �� � ������� ����������, �� ����������� ������
  if Assigned(Controller.ProcessForm) then
    Synchronize((Controller.ProcessForm as TgsFDBConvertFormView).DisableControls);

  try
    try
      // ���� ������� ����� - ���������� ��� �� ��������� ����
      if TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseName) then
      begin
        OriginalIsBackup := True;
        // ������� ������������ �� ����������� ��������� ������
        try
          Controller.ModelObject.ServiceProgressRoutine(Format('%s: %s %s',
            [TimeToStr(Time), GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svYaffil)]));
          Controller.ModelObject.ServerType := svYaffil;
          // �������� ��� ��������� ����� ����������� ��� ���������� ������ ���������� � ������ ��������
          TgsFileSystemHelper.CreateTempFiles(svYaffil);
          try
            Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
          finally
            // ������ ��������� �����, ��������� ��� ������ ������� �������
            TgsFileSystemHelper.DeleteTempFiles;
          end;  
        except
          on E: EgsInterruptConvertProcess do
            raise
          else
          begin
            try
              // ������� �� ������ ��������������
              Controller.ModelObject.ServiceProgressRoutine(GetLocalizedString(lsDatabaseRestoreProcessError));
              // ��������������� ����. ��������
              Controller.ModelObject.ServiceProgressRoutine(Format('%s: %s %s',
                [TimeToStr(Time), GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svFirebird_20)]));
              Controller.ModelObject.ServerType := svFirebird_20;
              Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
            except
              on E: EgsInterruptConvertProcess do
                raise
              else
              begin
                try
                  // ������� �� ������ ��������������
                  Controller.ModelObject.ServiceProgressRoutine(GetLocalizedString(lsDatabaseRestoreProcessError));
                  // ��������������� ����. ��������
                  Controller.ModelObject.ServiceProgressRoutine(Format('%s: %s %s',
                    [TimeToStr(Time), GetLocalizedString(lsRestoreWithServer), GetTextServerVersion(svFirebird_25)]));
                  Controller.ModelObject.ServerType := svFirebird_25;
                  Controller.ModelObject.RestoreDatabase(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
                except
                  on E: EgsInterruptConvertProcess do
                    raise;

                  on E: Exception do
                  begin
                    // ������� �� ������ ��������������
                    Controller.ModelObject.ServiceProgressRoutine(GetLocalizedString(lsDatabaseRestoreProcessError));
                    raise Exception.Create(E.Message);
                  end;
                end;
              end;  
            end;
          end;  
        end;
      end
      else
      begin
        OriginalIsBackup := False;

        Controller.SetCurrentStepMessage(GetLocalizedString(lsDatabaseFileCopyingProcess));
        // ����� ����� ���� � �������� �� ��������� ����
        Controller.ModelObject.CopyDatabaseFile(Controller.ModelObject.DatabaseName, Controller.ModelObject.DatabaseCopyName);
        Controller.SetCurrentStepMessage('');
      end;

      // ����� ����� �������� � ������ ��
      Controller.ModelObject.DatabaseName := Controller.ModelObject.DatabaseCopyName;

      // ���� � ��� ��� �����, �� ������� ������ ������� ������������ ��
      if OriginalIsBackup then
      begin
        Controller.ModelObject.ServerType := CONVERT_SERVER_VERSION;
        Controller.ModelObject.Connect;
        try
          Controller.ModelObject.ServerType :=
            GetAppropriateServerVersion(GetServerVersionByDBVersion(Controller.ModelObject.GetDatabaseVersion));
          // �������� ������ ������������� �������, ����� �������������� � ModelObject.RestoreDatabase
          Controller.ModelObject.OriginalServerType := Controller.ModelObject.ServerType;
          // ������� �� ��������������� ���� ������� ��������
          ConnectInfo := Controller.ModelObject.ConnectionInformation;
          ConnectInfo.CharacterSet := Controller.ModelObject.GetDatabaseCharacterSet;
          Controller.ModelObject.ConnectionInformation := ConnectInfo;
        finally
          Controller.ModelObject.Disconnect;
        end;
      end
      else
      begin
        // ��� ���������� �� ������ ���� �������� � ViewPreProcessInformation
        Controller.ModelObject.ServerType :=
          GetAppropriateServerVersion(Controller.ModelObject.OriginalServerType);
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
          TgsFileSystemHelper.DoRenameFile(Controller.ModelObject.DatabaseOriginalName,
            Controller.ModelObject.FinishOriginalDatabaseName);
          // ����������� ����� �� � ������
          TgsFileSystemHelper.DoRenameFile(Controller.ModelObject.DatabaseCopyName,
            Controller.ModelObject.DatabaseOriginalName);
        except
          on E: Exception do
            Controller.ModelObject.ServiceProgressRoutine(E.Message);
        end;
      end;

      // ��������� ���������� � ����������� ��������
      SynchronizeMethod(Controller.ViewAfterProcessInformation);
    except
      on E: Exception do
      begin
        // ��������� ���������� � ���������� ��������
        FMessage := E.Message;
        SynchronizeMethod(OnInterruptedProcess);
      end;
    end;
  finally
    // ���������� �� ��
    Controller.ModelObject.Disconnect;
    // ������ ��������� �����
    if not TgsFileSystemHelper.IsBackupFile(Controller.ModelObject.DatabaseOriginalName) then
      TgsFileSystemHelper.DoDeleteFile(Controller.ModelObject.DatabaseCopyName);
    TgsFileSystemHelper.DoDeleteFile(Controller.ModelObject.DatabaseBackupName);

    // ������ ����������� ��� ������� ����������
    Controller.InConvertingProcess := False;

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
  NewFunctionText: String;
  DialogResult: TModalResult;
  DelimeterPos: Integer;
  ComputedTableName, ComputedFieldName: String;
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
            // ������� ��������� �� ������
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFEProcedureErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // ������� ������ �������������� ��� �������� ���������
            DialogResult := ShowForProcedure(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // �������� ���������� ���������
                FgsFunctionEditor.SetProcedureText(NewFunctionText);
                // ������������ ��������
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsProcedureModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
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
            // ������� ��������� �� ������
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFETriggerErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // ������� ������ �������������� ��� ��������
            DialogResult := ShowForTrigger(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // �������� ���������� �������
                FgsFunctionEditor.SetTriggerText(NewFunctionText);
                // ������������ ��������
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsTriggerModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
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
            // ������� ��������� �� ������
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFEViewErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // ������� ������ �������������� ��� ��������
            DialogResult := ShowForView(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;
                // �������� ���������� �������
                FgsFunctionEditor.SetViewText(NewFunctionText);
                // ����������� ������ ��� �������������
                FgsFunctionEditor.RestoreGrant(FMetadataName);
                // ������������ ��������
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsViewModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
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
            // ������� ��������� �� ������
            Application.MessageBox(
              PChar(Format('%s %s %s',
                [GetLocalizedString(lsFEComputedFieldErrorCaption), #13#10,
                 FgsFunctionEditor.GetFirstNLines(FMetadataError, 25)])),
              PChar(GetLocalizedString(lsInformationDialogCaption)),
              MB_OK or MB_ICONERROR or MB_APPLMODAL);

            // ������� ������ �������������� ��� ��������
            DialogResult := ShowForComputedField(FMetadataName, FMetadataText, FMetadataError);
            case DialogResult of
              idOk:
              begin
                NewFunctionText := SynEditFunctionText;        
                // �������� ���������� �������
                FgsFunctionEditor.SetViewText(NewFunctionText);
                // ������� ��� ������� � ��� ������������ ����
                DelimeterPos := AnsiPos(COMPUTED_FIELD_DELIMITER, FMetadataName);
                ComputedTableName := StrLeft(FMetadataName, DelimeterPos - 1);
                ComputedFieldName := StrRight(FMetadataName, StrLength(FMetadataName) - DelimeterPos);
                // ����������� ������ � ������� ������������ ����
                FgsFunctionEditor.RestoreGrant(ComputedFieldName, ComputedTableName);
                FgsFunctionEditor.RestorePosition(ComputedTableName, ComputedFieldName);
                // ������������ ��������
                Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsComputedFieldModified), [FMetadataName]),
                  FMetadataMaxProgress, FMetadataCurrentProgress);
              end;

              idAbort:
              begin
                raise EgsInterruptConvertProcess.Create('');
              end;
            else
              // ������������ ��������
              Controller.ModelObject.MetadataProgressRoutine(Format(GetLocalizedString(lsComputedFieldSkipped), [FMetadataName]),
                FMetadataMaxProgress, FMetadataCurrentProgress);
            end;
          end;
        end;
      end;
    except
      // ��� �������������� ����� �������� ������ - ����� ��������� ������ ��������������
      on E: EIBInterbaseError do
      begin
        FMetadataText := NewFunctionText;
        FMetadataError := E.Message;
        SynchronizeMethod(OnMetadataEditError);
      end;
    end;
  end
  else
  begin
    case FEditMetadataType of
      mtProcedure:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsProcedureError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);

      mtTrigger:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsTriggerError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);

      mtView:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsViewError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);

      mtComputedField:
        Controller.ModelObject.MetadataProgressRoutine(
          Format('%s %s. %s', [GetLocalizedString(lsComputedFieldError), FMetadataName, GetLocalizedString(lsObjectLeftCommented)]),
          FMetadataMaxProgress, FMetadataCurrentProgress);
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
    // ������� ������ �������� ��� ���������
    FgsFunctionEditor.GetProcedureList(FunctionList);
    // ������������ ��������
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;
    if not FIsRestoringMetadata then
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcedureProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsProcedureProcessStart));
    end
    else
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsProcedureProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsProcedureProcessFinish));
    end;

    // ������� �� ������ ��������
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // ������������ ��������
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('  ' + FunctionList[MetadataCounter], FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // ��������������\�������������� ���� ��������� FunctionList[MetadataCounter]
        FunctionText := FgsFunctionEditor.GetProcedureText(FunctionList[MetadataCounter]);
        // � ����������� �� �������������� ����� ����� ��������������, ��� �� ������� �����������
        if not FIsRestoringMetadata then
        begin
          if FgsFunctionEditor.CommentFunctionBody(FunctionText, True) then
            FgsFunctionEditor.SetProcedureText(FunctionText);
        end
        else
        begin
          // ������� ������ ������� �� �����
          if FgsFunctionEditor.ReplaceSubstituteUDFFunction(FunctionText) then
            FgsFunctionEditor.SetProcedureText(FunctionText);
          // �������������� ���������
          if FgsFunctionEditor.UncommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetProcedureText(FunctionText);
        end;
      except
        on E: EIBInterbaseError do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataText := FunctionText;
          FMetadataError := E.Message;
          SynchronizeMethod(OnMetadataEditError);
        end;
      end;
    end;
    // ������������ ��������
    FMetadataMaxProgress := FMetadataCurrentProgress;
    Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
    Controller.SetCurrentStepMessage('');
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
    // ������� ������ ��������� ��� ���������
    FgsFunctionEditor.GetTriggerList(FunctionList);
    // ������������ ��������
    FMetadataMaxProgress := FunctionList.Count;
    FMetadataCurrentProgress := 0;

    if not FIsRestoringMetadata then
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsTriggerProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsTriggerProcessStart));
    end
    else
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsTriggerProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsTriggerProcessFinish));
    end;

    // ������� �� ������ ���������
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // ������������ ��������
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('  ' + FunctionList[MetadataCounter], FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // ��������������\�������������� ���� �������� FunctionList[MetadataCounter]
        FunctionText := FgsFunctionEditor.GetTriggerText(FunctionList[MetadataCounter]);
        // � ����������� �� �������������� ����� ����� ��������������, ��� �� ������� �����������
        if not FIsRestoringMetadata then
        begin
          if FgsFunctionEditor.CommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionText);
        end
        else
        begin
          // ������� ������ ������� �� �����
          if FgsFunctionEditor.ReplaceSubstituteUDFFunction(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionText);
          // �������������� �������
          if FgsFunctionEditor.UncommentFunctionBody(FunctionText) then
            FgsFunctionEditor.SetTriggerText(FunctionText);
        end;
      except
        on E: EIBInterbaseError do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataText := FunctionText;
          FMetadataError := E.Message;
          SynchronizeMethod(OnMetadataEditError);
        end;
      end;
    end;
    // ������������ ��������
    FMetadataMaxProgress := FMetadataCurrentProgress;
    Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
    Controller.SetCurrentStepMessage('');
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
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessStart)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsViewFieldsProcessStart));
    end
    else
    begin
      Controller.ModelObject.MetadataProgressRoutine(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsViewFieldsProcessFinish)]),
        FMetadataMaxProgress, FMetadataCurrentProgress);
      Controller.SetCurrentStepMessage(GetLocalizedString(lsViewFieldsProcessFinish));
    end;

    // ������� �� ������ ������������� � ����������� �����
    for MetadataCounter := 0 to FunctionList.Count - 1 do
    begin
      // ������������ ��������
      FMetadataCurrentProgress := MetadataCounter + 1;
      Controller.ModelObject.MetadataProgressRoutine('  ' + FunctionList[MetadataCounter], FMetadataMaxProgress, FMetadataCurrentProgress);
      try
        // ��������� ��� �� ������� ������, ������������� ��� ���. ����
        DelimeterPos := AnsiPos(COMPUTED_FIELD_DELIMITER, FunctionList[MetadataCounter]);
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
            FgsFunctionEditor.SetViewText(MetadataText);
            FgsFunctionEditor.RestoreGrant(FunctionList[MetadataCounter]);
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
            MetadataText := FgsFunctionEditor.GetBackupComputedFieldText(ComputedTableName, ComputedFieldName);
            FgsFunctionEditor.SetComputedFieldText(MetadataText);
            FgsFunctionEditor.RestoreGrant(ComputedFieldName, ComputedTableName);
            FgsFunctionEditor.RestorePosition(ComputedTableName, ComputedFieldName);
          end;
        end;
      except
        on E: EIBInterbaseError do
        begin
          FMetadataName := FunctionList[MetadataCounter];
          FMetadataError := E.Message;
          FMetadataText := MetadataText;
          SynchronizeMethod(OnMetadataEditError);
        end;
      end;
    end;
    // ������������ ��������
    FMetadataMaxProgress := FMetadataCurrentProgress;
    Controller.ModelObject.MetadataProgressRoutine('', FMetadataMaxProgress, FMetadataCurrentProgress);
    Controller.SetCurrentStepMessage('');
  finally
    FreeAndNil(FunctionList);
  end;
end;

procedure TgsConvertThread.OnInterruptedProcess;
begin
  // ���������� ���������� ���������� �������� (��������� ������������� ��� �����������)
  Controller.ViewInterruptedProcessInformation(FMessage);
  // ������� ��������� �� ������
  FMessage := '';
end;

procedure TgsConvertThread.SynchronizeMethod(Method: TThreadMethod);
begin
  if Assigned(Controller.ProcessForm) then
    Synchronize(Method)
  else
    Method;
end;

end.
