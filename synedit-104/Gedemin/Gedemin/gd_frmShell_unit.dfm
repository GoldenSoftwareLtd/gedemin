object gd_frmShell: Tgd_frmShell
  Left = 555
  Top = 441
  BorderStyle = bsDialog
  Caption = '������������ ��� �������� �� Windows'
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
    Caption = '������ ��� ������������ �����:'
  end
  object Label2: TLabel
    Left = 8
    Top = 103
    Width = 69
    Height = 13
    Caption = '���� ������:'
  end
  object Label3: TLabel
    Left = 8
    Top = 152
    Width = 76
    Height = 13
    Caption = '������������:'
  end
  object Label4: TLabel
    Left = 8
    Top = 177
    Width = 41
    Height = 13
    Caption = '������:'
  end
  object chbxUseShell: TCheckBox
    Left = 8
    Top = 8
    Width = 257
    Height = 17
    Caption = '������������ � �������� �������� Windows'
    TabOrder = 0
  end
  object chbxAuto: TCheckBox
    Left = 8
    Top = 83
    Width = 257
    Height = 17
    Caption = '������������� ������������ � ���� ������'
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
    Caption = '������'
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
