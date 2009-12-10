inherited gdc_dlgSetting: Tgdc_dlgSetting
  Left = 310
  Top = 188
  HelpContext = 127
  ActiveControl = dbeName
  Caption = 'Настройка'
  ClientHeight = 234
  ClientWidth = 385
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 10
    Width = 77
    Height = 13
    Caption = 'Наименование:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel [1]
    Left = 8
    Top = 34
    Width = 53
    Height = 13
    Caption = 'Описание:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel [2]
    Left = 8
    Top = 82
    Width = 39
    Height = 13
    Caption = 'Версия:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  inherited btnAccess: TButton
    Left = 8
    Top = 208
    TabOrder = 7
  end
  inherited btnNew: TButton
    Left = 80
    Top = 208
    Enabled = False
    TabOrder = 8
  end
  inherited btnOK: TButton
    Left = 232
    Top = 208
    TabOrder = 5
  end
  inherited btnCancel: TButton
    Left = 304
    Top = 208
    TabOrder = 6
  end
  inherited btnHelp: TButton
    Left = 152
    Top = 208
    TabOrder = 9
  end
  object dbeName: TDBEdit [8]
    Left = 104
    Top = 8
    Width = 273
    Height = 21
    DataField = 'name'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [9]
    Left = 104
    Top = 32
    Width = 273
    Height = 45
    DataField = 'description'
    DataSource = dsgdcBase
    TabOrder = 1
    OnEnter = dbmDescriptionEnter
    OnExit = dbmDescriptionExit
  end
  object dbeVersion: TDBEdit [10]
    Left = 104
    Top = 80
    Width = 121
    Height = 21
    DataField = 'version'
    DataSource = dsgdcBase
    ReadOnly = True
    TabOrder = 2
  end
  object dbcbEnding: TDBCheckBox [11]
    Left = 10
    Top = 112
    Width = 145
    Height = 17
    Caption = 'Конечная настройка'
    DataField = 'ending'
    DataSource = dsgdcBase
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
    OnClick = dbcbEndingClick
  end
  object pMinVersions: TPanel [12]
    Left = 0
    Top = 136
    Width = 385
    Height = 65
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    object Label4: TLabel
      Left = 11
      Top = 12
      Width = 174
      Height = 13
      Caption = 'Мин. версия исполняемого файла:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 11
      Top = 36
      Width = 136
      Height = 13
      Caption = 'Мин. версия базы данных:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object dbeMinExeVersion: TDBEdit
      Left = 216
      Top = 8
      Width = 137
      Height = 21
      DataField = 'minexeversion'
      DataSource = dsgdcBase
      TabOrder = 0
    end
    object btnCurExeVersion: TBitBtn
      Left = 352
      Top = 8
      Width = 29
      Height = 21
      Hint = 'Установить текущую версию'
      TabOrder = 1
      OnClick = btnCurExeVersionClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333444444
        33333333333F8888883F33330000324334222222443333388F3833333388F333
        000032244222222222433338F8833FFFFF338F3300003222222AAAAA22243338
        F333F88888F338F30000322222A33333A2224338F33F8333338F338F00003222
        223333333A224338F33833333338F38F00003222222333333A444338FFFF8F33
        3338888300003AAAAAAA33333333333888888833333333330000333333333333
        333333333333333333FFFFFF000033333333333344444433FFFF333333888888
        00003A444333333A22222438888F333338F3333800003A2243333333A2222438
        F38F333333833338000033A224333334422224338338FFFFF8833338000033A2
        22444442222224338F3388888333FF380000333A2222222222AA243338FF3333
        33FF88F800003333AA222222AA33A3333388FFFFFF8833830000333333AAAAAA
        3333333333338888883333330000333333333333333333333333333333333333
        0000}
      Layout = blGlyphBottom
      NumGlyphs = 2
    end
    object btnCurDBVersion: TBitBtn
      Left = 352
      Top = 32
      Width = 29
      Height = 21
      Hint = 'Установить текущую версию'
      TabOrder = 3
      OnClick = btnCurDBVersionClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333444444
        33333333333F8888883F33330000324334222222443333388F3833333388F333
        000032244222222222433338F8833FFFFF338F3300003222222AAAAA22243338
        F333F88888F338F30000322222A33333A2224338F33F8333338F338F00003222
        223333333A224338F33833333338F38F00003222222333333A444338FFFF8F33
        3338888300003AAAAAAA33333333333888888833333333330000333333333333
        333333333333333333FFFFFF000033333333333344444433FFFF333333888888
        00003A444333333A22222438888F333338F3333800003A2243333333A2222438
        F38F333333833338000033A224333334422224338338FFFFF8833338000033A2
        22444442222224338F3388888333FF380000333A2222222222AA243338FF3333
        33FF88F800003333AA222222AA33A3333388FFFFFF8833830000333333AAAAAA
        3333333333338888883333330000333333333333333333333333333333333333
        0000}
      Layout = blGlyphBottom
      NumGlyphs = 2
    end
    object dbeMinDBVersion: TDBEdit
      Left = 216
      Top = 32
      Width = 137
      Height = 21
      DataField = 'mindbversion'
      DataSource = dsgdcBase
      TabOrder = 2
    end
  end
  inherited alBase: TActionList
    Top = 65535
  end
  inherited dsgdcBase: TDataSource
    Top = 65535
  end
  inherited pm_dlgG: TPopupMenu
    Top = 0
  end
end
