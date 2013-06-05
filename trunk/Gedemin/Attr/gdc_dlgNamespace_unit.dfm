inherited gdc_dlgNamespace: Tgdc_dlgNamespace
  Left = 431
  Top = 220
  Caption = 'gdc_dlgNamespace'
  ClientHeight = 399
  ClientWidth = 559
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 370
  end
  inherited btnNew: TButton
    Top = 370
  end
  inherited btnHelp: TButton
    Top = 370
  end
  inherited btnOK: TButton
    Left = 412
    Top = 370
  end
  inherited btnCancel: TButton
    Left = 484
    Top = 370
  end
  inherited pgcMain: TPageControl
    Width = 549
    Height = 355
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 5
      end
      object Label1: TLabel
        Left = 5
        Top = 29
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object Label2: TLabel
        Left = 5
        Top = 72
        Width = 126
        Height = 13
        Caption = 'Текст для отображения:'
      end
      object Label3: TLabel
        Left = 5
        Top = 114
        Width = 58
        Height = 13
        Caption = 'Имя файла:'
      end
      object Label4: TLabel
        Left = 5
        Top = 163
        Width = 86
        Height = 13
        Caption = 'Дата изменения:'
      end
      object Label5: TLabel
        Left = 207
        Top = 163
        Width = 39
        Height = 13
        Caption = 'Версия:'
      end
      object Label6: TLabel
        Left = 364
        Top = 163
        Width = 56
        Height = 13
        Caption = 'Версия БД:'
      end
      object Label7: TLabel
        Left = 5
        Top = 208
        Width = 71
        Height = 13
        Caption = 'Комментарий:'
      end
      object dbedName: TDBEdit
        Left = 5
        Top = 47
        Width = 529
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbedCaption: TDBEdit
        Left = 4
        Top = 90
        Width = 529
        Height = 21
        DataField = 'CAPTION'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbedFileName: TDBEdit
        Left = 4
        Top = 132
        Width = 529
        Height = 21
        Color = clBtnFace
        DataField = 'FILENAME'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 2
      end
      object dbedFileTimestamp: TDBEdit
        Left = 94
        Top = 160
        Width = 108
        Height = 21
        Color = clBtnFace
        DataField = 'FILETIMESTAMP'
        DataSource = dsgdcBase
        ReadOnly = True
        TabOrder = 3
      end
      object dbedVersion: TDBEdit
        Left = 250
        Top = 160
        Width = 108
        Height = 21
        DataField = 'VERSION'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object dbedDBVersion: TDBEdit
        Left = 425
        Top = 160
        Width = 108
        Height = 21
        DataField = 'DBVERSION'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object dbchbxOptional: TDBCheckBox
        Left = 5
        Top = 186
        Width = 249
        Height = 17
        Caption = 'Опциональное пространство имен'
        DataField = 'OPTIONAL'
        DataSource = dsgdcBase
        TabOrder = 6
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbchbxInternal: TDBCheckBox
        Left = 250
        Top = 186
        Width = 187
        Height = 17
        Caption = 'Внутреннее пространство имен'
        DataField = 'INTERNAL'
        DataSource = dsgdcBase
        TabOrder = 7
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbmComment: TDBMemo
        Left = 5
        Top = 224
        Width = 527
        Height = 97
        ScrollBars = ssVertical
        TabOrder = 8
      end
    end
  end
  inherited alBase: TActionList
    Top = 151
  end
  inherited dsgdcBase: TDataSource
    Top = 151
  end
  inherited pm_dlgG: TPopupMenu
    Top = 152
  end
  inherited ibtrCommon: TIBTransaction
    Top = 152
  end
end
