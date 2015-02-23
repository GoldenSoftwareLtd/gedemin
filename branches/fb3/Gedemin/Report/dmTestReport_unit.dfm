object dmTestReport: TdmTestReport
  Left = 236
  Top = 157
  Height = 479
  Width = 741
  object IBDatabase1: TIBDatabase
    DatabaseName = 'Win2000server:k:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    AllowStreamedConnected = False
    AfterConnect = IBDatabase1AfterConnect
    Left = 24
    Top = 8
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 72
    Top = 8
  end
end
