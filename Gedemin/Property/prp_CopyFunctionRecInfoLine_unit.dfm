object CopyFunctionRecInfoLine: TCopyFunctionRecInfoLine
  Left = 0
  Top = 0
  Width = 443
  Height = 113
  Align = alTop
  AutoSize = True
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 443
    Height = 113
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 3
    Caption = 'Panel1'
    TabOrder = 0
    object stTableName: TStaticText
      Left = 4
      Top = 4
      Width = 435
      Height = 17
      Align = alTop
      Caption = 'stTableName'
      Color = clBackground
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 0
    end
    object DBGrid: TDBGrid
      Left = 4
      Top = 21
      Width = 435
      Height = 88
      Align = alClient
      BorderStyle = bsNone
      DataSource = DataSource
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
  object IBDataSet: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    Left = 56
    Top = 64
  end
  object DataSource: TDataSource
    DataSet = IBDataSet
    Left = 88
    Top = 64
  end
end
