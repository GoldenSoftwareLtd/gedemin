inherited gdc_frmEvent: Tgdc_frmEvent
  Left = 55
  Top = 92
  Caption = 'События'
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
    inherited actDelete: TAction
      Visible = False
    end
    inherited actDuplicate: TAction
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
    inherited actMacros: TAction
      Visible = False
    end
    inherited actMainReduction: TAction
      Visible = False
    end
  end
  object gdcEvent: TgdcEvent
    MasterSource = dsMain
    MasterField = 'lb;rb'
    DetailField = 'lb;rb'
    SubSet = 'ByLBRBObject'
    CachedUpdates = False
    Left = 257
    Top = 209
  end
  object gdcDelphiObject: TgdcDelphiObject
    CachedUpdates = False
    ObjectType = otObject
    Left = 177
    Top = 137
  end
end
