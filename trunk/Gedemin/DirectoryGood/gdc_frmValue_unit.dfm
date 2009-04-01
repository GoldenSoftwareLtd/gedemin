inherited gdc_frmValue: Tgdc_frmValue
  Left = 133
  Top = 101
  HelpContext = 41
  Caption = 'Единицы измерения'
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    Left = 175
    Top = 110
  end
  inherited pmMain: TPopupMenu
    Left = 115
    Top = 110
  end
  inherited dsMain: TDataSource
    DataSet = gdcValue
    Left = 85
    Top = 110
  end
  object gdcValue: TgdcValue
    ModifyFromStream = False
    CachedUpdates = False
    Left = 145
    Top = 110
  end
end
