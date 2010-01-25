object frmRegistryForm: TfrmRegistryForm
  Left = 173
  Top = 137
  Width = 544
  Height = 375
  Caption = 'Список печатных форм'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object pnlDemandPayment: TPanel
    Left = 0
    Top = 28
    Width = 536
    Height = 320
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object pnlDocument: TPanel
      Left = 4
      Top = 4
      Width = 528
      Height = 312
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object dbgReportRegistry: TgsIBGrid
        Left = 0
        Top = 0
        Width = 528
        Height = 312
        Align = alClient
        DataSource = dsReportRegistry
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgMultiSelect]
        PopupMenu = pmReportRegistry
        TabOrder = 0
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
        ToolBar = ToolBar2
        ColumnEditors = <>
        Aliases = <>
      end
    end
  end
  object ControlBar1: TControlBar
    Left = 0
    Top = 0
    Width = 536
    Height = 28
    Align = alTop
    BevelInner = bvNone
    BevelOuter = bvNone
    RowSize = 28
    TabOrder = 1
    object ToolBar1: TToolBar
      Left = 11
      Top = 2
      Width = 72
      Height = 24
      Align = alLeft
      AutoSize = True
      ButtonHeight = 24
      ButtonWidth = 24
      Caption = 'ToolBar1'
      Ctl3D = False
      EdgeInner = esNone
      EdgeOuter = esNone
      Flat = True
      Images = dmImages.ilTree
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = actAdd
      end
      object ToolButton2: TToolButton
        Left = 24
        Top = 0
        Action = actEdit
      end
      object tbDelete: TToolButton
        Left = 48
        Top = 0
        Action = actDelete
      end
    end
    object ToolBar2: TToolBar
      Left = 107
      Top = 2
      Width = 151
      Height = 24
      Align = alNone
      ButtonHeight = 24
      ButtonWidth = 24
      Caption = 'ToolBar2'
      Ctl3D = False
      EdgeInner = esNone
      EdgeOuter = esNone
      Flat = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object alReportRegistry: TActionList
    Images = dmImages.ilTree
    Left = 210
    Top = 280
    object actAdd: TAction
      Caption = 'Новый ...'
      Hint = 'Новый ...'
      ImageIndex = 44
      ShortCut = 45
      OnExecute = actAddExecute
    end
    object actEdit: TAction
      Caption = 'Изменить ...'
      Hint = 'Изменить ...'
      ImageIndex = 42
      ShortCut = 13
      OnExecute = actEditExecute
    end
    object actDelete: TAction
      Caption = 'Удалить ...'
      Hint = 'Удалить ...'
      ImageIndex = 38
      ShortCut = 46
      OnExecute = actDeleteExecute
    end
    object actCopy: TAction
      Caption = 'Копировать'
      Hint = 'Копировать'
      ImageIndex = 21
    end
  end
  object dsReportRegistry: TDataSource
    DataSet = qryReportRegistry
    Left = 270
    Top = 280
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 240
    Top = 280
  end
  object qryReportRegistry: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    SQL.Strings = (
      'SELECT * FROM rp_registry'
      'WHERE parent = :parent'
      'and'
      '(g_sec_testall(aview, achag, afull,  /*<UserGroups>*/-1)  <> 0)')
    UpdateObject = ibuReportRegistry
    Left = 300
    Top = 280
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'parent'
        ParamType = ptUnknown
      end>
  end
  object pmReportRegistry: TPopupMenu
    Left = 360
    Top = 280
    object N1: TMenuItem
      Action = actAdd
    end
    object N2: TMenuItem
      Action = actEdit
    end
    object N3: TMenuItem
      Action = actDelete
    end
  end
  object ibuReportRegistry: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  PARENT,'
      '  NAME,'
      '  FILENAME,'
      '  HOTKEY,'
      '  ISQUICK,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  RESERVED,'
      '  ISREGISTRY,'
      '  TEMPLATE'
      'from rp_registry '
      'where'
      '  ID = :ID')
    ModifySQL.Strings = (
      'update rp_registry'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  NAME = :NAME,'
      '  FILENAME = :FILENAME,'
      '  HOTKEY = :HOTKEY,'
      '  ISQUICK = :ISQUICK,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  RESERVED = :RESERVED,'
      '  ISREGISTRY = :ISREGISTRY,'
      '  TEMPLATE = :TEMPLATE'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into rp_registry'
      
        '  (ID, PARENT, NAME, FILENAME, HOTKEY, ISQUICK, AFULL, ACHAG, AV' +
        'IEW, '
      'RESERVED, '
      '   ISREGISTRY, TEMPLATE)'
      'values'
      
        '  (:ID, :PARENT, :NAME, :FILENAME, :HOTKEY, :ISQUICK, :AFULL, :A' +
        'CHAG, '
      ':AVIEW, '
      '   :RESERVED, :ISREGISTRY, :TEMPLATE)')
    DeleteSQL.Strings = (
      'delete from rp_registry'
      'where'
      '  ID = :OLD_ID')
    Left = 330
    Top = 280
  end
  object IBSQL: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT * FROM RP_REGISTRY'
      'WHERE ID = :ID')
    Transaction = IBTransaction
    Left = 150
    Top = 280
  end
end
