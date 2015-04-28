object frmRPLLog: TfrmRPLLog
  Left = 237
  Top = 162
  Width = 518
  Height = 424
  Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1090#1072#1073#1083#1080#1094#1099' '#1080#1079#1084#1077#1085#1077#1085#1080#1081
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object dbgrLog: TrplDBGrid
    Left = 0
    Top = 29
    Width = 510
    Height = 368
    Align = alClient
    Color = 15921906
    DataSource = dsLog
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnDblClick = dbgrLogDblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 510
    Height = 29
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      510
      29)
    object btnClose: TXPButton
      Left = 434
      Top = 4
      Height = 21
      Action = actClose
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object XPButton1: TXPButton
      Left = 187
      Top = 4
      Width = 25
      Height = 21
      Action = actFilter
      Anchors = [akTop, akRight]
      ImageList = dmImages.il16x16
      TabOrder = 1
    end
    object cmbWhere: TXPComboBox
      Left = 4
      Top = 4
      Width = 181
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        ' ')
    end
  end
  object ibdsLog: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    Left = 136
    Top = 64
  end
  object dsLog: TDataSource
    DataSet = ibdsLog
    Left = 224
    Top = 64
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 336
    Top = 136
    object actClose: TAction
      Caption = #1047#1072#1082#1088#1099#1090#1100
      OnExecute = actCloseExecute
    end
    object actFilter: TAction
      ImageIndex = 20
      OnExecute = actFilterExecute
    end
  end
end
