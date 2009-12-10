object dmReport: TdmReport
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 153
  Top = 150
  Height = 375
  Width = 544
  object ClientReport1: TClientReport
    Left = 24
    Top = 8
  end
  object IBTransaction1: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 24
    Top = 56
  end
  object ServerReport1: TServerReport
    Left = 112
    Top = 8
  end
end
