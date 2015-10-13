object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 267
  Top = 214
  Height = 563
  Width = 1088
  object IBDB: TIBDatabase
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTr
    Left = 30
    Top = 40
  end
  object IBTr: TIBTransaction
    Active = False
    DefaultDatabase = IBDB
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 70
    Top = 40
  end
  object IBDS: TIBDataSet
    Database = IBDB
    Transaction = IBTr
    ReadTransaction = IBTr
    Left = 110
    Top = 40
  end
  object q: TIBSQL
    Database = IBDB
    Transaction = IBTr
    Left = 150
    Top = 40
  end
  object DSrc: TDataSource
    DataSet = IBDS
    Left = 190
    Top = 40
  end
end
