object dlgQueryParam: TdlgQueryParam
  Left = 772
  Top = 285
  BorderStyle = bsDialog
  Caption = '¬ведите параметры'
  ClientHeight = 63
  ClientWidth = 396
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 34
    Width = 396
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object pnlRightButtons: TPanel
      Left = 195
      Top = 0
      Width = 201
      Height = 29
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOK: TButton
        Left = 39
        Top = 3
        Width = 75
        Height = 21
        Caption = 'OK'
        Default = True
        TabOrder = 0
        OnClick = btnOKClick
      end
      object btnCancel: TButton
        Left = 119
        Top = 3
        Width = 75
        Height = 21
        Cancel = True
        Caption = 'ќтмена'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 30
    Width = 396
    Height = 4
    Align = alClient
    BorderStyle = bsNone
    TabOrder = 1
  end
  object pnlName: TPanel
    Left = 0
    Top = 0
    Width = 396
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 2
    object lblFilterName: TLabel
      Left = 0
      Top = 13
      Width = 396
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'lblFilterName'
    end
    object lblFormName: TLabel
      Left = 0
      Top = 0
      Width = 396
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Label1'
    end
    object Bevel1: TBevel
      Left = 0
      Top = -20
      Width = 396
      Height = 50
      Align = alBottom
      Shape = bsBottomLine
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 120
    Top = 4
  end
end
