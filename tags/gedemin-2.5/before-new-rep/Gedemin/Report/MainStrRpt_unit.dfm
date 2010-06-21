object Form1: TForm1
  Left = 231
  Top = 154
  Width = 544
  Height = 375
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
  object Button1: TButton
    Left = 448
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 448
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 448
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 448
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 448
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 448
    Top = 224
    Width = 75
    Height = 25
    Caption = 'Button6'
    TabOrder = 5
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 168
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button7'
    TabOrder = 6
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 256
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button8'
    TabOrder = 7
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 256
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button9'
    TabOrder = 8
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 168
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button10'
    TabOrder = 9
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 256
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Button11'
    TabOrder = 10
    OnClick = Button11Click
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 104
    Width = 320
    Height = 120
    DataSource = DataSource1
    TabOrder = 11
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object DBGrid2: TDBGrid
    Left = 8
    Top = 224
    Width = 320
    Height = 120
    DataSource = DataSource2
    TabOrder = 12
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Button12: TButton
    Left = 168
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Button12'
    TabOrder = 13
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 344
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button13'
    TabOrder = 14
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 344
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button14'
    TabOrder = 15
    OnClick = Button14Click
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
    Left = 8
    Top = 8
  end
  object dsResult: TDataSource
    DataSet = IBQuery1
    Left = 8
    Top = 48
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  id'
      '  , name'
      '  , (SELECT COUNT(*) FROM RDB$DATABASE)'
      'FROM'
      '  gd_user'
      'ORDER BY id')
    Left = 40
    Top = 48
  end
  object IBDatabase1: TIBDatabase
    Connected = True
    DatabaseName = 'win2000server:k:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    AllowStreamedConnected = False
    Left = 304
    Top = 104
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    Left = 336
    Top = 104
  end
  object frReport1: TfrReport
    InitialZoom = pzDefault
    PreviewButtons = [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbHelp, pbExit]
    StoreInDFM = True
    Left = 136
    Top = 104
    ReportForm = {
      180000003106000018000000001F005C5C57494E323030305345525645525C4C
      65786D61726B204F70747261204500FFFFFFFFFF0900000035080000990B0000
      0000000000000000000000000000000000FFFF00000000FFFF00000000000000
      0000000000030400466F726D000F000080DC000000780000007C0100002C0100
      00040000000200F40000000B004D617374657244617461310002010000000040
      000000F6020000120000003000050001000000000000000000FFFFFF1F000000
      000C0066724442446174615365743100000000000000FFFF0000000000020000
      00010000000000000001000000C8000000140000000100000000000002005901
      0000050042616E64310002010000000017000000F60200001200000030000200
      01000000000000000000FFFFFF1F00000000000000000000000000FFFF000000
      000002000000010000000000000001000000C800000014000000010000000000
      000200D00100000B0044657461696C44617461310002010000000064000000F6
      020000120000003000080001000000000000000000FFFFFF1F000000000C0066
      724442446174615365743200000000000000FFFF000000000002000000010000
      000000000001000000C8000000140000000100000000000000005F0200000500
      4D656D6F310002002800000040000000B00000001200000043000E0001000000
      000000000000FFFFFF1F2E020000000000010011005B49425175657279312E22
      4E414D45225D00000000FFFF0000000000020000000100000000050041726961
      6C000A00000000000000000000000000CC00020000000000FFFFFF0000000002
      000000000000000000EC02000005004D656D6F32000200D800000040000000B0
      0000001200000043000A0001000000000000000000FFFFFF1F2E020000000000
      01000F005B49425175657279312E224944225D00000000FFFF00000000000200
      000001000000000500417269616C000A00000000000000000000000000CC0002
      0000000000FFFFFF00000000020000000000000000007A03000005004D656D6F
      330002008801000040000000600000001200000043000B000100000000000000
      0000FFFFFF1F2E020000000000010010005B49425175657279312E22465F3122
      5D00000000FFFF00000000000200000001000000000500417269616C000A0000
      0000000000000000000000CC00020000000000FFFFFF00000000020000000000
      00000000FB03000005004D656D6F360002001700000017000000200000001200
      00004300000001000000000000000000FFFFFF1F2E0200000000000100030046
      5F3100000000FFFF00000000000200000001000000000500417269616C000A00
      000002000000000000000000CC00020000000000FFFFFF000000000200000000
      00000000007B04000005004D656D6F380002006B000000170000001800000012
      0000004300000001000000000000000000FFFFFF1F2E02000000000001000200
      494400000000FFFF00000000000200000001000000000500417269616C000A00
      000002000000000000000000CC00020000000000FFFFFF000000000200000000
      0000000000FE04000006004D656D6F3130000200BF0000001700000030000000
      120000004300000001000000000000000000FFFFFF1F2E020000000000010004
      004E414D4500000000FFFF00000000000200000001000000000500417269616C
      000A00000002000000000000000000CC00020000000000FFFFFF000000000200
      00000000000000008C05000005004D656D6F35000200F0010000400000006000
      0000120000004300000001000000000000000000FFFFFF1F2E02000000000001
      0010005B49425175657279312E22465F31225D00000000FFFF00000000000200
      000001000000000500417269616C000A00000000000000000000000000CC0002
      0000000000FFFFFF00000000020000000000000000001B06000005004D656D6F
      340002003000000064000000C400000012000000430000000100000000000000
      0000FFFFFF1F2E020000000000010011005B49425175657279322E224E414D45
      225D00000000FFFF00000000000200000001000000000500417269616C000A00
      000000000000000000000000CC00020000000000FFFFFF000000000200000000
      000000FEFEFF000000000000000000000000FDFF0100000000}
  end
  object frCompositeReport1: TfrCompositeReport
    InitialZoom = pzDefault
    PreviewButtons = [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbHelp, pbExit]
    Left = 184
    Top = 216
    ReportForm = {18000000}
  end
  object IBQuery2: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  id'
      '  , name'
      '  , (SELECT COUNT(*) FROM RDB$DATABASE)'
      'FROM'
      '  gd_user'
      'ORDER BY id')
    Left = 88
    Top = 48
  end
  object frDesigner1: TfrDesigner
    Left = 184
    Top = 168
  end
  object frDBDataSet1: TfrDBDataSet
    DataSet = IBQuery1
    Left = 88
    Top = 104
  end
  object frDBDataSet2: TfrDBDataSet
    DataSet = IBQuery2
    Left = 88
    Top = 136
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 168
    Top = 40
  end
  object DataSetProvider1: TDataSetProvider
    Constraints = True
    Options = [poFetchBlobsOnDemand, poReadOnly, poAllowMultiRecordUpdates, poDisableInserts, poDisableEdits, poDisableDeletes, poNoReset]
    Left = 200
    Top = 40
  end
  object IBQuery3: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '/*  id, locnumeric, name, locdouble, locsmallint, loccstring*/'
      ''
      '  body'
      'FROM'
      '  msg_message /**/'
      '/*  tst_test /**/'
      '  ')
    Left = 232
    Top = 40
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 168
    Top = 72
  end
  object DataSource2: TDataSource
    DataSet = IBQuery3
    Left = 232
    Top = 72
  end
  object IBTable1: TIBTable
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    TableName = 'TST_TEST'
    Left = 344
    Top = 40
  end
end
