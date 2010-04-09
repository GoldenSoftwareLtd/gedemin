inherited gdc_frmInvPriceList: Tgdc_frmInvPriceList
  Left = 117
  Top = 63
  Caption = 'Прайс-лист'
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    Top = 79
  end
  inherited pmMain: TPopupMenu
    Left = 114
    Top = 109
  end
  inherited dsMain: TDataSource
    DataSet = gdcInvPriceList
    Top = 109
  end
  inherited dsDetail: TDataSource
    DataSet = gdcInvPriceListLine
    Left = 409
    Top = 296
  end
  inherited pmDetail: TPopupMenu
    Left = 439
    Top = 296
  end
  object gdcInvPriceList: TgdcInvPriceList
    CachedUpdates = False
    Left = 114
    Top = 79
  end
  object gdcInvPriceListLine: TgdcInvPriceListLine
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'PARENT'
    SubSet = 'ByParent'
    CachedUpdates = False
    Left = 409
    Top = 267
  end
end
