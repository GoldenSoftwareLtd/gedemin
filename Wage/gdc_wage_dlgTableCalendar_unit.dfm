inherited gdc_wage_dlgTableCalendar: Tgdc_wage_dlgTableCalendar
  Left = 306
  Top = 159
  Caption = 'График рабочего времени'
  ClientHeight = 342
  ClientWidth = 485
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 404
    Top = 93
  end
  inherited btnNew: TButton
    Left = 404
    Top = 125
  end
  inherited btnOK: TButton
    Left = 405
    Top = 29
  end
  inherited btnCancel: TButton
    Left = 405
    Top = 61
  end
  inherited btnHelp: TButton
    Left = 404
    Top = 157
  end
  inherited pgcMain: TPageControl
    Width = 389
    Height = 331
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Width = 83
      end
      object Label1: TLabel
        Left = 8
        Top = 32
        Width = 79
        Height = 13
        Caption = 'Наименование:'
      end
      object dbedName: TDBEdit
        Left = 96
        Top = 27
        Width = 273
        Height = 21
        DataField = 'name'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object GroupBox1: TGroupBox
        Left = 6
        Top = 224
        Width = 363
        Height = 73
        Caption = ' Формирование '
        TabOrder = 1
        object Label2: TLabel
          Left = 16
          Top = 49
          Width = 41
          Height = 13
          Caption = 'Период:'
        end
        object Label13: TLabel
          Left = 150
          Top = 49
          Width = 3
          Height = 13
          Caption = '-'
        end
        object cbHolidayIsWork: TDBCheckBox
          Left = 16
          Top = 17
          Width = 233
          Height = 17
          Caption = 'Учитывать государственные праздники'
          DataField = 'HOLIDAYISWORK'
          DataSource = dsgdcBase
          TabOrder = 0
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
        object Button1: TButton
          Left = 248
          Top = 45
          Width = 89
          Height = 21
          Action = actCalcSchedule
          TabOrder = 3
        end
        object xdeDB: TxDateEdit
          Left = 80
          Top = 45
          Width = 65
          Height = 21
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 1
          Text = '09.10.2002'
        end
        object xdeDE: TxDateEdit
          Left = 160
          Top = 45
          Width = 65
          Height = 21
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 2
          Text = '09.10.2002'
        end
      end
      object tc: TTabControl
        Left = 7
        Top = 59
        Width = 362
        Height = 153
        TabOrder = 2
        Tabs.Strings = (
          'Пн'
          'Вт'
          'Ср'
          'Чт'
          'Пт'
          'Сб'
          'Вс'
          'Перед пр')
        TabIndex = 0
        OnChange = tcChange
        OnChanging = tcChanging
        object Label3: TLabel
          Left = 9
          Top = 53
          Width = 40
          Height = 13
          Caption = 'Начало:'
        end
        object Label4: TLabel
          Left = 148
          Top = 53
          Width = 58
          Height = 13
          Caption = 'Окончание:'
        end
        object Label5: TLabel
          Left = 9
          Top = 77
          Width = 40
          Height = 13
          Caption = 'Начало:'
        end
        object Label6: TLabel
          Left = 148
          Top = 77
          Width = 58
          Height = 13
          Caption = 'Окончание:'
        end
        object Label7: TLabel
          Left = 9
          Top = 102
          Width = 40
          Height = 13
          Caption = 'Начало:'
        end
        object Label8: TLabel
          Left = 148
          Top = 102
          Width = 58
          Height = 13
          Caption = 'Окончание:'
        end
        object Label9: TLabel
          Left = 9
          Top = 126
          Width = 40
          Height = 13
          Caption = 'Начало:'
        end
        object Label10: TLabel
          Left = 148
          Top = 126
          Width = 58
          Height = 13
          Caption = 'Окончание:'
        end
        object Label11: TLabel
          Left = 148
          Top = 29
          Width = 57
          Height = 13
          Caption = 'Смещение:'
        end
        object chbxWD: TDBCheckBox
          Left = 9
          Top = 26
          Width = 97
          Height = 17
          Caption = 'Рабочий день'
          DataField = 'mon'
          DataSource = dsgdcBase
          TabOrder = 0
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
        object xdeE3: TxDateDBEdit
          Left = 225
          Top = 99
          Width = 57
          Height = 21
          DataField = 'w1_end3'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 7
        end
        object xdeE2: TxDateDBEdit
          Left = 225
          Top = 74
          Width = 57
          Height = 21
          DataField = 'w1_end2'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 5
        end
        object xdeE4: TxDateDBEdit
          Left = 225
          Top = 124
          Width = 57
          Height = 21
          DataField = 'w1_end4'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 9
        end
        object xdeE1: TxDateDBEdit
          Left = 225
          Top = 49
          Width = 57
          Height = 21
          DataField = 'w1_end1'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 3
        end
        object xdeB2: TxDateDBEdit
          Left = 67
          Top = 74
          Width = 57
          Height = 21
          DataField = 'w1_start2'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 4
        end
        object xdeB3: TxDateDBEdit
          Left = 67
          Top = 99
          Width = 57
          Height = 21
          DataField = 'w1_start3'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 6
        end
        object xdeB4: TxDateDBEdit
          Left = 67
          Top = 124
          Width = 57
          Height = 21
          DataField = 'w1_start4'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 8
        end
        object xdeB1: TxDateDBEdit
          Left = 66
          Top = 48
          Width = 57
          Height = 21
          DataField = 'w1_start1'
          DataSource = dsgdcBase
          Kind = kTime
          EditMask = '!99\:99\:99;1;_'
          MaxLength = 8
          TabOrder = 2
        end
        object xdeOffset: TDBEdit
          Left = 225
          Top = 24
          Width = 57
          Height = 21
          DataField = 'w1_offset'
          DataSource = dsgdcBase
          TabOrder = 1
        end
      end
    end
    object TabSheet1: TTabSheet [1]
      Caption = 'Дни'
      ImageIndex = 2
      object ibgrTblCalDay: TgsIBGrid
        Left = 0
        Top = 0
        Width = 381
        Height = 303
        HelpContext = 3
        Align = alClient
        DataSource = dsTableCalendarDay
        TabOrder = 0
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
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 381
        Height = 303
      end
    end
  end
  inherited alBase: TActionList
    Left = 350
    Top = 15
    object actCalcSchedule: TAction
      Caption = 'Сформировать'
      OnExecute = actCalcScheduleExecute
      OnUpdate = actCalcScheduleUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 320
    Top = 15
  end
  inherited pm_dlgG: TPopupMenu
    Left = 392
    Top = 16
  end
  inherited ibtrCommon: TIBTransaction
    Left = 400
  end
  object dsTableCalendarDay: TDataSource
    DataSet = gdcTableCalendarDay
    Left = 432
    Top = 264
  end
  object gdcTableCalendarDay: TgdcTableCalendarDay
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'tblcalkey'
    SubSet = 'ByTableCalendar'
    Left = 200
    Top = 126
  end
end
