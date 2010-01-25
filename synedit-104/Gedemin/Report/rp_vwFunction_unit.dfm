object vwFunction: TvwFunction
  Left = 152
  Top = 183
  Width = 331
  Height = 264
  BorderIcons = [biSystemMenu]
  Caption = 'Список функций'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlRight: TPanel
    Left = 232
    Top = 0
    Width = 91
    Height = 237
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object pnlButton: TPanel
      Left = 0
      Top = 152
      Width = 91
      Height = 85
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object btnSelect: TButton
        Left = 8
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Выбрать'
        Default = True
        TabOrder = 0
        OnClick = btnSelectClick
      end
      object btnClose: TButton
        Left = 8
        Top = 48
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Закрыть'
        ModalResult = 2
        TabOrder = 1
      end
    end
    object btnAdd: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Action = actAdd
      TabOrder = 1
    end
    object btnEdit: TButton
      Left = 8
      Top = 40
      Width = 75
      Height = 25
      Action = actEdit
      TabOrder = 2
    end
    object btnDelete: TButton
      Left = 8
      Top = 72
      Width = 75
      Height = 25
      Action = actDelete
      TabOrder = 3
    end
  end
  object lvFunction: TListView
    Left = 0
    Top = 0
    Width = 232
    Height = 237
    Align = alClient
    Columns = <
      item
        Caption = 'Список функций'
        Width = 228
      end>
    HideSelection = False
    TabOrder = 1
    ViewStyle = vsReport
  end
  object ActionList1: TActionList
    Left = 288
    Top = 104
    object actAdd: TAction
      Caption = 'Добавить'
      OnExecute = actAddExecute
    end
    object actEdit: TAction
      Caption = 'Изменить'
      OnExecute = actEditExecute
    end
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
    end
  end
  object ibsqlFunction: TIBSQL
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  id, name'
      'FROM'
      '  gd_function'
      'WHERE'
      '  module = :module')
    Left = 256
    Top = 104
  end
end
