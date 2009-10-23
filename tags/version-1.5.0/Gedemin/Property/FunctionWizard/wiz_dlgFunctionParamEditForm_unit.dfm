object dlgFunctionParamEditForm: TdlgFunctionParamEditForm
  Left = 366
  Top = 216
  Width = 273
  Height = 117
  BorderWidth = 5
  Caption = 'Своиства параметра'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 49
    Width = 255
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 255
      Height = 5
      Align = alTop
      Shape = bsBottomLine
    end
    object Button1: TButton
      Left = 180
      Top = 10
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object Button2: TButton
      Left = 100
      Top = 10
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
    Width = 255
    Height = 49
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 0
      Top = 4
      Width = 79
      Height = 13
      Caption = 'Наименование:'
    end
    object Label2: TLabel
      Left = 0
      Top = 28
      Width = 90
      Height = 13
      Caption = 'Способ передачи:'
    end
    object eName: TEdit
      Left = 104
      Top = 0
      Width = 151
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object cbReferenceType: TComboBox
      Left = 104
      Top = 24
      Width = 151
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
