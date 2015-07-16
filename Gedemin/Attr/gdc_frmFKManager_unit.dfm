inherited gdc_frmFKManager: Tgdc_frmFKManager
  Left = 302
  Top = 150
  Width = 870
  Height = 640
  Caption = 'gdc_frmFKManager'
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 14
  inherited sbMain: TStatusBar
    Top = 590
    Width = 862
  end
  inherited TBDockTop: TTBDock
    Width = 862
    inherited tbMainCustom: TTBToolbar
      object TBItem2: TTBItem
        Action = actConvertFK
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object tbiUpdateStats: TTBItem
        Action = actUpdateStats
      end
      object TBItem1: TTBItem
        Action = actCancelUpdateStats
      end
      object tbsiUpdateStats: TTBSeparatorItem
      end
      object TBControlItem1: TTBControlItem
        Control = pbUpdateStats
      end
      object pbUpdateStats: TProgressBar
        Left = 30
        Top = 3
        Width = 150
        Height = 16
        Min = 0
        Max = 100
        TabOrder = 0
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 530
  end
  inherited TBDockRight: TTBDock
    Left = 853
    Height = 530
  end
  inherited TBDockBottom: TTBDock
    Top = 581
    Width = 862
  end
  inherited pnlWorkArea: TPanel
    Width = 844
    Height = 530
    inherited spChoose: TSplitter
      Top = 427
      Width = 844
    end
    inherited pnlMain: TPanel
      Width = 844
      Height = 427
      inherited pnlSearchMain: TPanel
        Height = 427
        inherited sbSearchMain: TScrollBox
          Height = 400
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 684
        Height = 427
      end
    end
    inherited pnChoose: TPanel
      Top = 431
      Width = 844
      inherited pnButtonChoose: TPanel
        Left = 739
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 739
      end
      inherited pnlChooseCaption: TPanel
        Width = 844
      end
    end
  end
  inherited alMain: TActionList
    object actUpdateStats: TAction
      Category = 'Main'
      Caption = 'Обновить статистику...'
      Hint = 'Обновить статистику индексов'
      ImageIndex = 209
      OnExecute = actUpdateStatsExecute
      OnUpdate = actUpdateStatsUpdate
    end
    object actCancelUpdateStats: TAction
      Category = 'Main'
      Caption = 'Прервать'
      Hint = 'Прервать обновление статистики индексов'
      ImageIndex = 207
      OnExecute = actCancelUpdateStatsExecute
      OnUpdate = actCancelUpdateStatsUpdate
    end
    object actConvertFK: TAction
      Category = 'Main'
      Caption = 'actConvertFK'
      Hint = 'Конвертироват внешние ключи'
      ImageIndex = 175
      OnExecute = actConvertFKExecute
      OnUpdate = actConvertFKUpdate
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcFKManager
  end
  object gdcFKManager: TgdcFKManager
    Left = 182
    Top = 187
  end
end
