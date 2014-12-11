inherited gdc_frmRplDatabase2: Tgdc_frmRplDatabase2
  Left = 221
  Top = 139
  Width = 1305
  Height = 675
  Caption = 'gdc_frmRplDatabase2'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 609
    Width = 1289
  end
  inherited TBDockTop: TTBDock
    Width = 1289
  end
  inherited TBDockLeft: TTBDock
    Height = 558
  end
  inherited TBDockRight: TTBDock
    Left = 1280
    Height = 558
  end
  inherited TBDockBottom: TTBDock
    Top = 628
    Width = 1289
  end
  inherited pnlWorkArea: TPanel
    Width = 1271
    Height = 558
    inherited spChoose: TSplitter
      Top = 455
      Width = 1271
    end
    inherited pnlMain: TPanel
      Width = 1271
      Height = 455
      inherited pnlSearchMain: TPanel
        Height = 455
        inherited sbSearchMain: TScrollBox
          Height = 428
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 1111
        Height = 455
      end
    end
    inherited pnChoose: TPanel
      Top = 459
      Width = 1271
      inherited pnButtonChoose: TPanel
        Left = 1166
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 1166
      end
      inherited pnlChooseCaption: TPanel
        Width = 1271
      end
    end
  end
  object gdcRplDatabase2: TgdcRplDatabase2
    Left = 233
    Top = 203
  end
end
