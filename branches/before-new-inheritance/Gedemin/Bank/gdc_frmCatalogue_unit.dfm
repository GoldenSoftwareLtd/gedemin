inherited gdc_frmCatalogue: Tgdc_frmCatalogue
  Left = 301
  Top = 113
  Width = 621
  Caption = 'Банковская картотека'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 448
    Width = 613
  end
  inherited TBDockTop: TTBDock
    Width = 613
    inherited tbMainCustom: TTBToolbar
      Left = 360
      BorderStyle = bsSingle
      inherited ibcmbAccount: TgsIBLookupComboBox
        Left = 210
        Top = 22
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 304
    end
    inherited tbChooseMain: TTBToolbar
      Left = 580
    end
  end
  inherited TBDockRight: TTBDock
    Left = 604
  end
  inherited TBDockBottom: TTBDock
    Top = 467
    Width = 613
  end
  inherited pnlWorkArea: TPanel
    Width = 595
    inherited sMasterDetail: TSplitter
      Width = 595
    end
    inherited spChoose: TSplitter
      Width = 595
    end
    inherited pnlMain: TPanel
      Width = 595
      inherited ibgrMain: TgsIBGrid
        Width = 435
      end
    end
    inherited pnChoose: TPanel
      Width = 595
      inherited pnButtonChoose: TPanel
        Left = 490
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 490
      end
    end
    inherited pnlDetail: TPanel
      Width = 595
      inherited TBDockDetail: TTBDock
        Width = 593
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 433
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcBankCatalogue
  end
  inherited dsDetail: TDataSource
    DataSet = gdcBankCatalogueLine
  end
  object gdcBankCatalogue: TgdcBankCatalogue
    SubSet = 'ByAccount'
    Left = 120
    Top = 124
  end
  object gdcBankCatalogueLine: TgdcBankCatalogueLine
    MasterSource = dsMain
    MasterField = 'documentkey'
    DetailField = 'parent'
    SubSet = 'ByParent'
    Left = 436
    Top = 256
  end
end
