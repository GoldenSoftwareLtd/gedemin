object gdc_dlgG: Tgdc_dlgG
  Left = 425
  Top = 257
  HelpContext = 114
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  ClientHeight = 315
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PopupMenu = pm_dlgG
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnDragDrop = FormDragDrop
  OnDragOver = FormDragOver
  PixelsPerInch = 96
  TextHeight = 13
  object btnAccess: TButton
    Left = 10
    Top = 285
    Width = 68
    Height = 21
    Caption = '&����'
    TabOrder = 2
    OnClick = btnAccessClick
  end
  object btnNew: TButton
    Left = 82
    Top = 285
    Width = 68
    Height = 21
    Action = actNew
    Caption = '&�����'
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 154
    Top = 285
    Width = 68
    Height = 21
    Action = actHelp
    TabOrder = 4
  end
  object btnOK: TButton
    Left = 377
    Top = 285
    Width = 68
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 449
    Top = 285
    Width = 68
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 1
  end
  object alBase: TActionList
    Left = 118
    Top = 215
    object actNew: TAction
      Caption = '�����'
      ImageIndex = 0
      ShortCut = 16463
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actHelp: TAction
      Caption = '�������'
      ImageIndex = 13
      ShortCut = 112
      OnExecute = actHelpExecute
      OnUpdate = actHelpUpdate
    end
    object actSecurity: TAction
      Caption = '��������...'
      ImageIndex = 28
      OnExecute = actSecurityExecute
      OnUpdate = actSecurityUpdate
    end
    object actOk: TAction
      Caption = '��'
      ShortCut = 16397
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = '������'
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
    object actNextRecord: TAction
      Caption = 'C���'
      ImageIndex = 46
      ShortCut = 16462
      OnExecute = actNextRecordExecute
      OnUpdate = actNextRecordUpdate
    end
    object actPrevRecord: TAction
      Caption = '����'
      ImageIndex = 45
      ShortCut = 16464
      OnExecute = actPrevRecordExecute
      OnUpdate = actPrevRecordUpdate
    end
    object actApply: TAction
      Caption = '���������'
      ImageIndex = 18
      ShortCut = 16467
      OnExecute = actApplyExecute
      OnUpdate = actApplyUpdate
    end
    object actFirstRecord: TAction
      Caption = '������'
      ImageIndex = 43
      OnExecute = actFirstRecordExecute
      OnUpdate = actFirstRecordUpdate
    end
    object actLastRecord: TAction
      Caption = '���������'
      ImageIndex = 44
      OnExecute = actLastRecordExecute
      OnUpdate = actLastRecordUpdate
    end
    object actProperty: TAction
      Caption = '�������� ������-��������'
      ImageIndex = 21
      OnExecute = actPropertyExecute
      OnUpdate = actPropertyUpdate
    end
    object actCopySettingsFromUser: TAction
      Caption = '����������� ��������� �����...'
      ImageIndex = 33
      OnExecute = actCopySettingsFromUserExecute
      OnUpdate = actCopySettingsFromUserUpdate
    end
    object actAddToSetting: TAction
      Caption = '������������ ����...'
      ImageIndex = 81
      OnExecute = actAddToSettingExecute
      OnUpdate = actAddToSettingUpdate
    end
    object actDocumentType: TAction
      Caption = '��� ���������, ���������...'
      OnExecute = actDocumentTypeExecute
      OnUpdate = actDocumentTypeUpdate
    end
    object actDistributeUserSettings: TAction
      Caption = '�������������� ���������'
      OnExecute = actDistributeUserSettingsExecute
    end
    object actHistory: TAction
      Caption = '�������...'
      Hint = '�������'
      OnExecute = actHistoryExecute
      OnUpdate = actHistoryUpdate
    end
  end
  object dsgdcBase: TDataSource
    Left = 80
    Top = 215
  end
  object pm_dlgG: TPopupMenu
    Left = 152
    Top = 216
    object actSecurity1: TMenuItem
      Action = actSecurity
    end
    object actHistory1: TMenuItem
      Action = actHistory
    end
    object N1: TMenuItem
      Action = actDocumentType
    end
    object sepFirst: TMenuItem
      Caption = '-'
    end
    object actNextRecord1: TMenuItem
      Action = actNextRecord
    end
    object actPrevRecord1: TMenuItem
      Action = actPrevRecord
    end
    object actFirstRecord1: TMenuItem
      Action = actFirstRecord
    end
    object actLastRecord1: TMenuItem
      Action = actLastRecord
    end
    object sepSecond: TMenuItem
      Caption = '-'
    end
    object actApply1: TMenuItem
      Action = actApply
    end
    object sepThird: TMenuItem
      Caption = '-'
    end
    object actProperty1: TMenuItem
      Action = actProperty
    end
    object actCopySettings1: TMenuItem
      Action = actCopySettingsFromUser
    end
    object nAddToSetting1: TMenuItem
      Action = actAddToSetting
    end
  end
end
