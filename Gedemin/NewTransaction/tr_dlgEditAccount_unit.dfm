object dlgEditAccount: TdlgEditAccount
  Left = 244
  Top = 103
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Параметры счета'
  ClientHeight = 361
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblAlias: TLabel
    Left = 13
    Top = 19
    Width = 65
    Height = 13
    Caption = 'Номер счета'
  end
  object lblName: TLabel
    Left = 13
    Top = 48
    Width = 107
    Height = 13
    Caption = 'Наименование счета'
  end
  object Label1: TLabel
    Left = 17
    Top = 190
    Width = 99
    Height = 13
    Caption = 'Аналитика по счету'
  end
  object dbedAlias: TDBEdit
    Left = 139
    Top = 15
    Width = 121
    Height = 21
    DataField = 'ALIAS'
    DataSource = dsAccount
    TabOrder = 0
  end
  object dbedName: TDBEdit
    Left = 139
    Top = 43
    Width = 281
    Height = 21
    DataField = 'NAME'
    DataSource = dsAccount
    TabOrder = 1
  end
  object pAccountInfo: TPanel
    Left = 13
    Top = 69
    Width = 409
    Height = 117
    BevelOuter = bvNone
    TabOrder = 2
    object Label2: TLabel
      Left = 1
      Top = 97
      Width = 68
      Height = 13
      Caption = 'Раздел (счет)'
    end
    object GroupBox1: TGroupBox
      Left = 1
      Top = 0
      Width = 199
      Height = 89
      Caption = 'Параметры счета'
      TabOrder = 0
      object dbcbCurrAccount: TDBCheckBox
        Left = 9
        Top = 41
        Width = 97
        Height = 17
        Caption = 'Валютный счет'
        DataField = 'MULTYCURR'
        DataSource = dsAccount
        TabOrder = 1
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbcbOffBalance: TDBCheckBox
        Left = 9
        Top = 64
        Width = 144
        Height = 17
        Caption = 'Забалансовый счет'
        DataField = 'OFFBALANCE'
        DataSource = dsAccount
        TabOrder = 2
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbcbGrade: TDBCheckBox
        Left = 10
        Top = 18
        Width = 97
        Height = 17
        Caption = 'Субсчет'
        DataField = 'GRADE'
        DataSource = dsAccount
        TabOrder = 0
        ValueChecked = '3'
        ValueUnchecked = '2'
      end
    end
    object dbrgTypeAccount: TDBRadioGroup
      Left = 208
      Top = 0
      Width = 199
      Height = 89
      Caption = 'Тип счета'
      DataField = 'TYPEACCOUNT'
      DataSource = dsAccount
      Items.Strings = (
        'Активный'
        'Пассивный'
        'Активно-пассивный')
      TabOrder = 1
      Values.Strings = (
        '0'
        '1'
        '2')
    end
    object gsiblcGroupAccount: TgsIBLookupComboBox
      Left = 126
      Top = 94
      Width = 282
      Height = 21
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTransaction
      DataSource = dsAccount
      DataField = 'PARENT'
      ListTable = 'GD_CARDACCOUNT'
      ListField = 'ALIAS'
      KeyField = 'ID'
      Condition = 'GRADE <= 2'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  object gsibgrAnalytical: TgsIBGrid
    Left = 16
    Top = 203
    Width = 405
    Height = 137
    DataSource = dsAnalytical
    Options = [dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 3
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.DisplayField = 'LNAME'
    CheckBox.FieldName = 'FIELDNAME'
    CheckBox.Visible = True
    MinColWidth = 40
    Columns = <
      item
        Alignment = taLeftJustify
        Expanded = False
        FieldName = 'FIELDNAME'
        Title.Caption = 'FIELDNAME'
        Width = -1
        Visible = False
      end
      item
        Alignment = taLeftJustify
        Expanded = False
        FieldName = 'LNAME'
        Title.Caption = 'Аналитика'
        Width = 364
        Visible = True
      end>
  end
  object Button1: TButton
    Left = 437
    Top = 14
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    TabOrder = 4
  end
  object Button2: TButton
    Left = 437
    Top = 44
    Width = 75
    Height = 25
    Action = actNext
    TabOrder = 5
  end
  object Button3: TButton
    Left = 437
    Top = 74
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    ModalResult = 2
    TabOrder = 6
  end
  object ibdsAccount: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_cardaccount'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_cardaccount'
      '  (ID, PARENT, ALIAS, NAME, TYPEACCOUNT, GRADE, ACTIVECARD, '
      'MULTYCURR, '
      
        '   OFFBALANCE, MAINANALYZE, DISABLED, AFULL, ACHAG, AVIEW, RESER' +
        'VED)'
      'values'
      '  (:ID, :PARENT, :ALIAS, :NAME, :TYPEACCOUNT, :GRADE, '
      ':ACTIVECARD, '
      
        '   :MULTYCURR, :OFFBALANCE, :MAINANALYZE, :DISABLED, :AFULL, :AC' +
        'HAG, '
      ':AVIEW, '
      '   :RESERVED)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_cardaccount '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_cardaccount'
      'WHERE id = :accountkey')
    ModifySQL.Strings = (
      'update gd_cardaccount'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  ALIAS = :ALIAS,'
      '  NAME = :NAME,'
      '  TYPEACCOUNT = :TYPEACCOUNT,'
      '  GRADE = :GRADE,'
      '  ACTIVECARD = :ACTIVECARD,'
      '  MULTYCURR = :MULTYCURR,'
      '  OFFBALANCE = :OFFBALANCE,'
      '  MAINANALYZE = :MAINANALYZE,'
      '  DISABLED = :DISABLED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 448
    Top = 112
  end
  object ibdsAnalytical: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT fieldname, lname FROM at_relation_fields'
      'WHERE relationname = '#39'GD_CARDACCOUNT'#39' and fieldname LIKE '#39'USR$%'#39)
    Left = 480
    Top = 111
    object ibdsAnalyticalFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object ibdsAnalyticalLNAME: TIBStringField
      DisplayLabel = 'Аналитика'
      FieldName = 'LNAME'
      Required = True
      Size = 60
    end
  end
  object dsAccount: TDataSource
    DataSet = ibdsAccount
    Left = 448
    Top = 144
  end
  object dsAnalytical: TDataSource
    DataSet = ibdsAnalytical
    Left = 480
    Top = 143
  end
  object ActionList1: TActionList
    Left = 416
    Top = 112
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actNext: TAction
      Caption = 'Следующее'
      ShortCut = 45
      OnExecute = actNextExecute
    end
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 448
    Top = 176
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 448
    Top = 208
  end
end
