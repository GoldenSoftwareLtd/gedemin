object dlgChooseEntryVar: TdlgChooseEntryVar
  Left = 294
  Top = 103
  Width = 478
  Height = 475
  Caption = 'Выбор переменной'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 376
    Height = 448
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object gsibgrVariable: TgsIBGrid
      Left = 5
      Top = 5
      Width = 366
      Height = 438
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsFields
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
      TabOrder = 0
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.DisplayField = 'LNAME'
      CheckBox.FieldName = 'FT'
      CheckBox.Visible = True
      MinColWidth = 40
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
          FieldName = 'RLNAME'
          Title.Caption = 'Таблица'
          Width = 124
          Visible = True
        end
        item
          Alignment = taLeftJustify
          Expanded = False
          FieldName = 'LSHORTNAME'
          Title.Caption = 'Поле - кратко'
          Width = 124
          Visible = True
        end
        item
          Alignment = taLeftJustify
          Expanded = False
          FieldName = 'RLSHORTNAME'
          Title.Caption = 'Таблица кратко'
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
        end
        item
          Alignment = taLeftJustify
          Expanded = False
          FieldName = 'FT'
          Title.Caption = 'FT'
          Width = -1
          Visible = False
        end>
    end
  end
  object Panel2: TPanel
    Left = 376
    Top = 0
    Width = 94
    Height = 448
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object bOk: TButton
      Left = 10
      Top = 7
      Width = 75
      Height = 25
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object bCancel: TButton
      Left = 10
      Top = 37
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ibdsFields: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT '
      '  RF.LName, RF.LShortName, R.LNAME as RLNAME,   '
      
        '  R.LSHORTNAME AS RLSHORTNAME, RF.FIELDNAME,     RF.RELATIONNAME' +
        ', '
      '  RF.RELATIONNAME || '#39'&'#39' || RF.FIELDNAME AS FT'
      'FROM '
      ' GD_DOCUMENTTRTYPE DTT JOIN   GD_RELATIONTYPEDOC RTD '
      '     ON DTT.DOCUMENTTYPEKEY = RTD.DOCTYPEKEY '
      '         AND DTT.TRTYPEKEY = :TRTYPEKEY'
      ' JOIN AT_RELATIONS R'
      '    ON RTD.RELATIONNAME = R.RELATIONNAME'
      'JOIN  AT_RELATION_FIELDS RF '
      '    ON R.RELATIONNAME =     RF.RELATIONNAME'
      'WHERE'
      '  RF.LShortName IS NOT NULL'
      'ORDER BY'
      '  RF.RELATIONNAME, RF.FIELDNAME')
    Left = 176
    Top = 104
    object ibdsFieldsLNAME: TIBStringField
      DisplayLabel = 'Поле'
      DisplayWidth = 20
      FieldName = 'LNAME'
      Required = True
      Size = 60
    end
    object ibdsFieldsRLNAME: TIBStringField
      DisplayLabel = 'Таблица'
      DisplayWidth = 20
      FieldName = 'RLNAME'
      Required = True
      Size = 60
    end
    object ibdsFieldsLSHORTNAME: TIBStringField
      DisplayLabel = 'Поле - кратко'
      FieldName = 'LSHORTNAME'
    end
    object ibdsFieldsRLSHORTNAME: TIBStringField
      DisplayLabel = 'Таблица кратко'
      DisplayWidth = 20
      FieldName = 'RLSHORTNAME'
      Required = True
      Size = 60
    end
    object ibdsFieldsFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object ibdsFieldsRELATIONNAME: TIBStringField
      FieldName = 'RELATIONNAME'
      Required = True
      Visible = False
      Size = 31
    end
    object ibdsFieldsFT: TIBStringField
      FieldName = 'FT'
      Required = True
      Visible = False
      Size = 63
    end
  end
  object dsFields: TDataSource
    DataSet = ibdsFields
    Left = 208
    Top = 104
  end
end
