inherited gdc_frmAcctTransaction: Tgdc_frmAcctTransaction
  Left = 358
  Top = 68
  Caption = 'Типовые операции'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlWorkArea: TPanel
    inherited sMasterDetail: TSplitter
      Left = 200
    end
    inherited pnlMain: TPanel
      Width = 200
      inherited tvGroup: TgsDBTreeView
        Width = 40
      end
    end
    inherited pnlDetail: TPanel
      Left = 206
      Width = 572
      inherited TBDockDetail: TTBDock
        Width = 572
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 412
      end
    end
  end
  inherited alMain: TActionList
    Top = 141
  end
  inherited pmMain: TPopupMenu
    Left = 115
    Top = 174
  end
  inherited dsMain: TDataSource
    DataSet = gdcAcctTransaction
    Left = 83
  end
  inherited dsDetail: TDataSource
    DataSet = gdcAcctTransactionEntry
    Left = 412
  end
  inherited pmDetail: TPopupMenu
    Left = 444
    Top = 300
  end
  object gdcAcctTransaction: TgdcAcctTransaction
    SubSet = 'ByCompany'
    Left = 116
    Top = 141
  end
  object gdcAcctTransactionEntry: TgdcAcctTransactionEntry
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'TransactionKey'
    SubSet = 'ByTransaction'
    Left = 373
    Top = 188
  end
end
