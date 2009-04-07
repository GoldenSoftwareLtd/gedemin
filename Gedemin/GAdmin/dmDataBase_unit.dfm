object dmDatabase: TdmDatabase
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 218
  Top = 201
  Height = 479
  Width = 741
  object ibdbGAdmin: TIBDatabase
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251'
      '')
    LoginPrompt = False
    AllowStreamedConnected = False
    AfterConnect = ibdbGAdminAfterConnect
    BeforeDisconnect = ibdbGAdminBeforeDisconnect
    Left = 48
    Top = 24
  end
  object ibsqlGenUniqueID: TIBSQL
    Database = ibdbGAdmin
    SQL.Strings = (
      '')
    Transaction = ibtrGenUniqueID
    Left = 232
    Top = 32
  end
  object ibtrGenUniqueID: TIBTransaction
    Active = False
    IdleTimer = 120000
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait'
      'read')
    AutoStopAction = saNone
    Left = 136
    Top = 24
  end
end
