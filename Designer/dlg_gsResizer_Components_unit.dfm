object dlg_gsResizer_Components: Tdlg_gsResizer_Components
  Left = 577
  Top = 196
  Width = 278
  Height = 375
  BorderStyle = bsSizeToolWin
  BorderWidth = 3
  Caption = 'Компоненты'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 256
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lbl1: TLabel
      Left = 0
      Top = 1
      Width = 85
      Height = 13
      Caption = 'Поиск по имени:'
    end
    object edName: TEdit
      Left = 0
      Top = 16
      Width = 256
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edNameChange
      OnKeyPress = edNameKeyPress
    end
  end
  object lbComponents: TListBox
    Left = 0
    Top = 41
    Width = 256
    Height = 264
    Align = alClient
    ItemHeight = 13
    Sorted = True
    TabOrder = 1
    OnDblClick = lbComponentsDblClick
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 305
    Width = 256
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object pnlBottomRight: TPanel
      Left = 64
      Top = 0
      Width = 192
      Height = 26
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnAdd: TButton
        Left = 29
        Top = 4
        Width = 85
        Height = 21
        Anchors = [akTop, akRight]
        Caption = 'Добавить'
        Default = True
        ModalResult = 1
        TabOrder = 0
        OnClick = btnAddClick
      end
      object btnClose: TButton
        Left = 120
        Top = 4
        Width = 72
        Height = 21
        Anchors = [akTop, akRight]
        Cancel = True
        Caption = 'Закрыть'
        ModalResult = 2
        TabOrder = 1
        OnClick = btnCloseClick
      end
    end
  end
end
