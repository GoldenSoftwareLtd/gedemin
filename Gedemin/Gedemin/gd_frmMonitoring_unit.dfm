object gd_frmMonitoring: Tgd_frmMonitoring
  Left = 403
  Top = 128
  Width = 841
  Height = 549
  Caption = 'Монитор подлючений'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 833
    Height = 522
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 200
      Width = 833
      Height = 4
      Cursor = crVSplit
      Align = alTop
    end
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 833
      Height = 200
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object pnlMenu: TPanel
        Left = 0
        Top = 0
        Width = 833
        Height = 38
        Align = alTop
        TabOrder = 0
        object cbxHideCurrentConnection: TCheckBox
          Left = 120
          Top = 10
          Width = 217
          Height = 17
          Caption = 'Не показывать текущее соединение'
          TabOrder = 0
        end
        object btnRefresh: TButton
          Left = 23
          Top = 6
          Width = 75
          Height = 25
          Caption = 'Обновить'
          TabOrder = 1
          OnClick = btnRefreshClick
        end
      end
      object ibgrAttachments: TgsIBGrid
        Left = 0
        Top = 38
        Width = 833
        Height = 162
        Align = alClient
        DataSource = dsAttachments
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 1
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
    object pnlBottom: TPanel
      Left = 0
      Top = 204
      Width = 833
      Height = 318
      Align = alClient
      TabOrder = 1
      object SuperPageControl1: TSuperPageControl
        Left = 1
        Top = 1
        Width = 831
        Height = 316
        BorderStyle = bsNone
        TabsVisible = True
        ActivePage = SuperTabSheet1
        Align = alClient
        TabHeight = 23
        TabOrder = 0
        object SuperTabSheet1: TSuperTabSheet
          Caption = 'Активные транзакции клиентов'
          object Splitter2: TSplitter
            Left = 417
            Top = 0
            Width = 4
            Height = 293
            Cursor = crHSplit
          end
          object Panel1: TPanel
            Left = 0
            Top = 0
            Width = 417
            Height = 293
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 0
            object ibrgTransactions: TgsIBGrid
              Left = 0
              Top = 0
              Width = 417
              Height = 293
              Align = alClient
              DataSource = dsTransactions
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
          end
          object Panel2: TPanel
            Left = 421
            Top = 0
            Width = 410
            Height = 293
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
            object Panel3: TPanel
              Left = 0
              Top = 0
              Width = 410
              Height = 36
              Align = alTop
              TabOrder = 0
              object btnKillStatement: TButton
                Left = 14
                Top = 5
                Width = 129
                Height = 25
                Caption = 'Убить запрос'
                TabOrder = 0
                OnClick = btnKillStatementClick
              end
            end
            object ibgrTransactionsStatements: TgsIBGrid
              Left = 0
              Top = 36
              Width = 257
              Height = 257
              Align = alLeft
              DataSource = dsTransactionsStatements
              Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
              ReadOnly = True
              TabOrder = 1
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
            object DBMemo1: TDBMemo
              Left = 257
              Top = 36
              Width = 153
              Height = 257
              Align = alClient
              DataField = 'MON$SQL_TEXT'
              DataSource = dsTransactionsStatements
              ReadOnly = True
              ScrollBars = ssVertical
              TabOrder = 2
            end
          end
        end
        object SuperTabSheet2: TSuperTabSheet
          Caption = 'Активные запросы ранних клиентов'
          object ibgrStatements: TgsIBGrid
            Left = 0
            Top = 0
            Width = 441
            Height = 293
            Align = alLeft
            DataSource = dsStatements
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
          object DBMemo2: TDBMemo
            Left = 441
            Top = 0
            Width = 390
            Height = 293
            Align = alClient
            DataField = 'MON$SQL_TEXT'
            DataSource = dsStatements
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 1
          end
        end
      end
    end
  end
  object dsAttachments: TDataSource
    DataSet = ibdsAttachments
    Left = 336
    Top = 120
  end
  object ibdsAttachments: TIBDataSet
    Transaction = trAttachments
    AfterScroll = ibdsAttachmentsAfterScroll
    BeforeClose = ibdsAttachmentsBeforeClose
    ReadTransaction = trAttachments
    Left = 264
    Top = 120
  end
  object trAttachments: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 216
    Top = 120
  end
  object dsTransactions: TDataSource
    DataSet = ibdsTransactions
    Left = 33
    Top = 436
  end
  object ibdsTransactions: TIBDataSet
    Transaction = trAttachments
    AfterScroll = ibdsTransactionsAfterScroll
    BeforeClose = ibdsTransactionsBeforeClose
    ReadTransaction = trAttachments
    Left = 65
    Top = 436
  end
  object ibdsTransactionsStatements: TIBDataSet
    Transaction = trAttachments
    ReadTransaction = trAttachments
    Left = 470
    Top = 436
  end
  object dsTransactionsStatements: TDataSource
    DataSet = ibdsTransactionsStatements
    Left = 504
    Top = 436
  end
  object dsStatements: TDataSource
    DataSet = ibdsStatements
    Left = 249
    Top = 444
  end
  object ibdsStatements: TIBDataSet
    Transaction = trAttachments
    ReadTransaction = trAttachments
    Left = 280
    Top = 444
  end
end
