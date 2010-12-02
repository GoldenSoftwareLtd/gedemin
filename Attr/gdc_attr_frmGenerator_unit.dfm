inherited gdc_frmGenerator: Tgdc_frmGenerator
  Caption = 'gdc_frmGenerator'
  PixelsPerInch = 96
  TextHeight = 13
  inherited dsMain: TDataSource
    DataSet = gdcGenerator
  end
  object gdcGenerator: TgdcGenerator
    SubSet = 'OnlyAttribute'
    Left = 49
    Top = 113
  end
end
