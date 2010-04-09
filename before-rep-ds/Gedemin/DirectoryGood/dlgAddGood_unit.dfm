object dlgAddGood: TdlgAddGood
  Left = 245
  Top = 100
  BorderStyle = bsDialog
  Caption = 'ТМЦ:'
  ClientHeight = 419
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pcGood: TPageControl
    Left = 0
    Top = 0
    Width = 506
    Height = 377
    ActivePage = tsAttribute
    Align = alTop
    TabOrder = 0
    OnChange = pcGoodChange
    object tsOption: TTabSheet
      Caption = '&1 Свойства'
      object Label1: TLabel
        Left = 10
        Top = 17
        Width = 79
        Height = 13
        Caption = 'Наименование '
        FocusControl = dbeName
      end
      object Label2: TLabel
        Left = 10
        Top = 61
        Width = 50
        Height = 13
        Caption = 'Описание'
        FocusControl = dbmDescription
      end
      object Label3: TLabel
        Left = 10
        Top = 154
        Width = 52
        Height = 13
        Caption = 'Штрих-код'
        FocusControl = dbeBarCode
      end
      object Label4: TLabel
        Left = 10
        Top = 178
        Width = 56
        Height = 13
        Caption = 'Шифр ТМЦ'
        FocusControl = dbeAlias
      end
      object Label7: TLabel
        Left = 10
        Top = 202
        Width = 31
        Height = 13
        Caption = 'ТНВД'
        FocusControl = dblcbTNVD
      end
      object Label5: TLabel
        Left = 10
        Top = 219
        Width = 81
        Height = 13
        Caption = '&Налоги (Ctrl + Н)'
        FocusControl = gsibgrTax
      end
      object Label6: TLabel
        Left = 10
        Top = 129
        Width = 87
        Height = 13
        Caption = 'Базовая ед. изм.'
        FocusControl = dblcbValue
      end
      object sbAddValue: TSpeedButton
        Left = 464
        Top = 125
        Width = 23
        Height = 22
        Action = actAddValue
      end
      object sbAddTNVD: TSpeedButton
        Left = 464
        Top = 198
        Width = 23
        Height = 22
        Action = actAddTNVD
      end
      object SpeedButton1: TSpeedButton
        Left = 464
        Top = 12
        Width = 23
        Height = 22
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FF000000000000000000000000FF00FFFF00FFFF
          00FFFF00FF000000000000000000000000FF00FFFF00FFFF00FFFF00FF000000
          FFFFFF000000000000FF00FFFF00FFFF00FFFF00FF000000FFFFFF0000000000
          00FF00FFFF00FFFF00FFFF00FF000000FFFFFF000000000000FF00FFFF00FFFF
          00FFFF00FF000000FFFFFF000000000000FF00FFFF00FFFF00FFFF00FF000000
          000000000000000000000000000000FF00FF0000000000000000000000000000
          00FF00FFFF00FFFF00FFFF00FF00000000000000000000000000000000000000
          0000FFFFFF000000000000000000000000FF00FFFF00FFFF00FFFF00FF000000
          000000000000000000000000FF00FF000000FFFFFF0000000000000000000000
          00FF00FFFF00FFFF00FFFF00FFFF00FF00000000000000000000000000000000
          0000000000000000000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFFFFFF000000000000000000FF00FFFFFFFF000000000000000000FF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000000000000000000000FF
          00FF000000000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FF000000000000000000FF00FFFF00FF000000000000000000FF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000000000000000FF00FFFF
          00FF000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
        OnClick = SpeedButton1Click
      end
      object Label8: TLabel
        Left = 10
        Top = 41
        Width = 119
        Height = 13
        Caption = 'Краткое наименование'
        FocusControl = dbedShortName
      end
      object dbeName: TDBEdit
        Left = 146
        Top = 13
        Width = 317
        Height = 21
        DataField = 'NAME'
        DataSource = dsGood
        TabOrder = 0
        OnChange = dbeNameChange
      end
      object dbmDescription: TDBMemo
        Left = 146
        Top = 61
        Width = 343
        Height = 61
        DataField = 'DESCRIPTION'
        DataSource = dsGood
        TabOrder = 2
      end
      object dbeBarCode: TDBEdit
        Left = 146
        Top = 150
        Width = 343
        Height = 21
        DataField = 'BARCODE'
        DataSource = dsGood
        TabOrder = 4
      end
      object dbeAlias: TDBEdit
        Left = 146
        Top = 174
        Width = 343
        Height = 21
        DataField = 'ALIAS'
        DataSource = dsGood
        TabOrder = 5
      end
      object dblcbTNVD: TgsIBLookupComboBox
        Left = 146
        Top = 198
        Width = 319
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrGood
        DataSource = dsGood
        DataField = 'TNVDKEY'
        ListTable = 'gd_tnvd'
        ListField = 'Name'
        KeyField = 'ID'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        OnExit = dblcbTNVDExit
      end
      object gsibgrTax: TgsIBCtrlGrid
        Left = 11
        Top = 236
        Width = 405
        Height = 87
        DataSource = dsTax
        Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 7
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
      object Button5: TButton
        Left = 416
        Top = 236
        Width = 75
        Height = 25
        Action = actAddTax
        TabOrder = 8
      end
      object Button10: TButton
        Left = 416
        Top = 265
        Width = 75
        Height = 25
        Action = actDelTax
        TabOrder = 9
      end
      object dbcbSet: TDBCheckBox
        Left = 9
        Top = 328
        Width = 138
        Height = 17
        Caption = 'Является комплектом'
        DataField = 'ISASSEMBLY'
        DataSource = dsGood
        TabOrder = 10
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dblcbValue: TgsIBLookupComboBox
        Left = 146
        Top = 125
        Width = 319
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrGood
        DataSource = dsGood
        DataField = 'VALUEKEY'
        ListTable = 'gd_value'
        ListField = 'Name'
        KeyField = 'ID'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = dblcbValueExit
      end
      object dbcbDisabled: TDBCheckBox
        Left = 152
        Top = 328
        Width = 97
        Height = 17
        Caption = 'Отключен'
        DataField = 'DISABLED'
        DataSource = dsGood
        TabOrder = 11
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbedShortName: TDBEdit
        Left = 146
        Top = 37
        Width = 317
        Height = 21
        DataField = 'ShortName'
        DataSource = dsGood
        TabOrder = 1
        OnChange = dbeNameChange
      end
      object ddbeDateTax: TxDateDBEdit
        Left = 224
        Top = 256
        Width = 89
        Height = 21
        EditMask = '!99/99/9999;1;_'
        MaxLength = 10
        TabOrder = 12
        Visible = False
        OnExit = gsiblcTaxExit
        Kind = kDate
        DataField = 'DATETAX'
        DataSource = dsTax
      end
      object gsiblcTax: TgsIBLookupComboBox
        Left = 72
        Top = 288
        Width = 145
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrGood
        DataSource = dsTax
        DataField = 'TAXKEY'
        ListTable = 'GD_TAX'
        ListField = 'NAME'
        KeyField = 'ID'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 13
        Visible = False
        OnExit = gsiblcTaxExit
      end
    end
    object tsValue: TTabSheet
      Caption = '&2 Доп.ед.изм.'
      ImageIndex = 3
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 498
        Height = 349
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Button11: TButton
          Left = 418
          Top = 4
          Width = 75
          Height = 25
          Action = actSetValue
          Anchors = [akTop, akRight]
          TabOrder = 0
        end
        object Button13: TButton
          Left = 418
          Top = 36
          Width = 75
          Height = 25
          Action = actDelValue
          Anchors = [akTop, akRight]
          TabOrder = 1
        end
        object Button15: TButton
          Left = 418
          Top = 132
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Справка'
          TabOrder = 2
        end
        object gsIbgrValues: TgsIBGrid
          Left = 3
          Top = 4
          Width = 409
          Height = 340
          Anchors = [akLeft, akTop, akRight]
          DataSource = dsValues
          Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 3
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
        end
      end
    end
    object tsPrMetal: TTabSheet
      Caption = '&3 Драг.металлы'
      ImageIndex = 4
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 498
        Height = 349
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Button6: TButton
          Left = 418
          Top = 4
          Width = 75
          Height = 25
          Action = actAddPrMetal
          Anchors = [akTop, akRight]
          TabOrder = 0
        end
        object Button8: TButton
          Left = 418
          Top = 36
          Width = 75
          Height = 25
          Action = actDelPrMetal
          Anchors = [akTop, akRight]
          TabOrder = 1
        end
        object Button16: TButton
          Left = 418
          Top = 132
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Справка'
          TabOrder = 2
        end
        object gsibgrPrMetal: TgsIBGrid
          Left = 2
          Top = 4
          Width = 410
          Height = 340
          Anchors = [akLeft, akTop, akRight]
          DataSource = dsSelPrMetal
          Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 3
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
        end
      end
    end
    object tsBarCode: TTabSheet
      Caption = '&4 Штрих коды'
      ImageIndex = 5
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 498
        Height = 349
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Button2: TButton
          Left = 418
          Top = 4
          Width = 75
          Height = 25
          Action = actAddBarCode
          Anchors = [akTop, akRight]
          TabOrder = 0
        end
        object Button3: TButton
          Left = 418
          Top = 36
          Width = 75
          Height = 25
          Action = actEditBarCode
          Anchors = [akTop, akRight]
          TabOrder = 1
        end
        object Button4: TButton
          Left = 418
          Top = 68
          Width = 75
          Height = 25
          Action = actDelBarCode
          Anchors = [akTop, akRight]
          TabOrder = 2
        end
        object Button17: TButton
          Left = 418
          Top = 132
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Справка'
          TabOrder = 3
        end
        object gdibgrBarCode: TgsIBGrid
          Left = 3
          Top = 4
          Width = 409
          Height = 340
          Anchors = [akLeft, akTop, akRight]
          DataSource = dsBarCode
          Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 4
          OnDblClick = gdibgrBarCodeDblClick
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
        end
      end
    end
    object tsAttribute: TTabSheet
      Caption = '&5 Атрибуты'
      ImageIndex = 1
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 381
    Width = 506
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnRight: TButton
      Left = 4
      Top = 8
      Width = 80
      Height = 25
      Action = actSetRight
      TabOrder = 0
    end
    object btnNew: TButton
      Left = 245
      Top = 8
      Width = 80
      Height = 25
      Action = actNew
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
    object btnOk: TButton
      Left = 337
      Top = 8
      Width = 80
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 2
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 421
      Top = 8
      Width = 80
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 3
    end
  end
  object ActionList: TActionList
    Left = 88
    Top = 104
    object actSetRight: TAction
      Caption = 'Права...'
    end
    object actNew: TAction
      Caption = 'Новый'
      OnExecute = actNewExecute
    end
    object actAddValue: TAction
      Caption = '...'
      OnExecute = actAddValueExecute
    end
    object actAddTNVD: TAction
      Caption = '...'
      OnExecute = actAddTNVDExecute
    end
    object actShowBarCode: TAction
      Category = 'BarCode'
      Caption = 'actShowBarCode'
    end
    object actAddBarCode: TAction
      Category = 'BarCode'
      Caption = 'Добавить...'
      OnExecute = actAddBarCodeExecute
    end
    object actEditBarCode: TAction
      Category = 'BarCode'
      Caption = 'Изменить...'
      OnExecute = actEditBarCodeExecute
      OnUpdate = actEditBarCodeUpdate
    end
    object actDelBarCode: TAction
      Category = 'BarCode'
      Caption = 'Удалить'
      OnExecute = actDelBarCodeExecute
      OnUpdate = actDelBarCodeUpdate
    end
    object actAddPrMetal: TAction
      Category = 'PrMetal'
      Caption = 'Выбрать...'
      OnExecute = actAddPrMetalExecute
    end
    object actDelPrMetal: TAction
      Category = 'PrMetal'
      Caption = 'Удалить'
      OnExecute = actDelPrMetalExecute
      OnUpdate = actDelPrMetalUpdate
    end
    object actShowPrMetal: TAction
      Category = 'PrMetal'
      Caption = 'actShowPrMetal'
    end
    object actAddTax: TAction
      Category = 'Tax'
      Caption = 'Выбрать...'
      OnExecute = actAddTaxExecute
    end
    object actSetValue: TAction
      Category = 'Value'
      Caption = 'Выбрать...'
      OnExecute = actSetValueExecute
    end
    object actDelValue: TAction
      Category = 'Value'
      Caption = 'Удалить'
      OnExecute = actDelValueExecute
      OnUpdate = actDelValueUpdate
    end
    object actShowValue: TAction
      Category = 'Value'
      Caption = 'actShowValue'
    end
    object actDelTax: TAction
      Category = 'Tax'
      Caption = 'Удалить'
      OnExecute = actDelTaxExecute
      OnUpdate = actDelTaxUpdate
    end
    object actNewAll: TAction
      Caption = 'actNewAll'
      ShortCut = 45
      OnExecute = actNewAllExecute
    end
    object actTaxSelect: TAction
      Caption = 'actTaxSelect'
      ShortCut = 16473
      OnExecute = actTaxSelectExecute
    end
  end
  object dsGood: TDataSource
    DataSet = ibdsGood
    Left = 231
    Top = 80
  end
  object ibtrGood: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 156
    Top = 104
  end
  object dsTax: TDataSource
    DataSet = ibdsSelTax
    Left = 125
    Top = 138
  end
  object dsValues: TDataSource
    DataSet = ibdsSelValue
    Left = 124
    Top = 168
  end
  object dsSelPrMetal: TDataSource
    DataSet = ibdsGoodPrMetal
    Left = 268
    Top = 136
  end
  object dsBarCode: TDataSource
    DataSet = ibdsBarCode
    Left = 268
    Top = 168
  end
  object ibdsBarCode: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrGood
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_goodbarcode'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_goodbarcode'
      '  (ID, GOODKEY, BARCODE, DESCRIPTION)'
      'values'
      '  (:ID, :GOODKEY, :BARCODE, :DESCRIPTION)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_goodbarcode '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_goodbarcode '
      'WHERE'
      '  goodkey = :goodkey')
    ModifySQL.Strings = (
      'update gd_goodbarcode'
      'set'
      '  ID = :ID,'
      '  GOODKEY = :GOODKEY,'
      '  BARCODE = :BARCODE,'
      '  DESCRIPTION = :DESCRIPTION'
      'where'
      '  ID = :OLD_ID')
    Left = 236
    Top = 168
  end
  object ibdsGoodPrMetal: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrGood
    BeforePost = ibdsGoodPrMetalBeforePost
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_GOODPRMETAL'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  PRMETALKEY = :OLD_PRMETALKEY')
    InsertSQL.Strings = (
      'insert into GD_GOODPRMETAL'
      '  (GOODKEY, PRMETALKEY, QUANTITY)'
      'values'
      '  (:GOODKEY, :PRMETALKEY, :QUANTITY)')
    RefreshSQL.Strings = (
      'select pm.Name, gprm.quantity, gprm.goodkey, gprm.prmetalkey'
      'FROM '
      '   GD_GOODPRMETAL gprm,'
      '   gd_preciousemetal pm'
      'where gprm.goodkey = :goodkey and'
      '  gprm.prmetalkey = pm.id and'
      '  PRMETALKEY = :PRMETALKEY')
    SelectSQL.Strings = (
      'select pm.Name, gprm.quantity, gprm.goodkey, gprm.prmetalkey'
      'FROM '
      '   GD_GOODPRMETAL gprm,'
      '   gd_preciousemetal pm'
      'where gprm.goodkey = :goodkey and'
      '  gprm.prmetalkey = pm.id')
    ModifySQL.Strings = (
      'update GD_GOODPRMETAL'
      'set'
      '  GOODKEY = :GOODKEY,'
      '  PRMETALKEY = :PRMETALKEY,'
      '  QUANTITY = :QUANTITY'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  PRMETALKEY = :OLD_PRMETALKEY')
    Left = 236
    Top = 136
  end
  object ibdsSelValue: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrGood
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_goodvalue'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  VALUEKEY = :OLD_VALUEKEY')
    InsertSQL.Strings = (
      'insert into gd_goodvalue'
      '  (GOODKEY, VALUEKEY, SCALE, DISCOUNT, DECDIGIT)'
      'values'
      '  (:GOODKEY, :VALUEKEY, :SCALE, :DISCOUNT, :DECDIGIT)')
    RefreshSQL.Strings = (
      'SELECT'
      '  ggv.*, gv.name'
      'FROM'
      '  gd_goodvalue ggv JOIN gd_value gv ON ggv.valuekey = gv.id and'
      '   ggv.goodkey = :goodkey'
      'WHERE'
      '  ggv.VALUEKEY = :VALUEKEY')
    SelectSQL.Strings = (
      'SELECT'
      '  ggv.*, gv.name'
      'FROM'
      '  gd_goodvalue ggv JOIN gd_value gv ON ggv.valuekey = gv.id and'
      '   ggv.goodkey = :goodkey')
    ModifySQL.Strings = (
      'update gd_goodvalue'
      'set'
      '  GOODKEY = :GOODKEY,'
      '  VALUEKEY = :VALUEKEY,'
      '  SCALE = :SCALE,'
      '  DISCOUNT = :DISCOUNT,'
      '  DECDIGIT = :DECDIGIT'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  VALUEKEY = :OLD_VALUEKEY')
    Left = 156
    Top = 168
  end
  object ibdsSelTax: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrGood
    AfterInsert = ibdsSelTaxAfterInsert
    AfterPost = ibdsSelTaxAfterPost
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_goodtax'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  TAXKEY = :OLD_TAXKEY')
    InsertSQL.Strings = (
      'insert into gd_goodtax'
      '  (GOODKEY, TAXKEY, DATETAX, RATE)'
      'values'
      '  (:GOODKEY, :TAXKEY, :DATETAX, :RATE)')
    RefreshSQL.Strings = (
      'SELECT'
      '  ggt.*,'
      '  gt.name'
      ''
      'FROM'
      '  gd_goodtax ggt'
      '  , gd_tax gt'
      'WHERE'
      '  ggt.goodkey = :goodkey'
      '  AND gt.id = ggt.taxkey and'
      '  TAXKEY = :TAXKEY and'
      '  datetax = :datetax')
    SelectSQL.Strings = (
      'SELECT'
      '  ggt.*,'
      '  gt.name'
      ''
      'FROM'
      '  gd_goodtax ggt'
      '  , gd_tax gt'
      'WHERE'
      '  ggt.goodkey = :goodkey'
      '  AND gt.id = ggt.taxkey')
    ModifySQL.Strings = (
      'update gd_goodtax'
      'set'
      '  GOODKEY = :GOODKEY,'
      '  TAXKEY = :TAXKEY,'
      '  DATETAX = :DATETAX,'
      '  RATE = :RATE'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  TAXKEY = :OLD_TAXKEY and'
      '  DATETAX = :OLD_DATETAX')
    Left = 156
    Top = 139
  end
  object ibdsGood: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrGood
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_good'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_good'
      
        '  (ID, GROUPKEY, NAME, SHORTNAME, ALIAS, DESCRIPTION, BARCODE, V' +
        'ALUEKEY, '
      'TNVDKEY, '
      '   ISASSEMBLY, RESERVED, DISABLED, AFULL, ACHAG, AVIEW)'
      'values'
      
        '  (:ID, :GROUPKEY, :NAME, :SHORTNAME, :ALIAS, :DESCRIPTION, :BAR' +
        'CODE, :VALUEKEY, '
      ':TNVDKEY, '
      '   :ISASSEMBLY, :RESERVED, :DISABLED, :AFULL, :ACHAG, :AVIEW)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_good '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  *'
      'FROM'
      '  gd_good'
      'WHERE'
      '  id = :id')
    ModifySQL.Strings = (
      'update gd_good'
      'set'
      '  ID = :ID,'
      '  GROUPKEY = :GROUPKEY,'
      '  NAME = :NAME,'
      '  SHORTNAME = :SHORTNAME,'
      '  ALIAS = :ALIAS,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  BARCODE = :BARCODE,'
      '  VALUEKEY = :VALUEKEY,'
      '  TNVDKEY = :TNVDKEY,'
      '  ISASSEMBLY = :ISASSEMBLY,'
      '  RESERVED = :RESERVED,'
      '  DISABLED = :DISABLED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    Left = 204
    Top = 80
  end
  object ibsqlNewGood: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    Transaction = ibtrGood
    Left = 284
    Top = 88
  end
  object ibsqlNewBarCode: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    Transaction = ibtrGood
    Left = 284
    Top = 56
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 150
    Top = 240
  end
end
