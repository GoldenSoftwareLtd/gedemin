object dlgColFormat: TdlgColFormat
  Left = 282
  Top = 271
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Формат отображения данных'
  ClientHeight = 259
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 222
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 0
    object Bevel1: TBevel
      Left = 6
      Top = 6
      Width = 388
      Height = 210
      Align = alClient
    end
    object Label1: TLabel
      Left = 20
      Top = 15
      Width = 93
      Height = 13
      Caption = 'Список форматов:'
    end
    object sgFormat: TStringGrid
      Left = 20
      Top = 31
      Width = 361
      Height = 170
      ColCount = 2
      Ctl3D = True
      DefaultColWidth = 170
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 8
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goDrawFocusSelected, goRowSelect, goThumbTracking]
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 222
    Width = 400
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel3: TPanel
      Left = 132
      Top = 0
      Width = 268
      Height = 37
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnCancel: TButton
        Left = 99
        Top = 7
        Width = 75
        Height = 24
        Cancel = True
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
      object btnOk: TButton
        Left = 10
        Top = 7
        Width = 75
        Height = 24
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object btnHelp: TButton
        Left = 187
        Top = 7
        Width = 75
        Height = 24
        Caption = 'Помощь'
        TabOrder = 2
      end
    end
  end
end
