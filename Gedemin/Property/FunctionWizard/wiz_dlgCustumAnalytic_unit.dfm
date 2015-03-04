object CustomAnalyticForm: TCustomAnalyticForm
  Left = 310
  Top = 196
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Произвольная аналитика'
  ClientHeight = 130
  ClientWidth = 352
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 104
    Width = 352
    Height = 3
    Align = alTop
    Shape = bsTopLine
  end
  object bCancel: TButton
    Left = 277
    Top = 109
    Width = 75
    Height = 21
    Action = actCancel
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 2
  end
  object bOK: TButton
    Left = 197
    Top = 109
    Width = 75
    Height = 21
    Action = actOk
    Anchors = [akRight, akBottom]
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 352
    Height = 104
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 2
      Top = -1
      Width = 81
      Height = 13
      Caption = 'Имя аналитики:'
      FocusControl = cbAnalyticValue
    end
    object Label2: TLabel
      Left = 2
      Top = 39
      Width = 107
      Height = 13
      Caption = 'Значение аналитики:'
    end
    object cbNeedId: TCheckBox
      Left = 2
      Top = 83
      Width = 289
      Height = 17
      Caption = 'Получить ИД аналитики'
      TabOrder = 2
    end
    object cbAnalyticValue: TgsIBLookupComboBox
      Left = 2
      Top = 55
      Width = 350
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = Transaction
      SortOrder = soAsc
      Enabled = False
      ItemHeight = 13
      TabOrder = 1
    end
    object cbBO: TComboBox
      Left = 2
      Top = 16
      Width = 350
      Height = 21
      DropDownCount = 24
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
      OnChange = cbAnalyticNameChange
      OnDropDown = cbBODropDown
    end
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 88
    Top = 96
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actAdd: TAction
      Caption = 'Добавить аналитику'
      Hint = 'Добавить аналитику'
      ImageIndex = 179
    end
    object actEdit: TAction
      Caption = 'Изменить аналитику'
      Hint = 'Изменить аналитику'
      ImageIndex = 177
    end
    object actDelete: TAction
      Caption = 'Удалить аналитику'
      Hint = 'Удалить аналитику'
      ImageIndex = 178
    end
  end
  object Transaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 24
    Top = 88
  end
end
