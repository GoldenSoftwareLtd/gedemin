inherited gdc_frmCompany: Tgdc_frmCompany
  Left = 236
  Top = 178
  Width = 696
  Height = 480
  Caption = 'Организации'
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
      Height = 273
    end
    inherited spChoose: TSplitter
      Top = 273
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 273
      inherited pnlSearchMain: TPanel
        Height = 273
        inherited sbSearchMain: TScrollBox
          Height = 235
        end
        inherited pnlSearchMainButton: TPanel
          Top = 235
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 273
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
      inherited pnlChooseCaption: TPanel
        Width = 670
      end
    end
    inherited pnlDetail: TPanel
      Width = 500
      Height = 273
      inherited TBDockDetail: TTBDock
        Width = 500
      end
      inherited pnlSearchDetail: TPanel
        Height = 247
        inherited sbSearchDetail: TScrollBox
          Height = 209
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 209
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 340
        Height = 247
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcFolder
  end
  object gdcFolder: TgdcFolder
    Left = 128
    Top = 216
  end
  object gdcCompany: TgdcCompany
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB,WithAccount'
    Left = 368
    Top = 224
  end
end
