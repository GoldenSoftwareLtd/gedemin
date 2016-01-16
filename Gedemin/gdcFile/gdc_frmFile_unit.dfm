inherited gdc_frmFile: Tgdc_frmFile
  Left = 227
  Top = 169
  Width = 548
  Height = 409
  HelpContext = 19
  Caption = 'Файлы'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 351
    Width = 532
  end
  inherited TBDockTop: TTBDock
    Width = 532
    inherited tbMainCustom: TTBToolbar
      object TBItem4: TTBItem
        Action = actFolderSyncronize
      end
    end
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        Hint = 'Синхронизация папок'
        object TBItem2: TTBItem [24]
          Action = actFolderSyncronize
        end
        object TBSeparatorItem2: TTBSeparatorItem [25]
        end
      end
      inherited tbsiMainMenuDetailObject: TTBSubmenuItem
        object TBSeparatorItem3: TTBSeparatorItem
        end
        object TBItem3: TTBItem
          Action = actFileSyncronize
        end
      end
      object tbsmService: TTBSubmenuItem [2]
        Caption = 'Сервис'
        object tbiRootDirectory: TTBItem
          Action = actRootDirectory
        end
        object TBItem1: TTBItem
          Action = actSyncronize
        end
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Top = 71
    Height = 271
  end
  inherited TBDockRight: TTBDock
    Left = 523
    Top = 71
    Height = 271
  end
  inherited TBDockBottom: TTBDock
    Top = 342
    Width = 532
  end
  inherited pnlWorkArea: TPanel
    Top = 71
    Width = 514
    Height = 271
    inherited sMasterDetail: TSplitter
      Height = 166
    end
    inherited spChoose: TSplitter
      Top = 166
      Width = 514
    end
    inherited pnlMain: TPanel
      Height = 166
      inherited pnlSearchMain: TPanel
        Height = 166
        inherited sbSearchMain: TScrollBox
          Height = 139
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 166
      end
    end
    inherited pnChoose: TPanel
      Top = 172
      Width = 514
      inherited pnButtonChoose: TPanel
        Left = 409
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 409
      end
      inherited pnlChooseCaption: TPanel
        Width = 514
      end
    end
    inherited pnlDetail: TPanel
      Width = 342
      Height = 166
      inherited TBDockDetail: TTBDock
        Width = 342
        inherited tbDetailCustom: TTBToolbar
          Images = dmImages.il16x16
          Visible = True
          object tbiViewFile: TTBItem
            Action = actViewFile
          end
          object TBItem5: TTBItem
            Action = actFileSyncronize
          end
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 140
        inherited sbSearchDetail: TScrollBox
          Height = 113
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 182
        Height = 140
      end
    end
  end
  object pnlRootDirectory: TPanel [6]
    Left = 0
    Top = 51
    Width = 532
    Height = 20
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvNone
    TabOrder = 2
    object lblRootDirectory: TLabel
      Left = 108
      Top = 3
      Width = 77
      Height = 13
      Hint = 'Корневой каталог'
      Caption = 'lblRootDirectory'
      ParentShowHint = False
      ShowHint = True
      OnDblClick = actRootDirectoryExecute
    end
    object Label1: TLabel
      Left = 8
      Top = 3
      Width = 97
      Height = 13
      Caption = 'Корневой каталог:'
    end
  end
  inherited alMain: TActionList
    object actViewFile: TAction
      Caption = 'Проcмотреть файл'
      ImageIndex = 131
      OnExecute = actViewFileExecute
      OnUpdate = actViewFileUpdate
    end
    object actRootDirectory: TAction
      Caption = 'Корневой каталог'
      OnExecute = actRootDirectoryExecute
    end
    object actFolderSyncronize: TAction
      Category = 'Main'
      Caption = 'Синхронизация папок'
      Hint = 'Синхронизация папок'
      ImageIndex = 166
      OnExecute = actFolderSyncronizeExecute
      OnUpdate = actFolderSyncronizeUpdate
    end
    object actFileSyncronize: TAction
      Category = 'Detail'
      Caption = 'Синхронизация текущего файла'
      Hint = 'Синхронизация текущего файла'
      ImageIndex = 203
      OnExecute = actFileSyncronizeExecute
      OnUpdate = actFileSyncronizeUpdate
    end
    object actSyncronize: TAction
      Caption = 'Синхронизация файлов и папок'
      Hint = 'Синхронизация файлов и папок'
      OnExecute = actSyncronizeExecute
      OnUpdate = actSyncronizeUpdate
    end
  end
  object gdcFileFolder: TgdcFileFolder
    Left = 137
    Top = 113
  end
  object gdcFile: TgdcFile
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'parent'
    SubSet = 'ByParent'
    Left = 389
    Top = 161
  end
end
