object Form1: TForm1
  Left = 79
  Top = 97
  Width = 544
  Height = 401
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 96
    Top = 8
    Width = 433
    Height = 329
    DataSource = dsClient
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 8
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Create'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Edit'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Delete'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 8
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Execute'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 8
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 8
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 6
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 8
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 7
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 8
    Top = 344
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 8
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 432
    Top = 16
    Width = 91
    Height = 25
    Caption = 'TReportResult'
    TabOrder = 9
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 432
    Top = 48
    Width = 89
    Height = 25
    Caption = 'KindResult'
    TabOrder = 10
    OnClick = Button10Click
  end
  object xReport1: TxReport
    Options = [frMsgIfTerminated, frAlwaysOpenDataSet]
    Destination = dsScreen
    About.Strings = (
      ''
      ''
      '')
    Left = 16
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = IBQuery1
    Left = 48
    Top = 40
  end
  object IBQuery1: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  Subject'
      'FROM'
      '  msg_message')
    Left = 16
    Top = 40
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <
      item
        Visible = False
      end>
    Params = <>
    Left = 120
    Top = 184
    object ClientDataSet1id: TIntegerField
      FieldName = 'id'
    end
    object ClientDataSet1name: TStringField
      FieldName = 'name'
    end
  end
  object dsClient: TDataSource
    DataSet = ClientDataSet1
    Left = 152
    Top = 184
  end
  object DataSetProvider1: TDataSetProvider
    DataSet = IBQuery1
    Constraints = True
    Options = [poFetchBlobsOnDemand]
    Left = 88
    Top = 184
  end
  object OpenDialog1: TOpenDialog
    Filter = 'ClientDataSet (*.cds)|*.cds'
    Left = 112
    Top = 120
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'cds'
    Filter = 'ClientDataSet (*.cds)|*.cds'
    Left = 144
    Top = 120
  end
  object boScriptControl1: TboScriptControl
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGAdmin
    Silent = True
    OnCreateObject = boScriptControl1CreateObject
    Left = 144
    Top = 88
  end
  object boUserFunction1: TboUserFunction
    boScriptControl = boScriptControl1
    Left = 176
    Top = 88
  end
  object gsCustomReportBase1: TgsCustomReportBase
    Database = dmDatabase.ibdbGAdmin
    boScriptControl = boScriptControl1
    Left = 8
    Top = 184
  end
  object ibtblTest: TIBTable
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    Left = 88
    Top = 336
  end
  object IBDatabase1: TIBDatabase
    DatabaseName = 'ibserver:k:\bases\test\report1.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 1
    TraceFlags = []
    Left = 88
    Top = 304
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    Left = 120
    Top = 304
  end
  object IBDatabase2: TIBDatabase
    DatabaseName = 'ibserver:k:\bases\test\report2.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction2
    IdleTimer = 0
    SQLDialect = 1
    TraceFlags = []
    Left = 288
    Top = 304
  end
  object IBTransaction2: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase2
    Left = 320
    Top = 304
  end
  object ibtblReport: TIBTable
    Database = IBDatabase2
    Transaction = IBTransaction2
    BufferChunks = 1000
    CachedUpdates = False
    TableName = 'RP_TESTREPORT'
    Left = 288
    Top = 336
  end
  object IBQuery2: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    Left = 120
    Top = 336
  end
end
