object at_dlgNamespaceDeleteDependencies: Tat_dlgNamespaceDeleteDependencies
  Left = 398
  Top = 339
  Width = 655
  Height = 334
  Caption = 'Удаление объекта из пространства имен'
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
    Width = 639
    Height = 79
    Align = alTop
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 0
    object Label1: TLabel
      Left = 14
      Top = 11
      Width = 498
      Height = 13
      Caption = 
        'Ниже приведен список объектов, которые зависят от удаляемого объ' +
        'екта. Выберите действие:'
    end
    object rbDeleteAll: TRadioButton
      Left = 32
      Top = 32
      Width = 337
      Height = 17
      Caption = 'Удалить из пространства имен объект и все зависимые'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbDeleteOne: TRadioButton
      Left = 32
      Top = 53
      Width = 473
      Height = 17
      Caption = 
        'Удалить из пространства имен только выбранный объект. Сохранить ' +
        'все зависимые'
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 264
    Width = 639
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel4: TPanel
      Left = 459
      Top = 0
      Width = 180
      Height = 31
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 16
        Top = 3
        Width = 75
        Height = 21
        Caption = 'Ok'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object Button2: TButton
        Left = 96
        Top = 3
        Width = 75
        Height = 21
        Cancel = True
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 79
    Width = 639
    Height = 185
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object mObjects: TMemo
      Left = 4
      Top = 4
      Width = 631
      Height = 177
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
end
