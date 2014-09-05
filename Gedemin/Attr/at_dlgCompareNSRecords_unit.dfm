object dlgCompareNSRecords: TdlgCompareNSRecords
  Left = 527
  Top = 308
  Width = 728
  Height = 494
  Caption = 'Конфликт изменения данных объекта'
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
  object pnlWorkArea: TPanel
    Left = 0
    Top = 0
    Width = 712
    Height = 456
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lCaption: TLabel
      Left = 16
      Top = 16
      Width = 3
      Height = 13
    end
    object pnlBottom: TPanel
      Left = 0
      Top = 425
      Width = 712
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object pnlRightBottom: TPanel
        Left = 445
        Top = 0
        Width = 267
        Height = 31
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnSave: TButton
          Left = 7
          Top = 3
          Width = 124
          Height = 21
          Action = actContinue
          Default = True
          TabOrder = 0
        end
        object btnCancel: TButton
          Left = 138
          Top = 3
          Width = 124
          Height = 21
          Action = actCancel
          Cancel = True
          TabOrder = 1
        end
      end
    end
    object pnlGrid: TPanel
      Left = 0
      Top = 102
      Width = 712
      Height = 323
      Align = alClient
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      OnResize = pnlGridResize
      object sgMain: TStringGrid
        Left = 5
        Top = 32
        Width = 702
        Height = 286
        Align = alClient
        BorderStyle = bsNone
        ColCount = 3
        DefaultRowHeight = 18
        DefaultDrawing = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goColSizing, goRowSelect]
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = sgMainDrawCell
        OnMouseDown = sgMainMouseDown
        RowHeights = (
          18
          18
          18
          18
          18)
      end
      object tbDock: TTBDock
        Left = 5
        Top = 5
        Width = 702
        Height = 27
        AllowDrag = False
        BoundLines = [blBottom]
        LimitToOneRow = True
        object tb: TTBToolbar
          Left = 0
          Top = 0
          Align = alTop
          CloseButton = False
          DockMode = dmCannotFloatOrChangeDocks
          FullSize = True
          Images = dmImages.il16x16
          MenuBar = True
          Options = [tboShowHint, tboToolbarStyle]
          ParentShowHint = False
          ProcessShortCuts = True
          ShowHint = True
          ShrinkMode = tbsmWrap
          TabOrder = 0
          object TBItem1: TTBItem
            Action = actSelect
          end
          object tbView: TTBItem
            Action = actView
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBControlItem1: TTBControlItem
            Control = chbxShowOnlyDiff
          end
          object chbxShowOnlyDiff: TCheckBox
            Left = 52
            Top = 2
            Width = 169
            Height = 17
            Action = actShowOnlyDiff
            TabOrder = 0
          end
        end
      end
    end
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 712
      Height = 102
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      object mObject: TMemo
        Left = 8
        Top = 8
        Width = 601
        Height = 29
        TabStop = False
        BorderStyle = bsNone
        Lines.Strings = (
          
            'Объект "%s" был изменен и в базе данных, и в файле. Выберите дал' +
            'ьнейшее действие.'
          ' ')
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
      object rbSkip: TRadioButton
        Left = 8
        Top = 44
        Width = 481
        Height = 17
        Caption = 
          'Не изменять объект в базе данных. Игнорировать изменения из файл' +
          'а.'
        TabOrder = 1
        OnClick = rbSkipClick
      end
      object rbOverwrite: TRadioButton
        Left = 8
        Top = 60
        Width = 393
        Height = 23
        Caption = 'Полностью перезаписать объект в базе данных данными из файла.'
        TabOrder = 2
        OnClick = rbOverwriteClick
      end
      object rbSelected: TRadioButton
        Left = 8
        Top = 82
        Width = 497
        Height = 17
        Caption = 'Обновить из файла только выбранные в списке ниже поля объекта:'
        TabOrder = 3
        OnClick = rbSelectedClick
      end
      object Panel1: TPanel
        Left = 617
        Top = 0
        Width = 95
        Height = 102
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 4
        object btnProperties: TButton
          Left = 8
          Top = 32
          Width = 79
          Height = 21
          Action = actProperties
          TabOrder = 0
        end
        object btnObject: TButton
          Left = 8
          Top = 8
          Width = 79
          Height = 21
          Action = actObject
          TabOrder = 1
        end
      end
    end
  end
  object actList: TActionList
    Images = dmImages.il16x16
    Left = 320
    Top = 184
    object actShowOnlyDiff: TAction
      Caption = 'Показывать только различия'
      OnExecute = ActShowOnlyDiffExecute
      OnUpdate = actShowOnlyDiffUpdate
    end
    object actContinue: TAction
      Caption = 'Продолжить'
      OnExecute = actContinueExecute
      OnUpdate = actContinueUpdate
    end
    object actView: TAction
      Caption = 'Просмотр...'
      Hint = 'Просмотреть значение поля'
      ImageIndex = 204
      ShortCut = 114
      OnExecute = actViewExecute
      OnUpdate = actViewUpdate
    end
    object actCancel: TAction
      Caption = 'Прервать загрузку'
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
    object actObject: TAction
      Caption = 'Объект'
      ImageIndex = 0
      OnExecute = actObjectExecute
      OnUpdate = actObjectUpdate
    end
    object actProperties: TAction
      Caption = 'Свойства'
      ImageIndex = 83
      OnExecute = actPropertiesExecute
      OnUpdate = actPropertiesUpdate
    end
    object actSelect: TAction
      Caption = 'Выбрать'
      Hint = 
        'Выбрать/снять выделение с поля для записи в базу данных (двойной' +
        ' щелчек)'
      ImageIndex = 29
      OnExecute = actSelectExecute
      OnUpdate = actSelectUpdate
    end
  end
end
