object at_dlgLoadPackages: Tat_dlgLoadPackages
  Left = 122
  Top = 152
  BorderStyle = bsDialog
  Caption = 'Установка пакетов'
  ClientHeight = 313
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 536
    Height = 313
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object XPBevel1: TXPBevel
      Left = 0
      Top = 32
      Width = 537
      Height = 9
      Shape = bsTopLine
      Style = bsLowered
    end
    object sbSearch: TSpeedButton
      Left = 440
      Top = 8
      Width = 23
      Height = 21
      Action = actSearchGSF
      Glyph.Data = {
        42020000424D4202000000000000420000002800000010000000100000000100
        1000030000000002000000000000000000000000000000000000007C0000E003
        00001F0000001F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C3712F22509011F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C3712F22509011F7C37120901BC022F010901205E606A606A
        1F7C1F7C1F7C371209010D010E0109012D11BC023C0291010D010901606A606A
        205E1F7C1F7C333A09013C0237010D01090188000D010D019101EF3D807F007B
        007B205E1F7CCF218800370137010D018F010901D30191019101485E807F207F
        407FA472205E1F7C3125F501B2012F01AC31AF52F501F5015336807F917F487F
        487F407F606A1F7C1F7C31258F018F112C73E07A207F2C73487F807F917F957F
        487F487F606A1F7C1F7CA472207F807F487F207F007B207F207F487F807F917F
        917F487F606A1F7C1F7C1F7CA472207F807F487F207FE07A207FE072487F807F
        917FB77FA4721F7C1F7C1F7C1F7CA472207FB77F807F207FA4721F7C007BE072
        E072A4721F7C1F7C1F7C1F7C1F7C1F7C007BE072E072A4721F7C1F7C1F7C1F7C
        1F7C1F7C1F7C}
      Layout = blGlyphRight
    end
    object Label1: TLabel
      Left = 8
      Top = 40
      Width = 58
      Height = 13
      Caption = 'Настройки:'
    end
    object eSearchPath: TEdit
      Left = 8
      Top = 8
      Width = 433
      Height = 21
      TabOrder = 0
      Text = 'eSearchPath'
    end
    object btnBrowse: TButton
      Left = 472
      Top = 8
      Width = 57
      Height = 21
      Caption = 'Обзор...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object sgrGSF: TStringGrid
      Left = 8
      Top = 56
      Width = 289
      Height = 249
      ColCount = 1
      DefaultColWidth = 280
      DefaultRowHeight = 16
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
      TabOrder = 2
      OnClick = sgrGSFClick
      OnDrawCell = sgrGSFDrawCell
    end
    object mGSFInfo: TMemo
      Left = 304
      Top = 40
      Width = 225
      Height = 129
      TabStop = False
      Color = clBtnFace
      Lines.Strings = (
        'Name'
        'Comment'
        'Version'
        'Date')
      ScrollBars = ssVertical
      TabOrder = 3
    end
    object btnOk: TButton
      Left = 304
      Top = 280
      Width = 225
      Height = 25
      Cancel = True
      Caption = 'Закрыть'
      ModalResult = 1
      TabOrder = 6
    end
    object mExistSettInfo: TMemo
      Left = 304
      Top = 176
      Width = 225
      Height = 65
      TabStop = False
      Color = clBtnFace
      Lines.Strings = (
        'Настройка установлена'
        'Версия:'
        'Дата:')
      ScrollBars = ssVertical
      TabOrder = 4
    end
    object btnInstallPackage: TBitBtn
      Left = 304
      Top = 248
      Width = 225
      Height = 25
      Hint = 'Установка пакета в систему'
      Action = actInstallSetting
      Caption = 'Установить настройку'
      TabOrder = 5
      Glyph.Data = {
        42020000424D4202000000000000420000002800000010000000100000000100
        1000030000000002000000000000000000000000000000000000007C0000E003
        00001F0000001F7CFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F
        FF7FFF7F1F7CFF7FAA7E4349634D634D634D63516351634D634D434943494345
        2341A97EFF7FFF7F6351A35DC365C365C365C365C365C365C365C365A361A35D
        6351223DFF7FFF7F8355C365E36DE36DE3710372237A237A237A237AE36DA361
        83554345FF7FFF7FA361E36D037603760376107F237A237A237A237A0372C365
        A35D4349FF7FFF7FC3650372237A237E107FFF7F107F237A237A237A0372C369
        A361634DFF7FFF7FE36D237A237E107FFF7F107FFF7F107F237A237A0372C369
        C3656351FF7FFF7F0372237E107FFF7F107F237A237AFF7F107F0376E36DC365
        C3658355FF7FFF7F0376237E237E107F237A237A237A237AFF7F107FC369C365
        C3658355FF7FFF7F237E447E447E237E237E237A037A03760376FF7F107FC365
        C3658355FF7FFF7F237E877E877E447E437E237E237E03760372E36DFF7F107F
        C3658355FF7FFF7F447EAA7EA97E657E447E447E437E237A03760372E36DFF7F
        C3658355FF7FFF7F877EED7EAA7E877E667E657E657E447E237E037A0376E36D
        C3658355FF7FFF7FA97E107FED7EAA7EA97E877E667E657E447E437E237A0376
        C365634DFF7FFF7F757FA97E667E447E237E237E237A237A03760372E36DC365
        A35DCC7EFF7F1F7CFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F
        FF7FFF7F1F7C}
    end
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 496
    Top = 48
    object actSearchGSF: TAction
      Hint = 'Поиск файлов настроек по указанному пути'
      ImageIndex = 23
      ShortCut = 13
      OnExecute = actSearchGSFExecute
    end
    object actInstallSetting: TAction
      Caption = 'Установить настройку'
      Hint = 'Установка настройки в систему'
      ImageIndex = 38
      OnExecute = actInstallSettingExecute
      OnUpdate = actInstallSettingUpdate
    end
  end
end
