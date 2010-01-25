inherited gdc_frmMetal: Tgdc_frmMetal
  Left = 296
  Top = 234
  HelpContext = 46
  Caption = 'Драгоценные металлы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    Left = 85
  end
  inherited pmMain: TPopupMenu
    Left = 175
    Top = 80
  end
  inherited dsMain: TDataSource
    DataSet = gdcMetal
    Left = 145
    Top = 80
  end
  object gdcMetal: TgdcMetal
    Left = 115
    Top = 80
  end
end
