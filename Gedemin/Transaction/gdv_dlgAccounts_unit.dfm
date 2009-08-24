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
    Top = 287
    Width = 327
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 250
      Top = 10
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 1
    end
    object Button2: TButton
      Left = 170
      Top = 10
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 0
    end
    object Button3: TButton
      Left = 0
      Top = 10
      Width = 75
      Height = 21
      Action = actHelp
      Anchors = [akLeft, akBottom]
      TabOrder = 2
    end
  end
  object gsDBTreeView: TgsDBTreeView
    Left = 0
    Top = 28
    Width = 327
    Height = 259
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
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 327
    Height = 28
    BoundLines = [blTop, blBottom]
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar1'
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
      Caption = 'Ok'
      ShortCut = 13
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Cancel'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actSelectAll: TAction
      Caption = 'actSelectAll'
      Hint = 'Выбрать все'
      ImageIndex = 40
      OnExecute = actSelectAllExecute
    end
    object actDeselectAll: TAction
      Caption = 'actDeselectAll'
      Hint = 'Снять выбор'
      ImageIndex = 41
      OnExecute = actDeselectAllExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
    end
  end
end
