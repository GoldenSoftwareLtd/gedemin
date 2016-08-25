object frm_mcrMainForm: Tfrm_mcrMainForm
  Left = 186
  Top = 112
  Width = 742
  Height = 457
  Anchors = [akLeft, akBottom]
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 579
    Height = 430
    ActivePage = tsParams
    Align = alClient
    TabOrder = 0
    object tsParams: TTabSheet
      Caption = 'Параметры макроподстановки'
      object gdSearch: TGroupBox
        Left = 8
        Top = 8
        Width = 557
        Height = 121
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Поиск'
        TabOrder = 0
        object lbPath: TLabel
          Left = 6
          Top = 28
          Width = 24
          Height = 13
          Caption = 'Путь'
        end
        object lbMask: TLabel
          Left = 6
          Top = 60
          Width = 33
          Height = 13
          Caption = 'Маска'
        end
        object edPath: TEdit
          Left = 44
          Top = 20
          Width = 505
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edPathChange
          OnDblClick = edPathDblClick
        end
        object edMask: TEdit
          Left = 44
          Top = 52
          Width = 505
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
        end
        object cbRecursive: TCheckBox
          Left = 44
          Top = 88
          Width = 181
          Height = 17
          Caption = 'Сканировать c подкаталогами'
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = cbRecursiveClick
        end
      end
      object gbComment: TGroupBox
        Left = 8
        Top = 139
        Width = 557
        Height = 57
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Символы комментария'
        TabOrder = 1
        object lblBeginComment: TLabel
          Left = 6
          Top = 28
          Width = 37
          Height = 13
          Caption = 'Начало'
        end
        object Label1: TLabel
          Left = 110
          Top = 28
          Width = 55
          Height = 13
          Caption = 'Окончание'
        end
        object edBeginComment: TEdit
          Left = 54
          Top = 20
          Width = 41
          Height = 21
          TabOrder = 0
          OnChange = edBeginCommentChange
        end
        object edEndComment: TEdit
          Left = 174
          Top = 20
          Width = 41
          Height = 21
          TabOrder = 1
          OnChange = edEndCommentChange
        end
      end
      object gbDelete: TGroupBox
        Left = 8
        Top = 211
        Width = 557
        Height = 102
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Удаление вызова макроса'
        TabOrder = 2
        object lblDeleteName: TLabel
          Left = 8
          Top = 20
          Width = 69
          Height = 13
          Caption = 'Имя макроса'
        end
        object edDeleteMacro: TEdit
          Left = 294
          Top = 16
          Width = 251
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
        object lbDeleteMacros: TListBox
          Left = 88
          Top = 16
          Width = 193
          Height = 73
          ItemHeight = 13
          Sorted = True
          TabOrder = 1
        end
        object btnAddDelMacro: TButton
          Left = 304
          Top = 40
          Width = 75
          Height = 25
          Caption = 'Добавить'
          TabOrder = 2
          OnClick = btnAddDelMacroClick
        end
        object btnDelDelMacro: TButton
          Left = 392
          Top = 40
          Width = 75
          Height = 25
          Caption = 'Удалить'
          TabOrder = 3
          OnClick = btnDelDelMacroClick
        end
        object btnAddAllDelMacro: TButton
          Left = 304
          Top = 72
          Width = 163
          Height = 25
          Caption = 'Добавить все найденные'
          TabOrder = 4
          OnClick = btnAddAllDelMacroClick
        end
      end
      object cbBackup: TCheckBox
        Left = 8
        Top = 320
        Width = 209
        Height = 17
        Caption = 'Создавать резервные копии (*.mbk)'
        TabOrder = 3
      end
    end
    object tsSelect: TTabSheet
      Caption = 'Выбор макросов'
      ImageIndex = 3
      OnShow = btnRefreshClick
      object pnlSelect: TPanel
        Left = 8
        Top = 24
        Width = 489
        Height = 177
        BevelInner = bvSpace
        BevelOuter = bvLowered
        TabOrder = 0
        object lblAdd: TLabel
          Left = 8
          Top = 8
          Width = 77
          Height = 13
          Caption = 'Разворачивать'
        end
        object Label3: TLabel
          Left = 296
          Top = 8
          Width = 93
          Height = 13
          Caption = 'Не разворачивать'
        end
        object lbUnfold: TListBox
          Left = 8
          Top = 24
          Width = 185
          Height = 145
          ItemHeight = 13
          MultiSelect = True
          Sorted = True
          TabOrder = 0
        end
        object lbIgnore: TListBox
          Left = 296
          Top = 24
          Width = 185
          Height = 145
          ItemHeight = 13
          MultiSelect = True
          Sorted = True
          TabOrder = 1
        end
        object btnReturn: TBitBtn
          Left = 208
          Top = 96
          Width = 75
          Height = 25
          TabOrder = 2
          OnClick = btnReturnClick
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            04000000000000010000120B0000120B00001000000000000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            3333333333333333333333333333333333333333333333333333333333333333
            3333333333333FF3333333333333003333333333333F77F33333333333009033
            333333333F7737F333333333009990333333333F773337FFFFFF330099999000
            00003F773333377777770099999999999990773FF33333FFFFF7330099999000
            000033773FF33777777733330099903333333333773FF7F33333333333009033
            33333333337737F3333333333333003333333333333377333333333333333333
            3333333333333333333333333333333333333333333333333333333333333333
            3333333333333333333333333333333333333333333333333333}
          NumGlyphs = 2
        end
        object btnDelete: TBitBtn
          Left = 208
          Top = 64
          Width = 75
          Height = 25
          TabOrder = 3
          OnClick = btnDeleteClick
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            04000000000000010000120B0000120B00001000000000000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            3333333333333333333333333333333333333333333333333333333333333333
            3333333333333333333333333333333333333333333FF3333333333333003333
            3333333333773FF3333333333309003333333333337F773FF333333333099900
            33333FFFFF7F33773FF30000000999990033777777733333773F099999999999
            99007FFFFFFF33333F7700000009999900337777777F333F7733333333099900
            33333333337F3F77333333333309003333333333337F77333333333333003333
            3333333333773333333333333333333333333333333333333333333333333333
            3333333333333333333333333333333333333333333333333333}
          NumGlyphs = 2
        end
      end
      object btnRefresh: TButton
        Left = 216
        Top = 232
        Width = 75
        Height = 25
        Caption = 'Обновить'
        TabOrder = 1
        OnClick = btnRefreshClick
      end
    end
    object tsResult: TTabSheet
      Caption = 'Результат работы'
      ImageIndex = 1
      object plMemo: TPanel
        Left = 0
        Top = 0
        Width = 571
        Height = 402
        Align = alClient
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object lbResult: TListBox
          Left = 8
          Top = 8
          Width = 555
          Height = 386
          Anchors = [akLeft, akTop, akRight, akBottom]
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnMouseMove = lbResultMouseMove
        end
      end
    end
    object tsStatic: TTabSheet
      Caption = 'Текущая статистика'
      ImageIndex = 2
    end
  end
  object gbControl: TGroupBox
    Left = 579
    Top = 0
    Width = 155
    Height = 430
    Align = alRight
    Caption = 'Макро'
    TabOrder = 1
    object btSearch: TButton
      Left = 7
      Top = 46
      Width = 141
      Height = 25
      Anchors = [akLeft]
      Caption = 'Поиск объявлений'
      TabOrder = 0
      OnClick = btSearchClick
    end
    object btnMacrosReplace: TButton
      Left = 7
      Top = 197
      Width = 141
      Height = 25
      Anchors = [akLeft]
      Caption = 'Замена '
      TabOrder = 1
      OnClick = btnMacrosReplaceClick
    end
    object btnUnfoldRepl: TButton
      Left = 7
      Top = 147
      Width = 141
      Height = 25
      Anchors = [akLeft]
      Caption = 'Разворачивание и замена'
      TabOrder = 2
      OnClick = btnUnfoldReplClick
    end
    object btnDeleteMacro: TButton
      Left = 7
      Top = 301
      Width = 141
      Height = 25
      Anchors = [akLeft]
      Caption = 'Удалить вызов'
      TabOrder = 3
      OnClick = btnDeleteMacroClick
    end
    object btnSearchCall: TButton
      Left = 7
      Top = 98
      Width = 141
      Height = 25
      Anchors = [akLeft]
      Caption = 'Разворачивание'
      TabOrder = 4
      OnClick = btnSearchCallClick
    end
    object btnSearchUnfold: TButton
      Left = 7
      Top = 249
      Width = 141
      Height = 26
      Anchors = [akLeft]
      Caption = 'Сворачивание'
      TabOrder = 5
      OnClick = btnSearchUnfoldClick
    end
    object btnExit: TButton
      Left = 7
      Top = 370
      Width = 141
      Height = 25
      Anchors = [akLeft]
      Caption = 'Выход'
      TabOrder = 6
      OnClick = btnExitClick
    end
  end
end
