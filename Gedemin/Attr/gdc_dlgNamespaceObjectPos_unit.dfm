object gdc_dlgNamespaceObjectPos: Tgdc_dlgNamespaceObjectPos
  Left = 656
  Top = 249
  BorderStyle = bsDialog
  Caption = 'Изменение позиции объектов'
  ClientHeight = 438
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lv: TListView
    Left = 8
    Top = 8
    Width = 345
    Height = 393
    Columns = <
      item
        AutoSize = True
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 0
    ViewStyle = vsReport
  end
  object btnOk: TButton
    Left = 200
    Top = 408
    Width = 75
    Height = 21
    Action = actOK
    Default = True
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 280
    Top = 408
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 2
  end
  object btnUp: TButton
    Left = 8
    Top = 408
    Width = 75
    Height = 21
    Action = actUp
    TabOrder = 3
  end
  object btnDown: TButton
    Left = 88
    Top = 408
    Width = 75
    Height = 21
    Action = actDown
    TabOrder = 4
  end
  object ActionList: TActionList
    Left = 176
    Top = 192
    object actOK: TAction
      Caption = 'Ok'
      OnExecute = actOKExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actUp: TAction
      Caption = 'Вверх'
      OnExecute = actUpExecute
      OnUpdate = actUpUpdate
    end
    object actDown: TAction
      Caption = 'Вниз'
      OnExecute = actDownExecute
      OnUpdate = actDownUpdate
    end
  end
end
