object dlg_gsResizer_ObjectInspectorFind: Tdlg_gsResizer_ObjectInspectorFind
  Left = 374
  Top = 195
  BorderStyle = bsDialog
  Caption = 'Поиск объекта'
  ClientHeight = 512
  ClientWidth = 431
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbResult: TGroupBox
    Left = 3
    Top = 48
    Width = 424
    Height = 431
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' Результаты поиска '
    TabOrder = 1
    object lbResult: TListBox
      Left = 7
      Top = 16
      Width = 410
      Height = 407
      Anchors = [akLeft, akTop, akRight, akBottom]
      Enabled = False
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = lbResultDblClick
      OnKeyPress = lbResultKeyPress
    end
  end
  object btnGoTo: TButton
    Left = 273
    Top = 486
    Width = 75
    Height = 21
    Action = actGoTo
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 352
    Top = 486
    Width = 75
    Height = 21
    Action = actCancel
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object gbFind: TGroupBox
    Left = 3
    Top = 0
    Width = 424
    Height = 46
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Параметры поиска '
    TabOrder = 0
    object lblName: TLabel
      Left = 8
      Top = 19
      Width = 52
      Height = 13
      Caption = 'Название:'
    end
    object edtText: TEdit
      Left = 64
      Top = 17
      Width = 278
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnKeyPress = edtTextKeyPress
    end
    object btnFind: TButton
      Left = 328
      Top = 17
      Width = 71
      Height = 21
      Action = actFind
      Anchors = [akTop, akBottom]
      Default = True
      TabOrder = 1
    end
  end
  object alFind: TActionList
    Left = 211
    Top = 72
    object actFind: TAction
      Caption = 'Искать'
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actGoTo: TAction
      Caption = 'Перейти'
      OnExecute = actGoToExecute
      OnUpdate = actGoToUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
end
