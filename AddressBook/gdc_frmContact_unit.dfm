inherited gdc_frmContact: Tgdc_frmContact
  Left = 225
  Top = 193
  Width = 696
  Height = 480
  Caption = 'Люди'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 434
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 376
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 376
  end
  inherited TBDockBottom: TTBDock
    Top = 425
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 376
    inherited sMasterDetail: TSplitter
      Height = 274
    end
    inherited spChoose: TSplitter
      Top = 274
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 274
      inherited pnlSearchMain: TPanel
        Height = 274
        inherited sbSearchMain: TScrollBox
          Height = 236
        end
        inherited pnlSearchMainButton: TPanel
          Top = 236
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 274
      end
    end
    inherited pnChoose: TPanel
      Top = 277
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
    end
    inherited pnlDetail: TPanel
      Width = 466
      Height = 274
      inherited TBDockDetail: TTBDock
        Width = 466
      end
      inherited pnlSearchDetail: TPanel
        Height = 248
        inherited sbSearchDetail: TScrollBox
          Height = 210
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 210
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 306
        Height = 248
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcFolder
  end
  inherited dsDetail: TDataSource
    DataSet = gdcContact
  end
  object gdcFolder: TgdcFolder
    Left = 136
    Top = 216
  end
  object gdcContact: TgdcContact
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 392
    Top = 224
  end
end
