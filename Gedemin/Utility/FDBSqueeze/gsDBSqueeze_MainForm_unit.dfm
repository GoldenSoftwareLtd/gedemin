object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 186
  Top = 137
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  ClientHeight = 537
  ClientWidth = 853
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 304
    Top = 292
    Width = 85
    Height = 13
    Caption = 'Backup Directory:'
    Enabled = False
  end
  object pnl1: TPanel
    Left = -12
    Top = 0
    Width = 893
    Height = 538
    TabOrder = 0
    object shp10: TShape
      Left = 56
      Top = 24
      Width = 65
      Height = 65
    end
    object shp15: TShape
      Left = 124
      Top = 329
      Width = 83
      Height = 2
      Brush.Color = clBtnShadow
      Pen.Color = clGrayText
    end
    object shp16: TShape
      Left = 88
      Top = 337
      Width = 127
      Height = 2
      Brush.Color = clBtnShadow
      Pen.Color = clGrayText
    end
    object shp17: TShape
      Left = 48
      Top = 337
      Width = 167
      Height = 2
      Brush.Color = clBtnShadow
      Pen.Color = clGrayText
    end
    object shp18: TShape
      Left = 48
      Top = 531
      Width = 102
      Height = 2
      Brush.Color = clBtnShadow
      Pen.Color = clGrayText
    end
    object shp19: TShape
      Left = 24
      Top = 457
      Width = 225
      Height = 71
      Brush.Color = clBtnShadow
      Pen.Color = clGrayText
    end
    object shp21: TShape
      Left = 84
      Top = 516
      Width = 102
      Height = 11
      Brush.Color = clBtnShadow
      Pen.Color = clGrayText
    end
    object tbcPageController: TTabControl
      Left = 219
      Top = 0
      Width = 441
      Height = 25
      Style = tsFlatButtons
      TabOrder = 0
      Tabs.Strings = (
        'Settings'
        'Logs'
        'Statistics'
        'About')
      TabIndex = 0
      TabStop = False
      TabWidth = 100
      OnChange = tbcPageControllerChange
    end
    object pgcMain: TPageControl
      Left = 1
      Top = 21
      Width = 1212
      Height = 497
      ActivePage = tsSettings
      MultiLine = True
      TabOrder = 1
      TabPosition = tpLeft
      TabWidth = 100
      object tsSettings: TTabSheet
        Caption = 'Settings'
        object pgcSettings: TPageControl
          Left = 112
          Top = 54
          Width = 634
          Height = 369
          ActivePage = tsConnection
          TabOrder = 0
          object tsConnection: TTabSheet
            Caption = 'Database Connection'
            object shp9: TShape
              Left = 13
              Top = 4
              Width = 599
              Height = 43
              Brush.Style = bsClear
              Pen.Color = 12238
              Pen.Width = 3
            end
            object StaticText4: TStaticText
              Left = 562
              Top = 87
              Width = 49
              Height = 20
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              Color = clHighlightText
              ParentColor = False
              TabOrder = 5
            end
            object cbbCharset: TComboBox
              Left = 501
              Top = 262
              Width = 112
              Height = 21
              TabStop = False
              Style = csDropDownList
              DropDownCount = 5
              ItemHeight = 13
              TabOrder = 15
            end
            object StaticText2: TStaticText
              Left = 457
              Top = 262
              Width = 46
              Height = 20
              Alignment = taCenter
              AutoSize = False
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 14
            end
            object sttxtStateTestConnect: TStaticText
              Left = 562
              Top = 90
              Width = 49
              Height = 15
              Alignment = taCenter
              AutoSize = False
              Caption = 'unknown'
              Color = clHighlightText
              ParentColor = False
              TabOrder = 7
            end
            object StaticText3: TStaticText
              Left = 458
              Top = 87
              Width = 105
              Height = 20
              Alignment = taCenter
              AutoSize = False
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 4
            end
            object btnNext1: TButton
              Left = 587
              Top = 318
              Width = 25
              Height = 25
              Action = actNextPage
              Anchors = [akLeft, akTop, akRight]
              Caption = '>'
              TabOrder = 18
              TabStop = False
            end
            object grpDatabase: TGroupBox
              Left = 64
              Top = 62
              Width = 377
              Height = 151
              Caption = ' Database Location  '
              Color = 13822975
              ParentColor = False
              TabOrder = 2
              object lbl4: TLabel
                Left = 28
                Top = 69
                Width = 26
                Height = 13
                Caption = 'Host:'
              end
              object lbl8: TLabel
                Left = 188
                Top = 70
                Width = 24
                Height = 13
                Caption = 'Port:'
              end
              object lbl1: TLabel
                Left = 18
                Top = 110
                Width = 50
                Height = 13
                Caption = 'Database:'
              end
              object rbRemote: TRadioButton
                Left = 218
                Top = 30
                Width = 70
                Height = 17
                Action = actRadioLocation
                Caption = 'Remote'
                TabOrder = 1
              end
              object rbLocale: TRadioButton
                Left = 76
                Top = 30
                Width = 77
                Height = 17
                Action = actRadioLocation
                Caption = 'Locale'
                Checked = True
                TabOrder = 0
                TabStop = True
              end
              object edtHost: TEdit
                Left = 74
                Top = 66
                Width = 93
                Height = 21
                Enabled = False
                TabOrder = 2
              end
              object chkDefaultPort: TCheckBox
                Left = 220
                Top = 69
                Width = 55
                Height = 17
                TabStop = False
                Action = actDefaultPort
                Caption = 'default'
                Checked = True
                State = cbChecked
                TabOrder = 4
              end
              object sePort: TSpinEdit
                Left = 288
                Top = 67
                Width = 63
                Height = 22
                TabStop = False
                Enabled = False
                MaxLength = 5
                MaxValue = 65535
                MinValue = 0
                TabOrder = 3
                Value = 3050
              end
              object edDatabaseName: TEdit
                Left = 74
                Top = 107
                Width = 253
                Height = 21
                Hint = 'Диск:[\Каталог][\Файл] '
                TabOrder = 5
                Text = 'D:\aksGDBASE_2014_04_02.FDB'
              end
              object btnDatabaseBrowse: TButton
                Left = 331
                Top = 107
                Width = 20
                Height = 21
                Action = actDatabaseBrowse
                Caption = '...'
                TabOrder = 6
                TabStop = False
              end
            end
            object grpAuthorization: TGroupBox
              Left = 64
              Top = 224
              Width = 377
              Height = 78
              Caption = ' Authorization '
              Color = 13822975
              ParentColor = False
              TabOrder = 13
              object lbl2: TLabel
                Left = 17
                Top = 38
                Width = 52
                Height = 13
                Caption = 'Username:'
              end
              object lbl3: TLabel
                Left = 188
                Top = 39
                Width = 50
                Height = 13
                Caption = 'Password:'
              end
              object edUserName: TEdit
                Left = 74
                Top = 36
                Width = 94
                Height = 21
                Enabled = False
                TabOrder = 0
              end
              object edPassword: TEdit
                Left = 244
                Top = 37
                Width = 106
                Height = 21
                PasswordChar = '*'
                TabOrder = 1
              end
            end
            object btntTestConnection: TButton
              Left = 456
              Top = 318
              Width = 130
              Height = 25
              Action = actDisconnect
              Caption = 'Test Connect'
              TabOrder = 17
              TabStop = False
            end
            object sttxtActivUserCount: TStaticText
              Left = 561
              Top = 112
              Width = 49
              Height = 17
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              Color = clHighlightText
              ParentColor = False
              TabOrder = 9
              Visible = False
            end
            object sttxtServerName: TStaticText
              Left = 458
              Top = 150
              Width = 152
              Height = 17
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              Color = clHighlightText
              ParentColor = False
              TabOrder = 11
              Visible = False
            end
            object sttxtActivConnects: TStaticText
              Left = 458
              Top = 112
              Width = 104
              Height = 16
              Alignment = taCenter
              AutoSize = False
              Caption = 'Activ Connects'
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 8
              Visible = False
            end
            object sttxtTestConnectState: TStaticText
              Left = 460
              Top = 90
              Width = 100
              Height = 16
              Alignment = taCenter
              AutoSize = False
              Caption = 'Test Connect State'
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 6
            end
            object StaticText1: TStaticText
              Left = 458
              Top = 265
              Width = 43
              Height = 15
              Alignment = taCenter
              AutoSize = False
              Caption = 'Charset'
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 16
            end
            object sttxtTestServer: TStaticText
              Left = 458
              Top = 133
              Width = 152
              Height = 17
              Alignment = taCenter
              AutoSize = False
              Caption = 'Server'
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 10
              Visible = False
            end
            object txt1: TStaticText
              Left = 13
              Top = 3
              Width = 599
              Height = 41
              AutoSize = False
              BiDiMode = bdLeftToRight
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
            object txt7: TStaticText
              Left = 167
              Top = 8
              Width = 257
              Height = 31
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '  Database Connection'
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWhite
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 1
            end
            object txt9: TStaticText
              Left = 64
              Top = 62
              Width = 376
              Height = 19
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '   Database Location  '
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWhite
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 3
            end
            object txt12: TStaticText
              Left = 64
              Top = 224
              Width = 376
              Height = 19
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '   Authorization'
              Color = 12238
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWhite
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 12
            end
          end
          object tsSqueezeSettings: TTabSheet
            Caption = 'Squeeze Settings'
            ImageIndex = 1
            object lbl5: TLabel
              Left = 99
              Top = 69
              Width = 228
              Height = 13
              Caption = 'Удалить записи из gd_document до (строго):'
            end
            object shp14: TShape
              Left = 13
              Top = 4
              Width = 599
              Height = 43
              Brush.Style = bsClear
              Pen.Color = 12238
              Pen.Width = 3
            end
            object dtpClosingDate: TDateTimePicker
              Left = 337
              Top = 66
              Width = 86
              Height = 21
              Hint = 'рассчитать сальдо и удалить документы'
              CalAlignment = dtaLeft
              Date = 41380.5593590046
              Time = 41380.5593590046
              Color = clWhite
              DateFormat = dfShort
              DateMode = dmComboBox
              Kind = dtkDate
              ParseInput = False
              TabOrder = 2
              TabStop = False
            end
            object btnNext2: TButton
              Left = 587
              Top = 318
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 9
              TabStop = False
            end
            object btnBack1: TButton
              Left = 561
              Top = 318
              Width = 25
              Height = 25
              Caption = '<'
              TabOrder = 8
              TabStop = False
              OnClick = actBackPageExecute
            end
            object chk00Account: TCheckBox
              Left = 99
              Top = 322
              Width = 390
              Height = 17
              TabStop = False
              Caption = 
                'Дополнительно отразить бухгалтерское сальдо на счете "00 Остатки' +
                '"'
              TabOrder = 10
              Visible = False
              OnClick = actDefocusExecute
            end
            object btnLoadConfigFile: TButton
              Left = 98
              Top = 271
              Width = 209
              Height = 25
              Caption = 'Загрузить конфигурацию из файла...'
              TabOrder = 7
              TabStop = False
              OnClick = actConfigBrowseExecute
            end
            object chkCalculateSaldo: TCheckBox
              Left = 99
              Top = 101
              Width = 414
              Height = 17
              TabStop = False
              Caption = 
                'Сохранить бухгалтерское и складское сальдо, вычисленное программ' +
                'ой'
              Checked = True
              State = cbChecked
              TabOrder = 3
              OnClick = actDefocusExecute
            end
            object mIgnoreDocTypes: TMemo
              Left = 98
              Top = 196
              Width = 445
              Height = 52
              TabStop = False
              Color = clWhite
              ReadOnly = True
              ScrollBars = ssVertical
              TabOrder = 6
            end
            object tbcDocTypes: TTabControl
              Left = 97
              Top = 168
              Width = 457
              Height = 28
              Style = tsButtons
              TabHeight = 25
              TabOrder = 5
              Tabs.Strings = (
                'Не обрабатывать выбранные типы'
                'Обрабатывать только выбранные')
              TabIndex = 0
              TabStop = False
              TabWidth = 220
              OnChange = actDefocusExecute
            end
            object btnSelectDocTypes: TButton
              Left = 98
              Top = 135
              Width = 209
              Height = 25
              Caption = 'Выбрать типы документов...'
              TabOrder = 4
              TabStop = False
              OnClick = btnSelectDocTypesClick
            end
            object txt13: TStaticText
              Left = 13
              Top = 3
              Width = 599
              Height = 41
              AutoSize = False
              BiDiMode = bdLeftToRight
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
            object txt14: TStaticText
              Left = 212
              Top = 9
              Width = 185
              Height = 33
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = 'Squeeze Settings'
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 1
            end
          end
          object tsOptions: TTabSheet
            Caption = 'Options'
            ImageIndex = 2
            object lblLogDir: TLabel
              Left = 176
              Top = 91
              Width = 73
              Height = 13
              Caption = 'Logs Directory:'
              Enabled = False
            end
            object lblBackup: TLabel
              Left = 173
              Top = 155
              Width = 85
              Height = 13
              Caption = 'Backup Directory:'
              Enabled = False
            end
            object lblRestore: TLabel
              Left = 190
              Top = 211
              Width = 89
              Height = 13
              Caption = 'Restore Directory:'
              Enabled = False
            end
            object shp11: TShape
              Left = 13
              Top = 4
              Width = 599
              Height = 43
              Brush.Style = bsClear
              Pen.Color = 12238
              Pen.Width = 3
            end
            object btnNext3: TButton
              Left = 587
              Top = 318
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 14
              TabStop = False
            end
            object btnBack2: TButton
              Left = 561
              Top = 318
              Width = 25
              Height = 25
              Caption = '<'
              TabOrder = 13
              TabStop = False
              OnClick = actBackPageExecute
            end
            object chkbSaveLogs: TCheckBox
              Left = 152
              Top = 67
              Width = 113
              Height = 17
              TabStop = False
              Caption = 'Save Logs to File'
              TabOrder = 2
              OnClick = actDefocusExecute
            end
            object chkBackup: TCheckBox
              Left = 152
              Top = 131
              Width = 177
              Height = 17
              TabStop = False
              Caption = 'Backing Up the Database'
              Enabled = False
              TabOrder = 5
              OnClick = actDefocusExecute
            end
            object edLogs: TEdit
              Left = 266
              Top = 88
              Width = 253
              Height = 21
              Hint = '\\Сервер\СетевойКаталог[\ОтносительныйПуть]'
              Enabled = False
              TabOrder = 3
            end
            object btnLogDirBrowse: TButton
              Left = 523
              Top = 88
              Width = 20
              Height = 21
              Action = actDirectoryBrowse
              TabOrder = 4
              TabStop = False
              OnMouseDown = btnBackupBrowseMouseDown
            end
            object edtBackup: TEdit
              Left = 266
              Top = 152
              Width = 253
              Height = 21
              Hint = 'Диск:[\Каталог]'
              Enabled = False
              TabOrder = 6
            end
            object btnBackupBrowse: TButton
              Left = 523
              Top = 152
              Width = 20
              Height = 21
              Action = actDirectoryBrowse
              TabOrder = 7
              TabStop = False
              OnMouseDown = btnBackupBrowseMouseDown
            end
            object edtRestore: TEdit
              Left = 285
              Top = 208
              Width = 233
              Height = 21
              Hint = 'Диск:[\Каталог]'
              Enabled = False
              TabOrder = 9
            end
            object btnRestoreBrowse: TButton
              Left = 523
              Top = 208
              Width = 20
              Height = 21
              Action = actDirectoryBrowse
              TabOrder = 10
              TabStop = False
              OnMouseDown = btnBackupBrowseMouseDown
            end
            object chkRestore: TCheckBox
              Left = 172
              Top = 187
              Width = 133
              Height = 17
              TabStop = False
              Caption = 'Restore the Database'
              Enabled = False
              TabOrder = 8
              OnClick = actDefocusExecute
            end
            object txt15: TStaticText
              Left = 13
              Top = 3
              Width = 599
              Height = 41
              AutoSize = False
              BiDiMode = bdLeftToRight
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
            object txt8: TStaticText
              Left = 266
              Top = 8
              Width = 83
              Height = 31
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = 'Options'
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 1
            end
            object chkGetStatiscits: TCheckBox
              Left = 152
              Top = 250
              Width = 225
              Height = 17
              Hint = 'статистика ДО обработки и ПОСЛЕ'
              TabStop = False
              Caption = 'Автоматическое получение статистики'
              Checked = True
              State = cbChecked
              TabOrder = 11
              OnClick = actDefocusExecute
            end
            object btnSaveConfigFile: TButton
              Left = 152
              Top = 286
              Width = 221
              Height = 25
              Caption = 'Сохранить конфигурацию в файл...'
              TabOrder = 12
              TabStop = False
              OnClick = actConfigBrowseExecute
            end
          end
          object tsReviewSettings: TTabSheet
            Caption = 'ReviewSettings'
            ImageIndex = 3
            object shp12: TShape
              Left = 13
              Top = 4
              Width = 599
              Height = 43
              Brush.Style = bsClear
              Pen.Color = 12238
              Pen.Width = 3
            end
            object btnGo: TBitBtn
              Left = 555
              Top = 318
              Width = 57
              Height = 25
              Action = actGo
              Caption = 'Go!'
              TabOrder = 4
              TabStop = False
            end
            object btnBack3: TBitBtn
              Left = 529
              Top = 318
              Width = 25
              Height = 25
              Caption = '<'
              TabOrder = 3
              TabStop = False
              OnClick = actBackPageExecute
            end
            object mReviewSettings: TMemo
              Left = 120
              Top = 74
              Width = 377
              Height = 222
              ParentColor = True
              ReadOnly = True
              ScrollBars = ssVertical
              TabOrder = 2
            end
            object txt16: TStaticText
              Left = 13
              Top = 3
              Width = 599
              Height = 41
              AutoSize = False
              BiDiMode = bdLeftToRight
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
            object txt11: TStaticText
              Left = 226
              Top = 9
              Width = 171
              Height = 31
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = 'Review Settings'
              Color = 5206010
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 1
            end
          end
        end
      end
      object tsLogs: TTabSheet
        Caption = 'tsLogs'
        ImageIndex = 2
        object shp13: TShape
          Left = 20
          Top = 23
          Width = 445
          Height = 4
          Brush.Style = bsClear
          Pen.Color = 179
          Pen.Width = 2
        end
        object shp20: TShape
          Left = 487
          Top = 24
          Width = 327
          Height = 3
          Brush.Style = bsClear
          Pen.Color = 179
          Pen.Width = 2
        end
        object shp22: TShape
          Left = 20
          Top = 27
          Width = 461
          Height = 457
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 2
        end
        object shp23: TShape
          Left = 487
          Top = 27
          Width = 355
          Height = 457
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 2
        end
        object mLog: TMemo
          Left = 21
          Top = 27
          Width = 459
          Height = 456
          BorderStyle = bsNone
          ScrollBars = ssVertical
          TabOrder = 4
        end
        object mSqlLog: TMemo
          Left = 488
          Top = 27
          Width = 353
          Height = 456
          BorderStyle = bsNone
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 5
        end
        object btnClearGeneralLog: TButton
          Tag = 1
          Left = 437
          Top = 3
          Width = 44
          Height = 24
          Action = actClearLog
          Caption = 'Clear'
          TabOrder = 1
          TabStop = False
          OnMouseDown = btnClearGeneralLogMouseDown
        end
        object btnClearSqlLog: TButton
          Tag = 2
          Left = 799
          Top = 2
          Width = 43
          Height = 25
          Action = actClearLog
          Caption = 'Clear'
          TabOrder = 0
          TabStop = False
          OnMouseDown = btnClearGeneralLogMouseDown
        end
        object sttxt19: TStaticText
          Left = 20
          Top = 4
          Width = 417
          Height = 21
          Alignment = taCenter
          AutoSize = False
          Caption = 'General Log'
          Color = 5592556
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 3
        end
        object sttxt20: TStaticText
          Left = 487
          Top = 3
          Width = 312
          Height = 22
          Alignment = taCenter
          AutoSize = False
          Caption = 'SQL Log'
          Color = 5592556
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 2
        end
      end
      object tsStatistics: TTabSheet
        Caption = 'tsStatistics'
        ImageIndex = 3
        object shp3: TShape
          Left = 89
          Top = 37
          Width = 306
          Height = 28
          Pen.Color = 671448
          Pen.Mode = pmMask
          Pen.Style = psInsideFrame
          Pen.Width = 3
        end
        object shp4: TShape
          Left = 488
          Top = 63
          Width = 227
          Height = 266
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 3
        end
        object shp2: TShape
          Left = 487
          Top = 37
          Width = 229
          Height = 27
          Pen.Color = 671448
          Pen.Mode = pmMask
          Pen.Style = psInsideFrame
          Pen.Width = 3
        end
        object shp5: TShape
          Left = 488
          Top = 375
          Width = 227
          Height = 74
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 3
        end
        object shp1: TShape
          Left = 487
          Top = 349
          Width = 229
          Height = 27
          Pen.Color = 671448
          Pen.Mode = pmMask
          Pen.Style = psInsideFrame
          Pen.Width = 3
        end
        object shp6: TShape
          Left = 90
          Top = 63
          Width = 304
          Height = 350
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 3
        end
        object txt2: TStaticText
          Left = 90
          Top = 36
          Width = 302
          Height = 25
          AutoSize = False
          Caption = '         Number of records in a table                 '
          Color = 2058236
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWhite
          Font.Height = -17
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
        end
        object pnl2: TPanel
          Left = 488
          Top = 63
          Width = 226
          Height = 265
          Alignment = taLeftJustify
          BevelOuter = bvSpace
          TabOrder = 3
          object StaticText6: TStaticText
            Left = 10
            Top = 15
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'User'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object sttxtUser: TStaticText
            Left = 120
            Top = 16
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 1
          end
          object sttxtDialect: TStaticText
            Left = 120
            Top = 40
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 3
          end
          object StaticText5: TStaticText
            Left = 10
            Top = 39
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'SQL Dialect'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object sttxt32: TStaticText
            Left = 10
            Top = 63
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Server Version'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 4
          end
          object sttxtServerVer: TStaticText
            Left = 120
            Top = 64
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 5
          end
          object sttxt34: TStaticText
            Left = 10
            Top = 87
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'ODS Version'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 6
          end
          object sttxtODSVer: TStaticText
            Left = 120
            Top = 88
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 7
          end
          object sttxtRemoteProtocol: TStaticText
            Left = 120
            Top = 112
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 9
          end
          object StaticText7: TStaticText
            Left = 10
            Top = 111
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Remote Protocol'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 8
          end
          object StaticText8: TStaticText
            Left = 10
            Top = 135
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Remote Address'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 10
          end
          object sttxtRemoteAddr: TStaticText
            Left = 120
            Top = 136
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 11
          end
          object sttxtPageSize: TStaticText
            Left = 120
            Top = 160
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 13
          end
          object StaticText9: TStaticText
            Left = 10
            Top = 159
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Page Size'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 12
          end
          object StaticText10: TStaticText
            Left = 10
            Top = 183
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Page Buffers'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 14
          end
          object sttxtPageBuffers: TStaticText
            Left = 120
            Top = 184
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 15
          end
          object sttxtForcedWrites: TStaticText
            Left = 120
            Top = 208
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 17
          end
          object StaticText11: TStaticText
            Left = 10
            Top = 207
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Forced Writes'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 16
          end
          object StaticText12: TStaticText
            Left = 10
            Top = 230
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Garbage Collection'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 18
          end
          object sttxtGarbageCollection: TStaticText
            Left = 120
            Top = 231
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 19
          end
        end
        object sttxt30: TStaticText
          Left = 488
          Top = 36
          Width = 225
          Height = 25
          Alignment = taCenter
          AutoSize = False
          Caption = 'DB Properties'
          Color = 2058236
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWhite
          Font.Height = -17
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 1
        end
        object pnl3: TPanel
          Left = 488
          Top = 375
          Width = 226
          Height = 73
          TabOrder = 5
          object sttxt28: TStaticText
            Left = 12
            Top = 14
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Before Processing'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clHighlightText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object sttxt29: TStaticText
            Left = 12
            Top = 39
            Width = 99
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'After Processing'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clHighlightText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object sttxtDBSizeBefore: TStaticText
            Left = 120
            Top = 15
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 1
          end
          object sttxtDBSizeAfter: TStaticText
            Left = 120
            Top = 39
            Width = 97
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            Enabled = False
            ParentColor = False
            TabOrder = 3
          end
        end
        object sttxt21: TStaticText
          Left = 488
          Top = 348
          Width = 225
          Height = 25
          Alignment = taCenter
          AutoSize = False
          Caption = 'DB File Size'
          Color = 2058236
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWhite
          Font.Height = -17
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 4
        end
        object pnl4: TPanel
          Left = 90
          Top = 63
          Width = 303
          Height = 349
          TabOrder = 2
          object shp7: TShape
            Left = 124
            Top = 329
            Width = 79
            Height = 2
            Brush.Color = clBtnShadow
            Pen.Color = clGrayText
          end
          object shp8: TShape
            Left = 213
            Top = 329
            Width = 79
            Height = 2
            Brush.Color = clBtnShadow
            Pen.Color = clGrayText
          end
          object txt10: TStaticText
            Left = 123
            Top = 14
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'ORIGINAL'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object sttxt11: TStaticText
            Left = 211
            Top = 14
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'CURRENT'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
          end
          object sttxtGdDocAfter: TStaticText
            Left = 211
            Top = 42
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 4
          end
          object sttxtGdDoc: TStaticText
            Left = 123
            Top = 42
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 3
          end
          object txt3: TStaticText
            Left = 11
            Top = 41
            Width = 100
            Height = 18
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'GD_DOCUMENT'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object txt4: TStaticText
            Left = 11
            Top = 70
            Width = 100
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'AC_ENTRY'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 5
          end
          object sttxtAcEntry: TStaticText
            Left = 123
            Top = 70
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 6
          end
          object sttxtAcEntryAfter: TStaticText
            Left = 211
            Top = 70
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 7
          end
          object txt5: TStaticText
            Left = 11
            Top = 98
            Width = 100
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'INV_MOVEMENT'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 8
          end
          object sttxtInvMovement: TStaticText
            Left = 123
            Top = 98
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 9
          end
          object sttxtInvMovementAfter: TStaticText
            Left = 211
            Top = 98
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 10
          end
          object txt6: TStaticText
            Left = 11
            Top = 124
            Width = 100
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'INV_CARD'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 11
          end
          object sttxtInvCard: TStaticText
            Left = 123
            Top = 125
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 12
          end
          object sttxtInvCardAfter: TStaticText
            Left = 211
            Top = 125
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 13
          end
          object sttxt2: TStaticText
            Left = 0
            Top = 159
            Width = 302
            Height = 24
            Alignment = taCenter
            AutoSize = False
            Caption = 'Number of processing records'
            Color = 2058236
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWhite
            Font.Height = -17
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 14
          end
          object sttxt3: TStaticText
            Left = 11
            Top = 195
            Width = 100
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'GD_DOCUMENT'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 15
          end
          object sttxt4: TStaticText
            Left = 11
            Top = 219
            Width = 100
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'AC_ENTRY'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 18
          end
          object sttxt5: TStaticText
            Left = 11
            Top = 244
            Width = 100
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'INV_MOVEMENT'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 21
          end
          object sttxt6: TStaticText
            Left = 11
            Top = 268
            Width = 100
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'INV_CARD'
            Color = 671448
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindow
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 24
          end
          object sttxtProcGdDoc: TStaticText
            Left = 124
            Top = 196
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 16
          end
          object sttxtProcAcEntry: TStaticText
            Left = 123
            Top = 220
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 19
          end
          object sttxtProcInvMovement: TStaticText
            Left = 123
            Top = 244
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 22
          end
          object sttxtProcInvCard: TStaticText
            Left = 122
            Top = 268
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 25
          end
          object sttxtAfterProcGdDoc: TStaticText
            Left = 212
            Top = 196
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 17
          end
          object sttxtAfterProcAcEntry: TStaticText
            Left = 212
            Top = 220
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 20
          end
          object sttxtAfterProcInvMovement: TStaticText
            Left = 212
            Top = 244
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 23
          end
          object sttxtAfterProcInvCard: TStaticText
            Left = 212
            Top = 268
            Width = 79
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Color = clHighlightText
            ParentColor = False
            TabOrder = 26
          end
          object btnGetStatistics: TButton
            Left = 124
            Top = 305
            Width = 79
            Height = 25
            Action = actGet
            Caption = 'Get'
            Enabled = False
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 27
            TabStop = False
            OnMouseDown = btnGetStatisticsMouseDown
          end
          object btnUpdateStatistics: TBitBtn
            Left = 213
            Top = 305
            Width = 79
            Height = 25
            Action = actGet
            Caption = 'Update'
            Enabled = False
            TabOrder = 28
            TabStop = False
            OnMouseDown = btnGetStatisticsMouseDown
          end
        end
      end
      object tsAbout: TTabSheet
        Caption = 'tsAbout'
        ImageIndex = 3
      end
    end
    object statbarMain: TStatusBar
      Left = 1
      Top = 515
      Width = 864
      Height = 22
      Align = alNone
      Panels = <
        item
          Width = 114
        end
        item
          Alignment = taCenter
          Style = psOwnerDraw
          Text = 'Progress'
          Width = 320
        end
        item
          Width = 320
        end
        item
          BiDiMode = bdLeftToRight
          ParentBiDiMode = False
          Text = '     Not Connected'
          Width = 58
        end>
      ParentColor = True
      ParentFont = True
      SimplePanel = False
      UseSystemFont = False
      OnDrawPanel = statbarMainDrawPanel
    end
    object pbMain: TProgressBar
      Left = 118
      Top = 518
      Width = 316
      Height = 18
      DragCursor = crDefault
      Min = 0
      Max = 3000
      Smooth = True
      TabOrder = 4
    end
    object btnStop: TButton
      Left = 12
      Top = 518
      Width = 102
      Height = 20
      Hint = 'Корректно прервать'
      Action = actStop
      BiDiMode = bdLeftToRight
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      TabStop = False
    end
  end
  object ActionList: TActionList
    Left = 5
    Top = 6
    object actGo: TAction
      Caption = 'actGo'
      OnExecute = actGoExecute
      OnUpdate = actGoUpdate
    end
    object actCompany: TAction
      Caption = 'actCompany'
    end
    object actDatabaseBrowse: TAction
      Caption = 'actDatabaseBrowse'
      OnExecute = actDatabaseBrowseExecute
    end
    object actGet: TAction
      Caption = 'actGet'
      OnExecute = actGetExecute
      OnUpdate = actGetUpdate
    end
    object actUpdate: TAction
      Caption = 'actUpdate'
    end
    object actRadioLocation: TAction
      Caption = 'actRadioLocation'
      OnExecute = actRadioLocationExecute
    end
    object actDefaultPort: TAction
      Caption = 'actDefaultPort'
      OnExecute = actDefaultPortExecute
    end
    object actNextPage: TAction
      Caption = 'actNextPage'
      OnExecute = actNextPageExecute
      OnUpdate = actNextPageUpdate
    end
    object actBackPage: TAction
      Caption = 'actBackPage'
      OnExecute = actBackPageExecute
    end
    object actDirectoryBrowse: TAction
      Caption = '...'
      OnExecute = actDirectoryBrowseExecute
      OnUpdate = actDirectoryBrowseUpdate
    end
    object actStop: TAction
      Caption = 'STOP'
      OnExecute = actStopExecute
      OnUpdate = actStopUpdate
    end
    object actDisconnect: TAction
      Caption = 'actDisconnect'
      OnExecute = actDisconnectExecute
      OnUpdate = actDisconnectUpdate
    end
    object actClearLog: TAction
      Caption = 'actClearLog'
      OnExecute = actClearLogExecute
      OnUpdate = actClearLogUpdate
    end
    object actDefocus: TAction
      OnExecute = actDefocusExecute
    end
    object actConfigBrowse: TAction
      Caption = 'actConfigBrowse'
      OnExecute = actConfigBrowseExecute
    end
  end
end
