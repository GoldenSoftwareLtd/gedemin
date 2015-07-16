inherited gdc_frmMDVGR: Tgdc_frmMDVGR
  Left = 253
  Top = 192
  Width = 649
  Height = 480
  Caption = 'gdc_frmMDVGR'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 430
    Width = 641
  end
  inherited TBDockTop: TTBDock
    Width = 641
  end
  inherited TBDockLeft: TTBDock
    Height = 370
  end
  inherited TBDockRight: TTBDock
    Left = 632
    Height = 370
  end
  inherited TBDockBottom: TTBDock
    Top = 421
    Width = 641
  end
  inherited pnlWorkArea: TPanel
    Width = 623
    Height = 370
    inherited sMasterDetail: TSplitter
      Left = 225
      Top = 0
      Width = 4
      Height = 265
      Cursor = crHSplit
      Align = alLeft
    end
    inherited spChoose: TSplitter
      Top = 265
      Width = 623
    end
    inherited pnlMain: TPanel
      Width = 225
      Height = 265
      Align = alLeft
      Constraints.MinHeight = 100
      Constraints.MinWidth = 1
      inherited pnlSearchMain: TPanel
        Height = 265
        inherited sbSearchMain: TScrollBox
          Height = 238
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 65
        Height = 265
      end
    end
    inherited pnChoose: TPanel
      Top = 271
      Width = 623
      inherited pnButtonChoose: TPanel
        Left = 518
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 518
      end
      inherited pnlChooseCaption: TPanel
        Width = 623
      end
    end
    inherited pnlDetail: TPanel
      Left = 229
      Top = 0
      Width = 394
      Height = 265
      inherited TBDockDetail: TTBDock
        Width = 394
      end
      inherited pnlSearchDetail: TPanel
        Height = 239
        inherited sbSearchDetail: TScrollBox
          Height = 212
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 234
        Height = 239
      end
    end
  end
end
