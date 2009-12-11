inherited gdv_frmAcctLedger: Tgdv_frmAcctLedger
  Left = 169
  Top = 148
  Width = 1050
  Height = 566
  HelpContext = 100
  Caption = '������-�����'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sLeft: TSplitter
    Height = 496
  end
  inherited TBDock1: TTBDock
    Width = 1042
    inherited TBToolbar2: TTBToolbar
      DockPos = 154
    end
    inherited TBToolbar1: TTBToolbar
      inherited pCofiguration: TPanel
        inherited iblConfiguratior: TgsIBLookupComboBox
          gdClassName = 'TgdcAcctLedgerConfig'
        end
      end
    end
  end
  inherited Panel1: TPanel
    Width = 773
    Height = 496
    inherited ibgrMain: TgsIBGrid
      Width = 773
      Height = 496
    end
  end
  inherited TBDock2: TTBDock
    Height = 496
  end
  inherited TBDock3: TTBDock
    Left = 1033
    Height = 496
  end
  inherited TBDock4: TTBDock
    Top = 526
    Width = 1042
  end
  inherited pLeft: TPanel
    Height = 496
    inherited ScrollBox: TScrollBox
      Height = 479
      inherited Panel5: TPanel
        Width = 231
        Height = 115
        inherited bAccounts: TButton
          Left = 201
          Width = 19
        end
        inherited cbAccounts: TComboBox [3]
          Width = 157
        end
        object cbShowDebit: TCheckBox [4]
          Left = 8
          Top = 48
          Width = 147
          Height = 17
          Caption = '����������� �� ������'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object cbShowCredit: TCheckBox [5]
          Left = 8
          Top = 64
          Width = 155
          Height = 17
          Caption = '����������� �� �������'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object cbShowCorrSubAccount: TCheckBox [6]
          Left = 8
          Top = 80
          Width = 187
          Height = 17
          Caption = '��������������� � ����������'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        inherited cbIncludeInternalMovement: TCheckBox [7]
          Top = 96
          TabOrder = 6
        end
      end
      inherited frAcctQuantity: TfrAcctQuantity
        Top = 330
        Width = 231
        TabOrder = 4
        inherited ppMain: TgdvParamPanel
          Width = 231
        end
      end
      inherited frAcctSum: TfrAcctSum
        Top = 371
        Width = 231
        Height = 213
        TabOrder = 5
        inherited ppMain: TgdvParamPanel
          Width = 231
          Height = 213
          inherited cbEQScale: TComboBox
            OnExit = nil
            OnKeyPress = nil
          end
        end
      end
      inherited frAcctAnalytics: TfrAcctAnalytics
        Top = 115
        Width = 231
        inherited ppAnalytics: TgdvParamPanel
          Width = 231
        end
      end
      inherited frAcctCompany: TfrAcctCompany
        Top = 584
        Width = 231
        TabOrder = 6
        inherited ppMain: TgdvParamPanel
          Width = 231
          inherited cbAllCompanies: TCheckBox
            Width = 193
          end
          inherited iblCompany: TgsIBLookupComboBox
            Width = 143
          end
        end
      end
      inherited ppAppear: TgdvParamPanel
        Top = 644
        Width = 231
        Height = 80
        TabOrder = 7
        inherited cbExtendedFields: TCheckBox
          HelpContext = 100
        end
        object cbEnchancedSaldo: TCheckBox
          Left = 14
          Top = 54
          Width = 195
          Height = 17
          Caption = '����������� ������ �����'
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
        object cbSumNull: TCheckBox
          Left = 14
          Top = 37
          Width = 195
          Height = 17
          Caption = '������� ����� ������ �����'
          Color = 16316664
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 2
        end
      end
      inline frAcctAnalyticsGroup: TfrAcctAnalyticsGroup
        Top = 156
        Width = 231
        Align = alTop
        TabOrder = 2
        inherited ppMain: TgdvParamPanel
          Width = 231
          inherited pClient: TPanel
            Width = 219
            Color = 16316664
          end
        end
      end
      inline frAcctTreeAnalytic: Tgdv_frAcctTreeAnalytic
        Top = 292
        Width = 231
        Height = 38
        Align = alTop
        TabOrder = 3
        inherited ppMain: TgdvParamPanel
          Width = 231
          Height = 38
          Font.Color = 9529602
        end
      end
    end
    inherited Panel2: TPanel
      inherited sbCloseParamPanel: TSpeedButton
        Left = 225
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
      Caption = '������� �� ����� �����'
      Hint = '������� �� ����� �����'
      ImageIndex = 220
    end
    inherited actSaveConfig: TAction
      OnUpdate = actSaveConfigUpdate
    end
  end
  object ibdsMain: TgdvAcctLedger
    AfterOpen = ibdsMainAfterOpen
    CachedUpdates = True
    InsertSQL.Strings = (
      'INSERT INTO AC_LEDGER_ACCOUNTS (ACCOUNTKEY) VALUES (-1)')
    ModifySQL.Strings = (
      'UPDATE AC_LEDGER_ACCOUNTS SET ACCOUNTKEY = -1')
    OnCalcAggregates = ibdsMainCalcAggregates
    Left = 660
    Top = 174
  end
end
