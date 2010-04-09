object frmPeriod: TfrmPeriod
  Left = 304
  Top = 223
  Width = 513
  Height = 403
  HelpContext = 18
  BorderWidth = 5
  Caption = 'Параметры расчета'
  Color = clBtnFace
  Constraints.MinHeight = 150
  Constraints.MinWidth = 290
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 495
    Height = 336
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pcSelDate: TPageControl
      Left = 0
      Top = 0
      Width = 495
      Height = 336
      ActivePage = tsMonth
      Align = alClient
      TabOrder = 0
      OnChange = pcSelDateChange
      object tsMonth: TTabSheet
        BorderWidth = 3
        Caption = 'За месяц'
        object Panel1: TPanel
          Left = 0
          Top = 26
          Width = 481
          Height = 276
          Align = alClient
          BevelOuter = bvLowered
          FullRepaint = False
          TabOrder = 0
          object GridMonth: TgsIBGrid
            Left = 1
            Top = 1
            Width = 479
            Height = 274
            Align = alClient
            BorderStyle = bsNone
            DataSource = dsTaxName
            Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
            PopupMenu = pmPeriod
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.FieldName = 'Id'
            CheckBox.Visible = True
            CheckBox.FirstColumn = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
            ShowTotals = False
          end
        end
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 481
          Height = 26
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblM1: TLabel
            Left = 2
            Top = 5
            Width = 36
            Height = 13
            Caption = 'Месяц:'
          end
          object lblY1: TLabel
            Left = 164
            Top = 5
            Width = 21
            Height = 13
            Caption = 'Год:'
          end
          object cbMonth: TComboBox
            Left = 55
            Top = 1
            Width = 101
            Height = 21
            DropDownCount = 12
            ItemHeight = 13
            TabOrder = 0
          end
          object spMYear: TSpinEdit
            Left = 191
            Top = 0
            Width = 65
            Height = 22
            MaxValue = 2030
            MinValue = 1990
            TabOrder = 1
            Value = 2003
          end
        end
      end
      object tsQuarter: TTabSheet
        BorderWidth = 3
        Caption = 'За квартал'
        ImageIndex = 1
        object Panel2: TPanel
          Left = 0
          Top = 26
          Width = 481
          Height = 276
          Align = alClient
          BevelOuter = bvLowered
          FullRepaint = False
          TabOrder = 0
          object GridQuarter: TgsIBGrid
            Left = 1
            Top = 1
            Width = 479
            Height = 274
            Align = alClient
            BorderStyle = bsNone
            DataSource = dsTaxName
            Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.FieldName = 'Id'
            CheckBox.Visible = True
            CheckBox.FirstColumn = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
            ShowTotals = False
          end
        end
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 481
          Height = 26
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblQuart: TLabel
            Left = 2
            Top = 5
            Width = 45
            Height = 13
            Caption = 'Квартал:'
          end
          object lnlY2: TLabel
            Left = 164
            Top = 5
            Width = 21
            Height = 13
            Caption = 'Год:'
          end
          object cbQuarter: TComboBox
            Left = 55
            Top = 1
            Width = 101
            Height = 21
            ItemHeight = 13
            TabOrder = 0
            Items.Strings = (
              'I.   Первый      '
              'II.  Второй       '
              'III. Третий       '
              'IV. Четвертый')
          end
          object spQYear: TSpinEdit
            Left = 191
            Top = 0
            Width = 65
            Height = 22
            MaxValue = 2030
            MinValue = 1990
            TabOrder = 1
            Value = 2003
          end
        end
      end
      object tsArbitrary: TTabSheet
        BorderWidth = 3
        Caption = 'За период'
        ImageIndex = 2
        object Panel3: TPanel
          Left = 0
          Top = 26
          Width = 481
          Height = 276
          Align = alClient
          BevelOuter = bvLowered
          FullRepaint = False
          TabOrder = 0
          object GridPeriod: TgsIBGrid
            Left = 1
            Top = 1
            Width = 479
            Height = 274
            Align = alClient
            BorderStyle = bsNone
            DataSource = dsTaxName
            Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
            ReadOnly = True
            TabOrder = 0
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.FieldName = 'Id'
            CheckBox.Visible = True
            CheckBox.FirstColumn = True
            MinColWidth = 40
            ColumnEditors = <>
            Aliases = <>
            ShowTotals = False
          end
        end
        object Panel6: TPanel
          Left = 0
          Top = 0
          Width = 481
          Height = 26
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblEndPeriod: TLabel
            Left = 124
            Top = 5
            Width = 58
            Height = 13
            Caption = 'Окончание:'
          end
          object lblBeginPeriod: TLabel
            Left = 2
            Top = 5
            Width = 40
            Height = 13
            Caption = 'Начало:'
          end
          object xdeEPeriod: TxDateEdit
            Left = 191
            Top = 1
            Width = 65
            Height = 21
            Kind = kDate
            EditMask = '!99\.99\.9999;1;_'
            MaxLength = 10
            TabOrder = 0
            Text = '  .  .    '
          end
          object xdeBPeriod: TxDateEdit
            Left = 49
            Top = 1
            Width = 65
            Height = 21
            Kind = kDate
            EditMask = '!99\.99\.9999;1;_'
            MaxLength = 10
            TabOrder = 1
            Text = '  .  .    '
          end
        end
      end
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 336
    Width = 495
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 340
      Top = 9
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 420
      Top = 9
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
    object Button1: TButton
      Left = 1
      Top = 9
      Width = 75
      Height = 21
      Action = actHelp
      TabOrder = 2
    end
  end
  object dsTaxName: TDataSource
    DataSet = gdcTaxName
    Left = 104
    Top = 64
  end
  object gdcTaxName: TgdcTaxName
    OnGetOrderClause = gdcTaxNameGetOrderClause
    Left = 136
    Top = 64
  end
  object pmPeriod: TPopupMenu
    Left = 72
    Top = 64
    object N1: TMenuItem
      Action = actSelectAll
    end
    object N2: TMenuItem
      Action = actDiscardSelect
    end
  end
  object alPeriod: TActionList
    Left = 32
    Top = 64
    object actSelectAll: TAction
      Caption = 'Выделить все'
      OnExecute = actSelectAllExecute
    end
    object actDiscardSelect: TAction
      Caption = 'Сбросить выделение'
      OnExecute = actDiscardSelectExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
  end
end
