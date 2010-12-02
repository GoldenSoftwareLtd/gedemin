inherited gdc_frmBankStatement: Tgdc_frmBankStatement
  Left = 343
  Top = 185
  Height = 495
  Caption = 'Банковская выписка'
  PixelsPerInch = 96
  TextHeight = 13
  inherited gdMacrosMenu: TgdMacrosMenu
    Left = 257
    Top = 135
  end
  inherited dsDetail: TDataSource
    DataSet = gdcBankStatementLine
  end
  object gdcBankStatementLine: TgdcBankStatementLine
    MasterSource = dsMain
    MasterField = 'documentkey'
    DetailField = 'parent'
    SubSet = 'ByParent'
    Left = 436
    Top = 256
  end
end
