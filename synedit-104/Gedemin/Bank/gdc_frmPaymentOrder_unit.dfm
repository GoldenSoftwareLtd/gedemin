inherited gdc_frmPaymentOrder: Tgdc_frmPaymentOrder
  Left = 271
  Top = 107
  Caption = 'Платежные поручения'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainCustom: TTBToolbar
      Left = 445
      object tbiOptionsExport: TTBItem [0]
        Action = actOptionsExport
      end
      inherited ibcmbAccount: TgsIBLookupComboBox
        Left = 23
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 327
    end
    inherited tbChooseMain: TTBToolbar
      Left = 412
    end
  end
  object gdcPaymentOrder: TgdcPaymentOrder [6]
    CachedUpdates = False
    Left = 145
    Top = 80
  end
  inherited alMain: TActionList
    object actOptionsExport: TAction
      Caption = 'actOptionsExport'
      Hint = 'Настройки импорта'
      ImageIndex = 36
      OnExecute = actOptionsExportExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcPaymentOrder
    Left = 55
  end
end
