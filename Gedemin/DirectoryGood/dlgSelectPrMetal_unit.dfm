object dlgSelectPrMetal: TdlgSelectPrMetal
  Left = 254
  Top = 132
  ActiveControl = gsibgrPrMetal
  BorderStyle = bsDialog
  Caption = 'Выбор драгметаллов для товара'
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
      Left = 330
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OK'
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 492
    Height = 356
    Align = alTop
    TabOrder = 1
    object Button1: TButton
      Left = 409
      Top = 8
      Width = 75
      Height = 25
      Action = actAddPrMetal
      TabOrder = 1
    end
    object Button2: TButton
      Left = 409
      Top = 40
      Width = 75
      Height = 25
      Action = actEditPrMetal
      TabOrder = 2
    end
    object Button4: TButton
      Left = 409
      Top = 112
      Width = 75
      Height = 25
      Action = actSelect
      TabOrder = 4
    end
    object gsibgrPrMetal: TgsIBGrid
      Left = 8
      Top = 8
      Width = 393
      Height = 338
      DataSource = dsPrMetal
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 0
      SelectedColor = clAppWorkSpace
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      TitlesExpanding = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.DisplayField = 'NAME'
      CheckBox.FieldName = 'ID'
      CheckBox.Visible = True
      CheckBox.FirstColumn = False
      MinColWidth = 40
      ColumnEditors = <>
      Aliases = <>
    end
    object Button3: TButton
      Left = 409
      Top = 71
      Width = 75
      Height = 25
      Action = actDelPrMetal
      TabOrder = 3
    end
  end
  object ActionList1: TActionList
    Left = 296
    Top = 152
    object actAddPrMetal: TAction
      Caption = 'Добавить...'
      ShortCut = 45
      OnExecute = actAddPrMetalExecute
    end
    object actEditPrMetal: TAction
      Caption = 'Изменить...'
      OnExecute = actEditPrMetalExecute
      OnUpdate = actEditPrMetalUpdate
    end
    object actSelect: TAction
      Caption = 'Отметить'
      ShortCut = 16449
    end
    object actDelPrMetal: TAction
      Caption = 'Удалить'
      ShortCut = 46
      OnExecute = actDelPrMetalExecute
      OnUpdate = actDelPrMetalUpdate
    end
  end
  object dsPrMetal: TDataSource
    DataSet = ibdsPrMetal
    Left = 104
    Top = 201
  end
  object ibdsPrMetal: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = frmGedeminMain.IBTransaction
    DeleteSQL.Strings = (
      'delete from GD_PRECIOUSEMETAL'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_PRECIOUSEMETAL'
      '  (ID, NAME, DESCRIPTION)'
      'values'
      '  (:ID, :NAME, :DESCRIPTION)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  NAME,'
      '  DESCRIPTION'
      'from GD_PRECIOUSEMETAL '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'select * from GD_PRECIOUSEMETAL')
    ModifySQL.Strings = (
      'update GD_PRECIOUSEMETAL'
      'set'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = frmGedeminMain.IBTransaction
    Left = 136
    Top = 201
  end
  object ibsqlAddNew: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      
        'INSERT INTO gd_goodprmetal(goodkey, prmetalkey) VALUES (:goodkey' +
        ', :prmetalkey)')
    Transaction = frmGedeminMain.IBTransaction
    Left = 136
    Top = 104
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 110
    Top = 30
  end
end
