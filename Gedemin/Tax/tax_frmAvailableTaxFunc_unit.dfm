object frmAvailableTaxFunc: TfrmAvailableTaxFunc
  Left = 499
  Top = 244
  Width = 468
  Height = 343
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
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 276
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 128
      Width = 450
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object pnlHelp: TPanel
      Left = 0
      Top = 131
      Width = 450
      Height = 145
      Align = alBottom
      BevelOuter = bvLowered
      Color = clHighlight
      TabOrder = 0
      object pnlDecr: TPanel
        Left = 1
        Top = 1
        Width = 448
        Height = 143
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object mmDescription: TMemo
          Left = 0
          Top = 18
          Width = 448
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
          Width = 448
          Height = 18
          Align = alTop
          TabOrder = 1
          object lblFuncParam: TLabel
            Left = 1
            Top = 1
            Width = 446
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
      Width = 450
      Height = 128
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel1'
      TabOrder = 1
      object Splitter2: TSplitter
        Left = 233
        Top = 0
        Width = 3
        Height = 128
        Cursor = crHSplit
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 233
        Height = 128
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
          Height = 111
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
        Top = 0
        Width = 214
        Height = 128
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel3'
        TabOrder = 1
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 214
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
          Width = 214
          Height = 111
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
    Top = 276
    Width = 450
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 282
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
      Left = 368
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
