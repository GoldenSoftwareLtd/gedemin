object dlgCardOfAccount: TdlgCardOfAccount
  Left = 451
  Top = 300
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Запрос'
  ClientHeight = 84
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 336
    Height = 26
    Align = alTop
    Caption = 
      'Выберите план счетов, для всех типовых операций и налогов, у кот' +
      'орых он незадан:'
    WordWrap = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 58
    Width = 336
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 181
      Top = 5
      Width = 75
      Height = 21
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 261
      Top = 5
      Width = 75
      Height = 21
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ComboBox1: TComboBox
    Left = 0
    Top = 32
    Width = 336
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnDropDown = ComboBox1DropDown
  end
  object Transaction: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 24
    Top = 48
  end
end
