inherited bn_frmCurrCommissSell: Tbn_frmCurrCommissSell
  Left = 199
  Top = 161
  Caption = 'Поручение на продажу валюты'
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
    DataSet = gdcCurrCommissSell
    Left = 115
    Top = 85
  end
  object gdcCurrCommissSell: TgdcCurrCommissSell
    CachedUpdates = False
    Left = 175
    Top = 85
  end
end
