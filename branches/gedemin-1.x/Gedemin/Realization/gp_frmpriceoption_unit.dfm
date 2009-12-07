object frmPriceOption: TfrmPriceOption
  Left = 243
  Top = 115
  Width = 696
  Height = 480
  Caption = 'Настройка прайс-листов'
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
  PixelsPerInch = 96
  TextHeight = 13
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 32
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        Width = 684
      end>
    object ToolBar1: TToolBar
      Left = 9
      Top = 0
      Width = 671
      Height = 25
      ButtonHeight = 21
      ButtonWidth = 67
      Caption = 'ToolBar1'
      Flat = True
      ShowCaptions = True
      TabOrder = 0
      TabStop = True
      Transparent = True
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = actNewOption
      end
      object ToolButton2: TToolButton
        Left = 67
        Top = 0
        Action = actEditOption
      end
      object ToolButton3: TToolButton
        Left = 134
        Top = 0
        Action = actDelOption
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 32
    Width = 688
    Height = 421
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object gsibgrPricePosOption: TgsIBGrid
      Left = 5
      Top = 5
      Width = 678
      Height = 411
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsPricePosOption
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
  object ActionList1: TActionList
    Left = 488
    Top = 160
    object actNewOption: TAction
      Caption = 'Добавить...'
      OnExecute = actNewOptionExecute
    end
    object actEditOption: TAction
      Caption = 'Изменить...'
      OnExecute = actEditOptionExecute
    end
    object actDelOption: TAction
      Caption = 'Удалить'
      OnExecute = actDelOptionExecute
    end
  end
  object dsPricePosOption: TDataSource
    DataSet = ibdsPricePosOption
    Left = 320
    Top = 152
  end
  object ibdsPricePosOption: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_priceposoption'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME')
    InsertSQL.Strings = (
      'insert into gd_priceposoption'
      '  (FIELDNAME, CURRKEY, EXPRESSION, DISABLED, RESERVED)'
      'values'
      '  (:FIELDNAME, :CURRKEY, :EXPRESSION, :DISABLED, :RESERVED)')
    RefreshSQL.Strings = (
      'SELECT '
      '  g.fieldname,'
      '  g.currkey,'
      '  g.expression,'
      '  g.disabled,'
      '  g.reserved,'
      '  c.name'
      'FROM gd_priceposoption g LEFT JOIN gd_curr c ON g.currkey = c.id'
      'where'
      '  FIELDNAME = :FIELDNAME')
    SelectSQL.Strings = (
      'SELECT '
      '  g.fieldname,'
      '  g.currkey,'
      '  g.expression,'
      '  g.disabled,'
      '  g.reserved,'
      '  c.name'
      'FROM gd_priceposoption g LEFT JOIN gd_curr c ON g.currkey = c.id')
    ModifySQL.Strings = (
      'update gd_priceposoption'
      'set'
      '  FIELDNAME = :FIELDNAME,'
      '  CURRKEY = :CURRKEY,'
      '  EXPRESSION = :EXPRESSION,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED'
      'where'
      '  FIELDNAME = :OLD_FIELDNAME')
    Left = 352
    Top = 152
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 352
    Top = 184
  end
end
