inherited gdc_frmAcctLedger: Tgdc_frmAcctLedger
  Left = 360
  Top = 207
  Caption = 'Конфигурации журнал-ордера'
  PixelsPerInch = 96
  TextHeight = 13
  inherited dsMain: TDataSource
    DataSet = gdcAcctLedgerConfig
  end
  object gdcAcctLedgerConfig: TgdcAcctLedgerConfig
    Left = 176
    Top = 160
  end
end
