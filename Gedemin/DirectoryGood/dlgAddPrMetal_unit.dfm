object dlgAddPrMetal: TdlgAddPrMetal
  Left = 289
  Top = 189
  BorderStyle = bsDialog
  Caption = 'Параметры драгметалла'
  ClientHeight = 133
  ClientWidth = 277
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object lblTNVD: TLabel
    Left = 8
    Top = 32
    Width = 50
    Height = 13
    Caption = 'Описание'
  end
  object dbeName: TDBEdit
    Left = 112
    Top = 8
    Width = 160
    Height = 21
    DataField = 'NAME'
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 116
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 198
    Top = 104
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
  object dbmDescription: TDBMemo
    Left = 112
    Top = 32
    Width = 160
    Height = 65
    DataField = 'DESCRIPTION'
    TabOrder = 1
  end
end
