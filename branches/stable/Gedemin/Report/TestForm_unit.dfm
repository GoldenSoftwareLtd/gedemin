object Form1: TForm1
  Left = 83
  Top = 131
  Width = 570
  Height = 388
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 145
    Width = 562
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object mmText: TMemo
    Left = 0
    Top = 0
    Width = 562
    Height = 145
    Align = alTop
    Lines.Strings = (
      'Base.Clear();'
      'Base.AddQuery();'
      'Base.Query(0).SQL = '#39'SELECT c.name, COUNT(m.messagekey) '#39' +'
      
        ' '#39'FROM msg_target m, gd_contact c WHERE m.contactkey = c.id GROU' +
        'P BY c.name'#39';'
      'Base.Query(0).Open();'
      'Base.ResultIndex = 0;')
    TabOrder = 1
  end
  object ScriptControl1: TScriptControl
    Left = 8
    Top = 8
    Width = 32
    Height = 32
    ControlData = {
      2143341208000000ED030000ED030000D2F1594E010000002200000010270000
      010007004A00530063007200690070007400}
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 148
    Width = 562
    Height = 172
    Align = alClient
    DataSource = dsResult
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Panel1: TPanel
    Left = 0
    Top = 320
    Width = 562
    Height = 41
    Align = alBottom
    TabOrder = 3
    object btnStart: TButton
      Left = 456
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Выполнить'
      TabOrder = 0
      OnClick = btnStartClick
    end
  end
  object dsResult: TDataSource
    DataSet = IBQuery1
    Left = 280
    Top = 312
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT * FROM gd_user')
    Left = 280
    Top = 280
  end
  object IBDatabase1: TIBDatabase
    DatabaseName = 'ibserver:K:\Bases\Test\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'Lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 280
    Top = 232
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    Left = 312
    Top = 232
  end
  object xReport1: TxReport
    Options = [frMsgIfTerminated, frAlwaysOpenDataSet]
    Destination = dsScreen
    FormFile = 'temp.rtf'
    DataSources.Strings = (
      'DefaultTable = '#39'dsResult'#39)
    About.Strings = (
      ''
      ''
      '')
    Left = 240
    Top = 312
  end
end
