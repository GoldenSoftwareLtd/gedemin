inherited gdc_frmAcctAccount: Tgdc_frmAcctAccount
  Left = 293
  Top = 81
  HelpContext = 160
  Caption = 'План счетов'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        object tbsepAn: TTBSeparatorItem [23]
        end
        object tbiAn: TTBItem [24]
          Action = actAddAnalize
        end
      end
    end
  end
  inherited pnlWorkArea: TPanel
    inherited pnlMain: TPanel
      inherited tvGroup: TgsDBTreeView
        DisplayField = 'ALIAS'
        MainFolderHead = False
        MainFolder = False
      end
    end
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailToolbar: TTBToolbar
          object TBItem6: TTBItem
            Action = actAddAnalize
            Caption = 'Добавить аналитику'
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 309
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 55
    Top = 175
    object actAddAnalize: TAction
      Category = 'Detail'
      Caption = 'Добавить аналитику...'
      Hint = 'Добавить аналитику'
      ImageIndex = 135
      OnExecute = actAddAnalizeExecute
      OnUpdate = actAddAnalizeUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 115
    Top = 175
    object NAddAn: TMenuItem [17]
      Action = actAddAnalize
    end
    object NSepAddAn: TMenuItem [18]
      Caption = '-'
    end
  end
  inherited dsMain: TDataSource
    Left = 85
    Top = 175
  end
  inherited dsDetail: TDataSource
    DataSet = gdcAcctAccount
    Left = 320
    Top = 220
  end
  inherited pmDetail: TPopupMenu
    Left = 350
    Top = 220
  end
  object gdcAcctAccount: TgdcAcctAccount
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'RootID'
    SubSet = 'ByRootID'
    Left = 290
    Top = 220
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 380
    Top = 220
  end
  object gdcAcctChart: TgdcAcctBase
    SubSet = 'ChartsAndFolders,ByCompany'
    Left = 145
    Top = 177
  end
end
