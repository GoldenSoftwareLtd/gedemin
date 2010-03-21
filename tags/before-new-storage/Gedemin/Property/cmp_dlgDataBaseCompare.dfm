object dlg_DataBaseCompare: Tdlg_DataBaseCompare
  Left = 1351
  Top = 90
  Width = 987
  Height = 666
  Caption = 'Сравнение таблиц'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 979
    Height = 639
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Сравнение таблиц'
    TabOrder = 0
    object pcMain: TSuperPageControl
      Left = 0
      Top = 0
      Width = 979
      Height = 620
      BorderStyle = bsNone
      TabsVisible = True
      ActivePage = tsTriggers
      Align = alClient
      TabHeight = 23
      TabOrder = 0
      object tsTable: TSuperTabSheet
        Caption = 'Таблица'
        object spTable: TSplitter
          Left = 450
          Top = 0
          Width = 4
          Height = 597
          Cursor = crHSplit
          Beveled = True
        end
        object pnTblLeft: TPanel
          Left = 0
          Top = 0
          Width = 450
          Height = 597
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object lblRelationNameLeft: TLabel
            Left = 8
            Top = 24
            Width = 219
            Height = 13
            Caption = 'Название таблицы (на английском языке):'
          end
          object lblLNameLeft: TLabel
            Left = 8
            Top = 58
            Width = 186
            Height = 13
            Caption = 'Локализованное название таблицы:'
          end
          object lblShotNameLeft: TLabel
            Left = 8
            Top = 88
            Width = 142
            Height = 13
            Caption = 'Краткое название таблицы:'
          end
          object lblDescriptionLeft: TLabel
            Left = 8
            Top = 120
            Width = 99
            Height = 13
            Caption = 'Описание таблицы:'
          end
          object lblListFieldLeft: TLabel
            Left = 8
            Top = 226
            Width = 205
            Height = 13
            Caption = 'Поле для отображения (на английском):'
          end
          object lblExtendedFieldLeft: TLabel
            Left = 8
            Top = 256
            Width = 217
            Height = 26
            Caption = 
              'Поля для расширенного отображения  (на английском через запятую)' +
              ':'
            WordWrap = True
          end
          object edRelationNameLeft: TEdit
            Left = 254
            Top = 20
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 0
          end
          object edLNameLeft: TEdit
            Left = 254
            Top = 56
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 1
          end
          object edLShortNameLeft: TEdit
            Left = 254
            Top = 86
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 2
          end
          object edDescriptionLeft: TEdit
            Left = 254
            Top = 116
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 3
          end
          object edListFieldLeft: TEdit
            Left = 254
            Top = 224
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 4
          end
          object edExtendedFieldLeft: TEdit
            Left = 254
            Top = 256
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 5
          end
        end
        object pnTblRight: TPanel
          Left = 454
          Top = 0
          Width = 525
          Height = 597
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object lblRelationNameRight: TLabel
            Left = 81
            Top = 24
            Width = 219
            Height = 13
            Caption = 'Название таблицы (на английском языке):'
          end
          object lblLNameRight: TLabel
            Left = 81
            Top = 58
            Width = 186
            Height = 13
            Caption = 'Локализованное название таблицы:'
          end
          object lblShotNameRight: TLabel
            Left = 81
            Top = 88
            Width = 142
            Height = 13
            Caption = 'Краткое название таблицы:'
          end
          object lblDescriptionRight: TLabel
            Left = 81
            Top = 120
            Width = 99
            Height = 13
            Caption = 'Описание таблицы:'
          end
          object lblListFieldRight: TLabel
            Left = 81
            Top = 226
            Width = 205
            Height = 13
            Caption = 'Поле для отображения (на английском):'
          end
          object lblExtendedFieldRight: TLabel
            Left = 81
            Top = 256
            Width = 217
            Height = 26
            Caption = 
              'Поля для расширенного отображения  (на английском через запятую)' +
              ':'
            WordWrap = True
          end
          object edRelationNameRight: TEdit
            Left = 327
            Top = 20
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 0
          end
          object edLNameRight: TEdit
            Left = 327
            Top = 56
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 1
          end
          object edLShortNameRight: TEdit
            Left = 327
            Top = 86
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 2
          end
          object edDescriptionRight: TEdit
            Left = 327
            Top = 116
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 3
          end
          object edListFieldRight: TEdit
            Left = 327
            Top = 224
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 4
          end
          object edExtendedFieldRight: TEdit
            Left = 327
            Top = 256
            Width = 161
            Height = 21
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 5
          end
        end
      end
      object tsFields: TSuperTabSheet
        Caption = 'Поля'
        object spField: TSplitter
          Left = 441
          Top = 0
          Width = 4
          Height = 597
          Cursor = crHSplit
          Beveled = True
        end
        object pnFieldLeft: TPanel
          Left = 0
          Top = 0
          Width = 441
          Height = 597
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object ibgrFieldLeft: TgsIBGrid
            Left = 0
            Top = 0
            Width = 441
            Height = 597
            Align = alClient
            DataSource = dsFieldLeft
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.Visible = False
            CheckBox.FirstColumn = False
            ScaleColumns = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
          end
        end
        object pnFieldRight: TPanel
          Left = 445
          Top = 0
          Width = 534
          Height = 597
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object ibgrFieldRight: TgsIBGrid
            Left = 0
            Top = 0
            Width = 534
            Height = 597
            Align = alClient
            DataSource = dsFieldRight
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.Visible = False
            CheckBox.FirstColumn = False
            ScaleColumns = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
          end
        end
      end
      object tsTriggers: TSuperTabSheet
        Caption = 'Триггеры'
        object pnTriggerMain: TPanel
          Left = 0
          Top = 0
          Width = 979
          Height = 597
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object Splitter3: TSplitter
            Left = 0
            Top = 131
            Width = 979
            Height = 4
            Cursor = crVSplit
            Align = alTop
          end
          object pnTriggerTop: TPanel
            Left = 0
            Top = 0
            Width = 979
            Height = 131
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object Splitter2: TSplitter
              Left = 449
              Top = 0
              Width = 4
              Height = 131
              Cursor = crHSplit
            end
            object pnTriggerLeft: TPanel
              Left = 0
              Top = 0
              Width = 449
              Height = 131
              Align = alLeft
              BevelOuter = bvNone
              TabOrder = 0
              object tvTriggerLeft: TTreeView
                Left = 0
                Top = 0
                Width = 449
                Height = 131
                Align = alClient
                Images = dmImages.ilToolBarSmall
                Indent = 19
                TabOrder = 0
                OnChange = tvTriggerLeftChange
                OnCustomDrawItem = tvTriggerLeftCustomDrawItem
                Items.Data = {
                  06000000260000001C0000001C000000FFFFFFFFFFFFFFFF0000000000000000
                  0D4265666F726520496E73657274250000001C0000001C000000FFFFFFFFFFFF
                  FFFF00000000000000000C416674657220496E73657274260000001C0000001C
                  000000FFFFFFFFFFFFFFFF00000000000000000D4265666F7265205570646174
                  65250000001C0000001C000000FFFFFFFFFFFFFFFF00000000000000000C4166
                  74657220557064617465260000001C0000001C000000FFFFFFFFFFFFFFFF0000
                  0000000000000D4265666F72652044656C657465250000001C0000001C000000
                  FFFFFFFFFFFFFFFF00000000000000000C41667465722044656C657465}
              end
            end
            object pnTriggerRight: TPanel
              Left = 453
              Top = 0
              Width = 526
              Height = 131
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 1
              object tvTriggerRight: TTreeView
                Left = 0
                Top = 0
                Width = 526
                Height = 131
                Align = alClient
                Images = dmImages.ilToolBarSmall
                Indent = 19
                TabOrder = 0
                OnChange = tvTriggerRightChange
                OnCustomDrawItem = tvTriggerLeftCustomDrawItem
                Items.Data = {
                  06000000260000001C0000001C000000FFFFFFFFFFFFFFFF0000000000000000
                  0D4265666F726520496E73657274250000001C0000001C000000FFFFFFFFFFFF
                  FFFF00000000000000000C416674657220496E73657274260000001C0000001C
                  000000FFFFFFFFFFFFFFFF00000000000000000D4265666F7265205570646174
                  65250000001C0000001C000000FFFFFFFFFFFFFFFF00000000000000000C4166
                  74657220557064617465260000001C0000001C000000FFFFFFFFFFFFFFFF0000
                  0000000000000D4265666F72652044656C657465250000001C0000001C000000
                  FFFFFFFFFFFFFFFF00000000000000000C41667465722044656C657465}
              end
            end
          end
          object pnTriggerBottom: TPanel
            Left = 0
            Top = 135
            Width = 979
            Height = 462
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
          end
        end
      end
      object tsIndices: TSuperTabSheet
        Caption = 'Индексы'
        object Splitter4: TSplitter
          Left = 497
          Top = 0
          Width = 4
          Height = 597
          Cursor = crHSplit
        end
        object pnIndicesLeft: TPanel
          Left = 0
          Top = 0
          Width = 497
          Height = 597
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object ibgrIndicesLeft: TgsIBGrid
            Left = 0
            Top = 0
            Width = 497
            Height = 597
            Align = alClient
            DataSource = dsIndicesLeft
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.Visible = False
            CheckBox.FirstColumn = False
            ScaleColumns = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
          end
        end
        object pnIndicesRight: TPanel
          Left = 501
          Top = 0
          Width = 478
          Height = 597
          Align = alClient
          Caption = 'pnIndicesRight'
          TabOrder = 1
          object ibgrIndicesRight: TgsIBGrid
            Left = 1
            Top = 1
            Width = 476
            Height = 595
            Align = alClient
            DataSource = dsIndicesRight
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.Visible = False
            CheckBox.FirstColumn = False
            ScaleColumns = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
          end
        end
      end
      object tsCheck: TSuperTabSheet
        Caption = 'Ограничения'
        object Splitter1: TSplitter
          Left = 449
          Top = 0
          Width = 4
          Height = 597
          Cursor = crHSplit
          Beveled = True
        end
        object pnCheckLeft: TPanel
          Left = 0
          Top = 0
          Width = 449
          Height = 597
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object ibgrCheckLeft: TgsIBGrid
            Left = 0
            Top = 0
            Width = 449
            Height = 597
            Align = alClient
            DataSource = dsCheckLeft
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.Visible = False
            CheckBox.FirstColumn = False
            ScaleColumns = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
          end
        end
        object pnCheckRight: TPanel
          Left = 453
          Top = 0
          Width = 526
          Height = 597
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object ibgrCheckRight: TgsIBGrid
            Left = 0
            Top = 0
            Width = 526
            Height = 597
            Align = alClient
            DataSource = dsCheckRight
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.Visible = False
            CheckBox.FirstColumn = False
            ScaleColumns = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
          end
        end
      end
    end
    object sbDBCompare: TStatusBar
      Left = 0
      Top = 620
      Width = 979
      Height = 19
      Panels = <
        item
          Width = 100
        end
        item
          Alignment = taRightJustify
          Width = 50
        end>
      SimplePanel = False
    end
  end
  object ibdsFieldLeft: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  F.REFTABLE AS REFRELATIONNAME, '
      '  F.REFLISTFIELD, '
      '  F.SETTABLE AS REFCROSSRELATION, '
      '  F.SETLISTFIELD, '
      '  F.SETLISTFIELDKEY, '
      '  REL.RELATIONTYPE, '
      '  RDBF.RDB$CHARACTER_LENGTH AS STRINGLENGTH, '
      '  RF.RDB$DEFAULT_SOURCE AS DEFSOURCE, '
      '  RDBF.RDB$COMPUTED_SOURCE AS COMPUTED_VALUE, '
      '  RDBF.RDB$NULL_FLAG AS SOURCENULLFLAG, '
      '  RF.RDB$NULL_FLAG AS NULLFLAG, '
      '  RF.RDB$FIELD_POSITION, '
      '  Z.ID, '
      '  Z.FIELDNAME, '
      '  Z.RELATIONNAME, '
      '  Z.FIELDSOURCE, '
      '  Z.CROSSTABLE, '
      '  Z.CROSSFIELD, '
      '  Z.RELATIONKEY, '
      '  Z.FIELDSOURCEKEY, '
      '  Z.CROSSTABLEKEY, '
      '  Z.CROSSFIELDKEY, '
      '  Z.LNAME, '
      '  Z.LSHORTNAME, '
      '  Z.DESCRIPTION, '
      '  Z.VISIBLE, '
      '  Z.FORMAT, '
      '  Z.ALIGNMENT, '
      '  Z.COLWIDTH, '
      '  Z.READONLY, '
      '  Z.GDCLASSNAME, '
      '  Z.GDSUBTYPE, '
      '  Z.AFULL, '
      '  Z.ACHAG, '
      '  Z.AVIEW, '
      '  Z.OBJECTS, '
      '  Z.DELETERULE, '
      '  Z.EDITIONDATE, '
      '  Z.EDITORKEY, '
      '  Z.RESERVED '
      'FROM '
      '  AT_RELATION_FIELDS Z'
      '    LEFT JOIN '
      '      AT_RELATIONS REL'
      '    ON '
      '      Z.RELATIONKEY  =  REL.ID'
      '    LEFT JOIN '
      '      AT_FIELDS F'
      '    ON '
      '      Z.FIELDSOURCEKEY  =  F.ID'
      '    LEFT JOIN '
      '      RDB$FIELDS RDBF'
      '    ON '
      '      F.FIELDNAME  =  RDBF.RDB$FIELD_NAME'
      '    LEFT JOIN '
      '      RDB$RELATION_FIELDS RF'
      '    ON '
      '      RF.RDB$FIELD_NAME  =  Z.FIELDNAME'
      '         AND '
      '      RF.RDB$RELATION_NAME  =  Z.RELATIONNAME'
      'WHERE '
      '  Z.RELATIONKEY  =  :relationkey'
      'ORDER BY '
      '  RDB$FIELD_POSITION')
    Left = 80
    Top = 399
  end
  object dsFieldLeft: TDataSource
    DataSet = ibdsFieldLeft
    Left = 80
    Top = 431
  end
  object ExtTr: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 472
    Top = 416
  end
  object dsFieldRight: TDataSource
    DataSet = ibdsFieldRight
    Left = 536
    Top = 432
  end
  object ibdsFieldRight: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  F.REFTABLE AS REFRELATIONNAME, '
      '  F.REFLISTFIELD, '
      '  F.SETTABLE AS REFCROSSRELATION, '
      '  F.SETLISTFIELD, '
      '  F.SETLISTFIELDKEY, '
      '  REL.RELATIONTYPE, '
      '  RDBF.RDB$CHARACTER_LENGTH AS STRINGLENGTH, '
      '  RF.RDB$DEFAULT_SOURCE AS DEFSOURCE, '
      '  RDBF.RDB$COMPUTED_SOURCE AS COMPUTED_VALUE, '
      '  RDBF.RDB$NULL_FLAG AS SOURCENULLFLAG, '
      '  RF.RDB$NULL_FLAG AS NULLFLAG, '
      '  RF.RDB$FIELD_POSITION, '
      '  Z.ID, '
      '  Z.FIELDNAME, '
      '  Z.RELATIONNAME, '
      '  Z.FIELDSOURCE, '
      '  Z.CROSSTABLE, '
      '  Z.CROSSFIELD, '
      '  Z.RELATIONKEY, '
      '  Z.FIELDSOURCEKEY, '
      '  Z.CROSSTABLEKEY, '
      '  Z.CROSSFIELDKEY, '
      '  Z.LNAME, '
      '  Z.LSHORTNAME, '
      '  Z.DESCRIPTION, '
      '  Z.VISIBLE, '
      '  Z.FORMAT, '
      '  Z.ALIGNMENT, '
      '  Z.COLWIDTH, '
      '  Z.READONLY, '
      '  Z.GDCLASSNAME, '
      '  Z.GDSUBTYPE, '
      '  Z.AFULL, '
      '  Z.ACHAG, '
      '  Z.AVIEW, '
      '  Z.OBJECTS, '
      '  Z.DELETERULE, '
      '  Z.EDITIONDATE, '
      '  Z.EDITORKEY, '
      '  Z.RESERVED '
      'FROM '
      '  AT_RELATION_FIELDS Z'
      '    LEFT JOIN '
      '      AT_RELATIONS REL'
      '    ON '
      '      Z.RELATIONKEY  =  REL.ID'
      '    LEFT JOIN '
      '      AT_FIELDS F'
      '    ON '
      '      Z.FIELDSOURCEKEY  =  F.ID'
      '    LEFT JOIN '
      '      RDB$FIELDS RDBF'
      '    ON '
      '      F.FIELDNAME  =  RDBF.RDB$FIELD_NAME'
      '    LEFT JOIN '
      '      RDB$RELATION_FIELDS RF'
      '    ON '
      '      RF.RDB$FIELD_NAME  =  Z.FIELDNAME'
      '         AND '
      '      RF.RDB$RELATION_NAME  =  Z.RELATIONNAME'
      'WHERE '
      '  Z.RELATIONKEY  =  :relationkey'
      'ORDER BY '
      '  RDB$FIELD_POSITION')
    ReadTransaction = ExtTr
    Left = 536
    Top = 400
  end
  object dsCheckLeft: TDataSource
    DataSet = ibdsCheckLeft
    Left = 120
    Top = 431
  end
  object ibdsCheckLeft: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  T.RDB$TRIGGER_SOURCE, '
      '  T.RDB$RELATION_NAME, '
      '  Z.ID, '
      '  Z.CHECKNAME, '
      '  Z.MSG'
      ' '
      'FROM '
      '  AT_CHECK_CONSTRAINTS Z'
      '    LEFT JOIN '
      '      RDB$CHECK_CONSTRAINTS C'
      '    ON '
      '      C.RDB$CONSTRAINT_NAME  =  Z.CHECKNAME'
      '    LEFT JOIN '
      '      RDB$TRIGGERS T'
      '    ON '
      '      T.RDB$TRIGGER_NAME  =  C.RDB$TRIGGER_NAME'
      '    LEFT JOIN '
      '      AT_RELATIONS R'
      '    ON '
      '      R.RELATIONNAME  =  T.RDB$RELATION_NAME'
      ''
      'WHERE '
      '  T.RDB$TRIGGER_TYPE  =  1'
      '     AND '
      '  R.ID  =  :relationkey')
    Left = 120
    Top = 400
  end
  object dsCheckRight: TDataSource
    DataSet = ibdsCheckRight
    Left = 581
    Top = 431
  end
  object ibdsCheckRight: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  T.RDB$TRIGGER_SOURCE, '
      '  T.RDB$RELATION_NAME, '
      '  Z.ID, '
      '  Z.CHECKNAME, '
      '  Z.MSG'
      ' '
      'FROM '
      '  AT_CHECK_CONSTRAINTS Z'
      '    LEFT JOIN '
      '      RDB$CHECK_CONSTRAINTS C'
      '    ON '
      '      C.RDB$CONSTRAINT_NAME  =  Z.CHECKNAME'
      '    LEFT JOIN '
      '      RDB$TRIGGERS T'
      '    ON '
      '      T.RDB$TRIGGER_NAME  =  C.RDB$TRIGGER_NAME'
      '    LEFT JOIN '
      '      AT_RELATIONS R'
      '    ON '
      '      R.RELATIONNAME  =  T.RDB$RELATION_NAME'
      ''
      'WHERE '
      '  T.RDB$TRIGGER_TYPE  =  1'
      '     AND '
      '  R.ID  =  :relationkey')
    ReadTransaction = ExtTr
    Left = 584
    Top = 400
  end
  object dsIndicesLeft: TDataSource
    DataSet = ibdsIndicesLeft
    Left = 157
    Top = 431
  end
  object ibdsIndicesLeft: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  RI.RDB$INDEX_NAME, '
      '  RI.RDB$RELATION_NAME, '
      '  RI.RDB$INDEX_ID, '
      '  RI.RDB$UNIQUE_FLAG, '
      '  RI.RDB$DESCRIPTION, '
      '  RI.RDB$SEGMENT_COUNT, '
      '  RI.RDB$INDEX_INACTIVE, '
      '  RI.RDB$INDEX_TYPE, '
      '  RI.RDB$FOREIGN_KEY, '
      '  RI.RDB$SYSTEM_FLAG, '
      '  0 AS CHANGEACTIVE, '
      '  0 AS CHANGEDATA, '
      '  Z.ID, '
      '  Z.INDEXNAME, '
      '  Z.RELATIONNAME, '
      '  Z.FIELDSLIST, '
      '  Z.RELATIONKEY, '
      '  Z.UNIQUE_FLAG, '
      '  Z.INDEX_INACTIVE, '
      '  Z.EDITIONDATE, '
      '  Z.EDITORKEY'
      ' '
      'FROM '
      '  AT_INDICES Z'
      '    LEFT JOIN '
      '      RDB$INDICES RI'
      '    ON '
      '      RI.RDB$INDEX_NAME  =  Z.INDEXNAME'
      ''
      'WHERE '
      '  Z.RELATIONKEY  =  :relationkey')
    Left = 160
    Top = 400
  end
  object dsIndicesRight: TDataSource
    DataSet = ibdsIndicesRight
    Left = 621
    Top = 431
  end
  object ibdsIndicesRight: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  RI.RDB$INDEX_NAME, '
      '  RI.RDB$RELATION_NAME, '
      '  RI.RDB$INDEX_ID, '
      '  RI.RDB$UNIQUE_FLAG, '
      '  RI.RDB$DESCRIPTION, '
      '  RI.RDB$SEGMENT_COUNT, '
      '  RI.RDB$INDEX_INACTIVE, '
      '  RI.RDB$INDEX_TYPE, '
      '  RI.RDB$FOREIGN_KEY, '
      '  RI.RDB$SYSTEM_FLAG, '
      '  0 AS CHANGEACTIVE, '
      '  0 AS CHANGEDATA, '
      '  Z.ID, '
      '  Z.INDEXNAME, '
      '  Z.RELATIONNAME, '
      '  Z.FIELDSLIST, '
      '  Z.RELATIONKEY, '
      '  Z.UNIQUE_FLAG, '
      '  Z.INDEX_INACTIVE, '
      '  Z.EDITIONDATE, '
      '  Z.EDITORKEY'
      ' '
      'FROM '
      '  AT_INDICES Z'
      '    LEFT JOIN '
      '      RDB$INDICES RI'
      '    ON '
      '      RI.RDB$INDEX_NAME  =  Z.INDEXNAME'
      ''
      'WHERE '
      '  Z.RELATIONKEY  =  :relationkey')
    Left = 621
    Top = 399
  end
end
