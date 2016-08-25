inherited gdc_dlgJournal: Tgdc_dlgJournal
  Left = 390
  Top = 219
  Caption = 'gdc_dlgJournal'
  ClientHeight = 470
  ClientWidth = 489
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'Tahoma'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lDate: TLabel [0]
    Left = 8
    Top = 12
    Width = 73
    Height = 13
    Caption = 'Дата и время:'
  end
  object lUser: TLabel [1]
    Left = 8
    Top = 36
    Width = 76
    Height = 13
    Caption = 'Пользователь:'
  end
  object lSource: TLabel [2]
    Left = 8
    Top = 60
    Width = 34
    Height = 13
    Caption = 'Класс:'
  end
  object lID: TLabel [3]
    Left = 8
    Top = 85
    Width = 65
    Height = 13
    Caption = 'ИД объекта:'
  end
  object lData: TLabel [4]
    Left = 8
    Top = 109
    Width = 44
    Height = 13
    Caption = 'Данные:'
  end
  inherited btnAccess: TButton
    Left = 7
    Top = 442
    TabOrder = 8
  end
  inherited btnNew: TButton
    Left = 79
    Top = 442
    TabOrder = 9
  end
  inherited btnHelp: TButton
    Left = 151
    Top = 442
    TabOrder = 10
  end
  inherited btnOK: TButton
    Left = 339
    Top = 442
    TabOrder = 6
  end
  inherited btnCancel: TButton
    Left = 412
    Top = 442
    TabOrder = 7
  end
  object dbedDate: TDBEdit [10]
    Left = 88
    Top = 8
    Width = 177
    Height = 21
    DataField = 'operationdate'
    DataSource = dsgdcBase
    ReadOnly = True
    TabOrder = 0
  end
  object dbmData: TDBMemo [11]
    Left = 8
    Top = 125
    Width = 473
    Height = 313
    DataField = 'DATA'
    DataSource = dsgdcBase
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object iblkupUser: TgsIBLookupComboBox [12]
    Left = 88
    Top = 32
    Width = 260
    Height = 21
    HelpContext = 1
    DataSource = dsgdcBase
    DataField = 'contactkey'
    ListTable = 'gd_contact'
    ListField = 'name'
    KeyField = 'id'
    ReadOnly = True
    ItemHeight = 13
    TabOrder = 1
  end
  object dbedSource: TDBEdit [13]
    Left = 88
    Top = 56
    Width = 260
    Height = 21
    DataField = 'SOURCE'
    DataSource = dsgdcBase
    ReadOnly = True
    TabOrder = 2
  end
  object dbedID: TDBEdit [14]
    Left = 88
    Top = 80
    Width = 177
    Height = 21
    DataField = 'OBJECTID'
    DataSource = dsgdcBase
    ReadOnly = True
    TabOrder = 3
  end
  object btnOpenObject: TButton [15]
    Left = 268
    Top = 79
    Width = 80
    Height = 21
    Action = actOpenObject
    TabOrder = 4
  end
  inherited alBase: TActionList
    Left = 110
    Top = 211
  end
  inherited dsgdcBase: TDataSource
    Left = 72
    Top = 211
  end
  inherited pm_dlgG: TPopupMenu
    Left = 144
    Top = 212
  end
  object ActionList: TActionList
    Left = 376
    Top = 16
    object actOpenObject: TAction
      Caption = 'Открыть...'
      OnExecute = actOpenObjectExecute
      OnUpdate = actOpenObjectUpdate
    end
  end
end
