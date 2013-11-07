object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 197
  Top = 161
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
    object shp10: TShape
      Left = 56
      Top = 24
      Width = 65
      Height = 65
    end
    object tbcPageController: TTabControl
      Left = 228
      Top = 0
      Width = 441
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
      ActivePage = tsProcess
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
          ActivePage = tsSettings2
          TabOrder = 0
          object tsConnection: TTabSheet
            Caption = 'Database Connection'
            object shp9: TShape
              Left = 19
              Top = 9
              Width = 601
              Height = 36
              Brush.Style = bsClear
              Pen.Color = 10768896
              Pen.Width = 3
            end
            object btnNext1: TButton
              Left = 587
              Top = 302
              Width = 25
              Height = 25
              Action = actNextPage
              Anchors = [akLeft, akTop, akRight]
              Caption = '>'
              TabOrder = 11
            end
            object grpDatabase: TGroupBox
              Left = 64
              Top = 56
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
              Top = 217
              Width = 377
              Height = 77
              Caption = ' Authorization '
              TabOrder = 8
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
              Top = 7
              Width = 598
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '  Database Connection'
              Color = 15370833
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
            object btntTestConnection: TButton
              Left = 458
              Top = 302
              Width = 121
              Height = 25
              Action = actTestConnect
              TabOrder = 10
            end
            object sttxtStateTestConnect: TStaticText
              Left = 562
              Top = 86
              Width = 49
              Height = 17
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              Caption = 'unknown'
              Color = clHighlightText
              ParentColor = False
              TabOrder = 3
            end
            object btnDisconnect: TButton
              Left = 458
              Top = 272
              Width = 153
              Height = 21
              Action = actDisconnect
              TabOrder = 9
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
              TabOrder = 5
              Visible = False
            end
            object sttxtServerName: TStaticText
              Left = 458
              Top = 155
              Width = 152
              Height = 17
              Alignment = taCenter
              AutoSize = False
              BorderStyle = sbsSunken
              Color = clHighlightText
              ParentColor = False
              TabOrder = 7
              Visible = False
            end
            object sttxtTestServer: TStaticText
              Left = 458
              Top = 138
              Width = 152
              Height = 17
              Alignment = taCenter
              AutoSize = False
              Caption = 'Server'
              Color = 10768896
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 6
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
              Color = 10768896
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 4
              Visible = False
            end
            object sttxtTestConnectState: TStaticText
              Left = 458
              Top = 86
              Width = 105
              Height = 16
              Alignment = taCenter
              AutoSize = False
              Caption = 'Test Connect State'
              Color = 10768896
              Font.Charset = RUSSIAN_CHARSET
              Font.Color = clWindow
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 2
            end
          end
          object tsSqueezeSettings: TTabSheet
            Caption = 'Squeeze Settings'
            ImageIndex = 1
            object lbl5: TLabel
              Left = 148
              Top = 85
              Width = 183
              Height = 13
              Caption = '”далить записи из gd_document до:'
            end
            object lbl6: TLabel
              Left = 149
              Top = 132
              Width = 183
              Height = 13
              Caption = '–ассчитать и сохранить сальдо по: '
            end
            object shp11: TShape
              Left = 19
              Top = 9
              Width = 604
              Height = 36
              Brush.Style = bsClear
              Pen.Color = 10768896
              Pen.Width = 3
            end
            object dtpClosingDate: TDateTimePicker
              Left = 356
              Top = 82
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
              Top = 165
              Width = 225
              Height = 17
              Caption = 'всем рабочим организаци€м'
              TabOrder = 2
            end
            object rbCompany: TRadioButton
              Left = 166
              Top = 197
              Width = 225
              Height = 17
              Action = actCompany
              Caption = 'рабочей организации'
              TabOrder = 3
            end
            object cbbCompany: TComboBox
              Left = 200
              Top = 221
              Width = 241
              Height = 21
              Enabled = False
              ItemHeight = 13
              TabOrder = 4
            end
            object btnNext2: TButton
              Left = 587
              Top = 302
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 6
            end
            object btnBack1: TButton
              Left = 561
              Top = 302
              Width = 25
              Height = 25
              Action = actBackPage
              Caption = '<'
              TabOrder = 5
            end
            object sttxt16: TStaticText
              Left = 22
              Top = 7
              Width = 601
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '  Squeeze Settings'
              Color = 15370833
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
          end
          object tsSettings2: TTabSheet
            Caption = 'tsSettings2'
            ImageIndex = 4
            object shp14: TShape
              Left = 19
              Top = 9
              Width = 604
              Height = 36
              Brush.Style = bsClear
              Pen.Color = 10768896
              Pen.Width = 3
            end
            object btn1: TButton
              Left = 561
              Top = 302
              Width = 25
              Height = 25
              Action = actBackPage
              Caption = '<'
              TabOrder = 2
            end
            object btn2: TButton
              Left = 587
              Top = 302
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 3
            end
            object txt1: TStaticText
              Left = 22
              Top = 7
              Width = 601
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '  Squeeze Settings'
              Color = 15370833
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
            object pgcDocTypesSettings: TPageControl
              Left = 40
              Top = 64
              Width = 513
              Height = 265
              ActivePage = tsProcDocTypes
              Style = tsButtons
              TabHeight = 24
              TabOrder = 1
              TabWidth = 250
              object tsIgnoreDocTypes: TTabSheet
                Caption = 'Ignore Documents Types'
                object strngrdIgnoreDocTypes: TStringGrid
                  Left = 8
                  Top = 6
                  Width = 481
                  Height = 107
                  ColCount = 2
                  DefaultColWidth = 390
                  DefaultRowHeight = 20
                  FixedCols = 0
                  RowCount = 10
                  FixedRows = 0
                  Options = [goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
                  ScrollBars = ssVertical
                  TabOrder = 0
                  OnDblClick = strngrdIgnoreDocTypesDblClick
                  OnDrawCell = strngrdIgnoreDocTypesDrawCell
                end
                object mIgnoreDocTypes: TMemo
                  Left = 8
                  Top = 120
                  Width = 481
                  Height = 73
                  Color = clBtnFace
                  ReadOnly = True
                  ScrollBars = ssVertical
                  TabOrder = 1
                end
              end
              object tsProcDocTypes: TTabSheet
                Caption = 'Process Documents Types'
                ImageIndex = 1
                object strngrdProcDocTypes: TStringGrid
                  Left = 8
                  Top = 6
                  Width = 481
                  Height = 108
                  ColCount = 2
                  DefaultColWidth = 390
                  DefaultRowHeight = 20
                  FixedCols = 0
                  RowCount = 10
                  FixedRows = 0
                  Options = [goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
                  ScrollBars = ssVertical
                  TabOrder = 0
                  OnDblClick = strngrdProcDocTypesDblClick
                  OnDrawCell = strngrdProcDocTypesDrawCell
                end
                object mProcDocTypes: TMemo
                  Left = 8
                  Top = 120
                  Width = 481
                  Height = 69
                  Color = clBtnFace
                  ReadOnly = True
                  ScrollBars = ssVertical
                  TabOrder = 1
                end
              end
            end
          end
          object tsOptions: TTabSheet
            Caption = 'Options'
            ImageIndex = 2
            object lblLogDir: TLabel
              Left = 176
              Top = 92
              Width = 73
              Height = 13
              Caption = 'Logs Directory:'
              Enabled = False
            end
            object lblBackup: TLabel
              Left = 176
              Top = 156
              Width = 85
              Height = 13
              Caption = 'Backup Directory:'
              Enabled = False
            end
            object shp12: TShape
              Left = 19
              Top = 9
              Width = 604
              Height = 36
              Brush.Style = bsClear
              Pen.Color = 10768896
              Pen.Width = 3
            end
            object btnNext3: TButton
              Left = 580
              Top = 302
              Width = 25
              Height = 25
              Action = actNextPage
              Caption = '>'
              TabOrder = 9
            end
            object btnBack2: TButton
              Left = 554
              Top = 302
              Width = 25
              Height = 25
              Action = actBackPage
              Caption = '<'
              TabOrder = 8
            end
            object sttxt17: TStaticText
              Left = 22
              Top = 7
              Width = 601
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '  Options'
              Color = 15370833
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
            object chkbSaveLogs: TCheckBox
              Left = 152
              Top = 68
              Width = 113
              Height = 17
              Caption = 'Save Logs to File'
              TabOrder = 1
            end
            object chkBackup: TCheckBox
              Left = 152
              Top = 132
              Width = 177
              Height = 17
              Caption = 'Backing Up the Database'
              Enabled = False
              TabOrder = 4
            end
            object edLogs: TEdit
              Left = 266
              Top = 89
              Width = 253
              Height = 21
              Enabled = False
              TabOrder = 3
            end
            object btnLogDirBrowse: TButton
              Left = 523
              Top = 88
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
              Top = 153
              Width = 253
              Height = 21
              Enabled = False
              TabOrder = 6
            end
            object btnBackupBrowse: TButton
              Left = 523
              Top = 152
              Width = 20
              Height = 21
              Action = actDirectoryBrowse
              TabOrder = 5
              TabStop = False
              OnMouseDown = btnBackupBrowseMouseDown
            end
            object grpReprocessingType: TGroupBox
              Left = 152
              Top = 212
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
            object shp13: TShape
              Left = 19
              Top = 9
              Width = 604
              Height = 36
              Brush.Style = bsClear
              Pen.Color = 10768896
              Pen.Width = 3
            end
            object sttxt18: TStaticText
              Left = 22
              Top = 7
              Width = 601
              Height = 35
              AutoSize = False
              BiDiMode = bdLeftToRight
              Caption = '  Review Settings'
              Color = 15370833
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
            object btnGo: TBitBtn
              Left = 544
              Top = 302
              Width = 57
              Height = 25
              Action = actGo
              Caption = 'Go!'
              TabOrder = 3
            end
            object btnBack3: TBitBtn
              Left = 512
              Top = 302
              Width = 25
              Height = 25
              Action = actBackPage
              Caption = '<'
              TabOrder = 2
            end
            object mReviewSettings: TMemo
              Left = 120
              Top = 74
              Width = 377
              Height = 194
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
        object btnTMPstart: TButton
          Left = 128
          Top = 120
          Width = 75
          Height = 25
          Caption = 'btnTMPstart'
          TabOrder = 0
        end
        object btnTMPstop: TButton
          Left = 232
          Top = 120
          Width = 75
          Height = 25
          Caption = 'btnTMPstop'
          TabOrder = 1
        end
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
          Caption = 'General Log'
          Color = 5592556
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
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
        ImageIndex = 3
        object shp3: TShape
          Left = 87
          Top = 36
          Width = 309
          Height = 28
          Pen.Color = 671448
          Pen.Mode = pmMask
          Pen.Style = psInsideFrame
          Pen.Width = 3
        end
        object shp4: TShape
          Left = 488
          Top = 63
          Width = 228
          Height = 267
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 3
        end
        object shp2: TShape
          Left = 487
          Top = 37
          Width = 230
          Height = 27
          Pen.Color = 671448
          Pen.Mode = pmMask
          Pen.Style = psInsideFrame
          Pen.Width = 3
        end
        object shp5: TShape
          Left = 488
          Top = 376
          Width = 228
          Height = 75
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 3
        end
        object shp1: TShape
          Left = 487
          Top = 349
          Width = 230
          Height = 28
          Pen.Color = 671448
          Pen.Mode = pmMask
          Pen.Style = psInsideFrame
          Pen.Width = 3
        end
        object shp6: TShape
          Left = 88
          Top = 63
          Width = 307
          Height = 352
          Brush.Style = bsClear
          Pen.Color = clBtnShadow
          Pen.Width = 3
        end
        object txt2: TStaticText
          Left = 86
          Top = 35
          Width = 306
          Height = 25
          AutoSize = False
          Caption = '        Number of records in a table                 '
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
          Left = 486
          Top = 35
          Width = 227
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
          Top = 376
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
          Left = 486
          Top = 348
          Width = 227
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
          Left = 88
          Top = 63
          Width = 305
          Height = 350
          TabOrder = 2
          object shp7: TShape
            Left = 124
            Top = 329
            Width = 83
            Height = 2
            Brush.Color = clBtnShadow
            Pen.Color = clGrayText
          end
          object shp8: TShape
            Left = 213
            Top = 329
            Width = 82
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
            Caption = 'NOW'
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
            Left = -1
            Top = 159
            Width = 305
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
            Width = 82
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
            Width = 83
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
            Width = 83
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
            Width = 84
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
            Width = 82
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
            Width = 82
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
            Width = 82
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
            Width = 82
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
            Width = 83
            Height = 25
            Action = actGet
            Caption = 'Get'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 27
            TabStop = False
          end
          object btnUpdateStatistics: TBitBtn
            Left = 213
            Top = 305
            Width = 82
            Height = 25
            Action = actGet
            Caption = 'Update'
            TabOrder = 28
            TabStop = False
          end
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
      Left = 118
      Top = 518
      Width = 316
      Height = 18
      Min = 0
      Max = 100
      TabOrder = 3
    end
    object btnStop: TButton
      Left = 13
      Top = 519
      Width = 101
      Height = 17
      Action = actStop
      TabOrder = 4
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
    object actStop: TAction
      Caption = 'STOP'
      OnExecute = actStopExecute
      OnUpdate = actStopUpdate
    end
  end
end
