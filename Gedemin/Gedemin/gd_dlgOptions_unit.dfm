object gd_dlgOptions: Tgd_dlgOptions
  Left = 412
  Top = 268
  BorderStyle = bsDialog
  Caption = '����� �������'
  ClientHeight = 438
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 4
    Top = 3
    Width = 565
    Height = 397
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '�����'
      object Label1: TLabel
        Left = 3
        Top = 86
        Width = 275
        Height = 13
        Caption = '��� �������� �������� ����������� ���������� ��:'
      end
      object Label3: TLabel
        Left = 3
        Top = 188
        Width = 217
        Height = 13
        Caption = '���� ���, ��� �������� �� ������������:'
      end
      object Label4: TLabel
        Left = 335
        Top = 188
        Width = 159
        Height = 13
        Caption = '���. 0 -- �������� ���������.'
      end
      object Label5: TLabel
        Left = 3
        Top = 111
        Width = 238
        Height = 13
        Caption = '��� ����� ������� ����������� ������� ����:'
      end
      object chbxEnterAsTab: TCheckBox
        Left = 3
        Top = 6
        Width = 281
        Height = 17
        Caption = '������������ ENTER ��� TAB � ��������'
        TabOrder = 0
      end
      object chbxMagic: TCheckBox
        Left = 3
        Top = 24
        Width = 281
        Height = 17
        Caption = '��������� ���������� ����������� ����'
        TabOrder = 2
      end
      object chbxAutoSaveDesktop: TCheckBox
        Left = 278
        Top = 6
        Width = 269
        Height = 17
        Caption = '��������� ������� ���� ��� ������'
        TabOrder = 1
      end
      object chbxDialogDefaults: TCheckBox
        Left = 278
        Top = 24
        Width = 269
        Height = 17
        Caption = '��������� �������� ����� � ���������� �����'
        TabOrder = 3
      end
      object cbLanguage: TComboBox
        Left = 278
        Top = 81
        Width = 147
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 7
        Items.Strings = (
          '�� �����������'
          '���������� ����'
          '������� ����'
          'English')
      end
      object chbxCheckAccount: TCheckBox
        Left = 278
        Top = 131
        Width = 257
        Height = 17
        Caption = '��������� ������������ ����������� �����'
        TabOrder = 12
      end
      object chbxProhibitDuplicates: TCheckBox
        Left = 3
        Top = 131
        Width = 262
        Height = 17
        Caption = '��������� ���� ������������� �����������'
        TabOrder = 9
      end
      object chbxCheckUNN: TCheckBox
        Left = 24
        Top = 148
        Width = 233
        Height = 17
        Caption = '��������� ����������� �� ��� (���)'
        TabOrder = 10
      end
      object chbxCheckName: TCheckBox
        Left = 24
        Top = 166
        Width = 241
        Height = 17
        Caption = '��������� ����������� �� ������������'
        TabOrder = 11
      end
      object chbxHideMaster: TCheckBox
        Left = 278
        Top = 41
        Width = 269
        Height = 17
        Caption = '��������� ������� ������� ������'
        TabOrder = 4
      end
      object chbxShowZero: TCheckBox
        Left = 278
        Top = 59
        Width = 268
        Height = 17
        Caption = '���������� ���� � �������'
        TabOrder = 6
      end
      object seDateWindow: TSpinEdit
        Left = 278
        Top = 182
        Width = 52
        Height = 22
        MaxValue = 1000
        MinValue = 0
        TabOrder = 13
        Value = 0
      end
      object cbSaveDT: TComboBox
        Left = 278
        Top = 105
        Width = 147
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 8
        Items.Strings = (
          '���������'
          '�� ���������'
          '����������')
      end
      object chbxHintInGrid: TCheckBox
        Left = 3
        Top = 42
        Width = 273
        Height = 17
        Caption = '���������� ����������� ��������� � �������'
        TabOrder = 5
      end
      object chbxEditWarn: TCheckBox
        Left = 3
        Top = 206
        Width = 334
        Height = 17
        Caption = '������������� �� ���������� ���� �� ��������� ������'
        TabOrder = 14
      end
      object chbxByLBRB: TCheckBox
        Left = 3
        Top = 223
        Width = 302
        Height = 17
        Caption = '����� �� LB, RB ������� ��� ������������ ��������'
        TabOrder = 15
      end
      object chbxWarnMDMism: TCheckBox
        Left = 3
        Top = 239
        Width = 542
        Height = 17
        Caption = 
          '������������� � ��������� �������������� ��������� ������ ������' +
          '� ������'
        TabOrder = 16
      end
      object chbxFilterParams: TCheckBox
        Left = 3
        Top = 255
        Width = 542
        Height = 17
        Caption = 
          '������ ����������� ��������� ��� �������� ������� � ������������' +
          '� � ���������� ������'
        TabOrder = 17
      end
      object chbxCorrectWindowSize: TCheckBox
        Left = 3
        Top = 271
        Width = 542
        Height = 17
        Caption = '�������������, ���� ����� ����� ����� � ���������� ���� ������'
        TabOrder = 18
      end
      object cbDontUseGoodKey: TCheckBox
        Left = 3
        Top = 286
        Width = 542
        Height = 17
        Caption = 
          '��������� ������������� ���� ��� ������ ��� ������������ �������' +
          '�'
        TabOrder = 19
      end
      object chbxBlockRecord: TCheckBox
        Left = 3
        Top = 301
        Width = 542
        Height = 17
        Caption = '����������� ������ ��� �������� �� �������� ��� ���������'
        TabOrder = 20
      end
      object cbUseDelMovement: TCheckBox
        Left = 3
        Top = 317
        Width = 542
        Height = 17
        Caption = '������������ �������� ��������� ������� �������� ������� �� ����'
        TabOrder = 21
      end
      object chbxAutoCreate: TCheckBox
        Left = 3
        Top = 333
        Width = 486
        Height = 17
        Caption = 
          '������������� ��������� ������, ���� �� �� ������ � ���������� �' +
          '�����'
        TabOrder = 22
      end
      object chbxDelSilent: TCheckBox
        Left = 3
        Top = 349
        Width = 486
        Height = 17
        Caption = '�� ���������� ����������� ��� �������� �������'
        TabOrder = 23
      end
    end
    object tsAudit: TTabSheet
      Caption = '����� � ������������'
      ImageIndex = 1
      object Label12: TLabel
        Left = 16
        Top = 208
        Width = 317
        Height = 13
        Caption = '�������� ���������� ������� ����� ������ �������������.'
      end
      object GroupBox1: TGroupBox
        Left = 5
        Top = 4
        Width = 548
        Height = 89
        Caption = ' ������������  '
        TabOrder = 0
        object Memo1: TMemo
          Left = 8
          Top = 33
          Width = 529
          Height = 41
          TabStop = False
          BorderStyle = bsNone
          Lines.Strings = (
            
              '��� ����, ����� �������� ����������� ������������ ��������������' +
              '�� ���������� ����������  '
            
              '��������������� ����� � ���������� ���� �������������� ������� �' +
              '����� ������������.'
            ' '
            ' ')
          ParentColor = True
          ReadOnly = True
          TabOrder = 0
        end
        object Button4: TButton
          Left = 442
          Top = 61
          Width = 99
          Height = 21
          Action = actUsers
          TabOrder = 1
        end
        object chbxAllowAudit: TCheckBox
          Left = 11
          Top = 16
          Width = 281
          Height = 17
          Caption = '�������������� �������� ������������'
          TabOrder = 2
        end
      end
      object GroupBox2: TGroupBox
        Left = 5
        Top = 105
        Width = 548
        Height = 71
        Caption = ' �������  '
        TabOrder = 1
        object Memo2: TMemo
          Left = 8
          Top = 16
          Width = 529
          Height = 34
          TabStop = False
          BorderStyle = bsNone
          Lines.Strings = (
            
              '��� ����, ����� ���������������� ��������� ������ � ���� �������' +
              '��� ������� '
            '��������������� ��������.')
          ParentColor = True
          ReadOnly = True
          TabOrder = 0
        end
        object Button5: TButton
          Left = 442
          Top = 43
          Width = 99
          Height = 21
          Action = actJournal
          TabOrder = 1
        end
      end
      object gbBlock: TGroupBox
        Left = 5
        Top = 183
        Width = 548
        Height = 166
        Caption = ' ���������� �������, ���������������� �� ��������� � �������� '
        TabOrder = 2
        object lblBlock: TLabel
          Left = 149
          Top = 17
          Width = 169
          Height = 13
          Caption = '��������� �������� ������ ��:'
        end
        object chbxBlock: TCheckBox
          Left = 8
          Top = 16
          Width = 137
          Height = 17
          Caption = '�������� ����������.'
          TabOrder = 0
          OnClick = chbxBlockClick
        end
        object xdeBlock: TxDateEdit
          Left = 322
          Top = 13
          Width = 65
          Height = 21
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 7
          Text = '10.10.2003'
        end
        object mGroupsLabel: TMemo
          Left = 6
          Top = 35
          Width = 529
          Height = 14
          TabStop = False
          BorderStyle = bsNone
          ParentColor = True
          ReadOnly = True
          TabOrder = 3
          WordWrap = False
        end
        object mGroups: TMemo
          Left = 6
          Top = 52
          Width = 432
          Height = 44
          TabStop = False
          ParentColor = True
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 5
        end
        object btnGroups: TButton
          Left = 442
          Top = 77
          Width = 99
          Height = 21
          Action = actAddBlockGroup
          TabOrder = 1
        end
        object mDocumentTypes: TMemo
          Left = 6
          Top = 114
          Width = 432
          Height = 45
          TabStop = False
          ParentColor = True
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 4
        end
        object btnDocumentTypes: TButton
          Left = 442
          Top = 138
          Width = 99
          Height = 21
          Action = actAddBlockDT
          TabOrder = 2
        end
        object mDocumentTypesLabel: TMemo
          Left = 6
          Top = 98
          Width = 399
          Height = 14
          TabStop = False
          BorderStyle = bsNone
          ParentColor = True
          ReadOnly = True
          TabOrder = 6
          WordWrap = False
        end
      end
      object chbxMultipleConnect: TCheckBox
        Left = 14
        Top = 352
        Width = 345
        Height = 17
        Caption = '��������� ����� ������ ����������� ��� ����� �������'
        TabOrder = 3
      end
      object Button10: TButton
        Left = 440
        Top = 200
        Width = 99
        Height = 21
        Action = actBlock
        TabOrder = 4
        Visible = False
      end
    end
    object tsPolicy: TTabSheet
      Caption = '��������'
      ImageIndex = 3
      object lvPolicy: TListView
        Left = 0
        Top = 0
        Width = 557
        Height = 340
        Align = alClient
        Columns = <
          item
            Caption = '�������� ������������'
            Width = 220
          end
          item
            AutoSize = True
            Caption = '������'
          end
          item
            Caption = '��'
            Width = 0
          end>
        HideSelection = False
        ReadOnly = True
        ParentShowHint = False
        ShowHint = True
        SortType = stText
        TabOrder = 0
        ViewStyle = vsReport
      end
      object Panel1: TPanel
        Left = 0
        Top = 340
        Width = 557
        Height = 29
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object Button6: TButton
          Left = 0
          Top = 5
          Width = 89
          Height = 21
          Action = actPolDefault
          TabOrder = 0
        end
        object Button7: TButton
          Left = 94
          Top = 5
          Width = 89
          Height = 21
          Action = actPolChange
          TabOrder = 1
        end
      end
    end
    object tsBackup: TTabSheet
      Caption = '�������� �����������'
      ImageIndex = 3
      object Label9: TLabel
        Left = 16
        Top = 42
        Width = 261
        Height = 13
        Caption = '���� �� ������� ��� ���������� �������� �����:'
      end
      object gbArch2: TGroupBox
        Left = 8
        Top = 89
        Width = 353
        Height = 85
        TabOrder = 1
        object Label7: TLabel
          Left = 12
          Top = 57
          Width = 58
          Height = 13
          Caption = '��� �����:'
        end
        object rbArchOneFile: TRadioButton
          Left = 10
          Top = 13
          Width = 257
          Height = 17
          Caption = '������������ ���� ���� �������� �����'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbArchMultipleFiles: TRadioButton
          Left = 10
          Top = 32
          Width = 329
          Height = 17
          Caption = '������ ��� ��������� ����� ���� �������� �����'
          TabOrder = 1
        end
        object edArchFileName: TEdit
          Left = 104
          Top = 55
          Width = 166
          Height = 21
          TabOrder = 2
          Text = 'edArchFileName'
        end
        object Button9: TButton
          Left = 270
          Top = 54
          Width = 75
          Height = 21
          Caption = '��� ����'
          TabOrder = 3
          OnClick = Button9Click
        end
      end
      object gbArch3: TGroupBox
        Left = 8
        Top = 176
        Width = 353
        Height = 85
        TabOrder = 2
        object Label8: TLabel
          Left = 12
          Top = 57
          Width = 84
          Height = 13
          Caption = '������� ������:'
        end
        object rbArchAny: TRadioButton
          Left = 10
          Top = 13
          Width = 337
          Height = 17
          Caption = '�������������� ��� ����� ������� �������'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbArchSelected: TRadioButton
          Left = 10
          Top = 32
          Width = 321
          Height = 17
          Caption = '�������������� ������ ��� ��������� ������� �������'
          TabOrder = 1
        end
        object edArchLogin: TEdit
          Left = 104
          Top = 55
          Width = 166
          Height = 21
          TabOrder = 2
          Text = 'edArchFileName'
        end
      end
      object gbArch1: TGroupBox
        Left = 8
        Top = 2
        Width = 353
        Height = 85
        TabOrder = 0
        object Label6: TLabel
          Left = 10
          Top = 41
          Width = 261
          Height = 13
          Caption = '���� �� ������� ��� ���������� �������� �����:'
        end
        object chbxArchOn: TCheckBox
          Left = 10
          Top = 13
          Width = 305
          Height = 17
          Caption = '�������������� �������� ����������� ��������'
          TabOrder = 0
        end
        object edArchPath: TEdit
          Left = 10
          Top = 57
          Width = 260
          Height = 21
          TabOrder = 1
          Text = 'edArchPath'
        end
        object Button8: TButton
          Left = 270
          Top = 56
          Width = 75
          Height = 21
          Caption = '���� � ����'
          TabOrder = 2
          OnClick = Button8Click
        end
      end
      object gbArch4: TGroupBox
        Left = 8
        Top = 263
        Width = 353
        Height = 85
        TabOrder = 3
        object Label10: TLabel
          Left = 10
          Top = 16
          Width = 297
          Height = 13
          Caption = '��������� �������� ����������� ������                ����.'
        end
        object Label11: TLabel
          Left = 10
          Top = 60
          Width = 161
          Height = 13
          Caption = '���� ���������� �����������:'
        end
        object chbxArchCopy: TCheckBox
          Left = 10
          Top = 37
          Width = 329
          Height = 17
          Caption = '���������� ���������� ���� ������ �� ������� ��������'
          TabOrder = 1
        end
        object seArchInterval: TSpinEdit
          Left = 234
          Top = 14
          Width = 41
          Height = 22
          MaxValue = 999
          MinValue = 1
          TabOrder = 0
          Value = 7
        end
        object xedArchDate: TxDateEdit
          Left = 208
          Top = 56
          Width = 121
          Height = 21
          Enabled = False
          EditMask = '!99\.99\.9999 99\:99\:99;1;_'
          MaxLength = 19
          ReadOnly = True
          TabOrder = 2
          Text = '  .  .       :  :  '
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = '�������������'
      ImageIndex = 4
      object gbConfirmations: TGroupBox
        Left = 3
        Top = 9
        Width = 550
        Height = 56
        Caption = ' ����������� ������������� '
        TabOrder = 0
        object chbxEditMultipleConfirmation: TCheckBox
          Left = 10
          Top = 16
          Width = 215
          Height = 17
          Caption = '�� ��������� ���������� �������'
          TabOrder = 0
        end
        object chbxOtherConfirmations: TCheckBox
          Left = 10
          Top = 32
          Width = 257
          Height = 17
          Caption = '������ �������������'
          TabOrder = 2
        end
        object chbxFormConfirmations: TCheckBox
          Left = 275
          Top = 16
          Width = 270
          Height = 17
          Caption = '�� ��������� ����� �� ��� ���������������'
          TabOrder = 1
        end
      end
    end
  end
  object Button1: TButton
    Left = 410
    Top = 411
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 1
  end
  object Button2: TButton
    Left = 493
    Top = 411
    Width = 75
    Height = 21
    Action = actCancel
    Caption = '������'
    TabOrder = 2
  end
  object Button3: TButton
    Left = 4
    Top = 411
    Width = 75
    Height = 21
    Action = actHelp
    Caption = '�������'
    TabOrder = 3
  end
  object ActionList: TActionList
    Left = 520
    Top = 328
    object actOk: TAction
      Caption = '������'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'actCancel'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = 'actHelp'
      OnExecute = actHelpExecute
    end
    object actUsers: TAction
      Caption = '������������...'
      OnExecute = actUsersExecute
    end
    object actJournal: TAction
      Caption = '������...'
      OnExecute = actJournalExecute
    end
    object actPolDefault: TAction
      Caption = '�� ���������'
      OnExecute = actPolDefaultExecute
      OnUpdate = actPolDefaultUpdate
    end
    object actPolChange: TAction
      Caption = '��������...'
      OnExecute = actPolChangeExecute
      OnUpdate = actPolChangeUpdate
    end
    object actAddBlockGroup: TAction
      Caption = '��������...'
      OnExecute = actAddBlockGroupExecute
      OnUpdate = actAddBlockGroupUpdate
    end
    object actAddBlockDT: TAction
      Caption = '��������...'
      OnExecute = actAddBlockDTExecute
      OnUpdate = actAddBlockDTUpdate
    end
    object actClearRPLRecords: TAction
      Caption = '�������� ������� ���������� �������'
    end
    object actCreateDatabaseFile: TAction
      Caption = '������������ ���� �� ������� ���'
    end
    object actBlock: TAction
      Caption = '���������...'
      OnExecute = actBlockExecute
      OnUpdate = actBlockUpdate
    end
  end
end
