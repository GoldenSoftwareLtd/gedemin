inherited gdc_dlgStorageValue: Tgdc_dlgStorageValue
  Left = 643
  Top = 247
  Caption = 'Значение хранилища'
  ClientHeight = 255
  ClientWidth = 375
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 230
  end
  inherited btnNew: TButton
    Top = 230
  end
  inherited btnHelp: TButton
    Top = 230
  end
  inherited btnOK: TButton
    Left = 229
    Top = 230
  end
  inherited btnCancel: TButton
    Left = 302
    Top = 230
  end
  inherited pgcMain: TPageControl
    Width = 366
    Height = 219
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 8
        Top = 30
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object dbedName: TDBEdit
        Left = 96
        Top = 27
        Width = 256
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object pnlValue: TPanel
        Left = 2
        Top = 53
        Width = 359
        Height = 134
        BevelOuter = bvNone
        TabOrder = 1
        object Label2: TLabel
          Left = 6
          Top = 45
          Width = 64
          Height = 13
          Caption = 'Тип данных:'
        end
        object Label3: TLabel
          Left = 6
          Top = 114
          Width = 52
          Height = 13
          Caption = 'Значение:'
        end
        object Label4: TLabel
          Left = 6
          Top = 22
          Width = 66
          Height = 13
          Caption = 'Размещение:'
        end
        object Label5: TLabel
          Left = 6
          Top = 0
          Width = 61
          Height = 13
          Caption = 'Хранилище:'
        end
        object dbrgType: TDBRadioGroup
          Left = 94
          Top = 38
          Width = 257
          Height = 65
          Columns = 2
          DataField = 'DATA_TYPE'
          DataSource = dsgdcBase
          Items.Strings = (
            'Строка'
            'Целое число'
            'Дробное число'
            'Булевский тип'
            'Дата и время'
            'Двоичные данные')
          TabOrder = 0
          Values.Strings = (
            'S'
            'I'
            'C'
            'L'
            'D'
            'B')
        end
        object dbedValue: TDBEdit
          Left = 94
          Top = 110
          Width = 257
          Height = 21
          DataSource = dsgdcBase
          TabOrder = 1
        end
        object btnEdBLOB: TButton
          Left = 94
          Top = 110
          Width = 113
          Height = 21
          Action = actEditBLOB
          TabOrder = 2
        end
        object edPath: TEdit
          Left = 95
          Top = 22
          Width = 255
          Height = 21
          TabStop = False
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
          Text = 'edPath'
        end
        object edStorage: TEdit
          Left = 95
          Top = 0
          Width = 255
          Height = 21
          TabStop = False
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 4
          Text = 'edStorage'
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 310
    Top = 7
    object actEditBLOB: TAction
      Caption = 'Редактировать...'
      OnExecute = actEditBLOBExecute
      OnUpdate = actEditBLOBUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    OnDataChange = dsgdcBaseDataChange
    Left = 280
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 280
    Top = 40
  end
  inherited ibtrCommon: TIBTransaction
    Left = 312
    Top = 40
  end
end
