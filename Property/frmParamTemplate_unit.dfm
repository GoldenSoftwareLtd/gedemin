object frmParamTemplate: TfrmParamTemplate
  Left = 316
  Top = 315
  Width = 878
  Height = 369
  BorderIcons = [biSystemMenu]
  Caption = 'Шаблоны параметров'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 317
    Width = 870
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 707
      Top = 1
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 791
      Top = 1
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlList: TPanel
    Left = 0
    Top = 0
    Width = 870
    Height = 317
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object lv: TListView
      Left = 4
      Top = 4
      Width = 862
      Height = 309
      Align = alClient
      Columns = <
        item
          Caption = 'Наименование'
          Width = 120
        end
        item
          Caption = 'Комментарий'
          Width = 80
        end
        item
          Caption = 'Таблица'
          Width = 200
        end
        item
          Caption = 'Поле для отображения'
          Width = 130
        end
        item
          Caption = 'Поле ИД'
          Width = 90
        end
        item
          AutoSize = True
          Caption = 'Условие'
        end
        item
          Caption = 'Сорт'
          Width = 38
        end
        item
          Caption = 'Функция'
          Width = 90
        end>
      GridLines = True
      HideSelection = False
      RowSelect = True
      PopupMenu = pm
      SortType = stText
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object pm: TPopupMenu
    Left = 120
    Top = 80
    object N1: TMenuItem
      Caption = 'Скопировать имя функции в буфер'
      OnClick = N1Click
    end
  end
end
