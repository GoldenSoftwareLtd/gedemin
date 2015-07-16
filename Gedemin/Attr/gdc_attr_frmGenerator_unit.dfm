inherited gdc_frmGenerator: Tgdc_frmGenerator
  Left = 471
  Top = 100
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
