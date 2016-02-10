object dlgVarSelect: TdlgVarSelect
  Left = 675
  Top = 375
  Width = 571
  Height = 264
  ActiveControl = lbVars
  BorderWidth = 5
  Caption = 'Выбор переменной'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 553
    Height = 195
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 275
      Top = 0
      Width = 3
      Height = 195
      Cursor = crHSplit
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 275
      Height = 195
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 275
        Height = 16
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = ' Переменная'
        Color = clInactiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object lbVars: TListBox
        Left = 0
        Top = 16
        Width = 275
        Height = 179
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = lbVarsClick
        OnDblClick = lbVarsDblClick
      end
    end
    object Panel3: TPanel
      Left = 278
      Top = 0
      Width = 275
      Height = 195
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 275
        Height = 16
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = ' Описание'
        Color = clInactiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object mDescription: TMemo
        Left = 0
        Top = 16
        Width = 275
        Height = 179
        Align = alClient
        Color = clInfoBk
        TabOrder = 0
      end
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 195
    Width = 553
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 476
      Top = 7
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 1
    end
    object Button2: TButton
      Left = 396
      Top = 7
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 0
    end
  end
  object ActionList: TActionList
    Left = 32
    Top = 32
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
  end
end
