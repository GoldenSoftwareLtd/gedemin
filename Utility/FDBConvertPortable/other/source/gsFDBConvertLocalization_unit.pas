unit gsFDBConvertLocalization_unit;

interface

type
  // �������������� �������������� �����
  TgsLocalizedStringID =
    (
     lsApplicationCaption,
     lsEmptyLocalizedEntry,
     lsPressAnyButton,
     lsFileNotFound,
     lsFileDoesntExists,
     lsDirectoryAccessError,
     lsUnknownDatabaseType,
     lsUnknownServerType,
     lsLanguageNotFound,
     lsWrongSubstituteFile,
     lsCharsetListNotFound,
     lsEnterDatabasePath,
     lsUnknownParameterValue,
     lsDatabasePreprocessInformation,
     lsStep01,
     lsHello,
     lsLanguage,
     lsStep02,
     lsDatabaseBrowseDescription,
     lsStep03,
     lsStep03Group01,
     lsStep03Group02,
     lsStep03Group03,
     lsOriginalDatabase,
     lsOriginalBackup,
     lsResultDatabaseName,
     lsOriginalDBVersion,
     lsOriginalServerVersion,
     lsNewServerVersion,
     lsBackupName,
     lsTempDatabaseName,
     lsPageSize,
     lsPageSize_02,
     lsBufferSize,
     lsBufferSize_02,
     lsCharacterSet,
     lsStep04,
     lsOriginalFunction,
     lsSubstituteFunction,
     lsStep04Comment,
     lsDeleteUDF,
     lsStep05,
     lsStep06,
     lsStep07,
     lsStep07Comment,
     lsPrevButton,
     lsNextButton,
     lsExitButton,
     lsDatabaseBrowseButton,
     lsBAKDatabaseCopy,
     lsProcessSuccessfullEnd,
     lsNewDatabaseNameFinalMessage,
     lsOriginalDatabaseNameFinalMessage,
     lsProcessInterruptedEnd,
     lsOriginalDatabaseNameInterruptMessage,
     lsOriginalBackupNameInterruptMessage,
     lsStartConvertQuestion,
     lsNoDiskSpaceForTempFiles,
     lsNoDiskSpaceForDBCopy,
     lsNoDiskSpaceForBackup,
     lsDirectoryNotWritable,
     lsWantDiskSpace,
     lsDiskSpaceQuantifier,
     lsEditingMetadataError,
     lsRestoreWithServer,
     lsProcedureProcessStart,
     lsProcedureProcessFinish,
     lsProcedureModified,
     lsProcedureSkipped,
     lsProcedureError,
     lsTriggerProcessStart,
     lsTriggerProcessFinish,
     lsTriggerModified,
     lsTriggerSkipped,
     lsTriggerError,
     lsViewFieldsProcessStart,
     lsViewFieldsProcessFinish,
     lsComputedFieldProcessStartError,
     lsComputedFieldProcessFinishError,
     lsViewModified,
     lsViewSkipped,
     lsViewError,
     lsComputedFieldModified,
     lsComputedFieldSkipped,
     lsComputedFieldError, 
     lsObjectLeftCommented,
     lsDatabaseFileCopyingProcess,
     lsDatabaseBackupProcess,
     lsDatabaseBackupProcessError,
     lsDatabaseRestoreProcess,
     lsDatabaseRestoreProcessError,
     lsDatabaseValidationProcess,
     lsDatabaseValidationProcessError,
     lsDatabaseNULLCheckProcess,
     lsDatabaseNULLCheckMessage,
     lsDatabaseNULLCheckProcessError,
     lsContinueCheckingQuestion,
     lsContinueConvertingQuestion,
     lsCircularReferenceError,
     lsChooseDatabaseMessage,
     lsInformationDialogCaption,
     lsFEProcedureEditCaption,
     lsFEProcedureErrorCaption,
     lsFETriggerEditCaption,
     lsFETriggerErrorCaption,
     lsFEViewEditCaption,
     lsFEViewErrorCaption,
     lsFEComputedFieldEditCaption,
     lsFEComputedFieldErrorCaption,
     lsFEStopConvert,
     lsFESaveMetadata,
     lsFEDoComment,
     lsFEDoUncomment,
     lsFEDoShowError,
     lsAllFilesBrowseMask,
     lsDatabaseBrowseMask,
     lsBackupBrowseMask,
     lsLastID
    );

  function GetLocalizedString(const ALocStringID: TgsLocalizedStringID): String;
  procedure LoadLanguageStrings(const ALanguageName: String);
  function LanguageLoadedOnStartup: String;

implementation

uses
  classes, typinfo, sysutils, gsFDBConvertHelper_unit, jclStrings, windows;

const
  MULTILINE_FIRSTLINE_MARK = 1;
  MULTILINE_SEPARATOR = ' ';
  DOUBLE_SLASH_DUMMY = '/\\/';

  LANG_BELARUSIAN_NAME = '����������';
  LANG_RUSSIAN_NAME = '�������';
  LANG_ENGLISH_NAME = 'English';

var
  LocalizedStringArray: array [0..(Integer(lsLastID) - 1)] of String;
  LanguageLoadedOnStartupName: String;

function LanguageLoadedOnStartup: String;
begin
  Result := LanguageLoadedOnStartupName;
end;

procedure ProcessControlChar(var AString: String);
begin
  // �������� ������� ������� �����
  StrReplace(AString, '\\', DOUBLE_SLASH_DUMMY, [rfReplaceAll, rfIgnoreCase]);
  // ������� �� ����� ������
  StrReplace(AString, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]);
  // ���������
  StrReplace(AString, '\t', #9, [rfReplaceAll, rfIgnoreCase]);
  // ������ ������� ������� �����
  StrReplace(AString, DOUBLE_SLASH_DUMMY, '\\', [rfReplaceAll, rfIgnoreCase]);
  // ����
  StrReplace(AString, '\\', '\', [rfReplaceAll, rfIgnoreCase]);
end;

function LocalizedStringTypeToString(const ALocalizedStringType: TgsLocalizedStringID): String;
begin
  Result := GetEnumName(TypeInfo(TgsLocalizedStringID), Integer(ALocalizedStringType));
end;

function StringToLocalizedStringType(const ALocalizedStringTypeStr: String): TgsLocalizedStringID;
var
  I: Integer;
begin
  Result := lsEmptyLocalizedEntry;
  if ALocalizedStringTypeStr > '' then
  begin
    I := GetEnumValue(TypeInfo(TgsLocalizedStringID), ALocalizedStringTypeStr);
    if I <> -1 then
    begin
      Result := TgsLocalizedStringID(I);
      Exit;
    end;
  end;
end;

function GetLocalizedString(const ALocStringID: TgsLocalizedStringID): String;
begin
  Result := LocalizedStringArray[Integer(ALocStringID)];
end;

procedure SetLocalizedString(const ALocStringID: TgsLocalizedStringID; const AString: String);
begin
  LocalizedStringArray[Integer(ALocStringID)] := AString;
end;

procedure SetLanguageOnKeybordLayout;
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  KeboardLayout: Integer;
begin
  LanguageLoadedOnStartupName := '';

  GetKeyboardLayoutName(Ch);

  KeboardLayout := StrToInt('$' + String(Ch));
  try
    case (KeboardLayout and $3ff) of
      LANG_BELARUSIAN:
      begin
        LoadLanguageStrings(LANG_BELARUSIAN_NAME);
        LanguageLoadedOnStartupName := LANG_BELARUSIAN_NAME;
      end;

      LANG_RUSSIAN:
      begin
        LoadLanguageStrings(LANG_RUSSIAN_NAME);
        LanguageLoadedOnStartupName := LANG_RUSSIAN_NAME;
      end;

      LANG_ENGLISH:
      begin
        LoadLanguageStrings(LANG_ENGLISH_NAME);
        LanguageLoadedOnStartupName := LANG_ENGLISH_NAME;
      end;
    else
      LoadLanguageStrings(LANG_ENGLISH_NAME);
      LanguageLoadedOnStartupName := LANG_ENGLISH_NAME;
    end;
  except
    // ���� �� ���������� ��������� ���� �� ��������� ��������� ����������
    // �������� ��� ����� � �����, ��� ��������� ���� �� ��������� � �������
  end;
end;

procedure LoadLanguageStrings(const ALanguageName: String);
var
  LanguageStrings: TStringList;
  LocStringCounter: Integer;
  LocIDString: String;
  LocValue, TempS: String;
  LocID: TgsLocalizedStringID;
  MultiLineSymbolIndex: Integer;
  MultiLineNumberString: String;
begin
  LanguageStrings := TStringList.Create;
  try
    // �������� ����������� �� �����
    TgsConfigFileManager.GetLanguageContent(ALanguageName, LanguageStrings);
    // ������� ������ ����������� � ������
    for LocStringCounter := 0 to LanguageStrings.Count - 1 do
    begin
      LocIDString := LanguageStrings.Names[LocStringCounter];
      LocValue := LanguageStrings.Values[LocIDString];
      // ���������� ����������� �������
      ProcessControlChar(LocValue);
      // �������� ������ �������� ��������� �����, ���� lsLine.1, lsLine.2, lsLine.3
      MultiLineSymbolIndex := StrFind('.', LocIDString);
      if MultiLineSymbolIndex > 0 then
      begin
        LocID := StringToLocalizedStringType(StrLeft(LocIDString, MultiLineSymbolIndex - 1));
        // ���� ������������� �������� ����������� �����
        if LocID <> lsEmptyLocalizedEntry then
        begin
          // ������ ����� ������ � ��������������� ��������
          MultiLineNumberString := Trim(StrRight(LocIDString, StrLength(LocIDString) - MultiLineSymbolIndex));
          if StrIsDigit(MultiLineNumberString) then
          begin
            // ���� ����� ������ = MULTILINE_FIRSTLINE_MARK, �� �������� ��������� ������� ���������,
            //  ����� ���������� ��������� ������� ���������� �������,
            //  �������� �� ��������
            if StrToInt(MultiLineNumberString) = MULTILINE_FIRSTLINE_MARK then
              SetLocalizedString(LocID, LocValue)
            else
            begin
              TempS := GetLocalizedString(LocID);
              if Copy(TempS, Length(TempS), 1) > ' ' then
                TempS := TempS + MULTILINE_SEPARATOR;
              SetLocalizedString(LocID, TempS + LocValue);
            end;
          end;
        end;
      end
      else
      begin
        LocID := StringToLocalizedStringType(LocIDString);
        // ���� ������������� �������� ����������� �����
        if LocID <> lsEmptyLocalizedEntry then
          // ��������� ������� ����������� � �������
          SetLocalizedString(LocID, LocValue);
      end;
    end;
  finally
    FreeAndNil(LanguageStrings);
  end;
end;

procedure __SetDefaultValues;
begin
  SetLocalizedString(lsApplicationCaption, 'FDB Converter');
  SetLocalizedString(lsPressAnyButton, '������� ����� �������...');
  SetLocalizedString(lsFileNotFound, '���� �� ������');
  SetLocalizedString(lsFileDoesntExists, '���� %0:s �� ����������.');
  SetLocalizedString(lsDirectoryAccessError, '������ ������� � ����������');
  SetLocalizedString(lsUnknownDatabaseType, '����������� ��� ��');
  SetLocalizedString(lsUnknownServerType, '����������� ��� �������');
  SetLocalizedString(lsLanguageNotFound, '�� ������ ���� %0:s � ����� �����������!');
  SetLocalizedString(lsWrongSubstituteFile, '�������� ������ ����� ���������� �������!');
  SetLocalizedString(lsCharsetListNotFound, '�� ������ ������ ������� ������� � ����� ������ ����������!');
  SetLocalizedString(lsEnterDatabasePath, '������� ���� � �������������� ��:');
  SetLocalizedString(lsUnknownParameterValue, '����������');
  SetLocalizedString(lsDatabasePreprocessInformation, '��������������� ���������� � ����������� ��');

  SetLocalizedString(lsStep01, '�����������');
  SetLocalizedString(lsHello, '�����������');
  SetLocalizedString(lsLanguage, '���� ����������');
  SetLocalizedString(lsStep02, '����� ����� ���� ������');
  SetLocalizedString(lsDatabaseBrowseDescription, '�������� ���� ������ ��� ���� ������ ���� ������');
  SetLocalizedString(lsStep03, '��������� ����������');
  SetLocalizedString(lsStep03Group01, '��������� �����. ����� ������� �� ��������� ��������');
  SetLocalizedString(lsStep03Group02, '�������� ���� ������');
  SetLocalizedString(lsStep03Group03, '����������������� ���� ������');
  SetLocalizedString(lsOriginalDatabase, '�������� ���� ������');
  SetLocalizedString(lsOriginalBackup, '�������� �������� ����');
  SetLocalizedString(lsResultDatabaseName, '�������� ���� ������');
  SetLocalizedString(lsOriginalDBVersion, '������ �������� ��');
  SetLocalizedString(lsOriginalServerVersion, '�������� ������');
  SetLocalizedString(lsNewServerVersion, '����� ������');
  SetLocalizedString(lsBackupName, '�������� ����');
  SetLocalizedString(lsTempDatabaseName, '��������� ��');
  SetLocalizedString(lsPageSize, '������ ��������');
  SetLocalizedString(lsPageSize_02, '����');
  SetLocalizedString(lsBufferSize, '������ ������');
  SetLocalizedString(lsBufferSize_02, '�������');
  SetLocalizedString(lsCharacterSet, '������� ��������');
  SetLocalizedString(lsStep04, '���������� �������');
  SetLocalizedString(lsOriginalFunction, '���������� �������');
  SetLocalizedString(lsSubstituteFunction, '���������� �������');
  SetLocalizedString(lsStep04Comment, '������ ������� ����� ��������');
  SetLocalizedString(lsDeleteUDF, '��������� �������');
  SetLocalizedString(lsStep05, '����������');
  SetLocalizedString(lsStep06, '��� ��������');
  SetLocalizedString(lsStep07, '�������');
  SetLocalizedString(lsStep07Comment, '�������');
  SetLocalizedString(lsPrevButton, '�����');
  SetLocalizedString(lsNextButton, '�����');
  SetLocalizedString(lsExitButton, '�����');
  SetLocalizedString(lsDatabaseBrowseButton, '�����');            
  SetLocalizedString(lsBAKDatabaseCopy, 'BAK ����');

  SetLocalizedString(lsProcessSuccessfullEnd, '������� �������� �������');
  SetLocalizedString(lsNewDatabaseNameFinalMessage, '����������������� ���� ������ ��������� ��� ������:');
  SetLocalizedString(lsOriginalDatabaseNameFinalMessage, '������������ ���� ������ ��������� ��� ������:');
  SetLocalizedString(lsProcessInterruptedEnd, '������� ����������� �������');
  SetLocalizedString(lsOriginalDatabaseNameInterruptMessage, '������������ ������ ��������� ��� ������:');
  SetLocalizedString(lsOriginalBackupNameInterruptMessage, '������������ ���� ������ ��������� ��� ���������');
  SetLocalizedString(lsStartConvertQuestion, '������ ���������������');
  SetLocalizedString(lsNoDiskSpaceForTempFiles, '�� ������� ����� �� ����� ��� ��������� ������');
  SetLocalizedString(lsNoDiskSpaceForDBCopy, '�� ������� ����� �� ����� ��� ����� ��');
  SetLocalizedString(lsNoDiskSpaceForBackup, '�� ������� ����� �� ����� ��� ������ ��');
  SetLocalizedString(lsDirectoryNotWritable, '������ ������� � �����: ���������� ��������� ���������� ��� ������');
  SetLocalizedString(lsWantDiskSpace, '����������: %d ��');
  SetLocalizedString(lsEditingMetadataError, '� �������� �������������� ���������� ��������� ������');
  SetLocalizedString(lsRestoreWithServer, '�������������� ���� ������ � ������� �������');
  SetLocalizedString(lsProcedureProcessStart, '��������������� �������� ��������');
  SetLocalizedString(lsProcedureProcessFinish, '�������� ������������ �� �������� ��������');
  SetLocalizedString(lsProcedureModified, '��������� %s ��������');
  SetLocalizedString(lsProcedureSkipped, '��������� %s ���������. ���������� ������ ���������.');
  SetLocalizedString(lsProcedureError, '������ ��� ���������� �������� ���������');
  SetLocalizedString(lsTriggerProcessStart, '��������������� ���������');
  SetLocalizedString(lsTriggerProcessFinish, '�������� ������������ �� ���������');
  SetLocalizedString(lsTriggerModified, '������� %s �������');
  SetLocalizedString(lsTriggerSkipped, '������� %s ��������. ���������� ������ ���������.');
  SetLocalizedString(lsTriggerError, '������ ��� ���������� ��������');
  SetLocalizedString(lsViewFieldsProcessStart, '������������� ������������� � ����������� �����');
  SetLocalizedString(lsViewFieldsProcessFinish, '�������������� ������������� � ����������� �����');
  SetLocalizedString(lsComputedFieldProcessStartError, '������ ��� ������������� ������������ ����');
  SetLocalizedString(lsComputedFieldProcessFinishError, '������ ��� �������������� ������������ ����');
  SetLocalizedString(lsViewModified, '������������� %s ����������');
  SetLocalizedString(lsViewSkipped, '������������� %s ���������, � �� �������������. ���������� ������ ��������������.');
  SetLocalizedString(lsViewError, '������ ��� ���������� �������������');
  SetLocalizedString(lsComputedFieldModified, '����������� ���� %s ����������');
  SetLocalizedString(lsComputedFieldSkipped, '����������� ���� %s ���������, � �� �������������. ���������� ������ ��������������.');
  SetLocalizedString(lsComputedFieldError, '������ ��� ���������� ������������ ����');
  SetLocalizedString(lsObjectLeftCommented, '������ �������� ������������������.');
  
  SetLocalizedString(lsDatabaseFileCopyingProcess, '����������� ����� ���� ������');
  SetLocalizedString(lsDatabaseBackupProcess, '��������� ���� ������');
  SetLocalizedString(lsDatabaseBackupProcessError, '� �������� ��������� ���� ������ ��������� ������');
  SetLocalizedString(lsDatabaseRestoreProcess, '�������������� ���� ������');
  SetLocalizedString(lsDatabaseRestoreProcessError, '� �������� �������������� ���� ������ ��������� ������');
  SetLocalizedString(lsDatabaseValidationProcess, '�������� ���� ������');
  SetLocalizedString(lsDatabaseValidationProcessError, '� �������� �������� ���� ������ ��������� ������');
  SetLocalizedString(lsDatabaseNULLCheckProcess, '�������� ���� ������ �� NULL ��������');
  SetLocalizedString(lsContinueCheckingQuestion, '���������� ��������?');
  SetLocalizedString(lsContinueConvertingQuestion, '���������� ������� �����������?');
  SetLocalizedString(lsDatabaseNULLCheckMessage, '� ������� "%s" ������� "%s" ������������ ������������ NULL ��������');
  SetLocalizedString(lsDatabaseNULLCheckProcessError, '� �������� �������� ���� ������ �� NULL �������� ��������� ������');
  SetLocalizedString(lsCircularReferenceError, '��������� ������������� � ����������� ���� ��������� � ����������� �����������');

  SetLocalizedString(lsChooseDatabaseMessage, '�������� ���� ������ ��� �����������');
  SetLocalizedString(lsInformationDialogCaption, '��������');

  SetLocalizedString(lsFEProcedureEditCaption, '�������������� �������� ���������');
  SetLocalizedString(lsFEProcedureErrorCaption, '��������� ������ ��� ���������� �������� ���������');
  SetLocalizedString(lsFETriggerEditCaption, '�������������� ��������');
  SetLocalizedString(lsFETriggerErrorCaption, '��������� ������ ��� ���������� ��������');
  SetLocalizedString(lsFEViewEditCaption, '�������������� �������������');
  SetLocalizedString(lsFEViewErrorCaption, '��������� ������ ��� ���������� �������������');
  SetLocalizedString(lsFEComputedFieldEditCaption, '�������������� ������������ ����');
  SetLocalizedString(lsFEComputedFieldErrorCaption, '��������� ������ ��� ���������� ������������ ����');
  SetLocalizedString(lsFEStopConvert, '�������� ����������� ��');
  SetLocalizedString(lsFESaveMetadata, '���������');
  SetLocalizedString(lsFEDoComment, '����������������');
  SetLocalizedString(lsFEDoUncomment, '����������������');
  SetLocalizedString(lsFEDoShowError, '�������� ����� ������');

  SetLocalizedString(lsAllFilesBrowseMask, '��� �����');
  SetLocalizedString(lsDatabaseBrowseMask, '���� ������');
  SetLocalizedString(lsBackupBrowseMask, '����� ���� ������');

end;

initialization
  __SetDefaultValues;
  SetLanguageOnKeybordLayout;
end.
