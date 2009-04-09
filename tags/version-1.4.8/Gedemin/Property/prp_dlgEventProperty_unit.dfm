object dlgEventProperty: TdlgEventProperty
  Left = 238
  Top = 151
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Свойства'
  ClientHeight = 183
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 225
    Height = 148
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Журнал событий'
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 201
        Height = 105
        Caption = 'Осовные'
        TabOrder = 0
        object cbUnlimitSize: TCheckBox
          Left = 8
          Top = 48
          Width = 185
          Height = 17
          Caption = 'Неограниченная длинна списка'
          TabOrder = 1
          OnClick = cbUnlimitSizeClick
        end
        object eEventSize: TEdit
          Left = 24
          Top = 72
          Width = 169
          Height = 21
          TabOrder = 2
        end
        object cbClearOnStart: TCheckBox
          Left = 8
          Top = 32
          Width = 185
          Height = 17
          Caption = 'Очищать при запуске'
          TabOrder = 0
        end
        object cbUseEventLog: TCheckBox
          Left = 8
          Top = 16
          Width = 185
          Height = 17
          Caption = 'Запись в журнал'
          TabOrder = 3
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 148
    Width = 225
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object bCancel: TButton
      Left = 145
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 0
    end
    object bOK: TButton
      Left = 65
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'ОК'
      ModalResult = 1
      TabOrder = 1
    end
  end
end
