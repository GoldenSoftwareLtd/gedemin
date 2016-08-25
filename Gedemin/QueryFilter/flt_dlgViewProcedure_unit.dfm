object dlgViewProcedure: TdlgViewProcedure
  Left = 170
  Top = 187
  BorderStyle = bsDialog
  Caption = 'Список процедур'
  ClientHeight = 224
  ClientWidth = 359
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 280
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Выбрать'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 280
    Top = 192
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Закрыть'
    ModalResult = 2
    TabOrder = 5
  end
  object Button3: TButton
    Left = 280
    Top = 40
    Width = 75
    Height = 25
    Action = actEditProcedure
    TabOrder = 2
  end
  object Button4: TButton
    Left = 280
    Top = 8
    Width = 75
    Height = 25
    Action = actAddProcedure
    TabOrder = 1
  end
  object Button5: TButton
    Left = 280
    Top = 72
    Width = 75
    Height = 25
    Action = actDeleteProcedure
    TabOrder = 3
  end
  object lvProcedure: TListView
    Left = 0
    Top = 0
    Width = 273
    Height = 224
    Columns = <
      item
        Caption = 'Наименование'
        Width = 150
      end
      item
        Caption = 'Описание'
        Width = 119
      end>
    HideSelection = False
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ActionList1: TActionList
    Left = 328
    Top = 104
    object actAddProcedure: TAction
      Caption = 'Создать...'
      OnExecute = actAddProcedureExecute
    end
    object actEditProcedure: TAction
      Caption = 'Изменить...'
      OnExecute = actEditProcedureExecute
      OnUpdate = actEditProcedureUpdate
    end
    object actDeleteProcedure: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteProcedureExecute
      OnUpdate = actEditProcedureUpdate
    end
  end
  object ibsqlProcedure: TIBSQL
    ParamCheck = True
    SQL.Strings = (
      'SELECT '
      '  *'
      'FROM'
      '  flt_procedurefilter'
      'WHERE'
      '  componentkey = :componentkey'
      ' /* AND g_sec_test(aview, :ingroup) <> 0*/')
    Left = 280
    Top = 104
  end
end
