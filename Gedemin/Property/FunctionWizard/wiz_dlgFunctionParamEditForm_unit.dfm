object dlgFunctionParamEditForm: TdlgFunctionParamEditForm
  Left = 366
  Top = 216
  BorderStyle = bsDialog
  Caption = 'Свойства параметра'
  ClientHeight = 97
  ClientWidth = 398
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
    Top = 63
    Width = 398
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 398
      Height = 5
      Align = alTop
      Shape = bsBottomLine
    end
    object Button1: TButton
      Left = 316
      Top = 8
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object Button2: TButton
      Left = 235
      Top = 8
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 398
    Height = 63
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 79
      Height = 13
      Caption = 'Наименование:'
    end
    object Label2: TLabel
      Left = 8
      Top = 36
      Width = 90
      Height = 13
      Caption = 'Способ передачи:'
    end
    object eName: TEdit
      Left = 104
      Top = 8
      Width = 288
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object cbReferenceType: TComboBox
      Left = 104
      Top = 32
      Width = 288
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        ''
        'ByVal'
        'ByRef')
    end
  end
  object ActionList1: TActionList
    Left = 24
    Top = 32
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
  end
end
