object dlgEnterSysdbaPassword: TdlgEnterSysdbaPassword
  Left = 329
  Top = 282
  BorderStyle = bsDialog
  Caption = '����� ������'
  ClientHeight = 164
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 17
    Top = 109
    Width = 76
    Height = 13
    Caption = '����� ������:'
  end
  object Label2: TLabel
    Left = 16
    Top = 132
    Width = 84
    Height = 13
    Caption = '�������������:'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 96
    Width = 233
    Height = 62
    Shape = bsFrame
  end
  object edPassword1: TEdit
    Left = 103
    Top = 104
    Width = 129
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
    OnChange = edPassword1Change
  end
  object edPassword2: TEdit
    Left = 103
    Top = 128
    Width = 129
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    OnChange = edPassword1Change
  end
  object btnOk: TButton
    Left = 264
    Top = 8
    Width = 75
    Height = 25
    Caption = '������'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 264
    Top = 40
    Width = 75
    Height = 25
    Caption = '������'
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 241
    Height = 81
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      '������ ���� ������ ���������� �� '
      '����������.'
      ''
      '��� ����������� ������������ ����������'
      '������� ������ ���������� �������������� '
      '(SYSDBA).')
    ReadOnly = True
    TabOrder = 4
  end
end
