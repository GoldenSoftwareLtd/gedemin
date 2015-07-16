inherited gdc_frmMDVGR2: Tgdc_frmMDVGR2
  Left = 302
  Top = 183
  Width = 696
  Height = 480
  Caption = 'gdc_frmMDVGR2'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 421
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
    Top = 440
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 370
    inherited sMasterDetail: TSplitter
      Height = 265
    end
    inherited spChoose: TSplitter
      Top = 265
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 265
      inherited pnlSearchMain: TPanel
        Height = 265
        inherited sbSearchMain: TScrollBox
          Height = 238
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 271
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
      Width = 464
      Height = 265
      inherited TBDockDetail: TTBDock
        Width = 462
      end
      inherited pnlSearchDetail: TPanel
        Height = 237
        inherited sbSearchDetail: TScrollBox
          Height = 210
        end
      end
    end
  end
end
