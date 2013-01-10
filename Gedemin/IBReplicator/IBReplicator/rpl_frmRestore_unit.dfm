object frmRestore: TfrmRestore
  Left = 369
  Top = 187
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = #1042#1086#1089#1089#1090#1072#1085#1086#1074#1083#1077#1085#1080#1077' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093' '#1080#1079' '#1072#1088#1093#1080#1074#1072
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 383
    Width = 467
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
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
    object XPButton2: TXPButton
      Left = 288
      Top = 6
      Width = 89
      Height = 21
      Action = actDoIt
      Anchors = [akTop, akRight]
      Caption = '     '#1042#1099#1087#1086#1083#1085#1080#1090#1100
      ImageList = dmImages.il16x16
      TabOrder = 2
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 226
    Width = 467
    Height = 157
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel3'
    TabOrder = 1
    DesignSize = (
      467
      157)
    object Label1: TLabel
      Left = 8
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
      Width = 450
      Height = 132
      TabStop = False
      Anchors = [akLeft, akTop, akRight, akBottom]
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
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
  object pnlOptions: TPanel
    Left = 0
    Top = 87
    Width = 467
    Height = 139
    Align = alBottom
    BevelOuter = bvNone
    Constraints.MinWidth = 410
    TabOrder = 2
    DesignSize = (
      467
      139)
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
      Top = 42
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
    object Label5: TLabel
      Left = 8
      Top = 83
      Width = 111
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088' '#1089#1090#1088#1072#1085#1080#1094#1099':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 179
      Top = 83
      Width = 152
      Height = 13
      Caption = #1073#1072#1081#1090'.      '#1056#1072#1079#1084#1077#1088' '#1073#1091#1092#1077#1088#1072':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 406
      Top = 83
      Width = 53
      Height = 13
      Caption = #1089#1090#1088#1072#1085#1080#1094'.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edDatabase: TXPEdit
      Left = 8
      Top = 56
      Width = 427
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ShowHint = True
      TabOrder = 0
    end
    object edServer: TXPEdit
      Left = 8
      Top = 18
      Width = 450
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ShowHint = True
      TabOrder = 1
    end
    object edPageSize: TXPComboBox
      Left = 122
      Top = 80
      Width = 54
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Text = '8192'
      Items.Strings = (
        '1024'
        '2048'
        '4096'
        '8192'
        '16384')
    end
    object edPageBuffers: TXPEdit
      Left = 335
      Top = 80
      Width = 67
      Height = 19
      Text = '4096'
      TabOrder = 3
    end
    object chbxOneRelationAtATime: TXPCheckBox
      Left = 254
      Top = 104
      Width = 204
      Alignment = taRight
      Caption = 'Commit '#1087#1086#1089#1083#1077' '#1082#1072#1078#1076#1086#1081' '#1090#1072#1073#1083#1080#1094#1099':'
      Checked = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object chbxOverwrite: TXPCheckBox
      Left = 6
      Top = 104
      Width = 239
      Alignment = taRight
      Caption = #1055#1077#1088#1077#1079#1072#1087#1080#1089#1099#1074#1072#1090#1100' '#1092#1072#1081#1083' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093':'
      Checked = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object XPButton4: TXPButton
      Left = 436
      Top = 56
      Width = 21
      Height = 21
      Action = actSelectDataBase
      ImageList = dmImages.il16x16
      ShowHint = True
      TabOrder = 6
    end
    object chbxRecreateAllUsers: TXPCheckBox
      Left = 256
      Top = 122
      Width = 202
      Alignment = taRight
      Caption = #1055#1077#1088#1077#1089#1086#1079#1076#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081':'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      State = cbChecked
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 467
    Height = 87
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel4'
    TabOrder = 3
    DesignSize = (
      467
      87)
    object Label3: TLabel
      Left = 8
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
      Width = 450
      Height = 56
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvLowered
      Caption = 'Panel5'
      TabOrder = 0
      object dbgrBackupFiles: TDBGrid
        Left = 1
        Top = 1
        Width = 448
        Height = 54
        Align = alClient
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = 15921906
        Ctl3D = False
        DataSource = dsBackupFiles
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = [fsBold]
        Columns = <
          item
            Expanded = False
            FieldName = 'cdsBackupFilesField1'
            Width = 435
            Visible = True
          end>
      end
    end
    object XPButton5: TXPButton
      Left = 436
      Top = 3
      Width = 21
      Height = 21
      Action = actSelectArchive
      ImageList = dmImages.il16x16
      ShowHint = True
      TabOrder = 1
    end
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
    Left = 128
    Top = 272
    Data = {
      600000009619E0BD010000001800000002000000000003000000600014636473
      4261636B757046696C65734669656C6431010049000000010005574944544802
      000200C800146364734261636B757046696C65734669656C6432040001000000
      00000000}
    object fldFileName: TStringField
      CustomConstraint = 'x > '#39#39
      ConstraintErrorMessage = #1059#1082#1072#1078#1080#1090#1077' '#1080#1084#1103' '#1092#1072#1081#1083#1072' '#1072#1088#1093#1080#1074#1072
      DisplayLabel = #1048#1084#1103' '#1092#1072#1081#1083#1072
      DisplayWidth = 53
      FieldName = 'cdsBackupFilesField1'
      Size = 200
    end
    object fldFileSize: TIntegerField
      CustomConstraint = '(x is null) or (x >= 2048)'
      ConstraintErrorMessage = #1056#1072#1079#1084#1077#1088' '#1092#1072#1088#1093#1080#1074#1085#1086#1075#1086' '#1092#1072#1081#1083#1072' '#1076#1086#1083#1078#1077#1085' '#1087#1088#1077#1074#1099#1096#1072#1090#1100' 2048 '#1073#1072#1081#1090
      DisplayLabel = #1056#1072#1079#1084#1077#1088' '#1092#1072#1081#1083#1072
      DisplayWidth = 18
      FieldName = 'cdsBackupFilesField2'
    end
  end
  object dsBackupFiles: TDataSource
    DataSet = cdsBackupFiles
    Left = 160
    Top = 272
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 216
    Top = 272
    object actDoIt: TAction
      Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
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
      ImageIndex = 27
      OnExecute = actSelectArchiveExecute
    end
    object actSelectDataBase: TAction
      Hint = #1042#1099#1073#1086#1088' '#1092#1072#1081#1083#1072' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
      ImageIndex = 109
      OnExecute = actSelectDataBaseExecute
    end
  end
  object q: TIBSQL
    Database = ibdb
    ParamCheck = True
    Transaction = ibtr
    Left = 224
    Top = 312
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
    Top = 312
  end
  object ibdb: TIBDatabase
    LoginPrompt = False
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 160
    Top = 312
  end
  object sd: TSaveDialog
    DefaultExt = 'GDB'
    Filter = #1060#1072#1081#1083#1099' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093' (*.gdb, *.fdb)|*.?db|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #1040#1088#1093#1080#1074' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
    Left = 320
    Top = 96
  end
  object od: TOpenDialog
    DefaultExt = 'BK'
    Filter = #1040#1088#1093#1080#1074#1085#1099#1077' '#1092#1072#1081#1083#1099' (*.bk)|*.bk|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1060#1072#1081#1083' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
    Left = 272
    Top = 96
  end
  object IBRestoreService: TIBRestoreService
    Protocol = TCP
    LoginPrompt = False
    TraceFlags = []
    BufferSize = 8192
    PageSize = 0
    PageBuffers = 0
    Options = [NoValidityCheck, CreateNewDB]
    Left = 336
    Top = 256
  end
end
