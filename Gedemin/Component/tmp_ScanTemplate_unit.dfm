object tmp_ScanTemplate: Ttmp_ScanTemplate
  Left = 263
  Top = 196
  Width = 507
  Height = 334
  Caption = 'Считывание документа по шаблону'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 499
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 13
      Width = 42
      Height = 13
      Caption = 'Шаблон:'
    end
    object Label3: TLabel
      Left = 8
      Top = 35
      Width = 54
      Height = 13
      Caption = 'Документ:'
    end
    object sbtnTemplate: TSpeedButton
      Left = 336
      Top = 8
      Width = 23
      Height = 21
      Caption = '...'
      OnClick = sbtnTemplateClick
    end
    object sbtnDocument: TSpeedButton
      Left = 336
      Top = 32
      Width = 23
      Height = 21
      Caption = '...'
      OnClick = sbtnDocumentClick
    end
    object edTemplate: TEdit
      Left = 72
      Top = 8
      Width = 265
      Height = 21
      TabOrder = 0
    end
    object edDocument: TEdit
      Left = 72
      Top = 32
      Width = 265
      Height = 21
      TabOrder = 1
    end
    object btnScan: TButton
      Left = 365
      Top = 32
      Width = 84
      Height = 21
      Action = actScanTemplate
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 56
    Width = 499
    Height = 251
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 13
      Width = 46
      Height = 13
      Caption = 'Область:'
    end
    object Label4: TLabel
      Left = 8
      Top = 105
      Width = 46
      Height = 13
      Caption = 'Таблица:'
    end
    object cbAreas: TComboBox
      Left = 72
      Top = 8
      Width = 265
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAreasChange
    end
    object dbgrAreaFields: TDBGrid
      Left = 1
      Top = 36
      Width = 497
      Height = 60
      Anchors = [akLeft, akTop, akRight]
      DataSource = dsFields
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object cbTables: TComboBox
      Left = 72
      Top = 100
      Width = 265
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbTablesChange
    end
    object dbgrTableFields: TDBGrid
      Left = 1
      Top = 125
      Width = 497
      Height = 124
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = dsRecords
      TabOrder = 3
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '*.*'
    Filter = 'Any files (*.*)|*.*'
    Left = 344
    Top = 72
  end
  object dsFields: TDataSource
    Left = 240
    Top = 96
  end
  object dsRecords: TDataSource
    Left = 272
    Top = 96
  end
  object alScanTemplate: TActionList
    Left = 440
    Top = 97
    object actScanTemplate: TAction
      Caption = 'Считать'
      OnExecute = actScanTemplateExecute
      OnUpdate = actScanTemplateUpdate
    end
  end
end
