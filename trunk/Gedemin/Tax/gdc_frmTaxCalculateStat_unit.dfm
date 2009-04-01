object frmTaxCalculateStat: TfrmTaxCalculateStat
  Left = 366
  Top = 261
  BorderStyle = bsDialog
  Caption = 'Расчет отчетов бухгалтерии ...'
  ClientHeight = 156
  ClientWidth = 389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 5
    Top = 5
    Width = 378
    Height = 108
    TabOrder = 0
    object pnlTax: TPanel
      Left = 8
      Top = 8
      Width = 361
      Height = 25
      BevelOuter = bvLowered
      TabOrder = 0
      object lblTacName: TLabel
        Left = 8
        Top = 8
        Width = 65
        Height = 13
        AutoSize = False
        Caption = 'Бух. отчет :'
      end
      object lblTaxValue: TLabel
        Left = 349
        Top = 8
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
    end
    object pnlFunction: TPanel
      Left = 8
      Top = 72
      Width = 177
      Height = 25
      BevelOuter = bvLowered
      TabOrder = 1
      object lblFunction: TLabel
        Left = 8
        Top = 8
        Width = 49
        Height = 13
        Caption = 'Функция:'
      end
      object lblFNameValue: TLabel
        Left = 166
        Top = 8
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
    end
    object pnlDate: TPanel
      Left = 192
      Top = 40
      Width = 177
      Height = 25
      BevelOuter = bvLowered
      TabOrder = 2
      object lblDate: TLabel
        Left = 8
        Top = 8
        Width = 45
        Height = 13
        Caption = 'На дату: '
      end
      object lblOnDateValue: TLabel
        Left = 165
        Top = 8
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
    end
    object pnlStat: TPanel
      Left = 192
      Top = 72
      Width = 177
      Height = 25
      BevelOuter = bvLowered
      TabOrder = 3
      object lblStat: TLabel
        Left = 8
        Top = 8
        Width = 53
        Height = 13
        Caption = 'Действие:'
      end
      object lblActValue: TLabel
        Left = 165
        Top = 8
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
    end
    object pnlActualDate: TPanel
      Left = 8
      Top = 40
      Width = 177
      Height = 25
      BevelOuter = bvLowered
      TabOrder = 4
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 62
        Height = 13
        Caption = 'Дата ввода:'
      end
      object lblActualValue: TLabel
        Left = 166
        Top = 8
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
    end
  end
  object btnBreak: TButton
    Left = 159
    Top = 123
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Прервать'
    Default = True
    ModalResult = 2
    TabOrder = 1
    OnClick = btnBreakClick
  end
end
