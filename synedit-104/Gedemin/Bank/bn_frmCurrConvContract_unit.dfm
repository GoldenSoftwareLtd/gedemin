inherited bn_frmCurrConvContract: Tbn_frmCurrConvContract
  Left = 398
  Top = 206
  Caption = 'Контракт на конвертацию валюты'
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    Left = 85
    Top = 85
  end
  inherited pmMain: TPopupMenu
    Left = 145
    Top = 85
  end
  inherited dsMain: TDataSource
    DataSet = gdcCurrConvContract
    Left = 115
    Top = 85
  end
  object gdcCurrConvContract: TgdcCurrConvContract
    CachedUpdates = False
    Left = 175
    Top = 85
  end
end
