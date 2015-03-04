inherited gdc_frmMDV: Tgdc_frmMDV
  Top = 143
  Width = 634
  Height = 572
  Caption = 'gdc_frmMDV'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 526
    Width = 626
  end
  inherited TBDockTop: TTBDock
    Width = 626
    inherited tbMainToolbar: TTBToolbar
      TabOrder = 1
    end
    inherited tbMainCustom: TTBToolbar
      TabOrder = 2
    end
    inherited tbMainMenu: TTBToolbar
      TabOrder = 0
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 468
  end
  inherited TBDockRight: TTBDock
    Left = 617
    Height = 468
  end
  inherited TBDockBottom: TTBDock
    Top = 517
    Width = 626
  end
  inherited pnlWorkArea: TPanel
    Width = 608
    Height = 468
    inherited sMasterDetail: TSplitter
      Left = 200
      Top = 0
      Width = 6
      Height = 363
      Cursor = crHSplit
      Align = alLeft
    end
    inherited spChoose: TSplitter
      Top = 363
      Width = 608
    end
    inherited pnlMain: TPanel
      Width = 200
      Height = 363
      Align = alLeft
      Constraints.MinHeight = 100
      Constraints.MinWidth = 1
      inherited pnlSearchMain: TPanel
        Height = 363
        inherited sbSearchMain: TScrollBox
          Height = 325
        end
        inherited pnlSearchMainButton: TPanel
          Top = 325
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 369
      Width = 608
      inherited pnButtonChoose: TPanel
        Left = 503
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 503
      end
      inherited pnlChooseCaption: TPanel
        Width = 608
      end
    end
    inherited pnlDetail: TPanel
      Left = 206
      Top = 0
      Width = 402
      Height = 363
      Constraints.MinWidth = 100
      inherited TBDockDetail: TTBDock
        Width = 400
      end
      inherited pnlSearchDetail: TPanel
        Height = 335
        inherited sbSearchDetail: TScrollBox
          Height = 297
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 297
        end
      end
    end
  end
  inherited alMain: TActionList
    Top = 145
  end
  inherited pmMain: TPopupMenu
    Top = 201
  end
  inherited dsMain: TDataSource
    Top = 173
  end
end
