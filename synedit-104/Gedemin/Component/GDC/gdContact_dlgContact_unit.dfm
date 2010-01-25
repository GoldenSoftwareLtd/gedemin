object gdContact_dlgContact: TgdContact_dlgContact
  Left = 287
  Top = 252
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'йНМРЮЙР'
  ClientHeight = 363
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 352
    Top = 337
    Width = 76
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'нй'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 432
    Top = 337
    Width = 76
    Height = 20
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'нРЛЕМХРЭ'
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object pcContact: TPageControl
    Left = 5
    Top = 5
    Width = 504
    Height = 324
    ActivePage = tsGeneral
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = '&0 нАЫЕЕ'
      ImageIndex = 5
      object xLabel1: TxLabel
        Left = 4
        Top = 4
        Width = 488
        Height = 17
        Caption = ' нАЫЮЪ ХМТНПЛЮЖХЪ Н ЙНМРЮЙРЕ'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
      end
      object mInfoFields: TMemo
        Left = 4
        Top = 24
        Width = 109
        Height = 254
        Alignment = taRightJustify
        BorderStyle = bsNone
        Color = clBtnFace
        Lines.Strings = (
          '')
        ReadOnly = True
        TabOrder = 0
      end
      object dbcbDisabled: TDBCheckBox
        Left = 4
        Top = 279
        Width = 173
        Height = 17
        Caption = 'дЮММШИ ЙНМРЮЙР МЕ ЮЙРХБЕМ'
        DataField = 'DISABLED'
        TabOrder = 1
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object mInfoValues: TMemo
        Left = 111
        Top = 24
        Width = 109
        Height = 254
        BorderStyle = bsNone
        Color = clBtnFace
        Lines.Strings = (
          '')
        ReadOnly = True
        TabOrder = 2
      end
    end
    object tsName: TTabSheet
      Caption = '&1 хЛЪ'
      object Label6: TLabel
        Left = 8
        Top = 65
        Width = 23
        Height = 13
        Caption = 'хЛЪ:'
      end
      object Label8: TLabel
        Left = 8
        Top = 113
        Width = 35
        Height = 13
        Caption = 'щЙПЮМ:'
      end
      object Label9: TLabel
        Left = 8
        Top = 89
        Width = 53
        Height = 13
        Caption = 'нРВЕЯРБН:'
      end
      object Label10: TLabel
        Left = 8
        Top = 41
        Width = 48
        Height = 13
        Caption = 'тЮЛХКХЪ:'
      end
      object Label7: TLabel
        Left = 8
        Top = 137
        Width = 47
        Height = 13
        Caption = 'йНПНРЙН:'
      end
      object SpeedButton7: TSpeedButton
        Left = 327
        Top = 108
        Width = 21
        Height = 21
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FF000000000000000000000000FF00FFFF00FFFF
          00FFFF00FF000000000000000000000000FF00FFFF00FFFF00FFFF00FF000000
          FFFFFF000000000000FF00FFFF00FFFF00FFFF00FF000000FFFFFF0000000000
          00FF00FFFF00FFFF00FFFF00FF000000FFFFFF000000000000FF00FFFF00FFFF
          00FFFF00FF000000FFFFFF000000000000FF00FFFF00FFFF00FFFF00FF000000
          000000000000000000000000000000FF00FF0000000000000000000000000000
          00FF00FFFF00FFFF00FFFF00FF00000000000000000000000000000000000000
          0000FFFFFF000000000000000000000000FF00FFFF00FFFF00FFFF00FF000000
          000000000000000000000000FF00FF000000FFFFFF0000000000000000000000
          00FF00FFFF00FFFF00FFFF00FFFF00FF00000000000000000000000000000000
          0000000000000000000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFFFFFF000000000000000000FF00FFFFFFFF000000000000000000FF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000000000000000000000FF
          00FF000000000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FF000000000000000000FF00FFFF00FF000000000000000000FF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000000000000000FF00FFFF
          00FF000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
      end
      object xLabel2: TxLabel
        Left = 4
        Top = 4
        Width = 488
        Height = 17
        Caption = ' тЮЛХКХЪ, ХЛЪ, НРВЕЯРБН. юДПЕЯ ЩКЕЙРПНММНИ ОНВРШ'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
      end
      object dbeFirstName: TDBEdit
        Left = 68
        Top = 60
        Width = 261
        Height = 21
        DataField = 'FIRSTNAME'
        DataSource = dsContact
        TabOrder = 1
        OnChange = dbeSurnameChange
      end
      object dbeMiddleName: TDBEdit
        Left = 68
        Top = 84
        Width = 261
        Height = 21
        DataField = 'MIDDLENAME'
        DataSource = dsContact
        TabOrder = 2
        OnChange = dbeSurnameChange
      end
      object dbeSurname: TDBEdit
        Left = 68
        Top = 36
        Width = 261
        Height = 21
        DataField = 'SURNAME'
        DataSource = dsContact
        TabOrder = 0
        OnChange = dbeSurnameChange
      end
      object dbeNickName: TDBEdit
        Left = 68
        Top = 132
        Width = 261
        Height = 21
        DataField = 'NICKNAME'
        DataSource = dsContact
        TabOrder = 4
      end
      object dbgrEmail: TDBGrid
        Left = 6
        Top = 157
        Width = 322
        Height = 137
        DataSource = dsEmail
        Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete]
        TabOrder = 5
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object dbeName: TDBEdit
        Left = 68
        Top = 108
        Width = 261
        Height = 21
        DataField = 'NAME'
        DataSource = dsContact
        TabOrder = 3
        OnChange = dbeNameChange
        OnExit = dbeNameExit
      end
    end
    object TabSheet2: TTabSheet
      Caption = '&2 дНЛ'
      ImageIndex = 1
      object Label12: TLabel
        Left = 5
        Top = 64
        Width = 35
        Height = 13
        Caption = 'юДПЕЯ:'
      end
      object Label13: TLabel
        Left = 256
        Top = 64
        Width = 35
        Height = 13
        Caption = 'цНПНД:'
      end
      object Label14: TLabel
        Left = 256
        Top = 89
        Width = 47
        Height = 13
        Caption = 'нАКЮЯРЭ:'
      end
      object Label15: TLabel
        Left = 5
        Top = 114
        Width = 41
        Height = 13
        Caption = 'хМДЕЙЯ:'
      end
      object Label16: TLabel
        Left = 256
        Top = 114
        Width = 41
        Height = 13
        Caption = 'яРПЮМЮ:'
      end
      object Label17: TLabel
        Left = 10
        Top = 252
        Width = 34
        Height = 13
        Caption = 'WWW:'
      end
      object Label18: TLabel
        Left = 5
        Top = 139
        Width = 48
        Height = 13
        Caption = 'рЕКЕТНМ:'
      end
      object Label19: TLabel
        Left = 256
        Top = 139
        Width = 29
        Height = 13
        Caption = 'тЮЙЯ:'
      end
      object Label20: TLabel
        Left = 5
        Top = 164
        Width = 49
        Height = 13
        Caption = 'яНРНБШИ:'
      end
      object SpeedButton2: TSpeedButton
        Left = 455
        Top = 61
        Width = 18
        Height = 21
        Caption = '...'
      end
      object SpeedButton1: TSpeedButton
        Left = 455
        Top = 85
        Width = 18
        Height = 21
        Caption = '...'
      end
      object SpeedButton3: TSpeedButton
        Left = 455
        Top = 110
        Width = 18
        Height = 21
        Caption = '...'
      end
      object xLabel3: TxLabel
        Left = 4
        Top = 4
        Width = 488
        Height = 17
        Caption = ' дНЛЮЬМХИ ЮДПЕЯ'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
      end
      object btnGoHome: TButton
        Left = 404
        Top = 248
        Width = 71
        Height = 21
        Caption = 'оЕПЕИРХ'
        TabOrder = 9
      end
      object dbmHAddress: TDBMemo
        Left = 65
        Top = 60
        Width = 160
        Height = 46
        DataField = 'HADDRESS'
        DataSource = dsContact
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object dbHZIP: TDBEdit
        Left = 65
        Top = 110
        Width = 160
        Height = 21
        DataField = 'HZIP'
        DataSource = dsContact
        TabOrder = 3
      end
      object dbHWWW: TDBEdit
        Left = 66
        Top = 248
        Width = 334
        Height = 21
        DataField = 'HURL'
        DataSource = dsContact
        TabOrder = 8
      end
      object dbHPhone: TDBEdit
        Left = 65
        Top = 135
        Width = 160
        Height = 21
        DataField = 'HPHONE'
        DataSource = dsContact
        TabOrder = 5
      end
      object dbHFax: TDBEdit
        Left = 315
        Top = 135
        Width = 160
        Height = 21
        DataField = 'HFAX'
        DataSource = dsContact
        TabOrder = 6
      end
      object DBEdit13: TDBEdit
        Left = 65
        Top = 160
        Width = 160
        Height = 21
        DataField = 'WHANDY'
        DataSource = dsContact
        TabOrder = 7
      end
      object dbcbHCity: TDBComboBox
        Left = 315
        Top = 60
        Width = 139
        Height = 21
        DataField = 'HCITY'
        DataSource = dsContact
        ItemHeight = 13
        Items.Strings = (
          'аюпюмнбхвх'
          'аюпюмнбхвяйхи п-м '
          'аюпюмэ '
          'аекннгепяй '
          'аекшмхвх '
          'аекшмхвяйхи п-м '
          'аепегю '
          'аепегхмн '
          'аепегхмяйхи п-м '
          'аепегнбяйхи п-м '
          'аепеярнбхжю '
          'аепеярнбхжйхи п-м '
          'аеьемйнбхвх '
          'аеьемйнбхвяйхи п-м '
          'анапсияй '
          'анапсияйхи п-м '
          'анпхянб '
          'анпхянбяйхи п-м '
          'апюцхм'
          'апюцхмяйхи п-м '
          'апюякюб '
          'апюякюбяйхи п-м '
          'апеяр '
          'апеяряйхи п-м '
          'асдю-йньекебн '
          'асдю-йньекебяйхи п-м '
          'ашунб '
          'ашунбяйхи п-м '
          'бепумедбхмяй '
          'бепумедбхмяйхи п-м '
          'берйю '
          'берйнбяйхи п-м '
          'бхкеийю '
          'бхкеияйхи п-м '
          'бхреаяй '
          'бхреаяйхи п-м '
          'бнкйнбшяй'
          'бнкйнбшяяйхи п-м '
          'бнкнфхм '
          'бнкнфхмяйхи п-м '
          'бнпнмнбн '
          'бнпнмнбяйхи п-м '
          'цюмжебхвх '
          'цюмжебхвяйхи п-м '
          'цксанйне '
          'цксанйяйхи п-м '
          'цксяй '
          'цксяяйхи п-м '
          'цнлекэ '
          'цнлекэяйхи п-м '
          'цнпежйхи п-м '
          'цнпйх '
          'цнпйх-2 '
          'цнпндеъ '
          'цнпнднй'
          'цнпнднйяйхи п-м '
          'цпндмемяйхи п-м '
          'цпндмн '
          'цПНДМН '
          'дгепфхмяй '
          'дгепфхмяйхи п-м '
          'днапсь '
          'днапсьяйхи п-м '
          'днйьхжйхи п-м '
          'днйьхжш '
          'дпхахм '
          'дпхахмяйхи п-м '
          'дпнцхвхм '
          'дпнцхвхмяйхи п-м '
          'дсапнбемяйхи п-м '
          'дсапнбмн '
          'дъркнбн '
          'дъркнбяйхи п-м'
          'екэяй '
          'екэяйхи п-м '
          'фюахмйю '
          'фюахмйнбяйхи п-м '
          'фхрйнбхвх '
          'фхрйнбхвяйхи п-м '
          'фкнахм '
          'фкнахмяйхи п-м '
          'фндхмн '
          'гюякюбкэ '
          'гекэбю '
          'гекэбемяйхи п-м '
          'хбюмнбн '
          'хбюмнбяйхи п-м '
          'хбюжебхвх '
          'хбюжебхвяйхи п-м '
          'хбэе '
          'хбэебяйхи п-м'
          'йюкхмйнбхвх '
          'йюкхмйнбхвяйхи п-м '
          'йюлемеж '
          'йюлемежйхи п-м '
          'йхпнбяй '
          'йхпнбяйхи п-м '
          'йкежй '
          'йкежйхи п-м '
          'йкхлнбхвх '
          'йкхлнбхвяйхи п-м '
          'йкхвеб '
          'йкхвебяйхи п-м '
          'йнапхм '
          'йнапхмяйхи п-м '
          'йношкэ '
          'йношкэяйхи п-м '
          'йнпекхвх '
          'йнпекхвяйхи п-м'
          'йнплю '
          'йнплъмяйхи п-м '
          'йнярчйнбхвх '
          'йнярчйнбхвяйхи п-м '
          'йпюямнонкэе '
          'йпюямнонкэяйхи п-м '
          'йпхбхвх '
          'йпхвеб '
          'йпхвебяйхи п-м '
          'йпсцкне '
          'йпсцкъмяйхи п-м '
          'йпсойх '
          'йпсояйхи п-м '
          'кекэвхжйхи п-м '
          'кекэвхжш '
          'кеоекэ '
          'кеоекэяйхи п-м '
          'кхдю'
          'кхдяйхи п-м '
          'кхнгмемяйхи п-м '
          'кхнгмн '
          'кнцнияй '
          'кнцнияйхи п-м '
          'кнеб '
          'кнебяйхи п-м '
          'ксмхмеж '
          'ксмхмежйхи п-м '
          'кчаюмяйхи п-м '
          'кчаюмэ '
          'къунбхвх '
          'къунбхвяйхи п-м '
          'люкнпхрю '
          'люкнпхряйхи п-м '
          'люпэхмю цнпйю '
          'люпэхмю цнпйю-4 '
          'лхмяй'
          'лхмяй-98 '
          'лхмяйхи п-м '
          'лхнпяйхи п-м '
          'лхнпш '
          'лнцхкеб '
          'лнцхкебяйхи п-м '
          'лнгшпяйхи п-м '
          'лнгшпэ '
          'лнкндевмемяйхи п-м '
          'лнкндевмн '
          'лнярнбяйхи п-м '
          'лнярш '
          'лярхякюбкэ '
          'лярхякюбяйхи п-м '
          'лъдекэ '
          'лъдекэяйхи п-м '
          'мюпнбкъ '
          'мюпнбкъмяйхи п-м'
          'меябхф '
          'меябхфяйхи п-м '
          'мнбнцпсднй '
          'мнбнцпсдяйхи п-м '
          'мнбнксйнлкэ '
          'мнбнонкнжй '
          'нйръапэяйхи '
          'нйръапэяйхи п-м '
          'нпью '
          'нпьюмяйхи п-м '
          'няхонбхвх '
          'няхонбхвяйхи п-м '
          'нярпнбеж '
          'нярпнбежйхи п-м '
          'ньлъмяйхи п-м '
          'ньлъмш '
          'оерпхйнб '
          'оерпхйнбяйхи п-м'
          'охмяй '
          'охмяйхи п-м '
          'онкнжй '
          'онкнжйхи п-м '
          'онярюбяйхи п-м '
          'онярюбш '
          'опсфюмяйхи п-м '
          'опсфюмш '
          'осунбхвх '
          'осунбхвяйхи п-м '
          'певхжю '
          'певхжйхи п-м '
          'пнцювеб '
          'пнцювебяйхи п-м '
          'пняянмяйхи п-м '
          'пняянмш '
          'яберкюцнпяй '
          'яберкнцнпяй'
          'яберкнцнпяйхи п-м '
          'ябхякнвяйхи п-м '
          'ябхякнвэ '
          'яеммемяйхи п-м '
          'яеммн '
          'яйхдекэ '
          'якюбцнпнд '
          'якюбцнпндяйхи п-м '
          'якнмхл '
          'якнмхляйхи п-м '
          'яксжй '
          'яксжйхи п-м '
          'ялнкебхвх '
          'ялнкебхвяйхи п-м '
          'ялнпцнмяйхи п-м '
          'ялнпцнмэ '
          'янкхцнпяй '
          'янкхцнпяй-4'
          'янкхцнпяйхи п-м '
          'ярюпнахм '
          'ярюпнднпнфяйхи п-м '
          'ярюпше днпнцх '
          'ярнкажнбяйхи п-м '
          'ярнкажш '
          'ярнкхм '
          'ярнкхмяйхи п-м '
          'рнкнвхм '
          'рнкнвхмяйхи п-м '
          'сгдю '
          'сгдемяйхи п-м '
          'сйпюхмю '
          'сьювх '
          'сьювяйхи п-м '
          'унимхйх '
          'унимхйяйхи п-м '
          'унрхляй'
          'унрхляйхи п-м '
          'вюсяяйхи п-м'
          'вюсяш'
          'вюьмхйх'
          'вюьмхйяйхи п-м'
          'вепбемяйхи п-м'
          'вепбемэ'
          'вепхйнб'
          'вепхйнбяйхи п-м'
          'вевепяй'
          'вевепяйхи п-м'
          'ьюпйнбыхмю'
          'ьюпйнбыхмяйхи п-м'
          'ьйкнб'
          'ьйкнбяйхи п-м'
          'ьслхкхмн'
          'ьслхкхмяйхи п-м'
          'ысвхм'
          'ысвхмяйхи п-м')
        Sorted = True
        TabOrder = 1
      end
      object dbcbHRegion: TDBComboBox
        Left = 315
        Top = 85
        Width = 139
        Height = 21
        DataField = 'HREGION'
        DataSource = dsContact
        ItemHeight = 13
        Items.Strings = (
          'апеярйюъ'
          'бхреаяйюъ'
          'цнлекэяйюъ'
          'цпндмемяйюъ'
          'лхмяйюъ'
          'лнцхкебяйюъ')
        Sorted = True
        TabOrder = 2
      end
      object dbcbHCountry: TDBComboBox
        Left = 315
        Top = 110
        Width = 139
        Height = 21
        DataField = 'HCOUNTRY'
        DataSource = dsContact
        ItemHeight = 13
        Items.Strings = (
          'па'
          'пНЯЯХЪ')
        Sorted = True
        TabOrder = 4
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&3 пЮАНРЮ'
      ImageIndex = 2
      object Label21: TLabel
        Left = 5
        Top = 40
        Width = 36
        Height = 13
        Caption = 'тХПЛЮ:'
      end
      object Label22: TLabel
        Left = 244
        Top = 40
        Width = 35
        Height = 13
        Caption = 'юДПЕЯ:'
      end
      object Label23: TLabel
        Left = 5
        Top = 65
        Width = 35
        Height = 13
        Caption = 'цНПНД:'
      end
      object Label24: TLabel
        Left = 5
        Top = 90
        Width = 47
        Height = 13
        Caption = 'нАКЮЯРЭ:'
      end
      object Label25: TLabel
        Left = 5
        Top = 115
        Width = 41
        Height = 13
        Caption = 'хМДЕЙЯ:'
      end
      object Label26: TLabel
        Left = 244
        Top = 115
        Width = 41
        Height = 13
        Caption = 'яРПЮМЮ:'
      end
      object Label27: TLabel
        Left = 5
        Top = 260
        Width = 34
        Height = 13
        Caption = 'WWW:'
      end
      object Label28: TLabel
        Left = 5
        Top = 140
        Width = 61
        Height = 13
        Caption = 'дНКФМНЯРЭ:'
      end
      object Label29: TLabel
        Left = 244
        Top = 140
        Width = 37
        Height = 13
        Caption = 'нРДЕК:'
      end
      object Label30: TLabel
        Left = 5
        Top = 165
        Width = 31
        Height = 13
        Caption = 'нТХЯ:'
      end
      object Label31: TLabel
        Left = 244
        Top = 165
        Width = 48
        Height = 13
        Caption = 'рЕКЕТНМ:'
      end
      object Label32: TLabel
        Left = 5
        Top = 190
        Width = 29
        Height = 13
        Caption = 'тЮЙЯ:'
      end
      object Label33: TLabel
        Left = 244
        Top = 190
        Width = 49
        Height = 13
        Caption = 'оЩИДФЕП:'
      end
      object Label34: TLabel
        Left = 5
        Top = 215
        Width = 61
        Height = 13
        Caption = 'IP рЕКЕТНМ:'
      end
      object Label63: TLabel
        Left = 5
        Top = 240
        Width = 53
        Height = 13
        Caption = 'йНЛОЮМХЪ:'
      end
      object SpeedButton4: TSpeedButton
        Left = 219
        Top = 61
        Width = 18
        Height = 21
        Caption = '...'
      end
      object SpeedButton5: TSpeedButton
        Left = 219
        Top = 86
        Width = 18
        Height = 21
        Caption = '...'
      end
      object SpeedButton6: TSpeedButton
        Left = 454
        Top = 110
        Width = 18
        Height = 22
        Caption = '...'
      end
      object xLabel4: TxLabel
        Left = 4
        Top = 4
        Width = 488
        Height = 17
        Caption = ' пЮАНВХИ ЮДПЕЯ'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
      end
      object dbCompanyname: TDBEdit
        Left = 75
        Top = 36
        Width = 162
        Height = 21
        DataField = 'WCOMPANYNAME'
        DataSource = dsContact
        TabOrder = 0
      end
      object dbmWAddress: TDBMemo
        Left = 311
        Top = 36
        Width = 162
        Height = 71
        DataField = 'ADDRESS'
        DataSource = dsContact
        ScrollBars = ssVertical
        TabOrder = 3
      end
      object dbWZIP: TDBEdit
        Left = 75
        Top = 111
        Width = 162
        Height = 21
        DataField = 'ZIP'
        DataSource = dsContact
        TabOrder = 4
      end
      object dbWWW: TDBEdit
        Left = 67
        Top = 255
        Width = 326
        Height = 21
        DataField = 'URL'
        DataSource = dsContact
        TabOrder = 14
      end
      object btnGoWork: TButton
        Left = 405
        Top = 255
        Width = 68
        Height = 21
        Caption = 'оЕПЕИРХ'
        TabOrder = 13
      end
      object dbRank: TDBEdit
        Left = 75
        Top = 136
        Width = 162
        Height = 21
        DataField = 'RANK'
        DataSource = dsContact
        TabOrder = 6
      end
      object dbWDepartment: TDBEdit
        Left = 311
        Top = 136
        Width = 162
        Height = 21
        DataField = 'WDEPARTMENT'
        DataSource = dsContact
        TabOrder = 7
      end
      object dbWOffice: TDBEdit
        Left = 75
        Top = 161
        Width = 162
        Height = 21
        DataField = 'WOFFICE'
        DataSource = dsContact
        TabOrder = 8
      end
      object dbWPhone: TDBEdit
        Left = 311
        Top = 161
        Width = 162
        Height = 21
        DataField = 'PHONE'
        DataSource = dsContact
        TabOrder = 9
      end
      object dbWFax: TDBEdit
        Left = 75
        Top = 186
        Width = 162
        Height = 21
        DataField = 'FAX'
        DataSource = dsContact
        TabOrder = 10
      end
      object dbWPager: TDBEdit
        Left = 311
        Top = 186
        Width = 162
        Height = 21
        DataField = 'WPAGER'
        DataSource = dsContact
        TabOrder = 11
      end
      object dbIPPhone: TDBEdit
        Left = 75
        Top = 211
        Width = 162
        Height = 21
        DataField = 'IPPHONE'
        DataSource = dsContact
        TabOrder = 12
      end
      object dbcbWCity: TDBComboBox
        Left = 75
        Top = 61
        Width = 143
        Height = 21
        DataField = 'CITY'
        DataSource = dsContact
        ItemHeight = 13
        Items.Strings = (
          'аюпюмнбхвх'
          'аюпюмнбхвяйхи п-м '
          'аюпюмэ '
          'аекннгепяй '
          'аекшмхвх '
          'аекшмхвяйхи п-м '
          'аепегю '
          'аепегхмн '
          'аепегхмяйхи п-м '
          'аепегнбяйхи п-м '
          'аепеярнбхжю '
          'аепеярнбхжйхи п-м '
          'аеьемйнбхвх '
          'аеьемйнбхвяйхи п-м '
          'анапсияй '
          'анапсияйхи п-м '
          'анпхянб '
          'анпхянбяйхи п-м '
          'апюцхм'
          'апюцхмяйхи п-м '
          'апюякюб '
          'апюякюбяйхи п-м '
          'апеяр '
          'апеяряйхи п-м '
          'асдю-йньекебн '
          'асдю-йньекебяйхи п-м '
          'ашунб '
          'ашунбяйхи п-м '
          'бепумедбхмяй '
          'бепумедбхмяйхи п-м '
          'берйю '
          'берйнбяйхи п-м '
          'бхкеийю '
          'бхкеияйхи п-м '
          'бхреаяй '
          'бхреаяйхи п-м '
          'бнкйнбшяй'
          'бнкйнбшяяйхи п-м '
          'бнкнфхм '
          'бнкнфхмяйхи п-м '
          'бнпнмнбн '
          'бнпнмнбяйхи п-м '
          'цюмжебхвх '
          'цюмжебхвяйхи п-м '
          'цксанйне '
          'цксанйяйхи п-м '
          'цксяй '
          'цксяяйхи п-м '
          'цнлекэ '
          'цнлекэяйхи п-м '
          'цнпежйхи п-м '
          'цнпйх '
          'цнпйх-2 '
          'цнпндеъ '
          'цнпнднй'
          'цнпнднйяйхи п-м '
          'цпндмемяйхи п-м '
          'цПНДМН '
          'цпндмн '
          'дгепфхмяй '
          'дгепфхмяйхи п-м '
          'днапсь '
          'днапсьяйхи п-м '
          'днйьхжйхи п-м '
          'днйьхжш '
          'дпхахм '
          'дпхахмяйхи п-м '
          'дпнцхвхм '
          'дпнцхвхмяйхи п-м '
          'дсапнбемяйхи п-м '
          'дсапнбмн '
          'дъркнбн '
          'дъркнбяйхи п-м'
          'екэяй '
          'екэяйхи п-м '
          'фюахмйю '
          'фюахмйнбяйхи п-м '
          'фхрйнбхвх '
          'фхрйнбхвяйхи п-м '
          'фкнахм '
          'фкнахмяйхи п-м '
          'фндхмн '
          'гюякюбкэ '
          'гекэбю '
          'гекэбемяйхи п-м '
          'хбюмнбн '
          'хбюмнбяйхи п-м '
          'хбюжебхвх '
          'хбюжебхвяйхи п-м '
          'хбэе '
          'хбэебяйхи п-м'
          'йюкхмйнбхвх '
          'йюкхмйнбхвяйхи п-м '
          'йюлемеж '
          'йюлемежйхи п-м '
          'йхпнбяй '
          'йхпнбяйхи п-м '
          'йкежй '
          'йкежйхи п-м '
          'йкхлнбхвх '
          'йкхлнбхвяйхи п-м '
          'йкхвеб '
          'йкхвебяйхи п-м '
          'йнапхм '
          'йнапхмяйхи п-м '
          'йношкэ '
          'йношкэяйхи п-м '
          'йнпекхвх '
          'йнпекхвяйхи п-м'
          'йнплю '
          'йнплъмяйхи п-м '
          'йнярчйнбхвх '
          'йнярчйнбхвяйхи п-м '
          'йпюямнонкэе '
          'йпюямнонкэяйхи п-м '
          'йпхбхвх '
          'йпхвеб '
          'йпхвебяйхи п-м '
          'йпсцкне '
          'йпсцкъмяйхи п-м '
          'йпсойх '
          'йпсояйхи п-м '
          'кекэвхжйхи п-м '
          'кекэвхжш '
          'кеоекэ '
          'кеоекэяйхи п-м '
          'кхдю'
          'кхдяйхи п-м '
          'кхнгмемяйхи п-м '
          'кхнгмн '
          'кнцнияй '
          'кнцнияйхи п-м '
          'кнеб '
          'кнебяйхи п-м '
          'ксмхмеж '
          'ксмхмежйхи п-м '
          'кчаюмяйхи п-м '
          'кчаюмэ '
          'къунбхвх '
          'къунбхвяйхи п-м '
          'люкнпхрю '
          'люкнпхряйхи п-м '
          'люпэхмю цнпйю '
          'люпэхмю цнпйю-4 '
          'лхмяй'
          'лхмяй-98 '
          'лхмяйхи п-м '
          'лхнпяйхи п-м '
          'лхнпш '
          'лнцхкеб '
          'лнцхкебяйхи п-м '
          'лнгшпяйхи п-м '
          'лнгшпэ '
          'лнкндевмемяйхи п-м '
          'лнкндевмн '
          'лнярнбяйхи п-м '
          'лнярш '
          'лярхякюбкэ '
          'лярхякюбяйхи п-м '
          'лъдекэ '
          'лъдекэяйхи п-м '
          'мюпнбкъ '
          'мюпнбкъмяйхи п-м'
          'меябхф '
          'меябхфяйхи п-м '
          'мнбнцпсднй '
          'мнбнцпсдяйхи п-м '
          'мнбнксйнлкэ '
          'мнбнонкнжй '
          'нйръапэяйхи '
          'нйръапэяйхи п-м '
          'нпью '
          'нпьюмяйхи п-м '
          'няхонбхвх '
          'няхонбхвяйхи п-м '
          'нярпнбеж '
          'нярпнбежйхи п-м '
          'ньлъмяйхи п-м '
          'ньлъмш '
          'оерпхйнб '
          'оерпхйнбяйхи п-м'
          'охмяй '
          'охмяйхи п-м '
          'онкнжй '
          'онкнжйхи п-м '
          'онярюбяйхи п-м '
          'онярюбш '
          'опсфюмяйхи п-м '
          'опсфюмш '
          'осунбхвх '
          'осунбхвяйхи п-м '
          'певхжю '
          'певхжйхи п-м '
          'пнцювеб '
          'пнцювебяйхи п-м '
          'пняянмяйхи п-м '
          'пняянмш '
          'яберкюцнпяй '
          'яберкнцнпяй'
          'яберкнцнпяйхи п-м '
          'ябхякнвяйхи п-м '
          'ябхякнвэ '
          'яеммемяйхи п-м '
          'яеммн '
          'яйхдекэ '
          'якюбцнпнд '
          'якюбцнпндяйхи п-м '
          'якнмхл '
          'якнмхляйхи п-м '
          'яксжй '
          'яксжйхи п-м '
          'ялнкебхвх '
          'ялнкебхвяйхи п-м '
          'ялнпцнмяйхи п-м '
          'ялнпцнмэ '
          'янкхцнпяй '
          'янкхцнпяй-4'
          'янкхцнпяйхи п-м '
          'ярюпнахм '
          'ярюпнднпнфяйхи п-м '
          'ярюпше днпнцх '
          'ярнкажнбяйхи п-м '
          'ярнкажш '
          'ярнкхм '
          'ярнкхмяйхи п-м '
          'рнкнвхм '
          'рнкнвхмяйхи п-м '
          'сгдю '
          'сгдемяйхи п-м '
          'сйпюхмю '
          'сьювх '
          'сьювяйхи п-м '
          'унимхйх '
          'унимхйяйхи п-м '
          'унрхляй'
          'унрхляйхи п-м '
          'вюсяяйхи п-м'
          'вюсяш'
          'вюьмхйх'
          'вюьмхйяйхи п-м'
          'вепбемяйхи п-м'
          'вепбемэ'
          'вепхйнб'
          'вепхйнбяйхи п-м'
          'вевепяй'
          'вевепяйхи п-м'
          'ьюпйнбыхмю'
          'ьюпйнбыхмяйхи п-м'
          'ьйкнб'
          'ьйкнбяйхи п-м'
          'ьслхкхмн'
          'ьслхкхмяйхи п-м'
          'ысвхм'
          'ысвхмяйхи п-м')
        Sorted = True
        TabOrder = 1
      end
      object dbcbWRegion: TDBComboBox
        Left = 75
        Top = 86
        Width = 143
        Height = 21
        DataField = 'REGION'
        DataSource = dsContact
        ItemHeight = 13
        Items.Strings = (
          'апеярйюъ'
          'бхреаяйюъ'
          'цнлекэяйюъ'
          'цпндмемяйюъ'
          'лхмяйюъ'
          'лнцхкебяйюъ')
        Sorted = True
        TabOrder = 2
      end
      object dbcbWCountry: TDBComboBox
        Left = 311
        Top = 111
        Width = 143
        Height = 21
        DataField = 'COUNTRY'
        DataSource = dsContact
        ItemHeight = 13
        Items.Strings = (
          'па'
          'пНЯЯХЪ')
        Sorted = True
        TabOrder = 5
      end
    end
    object TabSheet4: TTabSheet
      Caption = '&4 кХВМНЕ'
      ImageIndex = 3
      object Label35: TLabel
        Left = 5
        Top = 32
        Width = 54
        Height = 13
        Caption = 'яСОПСЦ(Ю):'
      end
      object Label36: TLabel
        Left = 5
        Top = 58
        Width = 30
        Height = 13
        Caption = 'дЕРХ:'
      end
      object Label37: TLabel
        Left = 5
        Top = 144
        Width = 23
        Height = 13
        Caption = 'оНК:'
      end
      object Label38: TLabel
        Left = 197
        Top = 138
        Width = 84
        Height = 13
        Caption = 'дЕМЭ ПНФДЕМХЪ:'
      end
      object Label39: TLabel
        Left = 5
        Top = 187
        Width = 65
        Height = 13
        Caption = 'йНЛЛЕМРЮПХИ:'
      end
      object xLabel5: TxLabel
        Left = 4
        Top = 4
        Width = 488
        Height = 17
        Caption = ' кХВМШЕ ЯБЕДЕМХЪ'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
      end
      object dbCouple: TDBEdit
        Left = 71
        Top = 28
        Width = 296
        Height = 21
        DataField = 'SPOUSE'
        DataSource = dsContact
        TabOrder = 0
      end
      object DBGrid1: TDBGrid
        Left = 72
        Top = 56
        Width = 297
        Height = 73
        DataSource = dsChildren
        Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete]
        TabOrder = 1
        TitleFont.Charset = RUSSIAN_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object cbSex: TComboBox
        Left = 71
        Top = 140
        Width = 106
        Height = 21
        ItemHeight = 13
        TabOrder = 2
        Items.Strings = (
          'мЕ НОПЕДЕКЕМ'
          'лСФЯЙНИ'
          'фЕМЯЙХИ')
      end
      object dbmComentary: TDBMemo
        Left = 5
        Top = 208
        Width = 470
        Height = 74
        DataField = 'NOTE'
        DataSource = dsContact
        TabOrder = 3
      end
    end
    object TabSheet8: TTabSheet
      Caption = '&5 бХГХРЙЮ, ТНРН'
      ImageIndex = 9
      object Label70: TLabel
        Left = 5
        Top = 315
        Width = 421
        Height = 13
        Caption = 
          'бМХЛЮМХЕ: ПЕЙНЛЕМДСЕЛНЕ ПЮГПЕЬЕМХЕ ОПХ ЯЙЮМХПНБЮМХХ 100 РНВЕЙ МЮ' +
          ' ДЧИЛ (DPI)'
      end
      object xLabel6: TxLabel
        Left = 4
        Top = 4
        Width = 488
        Height = 17
        Caption = ' бХГХРМЮЪ ЙЮПРНВЙЮ, ТНРНЦПЮТХЪ'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
      end
      object Button4: TButton
        Left = 395
        Top = 80
        Width = 84
        Height = 20
        Caption = 'яЙЮМХПНБЮРЭ'
        TabOrder = 0
      end
      object Button5: TButton
        Left = 395
        Top = 110
        Width = 84
        Height = 20
        Caption = 'гЮЦПСГХРЭ'
        TabOrder = 1
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 395
        Top = 140
        Width = 84
        Height = 20
        Caption = 'нВХЯРХРЭ'
        TabOrder = 2
        OnClick = Button6Click
      end
      object pcPhoto: TPageControl
        Left = 3
        Top = 29
        Width = 385
        Height = 265
        ActivePage = tsVis1
        Style = tsFlatButtons
        TabOrder = 3
        object tsVis1: TTabSheet
          Caption = 'бХГХРЙЮ 1'
          object dbiVis1: TDBImage
            Left = 0
            Top = 0
            Width = 377
            Height = 234
            Align = alClient
            DataField = 'VISITCARD'
            DataSource = dsContact
            TabOrder = 0
          end
        end
        object tsVis2: TTabSheet
          Caption = 'бХГХРЙЮ 2'
          ImageIndex = 1
          object dbiVis2: TDBImage
            Left = 0
            Top = 0
            Width = 281
            Height = 162
            Align = alClient
            DataField = 'VISITCARD2'
            DataSource = dsContact
            TabOrder = 0
          end
        end
        object tsPhoto: TTabSheet
          Caption = 'тНРН'
          ImageIndex = 2
          object dbiPhoto: TDBImage
            Left = 0
            Top = 0
            Width = 281
            Height = 162
            Align = alClient
            DataField = 'PHOTO'
            DataSource = dsContact
            TabOrder = 0
          end
        end
      end
    end
  end
  object Button1: TButton
    Left = 5
    Top = 337
    Width = 76
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'яОПЮБЙЮ'
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOKClick
  end
  object Button2: TButton
    Left = 85
    Top = 337
    Width = 76
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'дНЯРСО'
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOKClick
  end
  object Scanner: TScanner
    SettingUnits = UN_CENTIMETERS
    SettingLayoutAll = True
    SettingLayoutBottom = 1
    SettingLayoutRight = 1
    SettingShowUI = True
    SettingDPI = 100
    SettingBPP = 0
    SettingColour = True
    SettingCaptureCount = 0
    Left = 470
    Top = 138
  end
  object ActionList: TActionList
    Left = 433
    Top = 138
  end
  object opdContact: TOpenPictureDialog
    DefaultExt = 'bmp'
    Filter = 'Bitmaps (*.bmp)|*.bmp|JPEG (*.jpg)|*.jpg|*.*|*.*'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 432
    Top = 106
  end
  object dsContact: TDataSource
    Left = 464
    Top = 5
  end
  object dsEmail: TDataSource
    DataSet = gddbsdsEmail
    Left = 465
    Top = 37
  end
  object dsChildren: TDataSource
    Left = 465
    Top = 69
  end
  object gddbsdsEmail: TgdDBStringDataSet
    FieldName = 'щКЕЙРПНММЮЪ ОНВРЮ'
    DataField = 'email'
    DataSource = dsContact
    Left = 433
    Top = 37
  end
  object gddbsdsChildren: TgdDBStringDataSet
    FieldName = 'дЕРХ'
    DataField = 'children'
    DataSource = dsContact
    Left = 433
    Top = 69
  end
end
