inherited gdc_frmSQLHistory: Tgdc_frmSQLHistory
  Left = 228
  Top = 287
  Width = 1030
  Height = 640
  Caption = 'gdc_frmSQLHistory'
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 594
    Width = 1022
  end
  inherited TBDockTop: TTBDock
    Width = 1022
    inherited tbMainCustom: TTBToolbar
      object tbiTrace: TTBControlItem
        Control = chbxTrace
      end
      object tbsTrace: TTBSeparatorItem
      end
      object tbiRefr: TTBItem
        Action = actRefr
      end
      object tbsRefr: TTBSeparatorItem
      end
      object tbiDeleteHistory: TTBItem
        Action = actDeleteHistory
      end
      object tbiDeleteTraceLog: TTBItem
        Action = actDeleteTraceLog
      end
      object chbxTrace: TCheckBox
        Left = 0
        Top = 2
        Width = 145
        Height = 17
        Action = actEnableTrace
        TabOrder = 0
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 536
  end
  inherited TBDockRight: TTBDock
    Left = 1013
    Height = 536
  end
  inherited TBDockBottom: TTBDock
    Top = 585
    Width = 1022
  end
  inherited pnlWorkArea: TPanel
    Width = 1004
    Height = 536
    inherited spChoose: TSplitter
      Top = 433
      Width = 1004
    end
    inherited pnlMain: TPanel
      Width = 1004
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
        Width = 844
        Height = 433
        ScaleColumns = True
      end
    end
    inherited pnChoose: TPanel
      Top = 437
      Width = 1004
      inherited pnButtonChoose: TPanel
        Left = 899
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 899
      end
      inherited pnlChooseCaption: TPanel
        Width = 1004
      end
    end
  end
  inherited alMain: TActionList
    object actEnableTrace: TAction
      Caption = 'Включить трассировку'
      OnExecute = actEnableTraceExecute
    end
    object actDeleteTraceLog: TAction
      Caption = 'Очистить журнал трассировки'
      ImageIndex = 117
      OnExecute = actDeleteTraceLogExecute
    end
    object actDeleteHistory: TAction
      Caption = 'Удалить историю'
      ImageIndex = 117
      OnExecute = actDeleteHistoryExecute
    end
    object actRefr: TAction
      Caption = 'Обновить'
      ImageIndex = 17
      OnExecute = actRefrExecute
      OnUpdate = actRefrUpdate
    end
  end
  object gdcSQLHistory: TgdcSQLHistory
    Left = 416
    Top = 296
  end
end
