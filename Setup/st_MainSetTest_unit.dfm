object MainForm: TMainForm
  Left = 257
  Top = 235
  Width = 672
  Height = 445
  Caption = 'Список настроек для комплекса Gedemin'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 576
    Top = 0
    Width = 88
    Height = 412
    Align = alRight
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Добавить'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 8
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Изменить'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 8
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Удалить'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 576
    Height = 412
    Align = alClient
    Columns = <
      item
        Caption = 'RUID'
        Width = 150
      end
      item
        Caption = 'Наименование'
        Width = 400
      end>
    HideSelection = False
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnResize = ListView1Resize
  end
end
