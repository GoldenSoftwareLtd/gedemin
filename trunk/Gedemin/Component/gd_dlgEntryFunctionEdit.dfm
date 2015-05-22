object dlgEntryFunctionEdit: TdlgEntryFunctionEdit
  Left = 429
  Top = 274
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Редактор функции суммы проводки'
  ClientHeight = 254
  ClientWidth = 620
  Color = clBtnFace
  Constraints.MinHeight = 274
  Constraints.MinWidth = 638
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
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 620
    Height = 225
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object lblName: TLabel
      Left = 8
      Top = 4
      Width = 48
      Height = 13
      Anchors = []
      Caption = 'Функция:'
    end
    object lblDocHeadFields: TLabel
      Left = 8
      Top = 160
      Width = 87
      Height = 13
      Anchors = []
      Caption = 'Поля документа:'
    end
    object btnInsertHeadField: TSpeedButton
      Left = 522
      Top = 175
      Width = 90
      Height = 21
      Anchors = []
      Caption = 'Вставить'
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFCCC0FFFFFFFFFFFFCEC0FF
        FFFFFFFFFFCEC0FFFFFFFFFFFFCEC0FFFFFFFFFFFFCEC0FFFFFFFFFFFFCEC0FF
        FFFFFFF0000EC0000FFFFFFFCEEECCC0FFFFFFFFFCEE6C0FFFFFFFFFFFCEC0FF
        FFFFFFFFFFFC0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      ParentShowHint = False
      ShowHint = True
      OnClick = btnInsertHeadFieldClick
    end
    object Label1: TLabel
      Left = 8
      Top = 202
      Width = 604
      Height = 15
      Anchors = []
      AutoSize = False
      Caption = 
        'Поля документа добавляются в функцию, как наименование поля с ти' +
        'пом в квадратных скобках.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Bevel1: TBevel
      Left = 8
      Top = 155
      Width = 604
      Height = 2
      Anchors = []
    end
    object mmFunction: TMemo
      Left = 8
      Top = 25
      Width = 604
      Height = 119
      Anchors = []
      HideSelection = False
      TabOrder = 0
    end
    object cbHeadDocField: TComboBox
      Left = 8
      Top = 175
      Width = 509
      Height = 21
      Anchors = []
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = False
      Sorted = True
      TabOrder = 1
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 225
    Width = 620
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 464
      Top = 6
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 544
      Top = 6
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
