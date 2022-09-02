object dlgChooseVariable: TdlgChooseVariable
  Left = 243
  Top = 101
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор переменной'
  ClientHeight = 453
  ClientWidth = 465
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 370
    Height = 453
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 5
      Top = 298
      Width = 360
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object Panel3: TPanel
      Left = 5
      Top = 5
      Width = 360
      Height = 293
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel3'
      TabOrder = 0
      object Label1: TLabel
        Left = 0
        Top = 0
        Width = 360
        Height = 13
        Align = alTop
        Caption = 'Переменные'
      end
      object ibgrVariable: TgsIBGrid
        Left = 0
        Top = 13
        Width = 360
        Height = 280
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsRelationField
        TabOrder = 0
        RefreshType = rtNone
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.DisplayField = 'LNAME'
        CheckBox.FieldName = 'LVAR'
        CheckBox.Visible = True
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        Columns = <
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'LNAME'
            Title.Caption = 'Поле'
            Width = 124
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'LSHORTNAME'
            Title.Caption = 'Кратко'
            Width = 124
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'LTABLENAME'
            Title.Caption = 'Таблица'
            Width = 124
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'LTABLESHORTNAME'
            Title.Caption = 'Краткое наименование'
            Width = 124
            Visible = True
          end
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
            FieldName = 'RELATIONNAME'
            Title.Caption = 'RELATIONNAME'
            Width = -1
            Visible = False
          end>
      end
    end
    object pTax: TPanel
      Left = 5
      Top = 301
      Width = 360
      Height = 147
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object Label2: TLabel
        Left = 0
        Top = 0
        Width = 360
        Height = 13
        Align = alTop
        Caption = 'Налоги'
      end
      object ibgrTax: TgsIBGrid
        Left = 0
        Top = 13
        Width = 360
        Height = 134
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsTax
        TabOrder = 0
        RefreshType = rtNone
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.DisplayField = 'NAME'
        CheckBox.FieldName = 'SHOT'
        CheckBox.Visible = True
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        Columns = <
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ID'
            Title.Caption = 'ID'
            Width = -1
            Visible = False
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'NAME'
            Title.Caption = 'Налог'
            Width = 184
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'SHOT'
            Title.Caption = 'Переменная'
            Width = 124
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'RATE'
            Title.Caption = 'RATE'
            Width = -1
            Visible = False
          end>
      end
    end
  end
  object Panel2: TPanel
    Left = 370
    Top = 0
    Width = 95
    Height = 453
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object bOk: TButton
      Left = 10
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object bCancel: TButton
      Left = 10
      Top = 36
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ibdsRelationField: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    SelectSQL.Strings = (
      'SELECT '
      '  rf.LName, '
      '  rf.LShortName, '
      '  r.LName as LTableName, '
      '  r.LShortName as LTableShortName, '
      '  rf.FieldName,'
      '  r.RelationName,'
      '   r.LShortName || '#39'_'#39' || rf.LShortName as LVar'
      'FROM'
      
        '  at_relations r JOIN at_relation_fields rf ON r.relationname = ' +
        'rf.relationname')
    ReadTransaction = IBTransaction
    Left = 160
    Top = 72
    object ibdsRelationFieldLNAME: TIBStringField
      DisplayLabel = 'Поле'
      DisplayWidth = 20
      FieldName = 'LNAME'
      Required = True
      Size = 60
    end
    object ibdsRelationFieldLSHORTNAME: TIBStringField
      DisplayLabel = 'Кратко'
      FieldName = 'LSHORTNAME'
    end
    object ibdsRelationFieldLTABLENAME: TIBStringField
      DisplayLabel = 'Таблица'
      DisplayWidth = 20
      FieldName = 'LTABLENAME'
      Required = True
      Size = 60
    end
    object ibdsRelationFieldLTABLESHORTNAME: TIBStringField
      DisplayLabel = 'Краткое наименование'
      DisplayWidth = 20
      FieldName = 'LTABLESHORTNAME'
      Required = True
      Size = 60
    end
    object ibdsRelationFieldFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Required = True
      Size = 31
    end
    object ibdsRelationFieldRELATIONNAME: TIBStringField
      FieldName = 'RELATIONNAME'
      Required = True
      Size = 31
    end
    object ibdsRelationFieldLVAR: TIBStringField
      DisplayLabel = 'Переменная'
      FieldName = 'LVAR'
      Size = 81
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 168
    Top = 104
  end
  object dsRelationField: TDataSource
    DataSet = ibdsRelationField
    Left = 200
    Top = 72
  end
  object ibdsTax: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    SelectSQL.Strings = (
      'SELECT * FROM gd_tax'
      'WHERE not shot IS NULL and Shot <> '#39#39)
    ReadTransaction = IBTransaction
    Left = 133
    Top = 357
  end
  object dsTax: TDataSource
    DataSet = ibdsTax
    Left = 165
    Top = 357
  end
end
