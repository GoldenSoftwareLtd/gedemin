inherited frmClassesInspector: TfrmClassesInspector
  Left = 408
  Top = 87
  Width = 294
  Height = 608
  Caption = 'frmClassesInspector'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited pCaption: TPanel
    Width = 286
  end
  object sbCurrentNode: TStatusBar [1]
    Left = 0
    Top = 562
    Width = 286
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object pcMain: TPageControl [2]
    Left = 0
    Top = 18
    Width = 286
    Height = 544
    ActivePage = tsClasses
    Align = alClient
    TabOrder = 1
    object tsClasses: TTabSheet
      Caption = 'Классы'
      object Splitter1: TSplitter
        Left = 0
        Top = 470
        Width = 278
        Height = 2
        Cursor = crVSplit
        Align = alBottom
      end
      object TBDock1: TTBDock
        Left = 0
        Top = 0
        Width = 278
        Height = 25
        object TBToolbar2: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'TBToolbar1'
          TabOrder = 0
          object TBControlItem2: TTBControlItem
            Control = cbClasses
          end
          object cbClasses: TComboBox
            Left = 0
            Top = 0
            Width = 145
            Height = 21
            ItemHeight = 13
            TabOrder = 0
            Text = 'cbClasses'
          end
        end
      end
      object mmDescription: TMemo
        Left = 0
        Top = 472
        Width = 278
        Height = 44
        Align = alBottom
        Lines.Strings = (
          '')
        TabOrder = 1
      end
    end
    object tsSearch: TTabSheet
      Caption = 'Поиск'
      ImageIndex = 1
      OnShow = tsSearchShow
      object pnlSearch: TPanel
        Left = 0
        Top = 0
        Width = 278
        Height = 516
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object Label1: TLabel
          Left = 8
          Top = 16
          Width = 91
          Height = 13
          Caption = '1. Искомое слово:'
        end
        object Label2: TLabel
          Left = 8
          Top = 88
          Width = 101
          Height = 13
          Caption = '2. Наденные слова:'
        end
        object Label3: TLabel
          Left = 8
          Top = 200
          Width = 54
          Height = 13
          Caption = '2. Классы:'
        end
        object Label4: TLabel
          Left = 20
          Top = 216
          Width = 186
          Height = 13
          Caption = 'Выберите класс и нажмите перейти.'
        end
        object edtSearch: TEdit
          Left = 8
          Top = 32
          Width = 177
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
        object Button1: TButton
          Left = 192
          Top = 32
          Width = 78
          Height = 22
          Action = actSearch
          Anchors = [akTop, akRight]
          TabOrder = 1
        end
        object CheckBox1: TCheckBox
          Left = 8
          Top = 56
          Width = 145
          Height = 17
          Caption = 'Полное совпадение'
          TabOrder = 2
        end
        object lbClasses: TListBox
          Left = 8
          Top = 232
          Width = 261
          Height = 276
          Anchors = [akLeft, akTop, akRight, akBottom]
          ItemHeight = 13
          Sorted = True
          TabOrder = 3
        end
        object Button2: TButton
          Left = 192
          Top = 64
          Width = 78
          Height = 21
          Anchors = [akTop, akRight]
          Caption = 'Перейти'
          TabOrder = 4
        end
        object lbWords: TListBox
          Left = 8
          Top = 104
          Width = 260
          Height = 89
          ItemHeight = 16
          Style = lbOwnerDrawFixed
          TabOrder = 5
          OnDblClick = lbWordsDblClick
          OnDrawItem = lbWordsDrawItem
        end
      end
    end
  end
  object alMain1: TActionList
    Left = 80
    Top = 192
    object actInsertCurrentItem: TAction
      Caption = 'Вставить в текст'
      OnExecute = actInsertCurrentItemExecute
    end
    object actCollapse: TAction
      Caption = 'Свернуть дерево'
      OnExecute = actCollapseExecute
    end
    object actExpand: TAction
      Caption = 'Развернуть дерево'
      OnExecute = actExpandExecute
    end
    object actSearch: TAction
      Caption = 'Поиск'
      OnExecute = actSearchExecute
    end
  end
  object pmMain1: TPopupMenu
    Left = 40
    Top = 192
    object N3: TMenuItem
      Action = actInsertCurrentItem
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Action = actExpand
    end
    object N5: TMenuItem
      Action = actCollapse
    end
  end
end
