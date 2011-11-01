object BaseFrame: TBaseFrame
  Left = 0
  Top = 0
  Width = 443
  Height = 270
  Align = alClient
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentColor = False
  ParentFont = False
  PopupMenu = PopupMenu
  TabOrder = 0
  object PageControl: TSuperPageControl
    Left = 0
    Top = 0
    Width = 443
    Height = 270
    BorderStyle = bsNone
    TabsVisible = True
    ActivePage = tsProperty
    Align = alClient
    Style = tsFlatButtons
    TabHeight = 23
    TabOrder = 0
    object tsProperty: TSuperTabSheet
      BorderWidth = 2
      Caption = 'Свойства'
      object TBDock1: TTBDock
        Left = 0
        Top = 0
        Width = 439
        Height = 9
        BoundLines = [blTop, blBottom, blLeft, blRight]
      end
      object pMain: TPanel
        Left = 0
        Top = 9
        Width = 439
        Height = 234
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lbName: TLabel
          Left = 8
          Top = 12
          Width = 124
          Height = 13
          Caption = 'Наименование функции:'
        end
        object lbDescription: TLabel
          Left = 8
          Top = 32
          Width = 71
          Height = 13
          Caption = 'Комментарий:'
        end
        object dbeName: TprpDBComboBox
          Left = 144
          Top = 8
          Width = 293
          Height = 21
          Hint = 
            'Используйте клавиши: '#13#10'  F1 -- вызов справки '#13#10'  F2 -- создание ' +
            'нового объекта '#13#10'  F8 -- удаление выбранного объекта '
          Style = csSimple
          Anchors = [akLeft, akTop, akRight]
          DataField = 'NAME'
          DataSource = DataSource
          ItemHeight = 13
          ParentShowHint = False
          PopupMenu = PopupMenu
          ShowHint = False
          TabOrder = 0
          OnChange = dbeNameChange
          OnDropDown = dbeNameDropDown
        end
        object dbmDescription: TDBMemo
          Left = 144
          Top = 32
          Width = 293
          Height = 69
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          DataField = 'COMMENT'
          DataSource = DataSource
          ParentCtl3D = False
          PopupMenu = PopupMenu
          TabOrder = 1
          OnChange = dbeFunctionNameChange
        end
      end
    end
  end
  object DataSource: TDataSource
    Left = 40
    Top = 83
  end
  object PopupMenu: TPopupMenu
    HelpContext = 317
    MenuAnimation = [maLeftToRight, maRightToLeft, maTopToBottom, maBottomToTop]
    Left = 72
    Top = 80
    object miClose: TMenuItem
      Action = actClosePage
    end
    object miS1: TMenuItem
      Caption = '-'
    end
    object miAddToSetting: TMenuItem
      Action = actAddToSetting
    end
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 72
    Top = 109
    object actClosePage: TAction
      Caption = 'Закрыть страницу'
      OnExecute = actClosePageExecute
    end
    object actAddToSetting: TAction
      Caption = 'Добавить в настройку ...'
      ImageIndex = 81
      OnExecute = actAddToSettingExecute
      OnUpdate = actAddToSettingUpdate
    end
    object actCopyIdToClipBoard: TAction
      Caption = 'Скопировать'
    end
    object actEditCopy: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy'
      ImageIndex = 10
      ShortCut = 16451
    end
    object actEditCut: TEditCut
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut'
      ImageIndex = 9
      ShortCut = 16472
    end
    object actEditDelete: TEditDelete
      Category = 'Edit'
      Caption = '&Delete'
      ImageIndex = 117
    end
    object actEditPaste: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste'
      ImageIndex = 11
      ShortCut = 16470
    end
    object actEditSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select &All'
    end
    object actEditUndo: TEditUndo
      Category = 'Edit'
      Caption = '&Undo'
      ImageIndex = 19
      ShortCut = 32776
    end
    object actProperty: TAction
      Caption = 'Свойства'
      Hint = 'Дополнительные свойства'
      ImageIndex = 78
      OnExecute = actPropertyExecute
      OnUpdate = actPropertyUpdate
    end
  end
end
