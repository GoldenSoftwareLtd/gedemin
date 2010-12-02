object FilesFrame: TFilesFrame
  Left = 0
  Top = 0
  Width = 435
  Height = 266
  Align = alClient
  TabOrder = 0
  OnResize = FrameResize
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 416
    Height = 266
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlMain'
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 315
      Top = 0
      Width = 3
      Height = 266
      Cursor = crHSplit
    end
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 315
      Height = 266
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'pnlLeft'
      TabOrder = 0
      object pnlCaptionLeft: TPanel
        Left = 0
        Top = 0
        Width = 315
        Height = 20
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvLowered
        TabOrder = 0
      end
    end
    object pnlRight: TPanel
      Left = 318
      Top = 0
      Width = 98
      Height = 266
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pnlRight'
      TabOrder = 1
      object pnlCaptionRight: TPanel
        Left = 0
        Top = 0
        Width = 98
        Height = 20
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvLowered
        TabOrder = 0
      end
    end
  end
  object pnlDisplay: TPanel
    Left = 416
    Top = 0
    Width = 19
    Height = 266
    Align = alRight
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    Visible = False
    object pbDiffMarker: TPaintBox
      Left = 8
      Top = 2
      Width = 9
      Height = 262
      Align = alClient
      Color = clBtnFace
      ParentColor = False
      OnPaint = pbDiffMarkerPaint
    end
    object pbScrollPosMarker: TPaintBox
      Left = 2
      Top = 2
      Width = 6
      Height = 262
      Align = alLeft
      Color = clBtnFace
      ParentColor = False
      OnPaint = pbScrollPosMarkerPaint
    end
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly]
    Left = 16
    Top = 45
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 47
    Top = 46
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Options = [fdEffects, fdFixedPitchOnly]
    Left = 81
    Top = 46
  end
end
