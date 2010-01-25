inherited gdc_frmAttrUserDefined: Tgdc_frmAttrUserDefined
  Left = 165
  Top = 60
  Height = 433
  Caption = 'Таблица пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 378
  end
  inherited TBDockLeft: TTBDock
    Height = 329
  end
  inherited TBDockRight: TTBDock
    Height = 329
  end
  inherited TBDockBottom: TTBDock
    Top = 397
  end
  inherited pnlWorkArea: TPanel
    Height = 329
    inherited spChoose: TSplitter
      Top = 227
    end
    inherited pnlMain: TPanel
      Height = 227
      inherited pnlSearchMain: TPanel
        Height = 227
        inherited sbSearchMain: TScrollBox
          Height = 189
          Anchors = [akLeft, akTop]
        end
        inherited pnlSearchMainButton: TPanel
          Top = 189
        end
      end
      inherited ibgrMain: TgsIBGrid
        Height = 227
      end
    end
    inherited pnChoose: TPanel
      Top = 230
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
