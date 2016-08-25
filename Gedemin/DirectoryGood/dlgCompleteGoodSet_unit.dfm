object dlgCompleteGoodSet: TdlgCompleteGoodSet
  Left = 248
  Top = 122
  ActiveControl = gsibdsGoodSet
  BorderStyle = bsDialog
  Caption = 'Список комплектующих'
  ClientHeight = 393
  ClientWidth = 492
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 161
    Height = 13
    Caption = 'Наименование комплекта:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblName: TLabel
    Left = 176
    Top = 8
    Width = 70
    Height = 13
    Caption = 'Комплект 1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 411
    Top = 23
    Width = 75
    Height = 25
    Action = actAddItem
    TabOrder = 0
  end
  object Button2: TButton
    Left = 411
    Top = 55
    Width = 75
    Height = 25
    Action = actEditItem
    TabOrder = 1
  end
  object Button3: TButton
    Left = 411
    Top = 87
    Width = 75
    Height = 25
    Action = actDelItem
    TabOrder = 2
  end
  object gsibdsGoodSet: TgsIBGrid
    Left = 8
    Top = 25
    Width = 393
    Height = 313
    DataSource = dsGoodSet
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
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
  object Panel2: TPanel
    Left = 0
    Top = 352
    Width = 492
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object btnOk: TButton
      Left = 330
      Top = 6
      Width = 75
      Height = 25
      Action = acOk
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 412
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 256
    Top = 40
    object N1: TMenuItem
      Action = actAddItem
    end
    object N2: TMenuItem
      Action = actEditItem
    end
    object N3: TMenuItem
      Action = actDelItem
    end
  end
  object ActionList1: TActionList
    Left = 296
    Top = 40
    object actAddItem: TAction
      Caption = 'Выбрать...'
      OnExecute = actAddItemExecute
    end
    object actEditItem: TAction
      Caption = 'Изменить...'
    end
    object actDelItem: TAction
      Caption = 'Удалить'
      OnExecute = actDelItemExecute
    end
    object acOk: TAction
      Caption = 'OK'
      OnExecute = acOkExecute
    end
  end
  object dsGoodSet: TDataSource
    DataSet = ibdsGoodSet
    Left = 72
    Top = 208
  end
  object ibsqlSetName: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    Transaction = IBTransaction
    Left = 136
    Top = 208
  end
  object ibdsGoodSet: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'DELETE FROM gd_goodset'
      'WHERE'
      '  goodkey = :OLD_goodkey AND'
      '  setkey = :OLD_setkey')
    InsertSQL.Strings = (
      'INSERT INTO gd_goodset(goodkey, setkey, goodcount) '
      'VALUES (:goodkey, :setkey, :goodcount)')
    RefreshSQL.Strings = (
      'SELECT g.Name, gs.GoodCount FROM'
      '  gd_goodset gs JOIN gd_good g ON gs.setkey = g.id and'
      '    gs.goodkey = :setkey'
      'WHERE'
      '  gs.setkey = :setkey')
    SelectSQL.Strings = (
      'SELECT g.Name, gs.GoodCount, gs.goodkey, gs.setkey FROM'
      '  gd_goodset gs JOIN gd_good g ON gs.setkey = g.id and'
      '    gs.goodkey = :setkey')
    ModifySQL.Strings = (
      'UPDATE gd_goodset'
      'SET'
      '  goodkey = :goodkey,'
      '  setkey = :setkey,'
      '  goodcount = :goodcount'
      'WHERE'
      '  goodkey = :OLD_goodkey and'
      '  setkey = :OLD_setkey')
    Left = 45
    Top = 208
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 176
    Top = 208
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 210
    Top = 210
  end
end
