unit prp_PropertySettings;

interface

uses gd_directories_const, prp_Filter, gd_i_ScriptFactory, classes, obj_i_Debugger;

type
  TDebugSet = record
    UseDebugInfo: Boolean;
    RuntimeSave: Boolean;
    IgnoreRuntime: Boolean;
    IgnoreRuntimeList: string;
  end;

  TGeneralSet = record
    AutoSaveChanges: Boolean;
    AutoSaveOnExecute: Boolean;
    AutoSaveCaretPos: Boolean;
    FullClassName: Boolean;
    NoticeTreeRefresh: Boolean;
    RestoreDeskTop: Boolean;
  end;

  TSFSet = record
    ShowUserSF: Boolean;
    ShowVBClassSF: Boolean;
    ShowMacrosSF: Boolean;
    ShowReportSF: Boolean;
    ShowEventSF: Boolean;
    ShowMethodSF: Boolean;
    ShowEntrySF: Boolean;
  end;

  TViewSet = record
    SFSet: TSFSet;
  end;

  TFilterSet = record
    OnlySpecEvent: Boolean;
    OnlyDisabled: Boolean;
    foClass: Integer;
    ClassName: ShortString;
    foMethod: Integer;
    MethodName: ShortString;
    foObject: Integer;
    ObjectName: ShortString;
    foEvent: Integer;
    EventName: ShortString;
  end;

  TSettings = record
    GeneralSet: TGeneralSet;
    ViewSet: TViewSet;
    DebugSet: TDebugSet;
    Filter: TFilterSet;
    Exceptions: TExceptionFlags;
  end;

function LoadSettings: TSettings;
procedure SaveSettings(Settings: TSettings);

var
  PropertySettings: TSettings;

const
  cRestoreDeskTop = 'RestoreDeskTop';
  cAutoSaveChanges = 'AutoSaveChanges';
  cAutoSaveOnExecute = 'AutoSaveOnExecute';
  cNoticeTreeRefresh = 'NoticeTreeRefresh';
  cShowUserSf = 'ShowUserSf';
  cShowVBClassSf = 'ShowVBClassSf';
  cShowMacrosSf = 'ShowMacrosSf';
  cShowReportSf = 'ShowReportSf';
  cShowEventSf = 'ShowEventSf';
  cShowMethodSf = 'ShowMethodSf';
  cShowEntrySf = 'ShowEntrySf';
  cUseDebugInfo = 'UseDebugInfo';
  cAutoSaveCaretPos = 'AutoSaveCaretPos';
  cFullClassName = 'FullClassName';
//  cStopOnException = 'StopOnException';
//  cStopOnDelphiException = 'StopOnDelphiException';
  //Filter
  cOnlySpecEvent = 'OnlySpecEvent';
  cOnlyDisabled = 'OnlyDisabled';
  cfoClass = 'foClass';
  cClassName = 'ClassName';
  cfoMethod = 'foMethod';
  cMethodName = 'MethodName';
  cfoObject = 'foObject';
  cObjectName = 'ObjectName';
  cfoEvent = 'foEvent';
  cEventName = 'EventName';
  // Exception
  cStop = 'Stop';
  cStopOnInside = 'StopOnInside';
  cSaveErrorLog = 'SaveErrorLog';
  cFileName = 'FileName';
  cLimitLines = 'LimitLines';
  cLinesCount = 'LinesCount';
  cIgnoreRuntime = 'IgnoreRuntime';
  cIgnoreRuntimeList = 'IgnoreRuntimeList';


const
  sPropertyGeneralPath = 'Options\PropertySettings\General';
  sPropertyViewSetPath = 'Options\PropertySettings\ViewSet';
  sPropertyDebugSetPath = 'Options\PropertySettings\DebugSet';
  sPropertyFilterPath = 'Options\PropertySettings\Filter';
  sPropertyExceptionPath = 'Options\PropertySettings\Exception';


implementation

uses
  Storages;

function LoadSettings: TSettings;
begin
  if not Assigned(UserStorage) then
    Exit;

  with Result do
  begin
    // Exception
    Exceptions.Stop :=
      UserStorage.ReadBoolean(sPropertyExceptionPath, cStop, False);
    Exceptions.StopOnInside :=
      UserStorage.ReadBoolean(sPropertyExceptionPath, cStopOnInside, False);
    Exceptions.SaveErrorLog :=
      UserStorage.ReadBoolean(sPropertyExceptionPath, cSaveErrorLog, False);
    Exceptions.FileName :=
      UserStorage.ReadString(sPropertyExceptionPath, cFileName, 'ErrScript.log');
    Exceptions.LimitLines :=
      UserStorage.ReadBoolean(sPropertyExceptionPath, cLimitLines, True);
    Exceptions.LinesCount :=
      UserStorage.ReadInteger(sPropertyExceptionPath, cLinesCount, 500);
    // General
    GeneralSet.AutoSaveChanges :=
      UserStorage.ReadBoolean(sPropertyGeneralPath, cAutoSaveChanges, True);
    GeneralSet.AutoSaveOnExecute :=
      UserStorage.ReadBoolean(sPropertyGeneralPath, cAutoSaveOnExecute, True);
    GeneralSet.AutoSaveCaretPos :=
      UserStorage.ReadBoolean(sPropertyGeneralPath, cAutoSaveCaretPos, true);
    GeneralSet.FullClassName :=
      UserStorage.ReadBoolean(sPropertyGeneralPath, cFullClassName, True);
    GeneralSet.NoticeTreeRefresh :=
      UserStorage.ReadBoolean(sPropertyGeneralPath, cNoticeTreeRefresh, True);
    GeneralSet.RestoreDeskTop :=
      UserStorage.ReadBoolean(sPropertyGeneralPath, cRestoreDeskTop, True);

    // ViewSet
    ViewSet.SFSet.ShowUserSF :=
      UserStorage.ReadBoolean(sPropertyViewSetPath, cShowUserSF, True);
    ViewSet.SFSet.ShowVBClassSF :=
      UserStorage.ReadBoolean(sPropertyViewSetPath, cShowVBClassSF, False);
    ViewSet.SFSet.ShowMacrosSF :=
      UserStorage.ReadBoolean(sPropertyViewSetPath, cShowMacrosSF, False);
    ViewSet.SFSet.ShowReportSF :=
      UserStorage.ReadBoolean(sPropertyViewSetPath, cShowReportSF, False);
    ViewSet.SFSet.ShowMethodSF :=
      UserStorage.ReadBoolean(sPropertyViewSetPath, cShowMethodSF, False);
    ViewSet.SFSet.ShowEventSF :=
      UserStorage.ReadBoolean(sPropertyViewSetPath, cShowEventSF, False);
    ViewSet.SFSet.ShowEntrySF :=
      UserStorage.ReadBoolean(sPropertyViewSetPath, cShowEntrySf, False);
    // DebugSet
    DebugSet.UseDebugInfo :=
      UserStorage.ReadBoolean(sPropertyDebugSetPath, cUseDebugInfo, False);
    { TODO : Пока не запоминается, может и не надо }
    DebugSet.RuntimeSave := False;
    DebugSet.IgnoreRuntime :=
      UserStorage.ReadBoolean(sPropertyDebugSetPath, cIgnoreRuntime, False);
    DebugSet.IgnoreRuntimeList :=
      UserStorage.ReadString(sPropertyDebugSetPath, cIgnoreRuntimeList, 'OnPaint, OnUpdate');
    // Filter
    Filter.OnlySpecEvent :=
      UserStorage.ReadBoolean(sPropertyFilterPath, cOnlySpecEvent, False);
    Filter.OnlyDisabled :=
      UserStorage.ReadBoolean(sPropertyFilterPath, cOnlyDisabled, False);
    Filter.foClass :=
      UserStorage.ReadInteger(sPropertyFilterPath, cfoClass, 0);
    Filter.ClassName :=
      UserStorage.ReadString(sPropertyFilterPath, cClassName, '');
    Filter.foMethod :=
      UserStorage.ReadInteger(sPropertyFilterPath, cfoMethod, 0);
    Filter.MethodName :=
      UserStorage.ReadString(sPropertyFilterPath, cMethodName, '');
    Filter.foObject :=
      UserStorage.ReadInteger(sPropertyFilterPath, cfoObject, 0);
    Filter.ObjectName :=
      UserStorage.ReadString(sPropertyFilterPath, cObjectName, '');
    Filter.foEvent :=
      UserStorage.ReadInteger(sPropertyFilterPath, cfoEvent, 0);
    Filter.EventName :=
      UserStorage.ReadString(sPropertyFilterPath, cEventName, '');
  end;

end;

procedure SaveSettings(Settings: TSettings);
begin
  if not Assigned(UserStorage) then
    Exit;

  // Exception
  UserStorage.WriteBoolean(sPropertyExceptionPath,
    cStop, Settings.Exceptions.Stop);
  UserStorage.WriteBoolean(sPropertyExceptionPath,
    cStopOnInside, Settings.Exceptions.StopOnInside);
  UserStorage.WriteBoolean(sPropertyExceptionPath,
    cSaveErrorLog, Settings.Exceptions.SaveErrorLog);
  UserStorage.WriteString(sPropertyExceptionPath,
    cFileName, Settings.Exceptions.FileName);
  UserStorage.WriteBoolean(sPropertyExceptionPath,
    cLimitLines, Settings.Exceptions.LimitLines);
  UserStorage.WriteInteger(sPropertyExceptionPath,
    cLinesCount, Settings.Exceptions.LinesCount);
  // General
  UserStorage.WriteBoolean(sPropertyGeneralPath,
    cAutoSaveChanges, Settings.GeneralSet.AutoSaveChanges);
  UserStorage.WriteBoolean(sPropertyGeneralPath,
    cAutoSaveOnExecute, Settings.GeneralSet.AutoSaveOnExecute);
  UserStorage.WriteBoolean(sPropertyGeneralPath,
    cAutoSaveCaretPos, Settings.GeneralSet.AutoSaveCaretPos);
  UserStorage.WriteBoolean(sPropertyGeneralPath,
    cFullClassName, Settings.GeneralSet.FullClassName);
  UserStorage.WriteBoolean(sPropertyGeneralPath,
    cNoticeTreeRefresh, Settings.GeneralSet.NoticeTreeRefresh);
  UserStorage.WriteBoolean(sPropertyGeneralPath,
    cRestoreDeskTop, Settings.GeneralSet.RestoreDeskTop);

//  UserStorage.WriteBoolean(sPropertyGeneralPath,
//    cStopOnException, Settings.GeneralSet.StopOnException);
//  UserStorage.WriteBoolean(sPropertyGeneralPath,
//    cStopOnDelphiException, Settings.GeneralSet.StopOnDelphiException);
  // ViewSet
  UserStorage.WriteBoolean(sPropertyViewSetPath,
    cShowUserSf, Settings.ViewSet.SFSet.ShowUserSF);
  UserStorage.WriteBoolean(sPropertyViewSetPath,
    cShowVBClassSf, Settings.ViewSet.SFSet.ShowVBClassSF);
  UserStorage.WriteBoolean(sPropertyViewSetPath,
    cShowMacrosSf, Settings.ViewSet.SFSet.ShowMacrosSF);
  UserStorage.WriteBoolean(sPropertyViewSetPath,
    cShowReportSf, Settings.ViewSet.SFSet.ShowReportSF);
  UserStorage.WriteBoolean(sPropertyViewSetPath,
    cShowEventSf, Settings.ViewSet.SFSet.ShowEventSF);
  UserStorage.WriteBoolean(sPropertyViewSetPath,
    cShowMethodSf, Settings.ViewSet.SFSet.ShowMethodSF);
  UserStorage.WriteBoolean(sPropertyViewSetPath,
    cShowEntrySf, Settings.ViewSet.SFSet.ShowEntrySF);
  // DebugSet
  UserStorage.WriteBoolean(sPropertyDebugSetPath,
    cUseDebugInfo, Settings.DebugSet.UseDebugInfo);
  // Filter
  UserStorage.WriteBoolean(sPropertyFilterPath,
    cOnlySpecEvent, Settings.Filter.OnlySpecEvent);
  UserStorage.WriteBoolean(sPropertyFilterPath,
    cOnlyDisabled, Settings.Filter.OnlyDisabled);
  UserStorage.WriteInteger(sPropertyFilterPath,
    cfoClass, Settings.Filter.foClass);
  UserStorage.WriteString(sPropertyFilterPath,
    cClassName, Settings.Filter.ClassName);
  UserStorage.WriteInteger(sPropertyFilterPath,
    cfoMethod, Settings.Filter.foMethod);
  UserStorage.WriteString(sPropertyFilterPath,
    cMethodName, Settings.Filter.MethodName);
  UserStorage.WriteInteger(sPropertyFilterPath,
    cfoObject, Settings.Filter.foObject);
  UserStorage.WriteString(sPropertyFilterPath,
    cObjectName, Settings.Filter.ObjectName);
  UserStorage.WriteInteger(sPropertyFilterPath,
    cfoEvent, Settings.Filter.foEvent);
  UserStorage.WriteString(sPropertyFilterPath,
    cEventName, Settings.Filter.EventName);
end;

end.
