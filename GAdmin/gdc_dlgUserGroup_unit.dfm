inherited gdc_dlgUserGroup: Tgdc_dlgUserGroup
  Left = 436
  Top = 371
  Caption = 'Группа пользователей'
  ClientHeight = 203
  ClientWidth = 356
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 10
    Top = 11
    Width = 86
    Height = 13
    Caption = 'Идентификатор:'
  end
  object Label2: TLabel [1]
    Left = 10
    Top = 34
    Width = 77
    Height = 13
    Caption = 'Наименование:'
    FocusControl = dbeName
  end
  object Label3: TLabel [2]
    Left = 10
    Top = 56
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object DBText1: TDBText [3]
    Left = 97
    Top = 11
    Width = 41
    Height = 13
    AutoSize = True
    DataField = 'ID'
    DataSource = dsgdcBase
  end
  inherited btnAccess: TButton
    Left = 74
    Top = 101
    Enabled = False
    TabOrder = 8
    Visible = False
  end
  inherited btnNew: TButton
    Left = 282
    Top = 72
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 282
    Top = 8
    TabOrder = 4
  end
  inherited btnCancel: TButton
    Left = 282
    Top = 35
    TabOrder = 5
  end
  inherited btnHelp: TButton
    Left = 282
    Top = 99
    TabOrder = 7
  end
  object dbeName: TDBEdit [9]
    Left = 96
    Top = 32
    Width = 177
    Height = 21
    Ctl3D = True
    DataField = 'NAME'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 0
  end
  object dbmDiscription: TDBMemo [10]
    Left = 10
    Top = 72
    Width = 263
    Height = 55
    Ctl3D = True
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 1
  end
  object cbDisabled: TDBCheckBox [11]
    Left = 10
    Top = 133
    Width = 127
    Height = 17
    Caption = 'Группа отключена'
    DataField = 'DISABLED'
    DataSource = dsgdcBase
    TabOrder = 2
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object Panel1: TPanel [12]
    Left = 8
    Top = 155
    Width = 265
    Height = 41
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 3
    object Button1: TButton
      Left = 29
      Top = 10
      Width = 96
      Height = 21
      Action = actUsers
      TabOrder = 0
    end
    object Button2: TButton
      Left = 138
      Top = 10
      Width = 99
      Height = 21
      Action = actRights
      TabOrder = 1
    end
  end
  inherited alBase: TActionList
    Left = 206
    Top = 95
    object actUsers: TAction
      Caption = 'Пользователи'
      OnExecute = actUsersExecute
    end
    object actRights: TAction
      Caption = 'Права'
      OnExecute = actRightsExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 176
    Top = 95
  end
end
