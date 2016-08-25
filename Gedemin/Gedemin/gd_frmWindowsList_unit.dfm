object gd_frmWindowsList: Tgd_frmWindowsList
  Left = 366
  Top = 262
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Список окон'
  ClientHeight = 262
  ClientWidth = 452
  Color = clBtnFace
  Constraints.MinHeight = 180
  Constraints.MinWidth = 360
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 67
    Height = 13
    Caption = 'Спис&ок окон:'
    FocusControl = lb
  end
  object lb: TListBox
    Left = 8
    Top = 24
    Width = 436
    Height = 183
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 300
    Top = 230
    Width = 69
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Перейти'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnClose: TButton
    Left = 374
    Top = 230
    Width = 69
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Закрыть'
    ModalResult = 2
    TabOrder = 4
    OnClick = btnCloseClick
  end
  object btnHelp: TButton
    Left = 4
    Top = 230
    Width = 69
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Справка'
    TabOrder = 5
  end
  object btnRefresh: TButton
    Left = 78
    Top = 230
    Width = 69
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'О&бновить'
    TabOrder = 6
    OnClick = btnRefreshClick
  end
  object chbxHidden: TCheckBox
    Left = 8
    Top = 210
    Width = 153
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Показать скрытые окна'
    TabOrder = 1
    OnClick = chbxHiddenClick
  end
  object chbxName: TCheckBox
    Left = 168
    Top = 210
    Width = 169
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Показать имя и класс окна'
    TabOrder = 2
    OnClick = chbxHiddenClick
  end
  object btnShow: TButton
    Left = 152
    Top = 230
    Width = 69
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Показа&ть'
    TabOrder = 7
    OnClick = btnShowClick
  end
  object btnHide: TButton
    Left = 226
    Top = 230
    Width = 69
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'С&крыть'
    TabOrder = 8
    OnClick = btnHideClick
  end
end
