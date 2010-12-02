object dlgAccountInfo: TdlgAccountInfo
  Left = 428
  Top = 266
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Карта счета'
  ClientHeight = 109
  ClientWidth = 253
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
    Left = 13
    Top = 13
    Width = 65
    Height = 13
    Caption = 'Номер счета'
  end
  object Label2: TLabel
    Left = 13
    Top = 39
    Width = 53
    Height = 13
    Caption = 'Период  с:'
  end
  object Label3: TLabel
    Left = 157
    Top = 39
    Width = 12
    Height = 13
    Caption = 'по'
  end
  object gsiblcAccount: TgsIBLookupComboBox
    Left = 88
    Top = 8
    Width = 152
    Height = 21
    ListTable = 'GD_CARDACCOUNT'
    ListField = 'ALIAS'
    KeyField = 'ID'
    Condition = 'GRADE >= 2'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnChange = gsiblcAccountChange
  end
  object xdeDateBegin: TxDateEdit
    Left = 88
    Top = 35
    Width = 65
    Height = 21
    EditMask = '!99/99/9999;1;_'
    MaxLength = 10
    TabOrder = 1
    Text = '19.02.2001'
    Kind = kDate
  end
  object xdeDateEnd: TxDateEdit
    Left = 176
    Top = 35
    Width = 65
    Height = 21
    EditMask = '!99/99/9999;1;_'
    MaxLength = 10
    TabOrder = 2
    Text = '19.02.2001'
    Kind = kDate
  end
  object bOk: TButton
    Left = 37
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 3
  end
  object Button2: TButton
    Left = 141
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Отмена'
    TabOrder = 4
  end
  object FormPlaceSaver: TFormPlaceSaver
    Left = 224
    Top = 72
  end
end
