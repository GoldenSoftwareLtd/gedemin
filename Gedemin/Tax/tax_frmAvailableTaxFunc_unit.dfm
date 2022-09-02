object frmAvailableTaxFunc: TfrmAvailableTaxFunc
  Left = 499
  Top = 244
  Width = 468
  Height = 493
  HelpContext = 17
  BorderIcons = [biSystemMenu, biMaximize, biHelp]
  BorderWidth = 5
  Caption = 'Доступные функции'
  Color = clBtnFace
  Constraints.MinHeight = 328
  Constraints.MinWidth = 468
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCanResize = FormCanResize
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 442
    Height = 419
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 271
      Width = 442
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object pnlHelp: TPanel
      Left = 0
      Top = 274
      Width = 442
      Height = 145
      Align = alBottom
      BevelOuter = bvLowered
      Color = clHighlight
      TabOrder = 0
      object pnlDecr: TPanel
        Left = 1
        Top = 1
        Width = 440
        Height = 143
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object mmDescription: TMemo
          Left = 0
          Top = 18
          Width = 440
          Height = 125
          TabStop = False
          Align = alClient
          BorderStyle = bsNone
          Color = clInfoBk
          Lines.Strings = (
            '')
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
        end
        object pnlFuncParam: TPanel
          Left = 0
          Top = 0
          Width = 440
          Height = 18
          Align = alTop
          TabOrder = 1
          object lblFuncParam: TLabel
            Left = 1
            Top = 1
            Width = 438
            Height = 16
            Align = alClient
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
          end
        end
      end
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 442
      Height = 271
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel1'
      TabOrder = 1
      object Splitter2: TSplitter
        Left = 233
        Top = 45
        Width = 3
        Height = 226
        Cursor = crHSplit
      end
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 442
        Height = 45
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object Label2: TLabel
          Left = 2
          Top = 4
          Width = 48
          Height = 13
          Caption = ' Фильтр: '
        end
        object lblFunctionCount: TLabel
          Left = 267
          Top = 4
          Width = 48
          Height = 13
          Caption = 'Функций:'
        end
        object edFilter: TEdit
          Left = 50
          Top = 0
          Width = 214
          Height = 21
          TabOrder = 0
          OnChange = edFilterChange
        end
        object cbSearchWithRegExp: TCheckBox
          Left = 49
          Top = 24
          Width = 392
          Height = 17
          Caption = 'использовать регулярные выражения'
          TabOrder = 1
          OnClick = cbSearchWithRegExpClick
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 45
        Width = 233
        Height = 226
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel2'
        TabOrder = 0
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 233
          Height = 17
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = ' Категория'
          Color = clInactiveCaption
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clCaptionText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object tvTypeFunction: TTreeView
          Left = 0
          Top = 17
          Width = 233
          Height = 209
          Align = alClient
          Images = dmImages.ilTree
          Indent = 19
          ParentShowHint = False
          ReadOnly = True
          RowSelect = True
          ShowHint = False
          ShowRoot = False
          TabOrder = 1
          OnChange = tvTypeFunctionChange
        end
      end
      object Panel3: TPanel
        Left = 236
        Top = 45
        Width = 206
        Height = 226
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel3'
        TabOrder = 1
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 206
          Height = 17
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = ' Функция'
          Color = clInactiveCaption
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clCaptionText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object lvFunction: TListView
          Left = 0
          Top = 17
          Width = 206
          Height = 209
          Align = alClient
          Columns = <
            item
              AutoSize = True
            end>
          ColumnClick = False
          ReadOnly = True
          ParentShowHint = False
          ShowColumnHeaders = False
          ShowHint = True
          SmallImages = dmImages.imTreeView
          SortType = stText
          TabOrder = 1
          ViewStyle = vsReport
          OnDblClick = lvFunctionDblClick
          OnSelectItem = lvFunctionSelectItem
        end
      end
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 419
    Width = 442
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 273
      Top = 5
      Width = 80
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 359
      Top = 5
      Width = 81
      Height = 21
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
