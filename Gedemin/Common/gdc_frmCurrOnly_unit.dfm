inherited gdc_frmCurrOnly: Tgdc_frmCurrOnly
  Left = 693
  Top = 269
  Width = 597
  Height = 400
  Caption = 'Валюты'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 333
    Width = 581
  end
  inherited TBDockTop: TTBDock
    Width = 581
  end
  inherited TBDockLeft: TTBDock
    Height = 282
  end
  inherited TBDockRight: TTBDock
    Left = 572
    Height = 282
  end
  inherited TBDockBottom: TTBDock
    Top = 352
    Width = 581
  end
  inherited pnlWorkArea: TPanel
    Width = 563
    Height = 282
    inherited spChoose: TSplitter
      Top = 179
      Width = 563
    end
    inherited pnlMain: TPanel
      Width = 563
      Height = 179
      inherited pnlSearchMain: TPanel
        Height = 179
        inherited sbSearchMain: TScrollBox
          Height = 152
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 403
        Height = 179
      end
    end
    inherited pnChoose: TPanel
      Top = 183
      Width = 563
      inherited pnButtonChoose: TPanel
        Left = 458
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 458
      end
      inherited pnlChooseCaption: TPanel
        Width = 563
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcCurr
  end
  object gdcCurr: TgdcCurr
    Left = 176
    Top = 112
  end
end
