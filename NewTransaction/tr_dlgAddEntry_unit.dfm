object dlgAddEntry: TdlgAddEntry
  Left = 240
  Top = 101
  ActiveControl = tvAccount
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Типовая проводка'
  ClientHeight = 208
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bOk: TButton
    Left = 476
    Top = 38
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object bNext: TButton
    Left = 476
    Top = 67
    Width = 75
    Height = 25
    Action = actNext
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 476
    Top = 97
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    ModalResult = 2
    TabOrder = 2
  end
  object tvAccount: TTreeView
    Left = 8
    Top = 39
    Width = 137
    Height = 156
    HideSelection = False
    Indent = 19
    TabOrder = 3
    OnChange = tvAccountChange
    Items.Data = {
      020000001E0000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      05C4E5E1E5F21F0000000000000000000000FFFFFFFFFFFFFFFF000000000000
      000006CAF0E5E4E8F2}
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 560
    Height = 29
    ButtonHeight = 21
    ButtonWidth = 105
    Caption = 'ToolBar1'
    ShowCaptions = True
    TabOrder = 4
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = actChooseAccount
    end
    object ToolButton3: TToolButton
      Left = 105
      Top = 2
      Action = actChooseAnalytical
    end
    object ToolButton2: TToolButton
      Left = 210
      Top = 2
      Action = actDel
    end
  end
  object nExpression: TNotebook
    Left = 150
    Top = 40
    Width = 323
    Height = 155
    PageIndex = 1
    TabOrder = 5
    object TPage
      Left = 0
      Top = 0
      Caption = '0'
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 323
        Height = 155
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Выберите или добавьте счет '
        TabOrder = 0
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '1'
      object Label1: TLabel
        Left = 2
        Top = 3
        Width = 122
        Height = 13
        Caption = 'Формула суммы в НДЕ'
      end
      object Label2: TLabel
        Left = 2
        Top = 43
        Width = 119
        Height = 13
        Caption = 'Формула суммы в вал.'
      end
      object Label3: TLabel
        Left = 2
        Top = 83
        Width = 119
        Height = 13
        Caption = 'Формула суммы в экв.'
      end
      object SpeedButton1: TSpeedButton
        Left = 291
        Top = 18
        Width = 23
        Height = 22
        OnClick = SpeedButton1Click
      end
      object SpeedButton2: TSpeedButton
        Left = 291
        Top = 58
        Width = 23
        Height = 22
        OnClick = SpeedButton2Click
      end
      object SpeedButton3: TSpeedButton
        Left = 291
        Top = 98
        Width = 23
        Height = 22
        OnClick = SpeedButton3Click
      end
      object dbedExpressionNCU: TDBEdit
        Left = 2
        Top = 19
        Width = 288
        Height = 21
        DataField = 'EXPRESSIONNCU'
        DataSource = dsDebitEntry
        TabOrder = 0
      end
      object dbedExpressionCURR: TDBEdit
        Left = 2
        Top = 59
        Width = 288
        Height = 21
        DataField = 'EXPRESSIONCURR'
        DataSource = dsDebitEntry
        TabOrder = 1
      end
      object dbedExpressionEq: TDBEdit
        Left = 2
        Top = 99
        Width = 288
        Height = 21
        DataField = 'EXPRESSIONEQ'
        DataSource = dsDebitEntry
        TabOrder = 2
      end
    end
  end
  object ActionList1: TActionList
    Left = 521
    Top = 139
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actNext: TAction
      Caption = 'Следующая'
      OnExecute = actNextExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actChooseAccount: TAction
      Caption = 'Выбор счета...'
      OnExecute = actChooseAccountExecute
    end
    object actChooseAnalytical: TAction
      Caption = 'Выбор аналитики...'
    end
    object actDel: TAction
      Caption = 'Удалить '
      OnExecute = actDelExecute
    end
  end
  object ibdsEntry: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_ENTRY'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_ENTRY'
      '  (ID, ENTRYKEY, TRTYPEKEY, ACCOUNTKEY, EXPRESSIONNCU, '
      'EXPRESSIONCURR, EXPRESSIONEQ, ACCOUNTTYPE)'
      'values'
      '  (:ID, :ENTRYKEY, :TRTYPEKEY, :ACCOUNTKEY, :EXPRESSIONNCU,'
      ':EXPRESSIONCURR, :EXPRESSIONEQ, :ACCOUNTTYPE)'
      ' ')
    RefreshSQL.Strings = (
      'Select'
      '  ID,'
      '  ENTRYKEY,'
      '  TRTYPEKEY,'
      '  ACCOUNTKEY,'
      '  EXPRESSIONNCU,'
      '  EXPRESSIONCURR,'
      '  EXPRESSIONEQ,'
      '  ACCOUNTTYPE'
      'from GD_ENTRY'
      'where'
      '  ID = :ID'
      ' ')
    SelectSQL.Strings = (
      'select E.*, C.ALIAS from GD_ENTRY E JOIN GD_CARDACCOUNT C'
      'ON E.accountkey = C.id'
      'where '
      '  (EntryKey = :EK)'
      'ORDER BY '
      '   E.accounttype'
      '')
    ModifySQL.Strings = (
      'update GD_ENTRY'
      'set'
      '  ID = :ID,'
      '  ENTRYKEY = :ENTRYKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  ACCOUNTKEY = :ACCOUNTKEY,'
      '  EXPRESSIONNCU = :EXPRESSIONNCU,'
      '  EXPRESSIONCURR = :EXPRESSIONCURR,'
      '  EXPRESSIONEQ = :EXPRESSIONEQ,'
      '  ACCOUNTTYPE = :ACCOUNTTYPE'
      'where'
      '  ID = :OLD_ID'
      ' ')
    Left = 80
    Top = 151
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 112
    Top = 151
  end
  object ibdsEntryLine: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_ENTRY'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_ENTRY'
      '  (ID, ENTRYKEY, TRTYPEKEY, ACCOUNTKEY, EXPRESSIONNCU, '
      'EXPRESSIONCURR, EXPRESSIONEQ,  ACCOUNTTYPE)'
      'values'
      '  (:ID, :ENTRYKEY, :TRTYPEKEY, :ACCOUNTKEY, :EXPRESSIONNCU, '
      ':EXPRESSIONCURR,  :EXPRESSIONEQ, :ACCOUNTTYPE)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  ENTRYKEY,'
      '  TRTYPEKEY,'
      '  ACCOUNTKEY,'
      '  EXPRESSIONNCU,'
      '  EXPRESSIONCURR,'
      '  EXPRESSIONEQ,'
      '  ACCOUNTTYPE'
      'from GD_ENTRY '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM GD_ENTRY'
      'WHERE ID = :ID')
    ModifySQL.Strings = (
      'update GD_ENTRY'
      'set'
      '  ID = :ID,'
      '  ENTRYKEY = :ENTRYKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  ACCOUNTKEY = :ACCOUNTKEY,'
      '  EXPRESSIONNCU = :EXPRESSIONNCU,'
      '  EXPRESSIONCURR = :EXPRESSIONCURR,'
      '  EXPRESSIONEQ = :EXPRESSIONEQ,'
      '  ACCOUNTTYPE = :ACCOUNTTYPE'
      'where'
      '  ID = :OLD_ID')
    Left = 48
    Top = 151
  end
  object dsDebitEntry: TDataSource
    DataSet = ibdsEntryLine
    Left = 16
    Top = 151
  end
end
