inherited gdc_frmPaymentDemand: Tgdc_frmPaymentDemand
  Left = 71
  Top = 118
  Caption = 'Платежные требования'
  PixelsPerInch = 96
  TextHeight = 13
  object gdcPaymentDemand: TgdcPaymentDemand [6]
    CachedUpdates = False
    Left = 145
    Top = 80
  end
  inherited dsMain: TDataSource
    DataSet = gdcPaymentDemand
    Left = 115
  end
  inherited gsTransaction: TgsTransaction
    DocumentType = 800200
    Left = 55
  end
end
