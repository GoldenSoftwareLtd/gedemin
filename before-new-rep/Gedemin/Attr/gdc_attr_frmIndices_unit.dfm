inherited gdc_frmIndices: Tgdc_frmIndices
  Left = 348
  Top = 174
  HelpContext = 85
  Caption = 'Индексы'
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
  object gdcIndex: TgdcIndex
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 337
    Top = 281
  end
  object gdcTable: TgdcTable
    Left = 313
    Top = 121
  end
end
