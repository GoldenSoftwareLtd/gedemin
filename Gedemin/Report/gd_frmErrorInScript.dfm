object frmErrorInScript: TfrmErrorInScript
  Left = 334
  Top = 245
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Ошибка'
  ClientHeight = 189
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 159
    Width = 366
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 0
      Top = 7
      Width = 70
      Height = 21
      Caption = '&Ok'
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 191
      Top = 7
      Width = 145
      Height = 21
      Caption = 'Выйти из программы'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 75
      Top = 7
      Width = 111
      Height = 21
      Action = actEditFunction
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 366
    Height = 159
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object mmErrorMessage: TMemo
      Left = 1
      Top = 1
      Width = 364
      Height = 157
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
