object dlgFilterList: TdlgFilterList
  Left = 787
  Top = 438
  HelpContext = 8
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Список фильтров'
  ClientHeight = 236
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lvFilter: TListView
    Left = 4
    Top = 2
    Width = 312
    Height = 199
    Color = clWhite
    Columns = <
      item
        AutoSize = True
        Caption = 'Наименование'
      end
      item
        Caption = 'Время выполнения'
        Width = 79
      end
      item
        Caption = 'Кол-во обращений'
        Width = 79
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    SortType = stText
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvFilterDblClick
  end
  object btnClose: TButton
    Left = 163
    Top = 209
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Закрыть'
    ModalResult = 2
    TabOrder = 1
  end
  object btnEdit: TButton
    Left = 3
    Top = 209
    Width = 75
    Height = 23
    Action = acEdit
    Cancel = True
    TabOrder = 2
  end
  object btnDelete: TButton
    Left = 83
    Top = 209
    Width = 75
    Height = 23
    Action = acDelete
    Cancel = True
    TabOrder = 3
  end
  object btnSelect: TButton
    Left = 243
    Top = 209
    Width = 75
    Height = 23
    Action = actSelect
    Cancel = True
    ModalResult = 1
    TabOrder = 4
  end
  object alFilter: TActionList
    Left = 150
    Top = 55
    object acDelete: TAction
      Caption = 'Удалить'
      ShortCut = 46
      OnExecute = acDeleteExecute
      OnUpdate = acDeleteUpdate
    end
    object acEdit: TAction
      Caption = 'Изменить ...'
      ShortCut = 13
      OnExecute = acEditExecute
      OnUpdate = acEditUpdate
    end
    object actSelect: TAction
      Caption = 'Выбрать'
      OnExecute = actSelectExecute
      OnUpdate = actSelectUpdate
    end
  end
  object ibsqlFilter: TIBSQL
    SQL.Strings = (
      'SELECT '
      '  *'
      'FROM'
      '  flt_savedfilter'
      'WHERE'
      '  componentkey = :componentkey'
      '  AND (userkey = :userkey'
      '           OR userkey IS NULL)'
      'ORDER BY readcount DESC'
      '   ')
    Left = 184
    Top = 56
  end
  object PopupMenu1: TPopupMenu
    Left = 216
    Top = 56
    object N1: TMenuItem
      Action = acEdit
    end
    object N2: TMenuItem
      Action = acDelete
    end
    object N3: TMenuItem
      Caption = 'Выбрать'
      OnClick = N3Click
    end
  end
end
