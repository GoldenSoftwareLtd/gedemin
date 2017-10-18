inherited gdc_dlgCompanyAccount: Tgdc_dlgCompanyAccount
  Left = 414
  Top = 210
  BorderIcons = [biSystemMenu]
  Caption = 'Банковский счет'
  ClientHeight = 246
  ClientWidth = 429
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 352
    Top = 114
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 352
    Top = 89
    TabOrder = 3
  end
  inherited btnHelp: TButton
    Left = 352
    Top = 139
  end
  inherited btnOK: TButton
    Left = 352
    Top = 26
  end
  inherited btnCancel: TButton
    Left = 352
    Top = 52
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
        Width = 21
        Height = 13
        Caption = 'BIC:'
      end
      object Label5: TLabel
        Left = 5
        Top = 52
        Width = 28
        Height = 13
        Caption = 'IBAN:'
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
        Top = 181
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
        TabOrder = 3
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
        TabOrder = 5
      end
      object gsibluBankCode: TgsIBLookupComboBox
        Left = 75
        Top = 75
        Width = 253
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
        TabOrder = 4
      end
      object dbcbDisabled: TDBCheckBox
        Left = 75
        Top = 186
        Width = 97
        Height = 17
        Caption = 'Не активный'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 6
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
    Left = 206
    Top = 10
  end
  inherited dsgdcBase: TDataSource
    Left = 264
    Top = 242
  end
  inherited pm_dlgG: TPopupMenu
    Left = 120
    Top = 152
  end
  inherited ibtrCommon: TIBTransaction
    Left = 224
    Top = 248
  end
end
