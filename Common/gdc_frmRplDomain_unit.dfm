inherited gdc_frmRplDomain: Tgdc_frmRplDomain
  Left = 280
  Top = 236
  Width = 870
  Height = 640
  Caption = 'gdc_frmRplDomain'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 594
    Width = 862
  end
  inherited TBDockTop: TTBDock
    Width = 862
  end
  inherited TBDockLeft: TTBDock
    Height = 536
  end
  inherited TBDockRight: TTBDock
    Left = 853
    Height = 536
  end
  inherited TBDockBottom: TTBDock
    Top = 585
    Width = 862
  end
  inherited pnlWorkArea: TPanel
    Width = 844
    Height = 536
    inherited sMasterDetail: TSplitter
      Height = 433
    end
    inherited spChoose: TSplitter
      Top = 433
      Width = 844
    end
    inherited pnlMain: TPanel
      Height = 433
      inherited pnlSearchMain: TPanel
        Height = 433
        inherited sbSearchMain: TScrollBox
          Height = 395
        end
        inherited pnlSearchMainButton: TPanel
          Top = 395
        end
      end
      inherited ibgrMain: TgsIBGrid
        Height = 433
      end
    end
    inherited pnChoose: TPanel
      Top = 437
      Width = 844
      inherited pnButtonChoose: TPanel
        Left = 739
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 739
      end
      inherited pnlChooseCaption: TPanel
        Width = 844
      end
    end
    inherited pnlDetail: TPanel
      Width = 615
      Height = 433
      inherited TBDockDetail: TTBDock
        Width = 615
      end
      inherited pnlSearchDetail: TPanel
        Height = 407
        inherited sbSearchDetail: TScrollBox
          Height = 369
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 369
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 455
        Height = 407
      end
    end
  end
  object gdcRplDomain: TgdcRplDomain
    Left = 160
    Top = 216
  end
  object gdcRplDomainClass: TgdcRplDomainClass
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'DOMAINKEY'
    SubSet = 'ByRplDomain'
    Left = 534
    Top = 249
  end
end
