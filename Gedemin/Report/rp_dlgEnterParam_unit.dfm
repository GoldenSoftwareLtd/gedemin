object dlgEnterParam: TdlgEnterParam
  Left = 239
  Top = 81
  BorderStyle = bsDialog
  Caption = 'Введите входные параметры функции'
  ClientHeight = 81
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object pnlButton: TPanel
    Left = 0
    Top = 31
    Width = 455
    Height = 50
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    object btnOk: TButton
      Left = 256
      Top = 10
      Width = 92
      Height = 31
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 354
      Top = 10
      Width = 93
      Height = 31
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlLabel: TPanel
    Left = 0
    Top = 0
    Width = 455
    Height = 31
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 108
      Top = 2
      Width = 144
      Height = 16
      Caption = 'Значение параметра'
    end
    object Label2: TLabel
      Left = 295
      Top = 2
      Width = 105
      Height = 16
      Caption = 'Тип параметра'
    end
    object Bevel1: TBevel
      Left = 0
      Top = 25
      Width = 454
      Height = 2
    end
  end
end
