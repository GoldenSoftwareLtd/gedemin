object Form1: TForm1
  Left = 261
  Top = 196
  Width = 696
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ControlBar1: TControlBar
    Left = 0
    Top = 0
    Width = 688
    Height = 33
    Align = alTop
    BevelEdges = []
    TabOrder = 0
    object Button1: TButton
      Left = 32
      Top = 2
      Width = 75
      Height = 22
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 33
    Width = 688
    Height = 420
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Units'
      object gsDBGrid1: TgsDBGrid
        Left = 0
        Top = 0
        Width = 680
        Height = 392
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsUnit
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        MinColWidth = 40
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Vars'
      ImageIndex = 1
      object gsDBGrid2: TgsDBGrid
        Left = 0
        Top = 0
        Width = 680
        Height = 281
        Align = alTop
        BorderStyle = bsNone
        DataSource = dsVars
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        MinColWidth = 40
      end
      object DBMemo1: TDBMemo
        Left = 0
        Top = 303
        Width = 281
        Height = 89
        DataField = 'DECLORATION'
        DataSource = dsVars
        TabOrder = 1
      end
      object DBMemo2: TDBMemo
        Left = 312
        Top = 304
        Width = 185
        Height = 89
        DataField = 'COMMENT'
        DataSource = dsVars
        TabOrder = 2
      end
    end
  end
  object IBDatabase: TIBDatabase
    Connected = True
    DatabaseName = 'ibserver:k:\bases\test\etalon.fdb'
    Params.Strings = (
      'user_name=sysdba'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 220
    Top = 89
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 252
    Top = 89
  end
  object qryUnit: TIBQuery
    Database = IBDatabase
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'select id, name, filename, source from ct_unit')
    Left = 300
    Top = 89
  end
  object dsUnit: TDataSource
    DataSet = qryUnit
    Left = 332
    Top = 89
  end
  object qryVar: TIBQuery
    Database = IBDatabase
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'select u.name, v.name, v.decloration, v.comment'
      'from ct_unit u, ct_var v'
      'where u.id = v.unitkey')
    Left = 300
    Top = 121
  end
  object dsVars: TDataSource
    DataSet = qryVar
    Left = 332
    Top = 121
  end
end
