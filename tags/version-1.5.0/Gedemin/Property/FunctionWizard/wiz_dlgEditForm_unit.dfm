object dlgEditForm: TdlgEditForm
  Left = 746
  Top = 208
  Width = 364
  Height = 281
  HelpContext = 205
  BorderWidth = 5
  Caption = '�������� �����'
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
    Top = 210
    Width = 346
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object bHelp: TButton
      Left = 1
      Top = 9
      Width = 75
      Height = 21
      Action = actHelp
      TabOrder = 0
    end
    object pnlRightButtons: TPanel
      Left = 184
      Top = 0
      Width = 162
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object bOk: TButton
        Left = 7
        Top = 9
        Width = 75
        Height = 21
        Action = actOk
        Anchors = [akRight, akBottom]
        Default = True
        TabOrder = 0
      end
      object bCancel: TButton
        Left = 85
        Top = 9
        Width = 77
        Height = 21
        Action = actCancel
        Anchors = [akRight, akBottom]
        ModalResult = 2
        TabOrder = 1
      end
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
      Caption = '������'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = '�������'
      OnExecute = actHelpExecute
    end
  end
end
