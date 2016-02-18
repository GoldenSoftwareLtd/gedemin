object dlgRegistryDemand: TdlgRegistryDemand
  Left = 444
  Top = 187
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Реестр требований'
  ClientHeight = 150
  ClientWidth = 199
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 5
    Top = 5
    Width = 191
    Height = 106
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = -6
    Top = 115
    Width = 205
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object Label1: TLabel
    Left = 15
    Top = 15
    Width = 78
    Height = 13
    Caption = 'Номер реестра'
  end
  object Label2: TLabel
    Left = 15
    Top = 39
    Width = 73
    Height = 13
    Caption = 'Дата реестра:'
  end
  object Label3: TLabel
    Left = 15
    Top = 64
    Width = 105
    Height = 13
    Caption = 'Товары отпущены с:'
  end
  object Label4: TLabel
    Left = 15
    Top = 89
    Width = 72
    Height = 13
    Caption = 'Срок кредита:'
  end
  object btnOk: TButton
    Left = 61
    Top = 123
    Width = 76
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'ОK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object edNumber: TEdit
    Left = 125
    Top = 10
    Width = 66
    Height = 21
    TabOrder = 0
    Text = '1'
  end
  object xdeDate1: TxDateEdit
    Left = 125
    Top = 35
    Width = 66
    Height = 21
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 1
    Text = '30.09.2002'
  end
  object xdeDate2: TxDateEdit
    Left = 125
    Top = 60
    Width = 66
    Height = 21
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 2
    Text = '30.09.2002'
  end
  object xdeDate3: TxDateEdit
    Left = 125
    Top = 85
    Width = 66
    Height = 21
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 3
    Text = '30.09.2002'
  end
end
