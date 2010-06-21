inherited gdv_frmAcctAccCard: Tgdv_frmAcctAccCard
  Left = 374
  Top = 70
  Width = 1042
  Height = 755
  HelpContext = 30
  Caption = 'Карта счета'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sLeft: TSplitter
    Height = 604
  end
  inherited TBDock1: TTBDock
    Width = 1034
    inherited tbMainToolbar: TTBToolbar
      object TBSeparatorItem5: TTBSeparatorItem [4]
      end
      object tbiEditDocument: TTBItem [5]
        Action = actEditDocument
      end
      object tbiEditDocumentLine: TTBItem [6]
        Action = actEditDocumentLine
      end
    end
    inherited TBToolbar2: TTBToolbar
      Left = 247
      DockPos = 184
    end
    inherited TBToolbar1: TTBToolbar
      Left = 527
      inherited pCofiguration: TPanel
        inherited iblConfiguratior: TgsIBLookupComboBox
          gdClassName = 'TgdcAcctAccConfig'
        end
      end
    end
  end
  inherited Panel1: TPanel
    Width = 765
    Height = 604
    TabOrder = 2
    inherited ibgrMain: TgsIBGrid
      Width = 765
      Height = 604
    end
  end
  inherited TBDock2: TTBDock
    Height = 604
  end
  inherited TBDock3: TTBDock
    Left = 1025
    Height = 604
  end
  inherited TBDock4: TTBDock
    Top = 634
    Width = 1034
  end
  inherited pLeft: TPanel
    Height = 604
    TabOrder = 1
    inherited ScrollBox: TScrollBox
      Height = 587
      inherited Panel5: TPanel
        Height = 81
        inherited bAccounts: TButton
          Left = 235
        end
        inherited cbAccounts: TComboBox
          Width = 190
        end
        object cbGroup: TCheckBox
          Left = 8
          Top = 64
          Width = 209
          Height = 17
          Caption = 'Группировать'
          TabOrder = 4
        end
      end
      inherited frAcctQuantity: TfrAcctQuantity
        Top = 202
      end
      inherited frAcctSum: TfrAcctSum
        Top = 243
      end
      inherited frAcctAnalytics: TfrAcctAnalytics
        Top = 161
      end
      inherited frAcctCompany: TfrAcctCompany
        Top = 464
        TabOrder = 5
        inherited ppMain: TgdvParamPanel
          inherited cbAllCompanies: TCheckBox
            Width = 205
          end
          inherited iblCompany: TgsIBLookupComboBox
            Left = 82
            Width = 135
          end
        end
        inherited Transaction: TIBTransaction
          Left = 104
          Top = 16
        end
      end
      inherited ppAppear: TgdvParamPanel
        Top = 524
        TabOrder = 4
      end
      object ppCorrAccount: TgdvParamPanel
        Left = 0
        Top = 81
        Width = 246
        Height = 80
        Align = alTop
        Caption = 'Корреспондентский счёт'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15692547
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = True
        ParentFont = False
        TabOrder = 6
        TabStop = True
        Unwraped = True
        HorisontalOffset = 5
        VerticalOffset = 1
        FillColor = 16316664
        StripeOdd = 14801601
        StripeEven = 16249840
        Origin = oLeft
        object Label3: TLabel
          Left = 14
          Top = 24
          Width = 59
          Height = 13
          Caption = 'Корр.счета:'
          FocusControl = cbCorrAccounts
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          Transparent = True
          Layout = tlCenter
        end
        object cbCorrAccounts: TComboBox
          Left = 76
          Top = 20
          Width = 140
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          TabOrder = 0
          OnChange = cbCorrAccountsChange
          OnExit = cbCorrAccountsExit
        end
        object btnCorrAccounts: TButton
          Left = 216
          Top = 20
          Width = 20
          Height = 20
          Anchors = [akTop, akRight]
          Caption = '...'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnCorrAccountsClick
        end
        object rbDebit: TRadioButton
          Left = 39
          Top = 44
          Width = 57
          Height = 17
          Caption = 'Дебет'
          Checked = True
          Color = 16316664
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 2
          TabStop = True
        end
        object rbCredit: TRadioButton
          Left = 127
          Top = 44
          Width = 57
          Height = 17
          Caption = 'Кредит'
          Color = 16316664
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 3
        end
        object cbShowCorrSubAccounts: TCheckBox
          Left = 16
          Top = 59
          Width = 121
          Height = 17
          Caption = 'Включать субсчета'
          Color = 16316664
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 4
          OnClick = cbShowCorrSubAccountsClick
        end
      end
    end
    inherited Panel2: TPanel
      inherited sbCloseParamPanel: TSpeedButton
        Left = 224
        Top = 2
      end
    end
  end
  object Panel3: TPanel [7]
    Left = 0
    Top = 643
    Width = 1034
    Height = 81
    Align = alBottom
    BevelOuter = bvNone
    Color = 15329769
    TabOrder = 6
    object Bevel2: TBevel
      Left = 0
      Top = 0
      Width = 1034
      Height = 4
      Align = alTop
      Shape = bsBottomLine
      Visible = False
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 4
      Width = 268
      Height = 37
      Caption = 'Сальдо на начало в НДЕ'
      TabOrder = 0
      object Label7: TLabel
        Left = 6
        Top = 16
        Width = 32
        Height = 13
        Caption = 'Дебет'
      end
      object Label9: TLabel
        Left = 133
        Top = 16
        Width = 38
        Height = 13
        Caption = 'Кредит'
      end
      object edBeginSaldoDebit: TEdit
        Left = 40
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 0
      end
      object edBeginSaldoCredit: TEdit
        Left = 172
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 1
      end
    end
    object GroupBox2: TGroupBox
      Left = 0
      Top = 41
      Width = 268
      Height = 37
      Caption = 'Сальдо на  конец в НДЕ'
      TabOrder = 1
      object Label6: TLabel
        Left = 6
        Top = 16
        Width = 32
        Height = 13
        Caption = 'Дебет'
      end
      object Label18: TLabel
        Left = 134
        Top = 16
        Width = 38
        Height = 13
        Caption = 'Кредит'
      end
      object edEndSaldoCredit: TEdit
        Left = 172
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 0
      end
      object edEndSaldoDebit: TEdit
        Left = 40
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 1
      end
    end
    object GroupBox3: TGroupBox
      Left = 272
      Top = 4
      Width = 268
      Height = 37
      Caption = 'Сальдо на начало в валюте'
      TabOrder = 2
      object Label5: TLabel
        Left = 6
        Top = 16
        Width = 32
        Height = 13
        Caption = 'Дебет'
      end
      object Label8: TLabel
        Left = 133
        Top = 16
        Width = 38
        Height = 13
        Caption = 'Кредит'
      end
      object edBeginSaldoDebitCurr: TEdit
        Left = 41
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 0
      end
      object edBeginSaldoCreditCurr: TEdit
        Left = 172
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 1
      end
    end
    object GroupBox4: TGroupBox
      Left = 272
      Top = 41
      Width = 268
      Height = 37
      Caption = 'Сальдо на  конец в валюте'
      TabOrder = 3
      object Label10: TLabel
        Left = 6
        Top = 16
        Width = 32
        Height = 13
        Caption = 'Дебет'
      end
      object Label19: TLabel
        Left = 134
        Top = 16
        Width = 38
        Height = 13
        Caption = 'Кредит'
      end
      object edEndSaldoDebitCurr: TEdit
        Left = 39
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 0
      end
      object edEndSaldoCreditCurr: TEdit
        Left = 172
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 1
      end
    end
    object GroupBox5: TGroupBox
      Left = 544
      Top = 4
      Width = 268
      Height = 37
      Caption = 'Сальдо на начало в эквиваленте'
      TabOrder = 4
      object Label4: TLabel
        Left = 6
        Top = 16
        Width = 32
        Height = 13
        Caption = 'Дебет'
      end
      object Label11: TLabel
        Left = 133
        Top = 16
        Width = 38
        Height = 13
        Caption = 'Кредит'
      end
      object edBeginSaldoDebitEQ: TEdit
        Left = 41
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 0
      end
      object edBeginSaldoCreditEQ: TEdit
        Left = 172
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 1
      end
    end
    object GroupBox6: TGroupBox
      Left = 544
      Top = 41
      Width = 268
      Height = 37
      Caption = 'Сальдо на  конец в эквиваленте'
      TabOrder = 5
      object Label12: TLabel
        Left = 6
        Top = 16
        Width = 32
        Height = 13
        Caption = 'Дебет'
      end
      object Label13: TLabel
        Left = 134
        Top = 16
        Width = 38
        Height = 13
        Caption = 'Кредит'
      end
      object edEndSaldoDebitEQ: TEdit
        Left = 39
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 0
      end
      object edEndSaldoCreditEQ: TEdit
        Left = 172
        Top = 14
        Width = 90
        Height = 17
        TabStop = False
        AutoSize = False
        BiDiMode = bdLeftToRight
        Color = 15329769
        ParentBiDiMode = False
        ReadOnly = True
        TabOrder = 1
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = ibdsMain
  end
  inherited alMain: TActionList
    inherited actGoto: TAction
      Caption = 'Перейти в журнал хозяйственных операций'
      Hint = 'Перейти в журнал хозяйственных операций'
    end
    object actEditDocument: TAction
      Caption = 'Изменить документ'
      Hint = 'Изменить документ'
      ImageIndex = 1
      ShortCut = 16453
      OnExecute = actEditDocumentExecute
      OnUpdate = actEditDocumentUpdate
    end
    object actEditDocumentLine: TAction
      Caption = 'Изменить позицию документа'
      Hint = 'Изменить позицию документа'
      ImageIndex = 121
      ShortCut = 16460
      OnExecute = actEditDocumentLineExecute
    end
  end
  inherited ppMain: TPopupMenu
    object nEditDocument: TMenuItem
      Action = actEditDocument
    end
    object nEditDocumentLine: TMenuItem
      Action = actEditDocumentLine
    end
  end
  object ibdsMain: TgdvAcctAccCard
    CachedUpdates = True
    InsertSQL.Strings = (
      'INSERT INTO AC_LEDGER_ACCOUNTS (ACCOUNTKEY) VALUES (-1)')
    ModifySQL.Strings = (
      'UPDATE AC_LEDGER_ACCOUNTS SET ACCOUNTKEY = -1')
    Left = 604
    Top = 206
  end
end
