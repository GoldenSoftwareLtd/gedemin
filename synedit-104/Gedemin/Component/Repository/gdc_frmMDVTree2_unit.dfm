inherited gdc_frmMDVTree2: Tgdc_frmMDVTree2
  Left = 250
  Top = 162
  Width = 696
  Height = 455
  Caption = 'gdc_frmMDVTree2'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 393
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 344
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 344
  end
  inherited TBDockBottom: TTBDock
    Top = 412
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 344
    inherited sMasterDetail: TSplitter
      Height = 242
    end
    inherited spChoose: TSplitter
      Top = 242
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 242
      inherited pnlSearchMain: TPanel
        Height = 242
        inherited sbSearchMain: TScrollBox
          Height = 212
        end
        inherited pnlSearchMainButton: TPanel
          Top = 212
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 245
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
      Height = 242
      inherited TBDockDetail: TTBDock
        Width = 464
      end
      inherited pnlSearchDetail: TPanel
        Height = 214
        inherited sbSearchDetail: TScrollBox
          Height = 184
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 184
        end
      end
    end
  end
end
