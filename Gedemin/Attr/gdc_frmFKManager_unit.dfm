inherited gdc_frmFKManager: Tgdc_frmFKManager
  Left = 305
  Top = 210
  Width = 870
  Height = 640
  Caption = 'gdc_frmFKManager'
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 594
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
        Left = 81
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
    Height = 536
  end
  inherited TBDockRight: TTBDock
    Left = 853
    Height = 536
  end
  inherited TBDockBottom: TTBDock
    Top = 585
    Width = 862
  end
  inherited pnlWorkArea: TPanel
    Width = 844
    Height = 536
    inherited sMasterDetail: TSplitter
      Height = 433
    end
    inherited spChoose: TSplitter
      Top = 433
      Width = 844
    end
    inherited pnlMain: TPanel
      Height = 433
      inherited pnlSearchMain: TPanel
        Height = 433
        inherited sbSearchMain: TScrollBox
          Height = 395
        end
        inherited pnlSearchMainButton: TPanel
          Top = 395
        end
      end
      inherited ibgrMain: TgsIBGrid
        Height = 433
      end
    end
    inherited pnChoose: TPanel
      Top = 437
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
    inherited pnlDetail: TPanel
      Width = 615
      Height = 433
      inherited TBDockDetail: TTBDock
        Width = 615
        inherited tbDetailToolbar: TTBToolbar
          Images = dmImages.il16x16
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 275
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 407
        inherited sbSearchDetail: TScrollBox
          Height = 369
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 369
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 455
        Height = 407
      end
    end
  end
  inherited alMain: TActionList
    object actUpdateStats: TAction
      Category = 'Main'
      Caption = 'Обновить статистику'
      Hint = 'Обновить статистику'
      ImageIndex = 209
      OnExecute = actUpdateStatsExecute
      OnUpdate = actUpdateStatsUpdate
    end
    object actCancelUpdateStats: TAction
      Category = 'Main'
      Caption = 'Прервать обновление статистики'
      Hint = 'Прервать обновление статистики'
      ImageIndex = 207
      OnExecute = actCancelUpdateStatsExecute
      OnUpdate = actCancelUpdateStatsUpdate
    end
    object actConvertFK: TAction
      Category = 'Main'
      Caption = 'actConvertFK'
      ImageIndex = 175
      OnExecute = actConvertFKExecute
      OnUpdate = actConvertFKUpdate
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcFKManager
  end
  inherited dsDetail: TDataSource
    DataSet = gdcFKManagerData
  end
  object gdcFKManager: TgdcFKManager
    Left = 182
    Top = 187
  end
  object gdcFKManagerData: TgdcFKManagerData
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'constraintkey'
    SubSet = 'ByRefConstraint'
    Left = 440
    Top = 248
  end
end
