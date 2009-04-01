object frmGedeminMain: TfrmGedeminMain
  Left = 167
  Top = 160
  Width = 918
  Height = 85
  HelpContext = 76
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Gedemin'
  Color = clBtnFace
  Constraints.MaxHeight = 85
  Constraints.MaxWidth = 2000
  Constraints.MinHeight = 80
  Constraints.MinWidth = 400
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TBDockMain: TTBDock
    Left = 0
    Top = 0
    Width = 910
    Height = 26
    LimitToOneRow = True
    object tbMainMenu: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'tbMainMenu'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 0
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      Stretch = True
      TabOrder = 0
      object tbsiDatabase: TTBSubmenuItem
        Caption = '���� ������'
        object N14: TTBItem
          Action = actShowUsers
        end
        object MenuItem1: TTBItem
          Action = actLogIn
        end
        object N15: TTBItem
          Action = actLogOff
        end
        object N23: TTBSeparatorItem
        end
        object N18: TTBItem
          Action = actLoginSingle
        end
        object N19: TTBItem
          Action = actBringOnline
        end
        object N20: TTBSeparatorItem
        end
        object actBackup1: TTBItem
          Action = actBackup
        end
        object N22: TTBItem
          Action = actRestore
        end
        object TBSeparatorItem9: TTBSeparatorItem
        end
        object tbiRecompile: TTBItem
          Action = actRecompileStatistics
        end
        object TBSeparatorItem8888: TTBSeparatorItem
        end
        object TBItem10: TTBItem
          Action = actExit
        end
      end
      object tbsiMacro: TTBSubmenuItem
        Caption = '������'
        object Property1: TTBItem
          Action = actProperty
        end
        object TBItem2: TTBItem
          Action = actEditForm
        end
        object TBItem21: TTBItem
          Action = actSQLEditor
        end
        object TBItem1: TTBItem
          Action = actSQLMonitor
        end
        object N24: TTBSeparatorItem
        end
        object tbiScanTemplate: TTBItem
          Action = actScanTemplate
        end
        object TBItem3: TTBItem
          Caption = '�������������� �����'
          OnClick = TBItem3Click
        end
        object TBItem4: TTBItem
          Caption = '��������'
          OnClick = TBItem4Click
        end
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBItem9: TTBItem
          Action = actShowSQLObjects
        end
        object TBSeparatorItem12: TTBSeparatorItem
        end
        object TBItem22: TTBItem
          Action = actLoadPackage
          Caption = '���������� ������ ��������...'
        end
        object TBSeparatorItem13: TTBSeparatorItem
        end
        object TBItem23: TTBItem
          Action = actShowMonitoring
          Caption = '������� ����������'
        end
        object TBItem17: TTBItem
          Action = actCompareDataBases
        end
        object TBSeparatorItem6: TTBSeparatorItem
        end
        object tbiStreamSaverOptions: TTBItem
          Action = actStreamSaverOptions
        end
        object TBItem20: TTBItem
          Action = actShell
        end
        object tbiOptions: TTBItem
          Action = actOptions
        end
      end
      object tbsiWindow: TTBSubmenuItem
        Caption = '����'
        object TBItem6: TTBItem
          Action = actExplorer
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object N25: TTBItem
          Action = actActiveFormList
        end
        object N26: TTBItem
          Action = actClear
        end
        object TBSeparatorItem3: TTBSeparatorItem
        end
        object TBItem7: TTBItem
          Action = actSaveDesktop
        end
        object TBItem8: TTBItem
          Action = actDeleteDesktop
        end
      end
      object tbsiHelp: TTBSubmenuItem
        Caption = '�������'
        object TBItem18: TTBItem
          Caption = '�������� ��������'
          ImageIndex = 13
          Visible = False
          OnClick = TBItem18Click
        end
        object TBItem12: TTBItem
          Caption = '����������� ������������'
          ImageIndex = 13
          OnClick = TBItem12Click
        end
        object TBItem11: TTBItem
          Caption = '����������� ������������'
          ImageIndex = 13
          Visible = False
          OnClick = TBItem11Click
        end
        object TBItem19: TTBItem
          Caption = '����������� ������������'
          ImageIndex = 13
          Visible = False
          OnClick = TBItem19Click
        end
        object TBSeparatorItem10: TTBSeparatorItem
        end
        object TBItem13: TTBItem
          Caption = '������� �� VBScript'
          ImageIndex = 13
          OnClick = TBItem13Click
        end
        object TBItem16: TTBItem
          Caption = '����������� �� FastReport'
          ImageIndex = 13
          OnClick = TBItem16Click
        end
        object TBSeparatorItem11: TTBSeparatorItem
        end
        object TBItem5: TTBItem
          Caption = 'www.gsbelarus.com'
          ImageIndex = 119
          OnClick = TBItem5Click
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object tbiRegistration: TTBItem
          Action = actRegistration
        end
        object N2: TTBItem
          Action = actAbout
        end
      end
      object TBSeparatorItem7: TTBSeparatorItem
      end
      object TBControlItem3: TTBControlItem
        Control = Label1
      end
      object TBControlItem1: TTBControlItem
        Control = cbDesktop
      end
      object TBItem14: TTBItem
        Action = actSaveDesktop
      end
      object TBItem15: TTBItem
        Action = actDeleteDesktop
      end
      object tbiCloseAll: TTBItem
        Action = actCloseAll
        Hint = '������� ��� ����'
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBControlItem5: TTBControlItem
        Control = Label2
      end
      object TBControlItem4: TTBControlItem
        Control = gsiblkupCompany
      end
      object tbiWorkingCompaniesBtn: TTBItem
        Action = actWorkingCompanies
      end
      object TBSeparatorItem8: TTBSeparatorItem
      end
      object TBControlItem6: TTBControlItem
        Control = lblDatabase
      end
      object Label1: TLabel
        Left = 224
        Top = 4
        Width = 32
        Height = 13
        Caption = '����: '
      end
      object Label2: TLabel
        Left = 476
        Top = 4
        Width = 73
        Height = 13
        Caption = '�����������: '
      end
      object lblDatabase: TLabel
        Left = 723
        Top = 4
        Width = 3
        Height = 13
        Alignment = taRightJustify
        PopupMenu = pmlblDataBase
      end
      object cbDesktop: TComboBox
        Left = 256
        Top = 0
        Width = 145
        Height = 21
        Style = csDropDownList
        Anchors = []
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 0
        OnChange = cbDesktopChange
      end
      object gsiblkupCompany: TgsIBLookupComboBox
        Left = 549
        Top = 0
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'gd_ourcompany z JOIN gd_contact c ON c.id = z.companykey'
        ListField = 'c.name'
        KeyField = 'companykey'
        SortOrder = soAsc
        gdClassName = 'TgdcOurCompany'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = gsiblkupCompanyChange
      end
    end
  end
  object TBDockForms: TTBDock
    Left = 0
    Top = 33
    Width = 910
    Height = 25
    LimitToOneRow = True
    Position = dpBottom
    object tbForms: TTBToolbar
      Left = 0
      Top = 0
      Caption = '�����'
      ChevronHint = '�������� ���'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 0
      Stretch = True
      TabOrder = 0
      OnResize = tbFormsResize
      object TBControlItem2: TTBControlItem
        Control = tcForms
      end
      object tcForms: TTabControl
        Left = 0
        Top = 0
        Width = 766
        Height = 21
        ParentShowHint = False
        PopupMenu = pmForms
        ShowHint = True
        Style = tsFlatButtons
        TabOrder = 0
        OnChange = tcFormsChange
        OnMouseMove = tcFormsMouseMove
      end
    end
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 606
    Top = 30
    object actAbout: TAction
      Category = '�������'
      Caption = '� �������...'
      ImageIndex = 150
      OnExecute = actAboutExecute
    end
    object actExit: TAction
      Category = 'File'
      Caption = '�����'
      ImageIndex = 125
      OnExecute = actExitExecute
      OnUpdate = actExitUpdate
    end
    object actExplorer: TAction
      Category = '��������'
      Caption = '�������������'
      ImageIndex = 219
      ShortCut = 16506
      OnExecute = actExplorerExecute
      OnUpdate = actExplorerUpdate
    end
    object actSaveDesktop: TAction
      Category = '��������'
      Caption = '��������� ����...'
      Hint = '��������� ����'
      ImageIndex = 38
      OnExecute = actSaveDesktopExecute
      OnUpdate = actSaveDesktopUpdate
    end
    object actDeleteDesktop: TAction
      Category = '��������'
      Caption = '������� ����'
      Hint = '������� ����'
      ImageIndex = 39
      OnExecute = actDeleteDesktopExecute
      OnUpdate = actDeleteDesktopUpdate
    end
    object actShow: TAction
      Category = 'Tray'
      Caption = '�������'
      ImageIndex = 0
      OnExecute = actShowExecute
      OnUpdate = actShowUpdate
    end
    object actActiveFormList: TAction
      Category = 'Actions'
      Caption = '������ �������� ����...'
      OnExecute = actActiveFormListExecute
      OnUpdate = actActiveFormListUpdate
    end
    object actClear: TAction
      Category = 'Actions'
      Caption = '�������� ������'
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
    end
    object actLogIn: TAction
      Category = 'Actions'
      Caption = '������������ � ���� ������'
      ImageIndex = 106
      OnExecute = actLogInExecute
      OnUpdate = actLogInUpdate
    end
    object actLogOff: TAction
      Category = 'Actions'
      Caption = '����������� �� ���� ������'
      ImageIndex = 109
      OnExecute = actLogOffExecute
      OnUpdate = actLogOffUpdate
    end
    object actLoginSingle: TAction
      Category = 'Actions'
      Caption = '������������ � �������������������� ������'
      ImageIndex = 111
      OnExecute = actLoginSingleExecute
      OnUpdate = actLoginSingleUpdate
    end
    object actBringOnline: TAction
      Category = 'Actions'
      Caption = '������� ���� ������ � ���������� �����'
      OnExecute = actBringOnlineExecute
      OnUpdate = actBringOnlineUpdate
    end
    object actBackup: TAction
      Category = 'Actions'
      Caption = '�������� �����������...'
      OnExecute = actBackupExecute
      OnUpdate = actBackupUpdate
    end
    object actRestore: TAction
      Category = 'Actions'
      Caption = '�������������� ���� ������...'
      OnExecute = actRestoreExecute
      OnUpdate = actRestoreUpdate
    end
    object actEditForm: TAction
      Category = 'Actions'
      Caption = '�������� ����...'
      ImageIndex = 115
      OnExecute = actEditFormExecute
      OnUpdate = actEditFormUpdate
    end
    object actShowUsers: TAction
      Category = 'Actions'
      Caption = '������������ ������������...'
      ImageIndex = 35
      OnExecute = actShowUsersExecute
      OnUpdate = actShowUsersUpdate
    end
    object actShowSQLObjects: TAction
      Category = 'Actions'
      Caption = 'actShowSQLObjects'
      OnExecute = actShowSQLObjectsExecute
      OnUpdate = actShowSQLObjectsUpdate
    end
    object actProperty: TAction
      Category = '�������'
      Caption = '�������� ������-��������...'
      ImageIndex = 21
      OnExecute = actPropertyExecute
      OnUpdate = actPropertyUpdate
    end
    object actOptions: TAction
      Caption = '�����...'
      ImageIndex = 28
      OnExecute = actOptionsExecute
      OnUpdate = actOptionsUpdate
    end
    object actScanTemplate: TAction
      Category = '��������'
      Caption = '�������� ������� ����������...'
      OnExecute = actScanTemplateExecute
      OnUpdate = actScanTemplateUpdate
    end
    object actSQLEditor: TAction
      Caption = 'SQL ��������...'
      ImageIndex = 108
      OnExecute = actSQLEditorExecute
      OnUpdate = actSQLEditorUpdate
    end
    object actCloseForm: TAction
      Category = 'Forms'
      Caption = '������� �����'
      Hint = '������� �����'
      OnExecute = actCloseFormExecute
      OnUpdate = actCloseFormUpdate
    end
    object actCloseAll: TAction
      Category = 'Forms'
      Caption = '������� ���'
      Hint = '������� ���'
      ImageIndex = 42
      OnExecute = actCloseAllExecute
      OnUpdate = actCloseAllUpdate
    end
    object actHideForm: TAction
      Category = 'Forms'
      Caption = '�������� �����'
      Hint = '�������� �����'
      OnExecute = actHideFormExecute
      OnUpdate = actHideFormUpdate
    end
    object actHideAll: TAction
      Category = 'Forms'
      Caption = '�������� ���'
      Hint = '�������� ���'
      OnExecute = actHideAllExecute
      OnUpdate = actHideAllUpdate
    end
    object actWorkingCompanies: TAction
      Caption = '������� �����������...'
      Hint = '������� �����������'
      ImageIndex = 134
      OnExecute = actWorkingCompaniesExecute
      OnUpdate = actWorkingCompaniesUpdate
    end
    object actHelp: TAction
      Caption = 'actHelp'
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actLoadPackage: TAction
      Category = 'Actions'
      Caption = '���������� ���������...'
      Hint = '���������� ������ ��������...'
      ImageIndex = 80
      OnExecute = actLoadPackageExecute
      OnUpdate = actLoadPackageUpdate
    end
    object actRegistration: TAction
      Category = '�������'
      Caption = '�����������...'
      ImageIndex = 214
      OnExecute = actRegistrationExecute
      OnUpdate = actRegistrationUpdate
    end
    object actRecompileStatistics: TAction
      Category = 'Actions'
      Caption = '���������� ���������� ��������'
      OnExecute = actRecompileStatisticsExecute
      OnUpdate = actRecompileStatisticsUpdate
    end
    object actSQLMonitor: TAction
      Category = 'Actions'
      Caption = 'SQL �������'
      OnExecute = actSQLMonitorExecute
      OnUpdate = actSQLMonitorUpdate
    end
    object actCopy: TAction
      Caption = '����������'
      ImageIndex = 10
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actCompareDataBases: TAction
      Category = 'Actions'
      Caption = '�������� ���� ������'
      Hint = '�������� ���� ������'
      ImageIndex = 121
      OnExecute = actCompareDataBasesExecute
      OnUpdate = actCompareDataBasesUpdate
    end
    object actShell: TAction
      Caption = '������������ ��� ��������...'
      OnExecute = actShellExecute
      OnUpdate = actShellUpdate
    end
    object actStreamSaverOptions: TAction
      Category = 'Actions'
      Caption = '����� �������� ������'
      ImageIndex = 228
      OnExecute = actStreamSaverOptionsExecute
    end
    object actShowMonitoring: TAction
      Category = 'Actions'
      Caption = 'actMonitoring'
      Hint = '������� ����������'
      ImageIndex = 120
      OnExecute = actShowMonitoringExecute
      OnUpdate = actShowMonitoringUpdate
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
    Left = 648
    Top = 26
  end
  object pmForms: TPopupMenu
    Images = dmImages.il16x16
    Left = 296
    Top = 24
    object N1: TMenuItem
      Action = actHideForm
    end
    object N3: TMenuItem
      Action = actHideAll
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object actCloseForm1: TMenuItem
      Action = actCloseForm
    end
    object N4: TMenuItem
      Action = actCloseAll
    end
  end
  object pmlblDataBase: TPopupMenu
    Images = dmImages.il16x16
    Left = 424
    Top = 24
    object N6: TMenuItem
      Action = actCopy
    end
  end
end
