inherited gdc_dlgCustomCompany: Tgdc_dlgCustomCompany
  Left = 443
  Top = 221
  HelpContext = 38
  BorderIcons = [biSystemMenu]
  Caption = 'BaseContact'
  ClientHeight = 366
  ClientWidth = 495
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 340
  end
  inherited btnNew: TButton
    Left = 76
    Top = 340
  end
  inherited btnHelp: TButton
    Left = 148
    Top = 340
  end
  inherited btnOK: TButton
    Left = 349
    Top = 340
  end
  inherited btnCancel: TButton
    Left = 421
    Top = 340
  end
  inherited pgcMain: TPageControl
    Top = 4
    Width = 485
    Height = 329
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 6
        Width = 19
        Caption = 'ИД:'
      end
      inherited dbtxtID: TDBText
        Left = 74
      end
      object Label8: TLabel
        Left = 6
        Top = 32
        Width = 52
        Height = 13
        Caption = 'Название:'
        FocusControl = dbeName
      end
      object Label4: TLabel
        Left = 320
        Top = 104
        Width = 22
        Height = 13
        Caption = 'Тип:'
      end
      object Label6: TLabel
        Left = 6
        Top = 56
        Width = 67
        Height = 13
        Caption = 'Полное назв:'
      end
      object Label66: TLabel
        Left = 6
        Top = 80
        Width = 48
        Height = 13
        Caption = 'Телефон:'
        FocusControl = dbePhone
      end
      object Label67: TLabel
        Left = 320
        Top = 80
        Width = 29
        Height = 13
        Caption = 'Факс:'
        FocusControl = dbeFax
      end
      object Label5: TLabel
        Left = 320
        Top = 32
        Width = 25
        Height = 13
        Caption = 'УНП:'
      end
      object Label63: TLabel
        Left = 6
        Top = 104
        Width = 35
        Height = 13
        Caption = 'Папка:'
        FocusControl = gsibluFolder
      end
      object Label16: TLabel
        Left = 320
        Top = 56
        Width = 43
        Height = 13
        Caption = 'ОКЮЛП:'
      end
      object btnSaveRec: TButton
        Left = 74
        Top = 208
        Width = 159
        Height = 21
        Action = actApply
        Caption = 'Банковские реквизиты...'
        TabOrder = 9
      end
      object pnAccount: TPanel
        Left = 1
        Top = 127
        Width = 473
        Height = 152
        BevelOuter = bvNone
        TabOrder = 7
        object Label23: TLabel
          Left = 6
          Top = 37
          Width = 95
          Height = 13
          Caption = 'Банковские счета:'
        end
        object Bevel2: TBevel
          Left = 102
          Top = 44
          Width = 265
          Height = 3
          Shape = bsTopLine
        end
        object Label29: TLabel
          Left = 6
          Top = 1
          Width = 74
          Height = 13
          Caption = 'Главный счет:'
        end
        object Bevel1: TBevel
          Left = 83
          Top = 8
          Width = 383
          Height = 3
          Shape = bsTopLine
        end
        object btnNewBank: TButton
          Left = 375
          Top = 45
          Width = 93
          Height = 21
          Action = actAddAccount
          TabOrder = 2
        end
        object btnEditBank: TButton
          Left = 375
          Top = 66
          Width = 93
          Height = 21
          Action = actEditAccount
          TabOrder = 3
        end
        object btnDeleteBank: TButton
          Left = 375
          Top = 87
          Width = 93
          Height = 21
          Action = actDelAccount
          TabOrder = 4
        end
        object dbgAccount: TgsIBGrid
          Left = 5
          Top = 52
          Width = 363
          Height = 97
          HelpContext = 3
          DataSource = dsAccount
          Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 1
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          TitlesExpanding = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
          ShowTotals = False
        end
        object btnRefreshBank: TButton
          Left = 375
          Top = 108
          Width = 93
          Height = 21
          Action = actRefreshBank
          TabOrder = 5
        end
        object gsiblkupMainAccount: TgsIBLookupComboBox
          Left = 74
          Top = 16
          Width = 241
          Height = 21
          HelpContext = 1
          DataSource = dsgdcBase
          DataField = 'companyaccountkey'
          ListTable = 'gd_companyaccount'
          ListField = 'account'
          KeyField = 'ID'
          gdClassName = 'TgdcAccount'
          OnCreateNewObject = gsiblkupMainAccountCreateNewObject
          StrictOnExit = False
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object btnAccRed: TButton
          Left = 375
          Top = 129
          Width = 93
          Height = 21
          Action = actAccountReduction
          TabOrder = 6
        end
      end
      object dbeName: TDBEdit
        Left = 74
        Top = 26
        Width = 241
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
        OnExit = dbeNameExit
      end
      object dbcbCompanyType: TDBComboBox
        Left = 365
        Top = 101
        Width = 107
        Height = 21
        DataField = 'COMPANYTYPE'
        DataSource = dsgdcBase
        ItemHeight = 13
        Items.Strings = (
          'АО'
          'ГП'
          'ЗАО'
          'ИП'
          'к-з'
          'МП'
          'ОДО'
          'ООО'
          'с-з'
          'СП'
          'УП'
          'ЧП')
        Sorted = True
        TabOrder = 6
      end
      object dbeFullName: TDBEdit
        Left = 74
        Top = 51
        Width = 241
        Height = 21
        DataField = 'FULLNAME'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbePhone: TDBEdit
        Left = 74
        Top = 76
        Width = 241
        Height = 21
        DataField = 'PHONE'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbeFax: TDBEdit
        Left = 365
        Top = 76
        Width = 106
        Height = 21
        DataField = 'FAX'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object dbeTaxid: TDBEdit
        Left = 365
        Top = 26
        Width = 106
        Height = 21
        DataField = 'TAXID'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object gsibluFolder: TgsIBLookupComboBox
        Left = 74
        Top = 101
        Width = 241
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
        TabOrder = 5
      end
      object dbcbDisabled: TDBCheckBox
        Left = 6
        Top = 280
        Width = 172
        Height = 17
        Caption = 'Организация не активна'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 8
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbeOkulp: TDBEdit
        Left = 365
        Top = 51
        Width = 106
        Height = 21
        DataField = 'OKULP'
        TabOrder = 10
      end
    end
    object TabSheet3: TTabSheet [1]
      Caption = 'Адрес'
      ImageIndex = 2
      object Label7: TLabel
        Left = 121
        Top = 177
        Width = 21
        Height = 13
        Caption = 'П/я:'
      end
      object Label10: TLabel
        Left = 2
        Top = 177
        Width = 41
        Height = 13
        Caption = 'Индекс:'
      end
      object Label9: TLabel
        Left = 2
        Top = 6
        Width = 228
        Height = 13
        Caption = 'Страна, область, район, город (нас пункт.):'
      end
      object Label1: TLabel
        Left = 2
        Top = 48
        Width = 41
        Height = 13
        Caption = 'Страна:'
      end
      object Label2: TLabel
        Left = 121
        Top = 48
        Width = 110
        Height = 13
        Caption = 'Область/республика:'
      end
      object Label3: TLabel
        Left = 2
        Top = 88
        Width = 34
        Height = 13
        Caption = 'Район:'
      end
      object Label13: TLabel
        Left = 121
        Top = 88
        Width = 93
        Height = 13
        Caption = 'Город/нас. пункт:'
      end
      object Label31: TLabel
        Left = 2
        Top = 127
        Width = 35
        Height = 13
        Caption = 'Адрес:'
      end
      object Label11: TLabel
        Left = 2
        Top = 214
        Width = 28
        Height = 13
        Caption = 'email:'
      end
      object Label17: TLabel
        Left = 121
        Top = 214
        Width = 32
        Height = 13
        Caption = 'http://'
      end
      object Bevel3: TBevel
        Left = 239
        Top = 9
        Width = 5
        Height = 290
        Shape = bsLeftLine
      end
      object Label19: TLabel
        Left = 247
        Top = 6
        Width = 40
        Height = 13
        Caption = 'СОАТО:'
      end
      object Label18: TLabel
        Left = 360
        Top = 6
        Width = 40
        Height = 13
        Caption = 'ОКОНХ:'
      end
      object Label27: TLabel
        Left = 245
        Top = 128
        Width = 52
        Height = 13
        Caption = 'Лицензия:'
      end
      object Label22: TLabel
        Left = 245
        Top = 88
        Width = 58
        Height = 13
        Caption = 'Рег. номер:'
      end
      object Label20: TLabel
        Left = 360
        Top = 48
        Width = 34
        Height = 13
        Caption = 'СООУ:'
      end
      object Label12: TLabel
        Left = 245
        Top = 167
        Width = 71
        Height = 13
        Caption = 'Комментарий:'
      end
      object Label21: TLabel
        Left = 245
        Top = 262
        Width = 122
        Height = 13
        Caption = 'Головное предприятие:'
      end
      object Label14: TLabel
        Left = 2
        Top = 256
        Width = 54
        Height = 13
        Caption = 'Директор:'
      end
      object Label15: TLabel
        Left = 2
        Top = 280
        Width = 50
        Height = 13
        Caption = 'Гл. бухг.:'
      end
      object Label28: TLabel
        Left = 247
        Top = 48
        Width = 34
        Height = 13
        Caption = 'ОКПО:'
      end
      object dbePbox: TDBEdit
        Left = 121
        Top = 193
        Width = 114
        Height = 21
        DataField = 'POBOX'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object dbeZIP: TDBEdit
        Left = 2
        Top = 193
        Width = 114
        Height = 21
        DataField = 'ZIP'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object dbmAddress: TDBMemo
        Left = 2
        Top = 143
        Width = 234
        Height = 33
        DataField = 'ADDRESS'
        DataSource = dsgdcBase
        ScrollBars = ssVertical
        TabOrder = 5
      end
      object gsiblkupAddress: TgsIBLookupComboBox
        Left = 2
        Top = 24
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
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object DBEdit1: TDBEdit
        Left = 2
        Top = 64
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'country'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 1
      end
      object DBEdit2: TDBEdit
        Left = 121
        Top = 64
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'region'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 2
      end
      object DBEdit3: TDBEdit
        Left = 2
        Top = 104
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'district'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 3
      end
      object DBEdit4: TDBEdit
        Left = 121
        Top = 104
        Width = 114
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'city'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 4
      end
      object dbeEmail: TDBEdit
        Left = 2
        Top = 229
        Width = 114
        Height = 21
        DataField = 'EMAIL'
        DataSource = dsgdcBase
        TabOrder = 8
      end
      object dbedWWW: TDBEdit
        Left = 121
        Top = 229
        Width = 114
        Height = 21
        DataField = 'URL'
        DataSource = dsgdcBase
        TabOrder = 9
      end
      object dbeSOATO: TDBEdit
        Left = 244
        Top = 24
        Width = 114
        Height = 21
        DataField = 'SOATO'
        DataSource = dsgdcBase
        TabOrder = 12
      end
      object dbeOKNH: TDBEdit
        Left = 361
        Top = 24
        Width = 114
        Height = 21
        DataField = 'OKNH'
        DataSource = dsgdcBase
        TabOrder = 13
      end
      object dbeLICENCE: TDBEdit
        Left = 244
        Top = 144
        Width = 231
        Height = 21
        DataField = 'LICENCE'
        DataSource = dsgdcBase
        TabOrder = 16
      end
      object dbeLegalNummer: TDBEdit
        Left = 244
        Top = 104
        Width = 231
        Height = 21
        DataField = 'LEGALNUMBER'
        DataSource = dsgdcBase
        TabOrder = 14
      end
      object dbeSOOU: TDBEdit
        Left = 361
        Top = 64
        Width = 114
        Height = 21
        DataField = 'SOOU'
        DataSource = dsgdcBase
        TabOrder = 15
      end
      object dbmNote: TDBMemo
        Left = 244
        Top = 184
        Width = 230
        Height = 75
        DataField = 'NOTE'
        DataSource = dsgdcBase
        TabOrder = 17
      end
      object gsIBlcHeadCompany: TgsIBLookupComboBox
        Left = 244
        Top = 279
        Width = 231
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'HEADCOMPANY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'contacttype=3'
        gdClassName = 'TgdcCompany'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 18
      end
      object gsiblkupChiefAccountant: TgsIBLookupComboBox
        Left = 64
        Top = 279
        Width = 171
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'chiefaccountantkey'
        ListTable = 
          'gd_contact c JOIN gd_contact cc ON cc.lb <= c.lb AND cc.rb >= c.' +
          'rb'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'c.contacttype=2 AND cc.id = :cc_id'
        gdClassName = 'TgdcEmployee'
        OnCreateNewObject = gsiblkupDirectorCreateNewObject
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 11
      end
      object gsiblkupDirector: TgsIBLookupComboBox
        Left = 64
        Top = 255
        Width = 171
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'directorkey'
        ListTable = 
          'gd_contact c JOIN gd_contact cc ON cc.lb <= c.lb AND cc.rb >= c.' +
          'rb'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'c.contacttype=2 AND cc.id = :cc_id'
        gdClassName = 'TgdcEmployee'
        OnCreateNewObject = gsiblkupDirectorCreateNewObject
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 10
      end
      object dbeOKPO: TDBEdit
        Left = 244
        Top = 64
        Width = 114
        Height = 21
        DataField = 'OKPO'
        DataSource = dsgdcBase
        TabOrder = 19
      end
    end
    object tbsLogo: TTabSheet [2]
      Caption = 'Логотип'
      ImageIndex = 3
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        Width = 477
        Height = 22
        Align = alTop
        Caption = 'TBToolbar1'
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object TBItem1: TTBItem
          Action = actLoadPicture
        end
        object TBItem2: TTBItem
          Action = actSavePicture
        end
        object TBItem3: TTBItem
          Action = actDeletePicture
        end
      end
      object JvDBImage: TJvDBImage
        Left = 0
        Top = 22
        Width = 477
        Height = 279
        Align = alClient
        DataField = 'LOGO'
        DataSource = dsgdcBase
        TabOrder = 1
        Proportional = True
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 477
        Height = 301
      end
    end
  end
  inherited alBase: TActionList
    Left = 159
    Top = 206
    object actAddAccount: TAction [8]
      Caption = 'Добавить...'
      OnExecute = actAddAccountExecute
    end
    object actEditAccount: TAction [9]
      Caption = 'Изменить...'
      OnExecute = actEditAccountExecute
      OnUpdate = actEditAccountUpdate
    end
    object actDelAccount: TAction [10]
      Caption = 'Удалить'
      OnExecute = actDelAccountExecute
      OnUpdate = actDelAccountUpdate
    end
    object actAddSubDepartment: TAction [11]
      Caption = 'Добавить подуровень'
      Hint = 'Добавить подуровень'
      ImageIndex = 0
    end
    object actAccountReduction: TAction [12]
      Caption = 'Объединить...'
      OnExecute = actAccountReductionExecute
      OnUpdate = actAccountReductionUpdate
    end
    object actRefreshBank: TAction
      Caption = 'Обновить'
      OnExecute = actRefreshBankExecute
      OnUpdate = actRefreshBankUpdate
    end
    object actLoadPicture: TAction
      Caption = 'Загрузить'
      Hint = 'Загрузить'
      ImageIndex = 132
      OnExecute = actLoadPictureExecute
    end
    object actSavePicture: TAction
      Caption = 'Сохранить'
      Hint = 'Сохранить'
      ImageIndex = 25
      OnExecute = actSavePictureExecute
      OnUpdate = actSavePictureUpdate
    end
    object actDeletePicture: TAction
      Caption = 'Удалить'
      Hint = 'Удалить'
      ImageIndex = 2
      OnExecute = actDeletePictureExecute
      OnUpdate = actDeletePictureUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 273
    Top = 262
  end
  inherited pm_dlgG: TPopupMenu
    Left = 328
    Top = 296
  end
  inherited ibtrCommon: TIBTransaction
    Left = 400
    Top = 184
  end
  object gdcAccount: TgdcAccount
    MasterField = 'id'
    DetailField = 'companykey'
    SubSet = 'ByCompany'
    BeforeShowDialog = gdcAccountBeforeShowDialog
    Left = 147
    Top = 118
  end
  object dsAccount: TDataSource
    DataSet = gdcAccount
    Left = 109
    Top = 118
  end
end
