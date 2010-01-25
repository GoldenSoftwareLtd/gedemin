object dlgInputFormula: TdlgInputFormula
  Left = 126
  Top = 139
  Width = 487
  Height = 319
  Caption = 'Условие пользователя'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object pnlActionBtn: TPanel
    Left = 373
    Top = 0
    Width = 106
    Height = 286
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object pnlEndBtn: TPanel
      Left = 0
      Top = 199
      Width = 106
      Height = 87
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 5
      object btnOk: TButton
        Left = 7
        Top = 10
        Width = 93
        Height = 31
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 7
        Top = 49
        Width = 93
        Height = 31
        Cancel = True
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
    end
    object gscbFields: TgsComboButton
      Left = 7
      Top = 5
      Width = 93
      Height = 31
      Caption = 'Поля >>'
      TabOrder = 0
      OnCloseUp = gscbFieldsCloseUp
      Items.Strings = (
        '1'
        '2'
        '2'
        '3'
        '3'
        '43')
      DropDownCount = 12
    end
    object gscbOperators: TgsComboButton
      Left = 7
      Top = 44
      Width = 93
      Height = 31
      Caption = 'Операторы >>'
      TabOrder = 1
      OnCloseUp = gscbOperatorsCloseUp
      Items.Strings = (
        ' SELECT '
        ' FROM '
        ' JOIN '
        ' LEFT '
        ' RIGHT '
        ' FULL '
        ' INNER '
        ' OUTER '
        ' WHERE '
        ' AND '
        ' OR '
        ' ( '
        ' ) '
        ' = '
        ' < '
        ' > '
        ' <= '
        ' >= '
        ' <> '
        ' LIKE '#39#39' '#39#39
        ' CONTAINING '#39#39' '#39#39
        #39#39)
      DropDownCount = 12
    end
    object gscbFunctions: TgsComboButton
      Left = 7
      Top = 84
      Width = 93
      Height = 30
      Caption = 'Функции >>'
      TabOrder = 2
      OnCloseUp = gscbOperatorsCloseUp
      Items.Strings = (
        ' COUNT( ) '
        ' ALL '
        ' DISTINCT( ) '
        ' SUM( ) '
        ' AVG( ) '
        ' MAX( ) '
        ' MIN( ) '
        ' CAST( ) '
        ' UPPER( ) '
        ' GEN_ID( , ) ')
      DropDownCount = 12
    end
    object btnProcedure: TButton
      Left = 7
      Top = 123
      Width = 93
      Height = 31
      Action = actProcedure
      TabOrder = 3
    end
    object btnSQLEditor: TButton
      Left = 7
      Top = 162
      Width = 93
      Height = 31
      Caption = 'SQL редактор'
      TabOrder = 4
      OnClick = btnSQLEditorClick
    end
  end
  object pnlMemo: TPanel
    Left = 0
    Top = 0
    Width = 373
    Height = 286
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 0
    object mmFormula: TMemo
      Left = 3
      Top = 3
      Width = 367
      Height = 280
      Align = alClient
      HideSelection = False
      TabOrder = 0
    end
  end
  object ActionList1: TActionList
    Left = 248
    Top = 8
    object actUndo: TAction
      Caption = 'Отменить'
      OnExecute = actUndoExecute
    end
    object actProcedure: TAction
      Caption = 'Процедуры'
      OnExecute = actProcedureExecute
    end
  end
end
