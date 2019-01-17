inherited gdc_dlgCustomGroup: Tgdc_dlgCustomGroup
  Left = 415
  Top = 241
  HelpContext = 33
  BorderIcons = [biSystemMenu]
  Caption = 'Группа'
  ClientHeight = 259
  ClientWidth = 432
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 232
    TabOrder = 1
  end
  inherited btnNew: TButton
    Top = 232
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 149
    Top = 232
  end
  inherited btnOK: TButton
    Top = 232
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 357
    Top = 232
    TabOrder = 4
  end
  inherited pgcMain: TPageControl
    Width = 421
    Height = 219
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 8
        Top = 32
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object Label22: TLabel
        Left = 8
        Top = 81
        Width = 35
        Height = 13
        Caption = 'Адрес:'
      end
      object Label28: TLabel
        Left = 8
        Top = 105
        Width = 48
        Height = 13
        Caption = 'Телефон:'
      end
      object Label29: TLabel
        Left = 8
        Top = 130
        Width = 29
        Height = 13
        Caption = 'Факс:'
      end
      object Label4: TLabel
        Left = 8
        Top = 154
        Width = 71
        Height = 13
        Caption = 'Комментарий:'
      end
      object Label3: TLabel
        Left = 8
        Top = 57
        Width = 35
        Height = 13
        Caption = 'Папка:'
      end
      object dbeName: TDBEdit
        Left = 96
        Top = 29
        Width = 313
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbmAddress: TDBMemo
        Left = 96
        Top = 78
        Width = 313
        Height = 21
        DataField = 'ADDRESS'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbmPhone: TDBEdit
        Left = 96
        Top = 103
        Width = 313
        Height = 21
        DataField = 'PHONE'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbmFax: TDBEdit
        Left = 96
        Top = 127
        Width = 313
        Height = 21
        DataField = 'FAX'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object dbmNote: TDBMemo
        Left = 96
        Top = 152
        Width = 313
        Height = 32
        DataField = 'NOTE'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object gsibluFolder: TgsIBLookupComboBox
        Left = 96
        Top = 54
        Width = 313
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'PARENT'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'contacttype IN (0, 3, 4, 5)'
        gdClassName = 'TgdcFolder'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 445
        Height = 207
      end
    end
  end
  inherited alBase: TActionList
    Left = 395
    Top = 0
    object actNewContact: TAction
      Caption = 'Новый контакт ...'
    end
    object actNewCompany: TAction
      Caption = 'Новая компания ...'
    end
    object actChooseContact: TAction
      Caption = 'Выбор ...'
    end
    object actDeleteContact: TAction
      Caption = 'Удаление'
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 365
    Top = 0
  end
  inherited ibtrCommon: TIBTransaction
    Left = 368
    Top = 160
  end
end
