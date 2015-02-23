object dlgShowPrint: TdlgShowPrint
  Left = 515
  Top = 204
  Width = 600
  Height = 450
  Caption = 'dlgShowPrint'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pc: TPageControl
    Left = 97
    Top = 0
    Width = 439
    Height = 350
    ActivePage = TabSheet1
    Anchors = [akTop, akRight]
    MultiLine = True
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      TabVisible = False
      object stName: TStaticText
        Left = 22
        Top = 22
        Width = 83
        Height = 17
        Caption = 'Наименование:'
        Color = clBtnFace
        FocusControl = dbedName
        ParentColor = False
        TabOrder = 0
      end
      object dbedName: TDBEdit
        Left = 104
        Top = 20
        Width = 209
        Height = 21
        DataField = 'P_NAME'
        DataSource = boDataSource1
        TabOrder = 1
      end
      object StaticText3: TStaticText
        Left = 22
        Top = 59
        Width = 49
        Height = 17
        Caption = 'Логотип:'
        Color = clBtnFace
        FocusControl = dbedName
        ParentColor = False
        TabOrder = 2
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      TabVisible = False
    end
    object TabSheet3: TTabSheet
      Caption = 'TabSheet3'
      ImageIndex = 2
      TabVisible = False
    end
    object TabSheet4: TTabSheet
      Caption = 'TabSheet4'
      ImageIndex = 3
      TabVisible = False
    end
  end
  object mBitButton1: TmBitButton
    Left = 468
    Top = 364
    Width = 71
    Height = 20
    Caption = 'Cancel'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
  end
  object mBitButton2: TmBitButton
    Left = 394
    Top = 364
    Width = 70
    Height = 20
    Caption = 'Ok'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 2
  end
  object mBitButton3: TmBitButton
    Left = 227
    Top = 364
    Width = 70
    Height = 20
    Caption = '<< Back'
    Action = actPrev
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 3
  end
  object mBitButton4: TmBitButton
    Left = 301
    Top = 364
    Width = 70
    Height = 20
    Caption = 'Next >>'
    Action = actNext
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 4
  end
  object ActionList: TActionList
    Left = 64
    Top = 264
    object actNext: TAction
      Caption = 'Next >>'
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actPrev: TAction
      Caption = '<< Back'
      OnExecute = actPrevExecute
      OnUpdate = actPrevUpdate
    end
  end
  object Query1: TQuery
    DatabaseName = 'xxx'
    SQL.Strings = (
      'SELECT p.id AS P_ID, p.name AS P_NAME, c.id as c_id,'
      '       c.name AS C_NAME '
      '     FROM '
      
        '       rdz_print p LEFT JOIN cst_customer c ON p.customerkey = c' +
        '.customerkey '
      '     WHERE '
      '       p.id = :Id')
    UpdateObject = UpdateSQL1
    Left = 28
    Top = 366
    ParamData = <
      item
        DataType = ftInteger
        Name = 'Id'
        ParamType = ptUnknown
      end>
  end
  object UpdateSQL1: TUpdateSQL
    ModifySQL.Strings = (
      'update rdz_print'
      'set'
      '  name = :P_NAME,'
      '  cutomerkey = :C_ID'
      'where'
      '  id  = :OLD_P_ID;')
    InsertSQL.Strings = (
      'insert into rdz_print'
      '  (P_NAME, C_ID, C_NAME)'
      'values'
      '  (:P_NAME, :C_ID, :C_NAME)')
    DeleteSQL.Strings = (
      'delete from rdz_print'
      'where'
      '  P_ID = :OLD_P_ID')
    Left = 72
    Top = 366
  end
  object boDataSource1: TboDataSource
    Left = 228
    Top = 134
  end
  object boIcon1: TboIcon
    DataBaseName = 'xxx'
    ID = -1
    Kind = 0
    Context = 0
    LinkFieldName = 'icon'
    Left = 156
    Top = 198
  end
end
