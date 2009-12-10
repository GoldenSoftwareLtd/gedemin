object gd_frmShell: Tgd_frmShell
  Left = 555
  Top = 441
  BorderStyle = bsDialog
  Caption = 'Использовать как оболочку ОС Windows'
  ClientHeight = 199
  ClientWidth = 364
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 32
    Width = 173
    Height = 13
    Caption = 'Полное имя выполняемого файла:'
  end
  object Label2: TLabel
    Left = 8
    Top = 103
    Width = 69
    Height = 13
    Caption = 'База данных:'
  end
  object Label3: TLabel
    Left = 8
    Top = 152
    Width = 76
    Height = 13
    Caption = 'Пользователь:'
  end
  object Label4: TLabel
    Left = 8
    Top = 177
    Width = 41
    Height = 13
    Caption = 'Пароль:'
  end
  object chbxUseShell: TCheckBox
    Left = 8
    Top = 8
    Width = 257
    Height = 17
    Caption = 'Использовать в качестве оболочки Windows'
    TabOrder = 0
  end
  object chbxAuto: TCheckBox
    Left = 8
    Top = 83
    Width = 257
    Height = 17
    Caption = 'Автоматически подключаться к базе данных'
    TabOrder = 2
  end
  object edDatabase: TEdit
    Left = 8
    Top = 120
    Width = 257
    Height = 21
    TabOrder = 3
  end
  object edUser: TEdit
    Left = 88
    Top = 147
    Width = 177
    Height = 21
    TabOrder = 4
  end
  object edPassword: TEdit
    Left = 88
    Top = 173
    Width = 177
    Height = 21
    PasswordChar = '#'
    TabOrder = 5
  end
  object btnOk: TButton
    Left = 280
    Top = 8
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 6
  end
  object edPath: TEdit
    Left = 8
    Top = 48
    Width = 257
    Height = 21
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 280
    Top = 32
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 7
  end
  object ActionList1: TActionList
    Left = 312
    Top = 72
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
  end
end
