object dlg_EditNewForm: Tdlg_EditNewForm
  Left = 280
  Top = 171
  Width = 344
  Height = 402
  HelpContext = 103
  Caption = 'Редактор форм'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 235
    Top = 0
    Width = 93
    Height = 364
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 4
      Top = 338
      Width = 85
      Height = 21
      Action = actExit
      Anchors = [akLeft, akBottom]
      Cancel = True
      TabOrder = 6
    end
    object Button2: TButton
      Left = 4
      Top = 4
      Width = 85
      Height = 21
      Action = actNewForm
      TabOrder = 0
    end
    object Button3: TButton
      Left = 4
      Top = 30
      Width = 85
      Height = 21
      Action = actEditForm
      Default = True
      TabOrder = 1
    end
    object Button4: TButton
      Left = 4
      Top = 55
      Width = 85
      Height = 21
      Action = actDeleteForm
      TabOrder = 2
    end
    object Button5: TButton
      Left = 4
      Top = 87
      Width = 85
      Height = 21
      Action = actFormAsDFM
      TabOrder = 3
    end
    object Button6: TButton
      Left = 4
      Top = 113
      Width = 85
      Height = 21
      Action = actRefresh
      TabOrder = 4
    end
    object Button7: TButton
      Left = 4
      Top = 144
      Width = 85
      Height = 21
      Action = actHelp
      TabOrder = 5
    end
  end
  object pnlList: TPanel
    Left = 0
    Top = 0
    Width = 235
    Height = 364
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    Caption = 'Идет редактирование формы...'
    TabOrder = 0
    object lbForms: TListBox
      Left = 4
      Top = 4
      Width = 227
      Height = 356
      Align = alClient
      ItemHeight = 13
      PopupMenu = PopupMenu1
      Sorted = True
      TabOrder = 0
      OnDblClick = actEditFormExecute
    end
  end
  object alEditForm: TActionList
    Left = 128
    Top = 136
    object actNewForm: TAction
      Caption = 'Создать'
      ShortCut = 45
      OnExecute = actNewFormExecute
      OnUpdate = actNewFormUpdate
    end
    object actEditForm: TAction
      Caption = 'Изменить'
      ShortCut = 16397
      OnExecute = actEditFormExecute
      OnUpdate = actEditFormUpdate
    end
    object actDeleteForm: TAction
      Caption = 'Удалить'
      ShortCut = 16430
      OnExecute = actDeleteFormExecute
      OnUpdate = actEditFormUpdate
    end
    object actExit: TAction
      Caption = 'Закрыть'
      OnExecute = actExitExecute
    end
    object actFormAsDFM: TAction
      Caption = 'DFM как текст'
      OnExecute = actFormAsDFMExecute
      OnUpdate = actEditFormUpdate
    end
    object actRefresh: TAction
      Caption = 'Обновить'
      ShortCut = 116
      OnExecute = actRefreshExecute
      OnUpdate = actRefreshUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 80
    Top = 104
    object N3: TMenuItem
      Action = actNewForm
    end
    object N4: TMenuItem
      Action = actEditForm
    end
    object N5: TMenuItem
      Action = actDeleteForm
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Action = actFormAsDFM
    end
    object N2: TMenuItem
      Action = actRefresh
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object N8: TMenuItem
      Action = actHelp
    end
  end
end
