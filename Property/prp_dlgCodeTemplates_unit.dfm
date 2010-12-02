object prp_dlgCodeTemplates: Tprp_dlgCodeTemplates
  Left = 526
  Top = 370
  BorderStyle = bsDialog
  Caption = 'Шаблоны кода'
  ClientHeight = 271
  ClientWidth = 405
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
  object Label1: TLabel
    Left = 8
    Top = 128
    Width = 80
    Height = 13
    Caption = 'Текст шаблона:'
  end
  object Label2: TLabel
    Left = 8
    Top = 3
    Width = 50
    Height = 13
    Caption = 'Шаблоны:'
  end
  object dbgrMain: TgsDBGrid
    Left = 8
    Top = 18
    Width = 313
    Height = 105
    DataSource = dsMain
    Options = [dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    InternalMenuKind = imkNone
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    ScaleColumns = True
    MinColWidth = 40
    ShowTotals = False
  end
  object dbmemCode: TDBMemo
    Left = 8
    Top = 144
    Width = 313
    Height = 97
    DataSource = dsMain
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object btnAdd: TButton
    Left = 326
    Top = 17
    Width = 75
    Height = 19
    Action = actAdd
    Anchors = [akLeft]
    TabOrder = 2
  end
  object btnDelete: TButton
    Left = 326
    Top = 40
    Width = 75
    Height = 19
    Action = actDelete
    Anchors = [akLeft]
    TabOrder = 3
  end
  object btnEdit: TButton
    Left = 326
    Top = 63
    Width = 75
    Height = 19
    Action = actEdit
    Anchors = [akLeft]
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 326
    Top = 248
    Width = 75
    Height = 19
    Hint = 'Отмена'
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 6
  end
  object btnOk: TButton
    Left = 246
    Top = 248
    Width = 75
    Height = 19
    Action = actOk
    Anchors = [akRight, akBottom]
    Default = True
    TabOrder = 5
  end
  object btnLoadFromFile: TButton
    Left = 8
    Top = 248
    Width = 75
    Height = 19
    Action = actLoadFromFile
    Anchors = [akLeft]
    TabOrder = 7
  end
  object btnSaveToFile: TButton
    Left = 88
    Top = 248
    Width = 75
    Height = 19
    Action = actSaveToFile
    Anchors = [akLeft]
    TabOrder = 8
  end
  object dsMain: TDataSource
    DataSet = cdsMain
    Left = 25
    Top = 26
  end
  object cdsMain: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'name'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'desc'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'value'
        DataType = ftString
        Size = 500
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    BeforePost = cdsMainBeforePost
    Left = 121
    Top = 33
  end
  object alMain: TActionList
    Left = 224
    Top = 40
    object actAdd: TAction
      Caption = 'Добавить'
      Hint = 'Добавить'
      OnExecute = actAddExecute
    end
    object actDelete: TAction
      Caption = 'Удалить'
      Hint = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actEdit: TAction
      Caption = 'Изменить'
      Hint = 'Изменить'
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actOk: TAction
      Caption = 'Ok'
      Hint = 'Ok'
      OnExecute = actOkExecute
    end
    object actLoadFromFile: TAction
      Caption = 'Загрузить...'
      Hint = 'Загрузить'
      OnExecute = actLoadFromFileExecute
    end
    object actSaveToFile: TAction
      Caption = 'Сохранить...'
      Hint = 'Сохранить'
      OnExecute = actSaveToFileExecute
    end
  end
  object od: TOpenDialog
    DefaultExt = 'ct'
    Filter = 'Шаблоны кода(*.ct)|*.ct'
    InitialDir = 'c:\'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 48
    Top = 96
  end
  object sd: TSaveDialog
    DefaultExt = 'ct'
    Filter = 'Шаблоны кода(*.ct)|*.ct'
    InitialDir = 'c:\'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 88
    Top = 96
  end
end
