object gdc_dlgQueryDescendant: Tgdc_dlgQueryDescendant
  Left = 559
  Top = 323
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор объекта '
  ClientHeight = 123
  ClientWidth = 401
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object rgObjects: TRadioGroup
    Left = 5
    Top = 1
    Width = 390
    Height = 88
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object pnlBtns: TPanel
    Left = 0
    Top = 93
    Width = 401
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnClasses: TButton
      Left = 5
      Top = 3
      Width = 21
      Height = 21
      Action = actClasses
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 239
      Top = 3
      Width = 75
      Height = 21
      Action = acOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 319
      Top = 3
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      Cancel = True
      TabOrder = 2
    end
  end
  object ActionList: TActionList
    Left = 193
    Top = 32
    object acOk: TAction
      Caption = 'Ок'
      OnExecute = acOkExecute
      OnUpdate = acOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actClasses: TAction
      Caption = '?'
      OnExecute = actClassesExecute
    end
  end
end
