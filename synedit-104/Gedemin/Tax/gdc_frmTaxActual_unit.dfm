inherited gdc_frmTaxActual: Tgdc_frmTaxActual
  Left = 325
  Top = 158
  Height = 503
  HelpContext = 13
  Caption = 'Настройка отчетов бухгалтерии'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 457
  end
  inherited TBDockTop: TTBDock
    Height = 75
    inherited tbMainCustom: TTBToolbar
      Left = 0
      Top = 49
      DockPos = -8
      DockRow = 2
    end
  end
  inherited TBDockLeft: TTBDock
    Top = 75
    Height = 373
  end
  inherited TBDockRight: TTBDock
    Top = 75
    Height = 373
  end
  inherited TBDockBottom: TTBDock
    Top = 448
  end
  inherited pnlWorkArea: TPanel
    Top = 75
    Height = 373
    inherited spChoose: TSplitter
      Top = 271
    end
    inherited pnChoose: TPanel
      Top = 274
    end
    inherited pnlDetail: TPanel
      Height = 100
      inherited pnlSearchDetail: TPanel
        Height = 72
        inherited sbSearchDetail: TScrollBox
          Height = 34
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 34
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Height = 72
      end
    end
  end
  inherited alMain: TActionList
    Left = 108
    Top = 112
    object actActualPrint: TAction
      Category = 'Main'
      Caption = 'Отчеты по текущему актуальному бух. отчету'
      Hint = 'Отчеты по текущему актуальному бух. отчету'
      ImageIndex = 16
    end
  end
  inherited pmMain: TPopupMenu
    Left = 364
    Top = 116
  end
  inherited dsMain: TDataSource
    DataSet = gdcTaxName
    Left = 332
    Top = 116
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Left = 329
    Top = 47
  end
  inherited dsChoose: TDataSource
    Left = 177
    Top = 378
  end
  inherited dsDetail: TDataSource
    DataSet = gdcTaxActual
    Left = 328
    Top = 292
  end
  inherited pmDetail: TPopupMenu
    Left = 400
    Top = 288
  end
  object gdcTaxActual: TgdcTaxActual
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'taxnamekey'
    SubSet = 'ByTax'
    Left = 289
    Top = 289
  end
  object gdcTaxName: TgdcTaxName
    Left = 296
    Top = 120
  end
end
