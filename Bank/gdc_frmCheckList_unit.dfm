inherited gdc_frmCheckList: Tgdc_frmCheckList
  Left = 77
  Top = 71
  Caption = 'Реестр чеков'
  PixelsPerInch = 96
  TextHeight = 13
  inherited dsMain: TDataSource
    DataSet = gdcCheckList
  end
  object gdcCheckList: TgdcCheckList [9]
    Transaction = SelfTransaction
    SubSet = 'ByAccount'
    CachedUpdates = False
    ReadTransaction = SelfTransaction
    DetailObject = gdcCheckListLine
    Left = 145
    Top = 80
  end
  object gdcCheckListLine: TgdcCheckListLine [10]
    Transaction = SelfTransaction
    MasterSource = dsMain
    MasterField = 'documentkey'
    DetailField = 'checklistkey'
    SubSet = 'ByCheckList'
    CachedUpdates = False
    ReadTransaction = SelfTransaction
    Left = 380
    Top = 230
  end
  inherited dsDetail: TDataSource
    DataSet = gdcCheckListLine
  end
end
