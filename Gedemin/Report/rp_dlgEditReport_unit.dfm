object dlgEditReport: TdlgEditReport
  Left = 111
  Top = 65
  BorderStyle = bsDialog
  Caption = 'Параметры отчета'
  ClientHeight = 371
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pcReport: TPageControl
    Left = 4
    Top = 5
    Width = 446
    Height = 328
    ActivePage = tsMain
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'Параметры'
      object Label1: TLabel
        Left = 8
        Top = 26
        Width = 79
        Height = 13
        Caption = 'Наименование:'
      end
      object Label2: TLabel
        Left = 8
        Top = 49
        Width = 53
        Height = 13
        Caption = 'Описание:'
      end
      object Label3: TLabel
        Left = 8
        Top = 101
        Width = 177
        Height = 13
        Caption = 'Частота обновления отчета (дней):'
      end
      object Label7: TLabel
        Left = 8
        Top = 172
        Width = 151
        Height = 13
        Caption = 'Функция обработки события:'
      end
      object Label8: TLabel
        Left = 8
        Top = 148
        Width = 113
        Height = 13
        Caption = 'Функция для расчета:'
      end
      object Label9: TLabel
        Left = 8
        Top = 125
        Width = 179
        Height = 13
        Caption = 'Функция для задания параметров:'
      end
      object Label10: TLabel
        Left = 8
        Top = 195
        Width = 78
        Height = 13
        Caption = 'Шаблон отчета:'
      end
      object Label5: TLabel
        Left = 8
        Top = 219
        Width = 119
        Height = 13
        Caption = 'Выполнять на сервере:'
      end
      object Label4: TLabel
        Left = 8
        Top = 3
        Width = 83
        Height = 13
        Caption = 'Идентификатор:'
      end
      object DBText1: TDBText
        Left = 192
        Top = 4
        Width = 65
        Height = 17
        DataField = 'ID'
        DataSource = dsReport
      end
      object dbeName: TDBEdit
        Left = 192
        Top = 23
        Width = 241
        Height = 24
        DataField = 'NAME'
        DataSource = dsReport
        TabOrder = 0
      end
      object dbeFrqRefresh: TDBEdit
        Left = 192
        Top = 95
        Width = 241
        Height = 24
        DataField = 'FRQREFRESH'
        DataSource = dsReport
        TabOrder = 2
      end
      object dbcbSaveResult: TDBCheckBox
        Left = 8
        Top = 260
        Width = 220
        Height = 17
        Caption = 'Перестраивать отчет заново'
        DataField = 'ISREBUILD'
        DataSource = dsReport
        TabOrder = 12
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object btnSelMain: TButton
        Left = 413
        Top = 144
        Width = 20
        Height = 21
        Action = actSelectMainFunc
        TabOrder = 6
      end
      object btnSelEvent: TButton
        Left = 413
        Top = 168
        Width = 20
        Height = 21
        Action = actSelectEventFunc
        TabOrder = 8
      end
      object dblcbMainFormula: TDBLookupComboBox
        Left = 192
        Top = 144
        Width = 217
        Height = 21
        DataField = 'MAINFORMULAKEY'
        DataSource = dsReport
        DropDownRows = 20
        KeyField = 'ID'
        ListField = 'NAME'
        ListSource = dsMainFormula
        TabOrder = 5
        OnKeyDown = dblcbMainFormulaKeyDown
      end
      object dblcbEventFormula: TDBLookupComboBox
        Left = 192
        Top = 168
        Width = 217
        Height = 21
        DataField = 'EVENTFORMULAKEY'
        DataSource = dsReport
        DropDownRows = 20
        KeyField = 'ID'
        ListField = 'NAME'
        ListSource = dsEventFormula
        TabOrder = 7
        OnKeyDown = dblcbEventFormulaKeyDown
      end
      object btnSelParam: TButton
        Left = 413
        Top = 120
        Width = 20
        Height = 21
        Action = actSelectParamFunc
        TabOrder = 4
      end
      object dblcbParamFormula: TDBLookupComboBox
        Left = 192
        Top = 120
        Width = 217
        Height = 21
        Ctl3D = True
        DataField = 'PARAMFORMULAKEY'
        DataSource = dsReport
        DropDownRows = 20
        KeyField = 'ID'
        ListField = 'NAME'
        ListSource = dsParamFormula
        ParentCtl3D = False
        TabOrder = 3
        OnKeyDown = dblcbParamFormulaKeyDown
      end
      object btnSelTemplate: TButton
        Left = 413
        Top = 192
        Width = 20
        Height = 21
        Action = actSelectTemplate
        TabOrder = 10
      end
      object dbcbReportServer: TDBLookupComboBox
        Left = 192
        Top = 216
        Width = 217
        Height = 21
        DataField = 'SERVERKEY'
        DataSource = dsReport
        DropDownRows = 20
        KeyField = 'ID'
        ListField = 'COMPUTERNAME'
        ListSource = dsReportServer
        TabOrder = 11
        OnKeyDown = dbcbReportServerKeyDown
      end
      object dbmDescription: TDBMemo
        Left = 192
        Top = 48
        Width = 241
        Height = 44
        DataField = 'DESCRIPTION'
        DataSource = dsReport
        TabOrder = 1
      end
      object dblcbTemplate: TDBLookupComboBox
        Left = 192
        Top = 192
        Width = 217
        Height = 21
        DataField = 'TEMPLATEKEY'
        DataSource = dsReport
        DropDownRows = 20
        KeyField = 'ID'
        ListField = 'NAME'
        ListSource = dsTemplate
        TabOrder = 9
        OnKeyDown = dblcbTemplateKeyDown
      end
      object dbcbIsLocalExecute: TDBCheckBox
        Left = 8
        Top = 280
        Width = 220
        Height = 17
        Caption = 'Выполнять отчет локально'
        DataField = 'ISLOCALEXECUTE'
        DataSource = dsReport
        TabOrder = 13
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbcbPreview: TDBCheckBox
        Left = 8
        Top = 240
        Width = 220
        Height = 17
        Caption = 'Отображать отчет перед печатью'
        DataField = 'PREVIEW'
        DataSource = dsReport
        TabOrder = 14
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 335
    Width = 455
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object pnlRBtn: TPanel
      Left = 270
      Top = 0
      Width = 185
      Height = 36
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
      object btnOk: TButton
        Left = 25
        Top = 8
        Width = 75
        Height = 22
        Caption = 'OK'
        Default = True
        TabOrder = 0
        OnClick = btnOkClick
      end
      object btnCancel: TButton
        Left = 105
        Top = 8
        Width = 75
        Height = 22
        Cancel = True
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
    end
    object btnHelp: TButton
      Left = 4
      Top = 7
      Width = 75
      Height = 22
      Caption = 'Справка'
      TabOrder = 0
    end
    object btnAccess: TButton
      Left = 84
      Top = 7
      Width = 75
      Height = 22
      Action = actRigth
      TabOrder = 1
    end
  end
  object ibdsReport: TIBDataSet
    Transaction = ibtrReport
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from rp_reportlist'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into rp_reportlist'
      
        '  (ID, NAME, DESCRIPTION, FRQREFRESH, REPORTGROUPKEY, PARAMFORMU' +
        'LAKEY, '
      
        '   MAINFORMULAKEY, EVENTFORMULAKEY, TEMPLATEKEY, ISREBUILD, AFUL' +
        'L, ACHAG, '
      '   AVIEW, SERVERKEY, ISLOCALEXECUTE, RESERVED, PREVIEW)'
      'values'
      
        '  (:ID, :NAME, :DESCRIPTION, :FRQREFRESH, :REPORTGROUPKEY, :PARA' +
        'MFORMULAKEY, '
      
        '   :MAINFORMULAKEY, :EVENTFORMULAKEY, :TEMPLATEKEY, :ISREBUILD, ' +
        ':AFULL, '
      
        '   :ACHAG, :AVIEW, :SERVERKEY, :ISLOCALEXECUTE, :RESERVED, :PREV' +
        'IEW)')
    RefreshSQL.Strings = (
      'Select '
      '  *'
      'from rp_reportlist '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportlist'
      'WHERE'
      '  id = :id')
    ModifySQL.Strings = (
      'update rp_reportlist'
      'set'
      '  ID = :ID,'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  FRQREFRESH = :FRQREFRESH,'
      '  REPORTGROUPKEY = :REPORTGROUPKEY,'
      '  PARAMFORMULAKEY = :PARAMFORMULAKEY,'
      '  MAINFORMULAKEY = :MAINFORMULAKEY,'
      '  EVENTFORMULAKEY = :EVENTFORMULAKEY,'
      '  TEMPLATEKEY = :TEMPLATEKEY,'
      '  ISREBUILD = :ISREBUILD,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  SERVERKEY = :SERVERKEY,'
      '  ISLOCALEXECUTE = :ISLOCALEXECUTE,'
      '  RESERVED = :RESERVED,'
      '  PREVIEW = :PREVIEW'
      'where'
      '  ID = :OLD_ID')
    Left = 220
    Top = 80
  end
  object dsReport: TDataSource
    DataSet = ibdsReport
    Left = 254
    Top = 80
  end
  object ActionList1: TActionList
    Left = 412
    Top = 80
    object actLoad_M: TAction
      Category = 'MainFormula'
      Caption = 'Загрузить'
      ImageIndex = 0
    end
    object actSave_M: TAction
      Category = 'MainFormula'
      Caption = 'Сохранить'
      ImageIndex = 1
    end
    object actCompile_M: TAction
      Category = 'MainFormula'
      Caption = 'Compile'
      ImageIndex = 2
    end
    object actFind_M: TAction
      Category = 'MainFormula'
      Caption = 'Поиск'
      ImageIndex = 3
    end
    object actHelp_M: TAction
      Category = 'MainFormula'
      Caption = 'Помощь'
      ImageIndex = 5
    end
    object actLoad_E: TAction
      Category = 'EventFormula'
      Caption = 'actLoad_E'
      ImageIndex = 0
    end
    object actSave_E: TAction
      Category = 'EventFormula'
      Caption = 'actSave_E'
      ImageIndex = 1
    end
    object actCompile_E: TAction
      Category = 'EventFormula'
      Caption = 'actCompile_E'
      ImageIndex = 2
    end
    object actFind_E: TAction
      Category = 'EventFormula'
      Caption = 'actFind_E'
      ImageIndex = 3
    end
    object actHelp_E: TAction
      Category = 'EventFormula'
      Caption = 'actHelp_E'
      ImageIndex = 5
    end
    object actRigth: TAction
      Caption = 'Права'
    end
    object actSelectMainFunc: TAction
      Caption = '...'
      OnExecute = actSelectMainFuncExecute
    end
    object actSelectEventFunc: TAction
      Caption = '...'
      OnExecute = actSelectEventFuncExecute
    end
    object actSelectParamFunc: TAction
      Caption = '...'
      OnExecute = actSelectParamFuncExecute
    end
    object actSelectTemplate: TAction
      Caption = '...'
      OnExecute = actSelectTemplateExecute
    end
  end
  object ibqryMainFormula: TIBQuery
    Transaction = ibtrReport
    AfterOpen = ibqryMainFormulaAfterOpen
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_function'
      'WHERE'
      '  module = :module'
      'ORDER BY '
      '  name')
    Left = 196
    Top = 200
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'module'
        ParamType = ptUnknown
      end>
  end
  object ibqryEventFormula: TIBQuery
    Transaction = ibtrReport
    AfterOpen = ibqryMainFormulaAfterOpen
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_function'
      'WHERE'
      '  module = :module'
      'ORDER BY '
      '  name')
    Left = 228
    Top = 200
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'module'
        ParamType = ptUnknown
      end>
  end
  object dsMainFormula: TDataSource
    DataSet = ibqryMainFormula
    Left = 196
    Top = 168
  end
  object dsEventFormula: TDataSource
    DataSet = ibqryEventFormula
    Left = 228
    Top = 168
  end
  object dsParamFormula: TDataSource
    DataSet = ibqryParamFormula
    Left = 260
    Top = 168
  end
  object ibqryParamFormula: TIBQuery
    Transaction = ibtrReport
    AfterOpen = ibqryMainFormulaAfterOpen
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_function'
      'WHERE'
      '  module = :module'
      'ORDER BY '
      '  name')
    Left = 260
    Top = 200
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'module'
        ParamType = ptUnknown
      end>
  end
  object OpenDialog1: TOpenDialog
    Filter = 'RTF Files|*.rtf'
    Options = [ofReadOnly, ofHideReadOnly, ofEnableSizing]
    Left = 340
    Top = 80
  end
  object ibqryReportServer: TIBQuery
    Transaction = ibtrReport
    AfterOpen = ibqryMainFormulaAfterOpen
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportserver'
      'ORDER BY '
      '  usedorder')
    Left = 292
    Top = 200
  end
  object dsReportServer: TDataSource
    DataSet = ibqryReportServer
    Left = 292
    Top = 168
  end
  object dsTemplate: TDataSource
    DataSet = ibqryTemplate
    Left = 324
    Top = 168
  end
  object ibqryTemplate: TIBQuery
    Transaction = ibtrReport
    AfterOpen = ibqryMainFormulaAfterOpen
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reporttemplate'
      'ORDER BY '
      '  name')
    Left = 324
    Top = 200
  end
  object ibtrReport: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 161
    Top = 169
  end
end
