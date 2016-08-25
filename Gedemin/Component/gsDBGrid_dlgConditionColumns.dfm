object dlgConditionColumns: TdlgConditionColumns
  Left = 229
  Top = 176
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выберите колонки'
  ClientHeight = 283
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 246
    Width = 268
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Panel3: TPanel
      Left = 80
      Top = 0
      Width = 188
      Height = 37
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnCancel: TButton
        Left = 106
        Top = 7
        Width = 75
        Height = 24
        Cancel = True
        Caption = 'Отменить'
        ModalResult = 2
        TabOrder = 1
      end
      object btnOk: TButton
        Left = 17
        Top = 7
        Width = 75
        Height = 24
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 268
    Height = 246
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 6
      Top = 6
      Width = 256
      Height = 234
      Align = alClient
      Caption = ' Список колонок: '
      TabOrder = 0
      object clbFields: TCheckListBox
        Left = 15
        Top = 21
        Width = 226
        Height = 180
        OnClickCheck = clbFieldsClickCheck
        ItemHeight = 13
        TabOrder = 0
      end
      object cbAll: TCheckBox
        Left = 13
        Top = 206
        Width = 228
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Выбрать все колонки'
        TabOrder = 1
        OnClick = cbAllClick
      end
    end
  end
end
