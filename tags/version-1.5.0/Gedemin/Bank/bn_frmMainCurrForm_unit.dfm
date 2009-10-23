inherited bn_frmMainCurrForm: Tbn_frmMainCurrForm
  Left = 245
  Top = 239
  Width = 696
  Height = 480
  Caption = 'bn_frmMainCurrForm'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 427
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
    Top = 418
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 369
    inherited spChoose: TSplitter
      Top = 267
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
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
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 267
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
  end
end
