object MainReportServer: TMainReportServer
  Left = 173
  Top = 168
  Width = 544
  Height = 375
  Caption = 'MainReportServer'
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
    Left = 232
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 232
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 1
  end
  object Button3: TButton
    Left = 64
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Execute'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 64
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Add Function'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 320
    Top = 72
    Width = 105
    Height = 25
    Caption = 'Variant to Stream'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 320
    Top = 104
    Width = 105
    Height = 25
    Caption = 'Compare variant'
    TabOrder = 5
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 320
    Top = 136
    Width = 105
    Height = 25
    Caption = 'Save ReportResult'
    TabOrder = 6
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 320
    Top = 168
    Width = 105
    Height = 25
    Caption = 'Prepare ReportList'
    TabOrder = 7
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 320
    Top = 200
    Width = 105
    Height = 25
    Caption = 'Rebuild Reports'
    TabOrder = 8
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 16
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Filter Table'
    TabOrder = 9
    OnClick = Button10Click
  end
  object Edit1: TEdit
    Left = 16
    Top = 208
    Width = 121
    Height = 21
    TabOrder = 10
    Text = 'Edit1'
  end
  object DBGrid1: TDBGrid
    Left = 112
    Top = 264
    Width = 304
    Height = 72
    DataSource = DataSource1
    TabOrder = 11
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Button11: TButton
    Left = 320
    Top = 232
    Width = 105
    Height = 25
    Caption = 'Server Option'
    TabOrder = 12
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 320
    Top = 40
    Width = 105
    Height = 25
    Caption = 'Save Data'
    TabOrder = 13
    OnClick = Button12Click
  end
  object boLogin1: TboLogin
    Database = gsIBDatabase1
    AutoOpenCompany = True
    Left = 8
    Top = 40
  end
  object gsIBDatabase1: TIBDatabase
    DatabaseName = 'win2000server:k:\bases\Gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey')
    LoginPrompt = False
    IdleTimer = 0
    TraceFlags = []
    Left = 8
    Top = 8
    AllowStreamedConnected = False
    SQLDialect = 3
  end
  object WordApplication1: TWordApplication
    AutoConnect = False
    ConnectKind = ckNewInstance
    AutoQuit = False
    Left = 200
    Top = 232
  end
  object WordDocument1: TWordDocument
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    OnNew = WordDocument1New
    OnOpen = WordDocument1Open
    OnClose = WordDocument1Close
    Left = 200
    Top = 200
  end
  object DataSetProvider1: TDataSetProvider
    DataSet = IBTable1
    Constraints = True
    Left = 200
    Top = 112
  end
  object ClientDataSet1: TClientDataSet
    Active = True
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'REPORTKEY'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'CRCPARAM'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'PARAMORDER'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'RESULTDATA'
        DataType = ftBlob
        Size = 8
      end
      item
        Name = 'CREATEDATE'
        DataType = ftDateTime
      end
      item
        Name = 'EXECUTETIME'
        DataType = ftTime
      end
      item
        Name = 'LASTUSEDATE'
        DataType = ftDateTime
      end
      item
        Name = 'RESERVED'
        DataType = ftInteger
      end
      item
        Name = 'PARAMDATA'
        DataType = ftBlob
        Size = 8
      end>
    IndexDefs = <
      item
        Name = 'DEFAULT_ORDER'
        Fields = 'REPORTKEY;CRCPARAM;PARAMORDER'
        Options = [ixUnique]
      end
      item
        Name = 'CHANGEINDEX'
      end>
    Params = <>
    StoreDefs = True
    Left = 200
    Top = 80
    Data = {
      390100009619E0BD010000001800000009000000000003000000390109524550
      4F52544B4559040001000400000008435243504152414D04000100040000000A
      504152414D4F5244455204000100040000000A524553554C544441544104004B
      0000000200075355425459504502004900070042696E61727900055749445448
      0200020008000A4352454154454441544508000800000000000B455845435554
      4554494D4504000700000000000B4C4153545553454441544508000800000000
      00085245534552564544040001000000000009504152414D4441544104004B00
      00000200075355425459504502004900070042696E6172790005574944544802
      000200080002000D44454641554C545F4F524445520200820003000000010002
      0003000B5052494D4152595F4B45590200820003000000010002000300}
  end
  object IBTable1: TIBTable
    Database = gsIBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    FieldDefs = <
      item
        Name = 'REPORTKEY'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'CRCPARAM'
        DataType = ftInteger
      end
      item
        Name = 'PARAMORDER'
        DataType = ftInteger
      end
      item
        Name = 'RESULTDATA'
        DataType = ftBlob
      end
      item
        Name = 'CREATEDATE'
        DataType = ftDateTime
      end
      item
        Name = 'EXECUTETIME'
        DataType = ftTime
      end
      item
        Name = 'LASTUSEDATE'
        DataType = ftDateTime
      end
      item
        Name = 'RESERVED'
        DataType = ftInteger
      end
      item
        Name = 'PARAMDATA'
        DataType = ftBlob
      end>
    Filter = 'reportkey is null'
    Filtered = True
    IndexDefs = <
      item
        Name = 'RDB$PRIMARY290'
        Fields = 'REPORTKEY;CRCPARAM;PARAMORDER'
        Options = [ixPrimary, ixUnique]
      end
      item
        Name = 'RDB$FOREIGN291'
        Fields = 'REPORTKEY'
      end>
    IndexFieldNames = 'REPORTKEY;CRCPARAM;PARAMORDER'
    StoreDefs = True
    TableName = 'RP_REPORTRESULT'
    Left = 16
    Top = 240
  end
  object DataSource1: TDataSource
    DataSet = IBTable1
    Left = 48
    Top = 240
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = gsIBDatabase1
    Params.Strings = (
      'read'
      'consistency')
    Left = 8
    Top = 88
  end
  object IBDataSet1: TIBDataSet
    Database = gsIBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from rp_reportresult'
      'where'
      '  REPORTKEY = :OLD_REPORTKEY and'
      '  CRCPARAM = :OLD_CRCPARAM and'
      '  PARAMORDER = :OLD_PARAMORDER')
    InsertSQL.Strings = (
      'insert into rp_reportresult'
      '  (REPORTKEY, CRCPARAM, PARAMORDER, RESULTDATA, CREATEDATE, '
      'EXECUTETIME, '
      '   LASTUSEDATE, RESERVED, PARAMDATA)'
      'values'
      
        '  (:REPORTKEY, :CRCPARAM, :PARAMORDER, :RESULTDATA, :CREATEDATE,' +
        ' '
      ':EXECUTETIME, '
      '   :LASTUSEDATE, :RESERVED, :PARAMDATA)')
    RefreshSQL.Strings = (
      'Select '
      '  *'
      'from rp_reportresult '
      'where'
      '  REPORTKEY = :REPORTKEY and'
      '  CRCPARAM = :CRCPARAM and'
      '  PARAMORDER = :PARAMORDER')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportresult')
    ModifySQL.Strings = (
      'update rp_reportresult'
      'set'
      '  REPORTKEY = :REPORTKEY,'
      '  CRCPARAM = :CRCPARAM,'
      '  PARAMORDER = :PARAMORDER,'
      '  RESULTDATA = :RESULTDATA,'
      '  CREATEDATE = :CREATEDATE,'
      '  EXECUTETIME = :EXECUTETIME,'
      '  LASTUSEDATE = :LASTUSEDATE,'
      '  RESERVED = :RESERVED,'
      '  PARAMDATA = :PARAMDATA'
      'where'
      '  REPORTKEY = :OLD_REPORTKEY and'
      '  CRCPARAM = :OLD_CRCPARAM and'
      '  PARAMORDER = :OLD_PARAMORDER')
    Left = 264
    Top = 40
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.cds|*.cds'
    Left = 264
    Top = 80
  end
end
