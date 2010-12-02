inherited gd_frmMDV: Tgd_frmMDV
  Left = 196
  Top = 232
  Width = 584
  Height = 271
  Caption = 'gd_frmMDV'
  PixelsPerInch = 96
  TextHeight = 13
  inherited splMain: TSplitter
    Left = 298
    Top = 0
    Width = 3
    Height = 206
    Cursor = crHSplit
    Align = alRight
  end
  inherited sbMain: TStatusBar
    Top = 206
    Width = 576
  end
  inherited pnlDetail: TPanel
    Left = 301
    Top = 0
    Width = 275
    Height = 206
    Align = alRight
    TabOrder = 1
    inherited cbDetail: TControlBar
      Width = 273
      inherited tbDetail: TToolBar
        Width = 260
      end
    end
  end
  inherited pnlMain: TPanel
    Width = 298
    Height = 206
    TabOrder = 0
    inherited cbMain: TControlBar
      Width = 296
      inherited tbMain: TToolBar
        Width = 283
      end
    end
  end
  inherited alMain: TActionList
    Left = 505
  end
end
