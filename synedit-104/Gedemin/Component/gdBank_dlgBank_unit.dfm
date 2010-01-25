object gdBank_dlgBank: TgdBank_dlgBank
  Left = 591
  Top = 313
  Width = 398
  Height = 326
  Caption = 'gdBank_dlgBank'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 72
    Top = 54
    Width = 41
    Height = 13
    Caption = 'Address:'
  end
  object Label2: TLabel
    Left = 88
    Top = 30
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object Label3: TLabel
    Left = 72
    Top = 78
    Width = 53
    Height = 13
    Caption = 'BankCode:'
  end
  object Label4: TLabel
    Left = 80
    Top = 102
    Width = 47
    Height = 13
    Caption = 'FullName:'
  end
  object Label5: TLabel
    Left = 88
    Top = 126
    Width = 26
    Height = 13
    Caption = 'Note:'
  end
  object Label6: TLabel
    Left = 96
    Top = 142
    Width = 20
    Height = 13
    Caption = 'City:'
  end
  object DBEdit1: TDBEdit
    Left = 128
    Top = 22
    Width = 121
    Height = 21
    DataField = 'NAME'
    DataSource = dsBank2
    TabOrder = 0
  end
  object DBEdit2: TDBEdit
    Left = 128
    Top = 46
    Width = 121
    Height = 21
    DataField = 'ADDRESS'
    DataSource = dsBank2
    TabOrder = 1
  end
  object DBEdit3: TDBEdit
    Left = 128
    Top = 70
    Width = 121
    Height = 21
    DataField = 'BANKCODE'
    DataSource = dsBank2
    TabOrder = 2
  end
  object DBEdit4: TDBEdit
    Left = 128
    Top = 94
    Width = 121
    Height = 21
    DataField = 'FULLNAME'
    DataSource = dsBank2
    TabOrder = 3
  end
  object DBEdit5: TDBEdit
    Left = 128
    Top = 118
    Width = 121
    Height = 21
    DataField = 'NOTE'
    DataSource = dsBank2
    TabOrder = 4
  end
  object DBEdit6: TDBEdit
    Left = 128
    Top = 142
    Width = 121
    Height = 21
    DataField = 'CITY'
    DataSource = dsBank2
    TabOrder = 5
  end
  object Button1: TButton
    Left = 280
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    ModalResult = 1
    TabOrder = 6
  end
  object Button2: TButton
    Left = 280
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button2'
    ModalResult = 2
    TabOrder = 7
  end
  object dsBank2: TDataSource
    Left = 40
    Top = 16
  end
end
