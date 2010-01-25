inherited dlgBaseAcctConfig: TdlgBaseAcctConfig
  Left = 284
  Top = 135
  BorderWidth = 5
  Caption = 'Конфигурация'
  ClientHeight = 428
  ClientWidth = 614
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 545
    Top = 85
    Anchors = [akTop, akRight]
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 545
    Top = 61
    Anchors = [akTop, akRight]
  end
  inherited btnOK: TButton
    Left = 544
    Top = 5
    Anchors = [akTop, akRight]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 544
    Top = 29
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 545
    Top = 109
    Anchors = [akTop, akRight]
    TabOrder = 5
  end
  object PageControl: TPageControl [5]
    Left = 0
    Top = 0
    Width = 536
    Height = 428
    ActivePage = tsGeneral
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsGeneral: TTabSheet
      BorderWidth = 3
      Caption = 'Общие'
      object Label2: TLabel
        Left = 0
        Top = 4
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object lAccounts: TLabel
        Left = 0
        Top = 28
        Width = 35
        Height = 13
        Caption = 'Счета:'
      end
      inline frSum: TframeSum
        Top = 191
        Width = 522
        Align = alBottom
        TabOrder = 6
        inherited gbSum: TGroupBox
          Width = 522
          Align = alClient
          inherited Label13: TLabel
            Width = 59
          end
          inherited Label15: TLabel
            Width = 59
          end
          inherited Label10: TLabel
            Width = 43
          end
          inherited Label1: TLabel
            Width = 59
          end
          inherited gsiblCurrKey: TgsIBLookupComboBox
            Width = 81
          end
        end
      end
      inline frQuantity: TframeQuantity
        Top = 88
        Width = 522
        Height = 103
        Align = alBottom
        TabOrder = 5
        inherited gbGroup: TGroupBox
          Width = 522
          Height = 103
          Align = alClient
          inherited Label11: TLabel
            Width = 53
          end
          inherited lbAvail: TListBox
            Width = 223
          end
          inherited lbSelected: TListBox
            Left = 289
            Width = 223
            Height = 68
          end
          inherited Button3: TButton
            Left = 241
          end
          inherited Button4: TButton
            Left = 241
          end
          inherited Button5: TButton
            Left = 241
          end
          inherited Button6: TButton
            Left = 241
          end
        end
        inherited ActionList1: TActionList
          Left = 16
          Top = 32
        end
      end
      object dbeName: TDBEdit
        Left = 88
        Top = 0
        Width = 249
        Height = 21
        DataField = 'name'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object cbAccounts: TComboBox
        Left = 88
        Top = 24
        Width = 228
        Height = 21
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbAccountsChange
        OnExit = cbAccountsExit
      end
      object cbSubAccounts: TCheckBox
        Left = 0
        Top = 48
        Width = 121
        Height = 14
        Caption = 'Включать субсчета'
        TabOrder = 3
        OnClick = cbSubAccountsClick
      end
      object cbIncludeInternalMovement: TCheckBox
        Left = 0
        Top = 64
        Width = 257
        Height = 14
        Caption = 'Включать внутренние проводки'
        TabOrder = 4
      end
      object Button1: TButton
        Left = 316
        Top = 24
        Width = 21
        Height = 21
        Action = actAccounts
        TabOrder = 2
      end
      object GroupBox1: TGroupBox
        Left = 0
        Top = 298
        Width = 522
        Height = 96
        Align = alBottom
        Caption = ' Отображение '
        TabOrder = 7
        object lShowInFolder: TLabel
          Left = 24
          Top = 50
          Width = 108
          Height = 13
          Caption = 'Показывать в папке:'
        end
        object lImage: TLabel
          Left = 24
          Top = 74
          Width = 41
          Height = 13
          Caption = 'Иконка:'
        end
        object dbcShowInExplorer: TDBCheckBox
          Left = 8
          Top = 30
          Width = 233
          Height = 14
          Caption = 'Показывать в исследователе'
          DataField = 'SHOWINEXPLORER'
          DataSource = dsgdcBase
          TabOrder = 1
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = dbcShowInExplorerClick
        end
        object iblFolder: TgsIBLookupComboBox
          Left = 136
          Top = 46
          Width = 193
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'FOLDER'
          ListTable = 'gd_command'
          ListField = 'name'
          KeyField = 'ID'
          gdClassName = 'TgdcExplorer'
          Enabled = False
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object cbImage: TDBComboBox
          Left = 136
          Top = 69
          Width = 193
          Height = 22
          Style = csOwnerDrawFixed
          Enabled = False
          ItemHeight = 16
          TabOrder = 3
          OnDrawItem = cbImageDrawItem
          OnDropDown = cbImageDropDown
        end
        object cbExtendedFields: TCheckBox
          Left = 8
          Top = 14
          Width = 321
          Height = 14
          Caption = 'Расширенное отображение полей'
          TabOrder = 0
        end
      end
    end
    object tsAnalytics: TTabSheet
      BorderWidth = 3
      Caption = 'Значения аналитик'
      ImageIndex = 1
      inline frAnalytics: TframeAnalyticValue
        Width = 338
        Height = 394
        Align = alClient
        inherited sbAnaliseLines: TScrollBox
          Width = 338
          Height = 394
          BorderStyle = bsSingle
        end
      end
    end
  end
  inherited alBase: TActionList
    object actAccounts: TAction
      Caption = '...'
      OnExecute = actAccountsExecute
    end
  end
  inherited ibtrCommon: TIBTransaction
    Left = 184
  end
end
