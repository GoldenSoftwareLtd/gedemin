object gdc_frmStreamSaver: Tgdc_frmStreamSaver
  Left = 629
  Top = 192
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = '������ �������� ������'
  ClientHeight = 371
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 330
    Width = 506
    Height = 41
    Align = alBottom
    TabOrder = 1
    object btnClose: TButton
      Left = 408
      Top = 8
      Width = 85
      Height = 25
      Caption = '�������'
      TabOrder = 2
      OnClick = btnCloseClick
    end
    object btnNext: TButton
      Left = 279
      Top = 8
      Width = 110
      Height = 25
      Action = actNext
      Caption = '������ >'
      Default = True
      TabOrder = 1
    end
    object btnPrev: TButton
      Left = 193
      Top = 8
      Width = 85
      Height = 25
      Action = actPrev
      Caption = '< �����'
      TabOrder = 0
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 330
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 506
      Height = 41
      Align = alTop
      TabOrder = 0
      object lblFirst: TLabel
        Left = 17
        Top = 13
        Width = 111
        Height = 13
        Caption = '1. ��� ����������'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSecond: TLabel
        Left = 384
        Top = 13
        Width = 72
        Height = 13
        Caption = '2. ����������'
      end
    end
    object PageControl: TPageControl
      Left = 0
      Top = 41
      Width = 506
      Height = 289
      ActivePage = tbsProcess
      Align = alClient
      TabOrder = 1
      object tbsSave: TTabSheet
        Caption = 'tbsSave'
        TabVisible = False
        OnShow = tbsSaveShow
        object lblIncrementedHelp: TLabel
          Left = 8
          Top = 70
          Width = 481
          Height = 19
          AutoSize = False
          Caption = 
            '�� ������� �������� ���� ������ �� ������� ����� ���������� ����' +
            '������� ������:'
          WordWrap = True
        end
        object lblFileType: TLabel
          Left = 8
          Top = 22
          Width = 57
          Height = 13
          Caption = '��� �����:'
        end
        object lblIncremented: TLabel
          Left = 8
          Top = 46
          Width = 80
          Height = 13
          Caption = '������������:'
        end
        object pnlDatabases: TPanel
          Left = 0
          Top = 88
          Width = 498
          Height = 191
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
        end
        object cbStreamFormat: TComboBox
          Left = 116
          Top = 18
          Width = 364
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 1
          OnChange = cbStreamFormatChange
        end
        object cbIncremented: TCheckBox
          Left = 116
          Top = 45
          Width = 221
          Height = 17
          TabOrder = 2
          OnClick = cbIncrementedClick
        end
      end
      object tbsLoad: TTabSheet
        Caption = 'tbsLoad'
        ImageIndex = 1
        TabVisible = False
        OnShow = tbsLoadShow
        object lblFileName: TLabel
          Left = 8
          Top = 22
          Width = 60
          Height = 13
          Caption = '��� �����:'
        end
        object lblLoadingSourceBase: TLabel
          Left = 8
          Top = 94
          Width = 79
          Height = 13
          Caption = '�������� ����:'
        end
        object lblLoadingTargetBase: TLabel
          Left = 8
          Top = 118
          Width = 74
          Height = 13
          Caption = '������� ����:'
        end
        object lblLoadingFileTypeLabel: TLabel
          Left = 8
          Top = 46
          Width = 57
          Height = 13
          Caption = '��� �����:'
        end
        object lblLoadingFileType: TLabel
          Left = 116
          Top = 46
          Width = 3
          Height = 13
        end
        object lblLoadingIncremented: TLabel
          Left = 116
          Top = 70
          Width = 3
          Height = 13
        end
        object lblLoadingIncrementedLabel: TLabel
          Left = 8
          Top = 70
          Width = 80
          Height = 13
          Caption = '������������:'
        end
        object eFileName: TEdit
          Left = 116
          Top = 18
          Width = 364
          Height = 21
          AutoSize = False
          ReadOnly = True
          TabOrder = 0
        end
        object eLoadingSourceBase: TEdit
          Left = 116
          Top = 90
          Width = 222
          Height = 21
          AutoSize = False
          ReadOnly = True
          TabOrder = 1
        end
        object eLoadingTargetBase: TEdit
          Left = 116
          Top = 114
          Width = 222
          Height = 21
          AutoSize = False
          ReadOnly = True
          TabOrder = 2
        end
      end
      object tbsProcess: TTabSheet
        ImageIndex = 3
        TabVisible = False
        OnShow = tbsProcessShow
        object lblErrorMsg: TLabel
          Left = 0
          Top = 125
          Width = 497
          Height = 124
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Visible = False
          WordWrap = True
        end
        object lblProcessText: TLabel
          Left = 6
          Top = 105
          Width = 483
          Height = 39
          AutoSize = False
          Transparent = True
          WordWrap = True
        end
        object lblResult: TLabel
          Left = 0
          Top = 33
          Width = 497
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '����������...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblWasErrorMsg: TLabel
          Left = 0
          Top = 105
          Width = 497
          Height = 14
          Alignment = taCenter
          AutoSize = False
          Caption = '� �������� ������ �������� ������...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Visible = False
          WordWrap = True
        end
        object lblProgressMain: TLabel
          Left = 72
          Top = 87
          Width = 354
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '0 / 0'
        end
        object imgStatus: TImage
          Left = 336
          Top = 257
          Width = 16
          Height = 16
        end
        object btnShowLog: TButton
          Left = 355
          Top = 251
          Width = 134
          Height = 25
          Caption = '����������� ���-����'
          TabOrder = 0
          OnClick = btnShowLogClick
        end
        object pbMain: TProgressBar
          Left = 8
          Top = 62
          Width = 481
          Height = 17
          Min = 0
          Max = 10
          Smooth = True
          TabOrder = 1
        end
      end
      object tbsSetting: TTabSheet
        Caption = 'tbsSetting'
        ImageIndex = 4
        TabVisible = False
        OnShow = tbsSettingShow
        object lblSettingHint01: TLabel
          Left = 4
          Top = 70
          Width = 489
          Height = 26
          Caption = 
            '  ��� ����, ����� ��������� ������ ���� �������, � ������� �����' +
            '� �����������, ���������, ����� �� �������� � ���� ������, �����' +
            '����� ��������������.'
          Visible = False
          WordWrap = True
        end
        object lblSettingHint02: TLabel
          Left = 4
          Top = 102
          Width = 461
          Height = 26
          Caption = 
            '  ��� ����� ���������� ���������� �� ��� ������ � ������� ������' +
            '� �������������� �� ������ ������������.'
          Visible = False
          WordWrap = True
        end
        object lblSettingQuestion: TLabel
          Left = 10
          Top = 7
          Width = 475
          Height = 39
          AutoSize = False
          Caption = 'lblSettingQuestion'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Visible = False
          WordWrap = True
        end
        object lblSettingFormat: TLabel
          Left = 6
          Top = 126
          Width = 101
          Height = 13
          Caption = '������ ���������:'
          Visible = False
        end
        object cbMakeSetting: TCheckBox
          Left = 6
          Top = 90
          Width = 300
          Height = 17
          Caption = '������������ ��������� ����� �����������'
          Checked = True
          State = cbChecked
          TabOrder = 0
          Visible = False
          OnClick = cbMakeSettingClick
        end
        object cbSettingFormat: TComboBox
          Left = 116
          Top = 122
          Width = 222
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 1
          Visible = False
          OnChange = cbSettingFormatChange
        end
      end
    end
  end
  object alMain: TActionList
    Left = 208
    Top = 288
    object actNext: TAction
      Caption = '������'
      OnExecute = actNextExecute
    end
    object actPrev: TAction
      Caption = '�����'
      OnExecute = actPrevExecute
    end
  end
end
