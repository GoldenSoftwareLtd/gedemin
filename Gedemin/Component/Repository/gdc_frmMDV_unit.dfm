inherited gdc_frmMDV: Tgdc_frmMDV
  Left = 433
  Top = 147
  Width = 634
  Height = 572
  Caption = 'gdc_frmMDV'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 514
    Width = 618
  end
  inherited TBDockTop: TTBDock
    Width = 618
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
    Height = 454
  end
  inherited TBDockRight: TTBDock
    Left = 609
    Height = 454
  end
  inherited TBDockBottom: TTBDock
    Top = 505
    Width = 618
  end
  inherited pnlWorkArea: TPanel
    Width = 600
    Height = 454
    inherited sMasterDetail: TSplitter
      Left = 200
      Top = 0
      Width = 6
      Height = 349
      Cursor = crHSplit
      Align = alLeft
    end
    inherited spChoose: TSplitter
      Top = 349
      Width = 600
    end
    inherited pnlMain: TPanel
      Width = 200
      Height = 349
      Align = alLeft
      Constraints.MinHeight = 100
      Constraints.MinWidth = 1
      inherited pnlSearchMain: TPanel
        Height = 349
        inherited sbSearchMain: TScrollBox
          Height = 322
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 355
      Width = 600
      inherited pnButtonChoose: TPanel
        Left = 495
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 495
      end
      inherited pnlChooseCaption: TPanel
        Width = 600
      end
    end
    inherited pnlDetail: TPanel
      Left = 206
      Top = 0
      Width = 394
      Height = 349
      Constraints.MinWidth = 100
      inherited TBDockDetail: TTBDock
        Width = 392
      end
      inherited pnlSearchDetail: TPanel
        Height = 321
        inherited sbSearchDetail: TScrollBox
          Height = 294
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
