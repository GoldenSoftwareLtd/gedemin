object dlgEditEntry: TdlgEditEntry
  Left = 246
  Top = 101
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Редактирование проводок по операции'
  ClientHeight = 331
  ClientWidth = 538
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 179
    Width = 54
    Height = 13
    Caption = 'Аналитика'
  end
  object sgrEntry: TStringGrid
    Left = 8
    Top = 8
    Width = 433
    Height = 167
    Ctl3D = False
    DefaultColWidth = 80
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goRangeSelect, goColSizing, goEditing]
    ParentCtl3D = False
    TabOrder = 0
    OnSelectCell = sgrEntrySelectCell
    ColWidths = (
      80
      87
      80
      80
      80)
  end
  object Button1: TButton
    Left = 450
    Top = 8
    Width = 75
    Height = 25
    Action = actOk
    TabOrder = 1
  end
  object Button2: TButton
    Left = 450
    Top = 37
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    TabOrder = 2
  end
  object Button3: TButton
    Left = 450
    Top = 65
    Width = 75
    Height = 25
    Action = actNext
    TabOrder = 3
  end
  object sbAnalyze: TScrollBox
    Left = 8
    Top = 194
    Width = 433
    Height = 133
    TabOrder = 4
  end
  object Button4: TButton
    Left = 450
    Top = 94
    Width = 75
    Height = 25
    Action = actPrev
    TabOrder = 5
  end
  object Button5: TButton
    Left = 450
    Top = 122
    Width = 75
    Height = 25
    Action = actNewLine
    TabOrder = 6
  end
  object Button6: TButton
    Left = 450
    Top = 150
    Width = 75
    Height = 25
    Action = actDelete
    TabOrder = 7
  end
  object ActionList1: TActionList
    Left = 480
    Top = 240
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actNext: TAction
      Caption = 'Следующая'
      ShortCut = 16418
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actPrev: TAction
      Caption = 'Предыдущая'
      ShortCut = 16417
      OnExecute = actPrevExecute
      OnUpdate = actPrevUpdate
    end
    object actNewLine: TAction
      Caption = 'Добавить'
      ShortCut = 45
      OnExecute = actNewLineExecute
    end
    object actDelete: TAction
      Caption = 'Удалить'
      ShortCut = 16430
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 488
    Top = 208
  end
end
