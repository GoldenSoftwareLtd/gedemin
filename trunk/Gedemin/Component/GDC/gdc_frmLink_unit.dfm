inherited gdc_frmLink: Tgdc_frmLink
  Left = 271
  Top = 236
  Width = 696
  Height = 420
  Caption = 'gdc_frmLink'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 365
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 316
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 316
  end
  inherited TBDockBottom: TTBDock
    Top = 384
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 316
    inherited spChoose: TSplitter
      Top = 213
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 213
      inherited pnlSearchMain: TPanel
        Height = 213
        inherited sbSearchMain: TScrollBox
          Height = 175
        end
        inherited pnlSearchMainButton: TPanel
          Top = 175
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 213
      end
    end
    inherited pnChoose: TPanel
      Top = 217
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
  end
  object gdcLink: TgdcLink
    Left = 320
    Top = 112
  end
end
