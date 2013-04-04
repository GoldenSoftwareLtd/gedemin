object dlgToNamespace: TdlgToNamespace
  Left = 603
  Top = 153
  Width = 577
  Height = 443
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
    Top = 129
    Width = 561
    Height = 276
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object dbgrListLink: TgsDBGrid
      Left = 0
      Top = 0
      Width = 561
      Height = 245
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
      CheckBox.DisplayField = 'displayname'
      CheckBox.FieldName = 'id'
      CheckBox.Visible = True
      CheckBox.FirstColumn = True
      ScaleColumns = True
      MinColWidth = 40
      ShowTotals = False
    end
    object pnlButtons: TPanel
      Left = 0
      Top = 245
      Width = 561
      Height = 31
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object btnDelete: TBitBtn
        Left = 7
        Top = 6
        Width = 80
        Height = 21
        Action = actClear
        Caption = '�������'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object Panel1: TPanel
        Left = 386
        Top = 0
        Width = 175
        Height = 31
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnOK: TBitBtn
          Left = 1
          Top = 5
          Width = 80
          Height = 21
          Action = actOK
          Caption = '&��'
          Default = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object btnCancel: TBitBtn
          Left = 87
          Top = 5
          Width = 80
          Height = 21
          Action = actCancel
          Caption = '&������'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
      end
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 561
    Height = 129
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
      Top = 110
      Width = 195
      Height = 13
      Caption = '��������� ������� (�� ����� 60-��):'
    end
    object cbIncludeSiblings: TCheckBox
      Left = 8
      Top = 84
      Width = 265
      Height = 17
      Caption = '�������� ��������� �������'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object cbDontRemove: TCheckBox
      Left = 8
      Top = 68
      Width = 289
      Height = 17
      Caption = '�� ������� ��� �������� ������������ ����'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object cbAlwaysOverwrite: TCheckBox
      Left = 8
      Top = 51
      Width = 233
      Height = 17
      Caption = '������ �������������� ��� ��������'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
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
      Caption = '�������'
      OnExecute = actClearExecute
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
