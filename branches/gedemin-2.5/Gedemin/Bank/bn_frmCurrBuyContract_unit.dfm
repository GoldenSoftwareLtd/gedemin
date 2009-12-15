inherited bn_frmCurrBuyContract: Tbn_frmCurrBuyContract
  Left = 56
  Top = 46
  Caption = 'Договор на покупку валюты'
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    Left = 85
    Top = 70
  end
  inherited pmMain: TPopupMenu
    Left = 145
    Top = 70
  end
  inherited dsMain: TDataSource
    DataSet = gdcCurrBuyContract
    Left = 115
    Top = 70
  end
  object gdcCurrBuyContract: TgdcCurrBuyContract
    CachedUpdates = False
    Left = 175
    Top = 70
  end
end
