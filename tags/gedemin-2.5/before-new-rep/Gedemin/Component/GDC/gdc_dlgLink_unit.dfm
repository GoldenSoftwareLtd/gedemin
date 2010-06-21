inherited gdc_dlgLink: Tgdc_dlgLink
  Left = 286
  Top = 274
  Caption = 'gdc_dlgLink'
  ClientHeight = 289
  ClientWidth = 432
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 262
  end
  inherited btnNew: TButton
    Top = 262
  end
  inherited btnOK: TButton
    Top = 262
  end
  inherited btnCancel: TButton
    Top = 262
  end
  inherited btnHelp: TButton
    Top = 262
  end
  inherited pgcMain: TPageControl
    Height = 248
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 8
        Top = 32
        Width = 132
        Height = 13
        Caption = 'Идентификатор объекта:'
      end
      object Label2: TLabel
        Left = 8
        Top = 56
        Width = 218
        Height = 13
        Caption = 'Идентификатор прикрепленного объекта:'
      end
      object Label3: TLabel
        Left = 8
        Top = 80
        Width = 165
        Height = 13
        Caption = 'Класс прикрепленного объекта:'
      end
      object Label4: TLabel
        Left = 8
        Top = 104
        Width = 174
        Height = 13
        Caption = 'Подтип прикрепленного объекта:'
      end
      object Label5: TLabel
        Left = 8
        Top = 128
        Width = 209
        Height = 13
        Caption = 'Наименование прикрепленного объекта:'
      end
      object Label6: TLabel
        Left = 8
        Top = 152
        Width = 225
        Height = 13
        Caption = 'Пользовательский тип прикрепленного об.:'
      end
      object Label7: TLabel
        Left = 8
        Top = 176
        Width = 206
        Height = 13
        Caption = 'Порядковый номер прикрепленного об.:'
      end
      object DBEdit1: TDBEdit
        Left = 240
        Top = 24
        Width = 169
        Height = 21
        DataField = 'objectkey'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object DBEdit2: TDBEdit
        Left = 240
        Top = 48
        Width = 169
        Height = 21
        DataField = 'linkedkey'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object DBEdit3: TDBEdit
        Left = 240
        Top = 72
        Width = 169
        Height = 21
        DataField = 'linkedclass'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object DBEdit4: TDBEdit
        Left = 240
        Top = 97
        Width = 169
        Height = 21
        DataField = 'linkedsubtype'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object DBEdit5: TDBEdit
        Left = 240
        Top = 121
        Width = 169
        Height = 21
        DataField = 'linkedname'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object DBEdit6: TDBEdit
        Left = 240
        Top = 145
        Width = 169
        Height = 21
        DataField = 'linkedusertype'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object DBEdit7: TDBEdit
        Left = 240
        Top = 169
        Width = 169
        Height = 21
        DataField = 'linkedorder'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object Button1: TButton
        Left = 240
        Top = 195
        Width = 169
        Height = 21
        Action = actOpenLinkedObject
        TabOrder = 7
      end
    end
  end
  inherited alBase: TActionList
    Left = 294
    Top = 175
    object actOpenLinkedObject: TAction
      Caption = 'Открыть прикрепленный об.'
      OnExecute = actOpenLinkedObjectExecute
      OnUpdate = actOpenLinkedObjectUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 336
    Top = 127
  end
  inherited pm_dlgG: TPopupMenu
    Left = 344
    Top = 184
  end
  inherited ibtrCommon: TIBTransaction
    Left = 184
    Top = 192
  end
end
