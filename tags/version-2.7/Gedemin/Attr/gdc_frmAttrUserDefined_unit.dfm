inherited gdc_frmAttrUserDefined: Tgdc_frmAttrUserDefined
  Left = 165
  Top = 60
  Height = 433
  Caption = 'Таблица пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 367
  end
  inherited TBDockLeft: TTBDock
    Height = 316
  end
  inherited TBDockRight: TTBDock
    Height = 316
  end
  inherited TBDockBottom: TTBDock
    Top = 386
  end
  inherited pnlWorkArea: TPanel
    Height = 316
    inherited spChoose: TSplitter
      Top = 213
    end
    inherited pnlMain: TPanel
      Height = 213
      inherited pnlSearchMain: TPanel
        Height = 213
        inherited sbSearchMain: TScrollBox
          Height = 186
          Anchors = [akLeft, akTop]
        end
      end
      inherited ibgrMain: TgsIBGrid
        Height = 213
      end
    end
    inherited pnChoose: TPanel
      Top = 217
    end
  end
  inherited alMain: TActionList
    Top = 79
  end
  inherited pmMain: TPopupMenu
    Left = 130
  end
  inherited dsMain: TDataSource
    DataSet = gdcAttrUserDefined
  end
  object gdcAttrUserDefined: TgdcAttrUserDefined
    Left = 122
    Top = 79
  end
end
