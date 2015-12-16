object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 285
  Top = 161
  Height = 479
  Width = 741
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
    Left = 110
    Top = 140
  end
  object DSrc: TDataSource
    DataSet = IBDS
    Left = 150
    Top = 40
  end
  object IBQ: TIBQuery
    Database = IBDB
    Transaction = IBTr
    Left = 110
    Top = 90
  end
  object DS: TDataSource
    DataSet = IBQ
    Left = 150
    Top = 90
  end
end
