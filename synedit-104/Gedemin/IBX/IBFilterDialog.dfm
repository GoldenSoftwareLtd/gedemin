object frmIBFilterDialog: TfrmIBFilterDialog
  Left = 210
  Top = 206
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'IBX Filter Dialog'
  ClientHeight = 233
  ClientWidth = 437
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 27
    Height = 13
    Caption = 'Fields'
  end
  object pgeFields: TPageControl
    Left = 0
    Top = 16
    Width = 161
    Height = 213
    ActivePage = tabAll
    HotTrack = True
    TabOrder = 0
    TabPosition = tpBottom
    OnChanging = pgeFieldsChanging
    object tabAll: TTabSheet
      Caption = '&All'
      object lstAllFields: TListBox
        Left = 0
        Top = 0
        Width = 153
        Height = 185
        Align = alClient
        ItemHeight = 13
        Sorted = True
        TabOrder = 0
        OnClick = FieldsListBoxClick
      end
    end
    object tabSelected: TTabSheet
      Caption = '&Selected'
      ImageIndex = 1
      object lstSelectedFields: TListBox
        Left = 0
        Top = 0
        Width = 153
        Height = 185
        Align = alClient
        ItemHeight = 13
        Sorted = True
        TabOrder = 0
        OnClick = FieldsListBoxClick
      end
    end
  end
  object pgeCriteria: TPageControl
    Left = 168
    Top = 4
    Width = 189
    Height = 189
    ActivePage = tabByValue
    HotTrack = True
    TabOrder = 1
    TabPosition = tpBottom
    object tabByValue: TTabSheet
      Caption = 'By &Value'
      object Label2: TLabel
        Left = 4
        Top = 4
        Width = 52
        Height = 13
        Caption = '&Field Value'
        FocusControl = edtFieldValue
      end
      object edtFieldValue: TEdit
        Left = 4
        Top = 20
        Width = 121
        Height = 21
        TabOrder = 0
        OnChange = RefreshClearButtons
      end
      object btnClearFieldValue: TButton
        Left = 132
        Top = 20
        Width = 45
        Height = 21
        Caption = 'Clear'
        Enabled = False
        TabOrder = 1
        OnClick = btnClearFieldValueClick
      end
      object grpSearchType: TRadioGroup
        Left = 0
        Top = 44
        Width = 181
        Height = 77
        Caption = 'Search Type'
        ItemIndex = 0
        Items.Strings = (
          '&Exact Match'
          '&Partial Match at Beginning'
          'Par&tial Match at End'
          'Partial Match Any&where')
        TabOrder = 2
      end
      object Panel1: TPanel
        Left = 0
        Top = 121
        Width = 181
        Height = 39
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 3
        object cbxCaseSensitive: TCheckBox
          Left = 8
          Top = 4
          Width = 97
          Height = 17
          Caption = 'Case Sensi&tive'
          TabOrder = 0
        end
        object cbxNonMatching: TCheckBox
          Left = 8
          Top = 20
          Width = 153
          Height = 17
          Caption = 'N&on-matching Records'
          TabOrder = 1
        end
      end
    end
    object tabByRange: TTabSheet
      Caption = 'By &Range'
      ImageIndex = 1
      object Label3: TLabel
        Left = 8
        Top = 12
        Width = 71
        Height = 13
        Caption = 'S&tarting Range'
        FocusControl = edtStartingRange
      end
      object Label4: TLabel
        Left = 8
        Top = 52
        Width = 68
        Height = 13
        Caption = 'En&ding Range'
        FocusControl = edtEndingRange
      end
      object edtStartingRange: TEdit
        Left = 8
        Top = 28
        Width = 121
        Height = 21
        TabOrder = 0
        OnChange = RefreshClearButtons
      end
      object edtEndingRange: TEdit
        Left = 8
        Top = 68
        Width = 121
        Height = 21
        TabOrder = 1
        OnChange = RefreshClearButtons
      end
      object btnClearStartingRange: TButton
        Left = 132
        Top = 28
        Width = 45
        Height = 21
        Caption = 'Clear'
        Enabled = False
        TabOrder = 2
        OnClick = btnClearStartingRangeClick
      end
      object btnClearEndingRange: TButton
        Left = 132
        Top = 68
        Width = 45
        Height = 21
        Caption = 'Clear'
        Enabled = False
        TabOrder = 3
        OnClick = btnClearEndingRangeClick
      end
    end
  end
  object btnOk: TBitBtn
    Left = 360
    Top = 17
    Width = 75
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = '&OK      '
    ParentBiDiMode = False
    TabOrder = 2
    OnClick = btnOkClick
    Kind = bkOK
  end
  object btnCancel: TBitBtn
    Left = 360
    Top = 53
    Width = 75
    Height = 25
    TabOrder = 3
    OnClick = btnCancelClick
    Kind = bkCancel
  end
  object btnViewSummary: TButton
    Left = 172
    Top = 204
    Width = 85
    Height = 25
    Caption = 'View Su&mmary'
    Enabled = False
    TabOrder = 4
    OnClick = btnViewSummaryClick
  end
  object btnNewSearch: TButton
    Left = 272
    Top = 204
    Width = 85
    Height = 25
    Caption = '&New Search'
    Enabled = False
    TabOrder = 5
    OnClick = btnNewSearchClick
  end
end
