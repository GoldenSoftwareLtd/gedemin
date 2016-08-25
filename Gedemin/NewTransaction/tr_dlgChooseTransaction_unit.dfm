object dlgChooseTransaction: TdlgChooseTransaction
  Left = 310
  Top = 171
  Width = 438
  Height = 246
  Caption = 'Выбор операций'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object bOk: TButton
    Left = 346
    Top = 8
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object bCancel: TButton
    Left = 346
    Top = 38
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object lvTransaction: TListView
    Left = 8
    Top = 8
    Width = 326
    Height = 202
    Columns = <
      item
        AutoSize = True
        Caption = 'Наименование операции'
      end
      item
        Caption = 'Описание'
      end>
    ColumnClick = False
    RowSelect = True
    SortType = stText
    TabOrder = 2
    ViewStyle = vsReport
  end
  object ActionList1: TActionList
    Left = 368
    Top = 104
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
  end
end
