object BlockEditForm: TBlockEditForm
  Left = 367
  Top = 216
  HelpContext = 205
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Свойства блока'
  ClientHeight = 204
  ClientWidth = 349
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
  object Panel1: TPanel
    Left = 0
    Top = 174
    Width = 349
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 272
      Top = 5
      Width = 77
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      ModalResult = 2
      TabOrder = 1
    end
    object Button2: TButton
      Left = 194
      Top = 5
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object Button4: TButton
      Left = 2
      Top = 5
      Width = 75
      Height = 21
      Action = actHelp
      TabOrder = 2
    end
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 349
    Height = 174
    ActivePage = tsGeneral
    Align = alClient
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = 'Общие'
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 79
        Height = 13
        Caption = 'Наименование:'
        WordWrap = True
      end
      object Label2: TLabel
        Left = 8
        Top = 58
        Width = 53
        Height = 13
        Caption = 'Описание:'
      end
      object lLocalName: TLabel
        Left = 8
        Top = 26
        Width = 89
        Height = 30
        AutoSize = False
        Caption = 'Локальное наименование:'
        WordWrap = True
      end
      object cbName: TComboBox
        Left = 96
        Top = 8
        Width = 238
        Height = 21
        Style = csSimple
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        Text = 'cbName'
      end
      object mDescription: TMemo
        Left = 96
        Top = 54
        Width = 238
        Height = 89
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'mDescription')
        TabOrder = 1
      end
      object eLocalName: TEdit
        Left = 96
        Top = 31
        Width = 239
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
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
