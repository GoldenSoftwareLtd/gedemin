object dlgSecLogIn2: TdlgSecLogIn2
  Left = 549
  Top = 253
  HelpContext = 39
  ActiveControl = edPassword
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Вход в систему'
  ClientHeight = 276
  ClientWidth = 333
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object imgSecurity: TImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
    AutoSize = True
    Picture.Data = {
      055449636F6E0000010001002020100000000000E80200001600000028000000
      2000000040000000010004000000000080020000000000000000000000000000
      0000000000000000000080000080000000808000800000008000800080800000
      C0C0C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
      FFFFFF0000000000000000000000000000000000000844444444444448000000
      000000000044777F777787884480000000000000004777FF7777787884400000
      8440000000477FFF7777878744400008F880000000477FFF7777787884400087
      F884000000477FFF7777878784400087F884000000477FFF7777787844400087
      F888000000477FFF7777878784400087F888440000477FFF7777787884400087
      F887880000477FFF7777878744400087F888000000477FFF7777787884400087
      F888440000477FFF7777878784400087F887880000477FFF7777787844400087
      F888000000477FFF7777878784400087F8884400004877FF7777787884400087
      F88888000084877F7777878884800087F8848000000844444444444448000087
      F884000000004FF48000047840000087F884000000004FF48000047840000087
      7884000000004FF748008878800008FFFFF78000000087FF7844877880008FFF
      FFFF78000000087FF777777800008FFFFFFF7780000000877FFFF78000087FFF
      FFF7F740000000088444480000087FFFFFFF7740000000000000000000087FFF
      FF7FF740000000000000000000087FFF44F777800000000000000000000087FF
      487F788000000000000000000000887FF7777800000000000000000000000887
      7778800000000000000000000000000844480000000000000000000000000000
      00000000FFFFFFFFE0003FFFC0001FFFC0001F1FC0001E1FC0001C0FC0001C0F
      C0001C0FC0001C03C0001C03C0001C0FC0001C03C0001C03C0001C0FC0001C03
      C0001C03C0001C07E0003C0FF0787C0FF0787C0FF0307807F0007003F800F001
      FC01E001FE03E001FFFFE001FFFFE001FFFFF001FFFFF003FFFFF807FFFFFE0F
      FFFFFFFF}
  end
  object lKL: TLabel
    Left = 8
    Top = 135
    Width = 3
    Height = 13
    Color = clActiveCaption
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clCaptionText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label1: TLabel
    Left = 56
    Top = 240
    Width = 268
    Height = 29
    AutoSize = False
    Caption = 
      'Для учетной записи Administrator по-умолчанию  установлен пароль' +
      ' Administrator.'
    Color = clInfoBk
    ParentColor = False
    WordWrap = True
  end
  object pnlLoginParams: TPanel
    Left = 56
    Top = 8
    Width = 270
    Height = 116
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Ctl3D = False
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 0
    object lblUser: TLabel
      Left = 8
      Top = 47
      Width = 76
      Height = 13
      Caption = 'Пользователь:'
    end
    object lblPassword: TLabel
      Left = 8
      Top = 72
      Width = 41
      Height = 13
      Caption = 'Пароль:'
      FocusControl = edPassword
    end
    object lblDBName: TLabel
      Left = 8
      Top = 10
      Width = 69
      Height = 13
      Caption = 'База данных:'
    end
    object bvl2: TBevel
      Left = 1
      Top = 35
      Width = 266
      Height = 2
      Shape = bsTopLine
    end
    object edPassword: TEdit
      Left = 88
      Top = 69
      Width = 175
      Height = 21
      Ctl3D = True
      MaxLength = 20
      ParentCtl3D = False
      PasswordChar = '*'
      TabOrder = 3
    end
    object cbUser: TComboBox
      Left = 88
      Top = 43
      Width = 175
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbUserChange
    end
    object chbxRememberPassword: TCheckBox
      Left = 88
      Top = 93
      Width = 129
      Height = 17
      Caption = 'Запомнить пароль'
      TabOrder = 4
    end
    object edDBName: TEdit
      Left = 88
      Top = 8
      Width = 151
      Height = 21
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 0
      Text = 'Комлексная автоматизация'
      OnChange = edDBNameChange
    end
    object btnSelectDB: TButton
      Left = 239
      Top = 7
      Width = 23
      Height = 20
      Action = actSelectDB
      TabOrder = 1
    end
  end
  object btnOk: TButton
    Left = 168
    Top = 131
    Width = 75
    Height = 21
    Action = actLogin
    Default = True
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 250
    Top = 131
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    ModalResult = 2
    TabOrder = 2
  end
  object btnMore: TButton
    Left = 56
    Top = 131
    Width = 24
    Height = 21
    Action = actMore
    TabOrder = 3
  end
  object pnlAdditionalInfo: TPanel
    Left = 56
    Top = 160
    Width = 270
    Height = 76
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Ctl3D = False
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 4
    object chbxWithoutConnection: TCheckBox
      Left = 9
      Top = 8
      Width = 256
      Height = 17
      Caption = 'Вход без подключения к базе данных'
      TabOrder = 0
      OnClick = chbxWithoutConnectionClick
    end
    object chbxSingleUser: TCheckBox
      Left = 9
      Top = 27
      Width = 256
      Height = 17
      Action = actSingleUser
      TabOrder = 1
    end
    object btnVer: TButton
      Left = 8
      Top = 47
      Width = 96
      Height = 21
      Action = actVer
      TabOrder = 2
    end
  end
  object ActionList: TActionList
    Left = 8
    Top = 59
    object actLogin: TAction
      Caption = 'Войти'
      OnExecute = actLoginExecute
      OnUpdate = actLoginUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = 'actHelp'
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actVer: TAction
      Caption = 'Информация...'
      OnExecute = actVerExecute
      OnUpdate = actVerUpdate
    end
    object actSelectDB: TAction
      Caption = '...'
      OnExecute = actSelectDBExecute
      OnUpdate = actSelectDBUpdate
    end
    object actMore: TAction
      Caption = '»'
      OnExecute = actMoreExecute
    end
    object actSingleUser: TAction
      Caption = 'Однопользовательский режим подключения'
      OnUpdate = actSingleUserUpdate
    end
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 8
    Top = 87
  end
end
