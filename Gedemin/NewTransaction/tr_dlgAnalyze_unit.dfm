object dlgAnalyze: TdlgAnalyze
  Left = 244
  Top = 107
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Параметры аналитики'
  ClientHeight = 142
  ClientWidth = 545
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 72
    Height = 13
    Caption = 'Аналитика по '
  end
  object Label2: TLabel
    Left = 16
    Top = 43
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object Label3: TLabel
    Left = 16
    Top = 70
    Width = 119
    Height = 13
    Caption = 'Краткое наименование'
  end
  object Label4: TLabel
    Left = 16
    Top = 97
    Width = 50
    Height = 13
    Caption = 'Описание'
  end
  object gsiblcRelation: TgsIBLookupComboBox
    Left = 152
    Top = 10
    Width = 297
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    ListTable = 'AT_RELATIONS'
    ListField = 'LName'
    KeyField = 'RELATIONNAME'
    CheckUserRights = False
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnExit = gsiblcRelationExit
  end
  object edName: TEdit
    Left = 152
    Top = 38
    Width = 297
    Height = 21
    TabOrder = 1
  end
  object edShortName: TEdit
    Left = 152
    Top = 65
    Width = 297
    Height = 21
    TabOrder = 2
  end
  object edDescription: TEdit
    Left = 152
    Top = 93
    Width = 297
    Height = 21
    TabOrder = 3
  end
  object Button1: TButton
    Left = 460
    Top = 8
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    TabOrder = 4
  end
  object Button2: TButton
    Left = 460
    Top = 38
    Width = 75
    Height = 25
    Action = actNext
    TabOrder = 5
  end
  object Button3: TButton
    Left = 460
    Top = 68
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    TabOrder = 6
  end
  object Button4: TButton
    Left = 460
    Top = 113
    Width = 75
    Height = 25
    Action = actRight
    TabOrder = 7
  end
  object ActionList1: TActionList
    Left = 88
    Top = 88
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actNext: TAction
      Caption = 'Следующая'
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actRight: TAction
      Caption = 'Права...'
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 40
    Top = 112
  end
  object IBSQL: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'UPDATE AT_RELATION_FIELDS '
      'SET'
      '    LNAME = :LNAME,'
      '    LSHORTNAME = :LSHORTNAME,'
      '    DESCRIPTION = :DESCRIPTION'
      'WHERE'
      '  RELATIONNAME = '#39'GD_CARDACCOUNT'#39' AND'
      '  FIELDNAME = :FIELDNAME  ')
    Transaction = IBTransaction
    Left = 176
    Top = 112
  end
end
