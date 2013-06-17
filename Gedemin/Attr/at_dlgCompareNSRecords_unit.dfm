object dlgCompareNSRecords: TdlgCompareNSRecords
  Left = 541
  Top = 213
  Width = 648
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlWorkArea: TPanel
    Left = 0
    Top = 0
    Width = 632
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
      Top = 416
      Width = 632
      Height = 40
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object rbSave: TRadioButton
        Left = 11
        Top = 1
        Width = 233
        Height = 17
        Caption = 'записать изменения в базу данных'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rbCancel: TRadioButton
        Left = 11
        Top = 19
        Width = 361
        Height = 17
        Caption = 'сохранить объект в базе данных в исходном состоянии'
        TabOrder = 1
      end
      object pnlRightBottom: TPanel
        Left = 447
        Top = 0
        Width = 185
        Height = 40
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 2
        object btnOK: TButton
          Left = 105
          Top = 7
          Width = 75
          Height = 21
          Action = actClose
          Default = True
          TabOrder = 0
        end
      end
    end
    object pnlGrid: TPanel
      Left = 0
      Top = 91
      Width = 632
      Height = 325
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      OnResize = pnlGridResize
      object sgMain: TStringGrid
        Left = 4
        Top = 4
        Width = 624
        Height = 317
        Align = alClient
        ColCount = 3
        DefaultRowHeight = 18
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
      Width = 632
      Height = 91
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      object lTitle: TLabel
        Left = 8
        Top = 64
        Width = 369
        Height = 27
        AutoSize = False
        Caption = 
          'Двойным щелчком мыши выделите в таблице значения, которые будут ' +
          'записаны в базу данных.'
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
        Width = 19
        Height = 13
        Caption = 'ИД:'
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
      object pnlRight: TPanel
        Left = 448
        Top = 0
        Width = 184
        Height = 91
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object cbShowOnlyDiff: TCheckBox
          Left = 6
          Top = 7
          Width = 169
          Height = 17
          Action = actShowOnlyDiff
          TabOrder = 0
        end
        object btnView: TButton
          Left = 104
          Top = 68
          Width = 75
          Height = 21
          Action = actView
          TabOrder = 1
        end
      end
    end
  end
  object actList: TActionList
    Left = 320
    Top = 184
    object actOK: TAction
      Caption = 'Записать'
      OnExecute = actOKExecute
    end
    object actCancel: TAction
      Caption = 'Сохранить'
      OnExecute = actCancelExecute
    end
    object actShowOnlyDiff: TAction
      Caption = 'Показывать только различия'
      OnExecute = ActShowOnlyDiffExecute
    end
    object actClose: TAction
      Caption = 'Закрыть'
      OnExecute = actCloseExecute
    end
    object actView: TAction
      Caption = 'Просмотр...'
      ShortCut = 114
      OnExecute = actViewExecute
      OnUpdate = actViewUpdate
    end
  end
end
