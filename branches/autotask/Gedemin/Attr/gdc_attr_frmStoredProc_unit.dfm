inherited gdc_attr_frmStoredProc: Tgdc_attr_frmStoredProc
  Left = 244
  Top = 103
  Width = 783
  Height = 540
  HelpContext = 78
  Caption = 'Список хранимых процедур'
  Font.Name = 'MS Sans Serif'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 485
    Width = 775
  end
  inherited TBDockTop: TTBDock
    Width = 775
  end
  inherited TBDockLeft: TTBDock
    Height = 436
  end
  inherited TBDockRight: TTBDock
    Left = 766
    Height = 436
  end
  inherited TBDockBottom: TTBDock
    Top = 504
    Width = 775
  end
  inherited pnlWorkArea: TPanel
    Width = 757
    Height = 436
    inherited spChoose: TSplitter
      Top = 334
      Width = 757
    end
    inherited pnlMain: TPanel
      Width = 757
      Height = 334
      inherited pnlSearchMain: TPanel
        Height = 334
        inherited sbSearchMain: TScrollBox
          Height = 296
        end
        inherited pnlSearchMainButton: TPanel
          Top = 296
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 597
        Height = 334
      end
    end
    inherited pnChoose: TPanel
      Top = 337
      Width = 757
      inherited pnButtonChoose: TPanel
        Left = 652
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 652
      end
    end
  end
  object gdcStoredProc: TgdcStoredProc
    Left = 113
    Top = 81
  end
end
