inherited gdc_flt_frmMain: Tgdc_flt_frmMain
  Left = 246
  Top = 185
  Width = 696
  Height = 488
  Caption = 'gdc_flt_frmMain'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 430
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 370
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 370
  end
  inherited TBDockBottom: TTBDock
    Top = 421
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 378
    inherited sMasterDetail: TSplitter
      Width = 670
    end
    inherited spChoose: TSplitter
      Top = 273
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      inherited ibgrMain: TgsIBGrid
        Width = 510
      end
    end
    inherited pnChoose: TPanel
      Top = 279
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
      inherited pnlChooseCaption: TPanel
        Width = 670
      end
    end
    inherited pnlDetail: TPanel
      Width = 670
      Height = 100
      inherited TBDockDetail: TTBDock
        Width = 670
      end
      inherited pnlSearchDetail: TPanel
        Height = 74
        inherited sbSearchDetail: TScrollBox
          Height = 47
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 510
        Height = 74
      end
    end
  end
  object gdcComponentFilter: TgdcComponentFilter
    Left = 224
    Top = 168
  end
  object gdcSavedFilter: TgdcSavedFilter
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'ComponentKey'
    SubSet = 'ByComponentFilter'
    Left = 368
    Top = 304
  end
end
