object frmAnalytics: TfrmAnalytics
  Left = 293
  Top = 219
  Width = 457
  Height = 386
  HelpContext = 16
  BorderIcons = [biSystemMenu, biMaximize, biHelp]
  BorderWidth = 5
  Caption = 'Фиксированные значения аналитик'
  Color = clBtnFace
  Constraints.MinHeight = 386
  Constraints.MinWidth = 457
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 281
    Top = 328
    Width = 75
    Height = 21
    Action = actOk
    Anchors = [akRight, akBottom]
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 364
    Top = 328
    Width = 75
    Height = 21
    Action = actCancel
    Anchors = [akRight, akBottom]
    Cancel = True
    ModalResult = 2
    TabOrder = 1
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 439
    Height = 323
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 2
    object Panel3: TPanel
      Left = 0
      Top = 250
      Width = 439
      Height = 73
      Align = alBottom
      BevelOuter = bvLowered
      FullRepaint = False
      TabOrder = 0
      object mValue: TMemo
        Left = 1
        Top = 1
        Width = 437
        Height = 71
        Align = alClient
        BorderStyle = bsNone
        Color = clInfoBk
        ReadOnly = True
        TabOrder = 0
      end
    end
    object cbAnalyticName: TCheckBox
      Left = 0
      Top = 231
      Width = 145
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'С именами аналитики'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    inline frFixedAnalytics: TfrFixedAnalytics
      Width = 439
      Height = 224
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 2
      inherited Panel: TPanel
        Width = 439
        Height = 224
        inherited sbAnalytics: TScrollBox
          Width = 437
          Height = 222
        end
      end
    end
  end
  object ActionList: TActionList
    Left = 160
    Top = 224
    object actOk: TAction
      Caption = '&OK'
      ShortCut = 16397
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 80
    Top = 192
  end
end
