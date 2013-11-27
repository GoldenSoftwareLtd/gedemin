inherited gdc_frmTrigger: Tgdc_frmTrigger
  Left = 341
  Top = 115
  Height = 495
  HelpContext = 87
  Caption = 'Триггеры'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainCustom: TTBToolbar
      Images = dmImages.ilToolBarSmall
      object tbiSync: TTBItem
        Action = actSync
      end
    end
  end
  inherited alMain: TActionList
    inherited actMacros: TAction
      Visible = False
    end
    object actSync: TAction
      Category = 'Commands'
      Caption = 'actSync'
      Hint = 'Синхронизировать с базой данных'
      ImageIndex = 29
      OnExecute = actSyncExecute
    end
  end
  object gdcTrigger: TgdcTrigger
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 321
    Top = 257
  end
  object gdcTable: TgdcTable
    Left = 321
    Top = 113
  end
end
