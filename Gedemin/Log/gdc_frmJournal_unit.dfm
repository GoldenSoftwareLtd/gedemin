inherited gdc_frmJournal: Tgdc_frmJournal
  Left = 220
  Top = 259
  Width = 783
  Height = 540
  HelpContext = 58
  Caption = 'gdc_frmJournal'
  Font.Name = 'Tahoma'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 474
    Width = 767
  end
  inherited TBDockTop: TTBDock
    Width = 767
    inherited tbMainCustom: TTBToolbar
      object tbiCreateTrig: TTBItem
        Action = actCreateTriggers
      end
      object tbiDelTrig: TTBItem
        Action = actDropTriggers
      end
      object tbsepBefOpenObject: TTBSeparatorItem
      end
      object tbiOpenObject: TTBItem
        Action = actOpenObject
      end
    end
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        object tbiCreateTrig2: TTBItem [22]
          Action = actCreateTriggers
        end
        object tbiDelTrig2: TTBItem [23]
          Action = actDropTriggers
        end
        object tbiOpenObj: TTBItem [24]
          Action = actOpenObject
        end
        object tbi_mm_sep5_2: TTBSeparatorItem [25]
        end
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 423
  end
  inherited TBDockRight: TTBDock
    Left = 758
    Height = 423
  end
  inherited TBDockBottom: TTBDock
    Top = 493
    Width = 767
  end
  inherited pnlWorkArea: TPanel
    Width = 749
    Height = 423
    inherited spChoose: TSplitter
      Top = 320
      Width = 749
    end
    inherited pnlMain: TPanel
      Width = 749
      Height = 320
      inherited pnlSearchMain: TPanel
        Height = 320
        inherited sbSearchMain: TScrollBox
          Height = 282
        end
        inherited pnlSearchMainButton: TPanel
          Top = 282
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 589
        Height = 320
      end
    end
    inherited pnChoose: TPanel
      Top = 324
      Width = 749
      inherited pnButtonChoose: TPanel
        Left = 644
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 644
      end
      inherited pnlChooseCaption: TPanel
        Width = 749
      end
    end
  end
  inherited alMain: TActionList
    inherited actMainReduction: TAction
      OnUpdate = actDuplicateUpdate
    end
    inherited actEditInGrid: TAction
      OnUpdate = actDuplicateUpdate
    end
    object actCreateTriggers: TAction
      Caption = 'Создать триггеры'
      Hint = 'Создать триггеры'
      ImageIndex = 105
      OnExecute = actCreateTriggersExecute
      OnUpdate = actCreateTriggersUpdate
    end
    object actDropTriggers: TAction
      Caption = 'Удалить триггеры'
      Hint = 'Удалить триггеры'
      ImageIndex = 110
      OnExecute = actDropTriggersExecute
      OnUpdate = actDropTriggersUpdate
    end
    object actOpenObject: TAction
      Caption = 'Открыть объект...'
      ImageIndex = 256
      OnExecute = actOpenObjectExecute
      OnUpdate = actOpenObjectUpdate
    end
  end
  inherited pmMain: TPopupMenu
    object nTriggersCreate: TMenuItem [11]
      Action = actCreateTriggers
    end
    object nTriggersDrop: TMenuItem [12]
      Action = actDropTriggers
    end
    object nTriggerSeparator: TMenuItem [13]
      Caption = '-'
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcJournal
  end
  object gdcJournal: TgdcJournal
    Left = 161
    Top = 177
  end
end
