inherited gdc_dlgDepartment: Tgdc_dlgDepartment
  Left = 859
  Top = 392
  HelpContext = 36
  Caption = 'Подразделение'
  ClientHeight = 347
  ClientWidth = 507
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 319
  end
  inherited btnNew: TButton
    Top = 319
  end
  inherited btnHelp: TButton
    Left = 150
    Top = 319
  end
  inherited btnOK: TButton
    Left = 362
    Top = 319
  end
  inherited btnCancel: TButton
    Left = 435
    Top = 319
  end
  inherited pgcMain: TPageControl
    Width = 499
    Height = 305
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 6
        Top = 4
      end
      inherited dbtxtID: TDBText
        Left = 94
        Top = 4
      end
      object Label1: TLabel
        Left = 6
        Top = 24
        Width = 77
        Height = 13
        Caption = 'Наименование:'
        FocusControl = dbedName
      end
      object Label2: TLabel
        Left = 6
        Top = 66
        Width = 125
        Height = 13
        Caption = 'Принадлежит компании:'
        FocusControl = iblkupCompany
      end
      object Label3: TLabel
        Left = 6
        Top = 106
        Width = 132
        Height = 13
        Caption = 'Входит в подразделение:'
      end
      object Label9: TLabel
        Left = 250
        Top = 24
        Width = 228
        Height = 13
        Caption = 'Страна, область, район, город (нас пункт.):'
      end
      object Label4: TLabel
        Left = 250
        Top = 106
        Width = 41
        Height = 13
        Caption = 'Страна:'
      end
      object Label13: TLabel
        Left = 371
        Top = 146
        Width = 93
        Height = 13
        Caption = 'Город/нас. пункт:'
      end
      object Label5: TLabel
        Left = 250
        Top = 146
        Width = 34
        Height = 13
        Caption = 'Район:'
      end
      object Label6: TLabel
        Left = 371
        Top = 106
        Width = 110
        Height = 13
        Caption = 'Область/республика:'
      end
      object Label31: TLabel
        Left = 250
        Top = 66
        Width = 35
        Height = 13
        Caption = 'Адрес:'
      end
      object Label10: TLabel
        Left = 250
        Top = 186
        Width = 41
        Height = 13
        Caption = 'Индекс:'
      end
      object Label7: TLabel
        Left = 371
        Top = 186
        Width = 21
        Height = 13
        Caption = 'П/я:'
      end
      object Label11: TLabel
        Left = 6
        Top = 185
        Width = 28
        Height = 13
        Caption = 'email:'
      end
      object Label17: TLabel
        Left = 124
        Top = 186
        Width = 32
        Height = 13
        Caption = 'http://'
      end
      object Label66: TLabel
        Left = 6
        Top = 146
        Width = 48
        Height = 13
        Caption = 'Телефон:'
      end
      object Label67: TLabel
        Left = 124
        Top = 146
        Width = 29
        Height = 13
        Caption = 'Факс:'
      end
      object Label8: TLabel
        Left = 8
        Top = 231
        Width = 68
        Height = 13
        Hint = 'Широта -90..+90, Долгота -180..+180'
        Caption = 'Координаты:'
        ParentShowHint = False
        ShowHint = True
      end
      object dbedName: TDBEdit
        Left = 6
        Top = 42
        Width = 234
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object iblkupCompany: TgsIBLookupComboBox
        Left = 6
        Top = 82
        Width = 234
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'ID'
        Condition = 'contacttype in (3, 5)'
        gdClassName = 'TgdcCompany'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnChange = iblkupCompanyChange
      end
      object iblkupDepartment: TgsIBLookupComboBox
        Left = 6
        Top = 122
        Width = 234
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'ID'
        Condition = 'contacttype=4'
        gdClassName = 'TgdcDepartment'
        OnCreateNewObject = iblkupDepartmentCreateNewObject
        ViewType = vtTree
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object gsiblkupAddress: TgsIBLookupComboBox
        Left = 250
        Top = 42
        Width = 234
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
        TabOrder = 1
      end
      object dbedCountry: TDBEdit
        Left = 250
        Top = 122
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'country'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 5
      end
      object dbedDistrict: TDBEdit
        Left = 250
        Top = 161
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'district'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 9
      end
      object dbedCity: TDBEdit
        Left = 370
        Top = 161
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'city'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 10
      end
      object dbedArea: TDBEdit
        Left = 370
        Top = 122
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'region'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 6
      end
      object dbmAddress: TDBMemo
        Left = 250
        Top = 82
        Width = 234
        Height = 21
        DataField = 'ADDRESS'
        DataSource = dsgdcBase
        ScrollBars = ssVertical
        TabOrder = 3
      end
      object dbeZIP: TDBEdit
        Left = 250
        Top = 199
        Width = 114
        Height = 21
        DataField = 'ZIP'
        DataSource = dsgdcBase
        TabOrder = 13
      end
      object dbePbox: TDBEdit
        Left = 370
        Top = 199
        Width = 114
        Height = 21
        DataField = 'POBOX'
        DataSource = dsgdcBase
        TabOrder = 14
      end
      object dbeEmail: TDBEdit
        Left = 6
        Top = 200
        Width = 114
        Height = 21
        DataField = 'EMAIL'
        DataSource = dsgdcBase
        TabOrder = 11
      end
      object dbedWWW: TDBEdit
        Left = 126
        Top = 200
        Width = 114
        Height = 21
        DataField = 'URL'
        DataSource = dsgdcBase
        TabOrder = 12
      end
      object dbePhone: TDBEdit
        Left = 6
        Top = 161
        Width = 114
        Height = 21
        DataField = 'PHONE'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object dbeFax: TDBEdit
        Left = 126
        Top = 161
        Width = 114
        Height = 21
        DataField = 'FAX'
        DataSource = dsgdcBase
        TabOrder = 8
      end
      object dbcbDisabled: TDBCheckBox
        Left = 6
        Top = 256
        Width = 172
        Height = 17
        Caption = 'Подразделение не активно'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 17
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object edGEOCoord: TEdit
        Left = 126
        Top = 226
        Width = 238
        Height = 21
        Hint = 'Широта -90..+90, Долгота -180..+180'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 15
      end
      object btnShowMap: TButton
        Left = 369
        Top = 225
        Width = 114
        Height = 21
        Action = actShowOnMap
        TabOrder = 16
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 491
        Height = 277
      end
    end
  end
  inherited alBase: TActionList
    Left = 430
    Top = 65535
    object actShowOnMap: TAction
      Caption = 'Показать на карте'
      OnExecute = actShowOnMapExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 336
    Top = 65535
  end
  inherited pm_dlgG: TPopupMenu
    Left = 400
    Top = 0
  end
  inherited ibtrCommon: TIBTransaction
    Left = 368
    Top = 0
  end
end
