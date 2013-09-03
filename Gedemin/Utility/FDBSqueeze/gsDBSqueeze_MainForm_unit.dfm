object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 496
  Top = 37
  BorderStyle = bsDialog
  ClientHeight = 536
  ClientWidth = 851
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = -12
    Top = 0
    Width = 893
    Height = 538
    TabOrder = 0
    object tbcPageController: TTabControl
      Left = 198
      Top = 0
      Width = 457
      Height = 25
      Style = tsFlatButtons
      TabOrder = 0
      Tabs.Strings = (
        'Settings'
        'Process'
        'Logs'
        'Statistics')
      TabIndex = 0
      TabStop = False
      TabWidth = 100
      OnChange = tbcPageControllerChange
      OnChanging = tbcPageControllerChanging
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
          ActivePage = tsReviewSettings
          TabOrder = 0
          object tsConnection: TTabSheet
            Caption = 'Database Connection'
            object lblTestConnectState: TLabel
              Left = 456
              Top = 56
              Width = 97
              Height = 13
              Caption = 'Test Connect State:'
              Enabled = False
            end
            object lblServerVersion: TLabel
              Left = 476
              Top = 80
              Width = 74
              Height = 13
              Caption = 'Server Version:'
              Visible = False
            end
            object lblActivConnectCount: TLabel
              Left = 474
              Top = 104
              Width = 76
              Height = 13
              Caption = 'Activ Connects:'
              Visible = False
            end
            object btnNext1: TButton
              Left = 584
              Top = 301
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 8
            end
            object grpDatabase: TGroupBox
              Left = 64
              Top = 48
              Width = 377
              Height = 153
              Caption = ' Database Location  '
              TabOrder = 1
              object lbl4: TLabel
                Left = 28
                Top = 71
                Width = 26
                Height = 13
                Caption = 'Host:'
              end
              object lbl8: TLabel
                Left = 188
                Top = 72
                Width = 24
                Height = 13
                Caption = 'Port:'
              end
              object lbl1: TLabel
                Left = 18
                Top = 112
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
                Top = 68
                Width = 93
                Height = 21
                Enabled = False
                TabOrder = 2
                Text = 'localhost'
              end
              object chkDefaultPort: TCheckBox
                Left = 220
                Top = 71
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
                Top = 69
                Width = 63
                Height = 22
                Enabled = False
                MaxLength = 5
                MaxValue = 65535
                MinValue = 0
                TabOrder = 3
                Value = 3053
              end
              object edDatabaseName: TEdit
                Left = 74
                Top = 109
                Width = 253
                Height = 21
                TabOrder = 6
                Text = 'C:\_AKSAMIT2.fdb'
              end
              object btnDatabaseBrowse: TButton
                Left = 331
                Top = 108
                Width = 20
                Height = 21
                Action = actDatabaseBrowse
                Caption = '...'
                TabOrder = 5
                TabStop = False
              end
            end
            object grpAuthorization: TGroupBox
              Left = 64
              Top = 212
              Width = 377
              Height = 77
              Caption = ' Authorization '
              TabOrder = 5
              object lbl2: TLabel
                Left = 17
                Top = 32
                Width = 52
                Height = 13
                Caption = 'Username:'
              end
              object lbl3: TLabel
                Left = 188
                Top = 33
                Width = 50
                Height = 13
                Caption = 'Password:'
              end
              object edUserName: TEdit
                Left = 74
                Top = 30
                Width = 94
                Height = 21
                TabOrder = 0
                Text = 'SYSDBA'
              end
              object edPassword: TEdit
                Left = 244
                Top = 31
                Width = 106
                Height = 21
                PasswordChar = '*'
                TabOrder = 1
                Text = 'masterkey'
              end
            end
            object sttxt1: TStaticText
              Left = 22
              Top = 1
              Width = 603
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              BorderStyle = sbsSingle
              Caption = '  Database Connection'
              Color = clInactiveCaption
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindowText
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
            object btntTestConnection: TButton
              Left = 456
              Top = 301
              Width = 121
              Height = 25
              Action = actTestConnect
              TabOrder = 7
            end
            object sttxtStateTestConnect: TStaticText
              Left = 560
              Top = 56
              Width = 49
              Height = 17
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              Enabled = False
              TabOrder = 2
            end
            object sttxtServer: TStaticText
              Left = 560
              Top = 80
              Width = 49
              Height = 17
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              TabOrder = 3
              Visible = False
            end
            object btnDisconnect: TButton
              Left = 456
              Top = 267
              Width = 153
              Height = 21
              Action = actDisconnect
              TabOrder = 6
              TabStop = False
            end
            object sttxtActivUserCount: TStaticText
              Left = 560
              Top = 104
              Width = 49
              Height = 17
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              TabOrder = 4
              Visible = False
            end
          end
          object tsSqueezeSettings: TTabSheet
            Caption = 'Squeeze Settings'
            ImageIndex = 1
            object lbl5: TLabel
              Left = 148
              Top = 73
              Width = 183
              Height = 13
              Caption = '”далить записи из gd_document до:'
            end
            object lbl6: TLabel
              Left = 149
              Top = 120
              Width = 183
              Height = 13
              Caption = '–ассчитать и сохранить сальдо по: '
            end
            object dtpClosingDate: TDateTimePicker
              Left = 356
              Top = 70
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
              TabOrder = 1
            end
            object rbAllOurCompanies: TRadioButton
              Left = 165
              Top = 153
              Width = 225
              Height = 17
              Caption = 'всем рабочим организаци€м'
              TabOrder = 2
            end
            object rbCompany: TRadioButton
              Left = 166
              Top = 185
              Width = 225
              Height = 17
              Action = actCompany
              Caption = 'рабочей организации'
              TabOrder = 3
            end
            object cbbCompany: TComboBox
              Left = 200
              Top = 209
              Width = 241
              Height = 21
              Enabled = False
              ItemHeight = 13
              TabOrder = 4
            end
            object btnNext2: TButton
              Left = 587
              Top = 297
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 6
            end
            object btnBack1: TButton
              Left = 561
              Top = 297
              Width = 25
              Height = 25
              Action = actBackPage
              Caption = '<'
              TabOrder = 5
            end
            object sttxt16: TStaticText
              Left = 22
              Top = 1
              Width = 603
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              BorderStyle = sbsSingle
              Caption = '  Squeeze Settings'
              Color = clInactiveCaption
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindowText
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
          end
          object tsOptions: TTabSheet
            Caption = 'Options'
            ImageIndex = 2
            object lblLogDir: TLabel
              Left = 176
              Top = 80
              Width = 73
              Height = 13
              Caption = 'Logs Directory:'
              Enabled = False
            end
            object lblBackup: TLabel
              Left = 176
              Top = 144
              Width = 85
              Height = 13
              Caption = 'Backup Directory:'
              Enabled = False
            end
            object btnNext3: TButton
              Left = 580
              Top = 298
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 9
            end
            object btnBack2: TButton
              Left = 554
              Top = 298
              Width = 25
              Height = 25
              Action = actBackPage
              Caption = '<'
              TabOrder = 8
            end
            object sttxt17: TStaticText
              Left = 1
              Top = 1
              Width = 625
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              BorderStyle = sbsSingle
              Caption = '  Options'
              Color = clInactiveCaption
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindowText
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
            object chkbSaveLogs: TCheckBox
              Left = 152
              Top = 56
              Width = 113
              Height = 17
              Caption = 'Save Logs to File'
              TabOrder = 1
            end
            object chkBackup: TCheckBox
              Left = 152
              Top = 120
              Width = 177
              Height = 17
              Caption = 'Backing Up the Database'
              Enabled = False
              TabOrder = 4
            end
            object edLogs: TEdit
              Left = 266
              Top = 77
              Width = 253
              Height = 21
              Enabled = False
              TabOrder = 3
            end
            object btnLogDirBrowse: TButton
              Left = 523
              Top = 76
              Width = 20
              Height = 21
              Action = actDirectoryBrowse
              Enabled = False
              TabOrder = 2
              TabStop = False
              OnMouseDown = btnBackupBrowseMouseDown
            end
            object edtBackup: TEdit
              Left = 266
              Top = 141
              Width = 253
              Height = 21
              Enabled = False
              TabOrder = 6
            end
            object btnBackupBrowse: TButton
              Left = 523
              Top = 140
              Width = 20
              Height = 21
              Action = actDirectoryBrowse
              TabOrder = 5
              TabStop = False
              OnMouseDown = btnBackupBrowseMouseDown
            end
            object grpReprocessingType: TGroupBox
              Left = 152
              Top = 200
              Width = 289
              Height = 57
              Caption = ' Reprocessing Type '
              Enabled = False
              TabOrder = 7
              object rbStartOver: TRadioButton
                Left = 56
                Top = 24
                Width = 105
                Height = 17
                Caption = 'Start Over'
                Enabled = False
                TabOrder = 0
              end
              object rbContinue: TRadioButton
                Left = 176
                Top = 24
                Width = 97
                Height = 17
                Caption = 'Continue'
                Enabled = False
                TabOrder = 1
              end
            end
          end
          object tsReviewSettings: TTabSheet
            Caption = 'ReviewSettings'
            ImageIndex = 3
            object sttxt18: TStaticText
              Left = 22
              Top = 1
              Width = 676
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              BorderStyle = sbsSingle
              Caption = '  Review Settings'
              Color = clInactiveCaption
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindowText
              Font.Height = -24
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentBiDiMode = False
              ParentColor = False
              ParentFont = False
              TabOrder = 0
            end
            object btnGo: TBitBtn
              Left = 544
              Top = 297
              Width = 57
              Height = 25
              Action = actGo
              Caption = 'Go!'
              TabOrder = 3
            end
            object btnBack3: TBitBtn
              Left = 512
              Top = 297
              Width = 25
              Height = 25
              Action = actBackPage
              Caption = '<'
              TabOrder = 2
            end
            object mReviewSettings: TMemo
              Left = 120
              Top = 56
              Width = 377
              Height = 209
              ParentColor = True
              ReadOnly = True
              ScrollBars = ssVertical
              TabOrder = 1
            end
          end
        end
      end
      object tsProcess: TTabSheet
        Caption = 'tsProcess'
        ImageIndex = 1
      end
      object tsLogs: TTabSheet
        Caption = 'tsLogs'
        ImageIndex = 2
        object mLog: TMemo
          Left = 22
          Top = 26
          Width = 459
          Height = 457
          ScrollBars = ssVertical
          TabOrder = 4
        end
        object mSqlLog: TMemo
          Left = 488
          Top = 26
          Width = 353
          Height = 456
          Lines.Strings = (
            '')
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 5
        end
        object btnClearGeneralLog: TButton
          Left = 437
          Top = 3
          Width = 44
          Height = 25
          Caption = 'Clear'
          TabOrder = 1
          TabStop = False
          OnClick = btnClearGeneralLogClick
        end
        object btnClearSqlLog: TButton
          Left = 797
          Top = 3
          Width = 44
          Height = 25
          Caption = 'Clear'
          TabOrder = 3
          TabStop = False
          OnClick = btnClearSqlLogClick
        end
        object sttxt19: TStaticText
          Left = 22
          Top = 3
          Width = 415
          Height = 24
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'General Log'
          Color = clInactiveCaption
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
        end
        object sttxt20: TStaticText
          Left = 488
          Top = 3
          Width = 309
          Height = 24
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'SQL Log'
          Color = clInactiveCaption
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 2
        end
      end
      object tsStatistics: TTabSheet
        ImageIndex = 3
        object btnGetStatistics: TButton
          Left = 222
          Top = 304
          Width = 78
          Height = 25
          Action = actGet
          Caption = 'Get'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 37
          TabStop = False
        end
        object sttxt21: TStaticText
          Left = 118
          Top = 64
          Width = 273
          Height = 17
          Alignment = taCenter
          AutoSize = False
          Caption = 'DB File Size'
          Color = clHighlightText
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
        end
        object txt10: TStaticText
          Left = 222
          Top = 192
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'ORIGINAL'
          TabOrder = 17
        end
        object sttxt11: TStaticText
          Left = 310
          Top = 192
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'NOW'
          TabOrder = 18
        end
        object txt3: TStaticText
          Left = 118
          Top = 220
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'GD_DOCUMENT'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 21
        end
        object txt5: TStaticText
          Left = 118
          Top = 275
          Width = 100
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'INV_MOVEMENT'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 31
        end
        object txt4: TStaticText
          Left = 118
          Top = 248
          Width = 100
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'AC_ENTRY'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 26
        end
        object sttxtGdDoc: TStaticText
          Left = 222
          Top = 220
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 22
        end
        object sttxtGdDocAfter: TStaticText
          Left = 310
          Top = 220
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 23
        end
        object sttxtAcEntry: TStaticText
          Left = 222
          Top = 248
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 27
        end
        object sttxtAcEntryAfter: TStaticText
          Left = 310
          Top = 248
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 28
        end
        object sttxtInvMovement: TStaticText
          Left = 222
          Top = 276
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 32
        end
        object sttxtInvMovementAfter: TStaticText
          Left = 310
          Top = 276
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 33
        end
        object txt2: TStaticText
          Left = 117
          Top = 160
          Width = 273
          Height = 17
          AutoSize = False
          Caption = '                 Number of records in a table                 '
          Color = clWhite
          ParentColor = False
          TabOrder = 13
        end
        object sttxt28: TStaticText
          Left = 118
          Top = 88
          Width = 185
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Size Before Processing'
          TabOrder = 3
        end
        object sttxt29: TStaticText
          Left = 118
          Top = 112
          Width = 185
          Height = 17
          Alignment = taCenter
          AutoSize = False
          Caption = 'Size After Processing'
          Enabled = False
          TabOrder = 7
        end
        object btnUpdateStatistics: TBitBtn
          Left = 311
          Top = 304
          Width = 78
          Height = 25
          Action = actGet
          Caption = 'Update'
          TabOrder = 38
          TabStop = False
        end
        object sttxtDBSizeBefore: TStaticText
          Left = 311
          Top = 88
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 4
        end
        object sttxtDBSizeAfter: TStaticText
          Left = 311
          Top = 112
          Width = 79
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          Enabled = False
          TabOrder = 8
        end
        object sttxt30: TStaticText
          Left = 470
          Top = 64
          Width = 275
          Height = 17
          Alignment = taCenter
          AutoSize = False
          Caption = 'DB Properties'
          Color = clHighlightText
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 1
        end
        object StaticText6: TStaticText
          Left = 470
          Top = 87
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'User'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 2
        end
        object StaticText5: TStaticText
          Left = 470
          Top = 111
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'SQL Dialect'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 6
        end
        object StaticText7: TStaticText
          Left = 470
          Top = 183
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Remote Protocol'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 15
        end
        object StaticText8: TStaticText
          Left = 471
          Top = 207
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Remote Address'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 19
        end
        object StaticText9: TStaticText
          Left = 471
          Top = 231
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Page Size'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 24
        end
        object StaticText10: TStaticText
          Left = 471
          Top = 255
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Page Buffers'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 29
        end
        object StaticText11: TStaticText
          Left = 471
          Top = 279
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Forced Writes'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 34
        end
        object StaticText12: TStaticText
          Left = 471
          Top = 303
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Garbage Collection'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 36
        end
        object sttxtODSVer: TStaticText
          Left = 579
          Top = 160
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 14
        end
        object sttxtServerVer: TStaticText
          Left = 579
          Top = 136
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 11
        end
        object sttxt32: TStaticText
          Left = 470
          Top = 135
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'Server Version'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 10
        end
        object sttxt34: TStaticText
          Left = 470
          Top = 159
          Width = 100
          Height = 18
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSingle
          Caption = 'ODS Version'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 12
        end
        object sttxtUser: TStaticText
          Left = 579
          Top = 88
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 5
        end
        object sttxtDialect: TStaticText
          Left = 579
          Top = 112
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 9
        end
        object sttxtRemoteProtocol: TStaticText
          Left = 579
          Top = 184
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 16
        end
        object sttxtRemoteAddr: TStaticText
          Left = 579
          Top = 208
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 20
        end
        object sttxtPageSize: TStaticText
          Left = 579
          Top = 232
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 25
        end
        object sttxtPageBuffers: TStaticText
          Left = 579
          Top = 256
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 30
        end
        object sttxtForcedWrites: TStaticText
          Left = 579
          Top = 280
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 35
        end
        object sttxtGarbageCollection: TStaticText
          Left = 579
          Top = 304
          Width = 166
          Height = 17
          Alignment = taCenter
          AutoSize = False
          BorderStyle = sbsSunken
          TabOrder = 39
        end
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
    end
    object pbMain: TProgressBar
      Left = 121
      Top = 519
      Width = 313
      Height = 15
      Min = 0
      Max = 100
      TabOrder = 4
    end
    object btnStop: TButton
      Left = 16
      Top = 519
      Width = 97
      Height = 17
      Caption = 'STOP'
      TabOrder = 3
      TabStop = False
    end
  end
  object ActionList: TActionList
    Left = 5
    Top = 6
    object actTestConnect: TAction
      Caption = 'Test Connect'
      OnExecute = actTestConnectExecute
      OnUpdate = actTestConnectUpdate
    end
    object actGo: TAction
      Caption = 'actGo'
      OnExecute = actGoExecute
      OnUpdate = actGoUpdate
    end
    object actDisconnect: TAction
      Caption = 'Disconnect'
      OnExecute = actDisconnectExecute
      OnUpdate = actDisconnectUpdate
    end
    object actCompany: TAction
      Caption = 'actCompany'
      OnExecute = actCompanyExecute
      OnUpdate = actCompanyUpdate
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
      OnUpdate = actDefaultPortUpdate
    end
    object actNextPage: TAction
      Caption = 'actNextPage'
      OnExecute = actNextPageExecute
      OnUpdate = actNextPageUpdate
    end
    object actBackPage: TAction
      Caption = 'actBackPage'
      OnExecute = actBackPageExecute
      OnUpdate = actBackPageUpdate
    end
    object actDirectoryBrowse: TAction
      Caption = '...'
      OnExecute = actDirectoryBrowseExecute
      OnUpdate = actDirectoryBrowseUpdate
    end
  end
end
