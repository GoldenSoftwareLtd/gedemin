inherited gdc_frmLink: Tgdc_frmLink
  Left = 271
  Top = 236
  Width = 696
  Height = 420
  Caption = 'Прикрепления'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 361
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 310
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 310
  end
  inherited TBDockBottom: TTBDock
    Top = 380
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 310
    inherited spChoose: TSplitter
      Top = 207
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 207
      inherited pnlSearchMain: TPanel
        Height = 207
        inherited sbSearchMain: TScrollBox
          Height = 180
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 207
      end
    end
    inherited pnChoose: TPanel
      Top = 211
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
