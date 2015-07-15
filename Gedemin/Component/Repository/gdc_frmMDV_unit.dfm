inherited gdc_frmMDV: Tgdc_frmMDV
  Left = 430
  Top = 145
  Width = 634
  Height = 572
  Caption = 'gdc_frmMDV'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 522
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
    Height = 462
  end
  inherited TBDockRight: TTBDock
    Left = 617
    Height = 462
  end
  inherited TBDockBottom: TTBDock
    Top = 513
    Width = 626
  end
  inherited pnlWorkArea: TPanel
    Width = 608
    Height = 462
    inherited sMasterDetail: TSplitter
      Left = 200
      Top = 0
      Width = 6
      Height = 357
      Cursor = crHSplit
      Align = alLeft
    end
    inherited spChoose: TSplitter
      Top = 357
      Width = 608
    end
    inherited pnlMain: TPanel
      Width = 200
      Height = 357
      Align = alLeft
      Constraints.MinHeight = 100
      Constraints.MinWidth = 1
      inherited pnlSearchMain: TPanel
        Height = 357
        inherited sbSearchMain: TScrollBox
          Height = 330
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 363
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
      Height = 357
      Constraints.MinWidth = 100
      inherited TBDockDetail: TTBDock
        Width = 400
      end
      inherited pnlSearchDetail: TPanel
        Height = 329
        inherited sbSearchDetail: TScrollBox
          Height = 302
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
