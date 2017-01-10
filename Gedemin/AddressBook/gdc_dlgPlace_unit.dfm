inherited gdc_dlgPlace: Tgdc_dlgPlace
  Left = 856
  Top = 399
  ActiveControl = DBComboBox1
  BorderWidth = 5
  Caption = 'Адм.-территориальная единица'
  ClientHeight = 258
  ClientWidth = 367
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 0
    Top = 237
  end
  inherited btnNew: TButton
    Left = 72
    Top = 237
  end
  inherited btnHelp: TButton
    Left = 143
    Top = 237
  end
  inherited btnOK: TButton
    Left = 227
    Top = 237
    Anchors = [akLeft, akBottom]
  end
  inherited btnCancel: TButton
    Left = 299
    Top = 237
    Anchors = [akLeft, akBottom]
  end
  inherited pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 367
    Height = 232
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
        Top = 134
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
        Top = 109
        Width = 79
        Height = 13
        Caption = 'Код местности:'
        FocusControl = dbeCode
      end
      object Label6: TLabel
        Left = 8
        Top = 160
        Width = 68
        Height = 13
        Hint = 'Широта -90..+90, Долгота -180..+180'
        Caption = 'Координаты:'
        FocusControl = cbMaster
        ParentShowHint = False
        ShowHint = True
      end
      object cbMaster: TgsIBLookupComboBox
        Left = 129
        Top = 129
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
        Top = 104
        Width = 216
        Height = 21
        DataField = 'Code'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object edGEOCoord: TEdit
        Left = 129
        Top = 154
        Width = 216
        Height = 21
        Hint = 'Широта -90..+90, Долгота -180..+180'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
      end
      object btnShowMap: TButton
        Left = 128
        Top = 178
        Width = 121
        Height = 21
        Action = actShowMap
        TabOrder = 6
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
    object actShowMap: TAction
      Caption = 'Показать на карте'
      OnExecute = actShowMapExecute
    end
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
