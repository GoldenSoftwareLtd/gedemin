object dlgAddTypeEntry: TdlgAddTypeEntry
  Left = 216
  Top = 125
  ActiveControl = gsibgrEntry
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Типовая проводка'
  ClientHeight = 341
  ClientWidth = 586
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
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 163
    Width = 54
    Height = 13
    Caption = 'Аналитика'
  end
  object gsibgrEntry: TgsIBCtrlGrid
    Left = 8
    Top = 8
    Width = 473
    Height = 153
    DataSource = dsEntry
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
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
    OnSetCtrl = gsibgrEntrySetCtrl
  end
  object ScrollBox1: TScrollBox
    Left = 8
    Top = 179
    Width = 473
    Height = 152
    TabOrder = 3
  end
  object bOk: TButton
    Left = 493
    Top = 8
    Width = 84
    Height = 25
    Action = actOk
    Default = True
    TabOrder = 4
  end
  object bNext: TButton
    Left = 493
    Top = 38
    Width = 84
    Height = 25
    Action = actNext
    TabOrder = 5
  end
  object bVariable: TButton
    Left = 493
    Top = 136
    Width = 84
    Height = 25
    Action = actVariable
    TabOrder = 6
  end
  object gsiblcAccount: TgsIBLookupComboBox
    Left = 104
    Top = 16
    Width = 145
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DataSource = dsEntry
    DataField = 'ACCOUNTKEY'
    ListTable = 'GD_CARDACCOUNT'
    ListField = 'ALIAS'
    KeyField = 'ID'
    SortOrder = soAsc
    CheckUserRights = False
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    Visible = False
    OnExit = gsiblcAccountExit
  end
  object dbcbAccountType: TDBComboBox
    Left = 104
    Top = 48
    Width = 145
    Height = 21
    Style = csDropDownList
    DataField = 'ACCOUNTTYPE'
    DataSource = dsEntry
    ItemHeight = 13
    Items.Strings = (
      'Дебет'
      'Кредит')
    TabOrder = 2
    Visible = False
    OnExit = dbcbAccountTypeExit
  end
  object bCancel: TButton
    Left = 493
    Top = 67
    Width = 84
    Height = 25
    Action = actCancel
    Cancel = True
    TabOrder = 7
  end
  object bRelation: TButton
    Left = 493
    Top = 107
    Width = 84
    Height = 25
    Action = actAnalyzeRelation
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
  end
  object ibdsEntry: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    AfterInsert = ibdsEntryAfterInsert
    BeforeInsert = ibdsEntryBeforeInsert
    BeforePost = ibdsEntryBeforePost
    BufferChunks = 1000
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from gd_entry'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_entry'
      '  (ID, ENTRYKEY, TRTYPEKEY, ACCOUNTKEY, ACCOUNTTYPE, '
      'EXPRESSIONNCU, EXPRESSIONCURR, '
      '   EXPRESSIONEQ)'
      'values'
      '  (:ID, :ENTRYKEY, :TRTYPEKEY, :ACCOUNTKEY, :ACCOUNTTYPE, '
      ':EXPRESSIONNCU, '
      '   :EXPRESSIONCURR, :EXPRESSIONEQ)')
    RefreshSQL.Strings = (
      'SELECT e.*, c.Alias FROM gd_entry e JOIN gd_cardaccount c '
      '  ON e.accountkey = c.id'
      'where'
      '  e.ID = :ID')
    SelectSQL.Strings = (
      'SELECT e.*, c.Alias FROM gd_entry e JOIN gd_cardaccount c '
      '  ON e.accountkey = c.id'
      'WHERE entrykey = :ek'
      'ORDER BY e.accounttype')
    ModifySQL.Strings = (
      'update gd_entry'
      'set'
      '  ID = :ID,'
      '  ENTRYKEY = :ENTRYKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  ACCOUNTKEY = :ACCOUNTKEY,'
      '  ACCOUNTTYPE = :ACCOUNTTYPE,'
      '  EXPRESSIONNCU = :EXPRESSIONNCU,'
      '  EXPRESSIONCURR = :EXPRESSIONCURR,'
      '  EXPRESSIONEQ = :EXPRESSIONEQ'
      'where'
      '  ID = :OLD_ID')
    Left = 195
    Top = 155
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 224
    Top = 155
  end
  object dsEntry: TDataSource
    DataSet = ibdsEntry
    Left = 168
    Top = 155
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <
      item
        Link = gsibgrEntry
        RelationName = 'GD_CARDACCOUNT'
        IgnoryType = itFull
      end>
    Left = 264
    Top = 155
  end
  object atEditor: TatEditor
    DataSource = dsEntry
    Site = ScrollBox1
    ControlPlacement = cpHorzThenVert
    LabelPlacement = lpVert
    Left = 296
    Top = 155
  end
  object ActionList1: TActionList
    Left = 448
    Top = 187
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actVariable: TAction
      Caption = 'Переменная...'
      ShortCut = 32839
      OnExecute = actVariableExecute
      OnUpdate = actVariableUpdate
    end
    object actNext: TAction
      Caption = 'Следующая'
      ShortCut = 45
      OnExecute = actNextExecute
    end
    object actAnalyzeRelation: TAction
      Caption = 'Связь...'
      OnExecute = actAnalyzeRelationExecute
    end
  end
end
