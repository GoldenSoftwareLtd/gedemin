object dlgConfigName: TdlgConfigName
  Left = 305
  Top = 237
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Сохранение конфигурации'
  ClientHeight = 66
  ClientWidth = 259
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lConfigName: TLabel
    Left = 6
    Top = 0
    Width = 143
    Height = 13
    Caption = 'Введите имя конфигурации:'
  end
  object Panel1: TPanel
    Left = 0
    Top = 40
    Width = 259
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 180
      Top = 5
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 1
    end
    object Button2: TButton
      Left = 100
      Top = 5
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 0
    end
  end
  object iblName: TgsIBLookupComboBox
    Left = 6
    Top = 16
    Width = 249
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = Transaction
    ListTable = 'ac_acct_config'
    ListField = 'name'
    KeyField = 'id'
    SortOrder = soAsc
    StrictOnExit = False
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object ActionList: TActionList
    Left = 48
    Top = 32
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
  end
  object Transaction: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 16
    Top = 31
  end
end
