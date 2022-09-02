object dlgRealizatoinOption: TdlgRealizatoinOption
  Left = 324
  Top = 199
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Настройки накладной'
  ClientHeight = 402
  ClientWidth = 543
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object bOk: TButton
    Left = 460
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 460
    Top = 37
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object pcOption: TPageControl
    Left = 8
    Top = 8
    Width = 441
    Height = 385
    ActivePage = tsMain
    TabOrder = 2
    object tsMain: TTabSheet
      Caption = 'Основные'
      object Label1: TLabel
        Left = 8
        Top = 12
        Width = 125
        Height = 13
        Caption = 'Единица измерения веса'
      end
      object Label3: TLabel
        Left = 8
        Top = 220
        Width = 229
        Height = 13
        Caption = 'Группа ТМЦ - по умолчанию для добавления'
      end
      object gsiblcValue: TgsIBLookupComboBox
        Left = 147
        Top = 8
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'GD_VALUE'
        ListField = 'NAME'
        KeyField = 'ID'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object cbPriceWithContact: TCheckBox
        Left = 8
        Top = 34
        Width = 361
        Height = 17
        Caption = 'Использовать жесткую привязку прайс-листа к контакту'
        TabOrder = 1
      end
      object gsdbtvGroup: TgsDBTreeView
        Left = 8
        Top = 236
        Width = 347
        Height = 105
        DataSource = dsGroup
        KeyField = 'ID'
        ParentField = 'PARENT'
        DisplayField = 'NAME'
        Images = dmImages.ilTree
        Indent = 19
        TabOrder = 7
        OnGetImageIndex = gsdbtvGroupGetImageIndex
        OnGetSelectedIndex = gsdbtvGroupGetSelectedIndex
        MainFolderHead = False
        MainFolder = False
        MainFolderCaption = 'Все'
        WithCheckBox = False
      end
      object cbOnlyPriceGood: TCheckBox
        Left = 8
        Top = 53
        Width = 329
        Height = 17
        Caption = 'Выбирать ТМЦ только из текущего прайса'
        TabOrder = 2
      end
      object cbMakeEntryOnSave: TCheckBox
        Left = 8
        Top = 71
        Width = 353
        Height = 17
        Caption = 'Формировать проводки при сохранении'
        TabOrder = 3
      end
      object cbAutoMakeTransaction: TCheckBox
        Left = 8
        Top = 90
        Width = 297
        Height = 17
        Caption = 'Автоматически формировать операцию'
        TabOrder = 4
      end
      object cbCheckNumber: TCheckBox
        Left = 8
        Top = 108
        Width = 273
        Height = 17
        Caption = 'Контроль уникальности номеров накладных'
        TabOrder = 5
      end
      object cbJoinRecord: TCheckBox
        Left = 8
        Top = 127
        Width = 248
        Height = 17
        Caption = 'Объединять позиции по умолчанию'
        TabOrder = 6
      end
      object rgDisabledGood: TRadioGroup
        Left = 8
        Top = 180
        Width = 347
        Height = 33
        Caption = 'Отключенный ТМЦ'
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          'Не выводить'
          'Предупреждать'
          'Игнорировать')
        TabOrder = 8
      end
      object rgCopy: TRadioGroup
        Left = 8
        Top = 144
        Width = 347
        Height = 33
        Caption = 'Копирование'
        Columns = 2
        ItemIndex = 1
        Items.Strings = (
          'Вся накладная'
          'Только шапка')
        TabOrder = 9
      end
    end
    object tsTax: TTabSheet
      Caption = 'Налоги'
      ImageIndex = 1
      object Label2: TLabel
        Left = 4
        Top = 7
        Width = 263
        Height = 13
        Caption = 'Поля по позиции накладной отвечающие за налоги'
      end
      object gsibgrDocRealPosOption: TgsIBCtrlGrid
        Left = 2
        Top = 25
        Width = 423
        Height = 170
        DataSource = dsDocRealPosOption
        TabOrder = 0
        OnEnter = gsibgrDocRealPosOptionEnter
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
        Columns = <
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'RELATIONNAME'
            Title.Caption = 'Таблица'
            Width = 156
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'FIELDNAME'
            Title.Caption = 'Поле'
            Width = 116
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'NAME'
            Title.Caption = 'Налог'
            Width = 74
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'RATE'
            Title.Caption = 'Ставка'
            Width = 40
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'INCLUDETAX'
            Title.Caption = 'Вкл. в цену'
            Width = 76
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ISCURRENCY'
            Title.Caption = 'Валют'
            Width = 40
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ROUNDING'
            Title.Caption = 'Округлять'
            Width = 57
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'EXPRESSION'
            Title.Caption = 'Формула'
            Width = 60
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'TAXKEY'
            Title.Caption = 'TAXKEY'
            Width = -1
            Visible = False
          end>
      end
      object gsiblcTax: TgsIBLookupComboBox
        Left = 64
        Top = 49
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        DataSource = dsDocRealPosOption
        DataField = 'TAXKEY'
        ListTable = 'GD_TAX'
        ListField = 'NAME'
        KeyField = 'ID'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Visible = False
        OnExit = gsiblcTaxExit
      end
      object dbcbIncludeTax: TDBCheckBox
        Left = 224
        Top = 57
        Width = 16
        Height = 17
        DataField = 'INCLUDETAX'
        DataSource = dsDocRealPosOption
        TabOrder = 2
        ValueChecked = '1'
        ValueUnchecked = '0'
        Visible = False
      end
      object dbcbIsCurrency: TDBCheckBox
        Left = 224
        Top = 78
        Width = 16
        Height = 17
        DataField = 'ISCURRENCY'
        DataSource = dsDocRealPosOption
        TabOrder = 3
        ValueChecked = '1'
        ValueUnchecked = '0'
        Visible = False
      end
      object gsiblcRelationName: TgsIBLookupComboBox
        Left = 24
        Top = 80
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        DataSource = dsDocRealPosOption
        DataField = 'RELATIONNAME'
        ListTable = 'AT_RELATIONS'
        ListField = 'RELATIONNAME'
        KeyField = 'RELATIONNAME'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Visible = False
      end
      object gsiblcFieldName: TgsIBLookupComboBox
        Left = 24
        Top = 112
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        DataSource = dsDocRealPosOption
        DataField = 'FIELDNAME'
        ListTable = 'AT_RELATION_FIELDS'
        ListField = 'FIELDNAME'
        KeyField = 'FIELDNAME'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Visible = False
      end
      object Button3: TButton
        Left = 3
        Top = 193
        Width = 96
        Height = 25
        Action = actChooseVar
        TabOrder = 6
      end
    end
    object tsPrint: TTabSheet
      Caption = 'Печать'
      ImageIndex = 2
      object Label4: TLabel
        Left = 8
        Top = 8
        Width = 333
        Height = 13
        Caption = 'Выделять при печати следующие группы (в указанном порядке)'
      end
      object sgrGroupSelect: TStringGrid
        Left = 8
        Top = 32
        Width = 329
        Height = 137
        ColCount = 4
        DefaultColWidth = 240
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 0
      end
      object Button1: TButton
        Left = 348
        Top = 31
        Width = 75
        Height = 25
        Action = actChooseGroup
        TabOrder = 1
      end
      object Button2: TButton
        Left = 348
        Top = 60
        Width = 75
        Height = 25
        Action = actDelete
        TabOrder = 2
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Нормы убыли'
      ImageIndex = 3
      object Label5: TLabel
        Left = 8
        Top = 8
        Width = 363
        Height = 13
        Caption = 
          'Нормы естественной убыли при доставки продукции (в разрезе групп' +
          ')'
      end
      object sgNaturalLoss: TStringGrid
        Left = 8
        Top = 24
        Width = 409
        Height = 129
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 0
        ColWidths = (
          64
          69
          75
          74
          64)
      end
      object Button4: TButton
        Left = 9
        Top = 154
        Width = 102
        Height = 25
        Action = actAddGroup
        TabOrder = 1
      end
      object Button5: TButton
        Left = 110
        Top = 154
        Width = 102
        Height = 25
        Action = actDelGroup
        TabOrder = 2
      end
      object Button6: TButton
        Left = 216
        Top = 154
        Width = 102
        Height = 25
        Action = actAddDist
        TabOrder = 3
      end
      object Button7: TButton
        Left = 317
        Top = 154
        Width = 102
        Height = 25
        Action = actDelDist
        TabOrder = 4
      end
    end
  end
  object ibdsDocRealPosOption: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from gd_docrealposoption'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME and'
      '  RELATIONNAME = :OLD_RELATIONNAME')
    InsertSQL.Strings = (
      'insert into gd_docrealposoption'
      
        '  (FIELDNAME, TAXKEY, EXPRESSION, INCLUDETAX, ISCURRENCY, ROUNDI' +
        'NG, '
      'RELATIONNAME, '
      '   RATE)'
      'values'
      '  (:FIELDNAME, :TAXKEY, :EXPRESSION, :INCLUDETAX, :ISCURRENCY, '
      ':ROUNDING, '
      '   :RELATIONNAME, :RATE)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_docrealposoption '
      'where'
      '  FIELDNAME = :FIELDNAME and'
      '  RELATIONNAME = :RELATIONNAME')
    SelectSQL.Strings = (
      'SELECT d.*, t.name FROM '
      '   gd_docrealposoption d '
      'LEFT JOIN'
      '  gd_tax t ON d.taxkey = t.id')
    ModifySQL.Strings = (
      'update gd_docrealposoption'
      'set'
      '  FIELDNAME = :FIELDNAME,'
      '  TAXKEY = :TAXKEY,'
      '  EXPRESSION = :EXPRESSION,'
      '  INCLUDETAX = :INCLUDETAX,'
      '  ISCURRENCY = :ISCURRENCY,'
      '  ROUNDING = :ROUNDING,'
      '  RELATIONNAME = :RELATIONNAME,'
      '  RATE = :RATE'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME and'
      '  RELATIONNAME = :OLD_RELATIONNAME')
    ReadTransaction = IBTransaction
    Left = 304
    Top = 249
  end
  object dsDocRealPosOption: TDataSource
    DataSet = ibdsDocRealPosOption
    Left = 272
    Top = 249
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 304
    Top = 217
  end
  object dsGroup: TDataSource
    DataSet = ibdsGroup
    Left = 312
    Top = 313
  end
  object ibdsGroup: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    SelectSQL.Strings = (
      'SELECT * FROM gd_goodgroup'
      'ORDER  BY parent DESC')
    ReadTransaction = IBTransaction
    Left = 312
    Top = 345
  end
  object ActionList1: TActionList
    Left = 332
    Top = 216
    object actChooseGroup: TAction
      Caption = 'Выбрать...'
      OnExecute = actChooseGroupExecute
    end
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
    end
    object actChooseVar: TAction
      Caption = 'Переменная...'
      OnExecute = actChooseVarExecute
      OnUpdate = actChooseVarUpdate
    end
    object actAddGroup: TAction
      Caption = 'Добавить группу'
      OnExecute = actAddGroupExecute
    end
    object actDelGroup: TAction
      Caption = 'Удалить группу'
      OnExecute = actDelGroupExecute
    end
    object actAddDist: TAction
      Caption = 'Добавить расст.'
      OnExecute = actAddDistExecute
    end
    object actDelDist: TAction
      Caption = 'Удалить расст.'
      OnExecute = actDelDistExecute
    end
  end
end
