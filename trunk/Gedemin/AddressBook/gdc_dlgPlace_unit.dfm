inherited gdc_dlgPlace: Tgdc_dlgPlace
  Left = 294
  Top = 243
  ActiveControl = DBComboBox1
  BorderWidth = 5
  Caption = 'Адм.-территориальная единица'
  ClientHeight = 217
  ClientWidth = 367
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 0
    Top = 196
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Left = 72
    Top = 196
    Anchors = [akLeft, akBottom]
  end
  inherited btnOK: TButton
    Left = 227
    Top = 196
    Anchors = [akLeft, akBottom]
  end
  inherited btnCancel: TButton
    Left = 299
    Top = 196
    Anchors = [akLeft, akBottom]
  end
  inherited btnHelp: TButton
    Left = 143
    Top = 196
    Anchors = [akLeft, akBottom]
  end
  inherited pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 367
    Height = 185
    Align = alTop
    inherited tbsMain: TTabSheet
      inherited dbtxtID: TDBText
        Left = 130
      end
      object Label2: TLabel
        Left = 8
        Top = 83
        Width = 114
        Height = 13
        Caption = 'Телефонный префикс:'
        FocusControl = dbeTelPrefix
      end
      object Label3: TLabel
        Left = 8
        Top = 130
        Width = 50
        Height = 13
        Caption = '&Входит в:'
        FocusControl = cbMaster
      end
      object Label1: TLabel
        Left = 8
        Top = 58
        Width = 77
        Height = 13
        Caption = '&Наименование:'
        FocusControl = dbedName
      end
      object Label4: TLabel
        Left = 8
        Top = 32
        Width = 70
        Height = 13
        Caption = 'Тип единицы:'
      end
      object Label5: TLabel
        Left = 8
        Top = 107
        Width = 79
        Height = 13
        Caption = 'Код местности:'
        FocusControl = dbeCode
      end
      object cbMaster: TgsIBLookupComboBox
        Left = 129
        Top = 126
        Width = 216
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = dmDatabase.ibtrGenUniqueID
        DataSource = dsgdcBase
        DataField = 'PARENT'
        ListTable = 'gd_place'
        ListField = 'name'
        KeyField = 'id'
        gdClassName = 'TgdcPlace'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object dbeTelPrefix: TDBEdit
        Left = 129
        Top = 79
        Width = 216
        Height = 21
        DataField = 'TelPrefix'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbedName: TDBEdit
        Left = 129
        Top = 54
        Width = 216
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object DBComboBox1: TDBComboBox
        Left = 129
        Top = 29
        Width = 216
        Height = 21
        Style = csDropDownList
        DataField = 'placetype'
        DataSource = dsgdcBase
        ItemHeight = 13
        Items.Strings = (
          'Страна'
          'Область'
          'Район'
          'Нас. пункт'
          'Прочее')
        TabOrder = 0
      end
      object dbeCode: TDBEdit
        Left = 129
        Top = 103
        Width = 216
        Height = 21
        DataField = 'Code'
        DataSource = dsgdcBase
        TabOrder = 3
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 357
        Height = 135
      end
    end
  end
  inherited alBase: TActionList
    Left = 295
    Top = 32
  end
  inherited dsgdcBase: TDataSource
    Left = 265
    Top = 0
  end
  inherited pm_dlgG: TPopupMenu
    Left = 296
    Top = 0
  end
  inherited ibtrCommon: TIBTransaction
    Left = 264
    Top = 32
  end
end
