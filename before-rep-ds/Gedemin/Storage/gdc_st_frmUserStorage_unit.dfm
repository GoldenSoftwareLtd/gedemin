inherited gdc_st_frmUserStorage: Tgdc_st_frmUserStorage
  Caption = 'Хранилище пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainInvariant: TTBToolbar
      Left = 280
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      Visible = False
    end
    inherited actEdit: TAction
      Visible = False
    end
    inherited actDelete: TAction
      Visible = False
    end
    inherited actDuplicate: TAction
      Visible = False
    end
    inherited actHlp: TAction
      Visible = False
    end
    inherited actPrint: TAction
      Visible = False
    end
    inherited actCut: TAction
      Visible = False
    end
    inherited actCopy: TAction
      Visible = False
    end
    inherited actPaste: TAction
      Visible = False
    end
    inherited actCommit: TAction
      Visible = False
    end
    inherited actMainReduction: TAction
      Visible = False
    end
  end
  object gdcUserStorage: TgdcUserStorage
    CachedUpdates = False
    Left = 377
    Top = 185
  end
end
