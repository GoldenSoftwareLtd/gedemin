inherited gdc_frmTrigger: Tgdc_frmTrigger
  Left = 341
  Top = 115
  HelpContext = 87
  Caption = '��������'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 437
  end
  inherited TBDockTop: TTBDock
    inherited tbMainCustom: TTBToolbar
      Images = dmImages.ilToolBarSmall
      object tbiSync: TTBItem
        Action = actSync
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 377
  end
  inherited TBDockRight: TTBDock
    Height = 377
  end
  inherited TBDockBottom: TTBDock
    Top = 428
  end
  inherited alMain: TActionList
    inherited actMacros: TAction
      Visible = False
    end
    object actSync: TAction
      Category = 'Commands'
      Caption = 'actSync'
      Hint = '���������������� � ����� ������'
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
