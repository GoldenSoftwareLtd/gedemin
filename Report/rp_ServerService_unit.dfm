object GedeminReportServer: TGedeminReportServer
  OldCreateOrder = True
  OnDestroy = ServiceDestroy
  Dependencies = <
    item
      Name = 'InterBaseGuardian'
      IsGroup = False
    end>
  DisplayName = 'Gedemin Report Server'
  Interactive = True
  StartType = stManual
  BeforeInstall = ServiceBeforeInstall
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Left = 210
  Top = 162
  Height = 479
  Width = 741
  object gsIBDatabase: TIBDatabase
    DatabaseName = 'win2000server:k:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    AllowStreamedConnected = False
    AfterConnect = gsIBDatabaseAfterConnect
    Left = 56
    Top = 8
  end
  object ServerReport: TServerReport
    OnCreateObject = ServerReportCreateObject
    Database = gsIBDatabase
    Left = 56
    Top = 64
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = gsIBDatabase
    Params.Strings = (
      'concurrency'
      'nowait')
    AutoStopAction = saNone
    Left = 56
    Top = 120
  end
end
