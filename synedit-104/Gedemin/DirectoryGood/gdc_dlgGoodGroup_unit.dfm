inherited gdc_dlgGoodGroup: Tgdc_dlgGoodGroup
  Left = 355
  Top = 203
  HelpContext = 50
  ActiveControl = dbeName
  Caption = 'Параметры группы ТМЦ'
  ClientHeight = 231
  ClientWidth = 406
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 205
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 85
    Top = 205
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 245
    Top = 205
    TabOrder = 5
  end
  inherited btnCancel: TButton
    Left = 325
    Top = 205
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 205
    TabOrder = 2
  end
  object PageControl1: TPageControl [5]
    Left = 5
    Top = 5
    Width = 396
    Height = 196
    ActivePage = tsGood
    TabOrder = 0
    object tsGood: TTabSheet
      Caption = '&1. Группа'
      object Label1: TLabel
        Left = 8
        Top = 16
        Width = 117
        Height = 13
        Caption = 'Наименование группы:'
      end
      object Label2: TLabel
        Left = 8
        Top = 40
        Width = 93
        Height = 13
        Caption = 'Описание группы:'
      end
      object Label3: TLabel
        Left = 8
        Top = 99
        Width = 74
        Height = 13
        Caption = 'Шифр группы:'
      end
      object Label4: TLabel
        Left = 9
        Top = 124
        Width = 88
        Height = 13
        Caption = 'Входит в группу:'
      end
      object dbmDescription: TDBMemo
        Left = 136
        Top = 40
        Width = 249
        Height = 56
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbcbDisabled: TDBCheckBox
        Left = 8
        Top = 144
        Width = 97
        Height = 17
        Caption = 'Отключена'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 3
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbeName: TDBEdit
        Left = 136
        Top = 16
        Width = 249
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbeAlias: TDBEdit
        Left = 136
        Top = 99
        Width = 249
        Height = 21
        DataField = 'ALIAS'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object iblcGoodGroup: TgsIBLookupComboBox
        Left = 136
        Top = 123
        Width = 249
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'parent'
        ListTable = 'gd_goodgroup'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcGoodGroup'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
    end
    object TabSheet1: TTabSheet
      Caption = '&2. Атрибуты'
      ImageIndex = 1
      object atContainer1: TatContainer
        Left = 0
        Top = 0
        Width = 388
        Height = 168
        DataSource = dsgdcBase
        Align = alClient
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 200
    Top = 10
  end
  inherited dsgdcBase: TDataSource
    Left = 170
    Top = 10
  end
end
