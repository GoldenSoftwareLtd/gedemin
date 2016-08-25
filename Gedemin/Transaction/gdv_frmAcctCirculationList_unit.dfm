inherited gdv_frmAcctCirculationList: Tgdv_frmAcctCirculationList
  Left = 401
  Top = 225
  Width = 1058
  Height = 629
  HelpContext = 159
  Caption = 'Оборотная ведомость'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sLeft: TSplitter
    Left = 250
    Height = 559
  end
  inherited TBDock1: TTBDock
    Width = 1050
    inherited tbMainToolbar: TTBToolbar
      CloseButton = False
      object TBItem3_: TTBItem [2]
        Action = actGotoLedger
      end
    end
    inherited TBToolbar2: TTBToolbar
      Left = 218
      inherited Panel4: TPanel
        inherited SpeedButton1: TSpeedButton
          Hint = 'Рассчитать'
          ParentShowHint = False
        end
      end
    end
    inherited TBToolbar1: TTBToolbar
      Left = 457
      inherited pCofiguration: TPanel
        inherited iblConfiguratior: TgsIBLookupComboBox
          gdClassName = 'TgdcAcctCicrilationListConfig'
        end
      end
    end
  end
  inherited Panel1: TPanel
    Left = 256
    Width = 785
    Height = 559
    inherited ibgrMain: TgsIBGrid
      Width = 785
      Height = 559
    end
  end
  inherited TBDock2: TTBDock
    Height = 559
  end
  inherited TBDock3: TTBDock
    Left = 1041
    Height = 559
  end
  inherited TBDock4: TTBDock
    Top = 589
    Width = 1050
  end
  inherited pLeft: TPanel
    Width = 241
    Height = 559
    inherited ScrollBox: TScrollBox
      Width = 241
      Height = 542
      inherited Panel5: TPanel
        Top = 220
        Width = 224
        Height = 88
        TabOrder = 1
        inherited Label17: TLabel
          Top = 127
          Visible = False
        end
        inherited bAccounts: TButton
          Left = 236
          Top = 80
          Visible = False
        end
        inherited cbSubAccount: TCheckBox
          Width = 185
          Caption = 'Включать субсчета в главный'
        end
        inherited cbAccounts: TComboBox [3]
          Top = 123
          Width = 152
          Enabled = False
          TabOrder = 5
          Visible = False
        end
        inherited cbIncludeInternalMovement: TCheckBox [4]
          Top = 16
          Checked = True
          State = cbChecked
        end
        object cbAutoBuildReport: TCheckBox
          Left = 8
          Top = 0
          Width = 193
          Height = 17
          Caption = 'Автоматически перестраивать'
          TabOrder = 0
        end
        object cbDisplaceSaldo: TCheckBox
          Left = 20
          Top = 48
          Width = 141
          Height = 17
          Caption = 'Сворачивать сальдо'
          TabOrder = 4
        end
        object cbOnlyAccounts: TCheckBox
          Left = 20
          Top = 64
          Width = 153
          Height = 17
          Caption = 'Только главные счета'
          TabOrder = 6
        end
      end
      inherited frAcctQuantity: TfrAcctQuantity
        Top = 349
        Width = 224
        TabOrder = 6
        inherited ppMain: TgdvParamPanel
          Width = 224
          Visible = False
        end
      end
      inherited frAcctSum: TfrAcctSum
        Top = 390
        Width = 224
        inherited ppMain: TgdvParamPanel
          Width = 224
          inherited pnlEQ: TPanel
            Width = 212
          end
          inherited pnlQuantity: TPanel
            Width = 212
          end
          inherited pnlTop: TPanel
            Width = 212
          end
        end
      end
      inherited frAcctAnalytics: TfrAcctAnalytics
        Top = 308
        Width = 224
        TabOrder = 2
        Visible = False
        inherited ppAnalytics: TgdvParamPanel
          Width = 224
        end
      end
      inherited frAcctCompany: TfrAcctCompany
        Top = 611
        Width = 224
        inherited ppMain: TgdvParamPanel
          Width = 224
          inherited cbAllCompanies: TCheckBox
            Width = 188
          end
          inherited iblCompany: TgsIBLookupComboBox
            Width = 138
          end
        end
      end
      inherited ppAppear: TgdvParamPanel
        Top = 671
        Width = 224
        Height = 42
        Visible = False
      end
      object pCardOfAccount: TPanel
        Left = 0
        Top = 0
        Width = 224
        Height = 220
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
          Width = 218
          Height = 201
          Align = alBottom
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelOuter = bvLowered
          FullRepaint = False
          TabOrder = 0
          object tvGroup: TgsDBTreeView
            Left = 1
            Top = 1
            Width = 216
            Height = 199
            DataSource = dsAcctChart
            KeyField = 'ID'
            ParentField = 'PARENT'
            DisplayField = 'NAME'
            ImageValueList.Strings = (
              '')
            Align = alClient
            BorderStyle = bsNone
            Color = 16316664
            DragMode = dmAutomatic
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
      Width = 241
      inherited sbCloseParamPanel: TSpeedButton
        Left = 220
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = ibdsMain
  end
  inherited alMain: TActionList
    object actAccountCard: TAction [0]
      Category = 'Commands'
      Caption = 'Карта по счету'
      Hint = 'Карта по счету'
      ImageIndex = 220
    end
    inherited actRun: TAction
      OnUpdate = actRunUpdate
    end
    inherited actGoto: TAction
      Caption = 'Перейти на карту счета'
      Hint = 'Перейти на карту счета'
      ImageIndex = 220
    end
    object actAnalizeRevolution: TAction
      Category = 'Commands'
      Caption = 'Аналитика по счету'
      Hint = 'Аналитика по счету'
      ImageIndex = 186
      OnUpdate = actAnalizeRevolutionUpdate
    end
    object actGotoLedger: TAction
      Caption = 'Перейти в журнал-ордер'
      Hint = 'Перейти в журнал-ордер'
      ImageIndex = 186
      ShortCut = 16460
      OnExecute = actGotoLedgerExecute
      OnUpdate = actGotoLedgerUpdate
    end
  end
  inherited ppMain: TPopupMenu
    object N3: TMenuItem
      Action = actGotoLedger
    end
  end
  object dsAcctChart: TDataSource
    DataSet = gdcAcctChart
    Left = 109
    Top = 124
  end
  object gdcAcctChart: TgdcAcctChart
    SubSet = 'ByCompany'
    Left = 116
    Top = 175
  end
  object PopupMenu: TPopupMenu
    Images = dmImages.il16x16
    Left = 278
    Top = 104
    object N1: TMenuItem
      Action = actAccountCard
    end
    object N2: TMenuItem
      Action = actAnalizeRevolution
    end
  end
  object ibdsMain: TgdvAcctCirculationList
    AfterOpen = ibdsMainAfterOpen
    CachedUpdates = True
    DeleteSQL.Strings = (
      'DELETE FROM AC_LEDGER_ACCOUNTS WHERE ACCOUNTKEY = -1')
    InsertSQL.Strings = (
      'INSERT INTO AC_LEDGER_ACCOUNTS (ACCOUNTKEY) VALUES (-1)')
    ModifySQL.Strings = (
      'UPDATE AC_LEDGER_ACCOUNTS SET ACCOUNTKEY = -1')
    Left = 631
    Top = 134
  end
  object cdsTotal: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 448
    Top = 152
  end
end
