inherited gdc_frmMDVGR2: Tgdc_frmMDVGR2
  Left = 302
  Top = 183
  Width = 696
  Height = 480
  Caption = 'gdc_frmMDVGR2'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 418
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 369
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 369
  end
  inherited TBDockBottom: TTBDock
    Top = 437
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 369
    inherited sMasterDetail: TSplitter
      Height = 267
    end
    inherited spChoose: TSplitter
      Top = 267
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 267
      inherited pnlSearchMain: TPanel
        Height = 267
        inherited sbSearchMain: TScrollBox
          Height = 237
        end
        inherited pnlSearchMainButton: TPanel
          Top = 237
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 270
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
    end
    inherited pnlDetail: TPanel
      Width = 466
      Height = 267
      inherited TBDockDetail: TTBDock
        Width = 464
      end
      inherited pnlSearchDetail: TPanel
        Height = 239
        inherited sbSearchDetail: TScrollBox
          Height = 209
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 209
        end
      end
    end
  end
end
