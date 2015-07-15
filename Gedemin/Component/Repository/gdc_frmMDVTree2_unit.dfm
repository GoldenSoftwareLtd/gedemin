inherited gdc_frmMDVTree2: Tgdc_frmMDVTree2
  Left = 250
  Top = 162
  Width = 696
  Height = 455
  Caption = 'gdc_frmMDVTree2'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 396
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 345
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 345
  end
  inherited TBDockBottom: TTBDock
    Top = 415
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 345
    inherited sMasterDetail: TSplitter
      Height = 240
    end
    inherited spChoose: TSplitter
      Top = 240
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 240
      inherited pnlSearchMain: TPanel
        Height = 240
        inherited sbSearchMain: TScrollBox
          Height = 213
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 246
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
      Height = 240
      inherited TBDockDetail: TTBDock
        Width = 462
      end
      inherited pnlSearchDetail: TPanel
        Height = 212
        inherited sbSearchDetail: TScrollBox
          Height = 185
        end
      end
    end
  end
end
