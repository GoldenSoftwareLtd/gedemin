inherited gdc_frmCurrOnly: Tgdc_frmCurrOnly
  Left = 321
  Top = 208
  Width = 597
  Height = 400
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 345
    Width = 589
  end
  inherited TBDockTop: TTBDock
    Width = 589
  end
  inherited TBDockLeft: TTBDock
    Height = 296
  end
  inherited TBDockRight: TTBDock
    Left = 580
    Height = 296
  end
  inherited TBDockBottom: TTBDock
    Top = 364
    Width = 589
  end
  inherited pnlWorkArea: TPanel
    Width = 571
    Height = 296
    inherited spChoose: TSplitter
      Top = 193
      Width = 571
    end
    inherited pnlMain: TPanel
      Width = 571
      Height = 193
      inherited pnlSearchMain: TPanel
        Height = 193
        inherited sbSearchMain: TScrollBox
          Height = 155
        end
        inherited pnlSearchMainButton: TPanel
          Top = 155
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 411
        Height = 193
      end
    end
    inherited pnChoose: TPanel
      Top = 197
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
