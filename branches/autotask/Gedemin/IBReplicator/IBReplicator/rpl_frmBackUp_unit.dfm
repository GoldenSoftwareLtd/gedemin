object frmBackup: TfrmBackup
  Left = 379
  Top = 164
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1072#1088#1093#1080#1074#1085#1086#1081' '#1082#1086#1087#1080#1080' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
  ClientHeight = 413
  ClientWidth = 467
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 467
    Height = 26
    Visible = False
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar1'
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object tbiChoosFile: TTBItem
        Action = actSelectArchive
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object tbiCheck: TTBItem
        AutoCheck = True
        Caption = #1055#1088#1086#1074#1077#1088#1103#1090#1100' '#1094#1077#1083#1086#1089#1090#1085#1086#1089#1090#1100' '#1076#1072#1085#1085#1099#1093
        Hint = #1055#1088#1086#1074#1077#1088#1103#1090#1100' '#1094#1077#1083#1086#1089#1090#1085#1086#1089#1090#1100' '#1076#1072#1085#1085#1099#1093
        ImageIndex = 142
      end
      object tbiGarbage: TTBItem
        AutoCheck = True
        Caption = #1057#1073#1086#1088#1082#1072' '#1084#1091#1089#1086#1088#1072
        Hint = #1057#1073#1086#1088#1082#1072' '#1084#1091#1089#1086#1088#1072
        ImageIndex = 197
      end
      object tbiDeleteTemp: TTBItem
        AutoCheck = True
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1088#1077#1084#1077#1085#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
        Hint = #1059#1076#1072#1083#1080#1090#1100' '#1074#1088#1077#1084#1077#1085#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
        ImageIndex = 178
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object tbiVerbose: TTBItem
        AutoCheck = True
        Caption = #1055#1086#1076#1088#1086#1073#1085#1072#1103' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1093#1086#1076#1077' '#1072#1088#1093#1080#1074#1080#1088#1086#1074#1072#1085#1080#1103
        Hint = #1055#1086#1076#1088#1086#1073#1085#1072#1103' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1093#1086#1076#1077' '#1072#1088#1093#1080#1074#1080#1088#1086#1074#1072#1085#1080#1103
        ImageIndex = 141
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object tbiDoIt: TTBItem
        Action = actDoIt
        DisplayMode = nbdmImageAndText
        Hint = #1057#1086#1079#1076#1072#1090#1100
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 26
    Width = 467
    Height = 113
    Align = alTop
    BevelOuter = bvNone
    Constraints.MinWidth = 410
    TabOrder = 1
    DesignSize = (
      467
      113)
    object Label2: TLabel
      Left = 8
      Top = 3
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
    object Label6: TLabel
      Left = 8
      Top = 43
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
    object Bevel3: TBevel
      Left = 0
      Top = 0
      Width = 467
      Height = 4
      Align = alTop
      Shape = bsTopLine
    end
    object edDatabase: TXPEdit
      Left = 8
      Top = 56
      Width = 430
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
    end
    object edServer: TXPEdit
      Left = 8
      Top = 20
      Width = 452
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      ShowHint = True
      TabOrder = 1
    end
    object XPButton2: TXPButton
      Left = 439
      Top = 56
      Width = 21
      Height = 21
      Action = actSelectDataBase
      ImageList = dmImages.il16x16
      ShowHint = True
      TabOrder = 2
    end
    object chbxDeleteTemp: TXPCheckBox
      Left = 268
      Top = 96
      Width = 192
      Alignment = taRight
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1088#1077#1084#1077#1085#1085#1099#1077' '#1076#1072#1085#1085#1099#1077':'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      State = cbChecked
    end
    object chbxGarbage: TXPCheckBox
      Left = 347
      Top = 80
      Width = 113
      Alignment = taRight
      Caption = #1057#1073#1086#1088#1082#1072' '#1084#1091#1089#1086#1088#1072':'
      Checked = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object chbxCheck: TXPCheckBox
      Left = 6
      Top = 80
      Width = 213
      Alignment = taRight
      Caption = #1055#1088#1086#1074#1077#1088#1103#1090#1100' '#1094#1077#1083#1086#1089#1090#1085#1086#1089#1090#1100' '#1076#1072#1085#1085#1099#1093':'
      Checked = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 383
    Width = 467
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 2
    DesignSize = (
      467
      30)
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 467
      Height = 3
      Align = alTop
      Shape = bsTopLine
    end
    object XPButton1: TXPButton
      Left = 386
      Top = 6
      Height = 21
      Action = actClose
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object XPButton3: TXPButton
      Left = 8
      Top = 6
      Height = 21
      Action = actHelp
      TabOrder = 1
    end
    object XPButton5: TXPButton
      Left = 301
      Top = 6
      Width = 81
      Height = 21
      Action = actDoIt
      Anchors = [akTop, akRight]
      ImageList = dmImages.il16x16
      TabOrder = 2
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 191
    Width = 467
    Height = 192
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel3'
    TabOrder = 3
    DesignSize = (
      467
      192)
    object Label1: TLabel
      Left = 6
      Top = 4
      Width = 87
      Height = 13
      Caption = #1061#1086#1076' '#1087#1088#1086#1094#1077#1089#1089#1072':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Bevel2: TBevel
      Left = 0
      Top = 0
      Width = 467
      Height = 3
      Align = alTop
      Shape = bsTopLine
    end
    object mProgress: TXPMemo
      Left = 8
      Top = 21
      Width = 451
      Height = 162
      TabStop = False
      Anchors = [akLeft, akTop, akRight]
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Lines.Strings = (
        #1044#1083#1103' '#1089#1086#1079#1076#1072#1085#1080#1103' '#1072#1088#1093#1080#1074#1072' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093' '#1074#1074#1077#1076#1080#1090#1077' '#1080#1084#1103' '#1072#1088#1093#1080#1074#1085#1086#1075#1086' '#1092#1072#1081#1083#1072'  '
        #1080' '#1085#1072#1078#1084#1080#1090#1077' '#1082#1085#1086#1087#1082#1091' '#1057#1086#1079#1076#1072#1090#1100'.'
        ''
        #1045#1089#1083#1080' '#1085#1077#1086#1073#1093#1086#1076#1080#1084#1086' '#1089#1086#1079#1076#1072#1090#1100' '#1085#1077#1089#1082#1086#1083#1100#1082#1086' '#1072#1088#1093#1080#1074#1085#1099#1093' '#1092#1072#1081#1083#1086#1074', '#1085#1072#1087#1088#1080#1084#1077#1088','
        #1076#1083#1103' '#1079#1072#1087#1080#1089#1080' '#1085#1072' '#1076#1080#1089#1082#1077#1090#1099', '#1091#1082#1072#1078#1080#1090#1077' '#1080#1084#1103' '#1082#1072#1078#1076#1086#1075#1086' '#1080' '#1077#1075#1086' '#1088#1072#1079#1084#1077#1088' '#1074' '#1073#1072#1081#1090#1072#1093
        '('#1076#1086#1083#1078#1085#1086' '#1073#1099#1090#1100' '#1087#1086#1083#1086#1078#1080#1090#1077#1083#1100#1085#1086#1077' '#1094#1077#1083#1086#1077' '#1095#1080#1089#1083#1086' '#1085#1077' '#1084#1077#1085#1100#1096#1077#1077' 2048). '
        #1044#1083#1103' '#1087#1086#1089#1083#1077#1076#1085#1077#1075#1086' '#1092#1072#1081#1083#1072' '#1074' '#1089#1087#1080#1089#1082#1077' '#1088#1072#1079#1084#1077#1088' '#1084#1086#1078#1085#1086' '#1085#1077' '#1079#1072#1076#1072#1074#1072#1090#1100'.'
        ''
        
          #1040#1088#1093#1080#1074#1085#1099#1081' '#1092#1072#1081#1083' '#1089#1086#1079#1076#1072#1077#1090#1089#1103' '#1085#1072' '#1089#1077#1088#1074#1077#1088#1077' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093' '#1074' '#1091#1082#1072#1079#1072#1085#1085#1086#1084' '#1082#1072#1090#1072#1083 +
          #1086#1075#1077'.'
        ''
        
          #1042#1099#1074#1086#1076' '#1087#1086#1076#1088#1086#1073#1085#1086#1081' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080' '#1089#1080#1083#1100#1085#1086' '#1079#1072#1084#1077#1076#1083#1103#1077#1090' '#1087#1088#1086#1094#1077#1089#1089' '#1072#1088#1093#1080#1074#1080#1088#1086#1074#1072#1085#1080 +
          #1103'.')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object chbxVerbose: TXPCheckBox
      Left = 150
      Top = 3
      Width = 308
      Alignment = taRight
      Caption = #1055#1086#1076#1088#1086#1073#1085#1072#1103' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1093#1086#1076#1077' '#1074#1086#1089#1089#1090#1072#1085#1086#1074#1083#1077#1085#1080#1103':'
      Checked = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 139
    Width = 467
    Height = 52
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      467
      52)
    object Label3: TLabel
      Left = 11
      Top = 6
      Width = 106
      Height = 13
      Caption = #1040#1088#1093#1080#1074#1085#1099#1077' '#1092#1072#1081#1083#1099':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Bevel4: TBevel
      Left = 0
      Top = 0
      Width = 467
      Height = 3
      Align = alTop
      Shape = bsTopLine
    end
    object Panel5: TPanel
      Left = 8
      Top = 24
      Width = 452
      Height = 50
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvLowered
      Caption = 'Panel5'
      TabOrder = 0
      object dbgrBackupFiles: TDBGrid
        Left = 1
        Top = 1
        Width = 450
        Height = 48
        Align = alClient
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = 15921906
        Ctl3D = False
        DataSource = dsBackupFiles
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines]
        ParentCtl3D = False
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
        OnExit = dbgrBackupFilesExit
      end
    end
    object XPButton4: TXPButton
      Left = 439
      Top = 3
      Width = 21
      Height = 21
      Action = actSelectArchive
      ImageList = dmImages.il16x16
      ShowHint = True
      TabOrder = 1
    end
  end
  object dsBackupFiles: TDataSource
    DataSet = cdsBackupFiles
    Left = 192
    Top = 176
  end
  object cdsBackupFiles: TClientDataSet
    Active = True
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'cdsBackupFilesField1'
        DataType = ftString
        Size = 200
      end
      item
        Name = 'cdsBackupFilesField2'
        DataType = ftInteger
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 160
    Top = 176
    Data = {
      600000009619E0BD010000001800000002000000000003000000600014636473
      4261636B757046696C65734669656C6431010049000000010005574944544802
      000200C800146364734261636B757046696C65734669656C6432040001000000
      00000000}
    object fldFileName: TStringField
      CustomConstraint = 'x > '#39#39
      ConstraintErrorMessage = #1059#1082#1072#1078#1080#1090#1077' '#1080#1084#1103' '#1092#1072#1081#1083#1072' '#1072#1088#1093#1080#1074#1072
      DisplayLabel = #1048#1084#1103' '#1092#1072#1081#1083#1072
      DisplayWidth = 55
      FieldName = 'cdsBackupFilesField1'
      Size = 200
    end
    object fldFileSize: TIntegerField
      CustomConstraint = '(x is null) or (x >= 2048)'
      ConstraintErrorMessage = #1056#1072#1079#1084#1077#1088' '#1092#1072#1088#1093#1080#1074#1085#1086#1075#1086' '#1092#1072#1081#1083#1072' '#1076#1086#1083#1078#1077#1085' '#1087#1088#1077#1074#1099#1096#1072#1090#1100' 2048 '#1073#1072#1081#1090
      DisplayLabel = #1056#1072#1079#1084#1077#1088' '#1092#1072#1081#1083#1072
      DisplayWidth = 13
      FieldName = 'cdsBackupFilesField2'
    end
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 248
    Top = 176
    object actDoIt: TAction
      Caption = '    '#1057#1086#1079#1076#1072#1090#1100
      ImageIndex = 108
      OnExecute = actDoItExecute
      OnUpdate = actDoItUpdate
    end
    object actClose: TAction
      Caption = #1047#1072#1082#1088#1099#1090#1100
      OnExecute = actCloseExecute
      OnUpdate = actCloseUpdate
    end
    object actHelp: TAction
      Caption = #1057#1087#1088#1072#1074#1082#1072
    end
    object actSelectArchive: TAction
      Hint = #1042#1099#1073#1086#1088' '#1092#1072#1081#1083#1072' '#1072#1088#1093#1080#1074#1085#1086#1081' '#1082#1086#1087#1080#1080
      ImageIndex = 27
      OnExecute = actSelectArchiveExecute
      OnUpdate = actSelectArchiveUpdate
    end
    object actSelectDataBase: TAction
      Hint = #1042#1099#1073#1086#1088' '#1092#1072#1081#1083#1072' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
      ImageIndex = 109
      OnExecute = actSelectDataBaseExecute
    end
  end
  object ibdb: TIBDatabase
    LoginPrompt = False
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 160
    Top = 224
  end
  object ibtr: TIBTransaction
    Active = False
    DefaultDatabase = ibdb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 192
    Top = 224
  end
  object q: TIBSQL
    Database = ibdb
    ParamCheck = True
    Transaction = ibtr
    Left = 224
    Top = 224
  end
  object sd: TSaveDialog
    DefaultExt = 'BK'
    Filter = #1040#1088#1093#1080#1074#1085#1099#1077' '#1092#1072#1081#1083#1099' (*.bk)|*.bk|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #1040#1088#1093#1080#1074' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
    Left = 152
    Top = 296
  end
  object IBBackupService: TIBBackupService
    Protocol = TCP
    LoginPrompt = False
    TraceFlags = []
    BufferSize = 8192
    BlockingFactor = 0
    Options = []
    Left = 248
    Top = 296
  end
  object od: TOpenDialog
    DefaultExt = 'GDB'
    Filter = #1060#1072#1081#1083#1099' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093' (*.gdb, *.fdb)|*.?db|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1060#1072#1081#1083' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
    Left = 192
    Top = 296
  end
end
