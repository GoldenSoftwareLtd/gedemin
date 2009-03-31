object dlgEntrys: TdlgEntrys
  Left = 242
  Top = 126
  Width = 675
  Height = 397
  Caption = 'Хозяйственная операция'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 127
    Height = 13
    Caption = 'Наименование операции'
  end
  object gsiblcTrType: TgsIBLookupComboBox
    Left = 152
    Top = 12
    Width = 412
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    ListTable = 'GD_V_TRTYPE_DOCUMENT'
    ListField = 'TRTYPE_NAME'
    KeyField = 'TRTYPE_KEY'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnChange = gsiblcTrTypeChange
  end
  object gbEntry: TGroupBox
    Left = 15
    Top = 39
    Width = 549
    Height = 318
    Caption = 'Проводка'
    Enabled = False
    TabOrder = 1
    object pUserInfo: TPanel
      Left = 2
      Top = 15
      Width = 545
      Height = 54
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label3: TLabel
        Left = 16
        Top = 6
        Width = 91
        Height = 13
        Caption = 'Номер документа'
      end
      object Label4: TLabel
        Left = 286
        Top = 6
        Width = 83
        Height = 13
        Caption = 'Дата документа'
      end
      object Label5: TLabel
        Left = 16
        Top = 30
        Width = 50
        Height = 13
        Caption = 'Описание'
      end
      object edNumberDoc: TEdit
        Left = 114
        Top = 2
        Width = 167
        Height = 21
        TabOrder = 0
      end
      object dtpDate: TDateTimePicker
        Left = 384
        Top = 2
        Width = 140
        Height = 21
        CalAlignment = dtaLeft
        Date = 36877.765828831
        Time = 36877.765828831
        DateFormat = dfShort
        DateMode = dmComboBox
        Kind = dtkDate
        ParseInput = False
        TabOrder = 1
      end
      object edDescription: TEdit
        Left = 114
        Top = 26
        Width = 409
        Height = 21
        TabOrder = 2
      end
    end
    object Panel2: TPanel
      Left = 2
      Top = 225
      Width = 545
      Height = 91
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object Label6: TLabel
        Left = 205
        Top = 21
        Width = 66
        Height = 13
        Caption = 'Итого в НДЕ'
      end
      object Label7: TLabel
        Left = 205
        Top = 41
        Width = 79
        Height = 13
        Caption = 'Итого в валюте'
      end
      object Label8: TLabel
        Left = 327
        Top = 1
        Width = 32
        Height = 13
        Caption = 'Дебет'
      end
      object Label9: TLabel
        Left = 449
        Top = 1
        Width = 36
        Height = 13
        Caption = 'Кредит'
      end
      object bNext: TButton
        Left = 368
        Top = 61
        Width = 75
        Height = 25
        Action = actNext
        TabOrder = 0
      end
      object bPrev: TButton
        Left = 448
        Top = 61
        Width = 75
        Height = 25
        Action = actPrev
        TabOrder = 1
      end
      object Button3: TButton
        Left = 8
        Top = 61
        Width = 75
        Height = 25
        Caption = 'Добавить'
        Enabled = False
        TabOrder = 2
        Visible = False
      end
      object Button4: TButton
        Left = 88
        Top = 61
        Width = 75
        Height = 25
        Caption = 'Удалить'
        Enabled = False
        TabOrder = 3
        Visible = False
      end
      object stDebitNCU: TStaticText
        Left = 290
        Top = 17
        Width = 113
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 4
      end
      object stDebitCurr: TStaticText
        Left = 290
        Top = 38
        Width = 113
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 5
      end
      object stCreditCurr: TStaticText
        Left = 410
        Top = 38
        Width = 113
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 6
      end
      object stCreditNCU: TStaticText
        Left = 410
        Top = 17
        Width = 113
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 7
      end
    end
    object Panel3: TPanel
      Left = 2
      Top = 69
      Width = 545
      Height = 156
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel3'
      TabOrder = 2
      object Label2: TLabel
        Left = 15
        Top = 0
        Width = 76
        Height = 13
        Caption = 'Счета и суммы'
      end
      object gsdbgrEntry: TgsDBGrid
        Left = 14
        Top = 16
        Width = 510
        Height = 138
        DataSource = dsEntrys
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
        ScrollBars = ssHorizontal
        TabOrder = 0
        OnKeyDown = gsdbgrEntryKeyDown
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        MinColWidth = 40
        SaveSettings = True
      end
    end
  end
  object bOk: TButton
    Left = 576
    Top = 12
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 576
    Top = 40
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
  object cdsEntry: TClientDataSet
    Aggregates = <>
    Params = <>
    AfterPost = cdsEntryAfterPost
    AfterDelete = cdsEntryAfterDelete
    Left = 160
    Top = 165
    object cdsEntryDebit: TStringField
      DisplayLabel = 'Дебет'
      DisplayWidth = 8
      FieldName = 'Debit'
      OnChange = cdsEntryDebitChange
    end
    object cdsEntryDebitSumNCU: TCurrencyField
      DisplayLabel = 'Сумма в НДЕ '
      DisplayWidth = 14
      FieldName = 'DebitSumNCU'
    end
    object cdsEntryDebitSumCurr: TCurrencyField
      DisplayLabel = 'Сумма в вал.'
      DisplayWidth = 13
      FieldName = 'DebitSumCurr'
      Visible = False
    end
    object cdsEntryDebitSumEq: TCurrencyField
      DisplayLabel = 'Сумма в экв.'
      DisplayWidth = 12
      FieldName = 'DebitSumEq'
      Visible = False
    end
    object cdsEntryCredit: TStringField
      DisplayLabel = 'Кредит'
      DisplayWidth = 8
      FieldName = 'Credit'
      LookupKeyFields = 'ID'
      OnChange = cdsEntryCreditChange
    end
    object cdsEntryCreditSumNCU: TCurrencyField
      DisplayLabel = 'Сумма в НДЕ'
      DisplayWidth = 14
      FieldName = 'CreditSumNCU'
    end
    object cdsEntryCreditSumCurr: TCurrencyField
      DisplayLabel = 'Сумма в вал.'
      DisplayWidth = 14
      FieldName = 'CreditSumCurr'
      Visible = False
    end
    object cdsEntryCreditSumEq: TCurrencyField
      DisplayLabel = 'Сумма в экв.'
      DisplayWidth = 12
      FieldName = 'CreditSumEq'
      Visible = False
    end
    object cdsEntryCurrName: TStringField
      DisplayLabel = 'Валюта'
      FieldKind = fkLookup
      FieldName = 'CurrName'
      LookupDataSet = ibdsCurr
      LookupKeyFields = 'ID'
      LookupResultField = 'SHORTNAME'
      KeyFields = 'CurrKey'
      Visible = False
      Size = 10
      Lookup = True
    end
    object cdsEntryDebitKey: TIntegerField
      FieldName = 'DebitKey'
      Visible = False
    end
    object cdsEntryCreditKey: TIntegerField
      FieldName = 'CreditKey'
      Visible = False
    end
    object cdsEntryCurrKey: TIntegerField
      FieldName = 'CurrKey'
      Visible = False
    end
    object cdsEntryEntryKey: TIntegerField
      FieldName = 'EntryKey'
      Visible = False
    end
  end
  object dsEntrys: TDataSource
    DataSet = cdsEntry
    OnDataChange = dsEntrysDataChange
    Left = 192
    Top = 165
  end
  object ibdsAccount: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM GD_CARDACCOUNT'
      'WHERE GRADE >= 2'
      'ORDER BY ALIAS')
    Left = 160
    Top = 205
  end
  object ibsql: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT * FROM GD_CARDACCOUNT '
      'WHERE Alias = :Alias')
    Left = 248
    Top = 165
  end
  object ActionList1: TActionList
    Left = 72
    Top = 189
    object actNext: TAction
      Caption = 'Следующая'
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actPrev: TAction
      Caption = 'Предыдущая'
      OnExecute = actPrevExecute
      OnUpdate = actPrevUpdate
    end
  end
  object ibdsCurr: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM GD_CURR ORDER BY SHORTNAME')
    Left = 192
    Top = 205
  end
end
