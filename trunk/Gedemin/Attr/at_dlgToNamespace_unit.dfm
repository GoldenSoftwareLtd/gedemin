object dlgToNamespace: TdlgToNamespace
  Left = 445
  Top = 223
  Width = 737
  Height = 542
  Caption = '���������� ������� � ������������ ����'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlGrid: TPanel
    Left = 0
    Top = 112
    Width = 721
    Height = 392
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object dbgrListLink: TgsDBGrid
      Left = 0
      Top = 0
      Width = 721
      Height = 361
      Align = alClient
      DataSource = dsMain
      Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      TableFont.Charset = DEFAULT_CHARSET
      TableFont.Color = clWindowText
      TableFont.Height = -11
      TableFont.Name = 'Tahoma'
      TableFont.Style = []
      SelectedFont.Charset = DEFAULT_CHARSET
      SelectedFont.Color = clHighlightText
      SelectedFont.Height = -11
      SelectedFont.Name = 'Tahoma'
      SelectedFont.Style = []
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = True
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.DisplayField = 'class'
      CheckBox.FieldName = 'id'
      CheckBox.Visible = True
      CheckBox.FirstColumn = True
      ScaleColumns = True
      MinColWidth = 40
      ShowTotals = False
    end
    object pnlButtons: TPanel
      Left = 0
      Top = 361
      Width = 721
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object pnlRightBottom: TPanel
        Left = 497
        Top = 0
        Width = 224
        Height = 31
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnOk: TButton
          Left = 61
          Top = 5
          Width = 75
          Height = 21
          Action = actOK
          Default = True
          TabOrder = 0
        end
        object Button2: TButton
          Left = 141
          Top = 5
          Width = 75
          Height = 21
          Action = actCancel
          Cancel = True
          TabOrder = 1
        end
      end
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 721
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lMessage: TLabel
      Left = 8
      Top = 8
      Width = 102
      Height = 13
      Caption = '������������ ����:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object Label1: TLabel
      Left = 8
      Top = 96
      Width = 245
      Height = 13
      Caption = '��������� ������� (�������� �� ����� 60-��):'
    end
    object Label2: TLabel
      Left = 8
      Top = 51
      Width = 43
      Height = 13
      Caption = '������:'
    end
    object cbIncludeSiblings: TCheckBox
      Left = 344
      Top = 55
      Width = 337
      Height = 17
      Caption = '��� ����������� �������� �������� ��������� �������'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
    end
    object cbDontRemove: TCheckBox
      Left = 344
      Top = 39
      Width = 331
      Height = 17
      Caption = '�� ������� ������� ��� �������� ������������ ����'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
    end
    object cbAlwaysOverwrite: TCheckBox
      Left = 344
      Top = 22
      Width = 233
      Height = 17
      Caption = '������ �������������� ��� ��������'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object lkup: TgsIBLookupComboBox
      Left = 8
      Top = 24
      Width = 305
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTransaction
      ListTable = 'at_namespace'
      ListField = 'name'
      KeyField = 'ID'
      gdClassName = 'TgdcNamespace'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = lkupChange
    end
    object edObjectName: TEdit
      Left = 8
      Top = 66
      Width = 305
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 2
    end
    object btnClear: TButton
      Left = 313
      Top = 23
      Width = 24
      Height = 21
      Action = actClear
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object cdsLink: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 336
    Top = 216
  end
  object dsMain: TDataSource
    DataSet = cdsLink
    Left = 304
    Top = 216
  end
  object ActionList: TActionList
    Left = 400
    Top = 216
    object actShowLink: TAction
      Caption = '��������'
      OnExecute = actShowLinkExecute
      OnUpdate = actShowLinkUpdate
    end
    object actOK: TAction
      Caption = '&��'
      OnExecute = actOKExecute
    end
    object actCancel: TAction
      Caption = '&������'
      OnExecute = actCancelExecute
    end
    object actClear: TAction
      Caption = 'X'
      Hint = '������� ������ �� ������������ ����'
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 368
    Top = 216
  end
end
