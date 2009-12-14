unit gsFDBConvertLocalization_unit;

interface

type
  // �������������� �������������� �����
  TgsLocalizedStringID =
    (
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
     lsStep05,
     lsStep06,
     lsStep07,
     lsStep08,
     lsPrevButton,
     lsNextButton,
     lsExitButton,
     lsDatabaseBrowseButton,
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
     lsWantDiskSpace,
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
     lsViewFieldsProcessStartError,
     lsViewFieldsProcessFinishError,
     lsViewModified,
     lsViewSkipped,
     lsViewError,
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
     lsCircularReferenceError,
     lsChooseDatabaseMessage,
     lsInformationDialogCaption,
     lsFEParamsCaption,
     lsFEProcedureCaption,
     lsFEProcedureEditCaption,
     lsFEProcedureErrorCaption,
     lsFETriggerCaption,
     lsFETriggerEditCaption,
     lsFETriggerErrorCaption,
     lsFEViewCaption,
     lsFEViewEditCaption,
     lsFEViewErrorCaption,
     lsFEStopConvert,
     lsFESaveMetadata,
     lsFESkipMetadata,
     lsAllFilesBrowseMask,
     lsDatabaseBrowseMask,
     lsBackupBrowseMask,
     lsLastID
    );

  function GetLocalizedString(const ALocStringID: TgsLocalizedStringID): String;
  procedure LoadLanguageStrings(const ALanguageName: String);

implementation

uses
  classes, typinfo, sysutils, gsFDBConvertHelper_unit;

var
  LocalizedStringArray: array [0..(Integer(lsLastID) - 1)] of String;

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

procedure LoadLanguageStrings(const ALanguageName: String);
var
  LanguageStrings: TStringList;
  LocStringCounter: Integer;
  LocIDString: String;
  LocID: TgsLocalizedStringID;
begin
  LanguageStrings := TStringList.Create;
  try
    // �������� ����������� �� �����
    TgsConfigFileManager.GetLanguageContent(ALanguageName, LanguageStrings);
    // ������� ������ ����������� � ������
    for LocStringCounter := 0 to LanguageStrings.Count - 1 do
    begin
      LocIDString := LanguageStrings.Names[LocStringCounter];
      LocID := StringToLocalizedStringType(LocIDString);
      if LocID <> lsEmptyLocalizedEntry then
        SetLocalizedString(LocID, LanguageStrings.Values[LocIDString]);
    end;
  finally
    FreeAndNil(LanguageStrings);
  end;
end;

procedure __SetDefaultValues;
begin
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
  SetLocalizedString(lsStep05, '����������');
  SetLocalizedString(lsStep06, '��� ��������');
  SetLocalizedString(lsStep07, '����������');
  SetLocalizedString(lsStep08, '�������');
  SetLocalizedString(lsPrevButton, '�����');
  SetLocalizedString(lsNextButton, '�����');
  SetLocalizedString(lsExitButton, '�����');
  SetLocalizedString(lsDatabaseBrowseButton, '�����');

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
  SetLocalizedString(lsViewFieldsProcessStartError, '������ ��� �������������');
  SetLocalizedString(lsViewFieldsProcessFinishError, '������ ��� ��������������');
  SetLocalizedString(lsViewModified, '������������� %s ����������');
  SetLocalizedString(lsViewSkipped, '������������� %s ���������, � �� �������������. ���������� ������ ��������������.');
  SetLocalizedString(lsViewError, '������ ��� ���������� �������������');
  SetLocalizedString(lsObjectLeftCommented, '������ �������� ������������������.');

  SetLocalizedString(lsDatabaseFileCopyingProcess, '����������� ����� ���� ������');
  SetLocalizedString(lsDatabaseBackupProcess, '��������� ���� ������');
  SetLocalizedString(lsDatabaseBackupProcessError, '� �������� ��������� ���� ������ ��������� ������');
  SetLocalizedString(lsDatabaseRestoreProcess, '�������������� ���� ������');
  SetLocalizedString(lsDatabaseRestoreProcessError, '� �������� �������������� ���� ������ ��������� ������');
  SetLocalizedString(lsDatabaseValidationProcess, '�������� ���� ������');
  SetLocalizedString(lsDatabaseValidationProcessError, '� �������� �������� ���� ������ ��������� ������');
  SetLocalizedString(lsDatabaseNULLCheckProcess, '�������� ���� ������ �� NULL ��������');
  SetLocalizedString(lsDatabaseNULLCheckMessage, '� ������� "%s" ������� "%s" ������������ ������������ NULL ��������');
  SetLocalizedString(lsDatabaseNULLCheckProcessError, '� �������� �������� ���� ������ �� NULL �������� ��������� ������');
  SetLocalizedString(lsCircularReferenceError, '��������� ������������� � ����������� ���� ��������� � ����������� �����������');

  SetLocalizedString(lsChooseDatabaseMessage, '�������� ���� ������ ��� �����������');
  SetLocalizedString(lsInformationDialogCaption, '��������');

  SetLocalizedString(lsFEParamsCaption, '���������');
  SetLocalizedString(lsFEProcedureCaption, '�������� ���������');
  SetLocalizedString(lsFEProcedureEditCaption, '�������������� �������� ���������');
  SetLocalizedString(lsFEProcedureErrorCaption, '��������� ������ ��� ���������� �������� ���������');
  SetLocalizedString(lsFETriggerCaption, '�������');
  SetLocalizedString(lsFETriggerEditCaption, '�������������� ��������');
  SetLocalizedString(lsFETriggerErrorCaption, '��������� ������ ��� ���������� ��������');
  SetLocalizedString(lsFEViewCaption, '�������������');
  SetLocalizedString(lsFEViewEditCaption, '�������������� �������������');
  SetLocalizedString(lsFEViewErrorCaption, '��������� ������ ��� ���������� �������������');
  SetLocalizedString(lsFEStopConvert, '�������� ����������� ��');
  SetLocalizedString(lsFESaveMetadata, '���������');
  SetLocalizedString(lsFESkipMetadata, '����������');

  SetLocalizedString(lsAllFilesBrowseMask, '��� �����');
  SetLocalizedString(lsDatabaseBrowseMask, '���� ������');
  SetLocalizedString(lsBackupBrowseMask, '����� ���� ������');

end;

initialization
  __SetDefaultValues;
end.
