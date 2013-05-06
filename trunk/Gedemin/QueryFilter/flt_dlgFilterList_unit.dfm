object dlgFilterList: TdlgFilterList
  Left = 538
  Top = 297
  HelpContext = 8
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Список фильтров'
  ClientHeight = 396
  ClientWidth = 598
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 598
    Height = 396
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object lvFilter: TListView
      Left = 4
      Top = 4
      Width = 508
      Height = 388
      Align = alClient
      BorderStyle = bsNone
      Color = clWhite
      Columns = <
        item
          AutoSize = True
          Caption = 'Наименование'
        end
        item
          Caption = 'Время вып.'
          Width = 79
        end
        item
          Caption = 'Кол-во обр.'
          Width = 89
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      PopupMenu = pm
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lvFilterDblClick
    end
    object pnlRightButtons: TPanel
      Left = 512
      Top = 4
      Width = 82
      Height = 388
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnEdit: TButton
        Left = 6
        Top = 18
        Width = 75
        Height = 23
        Action = acEdit
        Cancel = True
        TabOrder = 0
      end
      object btnDelete: TButton
        Left = 6
        Top = 46
        Width = 75
        Height = 23
        Action = acDelete
        Cancel = True
        TabOrder = 1
      end
      object btnSelect: TButton
        Left = 6
        Top = 74
        Width = 75
        Height = 23
        Action = actSelect
        Cancel = True
        ModalResult = 1
        TabOrder = 2
      end
      object btnClose: TButton
        Left = 6
        Top = 362
        Width = 75
        Height = 23
        Cancel = True
        Caption = 'Закрыть'
        Default = True
        ModalResult = 2
        TabOrder = 3
      end
    end
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
      '  f.*'
      'FROM'
      '  flt_savedfilter f'
      'WHERE'
      '  f.componentkey = :componentkey'
      '  AND (f.userkey = :userkey'
      '           OR f.userkey IS NULL)'
      'ORDER BY '
      '  f.name'
      '   ')
    Left = 184
    Top = 56
  end
  object pm: TPopupMenu
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
