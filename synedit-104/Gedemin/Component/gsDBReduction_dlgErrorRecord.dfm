object dlgErrorRecord: TdlgErrorRecord
  Left = 142
  Top = 160
  Width = 560
  Height = 374
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Ошибка'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 464
    Top = 0
    Width = 88
    Height = 347
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object btnDel: TButton
      Left = 8
      Top = 8
      Width = 77
      Height = 25
      Caption = 'Удалить'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 8
      Top = 40
      Width = 77
      Height = 25
      Cancel = True
      Caption = 'Отменить'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 464
    Height = 347
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 464
      Height = 54
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 9
        Top = 2
        Width = 267
        Height = 13
        Caption = 'Невозможно произвести замену в записях таблицы'
      end
      object Label2: TLabel
        Left = 9
        Top = 18
        Width = 438
        Height = 26
        Caption = 
          'Для того, чтобы продолжить объединение, необходимо удалить эти з' +
          'аписи. В случае согласия нажмите "Удалить". Для отмены объединен' +
          'ия записей нажмите "Отмена".'
        WordWrap = True
      end
      object lbTable: TLabel
        Left = 281
        Top = 2
        Width = 3
        Height = 13
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 54
      Width = 464
      Height = 293
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object dbgErrorRecord: TgsIBGrid
        Left = 0
        Top = 0
        Width = 464
        Height = 293
        Align = alClient
        Ctl3D = True
        DataSource = dsErrorRecord
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        ParentCtl3D = False
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
      end
    end
  end
  object qryErrorRecord: TIBQuery
    BufferChunks = 100
    Left = 255
    Top = 84
  end
  object dsErrorRecord: TDataSource
    DataSet = qryErrorRecord
    Left = 225
    Top = 84
  end
end
