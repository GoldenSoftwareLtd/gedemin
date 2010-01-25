inherited gdc_frmTaxFunction: Tgdc_frmTaxFunction
  Left = 280
  Top = 138
  Caption = 'gdc_frmTaxFunction'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlWorkArea: TPanel
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailCustom: TTBToolbar
          Images = dmImages.il16x16
          object TBItem1: TTBItem
            Action = actTaxFunction
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    object actTaxFunction: TAction
      Caption = 'Функции'
      ImageIndex = 72
      OnExecute = actTaxFunctionExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcTaxFunction
    Left = 196
    Top = 108
  end
  inherited dsDetail: TDataSource
    Left = 240
    Top = 292
  end
  object gdcTaxFunction: TgdcTaxFunction
    CachedUpdates = False
    Left = 336
    Top = 96
  end
end
