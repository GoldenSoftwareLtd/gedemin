object frmViewRPLFile: TfrmViewRPLFile
  Left = 130
  Top = 138
  Width = 835
  Height = 530
  Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1092#1072#1081#1083#1072' '#1088#1077#1087#1083#1080#1082#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object spl: TSplitter
    Left = 545
    Top = 29
    Height = 455
    Align = alRight
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 827
    Height = 29
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      827
      29)
    object cmbFileName: TXPComboBox
      Left = 4
      Top = 4
      Width = 571
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        ' ')
    end
    object btnOpen: TXPButton
      Left = 576
      Top = 4
      Width = 23
      Height = 21
      Action = actSelectFile
      Anchors = [akTop, akRight]
      ImageList = dmImages.il16x16
      TabOrder = 1
    end
    object btnClose: TXPButton
      Left = 749
      Top = 4
      Height = 21
      Action = actClose
      Anchors = [akTop, akRight]
      TabOrder = 2
    end
    object XPButton1: TXPButton
      Left = 600
      Top = 4
      Width = 23
      Height = 21
      Action = actViewRPL
      Anchors = [akTop, akRight]
      ImageList = dmImages.il16x16
      TabOrder = 3
    end
    object chkData: TXPCheckBox
      Left = 630
      Top = 6
      Width = 116
      Alignment = taLeft
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1076#1072#1085#1085#1099#1077
      Checked = False
      OnClick = chkDataClick
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 484
    Width = 827
    Height = 19
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      827
      19)
    object lLog: TLabel
      Left = 4
      Top = 4
      Width = 110
      Height = 13
      Caption = #1061#1086#1076' '#1086#1073#1088#1072#1073#1086#1090#1082#1080' '#1092#1072#1081#1083#1072
    end
    object pbProgress: TProgressBar
      Left = 118
      Top = 6
      Width = 706
      Height = 10
      Anchors = [akLeft, akTop, akRight]
      BorderWidth = 1
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 29
    Width = 545
    Height = 455
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Panel3: TPanel
      Left = 0
      Top = 40
      Width = 545
      Height = 415
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      OnResize = FormResize
      object Splitter1: TSplitter
        Left = 0
        Top = 333
        Width = 545
        Height = 3
        Cursor = crVSplit
        Align = alBottom
      end
      object dbgrEvent: TrplDBGrid
        Left = 0
        Top = 0
        Width = 545
        Height = 333
        Align = alClient
        Color = 15921906
        DataSource = dsEvent
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
        OnDblClick = dbgrEventDblClick
      end
      object gbxData: TXPGroupBox
        Left = 0
        Top = 336
        Width = 545
        Height = 79
        Align = alBottom
        BorderColor = clOlive
        Caption = #1044#1072#1085#1085#1099#1077
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13652736
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        Visible = False
        DesignSize = (
          545
          79)
        object dbgrData: TrplDBGrid
          Left = 7
          Top = 14
          Width = 532
          Height = 57
          Anchors = [akLeft, akTop, akRight]
          Color = 15921906
          DataSource = dsData
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = 13652736
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = [fsBold]
          OnDblClick = dbgrEventDblClick
        end
      end
    end
    object XPGroupBox1: TXPGroupBox
      Left = 0
      Top = 0
      Width = 545
      Height = 40
      Align = alTop
      BorderColor = clOlive
      Caption = #1060#1080#1083#1100#1090#1088#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13652736
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      DesignSize = (
        545
        40)
      object lblIndex: TLabel
        Left = 496
        Top = 8
        Width = 44
        Height = 28
        Alignment = taCenter
        Anchors = [akTop, akRight]
        AutoSize = False
        WordWrap = True
      end
      object cmbWhere: TXPComboBox
        Left = 248
        Top = 13
        Width = 263
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          ' ')
      end
      object XPButton2: TXPButton
        Left = 514
        Top = 13
        Width = 25
        Height = 21
        Action = actFilter
        Anchors = [akTop, akRight]
        ImageList = dmImages.il16x16
        TabOrder = 1
      end
      object chkInsert: TXPCheckBox
        Left = 8
        Top = 16
        Width = 54
        Alignment = taLeft
        Caption = 'Insert'
        Checked = True
        State = cbChecked
      end
      object chkUpdate: TXPCheckBox
        Left = 64
        Top = 16
        Width = 61
        Alignment = taLeft
        Caption = 'Update'
        Checked = True
        State = cbChecked
      end
      object chkDelete: TXPCheckBox
        Left = 128
        Top = 16
        Width = 57
        Alignment = taLeft
        Caption = 'Delete'
        Checked = True
        State = cbChecked
      end
      object chkEmpty: TXPCheckBox
        Left = 188
        Top = 16
        Width = 57
        Alignment = taLeft
        Caption = 'Empty'
        Checked = True
        State = cbChecked
      end
    end
  end
  object pnlDBData: TPanel
    Left = 548
    Top = 29
    Width = 279
    Height = 455
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    OnResize = FormResize
    object dbgrDBData: TrplDBGrid
      Left = 0
      Top = 40
      Width = 279
      Height = 415
      Align = alClient
      Color = 15921906
      DataSource = dsDBData
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnDblClick = dbgrDBDataDblClick
    end
    object XPGroupBox2: TXPGroupBox
      Left = 0
      Top = 0
      Width = 279
      Height = 40
      Align = alTop
      BorderColor = clOlive
      Caption = #1060#1080#1083#1100#1090#1088#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13652736
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      DesignSize = (
        279
        40)
      object cmbWhereDB: TXPComboBox
        Left = 5
        Top = 13
        Width = 236
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          ' ')
      end
      object XPButton3: TXPButton
        Left = 246
        Top = 13
        Width = 25
        Height = 21
        Action = actFilterDB
        Anchors = [akTop, akRight]
        ImageList = dmImages.il16x16
        TabOrder = 1
      end
    end
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 448
    Top = 72
    object actClose: TAction
      Caption = #1047#1072#1082#1088#1099#1090#1100
      OnExecute = actCloseExecute
    end
    object actFilter: TAction
      ImageIndex = 20
      OnExecute = actFilterExecute
      OnUpdate = actFilterUpdate
    end
    object actSelectFile: TAction
      ImageIndex = 27
      OnExecute = actSelectFileExecute
    end
    object actViewRPL: TAction
      ImageIndex = 204
      ShortCut = 24662
      OnExecute = actViewRPLExecute
    end
    object actFilterDB: TAction
      ImageIndex = 20
      OnExecute = actFilterDBExecute
      OnUpdate = actFilterUpdate
    end
    object actLoadEList: TAction
      ImageIndex = 27
      OnUpdate = actFilterUpdate
    end
    object actFindNext: TAction
      ImageIndex = 251
      OnUpdate = actFilterUpdate
    end
    object actSaveEList: TAction
      ImageIndex = 25
      OnUpdate = actFilterUpdate
    end
  end
  object cdsEvent: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'fdRelation'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'fdSeqNo'
        DataType = ftInteger
      end
      item
        Name = 'fdType'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'fdTime'
        DataType = ftDateTime
      end
      item
        Name = 'fdOldKey'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'fdNewKey'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'fdID'
        DataType = ftInteger
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    AfterScroll = cdsEventAfterScroll
    Left = 304
    Top = 96
  end
  object dsEvent: TDataSource
    DataSet = cdsEvent
    Left = 168
    Top = 104
  end
  object cdsData: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 296
    Top = 288
  end
  object dsData: TDataSource
    DataSet = cdsData
    Left = 168
    Top = 288
  end
  object ibdsDBData: TIBDataSet
    BufferChunks = 1
    CachedUpdates = False
    Left = 704
    Top = 163
  end
  object dsDBData: TDataSource
    DataSet = ibdsDBData
    Left = 652
    Top = 165
  end
end
