object dlgAddTax: TdlgAddTax
  Left = 231
  Top = 170
  BorderStyle = bsDialog
  Caption = 'Параметры налога'
  ClientHeight = 115
  ClientWidth = 291
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 115
    Height = 13
    Caption = 'Название переменной'
  end
  object lblRate: TLabel
    Left = 8
    Top = 56
    Width = 36
    Height = 13
    Caption = 'Ставка'
  end
  object dbeName: TDBEdit
    Left = 136
    Top = 8
    Width = 150
    Height = 21
    DataField = 'NAME'
    DataSource = dsTax
    TabOrder = 0
  end
  object dbeShot: TDBEdit
    Left = 136
    Top = 32
    Width = 150
    Height = 21
    DataField = 'SHOT'
    DataSource = dsTax
    TabOrder = 1
  end
  object dbeRate: TDBEdit
    Left = 136
    Top = 56
    Width = 150
    Height = 21
    DataField = 'RATE'
    DataSource = dsTax
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 130
    Top = 86
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 212
    Top = 86
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object dsTax: TDataSource
    Left = 112
    Top = 80
  end
end
