object MainTestForm2: TMainTestForm2
  Left = 15
  Top = 51
  Width = 772
  Height = 480
  Caption = 'MainTestForm2'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 16
    Top = 376
    Width = 113
    Height = 57
    TabOrder = 29
  end
  object ReportScript1: TReportScript
    Left = 39
    Top = 65
    Width = 32
    Height = 32
    OnCreateObject = ReportScript1CreateObject
    ControlData = {
      21433412080000002403000024030000D2F1594E010000002400000010270000
      0100080056004200530063007200690070007400}
  end
  object Button1: TButton
    Left = 249
    Top = 26
    Width = 79
    Height = 20
    Caption = 'Execute Script'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 124
    Top = 51
    Width = 286
    Height = 156
    Lines.Strings = (
      'function Test'
      '  BaseClass.Method1'
      'end function')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 13
    Top = 176
    Width = 98
    Height = 20
    Caption = 'PropByName'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 13
    Top = 150
    Width = 98
    Height = 21
    TabOrder = 3
    Text = 'Name'
  end
  object Button3: TButton
    Left = 20
    Top = 221
    Width = 60
    Height = 20
    Caption = 'Button3'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 7
    Top = 7
    Width = 60
    Height = 20
    Caption = 'PropDlg'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 124
    Top = 221
    Width = 60
    Height = 20
    Caption = 'Button5'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 234
    Top = 221
    Width = 61
    Height = 20
    Caption = 'Button6'
    TabOrder = 7
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 124
    Top = 247
    Width = 60
    Height = 20
    Caption = 'GenEvent'
    TabOrder = 8
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 234
    Top = 247
    Width = 61
    Height = 20
    Caption = 'Button8'
    TabOrder = 9
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 247
    Top = 0
    Width = 74
    Height = 20
    Caption = 'CheckStream'
    TabOrder = 10
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 332
    Top = 0
    Width = 98
    Height = 20
    Caption = 'CheckObjectStream'
    TabOrder = 11
    OnClick = Button10Click
  end
  object ComboBox1: TComboBox
    Left = 13
    Top = 111
    Width = 118
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 12
    Items.Strings = (
      'uiouio'
      'yuoyuo'
      'yu')
  end
  object Button11: TButton
    Left = 7
    Top = 33
    Width = 60
    Height = 20
    Caption = 'PropForm'
    TabOrder = 13
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 332
    Top = 26
    Width = 60
    Height = 20
    Caption = 'Sound'
    TabOrder = 14
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 332
    Top = 213
    Width = 60
    Height = 20
    Caption = 'SetEvent'
    TabOrder = 15
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 332
    Top = 239
    Width = 60
    Height = 20
    Caption = 'Popup'
    TabOrder = 16
    OnClick = Button14Click
  end
  object Button15: TButton
    Left = 332
    Top = 289
    Width = 60
    Height = 20
    Caption = 'ShowScript'
    TabOrder = 17
    OnClick = Button15Click
  end
  object ComboBox2: TComboBox
    Left = 208
    Top = 273
    Width = 118
    Height = 21
    ItemHeight = 13
    TabOrder = 18
    Text = 'ComboBox2'
    Items.Strings = (
      'Delphi'
      'VBScript'
      'JScript')
  end
  object Button16: TButton
    Left = 20
    Top = 267
    Width = 60
    Height = 20
    Caption = 'Button16'
    TabOrder = 19
    OnClick = Button16Click
  end
  object Button17: TButton
    Left = 16
    Top = 304
    Width = 75
    Height = 25
    Caption = 'MainDlg 3'
    TabOrder = 20
    OnClick = Button17Click
  end
  object Button18: TButton
    Left = 16
    Top = 336
    Width = 75
    Height = 25
    Caption = 'MainForm 3'
    TabOrder = 21
    OnClick = Button18Click
  end
  object Button19: TButton
    Left = 104
    Top = 304
    Width = 75
    Height = 25
    Caption = 'MainDlg 2'
    TabOrder = 22
    OnClick = Button19Click
  end
  object Button20: TButton
    Left = 104
    Top = 336
    Width = 75
    Height = 25
    Caption = 'MainForm 2'
    TabOrder = 23
    OnClick = Button20Click
  end
  object Button21: TButton
    Left = 424
    Top = 56
    Width = 91
    Height = 25
    Caption = 'gdScriptFactory'
    TabOrder = 24
    OnClick = Button21Click
  end
  object Button22: TButton
    Left = 332
    Top = 315
    Width = 60
    Height = 20
    Caption = 'EventList'
    TabOrder = 25
    OnClick = Button22Click
  end
  object CheckBoxCache: TCheckBox
    Left = 24
    Top = 384
    Width = 97
    Height = 17
    Caption = 'Use Cache'
    TabOrder = 26
  end
  object CheckBoxRemote: TCheckBox
    Left = 24
    Top = 408
    Width = 97
    Height = 17
    Caption = 'Remote Execute'
    Checked = True
    State = cbChecked
    TabOrder = 27
  end
  object Button23: TButton
    Left = 424
    Top = 96
    Width = 89
    Height = 25
    Caption = 'gdScriptFactory 2'
    TabOrder = 30
    OnClick = Button23Click
  end
  object Button24: TButton
    Left = 136
    Top = 408
    Width = 161
    Height = 25
    Caption = 'Macros'
    TabOrder = 31
    OnClick = Button24Click
  end
  object Button25: TButton
    Left = 136
    Top = 376
    Width = 161
    Height = 25
    Caption = 'Macros with default server'
    TabOrder = 32
    OnClick = Button25Click
  end
  object gsIBCtrlGrid1: TgsIBCtrlGrid
    Left = 304
    Top = 336
    Width = 345
    Height = 113
    DataSource = DataSource1
    TabOrder = 33
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
  end
  object Button26: TButton
    Left = 520
    Top = 272
    Width = 75
    Height = 25
    Caption = 'Connect '
    TabOrder = 34
    OnClick = Button26Click
  end
  object gsIBCtrlGrid2: TgsIBCtrlGrid
    Left = 424
    Top = 144
    Width = 169
    Height = 121
    DataSource = DataSource2
    TabOrder = 35
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
  end
  object Button27: TButton
    Left = 536
    Top = 0
    Width = 75
    Height = 25
    Cursor = crHandPoint
    BiDiMode = bdLeftToRight
    Caption = 'Button27'
    ParentBiDiMode = False
    TabOrder = 36
    OnClick = Button27Click
  end
  object Button28: TButton
    Left = 536
    Top = 24
    Width = 75
    Height = 25
    Cursor = crHandPoint
    BiDiMode = bdLeftToRight
    Caption = 'Button28'
    ParentBiDiMode = False
    TabOrder = 37
    OnClick = Button28Click
  end
  object Button29: TButton
    Left = 536
    Top = 48
    Width = 75
    Height = 25
    Cursor = crHandPoint
    BiDiMode = bdLeftToRight
    Caption = 'Button29'
    ParentBiDiMode = False
    TabOrder = 38
    OnClick = Button29Click
  end
  object Button30: TButton
    Left = 536
    Top = 72
    Width = 75
    Height = 25
    Cursor = crHandPoint
    BiDiMode = bdLeftToRight
    Caption = 'Button30'
    ParentBiDiMode = False
    TabOrder = 39
    OnClick = Button30Click
  end
  object Edit2: TEdit
    Left = 416
    Top = 304
    Width = 121
    Height = 21
    TabOrder = 40
    Text = 'Edit2'
  end
  object TBToolbar1: TTBToolbar
    Left = 96
    Top = 8
    Width = 23
    Height = 22
    Caption = 'TBToolbar1'
    TabOrder = 41
  end
  object Button31: TButton
    Left = 332
    Top = 264
    Width = 60
    Height = 20
    Cursor = crHandPoint
    BiDiMode = bdLeftToRight
    Caption = 'Edit1 Chan'
    ParentBiDiMode = False
    TabOrder = 42
    OnClick = Button31Click
  end
  object CheckBox1: TCheckBox
    Left = 400
    Top = 280
    Width = 97
    Height = 9
    Caption = 'CheckBox1'
    TabOrder = 43
  end
  object xDateEdit1: TxDateEdit
    Left = 624
    Top = 240
    Width = 121
    Height = 21
    EditMask = '!99/99/9999 99:99:99;1;_'
    MaxLength = 19
    TabOrder = 44
    Text = '07.03.2002 10:10:16'
  end
  object xDateDBEdit1: TxDateDBEdit
    Left = 624
    Top = 272
    Width = 121
    Height = 21
    EditMask = '!99/99/9999 99:99:99;1;_'
    MaxLength = 19
    TabOrder = 45
  end
  object PopupMenu1: TPopupMenu
    Left = 104
    Top = 96
    object N4564561: TMenuItem
      Caption = '456456'
    end
  end
  object gsQueryFilter1: TgsQueryFilter
    Left = 192
    Top = 32
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 88
    Top = 32
    object ClientDataSet1wqeqwe: TIntegerField
      FieldName = 'wqeqwe'
    end
    object ClientDataSet1wqeqweqwe: TStringField
      FieldName = 'wqeqweqwe'
    end
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT * FROM gd_function')
    Left = 232
    Top = 32
  end
  object IBDatabase1: TIBDatabase
    Connected = True
    DatabaseName = 'win2000server:k:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    AllowStreamedConnected = False
    Left = 232
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 264
    Top = 32
  end
  object gdScriptFactory1: TgdScriptFactory
    ShowRaise = False
    DataBase = IBDatabase1
    Transaction = IBTransaction1
    Left = 168
    Top = 8
  end
  object boLogin1: TboLogin
    Database = IBDatabase1
    AutoOpenCompany = True
    Left = 440
    Top = 16
  end
  object SynManager1: TSynManager
    Left = 128
    Top = 8
  end
  object gdcBaseManager1: TgdcBaseManager
    Database = IBDatabase1
    Left = 104
    Top = 64
  end
  object DataSource1: TDataSource
    DataSet = IBQuery2
    Left = 480
    Top = 272
  end
  object IBQuery2: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT * FROM EVT_MACROSLIST')
    Left = 440
    Top = 272
  end
  object IBQuery3: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT * FROM RP_REPORTSERVER')
    Left = 616
    Top = 152
  end
  object DataSource2: TDataSource
    DataSet = IBQuery3
    Left = 616
    Top = 208
  end
end
