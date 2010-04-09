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
    ActivePage = tsAccess
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
        Lines.Strings = (
          '')
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
        ItemHeight = 13
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
        ItemHeight = 11
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
end
