object dlgSecLogIn2: TdlgSecLogIn2
  Left = 587
  Top = 452
  HelpContext = 39
  ActiveControl = edPassword
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Вход в систему'
  ClientHeight = 200
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
    Top = 176
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
  object pnlLoginParams: TPanel
    Left = 56
    Top = 8
    Width = 270
    Height = 156
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Ctl3D = False
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 0
    object lblUser: TLabel
      Left = 8
      Top = 72
      Width = 76
      Height = 13
      Caption = 'Пользователь:'
    end
    object lblPassword: TLabel
      Left = 8
      Top = 97
      Width = 41
      Height = 13
      Caption = 'Пароль:'
      FocusControl = edPassword
    end
    object lblDBName: TLabel
      Left = 8
      Top = 35
      Width = 69
      Height = 13
      Caption = 'База данных:'
    end
    object bvl2: TBevel
      Left = 1
      Top = 60
      Width = 266
      Height = 2
      Shape = bsTopLine
    end
    object bvl1: TBevel
      Left = 1
      Top = 25
      Width = 266
      Height = 2
      Shape = bsTopLine
    end
    object edPassword: TEdit
      Left = 88
      Top = 94
      Width = 175
      Height = 21
      Ctl3D = True
      MaxLength = 20
      ParentCtl3D = False
      PasswordChar = '*'
      TabOrder = 1
    end
    object cbUser: TComboBox
      Left = 88
      Top = 68
      Width = 175
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbUserChange
    end
    object chbxRememberPassword: TCheckBox
      Left = 88
      Top = 118
      Width = 129
      Height = 17
      Caption = 'Запомнить пароль'
      TabOrder = 2
    end
    object edDBName: TEdit
      Left = 88
      Top = 33
      Width = 151
      Height = 21
      TabStop = False
      Color = clBtnFace
      Ctl3D = True
      ParentCtl3D = False
      ReadOnly = True
      TabOrder = 5
      Text = 'Комлексная автоматизация'
    end
    object btnSelectDB: TButton
      Left = 239
      Top = 32
      Width = 23
      Height = 20
      Action = actSelectDB
      TabOrder = 6
    end
    object chbxWithoutConnection: TCheckBox
      Left = 88
      Top = 5
      Width = 153
      Height = 17
      Caption = 'Без подключения к БД'
      TabOrder = 4
      OnClick = chbxWithoutConnectionClick
    end
    object chbxSingleUser: TCheckBox
      Left = 88
      Top = 135
      Width = 169
      Height = 17
      Caption = 'Монопольный режим'
      TabOrder = 3
    end
  end
  object btnOk: TButton
    Left = 168
    Top = 172
    Width = 75
    Height = 21
    Action = actLogin
    Default = True
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 250
    Top = 172
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    ModalResult = 2
    TabOrder = 2
  end
  object btnVer: TButton
    Left = 56
    Top = 172
    Width = 24
    Height = 21
    Action = actVer
    TabOrder = 3
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
      Caption = 'i'
      OnExecute = actVerExecute
    end
    object actSelectDB: TAction
      Caption = '...'
      OnExecute = actSelectDBExecute
      OnUpdate = actSelectDBUpdate
    end
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 8
    Top = 87
  end
end
