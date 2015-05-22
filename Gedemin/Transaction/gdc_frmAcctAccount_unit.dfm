inherited gdc_frmAcctAccount: Tgdc_frmAcctAccount
  Left = 212
  Top = 48
  HelpContext = 160
  Caption = 'План счетов'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainToolbar: TTBToolbar
      inherited tbiNew: TTBItem
        Action = actNewFolder
        Visible = False
      end
      object TBSubmenuItem1: TTBSubmenuItem [1]
        Action = actNewChart
        DropdownCombo = True
        object TBItem1: TTBItem
          Action = actNewChart
        end
        object TBItem2: TTBItem
          Action = actNewFolder
        end
      end
    end
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        inherited tbi_mm_New: TTBItem
          Visible = False
        end
        object tbsepAn: TTBSeparatorItem [23]
        end
        object tbiAn: TTBItem [24]
          Action = actAddAnalize
        end
      end
      inherited tbsiMainMenuDetailObject: TTBSubmenuItem
        inherited tbi_mm_DetailNew: TTBItem
          Visible = False
        end
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 286
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
          object TBSubmenuItem2: TTBSubmenuItem [0]
            Action = actNewAccount
            DropdownCombo = True
            object TBItem3: TTBItem
              Action = actNewAccount
            end
            object TBItem4: TTBItem
              Action = actNewSubAccount
            end
          end
          inherited tbiDetailNew: TTBItem
            Visible = False
          end
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
    object actNewChart: TAction
      Category = 'Main'
      Caption = 'Добавить план счетов...'
      Hint = 'Добавить план счетов'
      ImageIndex = 0
      OnExecute = actNewChartExecute
    end
    object actNewFolder: TAction
      Category = 'Main'
      Caption = 'Добавить раздел...'
      Hint = 'Добавить раздел'
      ImageIndex = 0
      OnExecute = actNewFolderExecute
      OnUpdate = actNewFolderUpdate
    end
    object actNewAccount: TAction
      Category = 'Detail'
      Caption = 'Добавить счет...'
      Hint = 'Добавить счет'
      ImageIndex = 0
      OnExecute = actNewAccountExecute
      OnUpdate = actNewAccountUpdate
    end
    object actNewSubAccount: TAction
      Category = 'Detail'
      Caption = 'Добавить субсчет...'
      ImageIndex = 0
      OnExecute = actNewSubAccountExecute
      OnUpdate = actNewSubAccountUpdate
    end
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
    inherited nNew_OLD: TMenuItem
      Action = nil
      Caption = 'Добавить'
      ShortCut = 0
      OnClick = nil
      object N1: TMenuItem
        Action = actNewChart
      end
      object N2: TMenuItem
        Action = actNewFolder
      end
    end
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
    inherited nDetailNew: TMenuItem
      Action = nil
      Caption = 'Добавить'
      ShortCut = 0
      object N3: TMenuItem
        Action = actNewAccount
      end
      object N4: TMenuItem
        Action = actNewSubAccount
      end
    end
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
