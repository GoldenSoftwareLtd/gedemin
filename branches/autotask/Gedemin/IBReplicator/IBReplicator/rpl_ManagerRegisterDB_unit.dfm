object frmManagerRegisterDB: TfrmManagerRegisterDB
  Left = 210
  Top = 171
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = #1052#1077#1085#1077#1076#1078#1077#1088' '#1088#1077#1075#1080#1089#1090#1088#1072#1094#1080#1080' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1081
  ClientHeight = 453
  ClientWidth = 678
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 0
    Top = 26
    Width = 678
    Height = 3
    Align = alTop
    Shape = bsTopLine
  end
  object Splitter1: TSplitter
    Left = 265
    Top = 29
    Height = 394
    AutoSnap = False
    ResizeStyle = rsUpdate
  end
  object Panel1: TPanel
    Left = 0
    Top = 423
    Width = 678
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    DesignSize = (
      678
      30)
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 678
      Height = 3
      Align = alTop
      Shape = bsTopLine
    end
    object XPButton1: TXPButton
      Left = 605
      Top = 9
      Height = 21
      Action = actCancel
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object XPButton2: TXPButton
      Left = 527
      Top = 9
      Height = 21
      Action = actOk
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
    object XPButton3: TXPButton
      Left = 2
      Top = 9
      Height = 21
      Action = actHelp
      TabOrder = 2
    end
  end
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 678
    Height = 26
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      Caption = 'TBToolbar1'
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object TBItem3: TTBItem
        Action = actRegisterDB
      end
      object TBItem2: TTBItem
        Action = actUnregisterDB
      end
      object TBItem1: TTBItem
        Action = actCopyInfo
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem4: TTBItem
        Action = actSave
      end
    end
  end
  object tvDB: TXPTreeView
    Left = 0
    Top = 29
    Width = 265
    Height = 394
    Align = alLeft
    Ctl3D = True
    HideSelection = False
    Indent = 19
    ParentCtl3D = False
    RowSelect = True
    ShowButtons = False
    ShowLines = False
    ShowRoot = False
    TabOrder = 2
    WithCheck = False
    OnChange = tvDBChange
    OnChanging = tvDBChanging
    OnEdited = tvDBEdited
  end
  object Panel2: TPanel
    Left = 268
    Top = 29
    Width = 410
    Height = 394
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinWidth = 410
    Enabled = False
    TabOrder = 3
    DesignSize = (
      410
      394)
    object Bevel3: TBevel
      Left = 0
      Top = 0
      Width = 3
      Height = 394
      Align = alLeft
      Shape = bsLeftLine
    end
    object Label2: TLabel
      Left = 8
      Top = 0
      Width = 79
      Height = 13
      Caption = #1048#1084#1103' '#1089#1077#1088#1074#1077#1088#1072
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object Label3: TLabel
      Left = 264
      Top = 1
      Width = 58
      Height = 13
      Caption = #1055#1088#1086#1090#1086#1082#1086#1083
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 8
      Top = 40
      Width = 115
      Height = 13
      Caption = #1060#1072#1081#1083' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 8
      Top = 81
      Width = 146
      Height = 13
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 8
      Top = 125
      Width = 86
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Label8: TLabel
      Left = 49
      Top = 149
      Width = 45
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1072#1088#1086#1083#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Label28: TLabel
      Left = 29
      Top = 173
      Width = 65
      Height = 13
      Alignment = taRightJustify
      Caption = #1050#1086#1076#1080#1088#1086#1074#1082#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Label9: TLabel
      Left = 69
      Top = 197
      Width = 25
      Height = 13
      Alignment = taRightJustify
      Caption = #1056#1086#1083#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
    object Label7: TLabel
      Left = 246
      Top = 125
      Width = 148
      Height = 13
      Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
    object cbServerName: TXPComboBox
      Left = 8
      Top = 15
      Width = 241
      Height = 21
      Color = clWhite
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnDropDown = cbServerNameDropDown
    end
    object cbProtocol: TXPComboBox
      Left = 265
      Top = 15
      Width = 142
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Color = clWhite
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        'TCP/IP'
        'Local')
    end
    object cePath: TXPEdit
      Left = 8
      Top = 53
      Width = 378
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ShowHint = True
      TabOrder = 2
    end
    object XPButton4: TXPButton
      Left = 386
      Top = 53
      Width = 21
      Height = 21
      Action = actOpenDBFile
      Anchors = [akTop, akRight]
      ImageList = dmImages.il16x16
      ShowHint = True
      TabOrder = 3
    end
    object eDBDescription: TXPEdit
      Left = 8
      Top = 95
      Width = 399
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
    end
    object eUser: TXPEdit
      Left = 104
      Top = 121
      Width = 129
      Height = 21
      TabOrder = 5
    end
    object ePassword: TXPEdit
      Left = 104
      Top = 145
      Width = 129
      Height = 21
      PasswordChar = '*'
      TabOrder = 6
    end
    object cbCharSet: TXPComboBox
      Left = 104
      Top = 169
      Width = 129
      Height = 21
      Style = csDropDownList
      Color = clWhite
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 7
      Items.Strings = (
        'NONE'
        'OCTETS'
        'ASCII'
        'UNICODE_FSS'
        'SJIS_0208'
        'EUCJ_0208'
        'DOS437'
        'DOS850'
        'DOS865'
        'ISO8859_1'
        'ISO8859_2'
        'DOS852'
        'DOS857'
        'DOS860'
        'DOS861'
        'DOS863'
        'CYRL'
        'WIN1250'
        'WIN1251'
        'WIN1252'
        'WIN1253'
        'WIN1254'
        'NEXT'
        'KSC_5601'
        'BIG_5'
        'GB_2312')
    end
    object eRole: TXPEdit
      Left = 104
      Top = 193
      Width = 129
      Height = 21
      TabOrder = 8
    end
    object mAddiditionParam: TXPMemo
      Left = 248
      Top = 140
      Width = 159
      Height = 74
      Anchors = [akLeft, akTop, akRight]
      ParentCtl3D = False
      TabOrder = 9
    end
    object Button5: TXPButton
      Left = 260
      Top = 225
      Width = 147
      Height = 21
      Action = actTestConnect
      TabOrder = 10
    end
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 256
    Top = 280
    object actOk: TAction
      Caption = #1054#1050
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = #1054#1090#1084#1077#1085#1072
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = #1057#1087#1088#1072#1074#1082#1072
    end
    object actTestConnect: TAction
      Caption = #1058#1077#1089#1090#1086#1074#1086#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1080#1077
      OnExecute = actTestConnectExecute
    end
    object actOpenDBFile: TAction
      Hint = #1059#1082#1072#1079#1072#1090#1100' '#1087#1091#1090#1100' '#1082' '#1073#1072#1079#1077
      ImageIndex = 27
      OnExecute = actOpenDBFileExecute
    end
    object actRegisterDB: TAction
      Caption = #1047#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1090#1100
      Hint = #1047#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1090#1100' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      ImageIndex = 247
      OnExecute = actRegisterDBExecute
    end
    object actCopyInfo: TAction
      Caption = 'actCopyInfo'
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1082#1086#1087#1080#1102' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
      ImageIndex = 248
      OnExecute = actCopyInfoExecute
      OnUpdate = actCopyInfoUpdate
    end
    object actUnregisterDB: TAction
      Caption = 'actUnregisterDB'
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      ImageIndex = 246
      OnExecute = actUnregisterDBExecute
      OnUpdate = actUnregisterDBUpdate
    end
    object actSave: TAction
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      ImageIndex = 25
      OnExecute = actSaveExecute
      OnUpdate = actSaveUpdate
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '*.gdb;*fdb'
    Filter = #1041#1072#1079#1099' '#1076#1072#1085#1085#1099#1093'|*.gdb; *.fdb|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Title = #1059#1082#1072#1078#1080#1090#1077' '#1073#1072#1079#1091' '#1076#1072#1085#1085#1099#1093
    Left = 288
    Top = 280
  end
end
