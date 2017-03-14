inherited gdc_dlgCompanyAccount: Tgdc_dlgCompanyAccount
  Left = 410
  Top = 206
  BorderIcons = [biSystemMenu]
  Caption = 'Банковский счет'
  ClientHeight = 248
  ClientWidth = 435
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 358
    Top = 109
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 358
    Top = 82
    TabOrder = 3
  end
  inherited btnHelp: TButton
    Left = 358
    Top = 136
  end
  inherited btnOK: TButton
    Left = 358
    Top = 8
  end
  inherited btnCancel: TButton
    Top = 36
  end
  inherited pgcMain: TPageControl
    Width = 341
    Height = 235
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 5
        Top = 0
      end
      inherited dbtxtID: TDBText
        Top = 0
      end
      object Label1: TLabel
        Left = 5
        Top = 105
        Width = 28
        Height = 13
        Caption = 'Банк:'
      end
      object Label3: TLabel
        Left = 5
        Top = 79
        Width = 24
        Height = 13
        Caption = 'Код:'
      end
      object Label4: TLabel
        Left = 177
        Top = 79
        Width = 31
        Height = 13
        Caption = 'МФО: '
      end
      object Label5: TLabel
        Left = 5
        Top = 52
        Width = 29
        Height = 13
        Caption = 'Счет:'
      end
      object Label6: TLabel
        Left = 5
        Top = 131
        Width = 54
        Height = 13
        Caption = 'Тип счета:'
      end
      object Label10: TLabel
        Left = 5
        Top = 157
        Width = 43
        Height = 13
        Caption = 'Валюта:'
      end
      object Bevel1: TBevel
        Left = 4
        Top = 182
        Width = 322
        Height = 2
        Anchors = [akTop, akRight]
      end
      object lblCompany: TLabel
        Left = 5
        Top = 26
        Width = 70
        Height = 13
        Caption = 'Организация:'
      end
      object gsibluBank: TgsIBLookupComboBox
        Left = 75
        Top = 101
        Width = 253
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'BANKKEY'
        Fields = 'b.bankcode'
        ListTable = 'gd_contact c right join gd_bank b on b.bankkey = c.id'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'contacttype=5'
        gdClassName = 'TgdcBank'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object dbeAccount: TDBEdit
        Left = 75
        Top = 49
        Width = 253
        Height = 21
        DataField = 'ACCOUNT'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object gsibluCurr: TgsIBLookupComboBox
        Left = 75
        Top = 153
        Width = 253
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'CURRKEY'
        ListTable = 'GD_CURR'
        ListField = 'NAME'
        KeyField = 'ID'
        SortOrder = soAsc
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
      end
      object gsibluBankCode: TgsIBLookupComboBox
        Left = 75
        Top = 75
        Width = 94
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'BANKKEY'
        Fields = 'bankmfo'
        ListTable = 
          'gd_bank join gd_contact c ON c.id=bankkey AND ((c.disabled IS NU' +
          'LL) OR (c.disabled = 0))'
        ListField = 'bankcode'
        KeyField = 'bankkey'
        SortOrder = soAsc
        Condition = 'bankcode <> '#39#39
        gdClassName = 'TgdcBank'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
      object gsibluMFO: TgsIBLookupComboBox
        Left = 208
        Top = 75
        Width = 120
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'BANKKEY'
        Fields = 'bankcode'
        ListTable = 
          'gd_bank join gd_contact c ON c.id=bankkey AND ((c.disabled IS NU' +
          'LL) OR (c.disabled = 0))'
        ListField = 'bankmfo'
        KeyField = 'bankkey'
        SortOrder = soAsc
        gdClassName = 'TgdcBank'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object gsibluAccountType: TgsIBLookupComboBox
        Left = 75
        Top = 127
        Width = 253
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'ACCOUNTTYPEKEY'
        ListTable = 'gd_compacctype'
        ListField = 'name'
        KeyField = 'id'
        gdClassName = 'TgdcCompanyAccountType'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
      end
      object dbcbDisabled: TDBCheckBox
        Left = 75
        Top = 187
        Width = 97
        Height = 17
        Caption = 'Не активный'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 7
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object gsibluCompany: TgsIBLookupComboBox
        Left = 75
        Top = 23
        Width = 253
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'COMPANYKEY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'contacttype in (3, 5)'
        gdClassName = 'TgdcCompany'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 86
    Top = 66
  end
  inherited dsgdcBase: TDataSource
    Left = 48
    Top = 106
  end
  inherited pm_dlgG: TPopupMenu
    Left = 120
    Top = 152
  end
  inherited ibtrCommon: TIBTransaction
    Left = 80
    Top = 120
  end
end
