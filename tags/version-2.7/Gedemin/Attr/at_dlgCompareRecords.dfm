object dlgCompareRecords: TdlgCompareRecords
  Left = 424
  Top = 228
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Сравнение записей'
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
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 507
    Height = 384
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object Label1: TLabel
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
    object Label2: TLabel
      Left = 8
      Top = 45
      Width = 79
      Height = 13
      Caption = 'Наименование:'
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
    object Label3: TLabel
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
    object Label4: TLabel
      Left = 8
      Top = 9
      Width = 470
      Height = 13
      Caption = 
        'Загружаемый объект уже существует в базе. Выберите значения резу' +
        'льтирующей записи. '
      WordWrap = True
    end
    object sgMain: TStringGrid
      Left = 4
      Top = 82
      Width = 499
      Height = 298
      Align = alBottom
      ColCount = 3
      DefaultRowHeight = 18
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
      TabOrder = 1
      OnDrawCell = sgMainDrawCell
      OnMouseDown = sgMainMouseDown
      RowHeights = (
        18
        18
        18
        18
        18)
    end
    object cbShowOnlyDiff: TCheckBox
      Left = 268
      Top = 61
      Width = 233
      Height = 17
      Action = actShowOnlyDiff
      State = cbChecked
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 384
    Width = 507
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 339
      Top = 3
      Width = 75
      Height = 21
      Caption = 'Применить'
      Default = True
      TabOrder = 0
      OnClick = actOKExecute
    end
    object Button1: TButton
      Left = 422
      Top = 3
      Width = 75
      Height = 21
      Caption = 'Отмена'
      TabOrder = 1
      OnClick = actCancelExecute
    end
  end
  object ActionList1: TActionList
    Left = 248
    Top = 24
    object actShowOnlyDiff: TAction
      Caption = 'Показывать только отличающиеся поля'
      Checked = True
      OnExecute = actShowOnlyDiffExecute
    end
    object actOK: TAction
      Caption = 'Применить'
      OnExecute = actOKExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
end
