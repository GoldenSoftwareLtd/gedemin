object dlg_gsResizer_Components: Tdlg_gsResizer_Components
  Left = 701
  Top = 252
  BorderStyle = bsDialog
  Caption = 'Компоненты'
  ClientHeight = 371
  ClientWidth = 266
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
    Width = 266
    Height = 371
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlSearch: TPanel
      Left = 0
      Top = 0
      Width = 266
      Height = 46
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 5
      TabOrder = 0
      object lblName: TLabel
        Left = 5
        Top = 5
        Width = 256
        Height = 13
        Align = alTop
        Caption = 'Поиск по имени:'
      end
      object edName: TEdit
        Left = 5
        Top = 24
        Width = 256
        Height = 21
        TabOrder = 0
        OnChange = edNameChange
        OnKeyPress = edNameKeyPress
      end
    end
    object pnlComponents: TPanel
      Left = 0
      Top = 46
      Width = 266
      Height = 297
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 5
      TabOrder = 1
      object lbComponents: TListBox
        Left = 5
        Top = 5
        Width = 256
        Height = 287
        Align = alClient
        ItemHeight = 13
        Sorted = True
        TabOrder = 0
        OnDblClick = lbComponentsDblClick
      end
    end
    object pnlBottom: TPanel
      Left = 0
      Top = 343
      Width = 266
      Height = 28
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object btnAdd: TButton
        Left = 96
        Top = 2
        Width = 75
        Height = 21
        Anchors = [akBottom]
        Caption = 'Добавить'
        Default = True
        TabOrder = 0
        OnClick = btnAddClick
      end
      object btnCancel: TButton
        Left = 218
        Top = 2
        Width = 0
        Height = 21
        Anchors = [akBottom]
        Cancel = True
        Caption = 'Закрыть'
        TabOrder = 1
        OnClick = btnCancelClick
      end
    end
  end
end
