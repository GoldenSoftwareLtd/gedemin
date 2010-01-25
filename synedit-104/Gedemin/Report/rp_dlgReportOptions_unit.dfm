object dlgReportOptions: TdlgReportOptions
  Left = 206
  Top = 93
  BorderStyle = bsDialog
  Caption = 'Параметры сервера отчетов'
  ClientHeight = 341
  ClientWidth = 438
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 142
    Height = 13
    Caption = 'Наименование компьютера'
  end
  object Label2: TLabel
    Left = 16
    Top = 40
    Width = 95
    Height = 13
    Caption = 'Время построения'
  end
  object Label3: TLabel
    Left = 216
    Top = 40
    Width = 6
    Height = 13
    Caption = 'с'
  end
  object Label4: TLabel
    Left = 328
    Top = 40
    Width = 12
    Height = 13
    Caption = 'по'
  end
  object Label5: TLabel
    Left = 16
    Top = 64
    Width = 183
    Height = 13
    Caption = 'Период обновления данных отчетов'
  end
  object Label7: TLabel
    Left = 16
    Top = 88
    Width = 183
    Height = 13
    Caption = 'Период актуальности данных (дней)'
  end
  object Label8: TLabel
    Left = 16
    Top = 112
    Width = 195
    Height = 13
    Caption = 'Период неактуальности данных (дней)'
  end
  object Label10: TLabel
    Left = 16
    Top = 136
    Width = 107
    Height = 13
    Caption = 'TCP/IP порт сервера'
  end
  object Button1: TButton
    Left = 280
    Top = 312
    Width = 75
    Height = 25
    Caption = 'ОК'
    Default = True
    TabOrder = 8
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 360
    Top = 312
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 9
  end
  object dtpStart: TDateTimePicker
    Left = 232
    Top = 37
    Width = 89
    Height = 21
    CalAlignment = dtaLeft
    Date = 36929
    Time = 36929
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkTime
    ParseInput = False
    TabOrder = 1
  end
  object DBEdit2: TDBEdit
    Left = 216
    Top = 13
    Width = 217
    Height = 21
    DataField = 'COMPUTERNAME'
    DataSource = dsReportServer
    Enabled = False
    TabOrder = 0
  end
  object dtpFinish: TDateTimePicker
    Left = 344
    Top = 37
    Width = 89
    Height = 21
    CalAlignment = dtaLeft
    Date = 36929.25
    Time = 36929.25
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkTime
    ParseInput = False
    TabOrder = 2
  end
  object dtpRefresh: TDateTimePicker
    Left = 344
    Top = 61
    Width = 89
    Height = 21
    CalAlignment = dtaLeft
    Date = 36929.0416666667
    Time = 36929.0416666667
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkTime
    ParseInput = False
    TabOrder = 3
  end
  object pnlExternal: TPanel
    Left = 8
    Top = 184
    Width = 429
    Height = 121
    BevelOuter = bvNone
    TabOrder = 7
    object Label9: TLabel
      Left = 8
      Top = 4
      Width = 304
      Height = 13
      Caption = 'Укажите путь для внешнего хранилища результатов отчета'
    end
    object dbePath: TDBEdit
      Left = 8
      Top = 20
      Width = 393
      Height = 21
      DataField = 'RESULTPATH'
      DataSource = dsReportServer
      TabOrder = 0
      OnChange = dbePathChange
    end
    object Button3: TButton
      Left = 404
      Top = 20
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = Button3Click
    end
    object pnlInterbase: TPanel
      Left = 8
      Top = 48
      Width = 393
      Height = 69
      BevelOuter = bvNone
      TabOrder = 2
      object Label6: TLabel
        Left = 0
        Top = 0
        Width = 153
        Height = 39
        Caption = 'Параметры для подключения к внешней базе данных Interbase'
        WordWrap = True
      end
      object DBMemo1: TDBMemo
        Left = 168
        Top = 0
        Width = 225
        Height = 65
        DataField = 'IBPARAMS'
        DataSource = dsReportServer
        TabOrder = 0
      end
    end
  end
  object dbcbLocal: TDBCheckBox
    Left = 16
    Top = 160
    Width = 233
    Height = 17
    Caption = 'Хранить результат в текущей базе'
    DataField = 'LocalStorage'
    DataSource = dsReportServer
    TabOrder = 6
    ValueChecked = '1'
    ValueUnchecked = '0'
    OnClick = dbcbLocalClick
  end
  object dbeActual: TDBEdit
    Left = 216
    Top = 85
    Width = 217
    Height = 21
    DataField = 'ACTUALREPORT'
    DataSource = dsReportServer
    TabOrder = 4
  end
  object dbeUnactual: TDBEdit
    Left = 216
    Top = 109
    Width = 217
    Height = 21
    DataField = 'UNACTUALREPORT'
    DataSource = dsReportServer
    TabOrder = 5
  end
  object dbePort: TDBEdit
    Left = 216
    Top = 133
    Width = 217
    Height = 21
    DataField = 'SERVERPORT'
    DataSource = dsReportServer
    TabOrder = 10
  end
  object dsReportServer: TDataSource
    DataSet = ibdsReportServer
    Left = 368
    Top = 152
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.cds'
    Filter = 'Interbase|*.gdb|ClientDataSet|*.cds|All Files|*.*'
    Options = [ofEnableSizing]
    Left = 400
    Top = 152
  end
  object ibdsReportServer: TIBDataSet
    Database = UnvisibleForm.gsIBDatabase1
    Transaction = UnvisibleForm.IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from rp_reportserver'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into rp_reportserver'
      
        '  (ID, COMPUTERNAME, RESULTPATH, STARTTIME, ENDTIME, FRQDATAREAD' +
        ', ACTUALREPORT, '
      
        '   UNACTUALREPORT, IBPARAMS, LOCALSTORAGE, RESERVED, USEDORDER, ' +
        'SERVERPORT)'
      'values'
      
        '  (:ID, :COMPUTERNAME, :RESULTPATH, :STARTTIME, :ENDTIME, :FRQDA' +
        'TAREAD, '
      
        '   :ACTUALREPORT, :UNACTUALREPORT, :IBPARAMS, :LOCALSTORAGE, :RE' +
        'SERVED, '
      '   :USEDORDER, :SERVERPORT)')
    RefreshSQL.Strings = (
      'Select '
      '  *'
      'from rp_reportserver '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportserver'
      'WHERE'
      '  id = :id')
    ModifySQL.Strings = (
      'update rp_reportserver'
      'set'
      '  ID = :ID,'
      '  COMPUTERNAME = :COMPUTERNAME,'
      '  RESULTPATH = :RESULTPATH,'
      '  STARTTIME = :STARTTIME,'
      '  ENDTIME = :ENDTIME,'
      '  FRQDATAREAD = :FRQDATAREAD,'
      '  ACTUALREPORT = :ACTUALREPORT,'
      '  UNACTUALREPORT = :UNACTUALREPORT,'
      '  IBPARAMS = :IBPARAMS,'
      '  LOCALSTORAGE = :LOCALSTORAGE,'
      '  RESERVED = :RESERVED,'
      '  USEDORDER = :USEDORDER,'
      '  SERVERPORT = :SERVERPORT'
      'where'
      '  ID = :OLD_ID')
    Left = 336
    Top = 152
  end
end
