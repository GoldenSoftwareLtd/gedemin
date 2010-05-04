object dlgChooseField: TdlgChooseField
  Left = 278
  Top = 183
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор полей в накладную'
  ClientHeight = 372
  ClientWidth = 615
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 4
    Width = 79
    Height = 13
    Caption = 'Основные поля'
  end
  object lRef: TLabel
    Left = 271
    Top = 4
    Width = 261
    Height = 13
    Caption = 'Поля таблица на которую ссылается текущее поле'
    Enabled = False
  end
  object bOk: TButton
    Left = 533
    Top = 19
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object bCancel: TButton
    Left = 533
    Top = 50
    Width = 75
    Height = 25
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object gsdbgrFields: TgsDBGrid
    Left = 8
    Top = 18
    Width = 256
    Height = 259
    DataSource = dsFields
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 2
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    TitlesExpanding = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    MinColWidth = 40
    Columns = <
      item
        Expanded = False
        FieldName = 'FIELDNAME'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'RELATIONNAME'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'LSHORTNAME'
        Title.Caption = 'Поле'
        Width = 124
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LNAME'
        Title.Caption = 'Полное наименование'
        Width = 364
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LTABLENAME'
        Title.Caption = 'Таблица'
        Width = 364
        Visible = True
      end>
  end
  object cbUseGroupKey: TCheckBox
    Left = 8
    Top = 281
    Width = 254
    Height = 14
    Caption = 'Учитывать выделяемую группу'
    Enabled = False
    TabOrder = 3
  end
  object sgrGroupSelect: TStringGrid
    Left = 8
    Top = 299
    Width = 518
    Height = 62
    ColCount = 2
    DefaultColWidth = 280
    Enabled = False
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 4
  end
  object gsdbgrRelField: TgsDBGrid
    Left = 269
    Top = 18
    Width = 256
    Height = 259
    DataSource = dsRelField
    Enabled = False
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 5
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    TitlesExpanding = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    MinColWidth = 40
    Columns = <
      item
        Expanded = False
        FieldName = 'FIELDNAME'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'RELATIONNAME'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'LSHORTNAME'
        Title.Caption = 'Поле'
        Width = 124
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LNAME'
        Title.Caption = 'Полное наименование'
        Width = 364
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LTABLENAME'
        Title.Caption = 'Таблица'
        Width = 364
        Visible = True
      end>
  end
  object ibdsField: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    AfterScroll = ibdsFieldAfterScroll
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT rf.FieldName, rf.RelationName,'
      '  rf.LShortName, rf.LName, r.LName as LTableName'
      'FROM'
      
        '  at_relation_fields rf JOIN at_relations r ON rf.RelationName =' +
        ' r.RelationName'
      'WHERE'
      
        '  r.RelationName IN ('#39'GD_DOCUMENT'#39', '#39'GD_DOCREALIZATION'#39', '#39'GD_DOC' +
        'REALINFO'#39',  '#39'GD_DOCREALPOS'#39') AND'
      '  rf.LShortName  IS NOT NULL')
    Left = 536
    Top = 98
    object ibdsFieldFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object ibdsFieldRELATIONNAME: TIBStringField
      FieldName = 'RELATIONNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object ibdsFieldLSHORTNAME: TIBStringField
      DisplayLabel = 'Поле'
      FieldName = 'LSHORTNAME'
    end
    object ibdsFieldLNAME: TIBStringField
      DisplayLabel = 'Полное наименование'
      FieldName = 'LNAME'
      Required = True
      Size = 60
    end
    object ibdsFieldLTABLENAME: TIBStringField
      DisplayLabel = 'Таблица'
      FieldName = 'LTABLENAME'
      Required = True
      Size = 60
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 536
    Top = 130
  end
  object dsFields: TDataSource
    DataSet = ibdsField
    Left = 568
    Top = 98
  end
  object ibdsRelField: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT rf.FieldName, rf.RelationName,'
      '  rf.LShortName, rf.LName, r.LName as LTableName'
      'FROM'
      
        '  at_relation_fields rf JOIN at_relations r ON rf.RelationName =' +
        ' r.RelationName'
      'WHERE'
      '  r.RelationName = :rn AND'
      '  rf.LShortName  IS NOT NULL')
    Left = 536
    Top = 162
    object IBStringField1: TIBStringField
      FieldName = 'FIELDNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object IBStringField2: TIBStringField
      FieldName = 'RELATIONNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object IBStringField3: TIBStringField
      DisplayLabel = 'Поле'
      FieldName = 'LSHORTNAME'
    end
    object IBStringField4: TIBStringField
      DisplayLabel = 'Полное наименование'
      FieldName = 'LNAME'
      Required = True
      Size = 60
    end
    object IBStringField5: TIBStringField
      DisplayLabel = 'Таблица'
      FieldName = 'LTABLENAME'
      Required = True
      Size = 60
    end
  end
  object dsRelField: TDataSource
    DataSet = ibdsRelField
    Left = 568
    Top = 160
  end
end
