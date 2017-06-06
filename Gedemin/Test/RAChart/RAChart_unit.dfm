object Form1: TForm1
  Left = 206
  Top = 191
  Width = 824
  Height = 661
  Caption = 'e'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 96
    Width = 808
    Height = 526
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object rachart: TgsRAChart
      Left = 5
      Top = 5
      Width = 798
      Height = 516
      Align = alClient
      TabStop = True
      PopupMenu = pm
      OnClick = rachartClick
      OnDblClick = rachartDblClick
      OnDragDrop = rachartDragDrop
      OnChange = rachartChange
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 808
    Height = 96
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblNotify: TLabel
      Left = 360
      Top = 8
      Width = 37
      Height = 13
      Caption = 'lblNotify'
    end
    object lblClick: TLabel
      Left = 360
      Top = 24
      Width = 33
      Height = 13
      Caption = 'lblClick'
    end
    object Label1: TLabel
      Left = 104
      Top = 43
      Width = 18
      Height = 13
      Caption = 'CW'
    end
    object Label2: TLabel
      Left = 184
      Top = 43
      Width = 15
      Height = 13
      Caption = 'CH'
    end
    object lblDblClick: TLabel
      Left = 360
      Top = 40
      Width = 49
      Height = 13
      Caption = 'lblDblClick'
    end
    object lblDragDrop: TLabel
      Left = 360
      Top = 56
      Width = 56
      Height = 13
      Caption = 'lblDragDrop'
    end
    object Button1: TButton
      Left = 16
      Top = 8
      Width = 75
      Height = 25
      Caption = 'NOP'
      TabOrder = 0
    end
    object gspe: TgsPeriodEdit
      Left = 104
      Top = 8
      Width = 193
      Height = 21
      TabOrder = 1
      OnChange = gspeChange
    end
    object spCellWidth: TxSpinEdit
      Left = 128
      Top = 40
      Width = 41
      Height = 21
      Increment = 1
      DecDigits = 0
      SpinCursor = 17555
      TabOrder = 2
      OnChange = spCellWidthChange
    end
    object spRowHeight: TxSpinEdit
      Left = 204
      Top = 40
      Width = 41
      Height = 21
      Increment = 1
      DecDigits = 0
      SpinCursor = 17555
      TabOrder = 3
      OnChange = spRowHeightChange
    end
    object rbDays: TRadioButton
      Left = 104
      Top = 72
      Width = 49
      Height = 17
      Caption = 'ƒни'
      Checked = True
      TabOrder = 4
      TabStop = True
      OnClick = rbDaysClick
    end
    object rbMonthes: TRadioButton
      Left = 160
      Top = 72
      Width = 73
      Height = 17
      Caption = 'ћес€цы'
      TabOrder = 5
      OnClick = rbMonthesClick
    end
  end
  object pm: TPopupMenu
    Left = 232
    Top = 145
    object actAction1: TMenuItem
      Action = actAction
    end
  end
  object ActionList1: TActionList
    Left = 888
    Top = 16
    object actAction: TAction
      Caption = 'actAction'
    end
  end
end
