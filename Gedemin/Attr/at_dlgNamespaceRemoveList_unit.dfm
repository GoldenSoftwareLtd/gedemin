object at_dlgNamespaceRemoveList: Tat_dlgNamespaceRemoveList
  Left = 548
  Top = 262
  BorderStyle = bsDialog
  Caption = 'Выбор объектов для удаления'
  ClientHeight = 374
  ClientWidth = 567
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
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 567
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 2
    object mInfo: TMemo
      Left = 4
      Top = 4
      Width = 559
      Height = 56
      TabStop = False
      Align = alClient
      BorderStyle = bsNone
      Lines.Strings = (
        
          'Ниже перечислены объекты, которые ранее входили в загружаемые пр' +
          'остранства имен, но позже были'
        
          'исключены из них. Отметьте объекты, которые следует удалить из б' +
          'азы данных.'
        ''
        
          'Возможно, объекты были перемещены в другие пространства имен, не' +
          ' участвующие в текущей загрузке.'
        ' '
        ' '
        ' ')
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 341
    Width = 567
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnDel: TButton
      Left = 405
      Top = 6
      Width = 75
      Height = 21
      Action = actDel
      Default = True
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 486
      Top = 6
      Width = 75
      Height = 21
      Action = actCancel
      Cancel = True
      TabOrder = 1
    end
  end
  object TBDock: TTBDock
    Left = 0
    Top = 64
    Width = 567
    Height = 25
    object TBToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar'
      DockMode = dmCannotFloatOrChangeDocks
      TabOrder = 0
      object tbiAll: TTBItem
        Action = actAll
      end
      object tbiNone: TTBItem
        Action = actNone
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object tbiObject: TTBItem
        Action = actObject
      end
    end
  end
  object List: TCheckListBox
    Left = 0
    Top = 89
    Width = 567
    Height = 252
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 0
  end
  object ActionList: TActionList
    Left = 416
    Top = 184
    object actAll: TAction
      Caption = 'Выделить все'
      OnExecute = actAllExecute
      OnUpdate = actAllUpdate
    end
    object actNone: TAction
      Caption = 'Ни одного'
      OnExecute = actNoneExecute
      OnUpdate = actNoneUpdate
    end
    object actObject: TAction
      Caption = 'Объект...'
      OnExecute = actObjectExecute
      OnUpdate = actObjectUpdate
    end
    object actDel: TAction
      Caption = 'Удалить'
      OnExecute = actDelExecute
      OnUpdate = actDelUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
end
