inherited gdv_frmAcctAccReview: Tgdv_frmAcctAccReview
  Left = 112
  Top = 168
  Width = 938
  Height = 726
  Caption = 'Анализ счета'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sLeft: TSplitter
    Height = 575
  end
  inherited TBDock1: TTBDock
    Width = 930
    inherited TBToolbar1: TTBToolbar
      inherited pCofiguration: TPanel
        inherited iblConfiguratior: TgsIBLookupComboBox
          gdClassName = 'TgdcAcctAccReviewConfig'
        end
      end
    end
  end
  inherited Panel1: TPanel
    Width = 660
    Height = 575
    inherited ibgrMain: TgsIBGrid
      Width = 660
      Height = 575
    end
  end
  inherited TBDock2: TTBDock
    Height = 575
  end
  inherited TBDock3: TTBDock
    Left = 921
    Height = 575
  end
  inherited TBDock4: TTBDock
    Top = 605
    Width = 930
  end
  inherited pLeft: TPanel
    Height = 575
    inherited ScrollBox: TScrollBox
      Height = 558
      inherited Panel5: TPanel
        Height = 65
        inherited bAccounts: TButton
          Left = 218
        end
        inherited cbAccounts: TComboBox
          Width = 173
        end
      end
      inherited frAcctQuantity: TfrAcctQuantity
        Top = 186
      end
      inherited frAcctSum: TfrAcctSum
        Top = 227
      end
      inherited frAcctAnalytics: TfrAcctAnalytics
        Top = 145
      end
      inherited frAcctCompany: TfrAcctCompany
        Top = 448
        inherited ppMain: TgdvParamPanel
          inherited cbAllCompanies: TCheckBox
            Width = 188
          end
          inherited iblCompany: TgsIBLookupComboBox
            Width = 152
          end
        end
      end
      inherited ppAppear: TgdvParamPanel
        Top = 508
        Visible = False
      end
      object ppCorrAccount: TgdvParamPanel
        Left = 0
        Top = 65
        Width = 246
        Height = 80
        Align = alTop
        Caption = 'Корреспондентский счёт'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15692547
        Font.Height = -11
        Font.Name = 'Tahoma'
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
          Font.Name = 'Tahoma'
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
          Font.Name = 'Tahoma'
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
          Font.Name = 'Tahoma'
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
          Font.Name = 'Tahoma'
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
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 4
          OnClick = cbShowCorrSubAccountsClick
        end
      end
    end
  end
  object Panel3: TPanel [7]
    Left = 0
    Top = 614
    Width = 930
    Height = 81
    Align = alBottom
    BevelOuter = bvNone
    Color = 15329769
    TabOrder = 6
    object Bevel2: TBevel
      Left = 0
      Top = 0
      Width = 930
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
    inherited actRun: TAction
      OnUpdate = actRunUpdate
    end
    inherited actGoto: TAction
      Caption = 'Перейти на карту счета'
      Hint = 'Перейти на карту счета'
      ImageIndex = 220
    end
  end
  inherited AccountDelayTimer: TTimer
    Left = 296
    Top = 48
  end
  object ibdsMain: TgdvAcctAccReview
    CachedUpdates = True
    InsertSQL.Strings = (
      'INSERT INTO AC_LEDGER_ACCOUNTS (ACCOUNTKEY) VALUES (-1)')
    ModifySQL.Strings = (
      'UPDATE AC_LEDGER_ACCOUNTS SET ACCOUNTKEY = -1')
    Left = 604
    Top = 182
  end
end
