object at_frmNSRecursion: Tat_frmNSRecursion
  Left = 293
  Top = 196
  Width = 1142
  Height = 656
  Caption = 'Рекурсия пространств имен'
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
  object sb: TStatusBar
    Left = 0
    Top = 599
    Width = 1126
    Height = 19
    Panels = <>
    SimplePanel = False
  end
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
    end
  end
  object gsIBGrid: TgsIBGrid
    Left = 0
    Top = 26
    Width = 1126
    Height = 573
    Align = alClient
    BorderStyle = bsNone
    DataSource = ds
    Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
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
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
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
      'SELECT DISTINCT'
      '  f.OutPath'
      'FROM'
      '  at_namespace n LEFT JOIN at_p_findnsrec('#39#39', n.id, n.id) f'
      '    ON f.OutFirstID = n.id'
      'WHERE'
      '  f.OutPath > '#39#39)
    ReadTransaction = ibtr
    Left = 584
    Top = 296
  end
  object ds: TDataSource
    DataSet = ibds
    OnDataChange = dsDataChange
    Left = 616
    Top = 296
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 800
    Top = 80
  end
end
