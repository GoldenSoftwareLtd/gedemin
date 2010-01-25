inherited gdc_frmDemandOrder: Tgdc_frmDemandOrder
  Left = 58
  Top = 128
  Caption = 'Платежные требования-поручения'
  PixelsPerInch = 96
  TextHeight = 13
  object gdcDemandOrder: TgdcDemandOrder [7]
    SubSet = 'ByAccount'
    CachedUpdates = False
    Left = 77
    Top = 143
  end
  inherited dsMain: TDataSource
    DataSet = gdcDemandOrder
  end
end
