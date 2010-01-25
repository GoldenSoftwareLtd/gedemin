object dlgPriceOption: TdlgPriceOption
  Left = 289
  Top = 180
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Настройка для поля прайс-листа'
  ClientHeight = 261
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 458
    Height = 220
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Основные'
      object Label1: TLabel
        Left = 7
        Top = 13
        Width = 77
        Height = 13
        Caption = 'Название поля'
      end
      object Label2: TLabel
        Left = 7
        Top = 40
        Width = 38
        Height = 13
        Caption = 'Валюта'
      end
      object Label3: TLabel
        Left = 7
        Top = 68
        Width = 91
        Height = 13
        Caption = 'Формула расчета'
      end
      object gsiblcFieldName: TgsIBLookupComboBox
        Left = 109
        Top = 9
        Width = 219
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        DataSource = dsPPosOption
        DataField = 'FIELDNAME'
        ListTable = 'at_relation_fields'
        ListField = 'fieldname'
        KeyField = 'fieldname'
        Condition = 'relationname = '#39'GD_PRICEPOS'#39
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object gsiblcCurr: TgsIBLookupComboBox
        Left = 109
        Top = 36
        Width = 219
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        DataSource = dsPPosOption
        DataField = 'CURRKEY'
        ListTable = 'GD_CURR'
        ListField = 'SHORTNAME'
        KeyField = 'ID'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object dbmExpression: TDBMemo
        Left = 109
        Top = 64
        Width = 219
        Height = 56
        DataField = 'EXPRESSION'
        DataSource = dsPPosOption
        TabOrder = 2
      end
      object dbcbDisabled: TDBCheckBox
        Left = 9
        Top = 167
        Width = 84
        Height = 17
        Caption = 'Отключено'
        DataField = 'Disabled'
        DataSource = dsPPosOption
        TabOrder = 3
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object Button3: TButton
        Left = 245
        Top = 119
        Width = 84
        Height = 25
        Action = actVariable
        TabOrder = 4
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Контакты'
      ImageIndex = 1
      object Label4: TLabel
        Left = 8
        Top = 37
        Width = 238
        Height = 13
        Caption = 'Цена используется для следующих  контактов'
      end
      object gsibgrPriceFieldRel: TgsIBGrid
        Left = 8
        Top = 5
        Width = 345
        Height = 180
        DataSource = dsPriceFieldRel
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
      object Button4: TButton
        Left = 361
        Top = 5
        Width = 84
        Height = 25
        Action = actChoose
        TabOrder = 1
      end
      object Button5: TButton
        Left = 361
        Top = 33
        Width = 84
        Height = 25
        Action = actDel
        TabOrder = 2
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Документы'
      ImageIndex = 2
      object gsibgrPriceDocRel: TgsIBCtrlGrid
        Left = 8
        Top = 8
        Width = 432
        Height = 177
        DataSource = dsPriceDocRel
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
      object gsiblcDocumentType: TgsIBLookupComboBox
        Left = 16
        Top = 48
        Width = 193
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        DataSource = dsPriceDocRel
        DataField = 'DOCUMENTTYPEKEY'
        ListTable = 'GD_DOCUMENTTYPE'
        ListField = 'NAME'
        KeyField = 'ID'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Visible = False
        OnChange = gsiblcDocumentTypeChange
      end
      object gsiblcRelationName: TgsIBLookupComboBox
        Left = 16
        Top = 80
        Width = 193
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        DataSource = dsPriceDocRel
        DataField = 'RELATIONNAME'
        ListTable = 'GD_RELATIONTYPEDOC'
        ListField = 'RELATIONNAME'
        KeyField = 'RELATIONNAME'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Visible = False
        OnChange = gsiblcRelationNameChange
      end
      object gsiblcRelFieldName: TgsIBLookupComboBox
        Left = 17
        Top = 112
        Width = 192
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        DataSource = dsPriceDocRel
        DataField = 'DOCFIELDNAME'
        ListTable = 'AT_RELATION_FIELDS'
        ListField = 'LNAME'
        KeyField = 'FIELDNAME'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Visible = False
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 220
    Width = 458
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Button1: TButton
      Left = 127
      Top = 8
      Width = 84
      Height = 25
      Action = actOk
      Default = True
      TabOrder = 0
    end
    object Button2: TButton
      Left = 247
      Top = 8
      Width = 84
      Height = 25
      Action = actCancel
      Cancel = True
      TabOrder = 1
    end
  end
  object dsPPosOption: TDataSource
    Left = 375
    Top = 136
  end
  object ActionList1: TActionList
    Left = 344
    Top = 128
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actVariable: TAction
      Caption = 'Переменная...'
      OnExecute = actVariableExecute
    end
    object actChoose: TAction
      Caption = 'Выбрать...'
      OnExecute = actChooseExecute
    end
    object actDel: TAction
      Caption = 'Удалить'
      OnExecute = actDelExecute
    end
  end
  object ibdsPriceFieldRel: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_pricefieldrel'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME and'
      '  CONTACTKEY = :OLD_CONTACTKEY')
    InsertSQL.Strings = (
      'insert into gd_pricefieldrel'
      '  (FIELDNAME, CONTACTKEY, ISSUBLEVEL)'
      'values'
      '  (:FIELDNAME, :CONTACTKEY, :ISSUBLEVEL)')
    RefreshSQL.Strings = (
      'SELECT g.fieldname, g.contactkey, g.issublevel, c.name'
      'FROM gd_pricefieldrel g JOIN gd_contact c ON g.contactkey = c.id'
      'where'
      '  FIELDNAME = :FIELDNAME and'
      '  CONTACTKEY = :CONTACTKEY')
    SelectSQL.Strings = (
      'SELECT g.fieldname, g.contactkey, g.issublevel, c.name'
      'FROM gd_pricefieldrel g JOIN gd_contact c ON g.contactkey = c.id'
      'WHERE'
      '  g.fieldname = :fn'
      'ORDER BY c.name')
    ModifySQL.Strings = (
      'update gd_pricefieldrel'
      'set'
      '  FIELDNAME = :FIELDNAME,'
      '  CONTACTKEY = :CONTACTKEY,'
      '  ISSUBLEVEL = :ISSUBLEVEL'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME and'
      '  CONTACTKEY = :OLD_CONTACTKEY')
    Left = 208
    Top = 173
    object ibdsPriceFieldRelFIELDNAME: TIBStringField
      DisplayLabel = 'Поле'
      FieldName = 'FIELDNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object ibdsPriceFieldRelCONTACTKEY: TIntegerField
      FieldName = 'CONTACTKEY'
      Required = True
      Visible = False
    end
    object ibdsPriceFieldRelNAME: TIBStringField
      DisplayLabel = 'Наименование'
      DisplayWidth = 30
      FieldName = 'NAME'
      Required = True
      Size = 60
    end
    object ibdsPriceFieldRelISSUBLEVEL: TSmallintField
      DisplayLabel = 'Включать подуровни'
      FieldName = 'ISSUBLEVEL'
    end
  end
  object dsPriceFieldRel: TDataSource
    DataSet = ibdsPriceFieldRel
    Left = 240
    Top = 165
  end
  object ibdsPriceDocRel: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    AfterInsert = ibdsPriceDocRelAfterInsert
    BufferChunks = 1000
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from gd_pricedocrel'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME and'
      '  DOCUMENTTYPEKEY = :OLD_DOCUMENTTYPEKEY and'
      '  RELATIONNAME = :OLD_RELATIONNAME and'
      '  DOCFIELDNAME = :OLD_DOCFIELDNAME')
    InsertSQL.Strings = (
      'insert into gd_pricedocrel'
      '  (FIELDNAME, DOCUMENTTYPEKEY, RELATIONNAME, DOCFIELDNAME, '
      'VALUETEXT, RESERVED)'
      'values'
      '  (:FIELDNAME, :DOCUMENTTYPEKEY, :RELATIONNAME, :DOCFIELDNAME, '
      ':VALUETEXT, '
      '   :RESERVED)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_pricedocrel '
      'where'
      '  FIELDNAME = :FIELDNAME and'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY and'
      '  RELATIONNAME = :RELATIONNAME and'
      '  DOCFIELDNAME = :DOCFIELDNAME')
    SelectSQL.Strings = (
      'SELECT '
      '  p.*,'
      '  d.name,'
      '  a.lname'
      'FROM '
      
        '  gd_pricedocrel p JOIN gd_documenttype d on p.documenttypekey =' +
        ' d.id'
      
        '  LEFT JOIN at_relation_fields a ON p.relationname = a.relationn' +
        'ame AND'
      '  p.docfieldname = a.fieldname'
      'WHERE'
      '  p.fieldname = :fn')
    ModifySQL.Strings = (
      'update gd_pricedocrel'
      'set'
      '  FIELDNAME = :FIELDNAME,'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY,'
      '  RELATIONNAME = :RELATIONNAME,'
      '  DOCFIELDNAME = :DOCFIELDNAME,'
      '  VALUETEXT = :VALUETEXT,'
      '  RESERVED = :RESERVED'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME and'
      '  DOCUMENTTYPEKEY = :OLD_DOCUMENTTYPEKEY and'
      '  RELATIONNAME = :OLD_RELATIONNAME and'
      '  DOCFIELDNAME = :OLD_DOCFIELDNAME')
    Left = 204
    Top = 120
    object ibdsPriceDocRelFIELDNAME: TIBStringField
      DisplayLabel = 'Поле'
      FieldName = 'FIELDNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object ibdsPriceDocRelNAME: TIBStringField
      DisplayLabel = 'Тип документа'
      DisplayWidth = 20
      FieldName = 'NAME'
      Required = True
      Size = 60
    end
    object ibdsPriceDocRelRELATIONNAME: TIBStringField
      DisplayLabel = 'Таблица'
      FieldName = 'RELATIONNAME'
      Required = True
      Size = 31
    end
    object ibdsPriceDocRelLNAME: TIBStringField
      DisplayLabel = 'Поле'
      DisplayWidth = 20
      FieldName = 'LNAME'
      Size = 60
    end
    object ibdsPriceDocRelVALUETEXT: TIBStringField
      DisplayLabel = 'Значение'
      DisplayWidth = 20
      FieldName = 'VALUETEXT'
      Size = 180
    end
    object ibdsPriceDocRelDOCFIELDNAME: TIBStringField
      DisplayLabel = 'Поле таблицы'
      FieldName = 'DOCFIELDNAME'
      Required = True
      Visible = False
      OnChange = ibdsPriceDocRelDOCFIELDNAMEChange
      Size = 31
    end
    object ibdsPriceDocRelRESERVED: TIntegerField
      FieldName = 'RESERVED'
      Visible = False
    end
    object ibdsPriceDocRelDOCUMENTTYPEKEY: TIntegerField
      FieldName = 'DOCUMENTTYPEKEY'
      Required = True
      Visible = False
      OnChange = ibdsPriceDocRelDOCUMENTTYPEKEYChange
    end
  end
  object dsPriceDocRel: TDataSource
    DataSet = ibdsPriceDocRel
    Left = 236
    Top = 120
  end
end
