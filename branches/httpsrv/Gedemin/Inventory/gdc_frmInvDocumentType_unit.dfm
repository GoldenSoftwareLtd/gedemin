inherited gdc_frmInvDocumentType: Tgdc_frmInvDocumentType
  Left = 315
  Top = 190
  Height = 447
  Caption = 'Типовые складские документы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 392
  end
  inherited TBDockLeft: TTBDock
    Height = 343
  end
  inherited TBDockRight: TTBDock
    Height = 343
  end
  inherited TBDockBottom: TTBDock
    Top = 411
  end
  inherited pnlWorkArea: TPanel
    Height = 343
    inherited spChoose: TSplitter
      Top = 241
    end
    inherited pnlMain: TPanel
      Height = 241
      inherited pnlSearchMain: TPanel
        Height = 241
        inherited sbSearchMain: TScrollBox
          Height = 203
        end
        inherited pnlSearchMainButton: TPanel
          Top = 203
        end
      end
      inherited ibgrMain: TgsIBGrid
        Height = 241
      end
    end
    inherited pnChoose: TPanel
      Top = 244
    end
  end
  inherited pmMain: TPopupMenu
    Left = 113
    Top = 109
  end
  inherited dsMain: TDataSource
    DataSet = gdcDocumentType
    Top = 109
  end
  object gdcDocumentType: TgdcInvDocumentType
    Left = 113
    Top = 80
  end
end
