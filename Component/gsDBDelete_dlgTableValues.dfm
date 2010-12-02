object dlgTableValues: TdlgTableValues
  Left = 272
  Top = 246
  Width = 574
  Height = 375
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Таблицы'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 566
    Height = 47
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 5
      Top = 2
      Width = 554
      Height = 26
      Caption = 
        'В базе данных существуют записи, которые содержат ссылки на удал' +
        'яемую запись. Для удаления записи, прежде, необходимо удалить ил' +
        'и изменить записи, которые на нее ссылаются.'
      WordWrap = True
    end
    object Label2: TLabel
      Left = 5
      Top = 31
      Width = 320
      Height = 13
      Caption = 'Перечень записей, содержащих ссылки на удаляемую запись:'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 47
    Width = 566
    Height = 301
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 146
      Top = 0
      Width = 3
      Height = 301
      Cursor = crHSplit
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 146
      Height = 301
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object lvTables: TListView
        Left = 0
        Top = 0
        Width = 146
        Height = 301
        Align = alClient
        Columns = <
          item
            AutoSize = True
            Caption = 'Тип записи (тип объекта)'
          end>
        HideSelection = False
        ReadOnly = True
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = lvTablesChange
      end
    end
    object Panel5: TPanel
      Left = 149
      Top = 0
      Width = 417
      Height = 301
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object lblEof: TLabel
        Left = 72
        Top = 5
        Width = 32
        Height = 13
        Caption = '<Eof>'
      end
      object dbgValue: TgsIBGrid
        Left = 0
        Top = 24
        Width = 417
        Height = 277
        Anchors = [akLeft, akTop, akRight, akBottom]
        Ctl3D = True
        DataSource = dsValue
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
      end
      object tbDelete: TTBToolbar
        Left = 2
        Top = 0
        Width = 46
        Height = 22
        Caption = 'tbDelete'
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object tbiEdit: TTBItem
          Action = actEdit
        end
        object tbiDelete: TTBItem
          Action = actDelete
        end
      end
    end
  end
  object dsValue: TDataSource
    Left = 320
    Top = 135
  end
  object alDelete: TActionList
    Images = dmImages.ilToolBarSmall
    Left = 375
    Top = 127
    object actEdit: TAction
      Caption = 'actEdit'
      Hint = 'Редактировать'
      ImageIndex = 1
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = 'actDelete'
      Hint = 'Удалить'
      ImageIndex = 2
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
  end
end
