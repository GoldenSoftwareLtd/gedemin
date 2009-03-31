inherited gdc_flt_frmMain: Tgdc_flt_frmMain
  Left = 246
  Top = 185
  Width = 696
  Height = 480
  Caption = 'gdc_flt_frmMain'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 434
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 376
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 376
  end
  inherited TBDockBottom: TTBDock
    Top = 425
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 376
    inherited sMasterDetail: TSplitter
      Width = 670
    end
    inherited spChoose: TSplitter
      Top = 274
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      inherited ibgrMain: TgsIBGrid
        Width = 510
      end
    end
    inherited pnChoose: TPanel
      Top = 277
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
    end
    inherited pnlDetail: TPanel
      Width = 670
      Height = 103
      inherited TBDockDetail: TTBDock
        Width = 668
      end
      inherited pnlSearchDetail: TPanel
        Height = 75
        inherited sbSearchDetail: TScrollBox
          Height = 45
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 45
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 508
        Height = 75
      end
    end
  end
  object gdcComponentFilter: TgdcComponentFilter
    CachedUpdates = False
    Left = 224
    Top = 168
  end
  object gdcSavedFilter: TgdcSavedFilter
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'ComponentKey'
    SubSet = 'ByComponentFilter'
    CachedUpdates = False
    Left = 368
    Top = 304
  end
end
