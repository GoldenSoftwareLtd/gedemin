inherited gdc_dlgObjectProperties: Tgdc_dlgObjectProperties
  Left = 359
  Top = 174
  Caption = 'Свойства объекта'
  ClientHeight = 426
  ClientWidth = 399
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 102
    Top = 396
    Width = 15
    Enabled = False
    TabOrder = 4
    Visible = False
  end
  inherited btnNew: TButton
    Left = 118
    Top = 396
    Width = 15
    Enabled = False
    TabOrder = 5
    Visible = False
  end
  inherited btnHelp: TButton
    Left = 4
    Top = 402
    TabOrder = 3
  end
  inherited btnOK: TButton
    Left = 253
    Top = 402
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 327
    Top = 402
    TabOrder = 2
  end
  object pcMain: TPageControl [5]
    Left = 4
    Top = 4
    Width = 391
    Height = 393
    ActivePage = TabSheet1
    TabOrder = 0
    OnChange = tsAccessShow
    object tsGeneral: TTabSheet
      Caption = 'Общие'
      object btnClassMethods: TButton
        Left = 2
        Top = 343
        Width = 119
        Height = 19
        Action = actGoToMethods
        TabOrder = 0
      end
      object btnSubTypeMethods: TButton
        Left = 260
        Top = 343
        Width = 119
        Height = 19
        Action = actGoToMethodsSubtype
        TabOrder = 2
      end
      object btnParentMethods: TButton
        Left = 131
        Top = 343
        Width = 119
        Height = 19
        Action = actGoToMethodsParent
        TabOrder = 1
      end
      object mProp: TMemo
        Left = 2
        Top = 2
        Width = 378
        Height = 336
        Color = clBtnFace
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssHorizontal
        TabOrder = 3
        WordWrap = False
      end
    end
    object tsAccess: TTabSheet
      Caption = 'Доступ'
      ImageIndex = 1
      object Label1: TLabel
        Left = 8
        Top = 11
        Width = 82
        Height = 13
        Caption = 'Правом доступа'
      end
      object Label2: TLabel
        Left = 240
        Top = 11
        Width = 46
        Height = 13
        Caption = 'к данной'
      end
      object Label3: TLabel
        Left = 8
        Top = 28
        Width = 213
        Height = 13
        Caption = 'записи обладают группы пользователей:'
      end
      object Label6: TLabel
        Left = 8
        Top = 268
        Width = 288
        Height = 13
        Caption = 'Для добавления, выберите группу и нажмите Добавить'
      end
      object cbAccessClass: TComboBox
        Left = 96
        Top = 6
        Width = 140
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbAccessClassChange
        Items.Strings = (
          'Только просмотр'
          'Просмотр и изменение'
          'Полный доступ')
      end
      object ibgrUserGroup: TgsIBGrid
        Left = 8
        Top = 43
        Width = 361
        Height = 166
        DataSource = dsUserGroup
        Options = [dgColumnResize, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 1
        InternalMenuKind = imkNone
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
        SaveSettings = False
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
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
            Title.Caption = 'NAME'
            Width = 124
            Visible = True
          end>
      end
      object ibcbUserGroup: TgsIBLookupComboBox
        Left = 8
        Top = 284
        Width = 361
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        ListTable = 'gd_usergroup'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcUserGroup'
        StrictOnExit = False
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
      end
      object memoExclude: TMemo
        Left = 8
        Top = 211
        Width = 361
        Height = 27
        BorderStyle = bsNone
        Color = clBtnFace
        Lines.Strings = (
          'Для исключения группы, выберите ее в списке и нажмите '
          'кнопку Исключить')
        ReadOnly = True
        TabOrder = 2
      end
      object btnExclude: TButton
        Left = 8
        Top = 243
        Width = 75
        Height = 21
        Action = actExclude
        TabOrder = 3
      end
      object btnInclude: TButton
        Left = 8
        Top = 310
        Width = 75
        Height = 21
        Action = actInclude
        TabOrder = 6
      end
      object btnIncludeAll: TButton
        Left = 89
        Top = 310
        Width = 88
        Height = 21
        Action = actIncludeAll
        TabOrder = 7
      end
      object btnExcludeAll: TButton
        Left = 89
        Top = 243
        Width = 88
        Height = 21
        Action = actExcludeAll
        TabOrder = 4
      end
      object chbxUpdateChildren: TCheckBox
        Left = 8
        Top = 335
        Width = 321
        Height = 17
        Caption = 'Распространить права доступа на дочерние объекты'
        TabOrder = 8
      end
    end
    object tsAdditional: TTabSheet
      Caption = 'Данные'
      ImageIndex = 3
      object Label24: TLabel
        Left = 3
        Top = 4
        Width = 90
        Height = 13
        Caption = 'Считано записей:'
      end
      object lblRecordCount: TLabel
        Left = 104
        Top = 4
        Width = 60
        Height = 13
        Caption = 'lblClassLabel'
      end
      object Label26: TLabel
        Left = 3
        Top = 23
        Width = 80
        Height = 13
        Caption = 'Размер буфера:'
      end
      object lblCacheSize: TLabel
        Left = 104
        Top = 23
        Width = 62
        Height = 13
        Caption = 'lblClassName'
      end
      object lblParams: TLabel
        Left = 118
        Top = 334
        Width = 61
        Height = 13
        Caption = 'Параметры:'
      end
      object Button6: TButton
        Left = 3
        Top = 329
        Width = 89
        Height = 21
        Action = actShowSQL
        TabOrder = 1
      end
      object cbParams: TComboBox
        Left = 184
        Top = 331
        Width = 189
        Height = 19
        Style = csDropDownList
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 0
        ParentFont = False
        TabOrder = 2
      end
      object sbFields: TScrollBox
        Left = 3
        Top = 41
        Width = 370
        Height = 282
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object tsFields: TTabSheet
      Caption = 'Поля'
      ImageIndex = 3
      object sbFields2: TScrollBox
        Left = 3
        Top = 3
        Width = 370
        Height = 346
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object tsLinks: TTabSheet
      Caption = 'Ссылки'
      ImageIndex = 4
      object Label29: TLabel
        Left = 8
        Top = 32
        Width = 219
        Height = 13
        Caption = 'Ссылок на данный объект не обнаружено.'
      end
      object tbLinks: TTBToolbar
        Left = 0
        Top = 0
        Width = 383
        Height = 22
        Align = alTop
        Caption = 'tbLinks'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object TBItem1: TTBItem
          Action = actShowLinkObject
          Images = dmImages.il16x16
        end
        object TBControlItem1: TTBControlItem
          Control = Label30
        end
        object TBControlItem2: TTBControlItem
          Control = cbOpenDoc
        end
        object Label30: TLabel
          Left = 23
          Top = 4
          Width = 176
          Height = 13
          Caption = '  Позиция документа, открывать: '
        end
        object cbOpenDoc: TComboBox
          Left = 199
          Top = 0
          Width = 106
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Позицию'
            'Шапку')
        end
      end
      object ibgrLinks: TgsIBGrid
        Left = 0
        Top = 22
        Width = 383
        Height = 343
        Align = alClient
        DataSource = dsLinks
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
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
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        ShowFooter = True
        ShowTotals = False
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'YAML'
      ImageIndex = 5
      object mYAMLFile: TSynEdit
        Left = 0
        Top = 1
        Width = 383
        Height = 328
        Cursor = crIBeam
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 0
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Gutter.Visible = False
        Highlighter = SynGeneralSyn
        Keystrokes = <
          item
            Command = ecUp
            ShortCut = 38
          end
          item
            Command = ecSelUp
            ShortCut = 8230
          end
          item
            Command = ecScrollUp
            ShortCut = 16422
          end
          item
            Command = ecDown
            ShortCut = 40
          end
          item
            Command = ecSelDown
            ShortCut = 8232
          end
          item
            Command = ecScrollDown
            ShortCut = 16424
          end
          item
            Command = ecLeft
            ShortCut = 37
          end
          item
            Command = ecSelLeft
            ShortCut = 8229
          end
          item
            Command = ecWordLeft
            ShortCut = 16421
          end
          item
            Command = ecSelWordLeft
            ShortCut = 24613
          end
          item
            Command = ecRight
            ShortCut = 39
          end
          item
            Command = ecSelRight
            ShortCut = 8231
          end
          item
            Command = ecWordRight
            ShortCut = 16423
          end
          item
            Command = ecSelWordRight
            ShortCut = 24615
          end
          item
            Command = ecPageDown
            ShortCut = 34
          end
          item
            Command = ecSelPageDown
            ShortCut = 8226
          end
          item
            Command = ecPageBottom
            ShortCut = 16418
          end
          item
            Command = ecSelPageBottom
            ShortCut = 24610
          end
          item
            Command = ecPageUp
            ShortCut = 33
          end
          item
            Command = ecSelPageUp
            ShortCut = 8225
          end
          item
            Command = ecPageTop
            ShortCut = 16417
          end
          item
            Command = ecSelPageTop
            ShortCut = 24609
          end
          item
            Command = ecLineStart
            ShortCut = 36
          end
          item
            Command = ecSelLineStart
            ShortCut = 8228
          end
          item
            Command = ecEditorTop
            ShortCut = 16420
          end
          item
            Command = ecSelEditorTop
            ShortCut = 24612
          end
          item
            Command = ecLineEnd
            ShortCut = 35
          end
          item
            Command = ecSelLineEnd
            ShortCut = 8227
          end
          item
            Command = ecEditorBottom
            ShortCut = 16419
          end
          item
            Command = ecSelEditorBottom
            ShortCut = 24611
          end
          item
            Command = ecToggleMode
            ShortCut = 45
          end
          item
            Command = ecCopy
            ShortCut = 16429
          end
          item
            Command = ecCut
            ShortCut = 8238
          end
          item
            Command = ecPaste
            ShortCut = 8237
          end
          item
            Command = ecDeleteChar
            ShortCut = 46
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8200
          end
          item
            Command = ecDeleteLastWord
            ShortCut = 16392
          end
          item
            Command = ecUndo
            ShortCut = 32776
          end
          item
            Command = ecRedo
            ShortCut = 40968
          end
          item
            Command = ecLineBreak
            ShortCut = 13
          end
          item
            Command = ecLineBreak
            ShortCut = 8205
          end
          item
            Command = ecTab
            ShortCut = 9
          end
          item
            Command = ecShiftTab
            ShortCut = 8201
          end
          item
            Command = ecContextHelp
            ShortCut = 16496
          end
          item
            Command = ecSelectAll
            ShortCut = 16449
          end
          item
            Command = ecCopy
            ShortCut = 16451
          end
          item
            Command = ecPaste
            ShortCut = 16470
          end
          item
            Command = ecCut
            ShortCut = 16472
          end
          item
            Command = ecBlockIndent
            ShortCut = 24649
          end
          item
            Command = ecBlockUnindent
            ShortCut = 24661
          end
          item
            Command = ecLineBreak
            ShortCut = 16461
          end
          item
            Command = ecInsertLine
            ShortCut = 16462
          end
          item
            Command = ecDeleteWord
            ShortCut = 16468
          end
          item
            Command = ecDeleteLine
            ShortCut = 16473
          end
          item
            Command = ecDeleteEOL
            ShortCut = 24665
          end
          item
            Command = ecUndo
            ShortCut = 16474
          end
          item
            Command = ecRedo
            ShortCut = 24666
          end
          item
            Command = ecGotoMarker0
            ShortCut = 16432
          end
          item
            Command = ecGotoMarker1
            ShortCut = 16433
          end
          item
            Command = ecGotoMarker2
            ShortCut = 16434
          end
          item
            Command = ecGotoMarker3
            ShortCut = 16435
          end
          item
            Command = ecGotoMarker4
            ShortCut = 16436
          end
          item
            Command = ecGotoMarker5
            ShortCut = 16437
          end
          item
            Command = ecGotoMarker6
            ShortCut = 16438
          end
          item
            Command = ecGotoMarker7
            ShortCut = 16439
          end
          item
            Command = ecGotoMarker8
            ShortCut = 16440
          end
          item
            Command = ecGotoMarker9
            ShortCut = 16441
          end
          item
            Command = ecSetMarker0
            ShortCut = 24624
          end
          item
            Command = ecSetMarker1
            ShortCut = 24625
          end
          item
            Command = ecSetMarker2
            ShortCut = 24626
          end
          item
            Command = ecSetMarker3
            ShortCut = 24627
          end
          item
            Command = ecSetMarker4
            ShortCut = 24628
          end
          item
            Command = ecSetMarker5
            ShortCut = 24629
          end
          item
            Command = ecSetMarker6
            ShortCut = 24630
          end
          item
            Command = ecSetMarker7
            ShortCut = 24631
          end
          item
            Command = ecSetMarker8
            ShortCut = 24632
          end
          item
            Command = ecSetMarker9
            ShortCut = 24633
          end
          item
            Command = ecNormalSelect
            ShortCut = 24654
          end
          item
            Command = ecColumnSelect
            ShortCut = 24643
          end
          item
            Command = ecLineSelect
            ShortCut = 24652
          end
          item
            Command = ecMatchBracket
            ShortCut = 24642
          end>
        Lines.Strings = (
          '')
        ReadOnly = True
      end
      object bLoad: TButton
        Left = 182
        Top = 336
        Width = 87
        Height = 25
        Action = actLoadYAML
        TabOrder = 1
      end
      object bSave: TButton
        Left = 292
        Top = 336
        Width = 87
        Height = 25
        Action = actSaveYAML
        TabOrder = 2
      end
    end
  end
  inherited alBase: TActionList
    Left = 310
    Top = 199
    object actExclude: TAction
      Caption = 'Исключить'
      OnExecute = actExcludeExecute
      OnUpdate = actExcludeUpdate
    end
    object actInclude: TAction
      Caption = 'Добавить'
      OnExecute = actIncludeExecute
      OnUpdate = actIncludeUpdate
    end
    object actIncludeAll: TAction
      Caption = 'Добавить все'
      OnExecute = actIncludeAllExecute
      OnUpdate = actIncludeAllUpdate
    end
    object actExcludeAll: TAction
      Caption = 'Исключить все'
      OnExecute = actExcludeAllExecute
      OnUpdate = actExcludeAllUpdate
    end
    object actShowSQL: TAction
      Caption = 'Показать SQL'
      OnExecute = actShowSQLExecute
      OnUpdate = actShowSQLUpdate
    end
    object actShowLinkObject: TAction
      Caption = 'actShowLinkObject'
      Hint = 'Открыть объект'
      ImageIndex = 158
      OnExecute = actShowLinkObjectExecute
      OnUpdate = actShowLinkObjectUpdate
    end
    object actGoToMethods: TAction
      Caption = 'Методы класса'
      Hint = 'Перейти на методы класса'
      OnExecute = actGoToMethodsExecute
      OnUpdate = actGoToMethodsUpdate
    end
    object actGoToMethodsSubtype: TAction
      Caption = 'Методы подтипа'
      Hint = 'Перейти на методы класса'
      OnExecute = actGoToMethodsSubtypeExecute
      OnUpdate = actGoToMethodsSubtypeUpdate
    end
    object actGoToMethodsParent: TAction
      Caption = 'Методы родителя'
      Hint = 'Перейти на методы класса'
      OnExecute = actGoToMethodsParentExecute
      OnUpdate = actGoToMethodsParentUpdate
    end
    object actSaveYAML: TAction
      Caption = 'Сохранить'
      OnExecute = actSaveYAMLExecute
    end
    object actLoadYAML: TAction
      Caption = 'Загрузить'
      OnExecute = actLoadYAMLExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 248
    Top = 199
  end
  inherited pm_dlgG: TPopupMenu
    Left = 280
    Top = 200
  end
  inherited ibtrCommon: TIBTransaction
    Left = 264
    Top = 136
  end
  object gdcUserGroup: TgdcUserGroup
    SubSet = 'ByMask'
    Left = 228
    Top = 304
    object gdcUserGroupID: TIntegerField
      FieldName = 'ID'
      Required = True
      Visible = False
    end
    object gdcUserGroupNAME: TIBStringField
      FieldName = 'NAME'
      Required = True
    end
  end
  object dsUserGroup: TDataSource
    DataSet = gdcUserGroup
    Left = 260
    Top = 304
  end
  object ibdsLinks: TIBDataSet
    Left = 72
    Top = 172
  end
  object dsLinks: TDataSource
    DataSet = ibdsLinks
    Left = 112
    Top = 172
  end
  object SynGeneralSyn: TSynGeneralSyn
    Comments = []
    DetectPreprocessor = False
    IdentifierChars = 
      '!"#$%&'#39'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`' +
      'abcdefghijklmnopqrstuvwxyz{|}~ЂЃ‚ѓ„…†‡€‰Љ‹ЊЌЋЏђ‘’“”•–—™љ›њќћџ ' +
      'ЎўЈ¤Ґ¦§Ё©Є«¬­®Ї°±Ііґµ¶·ё№є»јЅѕїАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯа' +
      'бвгдежзийклмнопрстуфхцчшщъыьэюя'
    Left = 224
    Top = 100
  end
end
