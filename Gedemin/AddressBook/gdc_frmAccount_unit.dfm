inherited gdc_frmAccount: Tgdc_frmAccount
  Left = 174
  Top = 106
  Width = 696
  Height = 480
  Caption = '��������� (����������) �����'
  OldCreateOrder = False
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
          Height = 240
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 267
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
  end
  object gdcAccount: TgdcAccount
    Left = 328
    Top = 216
  end
end
