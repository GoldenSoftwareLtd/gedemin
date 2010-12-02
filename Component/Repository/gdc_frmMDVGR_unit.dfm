inherited gdc_frmMDVGR: Tgdc_frmMDVGR
  Left = 253
  Top = 192
  Width = 649
  Height = 480
  Caption = 'gdc_frmMDVGR'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 434
    Width = 641
  end
  inherited TBDockTop: TTBDock
    Width = 641
  end
  inherited TBDockLeft: TTBDock
    Height = 376
  end
  inherited TBDockRight: TTBDock
    Left = 632
    Height = 376
  end
  inherited TBDockBottom: TTBDock
    Top = 425
    Width = 641
  end
  inherited pnlWorkArea: TPanel
    Width = 623
    Height = 376
    inherited sMasterDetail: TSplitter
      Left = 225
      Top = 0
      Width = 4
      Height = 274
      Cursor = crHSplit
      Align = alLeft
    end
    inherited spChoose: TSplitter
      Top = 274
      Width = 623
    end
    inherited pnlMain: TPanel
      Width = 225
      Height = 274
      Align = alLeft
      Constraints.MinHeight = 100
      Constraints.MinWidth = 1
      inherited pnlSearchMain: TPanel
        Height = 274
        inherited sbSearchMain: TScrollBox
          Height = 236
        end
        inherited pnlSearchMainButton: TPanel
          Top = 236
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 65
        Height = 274
      end
    end
    inherited pnChoose: TPanel
      Top = 277
      Width = 623
      inherited pnButtonChoose: TPanel
        Left = 518
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 518
      end
    end
    inherited pnlDetail: TPanel
      Left = 229
      Top = 0
      Width = 394
      Height = 274
      BevelOuter = bvNone
      inherited TBDockDetail: TTBDock
        Left = 0
        Top = 0
        Width = 394
      end
      inherited pnlSearchDetail: TPanel
        Left = 0
        Top = 26
        Height = 248
        inherited sbSearchDetail: TScrollBox
          Height = 210
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 210
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Left = 160
        Top = 26
        Width = 234
        Height = 248
      end
    end
  end
end
