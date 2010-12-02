object gdc_inv_dlgPredefinedField: Tgdc_inv_dlgPredefinedField
  Left = 353
  Top = 130
  BorderStyle = bsDialog
  Caption = 'Поля по умолчанию'
  ClientHeight = 247
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 17
    Top = 12
    Width = 46
    Height = 13
    Caption = 'Префикс'
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 35
    Width = 161
    Height = 172
    Caption = 'Цены и ставки'
    TabOrder = 0
    object cbPriceNCU: TCheckBox
      Left = 8
      Top = 19
      Width = 97
      Height = 17
      Caption = 'Цена в НДЕ'
      TabOrder = 0
    end
    object cbPriceCurr: TCheckBox
      Left = 8
      Top = 37
      Width = 97
      Height = 17
      Caption = 'Цена в вал.'
      TabOrder = 1
    end
    object cbVAT: TCheckBox
      Left = 8
      Top = 55
      Width = 97
      Height = 17
      Caption = 'Ставка НДС'
      TabOrder = 2
    end
    object cbPriceVAT: TCheckBox
      Left = 8
      Top = 72
      Width = 125
      Height = 17
      Caption = 'Цена НДС в НДЕ'
      TabOrder = 3
    end
    object cbPriceVATCurr: TCheckBox
      Left = 8
      Top = 90
      Width = 112
      Height = 17
      Caption = 'Цена НДС в вал'
      TabOrder = 4
    end
    object cbPerc: TCheckBox
      Left = 8
      Top = 108
      Width = 127
      Height = 17
      Caption = 'Процент наценки'
      TabOrder = 5
    end
    object edOtherTax: TEdit
      Left = 28
      Top = 144
      Width = 121
      Height = 21
      CharCase = ecUpperCase
      Enabled = False
      TabOrder = 6
      Text = 'SALETAX'
    end
  end
  object Button1: TButton
    Left = 93
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 216
    Top = 215
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object cbOtherTax: TCheckBox
    Left = 24
    Top = 160
    Width = 97
    Height = 17
    Caption = 'Ставка налога'
    TabOrder = 3
    OnClick = cbOtherTaxClick
  end
  object GroupBox2: TGroupBox
    Left = 200
    Top = 35
    Width = 161
    Height = 172
    Caption = 'Суммы'
    TabOrder = 4
    object cbAmountNCU: TCheckBox
      Left = 8
      Top = 19
      Width = 97
      Height = 17
      Caption = 'Сумма в НДЕ'
      TabOrder = 0
    end
    object cbAmountCURR: TCheckBox
      Left = 8
      Top = 36
      Width = 97
      Height = 17
      Caption = 'Сумма в вал.'
      TabOrder = 1
    end
    object cbAmountVAT: TCheckBox
      Left = 8
      Top = 53
      Width = 125
      Height = 17
      Caption = 'Сумма НДС в НДЕ'
      TabOrder = 2
    end
    object cbAmountVATCurr: TCheckBox
      Left = 8
      Top = 71
      Width = 112
      Height = 17
      Caption = 'Сумма НДС в вал'
      TabOrder = 3
    end
    object cbAmountWithVAT: TCheckBox
      Left = 8
      Top = 88
      Width = 97
      Height = 17
      Caption = 'Сумма с НДС'
      TabOrder = 4
    end
    object cbAmountWithVATCurr: TCheckBox
      Left = 8
      Top = 105
      Width = 129
      Height = 17
      Caption = 'Сумма с НДС в вал.'
      TabOrder = 5
    end
    object cbAmountOtherTax: TCheckBox
      Left = 8
      Top = 122
      Width = 97
      Height = 17
      Caption = 'Сумма налога'
      TabOrder = 6
    end
  end
  object edPrefix: TEdit
    Left = 72
    Top = 6
    Width = 104
    Height = 21
    TabOrder = 5
  end
end
