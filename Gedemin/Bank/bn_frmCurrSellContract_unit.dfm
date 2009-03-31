inherited bn_frmCurrSellContract: Tbn_frmCurrSellContract
  Left = 280
  Top = 199
  Caption = 'Договора на продажу валюты'
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    Left = 55
    Top = 110
  end
  inherited pmMain: TPopupMenu
    Left = 115
    Top = 110
  end
  inherited dsMain: TDataSource
    DataSet = gdcCurrSellContract
    Left = 85
    Top = 110
  end
  object gdcCurrSellContract: TgdcCurrSellContract
    CachedUpdates = False
    Left = 145
    Top = 110
  end
end
