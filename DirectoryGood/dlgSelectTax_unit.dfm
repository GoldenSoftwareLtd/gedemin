object dlgSelectTax: TdlgSelectTax
  Left = 223
  Top = 127
  ActiveControl = xdeDate
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор налогов на товар'
  ClientHeight = 393
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 356
    Width = 492
    Height = 37
    Align = alClient
    TabOrder = 0
    object btnOk: TButton
      Left = 329
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 411
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 492
    Height = 356
    Align = alTop
    TabOrder = 1
    object Button1: TButton
      Left = 411
      Top = 8
      Width = 75
      Height = 25
      Action = actAddTax
      TabOrder = 0
    end
    object Button2: TButton
      Left = 411
      Top = 40
      Width = 75
      Height = 25
      Action = actEditTax
      TabOrder = 1
    end
    object Button3: TButton
      Left = 411
      Top = 72
      Width = 75
      Height = 25
      Action = actDelTax
      TabOrder = 2
    end
    object Button4: TButton
      Left = 411
      Top = 105
      Width = 75
      Height = 25
      Action = actSelect
      TabOrder = 3
    end
    object Panel3: TPanel
      Left = 10
      Top = 9
      Width = 393
      Height = 337
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      Caption = 'Panel3'
      TabOrder = 4
      object gsibgrTax: TgsIBGrid
        Left = 5
        Top = 33
        Width = 383
        Height = 299
        Align = alClient
        DataSource = dsTax
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 1
        OnDblClick = gsibgrTaxDblClick
        OnKeyDown = gsibgrTaxKeyDown
        SelectedColor = clAppWorkSpace
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.DisplayField = 'Name'
        CheckBox.FieldName = 'ID'
        CheckBox.Visible = True
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
      object pDate: TPanel
        Left = 5
        Top = 5
        Width = 383
        Height = 28
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 6
          Top = 8
          Width = 119
          Height = 13
          Caption = 'Дата установки налога'
        end
        object xdeDate: TxDateEdit
          Left = 137
          Top = 3
          Width = 121
          Height = 21
          EditMask = '!99/99/9999;1;_'
          MaxLength = 10
          TabOrder = 0
          Text = '16.05.2002'
          Kind = kDate
          CurrentDateTimeAtStart = True
        end
      end
    end
  end
  object ActionList1: TActionList
    Left = 296
    Top = 152
    object actAddTax: TAction
      Caption = 'Добавить...'
      ShortCut = 45
      OnExecute = actAddTaxExecute
    end
    object actEditTax: TAction
      Caption = 'Изменить...'
      OnExecute = actEditTaxExecute
      OnUpdate = actEditTaxUpdate
    end
    object actDelTax: TAction
      Caption = 'Удалить'
      ShortCut = 46
      OnExecute = actDelTaxExecute
      OnUpdate = actDelTaxUpdate
    end
    object actShowTax: TAction
      Caption = 'act'
    end
    object actSelect: TAction
      Caption = 'Отметить'
      ShortCut = 16449
      OnExecute = actSelectExecute
    end
  end
  object dsTax: TDataSource
    DataSet = ibdsTax
    Left = 64
    Top = 104
  end
  object ibdsTax: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_tax'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_tax'
      '  (ID, NAME, SHOT, RATE)'
      'values'
      '  (:ID, :NAME, :SHOT, :RATE)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_tax '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_tax')
    ModifySQL.Strings = (
      'update gd_tax'
      'set'
      '  ID = :ID,'
      '  NAME = :NAME,'
      '  SHOT = :SHOT,'
      '  RATE = :RATE'
      'where'
      '  ID = :OLD_ID')
    Left = 96
    Top = 104
  end
  object ibsqlAddNew: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      
        'INSERT INTO gd_goodtax(goodkey, taxkey, datetax, rate) VALUES (:' +
        'goodkey, :taxkey, :datetax, :rate)')
    Transaction = IBTransaction
    Left = 136
    Top = 104
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 130
    Top = 40
  end
  object ibsqlAddNewForGroup: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'INSERT INTO gd_goodtax (goodkey, taxkey, datetax, rate)'
      'SELECT g.id, :taxkey, :datetax, :rate FROM gd_good g'
      'WHERE g.groupkey = :groupkey AND '
      '   not exists (SELECT * FROM gd_goodtax gt WHERE'
      '  gt.goodkey = g.id and taxkey = :taxkey and datetax = :datetax)')
    Transaction = IBTransaction
    Left = 166
    Top = 104
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 170
    Top = 133
  end
end
