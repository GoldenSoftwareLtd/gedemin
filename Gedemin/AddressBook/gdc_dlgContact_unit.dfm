inherited gdc_dlgContact: Tgdc_dlgContact
  Left = 329
  Top = 186
  HelpContext = 34
  BorderIcons = [biSystemMenu]
  Caption = 'Физическое лицо'
  ClientHeight = 372
  ClientWidth = 462
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 344
  end
  inherited btnNew: TButton
    Left = 82
    Top = 344
  end
  inherited btnHelp: TButton
    Left = 158
    Top = 344
  end
  inherited btnOK: TButton
    Left = 311
    Top = 344
  end
  inherited btnCancel: TButton
    Left = 388
    Top = 344
  end
  inherited pgcMain: TPageControl
    Top = 5
    Width = 453
    Height = 331
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 3
        Top = 4
        Width = 40
        Caption = 'Идент.:'
      end
      inherited dbtxtID: TDBText
        Left = 50
        Top = 4
        Width = 87
      end
      object Label6: TLabel
        Left = 115
        Top = 21
        Width = 23
        Height = 13
        Caption = 'Имя:'
      end
      object Label8: TLabel
        Left = 3
        Top = 59
        Width = 35
        Height = 13
        Caption = 'Экран:'
        FocusControl = dbcbName
      end
      object Label9: TLabel
        Left = 225
        Top = 21
        Width = 53
        Height = 13
        Caption = 'Отчество:'
      end
      object Label10: TLabel
        Left = 3
        Top = 21
        Width = 48
        Height = 13
        Caption = 'Фамилия:'
      end
      object Label7: TLabel
        Left = 337
        Top = 21
        Width = 47
        Height = 13
        Caption = 'Коротко:'
      end
      object Label3: TLabel
        Left = 3
        Top = 97
        Width = 35
        Height = 13
        Caption = 'Папка:'
        FocusControl = gsibluFolder
      end
      object Label31: TLabel
        Left = 225
        Top = 59
        Width = 48
        Height = 13
        Caption = 'Телефон:'
      end
      object Label32: TLabel
        Left = 337
        Top = 59
        Width = 29
        Height = 13
        Caption = 'Факс:'
      end
      object Label43: TLabel
        Left = 225
        Top = 172
        Width = 34
        Height = 13
        Caption = 'Район:'
      end
      object Label16: TLabel
        Left = 225
        Top = 135
        Width = 41
        Height = 13
        Caption = 'Страна:'
      end
      object Label21: TLabel
        Left = 337
        Top = 135
        Width = 59
        Height = 13
        Caption = 'Обл./респ.:'
      end
      object Label44: TLabel
        Left = 337
        Top = 172
        Width = 96
        Height = 13
        Caption = 'Город, нас. пункт:'
      end
      object Label22: TLabel
        Left = 3
        Top = 135
        Width = 150
        Height = 13
        Caption = 'Страна, область, нас. пункт:'
      end
      object Label14: TLabel
        Left = 3
        Top = 172
        Width = 35
        Height = 13
        Caption = 'Адрес:'
      end
      object Label25: TLabel
        Left = 3
        Top = 209
        Width = 41
        Height = 13
        Caption = 'Индекс:'
      end
      object Label1: TLabel
        Left = 115
        Top = 209
        Width = 28
        Height = 13
        Caption = 'Email:'
      end
      object Label17: TLabel
        Left = 225
        Top = 209
        Width = 34
        Height = 13
        Caption = 'WWW:'
      end
      object Label39: TLabel
        Left = 3
        Top = 245
        Width = 71
        Height = 13
        Caption = 'Комментарий:'
      end
      object Label18: TLabel
        Left = 337
        Top = 209
        Width = 75
        Height = 13
        Caption = 'Дом. телефон:'
      end
      object Label63: TLabel
        Left = 225
        Top = 97
        Width = 113
        Height = 13
        Caption = 'Рабочая организация:'
        FocusControl = gsIBlcWCompanyKey
      end
      object dbeFirstName: TDBEdit
        Left = 114
        Top = 36
        Width = 104
        Height = 21
        DataField = 'FIRSTNAME'
        DataSource = dsgdcBase
        TabOrder = 1
        OnKeyDown = dbeSurnameKeyDown
        OnKeyPress = dbeSurnameKeyPress
        OnKeyUp = dbeSurnameKeyUp
      end
      object dbeMiddleName: TDBEdit
        Left = 224
        Top = 36
        Width = 104
        Height = 21
        DataField = 'MIDDLENAME'
        DataSource = dsgdcBase
        TabOrder = 2
        OnKeyDown = dbeSurnameKeyDown
        OnKeyPress = dbeSurnameKeyPress
        OnKeyUp = dbeSurnameKeyUp
      end
      object dbeSurname: TDBEdit
        Left = 3
        Top = 36
        Width = 104
        Height = 21
        DataField = 'SURNAME'
        DataSource = dsgdcBase
        TabOrder = 0
        OnKeyDown = dbeSurnameKeyDown
        OnKeyPress = dbeSurnameKeyPress
        OnKeyUp = dbeSurnameKeyUp
      end
      object dbeNickName: TDBEdit
        Left = 335
        Top = 36
        Width = 104
        Height = 21
        DataField = 'NICKNAME'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbcbName: TDBComboBox
        Left = 3
        Top = 74
        Width = 215
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        ItemHeight = 13
        Items.Strings = (
          ''
          '')
        TabOrder = 4
      end
      object dbcbDisabled: TDBCheckBox
        Left = 3
        Top = 285
        Width = 150
        Height = 17
        Caption = 'Запись отключена'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 20
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object gsibluFolder: TgsIBLookupComboBox
        Left = 3
        Top = 111
        Width = 215
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
        TabOrder = 7
      end
      object dbWPhone: TDBEdit
        Left = 224
        Top = 74
        Width = 104
        Height = 21
        DataField = 'PHONE'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object dbWFax: TDBEdit
        Left = 335
        Top = 74
        Width = 104
        Height = 21
        DataField = 'FAX'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object DBEdit7: TDBEdit
        Left = 224
        Top = 187
        Width = 102
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'district'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 9
      end
      object DBEdit5: TDBEdit
        Left = 224
        Top = 150
        Width = 104
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'country'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 10
      end
      object DBEdit6: TDBEdit
        Left = 335
        Top = 150
        Width = 104
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'region'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 11
      end
      object DBEdit8: TDBEdit
        Left = 335
        Top = 187
        Width = 104
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'city'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 12
      end
      object gsIBLookupComboBox1: TgsIBLookupComboBox
        Left = 3
        Top = 150
        Width = 215
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'placekey'
        ListTable = 'GD_PLACE'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcPlace'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 13
      end
      object dbmAddressH: TDBMemo
        Left = 3
        Top = 187
        Width = 215
        Height = 21
        DataField = 'ADDRESS'
        DataSource = dsgdcBase
        ScrollBars = ssVertical
        TabOrder = 14
      end
      object dbZIP: TDBEdit
        Left = 3
        Top = 224
        Width = 102
        Height = 21
        DataField = 'ZIP'
        DataSource = dsgdcBase
        TabOrder = 15
      end
      object dbeEmail: TDBEdit
        Left = 114
        Top = 224
        Width = 102
        Height = 21
        DataField = 'EMAIL'
        DataSource = dsgdcBase
        TabOrder = 16
        OnKeyDown = dbeSurnameKeyDown
        OnKeyPress = dbeSurnameKeyPress
        OnKeyUp = dbeSurnameKeyUp
      end
      object dbHWWW: TDBEdit
        Left = 224
        Top = 224
        Width = 102
        Height = 21
        DataField = 'URL'
        DataSource = dsgdcBase
        TabOrder = 17
      end
      object dbmComentary: TDBMemo
        Left = 3
        Top = 260
        Width = 437
        Height = 21
        DataField = 'NOTE'
        DataSource = dsgdcBase
        TabOrder = 19
      end
      object dbHPhone: TDBEdit
        Left = 335
        Top = 224
        Width = 104
        Height = 21
        DataField = 'HPHONE'
        DataSource = dsgdcBase
        TabOrder = 18
      end
      object gsIBlcWCompanyKey: TgsIBLookupComboBox
        Left = 224
        Top = 111
        Width = 215
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'WCOMPANYKEY'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'contacttype IN (3, 5)'
        gdClassName = 'TgdcCompany'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 8
      end
    end
    object TabSheet2: TTabSheet [1]
      Caption = 'Паспорт'
      ImageIndex = 1
      object Label12: TLabel
        Left = 5
        Top = 20
        Width = 150
        Height = 13
        Caption = 'Страна, область, нас. пункт:'
      end
      object Label15: TLabel
        Left = 5
        Top = 96
        Width = 41
        Height = 13
        Caption = 'Индекс:'
      end
      object Label36: TLabel
        Left = 224
        Top = 20
        Width = 41
        Height = 13
        Caption = 'Страна:'
      end
      object Label40: TLabel
        Left = 335
        Top = 20
        Width = 47
        Height = 13
        Caption = 'Область:'
      end
      object Label41: TLabel
        Left = 224
        Top = 59
        Width = 34
        Height = 13
        Caption = 'Район:'
      end
      object Label42: TLabel
        Left = 335
        Top = 59
        Width = 93
        Height = 13
        Caption = 'Город/нас. пункт:'
      end
      object Label45: TLabel
        Left = 5
        Top = 59
        Width = 35
        Height = 13
        Caption = 'Адрес:'
      end
      object Label29: TLabel
        Left = 114
        Top = 97
        Width = 37
        Height = 13
        Caption = 'Отдел:'
      end
      object Label4: TLabel
        Left = 5
        Top = 212
        Width = 35
        Height = 13
        Caption = 'Номер:'
      end
      object Label5: TLabel
        Left = 114
        Top = 212
        Width = 80
        Height = 13
        Caption = 'Срок действия:'
      end
      object Label11: TLabel
        Left = 224
        Top = 212
        Width = 72
        Height = 13
        Caption = 'Дата выдачи:'
      end
      object Label23: TLabel
        Left = 335
        Top = 212
        Width = 59
        Height = 13
        Caption = 'Кто выдал:'
      end
      object Label24: TLabel
        Left = 5
        Top = 250
        Width = 77
        Height = 13
        Caption = 'Место выдачи:'
      end
      object Label13: TLabel
        Left = 114
        Top = 250
        Width = 76
        Height = 13
        Caption = 'Личный номер:'
      end
      object Label35: TLabel
        Left = 5
        Top = 157
        Width = 54
        Height = 13
        Caption = 'Супруг(а):'
      end
      object Label2: TLabel
        Left = 114
        Top = 157
        Width = 30
        Height = 13
        Caption = 'Дети:'
      end
      object Label38: TLabel
        Left = 335
        Top = 157
        Width = 84
        Height = 13
        Caption = 'Дата рождения:'
      end
      object Bevel1: TBevel
        Left = 96
        Top = 10
        Width = 342
        Height = 3
        Shape = bsTopLine
      end
      object Label26: TLabel
        Left = 5
        Top = 3
        Width = 85
        Height = 13
        Caption = 'Домашний адрес'
      end
      object Label28: TLabel
        Left = 225
        Top = 97
        Width = 61
        Height = 13
        Caption = 'Должность:'
      end
      object Label19: TLabel
        Left = 5
        Top = 195
        Width = 107
        Height = 13
        Caption = 'Паспортные данные '
      end
      object Bevel2: TBevel
        Left = 113
        Top = 202
        Width = 325
        Height = 3
        Shape = bsTopLine
      end
      object Label20: TLabel
        Left = 5
        Top = 139
        Width = 37
        Height = 13
        Caption = 'Личное'
      end
      object Bevel3: TBevel
        Left = 47
        Top = 146
        Width = 389
        Height = 3
        Shape = bsTopLine
      end
      object dbHZIP: TDBEdit
        Left = 3
        Top = 112
        Width = 104
        Height = 21
        DataField = 'HZIP'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object DBEdit1: TDBEdit
        Left = 224
        Top = 36
        Width = 104
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'hcountry'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 15
      end
      object DBEdit2: TDBEdit
        Left = 335
        Top = 36
        Width = 104
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'hregion'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 16
      end
      object DBEdit3: TDBEdit
        Left = 224
        Top = 74
        Width = 104
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'hdistrict'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 17
      end
      object DBEdit4: TDBEdit
        Left = 335
        Top = 74
        Width = 104
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'hcity'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 18
      end
      object gsIBLookupComboBox2: TgsIBLookupComboBox
        Left = 3
        Top = 36
        Width = 215
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'hplacekey'
        ListTable = 'GD_PLACE'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcPlace'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object dbmAddress: TDBMemo
        Left = 3
        Top = 74
        Width = 215
        Height = 21
        DataField = 'HADDRESS'
        DataSource = dsgdcBase
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object dbWDepartment: TDBEdit
        Left = 114
        Top = 112
        Width = 104
        Height = 21
        DataField = 'WDEPARTMENT'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbePassportNumber: TDBEdit
        Left = 3
        Top = 227
        Width = 104
        Height = 21
        DataField = 'PASSPORTNUMBER'
        DataSource = dsgdcBase
        TabOrder = 9
      end
      object dbePassportIssuer: TDBEdit
        Left = 335
        Top = 227
        Width = 104
        Height = 21
        DataField = 'PASSPORTISSUER'
        DataSource = dsgdcBase
        TabOrder = 12
      end
      object dbePassportIssCity: TDBEdit
        Left = 3
        Top = 264
        Width = 104
        Height = 21
        DataField = 'PASSPORTISSCITY'
        DataSource = dsgdcBase
        TabOrder = 13
      end
      object dbePersonalNumber: TDBEdit
        Left = 114
        Top = 264
        Width = 104
        Height = 21
        DataField = 'personalnumber'
        DataSource = dsgdcBase
        TabOrder = 14
      end
      object dbCouple: TDBEdit
        Left = 3
        Top = 171
        Width = 104
        Height = 21
        DataField = 'SPOUSE'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object dbeChildren: TDBEdit
        Left = 114
        Top = 171
        Width = 104
        Height = 21
        DataField = 'CHILDREN'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object xdbeBIRTHDAY: TxDateDBEdit
        Left = 335
        Top = 171
        Width = 104
        Height = 21
        DataField = 'BIRTHDAY'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 8
      end
      object gsiblkupPosition: TgsIBLookupComboBox
        Left = 224
        Top = 112
        Width = 215
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'WPOSITIONKEY'
        ListTable = 'WG_POSITION'
        ListField = 'NAME'
        KeyField = 'ID'
        SortOrder = soAsc
        gdClassName = 'TgdcWgPosition'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object DBRadioGroup1: TDBRadioGroup
        Left = 224
        Top = 158
        Width = 104
        Height = 35
        Caption = ' Пол '
        Columns = 2
        DataField = 'SEX'
        DataSource = dsgdcBase
        Items.Strings = (
          'М'
          'Ж')
        TabOrder = 7
        Values.Strings = (
          'M'
          'F')
      end
      object xdbePassportExpDate: TxDateDBEdit
        Left = 114
        Top = 227
        Width = 104
        Height = 21
        DataField = 'PASSPORTEXPDATE'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 10
      end
      object xdbePassportIssDate: TxDateDBEdit
        Left = 223
        Top = 227
        Width = 104
        Height = 21
        DataField = 'PASSPORTISSDATE'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 11
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 445
        Height = 303
      end
    end
  end
  object btnMakeEmployee: TButton [6]
    Left = 235
    Top = 344
    Width = 68
    Height = 21
    Action = actMakeEmployee
    TabOrder = 6
  end
  inherited alBase: TActionList
    Left = 251
    Top = 323
    object actMakeEmployee: TAction
      Caption = 'Сотрудник'
      OnExecute = actMakeEmployeeExecute
      OnUpdate = actMakeEmployeeUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 197
    Top = 291
  end
  inherited pm_dlgG: TPopupMenu
    Left = 296
    Top = 312
  end
  inherited ibtrCommon: TIBTransaction
    Left = 240
    Top = 280
  end
end
