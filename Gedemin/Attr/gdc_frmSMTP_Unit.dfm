inherited gdc_frmSMTP: Tgdc_frmSMTP
  Left = 263
  Top = 124
  Width = 928
  Height = 480
  Caption = 'gdc_frmSMTP'
  Font.Name = 'Tahoma'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 414
    Width = 912
  end
  inherited TBDockTop: TTBDock
    Width = 912
  end
  inherited TBDockLeft: TTBDock
    Height = 363
  end
  inherited TBDockRight: TTBDock
    Left = 903
    Height = 363
  end
  inherited TBDockBottom: TTBDock
    Top = 433
    Width = 912
  end
  inherited pnlWorkArea: TPanel
    Width = 894
    Height = 363
    inherited spChoose: TSplitter
      Top = 260
      Width = 894
    end
    inherited pnlMain: TPanel
      Width = 894
      Height = 260
      inherited pnlSearchMain: TPanel
        Height = 260
        inherited sbSearchMain: TScrollBox
          Height = 233
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 734
        Height = 260
      end
    end
    inherited pnChoose: TPanel
      Top = 264
      Width = 894
      inherited pnButtonChoose: TPanel
        Left = 789
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 789
      end
      inherited pnlChooseCaption: TPanel
        Width = 894
      end
    end
  end
  object gdcSMTP: TgdcSMTP
    Left = 177
    Top = 131
  end
end
