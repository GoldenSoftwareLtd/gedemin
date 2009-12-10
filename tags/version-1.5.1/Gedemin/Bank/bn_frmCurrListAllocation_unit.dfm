inherited bn_frmCurrListAllocation: Tbn_frmCurrListAllocation
  Left = 211
  Top = 180
  Caption = 'Реестр распределения валюты'
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    Left = 90
  end
  inherited pmMain: TPopupMenu
    Left = 150
    Top = 80
  end
  inherited dsMain: TDataSource
    DataSet = gdcCurrListAllocation
    Left = 120
    Top = 80
  end
  object gdcCurrListAllocation: TgdcCurrListAllocation
    CachedUpdates = False
    Left = 180
    Top = 80
  end
end
