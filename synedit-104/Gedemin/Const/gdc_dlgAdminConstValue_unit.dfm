inherited gdc_dlgAdminConstValue: Tgdc_dlgAdminConstValue
  Left = 392
  Top = 241
  ClientHeight = 271
  ClientWidth = 421
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 79
    Visible = True
  end
  inherited btnNew: TButton
    Top = 114
  end
  inherited btnCancel: TButton
    Top = 43
  end
  inherited btnHelp: TButton
    Top = 149
  end
  inherited pgcMain: TPageControl
    Height = 259
    inherited tbsMain: TTabSheet
      inherited Label2: TLabel
        Top = 61
      end
      inherited Label1: TLabel
        Top = 88
      end
      object Label3: TLabel [4]
        Left = 8
        Top = 141
        Width = 70
        Height = 13
        Caption = 'Организация:'
      end
      object Label21: TLabel [5]
        Left = 8
        Top = 114
        Width = 76
        Height = 13
        Caption = 'Пользователь:'
      end
      inherited dbeValue: TDBEdit
        Top = 84
      end
      object gsibUser: TgsIBLookupComboBox [10]
        Left = 90
        Top = 111
        Width = 215
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = dmDatabase.ibtrGenUniqueID
        DataSource = dsgdcBase
        DataField = 'USERKEY'
        Fields = 'u.name'
        ListTable = 'gd_contact JOIN gd_user u ON u.contactkey=gd_contact.id'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'contacttype=2'
        gdClassName = 'TgdcContact'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
      object gsIBCompany: TgsIBLookupComboBox [11]
        Left = 90
        Top = 137
        Width = 215
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = dmDatabase.ibtrGenUniqueID
        DataSource = dsgdcBase
        DataField = 'COMPANYKEY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'ID'
        SortOrder = soAsc
        Condition = 'id in (<HOLDINGLIST/>)'
        gdClassName = 'TgdcOurCompany'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      inherited Memo1: TMemo
        Top = 163
        TabOrder = 4
      end
    end
  end
  inherited alBase: TActionList
    Left = 245
    Top = 49
  end
  inherited dsgdcBase: TDataSource
    Left = 215
    Top = 49
  end
end
