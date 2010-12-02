object dlgAnaliticSelect: TdlgAnaliticSelect
  Left = 350
  Top = 179
  Width = 264
  Height = 245
  BorderWidth = 5
  Caption = 'Выбор аналитики'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 182
    Width = 246
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 171
      Top = 5
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object Button2: TButton
      Left = 83
      Top = 5
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 1
    end
  end
  object clbAlalitics: TCheckListBox
    Left = 0
    Top = 0
    Width = 246
    Height = 182
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
  end
  object ActionList: TActionList
    Left = 96
    Top = 40
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
  end
end
