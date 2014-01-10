object dlgCompareNSRecords: TdlgCompareNSRecords
  Left = 595
  Top = 395
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
        Left = 188
        Top = 0
        Width = 524
        Height = 31
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object btnSave: TButton
          Left = 17
          Top = 3
          Width = 164
          Height = 21
          Action = actSave
          Default = True
          TabOrder = 0
        end
        object btnSkip: TButton
          Left = 186
          Top = 3
          Width = 164
          Height = 21
          Action = actSkip
          Default = True
          TabOrder = 1
        end
        object btnCancel: TButton
          Left = 355
          Top = 3
          Width = 164
          Height = 21
          Action = actCancel
          Cancel = True
          Default = True
          TabOrder = 2
        end
      end
      object chbxShowOnlyDiff: TCheckBox
        Left = 4
        Top = 4
        Width = 169
        Height = 17
        Action = actShowOnlyDiff
        TabOrder = 0
      end
    end
    object pnlGrid: TPanel
      Left = 0
      Top = 91
      Width = 712
      Height = 334
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      OnResize = pnlGridResize
      object sgMain: TStringGrid
        Left = 4
        Top = 4
        Width = 704
        Height = 326
        Align = alClient
        ColCount = 3
        DefaultRowHeight = 18
        DefaultDrawing = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goColSizing]
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
    end
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 712
      Height = 91
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      object lTitle: TLabel
        Left = 8
        Top = 64
        Width = 617
        Height = 27
        AutoSize = False
        Caption = 
          'Выделенные жирным шрифтом значения будут записаны в базу данных.' +
          ' Используйте двойной щелчек мыши для просмотра и одинарный -- дл' +
          'я выделения.'
        WordWrap = True
      end
      object lObjClass: TLabel
        Left = 8
        Top = 7
        Width = 68
        Height = 13
        Caption = 'Тип объекта:'
      end
      object lObjName: TLabel
        Left = 8
        Top = 25
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object lObjID: TLabel
        Left = 8
        Top = 43
        Width = 32
        Height = 13
        Caption = 'РУИД:'
      end
      object lblID: TLabel
        Left = 93
        Top = 43
        Width = 21
        Height = 13
        Caption = 'lblID'
      end
      object lblName: TLabel
        Left = 93
        Top = 25
        Width = 37
        Height = 13
        Caption = 'lblName'
      end
      object lblClassName: TLabel
        Left = 93
        Top = 7
        Width = 62
        Height = 13
        Caption = 'lblClassName'
      end
    end
  end
  object actList: TActionList
    Left = 320
    Top = 184
    object actShowOnlyDiff: TAction
      Caption = 'Показывать только различия'
      OnExecute = ActShowOnlyDiffExecute
      OnUpdate = actShowOnlyDiffUpdate
    end
    object actSave: TAction
      Caption = 'Записать изменения'
      OnExecute = actSaveExecute
      OnUpdate = actSaveUpdate
    end
    object actView: TAction
      Caption = 'Просмотр...'
      ShortCut = 114
      OnExecute = actViewExecute
      OnUpdate = actViewUpdate
    end
    object actSkip: TAction
      Caption = 'Сохранить исходную запись'
      OnExecute = actSkipExecute
    end
    object actCancel: TAction
      Caption = 'Прервать загрузку'
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
  end
end
