object dlgEditForm: TdlgEditForm
  Left = 506
  Top = 233
  Width = 364
  Height = 281
  HelpContext = 205
  BorderWidth = 5
  Caption = 'Свойства блока'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pBottom: TPanel
    Left = 0
    Top = 214
    Width = 346
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object bCancel: TButton
      Left = 269
      Top = 9
      Width = 77
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      ModalResult = 2
      TabOrder = 1
    end
    object bOk: TButton
      Left = 191
      Top = 9
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 0
    end
    object bHelp: TButton
      Left = 1
      Top = 9
      Width = 75
      Height = 21
      Action = actHelp
      TabOrder = 2
    end
  end
  object ActionList: TActionList
    Left = 32
    Top = 112
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
  end
end
