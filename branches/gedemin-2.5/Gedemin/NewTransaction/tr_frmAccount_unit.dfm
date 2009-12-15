object frmAccount: TfrmAccount
  Left = 255
  Top = 143
  Width = 696
  Height = 480
  ActiveControl = gsdbtvGroupAccount
  Caption = 'Справочник бухгалтерских счетов'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 29
    Width = 688
    Height = 424
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 233
      Top = 0
      Width = 3
      Height = 424
      Cursor = crHSplit
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 233
      Height = 424
      Align = alLeft
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      Caption = 'Panel2'
      TabOrder = 0
      object gsdbtvGroupAccount: TgsDBTreeView
        Left = 5
        Top = 5
        Width = 223
        Height = 414
        DataSource = dsGroupAccount
        KeyField = 'ID'
        ParentField = 'PARENT'
        DisplayField = 'NAME'
        Align = alClient
        AutoExpand = True
        BorderStyle = bsNone
        HideSelection = False
        Images = dmImages.ilTree
        Indent = 19
        PopupMenu = pOperation
        ReadOnly = True
        SortType = stText
        TabOrder = 0
        OnChanging = gsdbtvGroupAccountChanging
        OnDblClick = gsdbtvGroupAccountDblClick
        OnDragDrop = gsdbtvGroupAccountDragDrop
        OnDragOver = gsdbtvGroupAccountDragOver
        OnGetImageIndex = gsdbtvGroupAccountGetImageIndex
        OnGetSelectedIndex = gsdbtvGroupAccountGetSelectedIndex
        MainFolderHead = True
        MainFolder = False
        MainFolderCaption = 'Все'
        WithCheckBox = False
      end
    end
    object Panel3: TPanel
      Left = 236
      Top = 0
      Width = 452
      Height = 424
      Align = alClient
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      Caption = 'Необходимо создать план счетов'
      TabOrder = 1
      object gsibgrAccount: TgsIBGrid
        Left = 5
        Top = 5
        Width = 442
        Height = 414
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsAccount
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        PopupMenu = pOperAccount
        ReadOnly = True
        TabOrder = 0
        OnDblClick = gsibgrAccountDblClick
        OnDragOver = gsibgrAccountDragOver
        OnMouseMove = gsibgrAccountMouseMove
        OnStartDrag = gsibgrAccountStartDrag
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
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 29
    ButtonHeight = 21
    ButtonWidth = 71
    Caption = 'ToolBar1'
    Flat = True
    ShowCaptions = True
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 8
      Top = 0
      Action = actNew
    end
    object ToolButton3: TToolButton
      Left = 79
      Top = 0
      Action = actEdit
    end
    object ToolButton4: TToolButton
      Left = 150
      Top = 0
      Action = actDel
    end
    object ToolButton6: TToolButton
      Left = 221
      Top = 0
      Width = 5
      Caption = 'ToolButton6'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 226
      Top = 0
      Action = actPlanForFirm
    end
  end
  object ibdsGroupAccount: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_cardaccount'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_cardaccount'
      
        '  (ID, PARENT, LB, RB, ALIAS, NAME, TYPEACCOUNT, GRADE, ACTIVECA' +
        'RD, '
      'MULTYCURR, '
      
        '   OFFBALANCE, MAINANALYZE, DISABLED, AFULL, ACHAG, AVIEW, RESER' +
        'VED)'
      'values'
      '  (:ID, :PARENT, :LB, :RB, :ALIAS, :NAME, :TYPEACCOUNT, :GRADE, '
      ':ACTIVECARD, '
      
        '   :MULTYCURR, :OFFBALANCE, :MAINANALYZE, :DISABLED, :AFULL, :AC' +
        'HAG, '
      ':AVIEW, '
      '   :RESERVED)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_cardaccount '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_cardaccount g'
      'WHERE g.grade < 2'
      'ORDER BY'
      '  PARENT DESC')
    ModifySQL.Strings = (
      'update gd_cardaccount'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  LB = :LB,'
      '  RB = :RB,'
      '  ALIAS = :ALIAS,'
      '  NAME = :NAME,'
      '  TYPEACCOUNT = :TYPEACCOUNT,'
      '  GRADE = :GRADE,'
      '  ACTIVECARD = :ACTIVECARD,'
      '  MULTYCURR = :MULTYCURR,'
      '  OFFBALANCE = :OFFBALANCE,'
      '  MAINANALYZE = :MAINANALYZE,'
      '  DISABLED = :DISABLED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 316
    Top = 149
  end
  object ibdsAccount: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_cardaccount'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_cardaccount'
      
        '  (ID, PARENT, LB, RB, ALIAS, NAME, TYPEACCOUNT, GRADE, ACTIVECA' +
        'RD, '
      'MULTYCURR, '
      
        '   OFFBALANCE, MAINANALYZE, DISABLED, AFULL, ACHAG, AVIEW, RESER' +
        'VED)'
      'values'
      '  (:ID, :PARENT, :LB, :RB, :ALIAS, :NAME, :TYPEACCOUNT, :GRADE, '
      ':ACTIVECARD, '
      
        '   :MULTYCURR, :OFFBALANCE, :MAINANALYZE, :DISABLED, :AFULL, :AC' +
        'HAG, '
      ':AVIEW, '
      '   :RESERVED)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_cardaccount '
      'where'
      '  ID = :OLD_ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_cardaccount a'
      'WHERE '
      '  a.grade >= 2 and'
      '  a.LB > :LB and a.RB < :RB'
      'ORDER BY a.alias')
    ModifySQL.Strings = (
      'update gd_cardaccount'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  LB = :LB,'
      '  RB = :RB,'
      '  ALIAS = :ALIAS,'
      '  NAME = :NAME,'
      '  TYPEACCOUNT = :TYPEACCOUNT,'
      '  GRADE = :GRADE,'
      '  ACTIVECARD = :ACTIVECARD,'
      '  MULTYCURR = :MULTYCURR,'
      '  OFFBALANCE = :OFFBALANCE,'
      '  MAINANALYZE = :MAINANALYZE,'
      '  DISABLED = :DISABLED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 348
    Top = 149
  end
  object dsGroupAccount: TDataSource
    DataSet = ibdsGroupAccount
    Left = 316
    Top = 181
  end
  object dsAccount: TDataSource
    DataSet = ibdsAccount
    Left = 348
    Top = 181
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 316
    Top = 213
  end
  object ActionList1: TActionList
    Left = 444
    Top = 117
    object actNew: TAction
      Caption = 'Добавить...'
      ImageIndex = 0
      ShortCut = 45
      OnExecute = actNewExecute
    end
    object actEdit: TAction
      Caption = 'Изменить...'
      ImageIndex = 1
      ShortCut = 13
      OnExecute = actEditExecute
    end
    object actDel: TAction
      Caption = 'Удалить'
      ImageIndex = 2
      ShortCut = 46
      OnExecute = actDelExecute
    end
    object actPlanForFirm: TAction
      Caption = 'Установки...'
      OnExecute = actPlanForFirmExecute
    end
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 420
    Top = 165
  end
  object pOperation: TPopupMenu
    Left = 380
    Top = 221
    object N2: TMenuItem
      Action = actNew
    end
    object N3: TMenuItem
      Action = actEdit
    end
    object N4: TMenuItem
      Action = actDel
    end
  end
  object gsqfAccount: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsAccount
    Left = 380
    Top = 149
  end
  object pOperAccount: TPopupMenu
    Left = 380
    Top = 253
    object N7: TMenuItem
      Action = actNew
    end
    object N8: TMenuItem
      Action = actEdit
    end
    object N9: TMenuItem
      Action = actDel
    end
  end
  object ibsqlChangeGroupKey: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'UPDATE gd_cardaccount'
      'SET parent = :p'
      'WHERE '
      '  id = :id')
    Transaction = IBTransaction
    Left = 478
    Top = 178
  end
end
