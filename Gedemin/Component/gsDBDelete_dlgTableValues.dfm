object dlgTableValues: TdlgTableValues
  Left = 198
  Top = 236
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
    Width = 558
    Height = 63
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object Memo1: TMemo
      Left = 4
      Top = 4
      Width = 550
      Height = 55
      TabStop = False
      Align = alClient
      BorderStyle = bsNone
      Color = clBtnFace
      Lines.Strings = (
        
          'Ниже приведен список записей, которые ссылаются на удаляемый объ' +
          'ект'
        'и препятствуют его удалению.'
        ''
        'Их надо удалить или отредактировать:'
        ' ')
      ReadOnly = True
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 63
    Width = 558
    Height = 273
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    Caption = 'Panel1'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 150
      Top = 4
      Width = 4
      Height = 265
      Cursor = crHSplit
    end
    object Panel4: TPanel
      Left = 4
      Top = 4
      Width = 146
      Height = 265
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object lvTables: TListView
        Left = 0
        Top = 0
        Width = 146
        Height = 265
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
      Left = 154
      Top = 4
      Width = 400
      Height = 265
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object dbgValue: TgsIBGrid
        Left = 0
        Top = 26
        Width = 400
        Height = 239
        Align = alClient
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
      object TBDock1: TTBDock
        Left = 0
        Top = 0
        Width = 400
        Height = 26
        object lblEof: TLabel
          Left = 72
          Top = 6
          Width = 32
          Height = 13
          Caption = '<Eof>'
        end
        object tbDelete: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'tbDelete'
          DockMode = dmCannotFloatOrChangeDocks
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object tbiEdit: TTBItem
            Action = actEdit
          end
          object tbiDelete: TTBItem
            Action = actDelete
          end
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
