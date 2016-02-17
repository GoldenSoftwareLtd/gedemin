object dlgVarSelect: TdlgVarSelect
  Left = 675
  Top = 375
  Width = 640
  Height = 352
  ActiveControl = lbVars
  BorderWidth = 5
  Caption = 'Выбор переменной'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
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
    Width = 622
    Height = 283
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 310
      Top = 0
      Width = 3
      Height = 283
      Cursor = crHSplit
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 310
      Height = 283
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 310
        Height = 16
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = ' Переменная'
        Color = clInactiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object lbVars: TListBox
        Left = 0
        Top = 16
        Width = 310
        Height = 267
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = lbVarsClick
        OnDblClick = lbVarsDblClick
      end
    end
    object Panel3: TPanel
      Left = 313
      Top = 0
      Width = 309
      Height = 283
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 309
        Height = 16
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = ' Описание'
        Color = clInactiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object mDescription: TMemo
        Left = 0
        Top = 16
        Width = 309
        Height = 267
        Align = alClient
        Color = clInfoBk
        TabOrder = 0
      end
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 283
    Width = 622
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 545
      Top = 7
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 1
    end
    object Button2: TButton
      Left = 465
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
