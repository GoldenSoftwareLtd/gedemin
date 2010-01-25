inherited gdc_dlgConstValue: Tgdc_dlgConstValue
  Left = 401
  Top = 263
  HelpContext = 130
  Caption = 'Значение константы'
  ClientHeight = 230
  ClientWidth = 417
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 335
    Top = 58
    Width = 76
    Visible = False
  end
  inherited btnNew: TButton
    Left = 335
    Top = 83
    Width = 76
  end
  inherited btnOK: TButton
    Left = 335
    Top = 8
    Width = 76
  end
  inherited btnCancel: TButton
    Left = 335
    Top = 33
    Width = 76
  end
  inherited btnHelp: TButton
    Left = 335
    Top = 108
    Width = 76
  end
  inherited pgcMain: TPageControl
    Left = 7
    Width = 317
    Height = 219
    inherited tbsMain: TTabSheet
      object Label2: TLabel
        Left = 8
        Top = 63
        Width = 45
        Height = 13
        Caption = 'На дату:'
      end
      object Label1: TLabel
        Left = 8
        Top = 90
        Width = 52
        Height = 13
        Caption = 'Значение:'
      end
      object Label4: TLabel
        Left = 8
        Top = 35
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object DBText1: TDBText
        Left = 90
        Top = 35
        Width = 41
        Height = 13
        AutoSize = True
        DataField = 'constname'
        DataSource = dsgdcBase
        Transparent = True
      end
      object xdbConstDate: TxDateDBEdit
        Left = 90
        Top = 57
        Width = 66
        Height = 21
        DataField = 'CONSTDATE'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 0
      end
      object dbeValue: TDBEdit
        Left = 90
        Top = 86
        Width = 215
        Height = 21
        DataField = 'CONSTVALUE'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object Memo1: TMemo
        Left = 5
        Top = 122
        Width = 296
        Height = 67
        TabStop = False
        BorderStyle = bsNone
        Color = clBtnFace
        Lines.Strings = (
          'При вводе значений типа дата используйте формат: '
          'дд.мм.гггг'
          ''
          'При вводе числовых значений используйте точку в '
          'качестве разделителя целой и дробной части.')
        ReadOnly = True
        TabOrder = 2
      end
    end
  end
  inherited alBase: TActionList
    Left = 365
    Top = 167
  end
  inherited dsgdcBase: TDataSource
    Left = 367
    Top = 143
  end
  inherited pm_dlgG: TPopupMenu
    Left = 328
    Top = 144
  end
  inherited ibtrCommon: TIBTransaction
    Left = 344
    Top = 168
  end
end
