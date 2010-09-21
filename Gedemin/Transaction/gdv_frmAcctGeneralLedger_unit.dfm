inherited gdv_frmGeneralLedger: Tgdv_frmGeneralLedger
  Left = 251
  Top = 105
  Width = 1066
  Height = 652
  HelpContext = 351
  Caption = 'Главная книга'
  DefaultMonitor = dmDesktop
  PixelsPerInch = 96
  TextHeight = 13
  inherited sLeft: TSplitter
    Left = 273
    Height = 575
  end
  inherited TBDock1: TTBDock
    Width = 1050
    inherited tbMainToolbar: TTBToolbar
      DockPos = -5
    end
    inherited TBToolbar2: TTBToolbar
      DockPos = 0
      inherited Panel4: TPanel
        Width = 271
        inherited Label1: TLabel
          Left = 3
        end
        inherited Label2: TLabel
          Left = 115
        end
        inherited xdeStart: TxDateEdit
          Left = 46
        end
      end
    end
    inherited TBToolbar1: TTBToolbar
      Left = 476
      inherited pCofiguration: TPanel
        inherited iblConfiguratior: TgsIBLookupComboBox
          gdClassName = 'TgdcAcctGeneralLedgerConfig'
        end
      end
    end
  end
  inherited Panel1: TPanel
    Left = 278
    Width = 763
    Height = 575
    TabOrder = 2
    inherited ibgrMain: TgsIBGrid
      Width = 763
      Height = 575
    end
  end
  inherited TBDock2: TTBDock
    Height = 575
  end
  inherited TBDock3: TTBDock
    Left = 1041
    Height = 575
  end
  inherited TBDock4: TTBDock
    Top = 605
    Width = 1050
  end
  inherited pLeft: TPanel
    Width = 264
    Height = 575
    TabOrder = 1
    inherited ScrollBox: TScrollBox
      Width = 264
      Height = 558
      inherited Panel5: TPanel
        Top = 184
        Width = 247
        Height = 93
        TabOrder = 1
        inherited Label17: TLabel
          Top = 137
          Visible = False
        end
        inherited bAccounts: TButton
          Top = 132
          TabOrder = 5
          Visible = False
        end
        inherited cbSubAccount: TCheckBox
          Top = 156
          TabOrder = 7
          Visible = False
        end
        inherited cbIncludeInternalMovement: TCheckBox
          Top = 60
          TabOrder = 4
        end
        object cbShowDebit: TCheckBox [4]
          Left = 8
          Top = 15
          Width = 147
          Height = 17
          Caption = 'Расшифровка по дебету'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object cbShowCredit: TCheckBox [5]
          Left = 8
          Top = 30
          Width = 155
          Height = 17
          Caption = 'Расшифровка по кредиту'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object cbShowCorrSubAccount: TCheckBox [6]
          Left = 8
          Top = 45
          Width = 187
          Height = 17
          Caption = 'Корреспонденция с субсчетами'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object cbAutoBuildReport: TCheckBox [7]
          Left = 8
          Top = 0
          Width = 193
          Height = 17
          Caption = 'Автоматически перестраивать'
          TabOrder = 0
        end
        inherited cbAccounts: TComboBox
          Top = 132
          Width = 175
          TabOrder = 3
          Visible = False
        end
        object chkBuildGroup: TCheckBox
          Left = 8
          Top = 76
          Width = 137
          Height = 15
          Caption = 'Строить по группам '
          Checked = True
          State = cbChecked
          TabOrder = 8
          OnClick = chkBuildGroupClick
        end
      end
      inherited frAcctQuantity: TfrAcctQuantity
        Top = 318
        Width = 247
        TabOrder = 4
        inherited ppMain: TgdvParamPanel
          Width = 247
        end
      end
      inherited frAcctSum: TfrAcctSum
        Top = 359
        Width = 247
        TabOrder = 6
        inherited ppMain: TgdvParamPanel
          Width = 247
          inherited pnlEQ: TPanel
            Width = 235
          end
          inherited pnlQuantity: TPanel
            Width = 235
          end
          inherited pnlTop: TPanel
            Width = 235
          end
        end
      end
      inherited frAcctAnalytics: TfrAcctAnalytics
        Top = 277
        Width = 247
        TabOrder = 2
        Visible = False
        inherited ppAnalytics: TgdvParamPanel
          Width = 247
        end
      end
      inherited frAcctCompany: TfrAcctCompany
        Top = 580
        Width = 247
        TabOrder = 3
        inherited ppMain: TgdvParamPanel
          Width = 247
          inherited cbAllCompanies: TCheckBox
            Width = 211
          end
          inherited iblCompany: TgsIBLookupComboBox
            Width = 161
            OnChange = frAcctCompanyiblCompanyChange
          end
        end
      end
      inherited ppAppear: TgdvParamPanel
        Top = 640
        Width = 247
        Height = 38
        inherited cbExtendedFields: TCheckBox
          Top = 37
          Visible = False
        end
        object cbEnchancedSaldo: TCheckBox
          Left = 14
          Top = 20
          Width = 195
          Height = 17
          Caption = 'Расширенное сальдо'
          Color = 16316664
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 1
        end
      end
      object pCardOfAccount: TPanel
        Left = 0
        Top = 0
        Width = 247
        Height = 184
        Align = alTop
        BevelOuter = bvNone
        BorderWidth = 3
        Color = 15329769
        TabOrder = 0
        object lCardOfaccount: TLabel
          Left = 4
          Top = 3
          Width = 67
          Height = 13
          Caption = 'План счетов:'
        end
        object ptvGroup: TPanel
          Left = 3
          Top = 16
          Width = 241
          Height = 165
          Align = alBottom
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelOuter = bvLowered
          FullRepaint = False
          TabOrder = 0
          object tvGroup: TgsDBTreeView
            Left = 1
            Top = 1
            Width = 239
            Height = 163
            DataSource = dsAcctChart
            KeyField = 'ID'
            ParentField = 'PARENT'
            DisplayField = 'ALIAS'
            ImageValueList.Strings = (
              '')
            Align = alClient
            BorderStyle = bsNone
            Color = 16316664
            DragMode = dmAutomatic
            HideSelection = False
            Indent = 19
            RightClickSelect = True
            SortType = stText
            TabOrder = 0
            OnChange = tvGroupChange
            MainFolderHead = False
            MainFolder = False
            MainFolderCaption = 'Все'
            WithCheckBox = False
          end
        end
      end
    end
    inherited Panel2: TPanel
      Width = 264
      inherited sbCloseParamPanel: TSpeedButton
        Left = 243
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = ibdsMain
    Left = 552
    Top = 104
  end
  inherited alMain: TActionList
    Top = 48
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Top = 48
  end
  inherited gdReportMenu: TgdReportMenu
    Top = 48
  end
  inherited gsQueryFilter: TgsQueryFilter
    Left = 520
    Top = 104
  end
  inherited Transaction: TIBTransaction
    Left = 624
  end
  inherited ppMain: TPopupMenu
    Left = 440
    Top = 48
  end
  inherited AccountDelayTimer: TTimer
    Left = 264
    Top = 32
  end
  object gdcAcctChart: TgdcAcctBase [15]
    Left = 112
    Top = 168
  end
  object dsAcctChart: TDataSource [16]
    DataSet = gdcAcctChart
    Left = 48
    Top = 136
  end
  object ibdsMain: TgdvAcctGeneralLedger
    CachedUpdates = True
    InsertSQL.Strings = (
      'INSERT INTO AC_LEDGER_ACCOUNTS (ACCOUNTKEY) VALUES (-1)')
    ModifySQL.Strings = (
      'UPDATE AC_LEDGER_ACCOUNTS SET ACCOUNTKEY = -1')
    Left = 606
    Top = 166
  end
end
