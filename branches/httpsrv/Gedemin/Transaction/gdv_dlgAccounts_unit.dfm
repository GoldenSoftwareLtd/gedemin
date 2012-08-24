object gdv_dlgAccounts: Tgdv_dlgAccounts
  Left = 417
  Top = 192
  Width = 345
  Height = 354
  BorderWidth = 5
  Caption = 'Выбор счёта'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 276
    Width = 319
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button3: TButton
      Left = 0
      Top = 7
      Width = 75
      Height = 21
      Action = actHelp
      Anchors = [akLeft, akBottom]
      TabOrder = 1
    end
    object pnlBottomRight: TPanel
      Left = 134
      Top = 0
      Width = 185
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 108
        Top = 7
        Width = 75
        Height = 21
        Action = actCancel
        Anchors = [akRight, akBottom]
        TabOrder = 0
      end
      object Button2: TButton
        Left = 24
        Top = 7
        Width = 75
        Height = 21
        Action = actOk
        Anchors = [akRight, akBottom]
        Default = True
        TabOrder = 1
      end
    end
  end
  object gsDBTreeView: TgsDBTreeView
    Left = 0
    Top = 26
    Width = 319
    Height = 250
    DataSource = DataSource1
    KeyField = 'ID'
    ParentField = 'PARENT'
    DisplayField = 'Alias'
    Align = alClient
    Indent = 19
    TabOrder = 1
    MainFolderHead = True
    MainFolder = False
    MainFolderCaption = 'Все'
    WithCheckBox = True
  end
  object tbdMain: TTBDock
    Left = 0
    Top = 0
    Width = 319
    Height = 26
    object tbtMain: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'tbtMain'
      DockMode = dmCannotFloatOrChangeDocks
      FullSize = True
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object TBItem2: TTBItem
        Action = actSelectAll
      end
      object TBItem1: TTBItem
        Action = actDeselectAll
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = gdcAcctAccountChart
    Left = 32
    Top = 208
  end
  object gdcAcctAccountChart: TgdcAcctBase
    Left = 64
    Top = 208
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 96
    Top = 208
    object actOk: TAction
      Caption = 'OK'
      Hint = 'OK'
      ShortCut = 13
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      Hint = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actDeselectAll: TAction
      Caption = 'Снять выбор'
      Hint = 'Снять выбор'
      ImageIndex = 41
      OnExecute = actDeselectAllExecute
    end
    object actSelectAll: TAction
      Caption = 'Выбрать все'
      Hint = 'Выбрать все'
      ImageIndex = 40
      OnExecute = actSelectAllExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
      Hint = 'Справка'
    end
  end
end
