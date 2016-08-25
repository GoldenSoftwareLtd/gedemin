object gdc_dlgShowMovement: Tgdc_dlgShowMovement
  Left = 239
  Top = 120
  Width = 702
  Height = 480
  Caption = 'Просмотр движений по измененной позиции'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 694
    Height = 114
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ibgrLine: TgsIBGrid
      Left = 0
      Top = 0
      Width = 694
      Height = 66
      TabStop = False
      Align = alClient
      DataSource = dsLine
      Enabled = False
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
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
      ColumnEditors = <>
      Aliases = <>
    end
    object Memo1: TMemo
      Left = 0
      Top = 66
      Width = 694
      Height = 48
      TabStop = False
      Align = alBottom
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Lines.Strings = (
        
          'По указанной позиции существует движение по указанным ниже докум' +
          'ентам.'
        
          'Произведенные изменения могут привести к некорректности докумен' +
          'тов или проводок по ним.'
        
          'Проверьте, пожалуйста, и примите решение о сохранении изменений (O' +
          'K) или их отмене (Отмена).'
        ' '
        ' ')
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 412
    Width = 694
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 602
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 0
    end
    object Button2: TButton
      Left = 520
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object Button3: TButton
      Left = 8
      Top = 8
      Width = 113
      Height = 25
      Action = Action1
      TabOrder = 2
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 114
    Width = 694
    Height = 298
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Splitter1: TSplitter
      Left = 0
      Top = 153
      Width = 694
      Height = 3
      Cursor = crVSplit
      Align = alTop
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 694
      Height = 153
      Align = alTop
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      Caption = 'Panel4'
      TabOrder = 0
      object Label1: TLabel
        Left = 5
        Top = 5
        Width = 684
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Документы'
      end
      object ibgrDocument: TgsIBGrid
        Left = 5
        Top = 18
        Width = 684
        Height = 130
        Align = alClient
        DataSource = dsDocument
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
        ColumnEditors = <>
        Aliases = <>
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 156
      Width = 694
      Height = 142
      Align = alClient
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      Caption = 'Panel5'
      TabOrder = 1
      object Label2: TLabel
        Left = 5
        Top = 5
        Width = 684
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Проводки'
      end
      object ibgrEntry: TgsIBGrid
        Left = 5
        Top = 18
        Width = 684
        Height = 119
        Align = alClient
        DataSource = dsEntry
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
        ColumnEditors = <>
        Aliases = <>
      end
    end
  end
  object dsLine: TDataSource
    Left = 112
    Top = 16
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 120
    Top = 163
  end
  object dsEntry: TDataSource
    DataSet = ibdsEntry
    Left = 136
    Top = 319
  end
  object ibdsDocument: TIBDataSet
    Transaction = ibtrCommon
    BufferChunks = 100
    SelectSQL.Strings = (
      'select doct.name, doc.number, doc.documentdate, doc1.printdate,'
      
        'SUM(m1.credit) as QUANTITY, doc1.id, doc.id as lineid from inv_m' +
        'ovement m'
      '  JOIN inv_movement m1 ON m.cardkey = m1.cardkey AND'
      '  m.contactkey = m1.contactkey AND'
      '  m.documentkey = :dockey AND'
      
        '  m.debit > 0 and m1.credit > 0 AND m.documentkey <> m1.document' +
        'key'
      '  JOIN gd_document doc ON m1.documentkey = doc.id'
      '  JOIN gd_documenttype doct ON doc.documenttypekey = doct.id'
      '  JOIN gd_document doc1 ON doc.parent = doc1.id'
      
        'GROUP BY doct.name, doc.number, doc.documentdate, doc1.printdate' +
        ', doc1.id, doc.id')
    ReadTransaction = ibtrCommon
    Left = 168
    Top = 163
  end
  object ibdsEntry: TIBDataSet
    Transaction = ibtrCommon
    BufferChunks = 100
    SelectSQL.Strings = (
      'select a.alias, e.debitncu, e.creditncu from'
      '  ac_record r'
      
        '  JOIN ac_entry e ON e.recordkey = r.id AND r.documentkey = :lin' +
        'eid'
      '  JOIN ac_account a ON e.accountkey = a.id')
    DataSource = dsDocument
    ReadTransaction = ibtrCommon
    Left = 176
    Top = 319
  end
  object ibtrCommon: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 228
    Top = 181
  end
  object ActionList1: TActionList
    Left = 328
    Top = 241
    object Action1: TAction
      Caption = 'Открыть документ'
      OnExecute = Action1Execute
    end
  end
end
