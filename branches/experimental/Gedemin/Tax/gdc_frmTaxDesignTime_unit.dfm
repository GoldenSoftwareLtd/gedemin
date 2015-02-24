inherited gdc_frmTaxDesignTime: Tgdc_frmTaxDesignTime
  Left = 148
  Top = 179
  Height = 521
  HelpContext = 14
  Caption = 'Расчет отчетов бухгалтерии'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 447
  end
  inherited TBDockTop: TTBDock
    Height = 77
    inherited tbMainToolbar: TTBToolbar
      inherited tbiEdit: TTBItem
        Visible = False
      end
    end
    inherited tbMainCustom: TTBToolbar
      Left = 0
      Top = 51
      DockPos = 1
      DockRow = 2
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 315
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Action = actCalculate
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 512
      DockPos = 512
    end
  end
  inherited TBDockLeft: TTBDock
    Top = 77
    Height = 361
  end
  inherited TBDockRight: TTBDock
    Top = 77
    Height = 361
  end
  inherited TBDockBottom: TTBDock
    Top = 438
  end
  inherited pnlWorkArea: TPanel
    Top = 77
    Height = 378
    inherited spChoose: TSplitter
      Top = 273
    end
    inherited pnlMain: TPanel
      object Label1: TLabel [0]
        Left = 208
        Top = 48
        Width = 22
        Height = 13
        Caption = 'Тип:'
      end
    end
    inherited pnChoose: TPanel
      Top = 279
    end
    inherited pnlDetail: TPanel
      Height = 100
      inherited pnlSearchDetail: TPanel
        Height = 74
        inherited sbSearchDetail: TScrollBox
          Height = 47
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Height = 74
      end
    end
  end
  inherited alMain: TActionList
    Left = 268
    Top = 208
    inherited actNew: TAction
      Enabled = False
    end
    inherited actEdit: TAction
      Enabled = False
    end
    inherited actDetailNew: TAction
      Enabled = False
    end
    object actCalculate: TAction
      Caption = 'Рассчитать за период'
      Hint = 'Рассчитать за период'
      ImageIndex = 212
      OnExecute = actCalculateExecute
    end
    object actActualPrint: TAction
      Caption = 'Отчеты по текущему бух. отчету'
      Hint = 'Отчеты по текущему бух. отчету'
      ImageIndex = 16
    end
  end
  inherited pmMain: TPopupMenu
    Left = 308
    Top = 204
  end
  inherited dsMain: TDataSource
    DataSet = gdcTaxDesignDate
    Left = 332
    Top = 140
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Left = 233
    Top = 207
  end
  inherited dsDetail: TDataSource
    DataSet = gdcTaxResult
    Left = 312
    Top = 276
  end
  object gdcTaxResult: TgdcTaxResult
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'parent'
    SubSet = 'ByParent'
    Left = 392
    Top = 276
  end
  object gdcTaxDesignDate: TgdcTaxDesignDate
    Left = 401
    Top = 113
  end
  object gdcTaxActual: TgdcTaxActual
    MasterSource = dsMain
    MasterField = 'taxactualkey'
    DetailField = 'id'
    SubSet = 'ByID'
    Left = 489
    Top = 129
  end
end
