object dlg_gsResizer_ObjectInspectorFind: Tdlg_gsResizer_ObjectInspectorFind
  Left = 374
  Top = 195
  BorderStyle = bsDialog
  Caption = 'Поиск объекта'
  ClientHeight = 221
  ClientWidth = 305
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
    Width = 298
    Height = 140
    Caption = ' Результаты поиска '
    TabOrder = 1
    object lbResult: TListBox
      Left = 7
      Top = 16
      Width = 284
      Height = 116
      Enabled = False
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = lbResultDblClick
      OnKeyPress = lbResultKeyPress
    end
  end
  object btnGoTo: TButton
    Left = 147
    Top = 195
    Width = 75
    Height = 21
    Action = actGoTo
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 226
    Top = 195
    Width = 75
    Height = 21
    Action = actCancel
    TabOrder = 3
  end
  object gbFind: TGroupBox
    Left = 3
    Top = 0
    Width = 298
    Height = 46
    Caption = ' Параметры поиска '
    TabOrder = 0
    object lblName: TLabel
      Left = 8
      Top = 19
      Width = 53
      Height = 13
      Caption = 'Название:'
    end
    object edtText: TEdit
      Left = 64
      Top = 17
      Width = 152
      Height = 21
      TabOrder = 0
      OnKeyPress = edtTextKeyPress
    end
    object btnFind: TButton
      Left = 220
      Top = 17
      Width = 71
      Height = 21
      Action = actFind
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
