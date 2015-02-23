object dmLogin: TdmLogin
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 293
  Top = 241
  Height = 480
  Width = 696
  object boLogin: TboLogin
    Database = dmDatabase.ibdbGAdmin
    AutoOpenCompany = True
    AfterSuccessfullConnection = boLoginAfterSuccessfullConnection
    BeforeDisconnect = boLoginBeforeDisconnect
    BeforeChangeCompany = boLoginBeforeChangeCompany
    AfterChangeCompany = boLoginAfterChangeCompany
    Left = 42
    Top = 64
  end
  object smMain: TSynManager
    Left = 296
    Top = 8
  end
  object gdcBaseManager: TgdcBaseManager
    Database = dmDatabase.ibdbGAdmin
    Left = 40
    Top = 8
  end
  object gsDesktopManager: TgsDesktopManager
    Database = dmDatabase.ibdbGAdmin
    Left = 138
    Top = 66
  end
  object ibtrAttr: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 344
    Top = 8
  end
  object prmGlobalDlg1: TprmGlobalDlg
    OnDlgCreate = prmGlobalDlg1DlgCreate
    Left = 144
    Top = 8
  end
  object ibtrGlobalDlg: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 224
    Top = 8
  end
end
