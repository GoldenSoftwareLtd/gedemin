object frmErrorInScript: TfrmErrorInScript
  Left = 334
  Top = 245
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Ошибка'
  ClientHeight = 163
  ClientWidth = 337
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
    Top = 133
    Width = 337
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 0
      Top = 9
      Width = 70
      Height = 21
      Caption = '&Ok'
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 191
      Top = 9
      Width = 145
      Height = 21
      Caption = 'Выйти из программы'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 75
      Top = 9
      Width = 111
      Height = 21
      Action = actEditFunction
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 337
    Height = 133
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object mmErrorMessage: TMemo
      Left = 1
      Top = 1
      Width = 335
      Height = 131
      TabStop = False
      Align = alClient
      BorderStyle = bsNone
      Color = clBtnFace
      Lines.Strings = (
        '')
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
      WantReturns = False
    end
  end
  object ActionList1: TActionList
    Left = 296
    Top = 40
    object actEditFunction: TAction
      Caption = 'Редактировать'
      OnExecute = actEditFunctionExecute
      OnUpdate = actEditFunctionUpdate
    end
  end
end
