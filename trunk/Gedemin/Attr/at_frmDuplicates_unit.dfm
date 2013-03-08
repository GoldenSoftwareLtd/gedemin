object at_frmDuplicates: Tat_frmDuplicates
  Left = 359
  Top = 231
  Width = 1142
  Height = 654
  Caption = 'Дубликаты позиций пространств имен'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 1126
    Height = 26
    object tb: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'tb'
      CloseButton = False
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object TBItem1: TTBItem
        Action = actOpenObject
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
    end
  end
  object sb: TStatusBar
    Left = 0
    Top = 597
    Width = 1126
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object gsIBGrid1: TgsIBGrid
    Left = 0
    Top = 26
    Width = 1126
    Height = 571
    Align = alClient
    BorderStyle = bsNone
    DataSource = ds
    Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 2
    InternalMenuKind = imkWithSeparator
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
    ColumnEditors = <>
    Aliases = <>
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 816
    Top = 80
    object actOpenObject: TAction
      Caption = 'actOpenObject'
      ImageIndex = 1
      OnExecute = actOpenObjectExecute
      OnUpdate = actOpenObjectUpdate
    end
  end
  object ibtr: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 552
    Top = 296
  end
  object ibds: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtr
    SelectSQL.Strings = (
      'SELECT'
      
        '  o.objectclass, o.subtype, o.objectname, o.xid, o.dbid, list(n.' +
        'id || '#39'='#39' || n.name) as ns_list, count(*)'
      'FROM '
      '  at_object o JOIN at_namespace n ON n.id = o.namespacekey'
      'WHERE'
      '  o.xid > 147000000'
      'GROUP BY'
      '  o.objectclass, o.subtype, o.objectname, o.xid, o.dbid'
      'HAVING'
      '  count(*) > 1'
      'ORDER BY'
      '  o.objectclass, o.subtype, o.objectname')
    ReadTransaction = ibtr
    Left = 592
    Top = 296
  end
  object ds: TDataSource
    DataSet = ibds
    OnDataChange = dsDataChange
    Left = 552
    Top = 336
  end
end
