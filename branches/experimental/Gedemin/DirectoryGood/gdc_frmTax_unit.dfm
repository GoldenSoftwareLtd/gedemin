inherited gdc_frmTax: Tgdc_frmTax
  Left = 258
  Top = 145
  HelpContext = 44
  Caption = 'Налоги'
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
    DataSet = gdcTax
    Left = 115
    Top = 85
  end
  object gdcTax: TgdcTax
    ModifyFromStream = False
    CachedUpdates = False
    Left = 175
    Top = 85
  end
end
