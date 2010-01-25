inherited gdc_frmInvPriceListType: Tgdc_frmInvPriceListType
  Left = 373
  Top = 199
  Caption = 'Типовые прайс-листы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    inherited actHlp: TAction
      OnExecute = actHlpExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 113
    Top = 109
  end
  inherited dsMain: TDataSource
    DataSet = gdcInvPriceListType
    Top = 109
  end
  object gdcInvPriceListType: TgdcInvPriceListType
    CachedUpdates = False
    Left = 113
    Top = 80
  end
end
