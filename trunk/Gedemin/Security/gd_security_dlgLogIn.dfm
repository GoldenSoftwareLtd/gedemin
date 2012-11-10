object dlgSecLogIn: TdlgSecLogIn
  Left = 480
  Top = 149
  HelpContext = 39
  ActiveControl = edPassword
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Вход в систему'
  ClientHeight = 171
  ClientWidth = 303
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
  OnDestroy = FormDestroy
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
    Top = 149
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
    Width = 241
    Height = 128
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Ctl3D = False
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 0
    object lblUser: TLabel
      Left = 8
      Top = 60
      Width = 76
      Height = 13
      Caption = 'Пользователь:'
    end
    object lblPassword: TLabel
      Left = 8
      Top = 85
      Width = 41
      Height = 13
      Caption = 'Пароль:'
      FocusControl = edPassword
    end
    object lblSubSystem: TLabel
      Left = 192
      Top = 76
      Width = 64
      Height = 13
      Caption = 'Подсистема:'
      Visible = False
    end
    object Label1: TLabel
      Left = 8
      Top = 5
      Width = 41
      Height = 13
      Caption = 'Сервер:'
    end
    object Label2: TLabel
      Left = 8
      Top = 27
      Width = 69
      Height = 13
      Caption = 'База данных:'
    end
    object lSubSystemName: TLabel
      Left = 200
      Top = 60
      Width = 67
      Height = 13
      Caption = '<subsystem>'
      Visible = False
    end
    object lServerName: TLabel
      Left = 88
      Top = 5
      Width = 47
      Height = 13
      Caption = '<server>'
    end
    object Bevel1: TBevel
      Left = 1
      Top = 49
      Width = 238
      Height = 2
      Shape = bsTopLine
    end
    object edPassword: TEdit
      Left = 88
      Top = 82
      Width = 145
      Height = 21
      Ctl3D = True
      MaxLength = 20
      ParentCtl3D = False
      PasswordChar = '*'
      TabOrder = 2
    end
    object cbUser: TComboBox
      Left = 88
      Top = 56
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbUserChange
    end
    object cbDBFileName: TComboBox
      Left = 88
      Top = 23
      Width = 145
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
      OnChange = cbDBFileNameChange
    end
    object chbxRememberPassword: TCheckBox
      Left = 88
      Top = 106
      Width = 129
      Height = 17
      Caption = 'Запомнить пароль'
      TabOrder = 3
    end
  end
  object btnOk: TButton
    Left = 139
    Top = 143
    Width = 75
    Height = 21
    Action = actLogin
    Default = True
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 221
    Top = 143
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    ModalResult = 2
    TabOrder = 2
  end
  object btnVer: TButton
    Left = 57
    Top = 143
    Width = 21
    Height = 21
    Action = actVer
    TabOrder = 3
  end
  object ActionList: TActionList
    Left = 8
    Top = 100
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
      Caption = '?'
      OnExecute = actVerExecute
    end
  end
  object spUserLogin: TIBStoredProc
    Transaction = ibtSecurity
    StoredProcName = 'GD_P_SEC_LOGINUSER'
    Left = 8
    Top = 72
    ParamData = <
      item
        DataType = ftInteger
        Name = 'RESULT'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'USERKEY'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'CONTACTKEY'
        ParamType = ptOutput
      end
      item
        DataType = ftString
        Name = 'IBNAME'
        ParamType = ptOutput
      end
      item
        DataType = ftString
        Name = 'IBPASSWORD'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'INGROUP'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'SESSION'
        ParamType = ptOutput
      end
      item
        DataType = ftString
        Name = 'SUBSYSTEMNAME'
        ParamType = ptOutput
      end
      item
        DataType = ftString
        Name = 'GROUPNAME'
        ParamType = ptOutput
      end
      item
        DataType = ftString
        Name = 'DBVERSION'
        ParamType = ptOutput
      end
      item
        DataType = ftDate
        Name = 'DBRELEASEDATE'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'DBVERSIONID'
        ParamType = ptOutput
      end
      item
        DataType = ftString
        Name = 'DBVERSIONCOMMENT'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'AUDITLEVEL'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'AUDITCACHE'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'AUDITMAXDAYS'
        ParamType = ptOutput
      end
      item
        DataType = ftString
        Name = 'USERNAME'
        ParamType = ptInput
      end
      item
        DataType = ftString
        Name = 'PASSW'
        ParamType = ptInput
      end
      item
        DataType = ftInteger
        Name = 'SUBSYSTEM'
        ParamType = ptInput
      end
      item
        DataType = ftSmallint
        Name = 'AllowUserAudit'
        ParamType = ptOutput
      end>
  end
  object ibtSecurity: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 8
    Top = 44
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 8
    Top = 128
  end
end
