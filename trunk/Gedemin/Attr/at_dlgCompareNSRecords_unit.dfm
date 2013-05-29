object dlgCompareNSRecords: TdlgCompareNSRecords
  Left = 541
  Top = 213
  BorderStyle = bsDialog
  Caption = 'dlgCompareNSRecords'
  ClientHeight = 416
  ClientWidth = 507
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 507
    Height = 416
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lCaption: TLabel
      Left = 16
      Top = 16
      Width = 3
      Height = 13
    end
    object lTitle: TLabel
      Left = 8
      Top = 9
      Width = 500
      Height = 13
      Caption = 
        'Загружаемый объект уже существует в базе. Выберите значения резу' +
        'льтирующей записи. '
      WordWrap = True
    end
    object lObjClass: TLabel
      Left = 8
      Top = 27
      Width = 67
      Height = 13
      Caption = 'Тип объекта:'
    end
    object lblClassName: TLabel
      Left = 93
      Top = 27
      Width = 76
      Height = 13
      Caption = 'lblClassName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblName: TLabel
      Left = 93
      Top = 45
      Width = 46
      Height = 13
      Caption = 'lblName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lObjName: TLabel
      Left = 8
      Top = 45
      Width = 79
      Height = 13
      Caption = 'Наименование:'
    end
    object lObjID: TLabel
      Left = 8
      Top = 63
      Width = 20
      Height = 13
      Caption = 'ИД:'
    end
    object lblID: TLabel
      Left = 93
      Top = 63
      Width = 27
      Height = 13
      Caption = 'lblID'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object sgMain: TStringGrid
      Left = 0
      Top = 84
      Width = 507
      Height = 291
      Align = alBottom
      ColCount = 3
      DefaultRowHeight = 18
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
      ParentFont = False
      TabOrder = 0
      OnDrawCell = sgMainDrawCell
      OnMouseDown = sgMainMouseDown
      RowHeights = (
        18
        18
        18
        18
        18)
    end
    object Panel2: TPanel
      Left = 0
      Top = 375
      Width = 507
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object btnOK: TButton
        Left = 336
        Top = 8
        Width = 75
        Height = 25
        Action = actOK
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 424
        Top = 8
        Width = 75
        Height = 25
        Action = actCancel
        TabOrder = 1
      end
    end
    object cbShowOnlyDiff: TCheckBox
      Left = 260
      Top = 61
      Width = 233
      Height = 17
      Action = actShowOnlyDiff
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object actList: TActionList
    Left = 320
    Top = 184
    object actOK: TAction
      Caption = 'Применить'
      OnExecute = actOKExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actShowOnlyDiff: TAction
      Caption = 'Показывать только отличающиеся поля'
      OnExecute = ActShowOnlyDiffExecute
    end
  end
end
