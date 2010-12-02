object dlgFindGood: TdlgFindGood
  Left = 172
  Top = 152
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Поиск товаров'
  ClientHeight = 371
  ClientWidth = 533
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 10
    Top = 5
    Width = 381
    Height = 43
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 15
      Width = 79
      Height = 13
      Caption = 'Наименование:'
    end
    object edName: TEdit
      Left = 95
      Top = 11
      Width = 275
      Height = 21
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 400
    Top = 5
    Width = 126
    Height = 21
    Action = actFind
    Default = True
    TabOrder = 1
  end
  object Button3: TButton
    Left = 400
    Top = 30
    Width = 126
    Height = 21
    Cancel = True
    Caption = 'Закрыть'
    ModalResult = 2
    TabOrder = 2
  end
  object Panel2: TPanel
    Left = 10
    Top = 55
    Width = 381
    Height = 309
    BevelOuter = bvNone
    TabOrder = 3
    object dbgGood: TgsIBGrid
      Left = 0
      Top = 0
      Width = 381
      Height = 309
      Align = alClient
      Ctl3D = True
      DataSource = dsGood
      Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      ParentCtl3D = False
      TabOrder = 0
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
  object btnProperty: TButton
    Left = 400
    Top = 55
    Width = 126
    Height = 21
    Action = actProperty
    TabOrder = 4
  end
  object btnDelete: TButton
    Left = 400
    Top = 80
    Width = 126
    Height = 21
    Action = actDelete
    TabOrder = 5
  end
  object PopupMenu: TPopupMenu
    Left = 210
    Top = 174
    object N1: TMenuItem
      Action = actProperty
    end
    object N2: TMenuItem
      Action = actDelete
    end
  end
  object ActionList1: TActionList
    Left = 240
    Top = 175
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actProperty: TAction
      Caption = 'Свойства ...'
      OnExecute = actPropertyExecute
      OnUpdate = actPropertyUpdate
    end
    object actFind: TAction
      Caption = 'Поиск'
      OnExecute = actFindExecute
    end
  end
  object dsGood: TDataSource
    DataSet = qryGood
    Left = 181
    Top = 206
  end
  object qryGood: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'select * from gd_good')
    UpdateObject = ibusGood
    Left = 210
    Top = 206
  end
  object ibusGood: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select *'
      'from gd_good '
      'where'
      '  ID = :ID')
    ModifySQL.Strings = (
      'update gd_good'
      'set'
      '  ID = :ID,'
      '  GROUPKEY = :GROUPKEY,'
      '  NAME = :NAME,'
      '  ALIAS = :ALIAS,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  BARCODE = :BARCODE,'
      '  VALUEKEY = :VALUEKEY,'
      '  TNVDKEY = :TNVDKEY,'
      '  ISASSEMBLY = :ISASSEMBLY,'
      '  RESERVED = :RESERVED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_good'
      '  (ID, GROUPKEY, NAME, ALIAS, DESCRIPTION, BARCODE, VALUEKEY, '
      'TNVDKEY, '
      '   ISASSEMBLY, RESERVED, AFULL, ACHAG, AVIEW)'
      'values'
      
        '  (:ID, :GROUPKEY, :NAME, :ALIAS, :DESCRIPTION, :BARCODE, :VALUE' +
        'KEY, '
      ':TNVDKEY, '
      '   :ISASSEMBLY, :RESERVED, :AFULL, :ACHAG, :AVIEW)')
    DeleteSQL.Strings = (
      'delete from gd_good'
      'where'
      '  ID = :OLD_ID')
    Left = 239
    Top = 206
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 152
    Top = 206
  end
  object DirectGood: TboDirectGood
    DGDatabase = dmDatabase.ibdbGAdmin
    DGTransaction = IBTransaction
    Left = 180
    Top = 176
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 299
    Top = 176
  end
end
