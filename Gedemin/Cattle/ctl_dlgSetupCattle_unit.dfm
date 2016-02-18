object ctl_dlgSetupCattle: Tctl_dlgSetupCattle
  Left = 243
  Top = 178
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Настройка учета скота (мяса)'
  ClientHeight = 204
  ClientWidth = 402
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 9
    Width = 118
    Height = 27
    AutoSize = False
    Caption = 'Ветка учета скота в справочнике товаров:'
    WordWrap = True
  end
  object lblCattleBranch: TLabel
    Left = 130
    Top = 16
    Width = 71
    Height = 13
    Caption = 'lblCattleBranch'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 10
    Top = 49
    Width = 291
    Height = 27
    AutoSize = False
    Caption = 
      'Настройка полей прайс-листа, настройка показателей других справо' +
      'чников:'
    WordWrap = True
  end
  object Label3: TLabel
    Left = 10
    Top = 89
    Width = 291
    Height = 27
    AutoSize = False
    Caption = 'Настройка формул расчета показателей приемной квитанции:'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 10
    Top = 159
    Width = 384
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object lbTariff: TLabel
    Left = 10
    Top = 130
    Width = 108
    Height = 13
    Caption = 'Транспортный тариф'
  end
  object btnClose: TButton
    Left = 314
    Top = 175
    Width = 79
    Height = 21
    Action = actClose
    Anchors = [akRight, akBottom]
    ModalResult = 1
    TabOrder = 0
  end
  object Button1: TButton
    Left = 314
    Top = 12
    Width = 79
    Height = 21
    Action = actBranch
    Anchors = [akTop, akRight]
    TabOrder = 1
  end
  object Button2: TButton
    Left = 314
    Top = 52
    Width = 79
    Height = 21
    Action = actFields
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object Button3: TButton
    Left = 314
    Top = 92
    Width = 79
    Height = 21
    Action = actReceiptFormula
    Anchors = [akTop, akRight]
    TabOrder = 3
  end
  object edTariff: TEdit
    Left = 315
    Top = 130
    Width = 81
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 4
  end
  object ActionList1: TActionList
    Left = 140
    Top = 140
    object actClose: TAction
      Caption = 'Закрыть'
      OnExecute = actCloseExecute
    end
    object actBranch: TAction
      Caption = 'Изменить'
      OnExecute = actBranchExecute
    end
    object actFields: TAction
      Caption = 'Изменить'
      OnExecute = actFieldsExecute
    end
    object actReceiptFormula: TAction
      Caption = 'Изменить'
      OnExecute = actReceiptFormulaExecute
    end
  end
  object ibsqlBranch: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  NAME'
      ''
      'FROM'
      '  GD_GOODGROUP'
      ''
      'WHERE'
      '  ID = :ID')
    Transaction = ibtrSetup
    Left = 110
    Top = 140
  end
  object ibtrSetup: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 80
    Top = 140
  end
end
