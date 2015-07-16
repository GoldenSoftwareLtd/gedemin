inherited gdc_frmCurrOnly: Tgdc_frmCurrOnly
  Left = 693
  Top = 269
  Width = 597
  Height = 400
  Caption = 'Валюты'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 341
    Width = 589
  end
  inherited TBDockTop: TTBDock
    Width = 589
  end
  inherited TBDockLeft: TTBDock
    Height = 290
  end
  inherited TBDockRight: TTBDock
    Left = 580
    Height = 290
  end
  inherited TBDockBottom: TTBDock
    Top = 360
    Width = 589
  end
  inherited pnlWorkArea: TPanel
    Width = 571
    Height = 290
    inherited spChoose: TSplitter
      Top = 187
      Width = 571
    end
    inherited pnlMain: TPanel
      Width = 571
      Height = 187
      inherited pnlSearchMain: TPanel
        Height = 187
        inherited sbSearchMain: TScrollBox
          Height = 160
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 411
        Height = 187
      end
    end
    inherited pnChoose: TPanel
      Top = 191
      Width = 571
      inherited pnButtonChoose: TPanel
        Left = 466
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 466
      end
      inherited pnlChooseCaption: TPanel
        Width = 571
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
