inherited gdc_dlgUser: Tgdc_dlgUser
  Left = 578
  Top = 215
  HelpContext = 55
  Caption = 'Параметры пользователя'
  ClientHeight = 352
  ClientWidth = 470
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 393
    Top = 166
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
  end
  inherited btnNew: TButton
    Left = 393
    Top = 107
    ParentShowHint = False
    ShowHint = True
  end
  inherited btnOK: TButton
    Left = 393
    Top = 6
    ParentShowHint = False
    ShowHint = True
  end
  inherited btnCancel: TButton
    Left = 393
    Top = 35
    ParentShowHint = False
    ShowHint = True
  end
  inherited btnHelp: TButton
    Left = 393
    Top = 195
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
  end
  object btnGroup: TButton [5]
    Left = 393
    Top = 77
    Width = 68
    Height = 21
    Action = actGroups
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object Button1: TButton [6]
    Left = 393
    Top = 136
    Width = 68
    Height = 21
    Action = actCopySettings
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
  inherited pgcMain: TPageControl
    Left = 6
    Width = 380
    Height = 340
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 11
      end
      inherited dbtxtID: TDBText
        Left = 112
      end
      object lblInfo: TLabel
        Left = 10
        Top = 32
        Width = 97
        Height = 13
        Caption = 'Имя пользователя:'
      end
      object Label1: TLabel
        Left = 10
        Top = 56
        Width = 62
        Height = 13
        Caption = 'Полное имя:'
      end
      object Label2: TLabel
        Left = 10
        Top = 105
        Width = 53
        Height = 13
        Caption = 'Описание:'
      end
      object Label3: TLabel
        Left = 10
        Top = 129
        Width = 82
        Height = 13
        Caption = 'Начало работы:'
      end
      object Label4: TLabel
        Left = 213
        Top = 129
        Width = 76
        Height = 13
        Caption = 'Конец работы:'
      end
      object lblExpDate: TLabel
        Left = 10
        Top = 222
        Width = 282
        Height = 13
        Caption = 'Дата истечения срока действия пароля пользователя:'
        Enabled = False
      end
      object Label6: TLabel
        Left = 10
        Top = 80
        Width = 41
        Height = 13
        Caption = 'Пароль:'
      end
      object Label7: TLabel
        Left = 199
        Top = 81
        Width = 87
        Height = 13
        Caption = 'Подтверждение:'
        WordWrap = True
      end
      object Label8: TLabel
        Left = 10
        Top = 154
        Width = 47
        Height = 13
        Caption = 'Контакт:'
      end
      object Label9: TLabel
        Left = 10
        Top = 178
        Width = 93
        Height = 13
        Caption = 'Рабочий телефон:'
      end
      object dbeName: TDBEdit
        Left = 112
        Top = 29
        Width = 257
        Height = 21
        Ctl3D = True
        DataField = 'NAME'
        DataSource = dsgdcBase
        ParentCtl3D = False
        TabOrder = 0
      end
      object dbeFullName: TDBEdit
        Left = 112
        Top = 53
        Width = 257
        Height = 21
        Ctl3D = True
        DataField = 'FULLNAME'
        DataSource = dsgdcBase
        ParentCtl3D = False
        TabOrder = 1
      end
      object dbmDescription: TDBMemo
        Left = 112
        Top = 101
        Width = 257
        Height = 21
        Ctl3D = True
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        ParentCtl3D = False
        TabOrder = 4
      end
      object edPasswordConfirmation: TEdit
        Left = 284
        Top = 77
        Width = 85
        Height = 21
        Color = 11141119
        Ctl3D = True
        ParentCtl3D = False
        PasswordChar = '*'
        TabOrder = 3
      end
      object cbNeverExp: TDBCheckBox
        Left = 10
        Top = 200
        Width = 270
        Height = 17
        Caption = 'Срок действия пароля никогда не истекает'
        DataField = 'PASSWNEVEREXP'
        DataSource = dsgdcBase
        TabOrder = 9
        ValueChecked = '1'
        ValueUnchecked = '0'
        OnClick = mmcbNeverExpClick
      end
      object cbCantChange: TDBCheckBox
        Left = 10
        Top = 242
        Width = 247
        Height = 17
        Caption = 'Пользователь не может менять пароль'
        DataField = 'CANTCHANGEPASSW'
        DataSource = dsgdcBase
        TabOrder = 11
        ValueChecked = '1'
        ValueUnchecked = '0'
        OnClick = cbCantChangeClick
      end
      object cbMustChange: TDBCheckBox
        Left = 10
        Top = 259
        Width = 294
        Height = 17
        Caption = 'При входе пользователь должен изменить пароль'
        DataField = 'MUSTCHANGE'
        DataSource = dsgdcBase
        TabOrder = 12
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object cbDisabled: TDBCheckBox
        Left = 10
        Top = 277
        Width = 159
        Height = 17
        Caption = 'Пользователь отключен'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 13
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object gsiblcContact: TgsIBLookupComboBox
        Left = 112
        Top = 150
        Width = 257
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'CONTACTKEY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        Condition = 'contacttype=2'
        gdClassName = 'TgdcContact'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
      end
      object cbAllowAudit: TDBCheckBox
        Left = 10
        Top = 294
        Width = 271
        Height = 17
        Caption = 'Регистрировать операции пользователя'
        DataField = 'ALLOWAUDIT'
        DataSource = dsgdcBase
        TabOrder = 14
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbePassword: TDBEdit
        Left = 112
        Top = 77
        Width = 85
        Height = 21
        Ctl3D = True
        DataField = 'PASSW'
        DataSource = dsgdcBase
        ParentCtl3D = False
        PasswordChar = '*'
        TabOrder = 2
      end
      object dbePhone: TDBEdit
        Left = 112
        Top = 174
        Width = 257
        Height = 21
        Ctl3D = True
        DataField = 'PHONE'
        DataSource = dsgdcBase
        ParentCtl3D = False
        TabOrder = 8
      end
      object dbeStartWork: TxDateDBEdit
        Left = 112
        Top = 125
        Width = 77
        Height = 21
        DataField = 'WORKSTART'
        DataSource = dsgdcBase
        Kind = kTime
        EmptyAtStart = True
        EditMask = '!99\:99\:99;1;_'
        MaxLength = 8
        TabOrder = 5
      end
      object dbeEndWork: TxDateDBEdit
        Left = 292
        Top = 125
        Width = 77
        Height = 21
        DataField = 'WORKEND'
        DataSource = dsgdcBase
        Kind = kTime
        EmptyAtStart = True
        EditMask = '!99\:99\:99;1;_'
        MaxLength = 8
        TabOrder = 6
      end
      object dbeExpDate: TxDateDBEdit
        Left = 292
        Top = 219
        Width = 77
        Height = 21
        DataField = 'EXPDATE'
        DataSource = dsgdcBase
        Kind = kDate
        EmptyAtStart = True
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 10
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 372
        Height = 312
      end
    end
    object pgcErrors: TTabSheet
      Caption = 'Ошибки'
      ImageIndex = 2
      object cbSaveErrorLog: TCheckBox
        Left = 6
        Top = 10
        Width = 273
        Height = 17
        Caption = 'Сохранять информацию об ошибках в файл'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbSaveErrorLogClick
      end
      object pnlErrLog: TPanel
        Left = 5
        Top = 32
        Width = 361
        Height = 73
        BevelOuter = bvLowered
        TabOrder = 1
        object Label5: TLabel
          Left = 8
          Top = 12
          Width = 169
          Height = 13
          Caption = 'Имя файла в каталоге Гедемина:'
        end
        object spErrorLines: TSpinEdit
          Left = 184
          Top = 40
          Width = 121
          Height = 22
          MaxLength = 5
          MaxValue = 20000
          MinValue = 100
          TabOrder = 0
          Value = 500
        end
        object cbLimitLines: TCheckBox
          Left = 8
          Top = 37
          Width = 174
          Height = 17
          Caption = 'Ограничить количество строк'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = cbLimitLinesClick
        end
        object cbErrorLogFile: TComboBox
          Left = 184
          Top = 13
          Width = 161
          Height = 21
          Hint = 
            'Имя *.log в каталоге Гедемин, в который должна сохраняться инфор' +
            'мация об ошибках в скрипт-функциях.'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          Sorted = True
          TabOrder = 2
          Text = 'ErrScript'
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 438
    Top = 279
    object actGroups: TAction
      Caption = 'Группы...'
      OnExecute = actGroupsExecute
    end
    object actCopySettings: TAction
      Caption = 'Профиль'
      Hint = 'Скопировать профиль'
      OnExecute = actCopySettingsExecute
      OnUpdate = actCopySettingsUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 408
    Top = 279
  end
  inherited ibtrCommon: TIBTransaction
    Left = 328
    Top = 200
  end
end
