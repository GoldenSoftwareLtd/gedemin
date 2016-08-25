object gd_modify_main: Tgd_modify_main
  Left = 355
  Top = 376
  BorderStyle = bsDialog
  Caption = 'Модификация БД'
  ClientHeight = 297
  ClientWidth = 489
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 264
    Width = 489
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Panel3: TPanel
      Left = 366
      Top = 0
      Width = 123
      Height = 33
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnExecute: TButton
        Left = 7
        Top = 7
        Width = 111
        Height = 20
        Action = actModify
        Default = True
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 489
    Height = 264
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 489
      Height = 264
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Panel5: TPanel
        Left = 0
        Top = 33
        Width = 489
        Height = 231
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object mmLog: TMemo
          Left = 0
          Top = 0
          Width = 489
          Height = 231
          Align = alClient
          ReadOnly = True
          TabOrder = 0
        end
      end
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 489
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Button1: TButton
          Left = 464
          Top = 7
          Width = 20
          Height = 20
          Caption = '...'
          TabOrder = 0
          OnClick = Button1Click
        end
        object edDatabaseName: TEdit
          Left = 1
          Top = 7
          Width = 457
          Height = 21
          TabOrder = 1
          Text = 'server:k:\bases\gdbase.gdb'
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Interbase database|*.gdb;*.fdb|All|*.*'
    Left = 16
    Top = 72
  end
  object ActionList1: TActionList
    Left = 48
    Top = 72
    object actModify: TAction
      Caption = 'Модифицировать'
      OnExecute = actModifyExecute
      OnUpdate = actModifyUpdate
    end
  end
  object IBDatabase1: TIBDatabase
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251'
      'no_garbage_collect')
    LoginPrompt = False
    AllowStreamedConnected = False
    Left = 80
    Top = 72
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 112
    Top = 73
  end
end
