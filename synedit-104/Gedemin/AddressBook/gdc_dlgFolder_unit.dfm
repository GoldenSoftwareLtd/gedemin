inherited gdc_dlgFolder: Tgdc_dlgFolder
  Left = 360
  Top = 290
  HelpContext = 35
  ActiveControl = dbeName
  BorderIcons = [biSystemMenu]
  Caption = 'Папка'
  ClientHeight = 202
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 171
    TabOrder = 1
  end
  inherited btnNew: TButton
    Left = 85
    Top = 171
    TabOrder = 2
  end
  inherited btnOK: TButton
    Left = 277
    Top = 171
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 357
    Top = 171
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 171
  end
  inherited pgcMain: TPageControl
    Height = 155
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Top = 16
      end
      inherited dbtxtID: TDBText
        Left = 136
        Top = 16
      end
      object Label1: TLabel
        Left = 8
        Top = 44
        Width = 110
        Height = 13
        Caption = 'Наименование папки:'
      end
      object Label2: TLabel
        Left = 8
        Top = 71
        Width = 83
        Height = 13
        Caption = 'Входит в папку:'
      end
      object dbeName: TDBEdit
        Left = 136
        Top = 40
        Width = 264
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object gsIBLookupComboBox1: TgsIBLookupComboBox
        Left = 136
        Top = 67
        Width = 265
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'PARENT'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'ID'
        Condition = 'gd_contact.contacttype=0'
        gdClassName = 'TgdcFolder'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Height = 127
      end
    end
  end
  inherited alBase: TActionList
    Left = 246
    Top = 45
  end
  inherited dsgdcBase: TDataSource
    Left = 186
    Top = 45
  end
  inherited pm_dlgG: TPopupMenu
    Left = 216
    Top = 48
  end
  inherited ibtrCommon: TIBTransaction
    Left = 336
    Top = 48
  end
end
