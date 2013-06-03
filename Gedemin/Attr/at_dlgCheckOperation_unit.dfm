object dlgCheckOperation: TdlgCheckOperation
  Left = 500
  Top = 224
  Width = 404
  Height = 210
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 388
    Height = 172
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 388
      Height = 65
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object lLoadRecords: TLabel
        Left = 8
        Top = 8
        Width = 369
        Height = 17
        AutoSize = False
      end
      object cbAlwaysOverwrite: TCheckBox
        Left = 8
        Top = 33
        Width = 161
        Height = 17
        Caption = 'Всегда перезаписывать'
        TabOrder = 0
      end
      object cbDontRemove: TCheckBox
        Left = 168
        Top = 33
        Width = 145
        Height = 17
        Caption = 'Не удалять объекты'
        TabOrder = 1
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 65
      Width = 388
      Height = 56
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object lSaveRecords: TLabel
        Left = 8
        Top = 8
        Width = 369
        Height = 17
        AutoSize = False
      end
      object cbIncVersion: TCheckBox
        Left = 8
        Top = 34
        Width = 169
        Height = 17
        Caption = 'Увеличить номер версии'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
    end
    object btnOK: TButton
      Left = 216
      Top = 134
      Width = 75
      Height = 25
      Caption = 'ОК'
      ModalResult = 1
      TabOrder = 2
    end
    object btnCancel: TButton
      Left = 304
      Top = 134
      Width = 75
      Height = 25
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 3
    end
  end
end
