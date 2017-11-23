inherited gdc_frmDBTrigger: Tgdc_frmDBTrigger
  Left = 432
  Top = 261
  Caption = 'gdc_frmDBTrigger'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainCustom: TTBToolbar
      object TBItem1: TTBItem
        Action = actSync
      end
    end
  end
  inherited alMain: TActionList
    object actSync: TAction
      Category = 'Commands'
      Caption = 'Синхронизировать с БД'
      ImageIndex = 29
      OnExecute = actSyncExecute
    end
  end
  object gdcDBTrigger: TgdcDBTrigger
    SubSet = 'ByDBTriggers'
    Left = 313
    Top = 187
  end
end
