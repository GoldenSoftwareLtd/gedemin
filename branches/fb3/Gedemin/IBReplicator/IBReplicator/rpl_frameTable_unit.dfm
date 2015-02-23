object frameTable: TframeTable
  Left = 0
  Top = 0
  Width = 485
  Height = 322
  TabOrder = 0
  object PageControl: TSuperPageControl
    Left = 0
    Top = 0
    Width = 485
    Height = 322
    BorderStyle = bsNone
    TabsVisible = True
    ActivePage = tsData
    Align = alClient
    TabHeight = 23
    TabOrder = 0
    OnChange = PageControlChange
    object tsFields: TSuperTabSheet
      Caption = #1055#1086#1083#1103
      object pCaption: TPanel
        Left = 0
        Top = 0
        Width = 485
        Height = 17
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = 'pCaption'
        Color = clInactiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
      end
      object Panel1: TPanel
        Left = 0
        Top = 17
        Width = 485
        Height = 282
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 1
        object gFields: TxpDBGrid
          Left = 1
          Top = 1
          Width = 483
          Height = 280
          Align = alClient
          BorderStyle = bsNone
          Ctl3D = False
          DataSource = dsFields
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
          ParentCtl3D = False
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = []
          Columns = <
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'PK'
              Font.Charset = SYMBOL_CHARSET
              Font.Color = clWindowText
              Font.Height = -16
              Font.Name = 'Wingdings'
              Font.Style = []
              Width = 20
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'FK'
              Font.Charset = SYMBOL_CHARSET
              Font.Color = clWindowText
              Font.Height = -16
              Font.Name = 'Wingdings'
              Font.Style = []
              Width = 18
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'FIELDNAME'
              Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077
              Width = 68
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'FIELDTYPE_CALC'
              Title.Caption = #1058#1080#1087
              Width = 48
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'DOMANENAME'
              Title.Caption = #1044#1086#1084#1077#1085
              Width = 56
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'FIELDLENGTH'
              Title.Caption = #1044#1083#1080#1085#1072
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'FIELDPRECISION'
              Title.Caption = #1058#1086#1095#1085#1086#1089#1090#1100
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'FIELDSUBTYPE_CALC'
              Title.Caption = #1055#1086#1076#1090#1080#1087
              Width = 40
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'NOTNULL'
              Font.Charset = SYMBOL_CHARSET
              Font.Color = clWindowText
              Font.Height = -16
              Font.Name = 'Wingdings'
              Font.Style = []
              Title.Caption = 'Not Null'
              Width = 47
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'CHARSET'
              Title.Caption = #1050#1086#1076#1080#1088#1086#1074#1082#1072
              Width = 79
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'COLLATENAME'
              Title.Caption = #1057#1086#1087#1086#1089#1090#1072#1074#1080#1090#1100
              Width = 97
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'COMPETEDSOURCE_CALC'
              Title.Caption = #1042#1099#1095#1080#1089#1083#1080#1090#1100' '#1082#1072#1082'...'
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'DEFAULTSOURCE_CALC'
              Title.Caption = #1047#1085#1072#1095#1077#1085#1080#1077' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'DESCRIPTION_CALC'
              Title.Caption = #1054#1087#1080#1089#1072#1085#1080#1077
              Visible = True
            end>
        end
      end
    end
    object tsConstraints: TSuperTabSheet
      Caption = #1054#1075#1088#1072#1085#1080#1095#1077#1085#1080#1103
      object pcConstraints: TSuperPageControl
        Left = 0
        Top = 0
        Width = 485
        Height = 299
        BorderStyle = bsNone
        TabsVisible = True
        ActivePage = tsUniques
        Align = alClient
        TabHeight = 23
        TabOrder = 0
        OnChange = pcConstraintsChange
        object tsPrimaryKey: TSuperTabSheet
          Caption = '1.'#1055#1077#1088#1074#1080#1095#1085#1099#1081' '#1082#1083#1102#1095
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 563
            Height = 276
            Align = alClient
            BevelInner = bvLowered
            BevelOuter = bvNone
            BorderWidth = 3
            TabOrder = 0
            object gPrimeKeys: TxpDBGrid
              Left = 4
              Top = 4
              Width = 555
              Height = 268
              Align = alClient
              BorderStyle = bsNone
              DataSource = dsPrimeKeys
              Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
              ReadOnly = True
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'MS Sans Serif'
              TitleFont.Style = []
              Columns = <
                item
                  Expanded = False
                  FieldName = 'CONSTAINTNAME'
                  Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1086#1075#1088#1072#1085#1080#1095#1077#1085#1080#1103
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'FIELDNAME'
                  Title.Caption = #1053#1072' '#1087#1086#1083#1077
                  Visible = True
                end>
            end
          end
        end
        object tsForeignKey: TSuperTabSheet
          Caption = '2.'#1042#1085#1077#1096#1085#1080#1077' '#1089#1089#1099#1083#1082#1080
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 563
            Height = 276
            Align = alClient
            BevelInner = bvLowered
            BevelOuter = bvNone
            BorderWidth = 3
            TabOrder = 0
            object gForeignKeys: TxpDBGrid
              Left = 4
              Top = 4
              Width = 555
              Height = 268
              Align = alClient
              BorderStyle = bsNone
              DataSource = dsForeignKeys
              Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
              ReadOnly = True
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'MS Sans Serif'
              TitleFont.Style = []
              Columns = <
                item
                  Expanded = False
                  FieldName = 'CONSTRAINTNAME'
                  Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1086#1075#1088#1072#1085#1080#1095#1077#1085#1080#1103
                  Width = 138
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'FIELDNAME'
                  Title.Caption = #1053#1072' '#1087#1086#1083#1077
                  Width = 166
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'REFRELATIONNAME'
                  Title.Caption = #1042#1085#1077#1096#1085#1103#1103' '#1090#1072#1073#1083#1080#1094#1072
                  Width = 161
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'REFFIELDNAME'
                  Title.Caption = #1042#1085#1077#1096#1085#1077#1077' '#1087#1086#1083#1077
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'UPDATERULE'
                  Title.Caption = #1055#1088#1072#1074#1080#1083#1086' '#1080#1079#1084#1077#1085#1077#1085#1080#1103
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'DELETERULE'
                  Title.Caption = #1055#1088#1072#1074#1080#1083#1086' '#1091#1076#1072#1083#1077#1085#1080#1103
                  Visible = True
                end>
            end
          end
        end
        object tsChecks: TSuperTabSheet
          Caption = '3. '#1050#1086#1085#1090#1088#1086#1083#1100
          object Panel4: TPanel
            Left = 0
            Top = 0
            Width = 563
            Height = 276
            Align = alClient
            BevelInner = bvLowered
            BevelOuter = bvNone
            BorderWidth = 3
            TabOrder = 0
            object gChecks: TxpDBGrid
              Left = 4
              Top = 4
              Width = 555
              Height = 268
              Align = alClient
              BorderStyle = bsNone
              DataSource = dsChecks
              Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
              ReadOnly = True
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'MS Sans Serif'
              TitleFont.Style = []
              Columns = <
                item
                  Expanded = False
                  FieldName = 'CONSTAINTNAME'
                  Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1086#1075#1088#1072#1085#1080#1095#1077#1085#1080#1103
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'CHECKCLAUSE_CALC'
                  Title.Caption = #1059#1089#1083#1086#1074#1080#1077
                  Width = 329
                  Visible = True
                end>
            end
          end
        end
        object tsUniques: TSuperTabSheet
          Caption = '4. '#1059#1085#1080#1082#1072#1083#1100#1085#1099#1077
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 563
            Height = 276
            Align = alClient
            BevelInner = bvLowered
            BevelOuter = bvNone
            BorderWidth = 3
            TabOrder = 0
            object gUnique: TxpDBGrid
              Left = 4
              Top = 4
              Width = 555
              Height = 268
              Align = alClient
              BorderStyle = bsNone
              DataSource = dsUniques
              Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
              ReadOnly = True
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'MS Sans Serif'
              TitleFont.Style = []
              Columns = <
                item
                  Expanded = False
                  FieldName = 'CONSTAINTNAME'
                  Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1086#1075#1088#1072#1085#1080#1095#1077#1085#1080#1103
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'FIELDNAME'
                  Title.Caption = #1053#1072' '#1087#1086#1083#1077
                  Visible = True
                end>
            end
          end
        end
      end
    end
    object tsIndices: TSuperTabSheet
      Caption = #1048#1085#1076#1077#1082#1089#1099
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 485
        Height = 299
        Align = alClient
        BevelInner = bvLowered
        BevelOuter = bvNone
        BorderWidth = 3
        TabOrder = 0
        object gIndices: TxpDBGrid
          Left = 4
          Top = 4
          Width = 477
          Height = 291
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsIndices
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              FieldName = 'INDEXNAME'
              Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1080#1085#1076#1077#1082#1089#1072
              Width = 146
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'FIELDNAME'
              Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1086#1083#1103
              Width = 121
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'UNIQUEFLAG_CALC'
              Font.Charset = SYMBOL_CHARSET
              Font.Color = clWindowText
              Font.Height = -16
              Font.Name = 'Wingdings'
              Font.Style = []
              Title.Caption = #1059#1085#1080#1082#1072#1083#1100#1085#1099#1081
              Width = 69
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'EXPRESSIONSOURCE_CALC'
              Title.Caption = #1042#1099#1088#1072#1078#1077#1085#1080#1077
              Width = 109
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'INDEXINACTIVE_CALC'
              Font.Charset = SYMBOL_CHARSET
              Font.Color = clWindowText
              Font.Height = -16
              Font.Name = 'Wingdings'
              Font.Style = []
              Title.Caption = #1057#1086#1089#1090#1086#1103#1085#1080#1077
              Width = 59
              Visible = True
            end>
        end
      end
    end
    object tsDependencies: TSuperTabSheet
      Caption = #1047#1072#1074#1080#1089#1080#1084#1086#1089#1090#1080
      object sDepend: TSplitter
        Left = 0
        Top = 204
        Width = 485
        Height = 3
        Cursor = crVSplit
        Align = alBottom
        AutoSnap = False
        Visible = False
      end
      object pDepend: TPanel
        Left = 0
        Top = 207
        Width = 485
        Height = 92
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        Visible = False
      end
      object Panel8: TPanel
        Left = 0
        Top = 0
        Width = 485
        Height = 204
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Splitter3: TSplitter
          Left = 233
          Top = 0
          Height = 204
          AutoSnap = False
        end
        object Panel9: TPanel
          Left = 0
          Top = 0
          Width = 233
          Height = 204
          Align = alLeft
          BevelOuter = bvLowered
          TabOrder = 0
          object pDependOn: TPanel
            Left = 1
            Top = 1
            Width = 231
            Height = 17
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvNone
            Caption = ' '
            Color = clInactiveCaption
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clCaptionText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 0
          end
          object lbDependOn: TListBox
            Left = 1
            Top = 18
            Width = 231
            Height = 185
            Align = alClient
            BorderStyle = bsNone
            ItemHeight = 13
            TabOrder = 1
            OnClick = lbDependOnClick
          end
        end
        object Panel10: TPanel
          Left = 236
          Top = 0
          Width = 249
          Height = 204
          Align = alClient
          BevelOuter = bvLowered
          TabOrder = 1
          object pDependsOn: TPanel
            Left = 1
            Top = 1
            Width = 247
            Height = 17
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvNone
            Color = clInactiveCaption
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clCaptionText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 0
          end
          object lbDependsOn: TListBox
            Left = 1
            Top = 18
            Width = 247
            Height = 185
            Align = alClient
            BorderStyle = bsNone
            ItemHeight = 13
            TabOrder = 1
            OnClick = lbDependOnClick
          end
        end
      end
    end
    object tsData: TSuperTabSheet
      Caption = #1044#1072#1085#1085#1099#1077
      inline frameTableData: TframeTableData
        Left = 0
        Top = 0
        Width = 485
        Height = 299
        Align = alClient
        TabOrder = 0
        inherited sFilter: TSplitter
          Top = 129
        end
        inherited Panel5: TPanel
          Top = 272
        end
        inherited pFilter: TPanel
          Top = 132
          inherited Panel3: TPanel
            inherited lvFilter: TXPListView
              Items.Data = {
                B40100000C00000000000000FFFFFFFFFFFFFFFF030000000000000006736466
                617364067361667364660473616466076173646661736400000000FFFFFFFFFF
                FFFFFF0300000000000000067364666173640673616673646604736164660761
                73646661736400000000FFFFFFFFFFFFFFFF0000000000000000046173646600
                000000FFFFFFFFFFFFFFFF000000000000000008617364666173646600000000
                FFFFFFFFFFFFFFFF030000000000000006736466617364067361667364660473
                616466076173646661736400000000FFFFFFFFFFFFFFFF000000000000000004
                6173646600000000FFFFFFFFFFFFFFFF00000000000000000861736466617364
                6600000000FFFFFFFFFFFFFFFF03000000000000000673646661736406736166
                7364660473616466076173646661736400000000FFFFFFFFFFFFFFFF00000000
                00000000046173646600000000FFFFFFFFFFFFFFFF0000000000000000086173
                64666173646600000000FFFFFFFFFFFFFFFF0000000000000000046173646600
                000000FFFFFFFFFFFFFFFF0000000000000000086173646661736466FFFFFFFF
                FFFF3D320000004400001A0000000000005CAD6F}
            end
          end
        end
        inherited Panel2: TPanel
          Height = 129
          inherited pcData: TPageControl
            Height = 102
            inherited tsGrid: TTabSheet
              inherited Panel7: TPanel
                Height = 92
                inherited gData: TrplDBGrid
                  Height = 90
                end
              end
            end
            inherited tsForm: TTabSheet
              inherited frameFormView: TframeFormView
                Height = 92
                inherited ScrollBox: TScrollBox
                  Height = 92
                end
              end
            end
          end
        end
        inherited il16x16: TImageList
          Left = 240
          Top = 56
        end
        inherited ActionList: TActionList
          Left = 208
          Top = 56
        end
        inherited DataSource: TDataSource
          DataSet = DataSet
          Left = 272
          Top = 56
        end
      end
    end
  end
  object dsFields: TDataSource
    DataSet = dFields
    Left = 8
    Top = 80
  end
  object dFields: TIBDataSet
    AfterScroll = dFieldsAfterScroll
    OnCalcFields = dFieldsCalcFields
    BufferChunks = 100
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT '
      '  rf.rdb$field_name as fieldname, '
      '  rf.rdb$field_position as fieldposition,'
      '  rf.rdb$description as description, '
      '  rf.rdb$default_value as defaultvalue, '
      '  rf.rdb$system_flag as systemflag, '
      '  f.rdb$null_flag as domanenullflag, '
      '  rf.rdb$default_source as defaultsource, '
      '  f.rdb$computed_source as computedsource, '
      '  f.rdb$field_length as fieldlength, '
      '  f.rdb$field_name as domanename,  '
      '  f.rdb$field_length as fieldlength,'
      '  f.rdb$field_precision as fieldprecision, '
      '  f.rdb$field_type as fieldtype, '
      '  f.rdb$field_sub_type as fieldsubtype, '
      '  cs.rdb$character_set_name as charset, '
      '  c.rdb$collation_name as collatename,'
      '  rf.rdb$null_flag as fieldnullflag '
      'FROM '
      '  rdb$relation_fields rf '
      
        '  LEFT JOIN rdb$fields f ON rf.rdb$field_source =  f.rdb$field_n' +
        'ame '
      
        '  LEFT JOIN rdb$character_sets cs ON f.rdb$character_set_id =  c' +
        's.rdb$character_set_id '
      
        '  LEFT JOIN rdb$collations c ON c.rdb$collation_id = f.rdb$colla' +
        'tion_id '
      'WHERE rf.rdb$relation_name = /*:relationname*/'#39'GD_FUNCTION'#39)
    Left = 8
    Top = 112
    object dFieldsFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Origin = 'RDB$RELATION_FIELDS.RDB$FIELD_NAME'
      FixedChar = True
      Size = 31
    end
    object dFieldsFIELDTYPE: TSmallintField
      FieldName = 'FIELDTYPE'
      Origin = 'RDB$FIELDS.RDB$FIELD_TYPE'
    end
    object dFieldsDOMANENAME: TIBStringField
      FieldName = 'DOMANENAME'
      Origin = 'RDB$FIELDS.RDB$FIELD_NAME'
      FixedChar = True
      Size = 31
    end
    object dFieldsFIELDPOSITION: TSmallintField
      FieldName = 'FIELDPOSITION'
      Origin = 'RDB$RELATION_FIELDS.RDB$FIELD_POSITION'
    end
    object dFieldsDESCRIPTION: TMemoField
      FieldName = 'DESCRIPTION'
      Origin = 'RDB$RELATION_FIELDS.RDB$DESCRIPTION'
      BlobType = ftMemo
      Size = 8
    end
    object dFieldsDEFAULTVALUE: TBlobField
      FieldName = 'DEFAULTVALUE'
      Origin = 'RDB$RELATION_FIELDS.RDB$DEFAULT_VALUE'
      Size = 8
    end
    object dFieldsSYSTEMFLAG: TSmallintField
      FieldName = 'SYSTEMFLAG'
      Origin = 'RDB$RELATION_FIELDS.RDB$SYSTEM_FLAG'
    end
    object dFieldsNULLFLAG: TSmallintField
      DisplayLabel = 'DOMANENULLFLAG'
      FieldName = 'domanenullflag'
      Origin = 'RDB$RELATION_FIELDS.RDB$NULL_FLAG'
    end
    object dFieldsDEFAULTSOURCE: TMemoField
      FieldName = 'FIELDDEFAULTSOURCE'
      Origin = 'RDB$RELATION_FIELDS.RDB$DEFAULT_SOURCE'
      BlobType = ftMemo
      Size = 8
    end
    object dFieldsCOMPUTEDSOURCE: TMemoField
      FieldName = 'COMPUTEDSOURCE'
      Origin = 'RDB$FIELDS.RDB$COMPUTED_SOURCE'
      BlobType = ftMemo
      Size = 8
    end
    object dFieldsFIELDLENGTH: TSmallintField
      FieldName = 'FIELDLENGTH'
      Origin = 'RDB$FIELDS.RDB$FIELD_LENGTH'
    end
    object dFieldsFIELDPRECISION: TSmallintField
      FieldName = 'FIELDPRECISION'
      Origin = 'RDB$FIELDS.RDB$FIELD_PRECISION'
    end
    object dFieldsFIELDSUBTYPE: TSmallintField
      FieldName = 'FIELDSUBTYPE'
      Origin = 'RDB$FIELDS.RDB$FIELD_SUB_TYPE'
    end
    object dFieldsCHARSET: TIBStringField
      FieldName = 'CHARSET'
      Origin = 'RDB$CHARACTER_SETS.RDB$CHARACTER_SET_NAME'
      FixedChar = True
      Size = 31
    end
    object dFieldsCOLLATENAME: TIBStringField
      FieldName = 'COLLATENAME'
      Origin = 'RDB$COLLATIONS.RDB$COLLATION_NAME'
      FixedChar = True
      Size = 31
    end
    object dFieldsFIELDTYPE_CALC: TStringField
      FieldKind = fkCalculated
      FieldName = 'FIELDTYPE_CALC'
      Calculated = True
    end
    object dFieldsFIELDSUBTYPE_CALC: TStringField
      FieldKind = fkCalculated
      FieldName = 'FIELDSUBTYPE_CALC'
      Calculated = True
    end
    object dFieldsFIELDNULLFLAG: TSmallintField
      FieldName = 'FIELDNULLFLAG'
      Origin = 'RDB$RELATION_FIELDS.RDB$NULL_FLAG'
    end
    object dFieldsNOTNULL: TStringField
      FieldKind = fkCalculated
      FieldName = 'NOTNULL'
      Calculated = True
    end
    object dFieldsCOMPETEDSOURCE_CALC: TStringField
      FieldKind = fkCalculated
      FieldName = 'COMPUTEDSOURCE_CALC'
      Calculated = True
    end
    object dFieldsDEFAULTSOURCE_CALC: TStringField
      FieldKind = fkCalculated
      FieldName = 'DEFAULTSOURCE_CALC'
      Calculated = True
    end
    object dFieldsDOMANEDEFAULTSOURCE: TMemoField
      FieldName = 'DOMANEDEFAULTSOURCE'
      BlobType = ftMemo
    end
    object dFieldsPK: TStringField
      FieldKind = fkCalculated
      FieldName = 'PK'
      Calculated = True
    end
    object dFieldsFK: TStringField
      FieldKind = fkCalculated
      FieldName = 'FK'
      Calculated = True
    end
    object dFieldsDESCRIPTION_CALC: TStringField
      FieldKind = fkCalculated
      FieldName = 'DESCRIPTION_CALC'
      Size = 0
      Calculated = True
    end
  end
  object dsPrimeKeys: TDataSource
    DataSet = dPrimeKeys
    Left = 40
    Top = 80
  end
  object dPrimeKeys: TIBDataSet
    BufferChunks = 10
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '  rc.rdb$constraint_name as constaintname,'
      '  i_s.rdb$field_name as fieldname'
      'FROM'
      '  rdb$relation_constraints rc  '
      '  LEFT JOIN rdb$index_segments i_s ON i_s.rdb$index_name = '
      '    rc.rdb$index_name'
      'WHERE'
      '  rc.rdb$relation_name = :relationname AND'
      '  rc.rdb$constraint_type = '#39'PRIMARY KEY'#39)
    Left = 40
    Top = 112
    object dPrimeKeysCONSTAINTNAME: TIBStringField
      FieldName = 'CONSTAINTNAME'
      Origin = 'RDB$RELATION_CONSTRAINTS.RDB$CONSTRAINT_NAME'
      FixedChar = True
      Size = 31
    end
    object dPrimeKeysFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Origin = 'RDB$INDEX_SEGMENTS.RDB$FIELD_NAME'
      FixedChar = True
      Size = 31
    end
  end
  object dsForeignKeys: TDataSource
    DataSet = dForeignKey
    Left = 72
    Top = 80
  end
  object dForeignKey: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '   RC.RDB$RELATION_NAME AS RELATIONNAME,'
      '   INDSEG.RDB$FIELD_NAME AS FIELDNAME,'
      '   RC2.RDB$RELATION_NAME AS REFRELATIONNAME,'
      '   INDSEG2.RDB$FIELD_NAME AS REFFIELDNAME,'
      '   RC.RDB$CONSTRAINT_NAME AS CONSTRAINTNAME,'
      '   REFC.RDB$UPDATE_RULE AS UPDATERULE,'
      '   REFC.RDB$DELETE_RULE AS DELETERULE'
      'FROM'
      '    RDB$RELATION_CONSTRAINTS RC'
      
        '    JOIN RDB$INDEX_SEGMENTS INDSEG ON RC.RDB$INDEX_NAME = INDSEG' +
        '.RDB$INDEX_NAME'
      
        '    LEFT JOIN RDB$REF_CONSTRAINTS REFC ON REFC.RDB$CONSTRAINT_NA' +
        'ME = RC.RDB$CONSTRAINT_NAME,'
      '    RDB$RELATION_CONSTRAINTS RC2'
      
        '    JOIN RDB$INDEX_SEGMENTS INDSEG2  ON RC2.RDB$INDEX_NAME = IND' +
        'SEG2.RDB$INDEX_NAME'
      'WHERE'
      '    RC.RDB$RELATION_NAME = :relationname AND'
      '    RC2.RDB$CONSTRAINT_NAME = REFC.RDB$CONST_NAME_UQ  AND'
      '    INDSEG.RDB$FIELD_POSITION = INDSEG2.RDB$FIELD_POSITION')
    Left = 72
    Top = 112
    object dForeignKeyRELATIONNAME: TIBStringField
      FieldName = 'RELATIONNAME'
      Origin = 'RDB$RELATION_CONSTRAINTS.RDB$RELATION_NAME'
      FixedChar = True
      Size = 31
    end
    object dForeignKeyFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Origin = 'RDB$INDEX_SEGMENTS.RDB$FIELD_NAME'
      FixedChar = True
      Size = 31
    end
    object dForeignKeyREFRELATIONNAME: TIBStringField
      FieldName = 'REFRELATIONNAME'
      Origin = 'RDB$RELATION_CONSTRAINTS.RDB$RELATION_NAME'
      FixedChar = True
      Size = 31
    end
    object dForeignKeyREFFIELDNAME: TIBStringField
      FieldName = 'REFFIELDNAME'
      Origin = 'RDB$INDEX_SEGMENTS.RDB$FIELD_NAME'
      FixedChar = True
      Size = 31
    end
    object dForeignKeyCONSTRAINTNAME: TIBStringField
      FieldName = 'CONSTRAINTNAME'
      Origin = 'RDB$RELATION_CONSTRAINTS.RDB$CONSTRAINT_NAME'
      FixedChar = True
      Size = 31
    end
    object dForeignKeyUPDATERULE: TIBStringField
      FieldName = 'UPDATERULE'
      Origin = 'RDB$REF_CONSTRAINTS.RDB$UPDATE_RULE'
      FixedChar = True
      Size = 11
    end
    object dForeignKeyDELETERULE: TIBStringField
      FieldName = 'DELETERULE'
      Origin = 'RDB$REF_CONSTRAINTS.RDB$DELETE_RULE'
      FixedChar = True
      Size = 11
    end
  end
  object dsChecks: TDataSource
    DataSet = dChecks
    Left = 104
    Top = 80
  end
  object dChecks: TIBDataSet
    OnCalcFields = dChecksCalcFields
    BufferChunks = 10
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '  rc.rdb$constraint_name as constaintname,'
      '  rt.RDB$TRIGGER_SOURCE as CHECKCLAUSE'
      'FROM'
      '  rdb$relation_constraints rc  '
      '  JOIN rdb$check_constraints cc ON cc.rdb$constraint_name = '
      '    rc.rdb$constraint_name'
      '  JOIN RDB$TRIGGERS RT ON RT.RDB$TRIGGER_NAME = '
      '     cc.RDB$TRIGGER_NAME'
      'WHERE'
      '  rc.rdb$relation_name = :relationname AND'
      '  rc.rdb$constraint_type = '#39'CHECK'#39)
    Left = 104
    Top = 112
    object dChecksCONSTAINTNAME: TIBStringField
      FieldName = 'CONSTAINTNAME'
      Origin = 'RDB$RELATION_CONSTRAINTS.RDB$CONSTRAINT_NAME'
      FixedChar = True
      Size = 31
    end
    object dChecksCHECKCLAUSE: TMemoField
      FieldName = 'CHECKCLAUSE'
      Origin = 'RDB$TRIGGERS.RDB$TRIGGER_SOURCE'
      BlobType = ftMemo
      Size = 8
    end
    object dChecksCHECKCLAUSE_CALC: TStringField
      DisplayWidth = 60
      FieldKind = fkCalculated
      FieldName = 'CHECKCLAUSE_CALC'
      Size = 1024
      Calculated = True
    end
  end
  object dsUniques: TDataSource
    DataSet = dUnique
    Left = 136
    Top = 80
  end
  object dUnique: TIBDataSet
    BufferChunks = 10
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '  rc.rdb$constraint_name as constaintname,'
      '  i_s.rdb$field_name as fieldname'
      'FROM'
      '  rdb$relation_constraints rc  '
      '  LEFT JOIN rdb$index_segments i_s ON i_s.rdb$index_name = '
      '    rc.rdb$index_name'
      'WHERE'
      '  rc.rdb$relation_name = :relationname AND'
      '  rc.rdb$constraint_type = '#39'UNIQUE'#39)
    Left = 136
    Top = 112
    object dUniqueCONSTAINTNAME: TIBStringField
      FieldName = 'CONSTAINTNAME'
      Origin = 'RDB$RELATION_CONSTRAINTS.RDB$CONSTRAINT_NAME'
      FixedChar = True
      Size = 31
    end
    object dUniqueFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Origin = 'RDB$INDEX_SEGMENTS.RDB$FIELD_NAME'
      FixedChar = True
      Size = 31
    end
  end
  object dIndices: TIBDataSet
    OnCalcFields = dIndicesCalcFields
    BufferChunks = 64
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '  i.rdb$index_name as indexname,'
      '  i_s.rdb$field_name as fieldname,'
      '  i.rdb$unique_flag as uniqueflag,'
      '  i.rdb$expression_source as expressionsource,'
      '  i.rdb$index_inactive as indexinactive'
      'FROM'
      '  rdb$indices i'
      '  LEFT JOIN  rdb$relation_constraints rc ON rc.rdb$index_name ='
      '    i.rdb$index_name'
      '  LEFT JOIN rdb$index_segments i_s ON i_s.rdb$index_name ='
      '    i.rdb$index_name'
      'WHERE'
      '  i.rdb$relation_name = :relationname')
    Left = 168
    Top = 112
    object dIndicesINDEXNAME: TIBStringField
      FieldName = 'INDEXNAME'
      Origin = 'RDB$INDICES.RDB$INDEX_NAME'
      FixedChar = True
      Size = 31
    end
    object dIndicesFIELDNAME: TIBStringField
      FieldName = 'FIELDNAME'
      Origin = 'RDB$INDEX_SEGMENTS.RDB$FIELD_NAME'
      FixedChar = True
      Size = 31
    end
    object dIndicesUNIQUEFLAG: TSmallintField
      FieldName = 'UNIQUEFLAG'
      Origin = 'RDB$INDICES.RDB$UNIQUE_FLAG'
    end
    object dIndicesEXPRESSIONSOURCE: TMemoField
      FieldName = 'EXPRESSIONSOURCE'
      Origin = 'RDB$INDICES.RDB$EXPRESSION_SOURCE'
      BlobType = ftMemo
      Size = 8
    end
    object dIndicesINDEXINACTIVE: TSmallintField
      FieldName = 'INDEXINACTIVE'
      Origin = 'RDB$INDICES.RDB$INDEX_INACTIVE'
    end
    object dIndicesEXPRESSIONSOURCE_CALC: TStringField
      DisplayWidth = 32
      FieldKind = fkCalculated
      FieldName = 'EXPRESSIONSOURCE_CALC'
      Size = 1024
      Calculated = True
    end
    object dIndicesUNIQUEFLAG_CALC: TStringField
      FieldKind = fkCalculated
      FieldName = 'UNIQUEFLAG_CALC'
      Calculated = True
    end
    object dIndicesINDEXINACTIVE_CALC: TStringField
      FieldKind = fkCalculated
      FieldName = 'INDEXINACTIVE_CALC'
      Calculated = True
    end
  end
  object dsIndices: TDataSource
    DataSet = dIndices
    Left = 168
    Top = 80
  end
  object DataSet: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    Left = 304
    Top = 80
  end
end
