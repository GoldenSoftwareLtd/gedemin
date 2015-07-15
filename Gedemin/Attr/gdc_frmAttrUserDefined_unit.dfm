inherited gdc_frmAttrUserDefined: Tgdc_frmAttrUserDefined
  Left = 165
  Top = 60
  Height = 433
  Caption = 'Таблица пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 374
  end
  inherited TBDockLeft: TTBDock
    Height = 323
  end
  inherited TBDockRight: TTBDock
    Height = 323
  end
  inherited TBDockBottom: TTBDock
    Top = 393
  end
  inherited pnlWorkArea: TPanel
    Height = 323
    inherited spChoose: TSplitter
      Top = 220
    end
    inherited pnlMain: TPanel
      Height = 220
      inherited pnlSearchMain: TPanel
        Height = 220
        inherited sbSearchMain: TScrollBox
          Height = 193
          Anchors = [akLeft, akTop]
        end
      end
      inherited ibgrMain: TgsIBGrid
        Height = 220
      end
    end
    inherited pnChoose: TPanel
      Top = 224
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
