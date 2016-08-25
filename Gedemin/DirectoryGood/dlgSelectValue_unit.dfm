object dlgSelectValue: TdlgSelectValue
  Left = 252
  Top = 156
  ActiveControl = gsibgrSelValues
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор дополнительных единиц измерения'
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 492
    Height = 356
    Align = alTop
    TabOrder = 0
    object Button1: TButton
      Left = 411
      Top = 8
      Width = 75
      Height = 25
      Action = actAddValue
      TabOrder = 0
    end
    object Button2: TButton
      Left = 411
      Top = 40
      Width = 75
      Height = 25
      Action = actEditValue
      TabOrder = 1
    end
    object Button3: TButton
      Left = 411
      Top = 72
      Width = 75
      Height = 25
      Action = actDelValue
      TabOrder = 2
    end
    object Button4: TButton
      Left = 411
      Top = 112
      Width = 75
      Height = 25
      Action = actSelect
      TabOrder = 3
    end
    object gsibgrSelValues: TgsIBGrid
      Left = 8
      Top = 8
      Width = 393
      Height = 338
      DataSource = dsValue
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 4
      OnDblClick = gsibgrSelValuesDblClick
      OnKeyDown = gsibgrSelValuesKeyDown
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
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
  end
  object Panel2: TPanel
    Left = 0
    Top = 356
    Width = 492
    Height = 37
    Align = alClient
    TabOrder = 1
    object btnOk: TButton
      Left = 326
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 408
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ActionList1: TActionList
    Left = 136
    Top = 64
    object actAddValue: TAction
      Caption = 'Добавить...'
      ShortCut = 45
      OnExecute = actAddValueExecute
    end
    object actEditValue: TAction
      Caption = 'Изменить...'
      OnExecute = actEditValueExecute
      OnUpdate = actEditValueUpdate
    end
    object actDelValue: TAction
      Caption = 'Удалить'
      ShortCut = 46
      OnExecute = actDelValueExecute
      OnUpdate = actDelValueUpdate
    end
    object actShowValue: TAction
      Caption = 'actShowValue'
    end
    object actSelect: TAction
      Caption = 'Выбрать все'
      ShortCut = 16449
      OnExecute = actSelectExecute
    end
  end
  object dsValue: TDataSource
    DataSet = ibdsValues
    Left = 72
    Top = 201
  end
  object ibdsValues: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_VALUE'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_VALUE'
      '  (ID, NAME, DESCRIPTION)'
      'values'
      '  (:ID, :NAME, :DESCRIPTION)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  NAME,'
      '  DESCRIPTION'
      'from GD_VALUE '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'select * from GD_VALUE')
    ModifySQL.Strings = (
      'update GD_VALUE'
      'set'
      '  ID = :ID,'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION'
      'where'
      '  ID = :OLD_ID')
    Left = 40
    Top = 201
  end
  object ibsqlAddNew: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      
        'INSERT INTO gd_goodvalue(goodkey, valuekey) VALUES (:goodkey, :v' +
        'aluekey)')
    Left = 136
    Top = 104
  end
  object ibsqlAddValue: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'INSERT INTO gd_value(id, name, description) VALUES (:ID, '
      '  :name, :description)')
    Left = 136
    Top = 200
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 130
    Top = 140
  end
end
