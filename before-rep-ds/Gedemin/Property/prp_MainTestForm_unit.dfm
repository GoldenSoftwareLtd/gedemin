object MainTestForm: TMainTestForm
  Left = 317
  Top = 187
  Width = 575
  Height = 525
  Caption = 'MainTestForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ReportScript1: TReportScript
    Left = 423
    Top = 89
    Width = 32
    Height = 32
    OnCreateObject = ReportScript1CreateObject
    ControlData = {
      21433412080000002403000024030000D2F1594E010000002400000010270000
      0100080056004200530063007200690070007400}
  end
  object Button1: TButton
    Left = 249
    Top = 74
    Width = 79
    Height = 20
    Caption = 'Execute Script'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 124
    Top = 107
    Width = 286
    Height = 156
    Lines.Strings = (
      'function Test'
      '  BaseClass.Method1'
      'end function')
    TabOrder = 2
  end
  object Button2: TButton
    Left = 13
    Top = 224
    Width = 98
    Height = 20
    Caption = 'PropByName'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 13
    Top = 182
    Width = 98
    Height = 21
    TabOrder = 4
    Text = 'Name'
  end
  object Button3: TButton
    Left = 20
    Top = 269
    Width = 60
    Height = 20
    Caption = 'Button3'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 7
    Top = 39
    Width = 60
    Height = 20
    Caption = 'PropDlg'
    TabOrder = 6
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 124
    Top = 269
    Width = 60
    Height = 20
    Caption = 'Button5'
    TabOrder = 7
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 234
    Top = 269
    Width = 61
    Height = 20
    Caption = 'Button6'
    TabOrder = 8
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 124
    Top = 295
    Width = 60
    Height = 20
    Caption = 'GenEvent'
    TabOrder = 9
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 234
    Top = 295
    Width = 61
    Height = 20
    Caption = 'Button8'
    TabOrder = 10
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 247
    Top = 48
    Width = 74
    Height = 20
    Caption = 'CheckStream'
    TabOrder = 11
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 332
    Top = 48
    Width = 98
    Height = 20
    Caption = 'CheckObjectStream'
    TabOrder = 12
    OnClick = Button10Click
  end
  object ComboBox1: TComboBox
    Left = 13
    Top = 159
    Width = 100
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 13
    Items.Strings = (
      'uiouio'
      'yuoyuo'
      'yu')
  end
  object Button11: TButton
    Left = 7
    Top = 65
    Width = 60
    Height = 20
    Caption = 'Prop fff'
    TabOrder = 14
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 332
    Top = 74
    Width = 60
    Height = 20
    Caption = 'Sound'
    TabOrder = 15
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 332
    Top = 269
    Width = 60
    Height = 20
    Caption = 'SetEvent'
    TabOrder = 16
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 332
    Top = 295
    Width = 60
    Height = 20
    Caption = 'Popup'
    TabOrder = 17
    OnClick = Button14Click
  end
  object Button15: TButton
    Left = 332
    Top = 321
    Width = 60
    Height = 20
    Caption = 'ShowScript'
    TabOrder = 18
    OnClick = Button15Click
  end
  object ComboBox2: TComboBox
    Left = 208
    Top = 321
    Width = 118
    Height = 21
    ItemHeight = 13
    TabOrder = 19
    Text = 'ComboBox2'
    Items.Strings = (
      'Delphi'
      'VBScript'
      'JScript')
  end
  object Button16: TButton
    Left = 20
    Top = 315
    Width = 60
    Height = 20
    Caption = 'Button16'
    TabOrder = 20
    OnClick = Button16Click
  end
  object Button19: TButton
    Left = 104
    Top = 352
    Width = 75
    Height = 25
    Caption = 'MainDlg 2'
    TabOrder = 21
  end
  object Button20: TButton
    Left = 104
    Top = 384
    Width = 75
    Height = 25
    Caption = 'MainForm 2'
    TabOrder = 22
  end
  object Button21: TButton
    Left = 112
    Top = 80
    Width = 91
    Height = 25
    Caption = 'gdScriptFactory'
    TabOrder = 23
    OnClick = Button21Click
  end
  object Button22: TButton
    Left = 332
    Top = 347
    Width = 60
    Height = 20
    Caption = 'EventList'
    TabOrder = 24
    OnClick = Button22Click
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 567
    Height = 29
    AutoSize = True
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        Width = 563
      end>
    object ToolBar1: TToolBar
      Left = 9
      Top = 0
      Width = 550
      Height = 25
      ButtonHeight = 21
      ButtonWidth = 54
      Caption = 'ToolBar1'
      EdgeBorders = []
      Flat = True
      ShowCaptions = True
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Caption = 'Макросы'
        DropdownMenu = gdMacrosMenu1
        Grouped = True
        ImageIndex = 0
      end
      object ToolButton2: TToolButton
        Left = 54
        Top = 0
        Caption = 'Отчёты'
        Grouped = True
        ImageIndex = 1
      end
    end
  end
  object Button17: TButton
    Left = 7
    Top = 89
    Width = 60
    Height = 20
    Caption = 'PropForm'
    TabOrder = 26
    OnClick = Button17Click
  end
  object Button18: TButton
    Left = 8
    Top = 112
    Width = 60
    Height = 20
    Caption = 'Button18'
    TabOrder = 27
    OnClick = Button18Click
  end
  object Button23: TButton
    Left = 104
    Top = 416
    Width = 105
    Height = 25
    Caption = 'Test Methods'
    TabOrder = 28
  end
  object Button24: TButton
    Left = 104
    Top = 456
    Width = 75
    Height = 25
    Caption = 'Test Mtd2'
    TabOrder = 29
    OnClick = Button24Click
  end
  object Button25: TButton
    Left = 192
    Top = 456
    Width = 113
    Height = 25
    Caption = 'Test for Close55'
    TabOrder = 30
  end
  object Button26: TButton
    Left = 16
    Top = 352
    Width = 75
    Height = 25
    Caption = 'fff'
    TabOrder = 31
    OnClick = Button26Click
  end
  object Button27: TButton
    Left = 16
    Top = 384
    Width = 75
    Height = 25
    Caption = 'fff2'
    TabOrder = 32
    OnClick = Button27Click
  end
  object Button28: TButton
    Left = 16
    Top = 416
    Width = 75
    Height = 25
    Caption = 'fff5'
    TabOrder = 33
    OnClick = Button28Click
  end
  object PopupMenu1: TPopupMenu
    Left = 88
    Top = 120
    object N4564561: TMenuItem
      Caption = '456456'
    end
  end
  object gsQueryFilter1: TgsQueryFilter
    Left = 192
    Top = 80
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 88
    Top = 80
    object ClientDataSet1wqeqwe: TIntegerField
      FieldName = 'wqeqwe'
    end
    object ClientDataSet1wqeqweqwe: TStringField
      FieldName = 'wqeqweqwe'
    end
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase2
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT * FROM gd_function')
    Left = 232
    Top = 80
  end
  object IBDatabase2: TIBDatabase
    Connected = True
    DatabaseName = 'win2000server:k:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    AllowStreamedConnected = False
    Left = 168
    Top = 40
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase2
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 200
    Top = 40
  end
  object gdMacrosMenu1: TgdMacrosMenu
    Left = 488
    Top = 176
  end
end
