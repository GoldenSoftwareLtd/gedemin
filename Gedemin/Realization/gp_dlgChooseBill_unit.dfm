object gp_dlgChooseBill: Tgp_dlgChooseBill
  Left = 87
  Top = 81
  Width = 696
  Height = 480
  Caption = 'Список счетов фактур на выдачу'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 28
    Width = 688
    Height = 425
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object gsibgrMain: TgsIBGrid
      Left = 5
      Top = 5
      Width = 678
      Height = 415
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsMain
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 0
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.DisplayField = 'NUMBER'
      CheckBox.FieldName = 'DOCUMENTKEY'
      CheckBox.Visible = True
      CheckBox.FirstColumn = False
      MinColWidth = 40
      ColumnEditors = <>
      Aliases = <>
    end
  end
  object cbMain: TControlBar
    Left = 0
    Top = 0
    Width = 688
    Height = 28
    Align = alTop
    AutoDock = False
    AutoSize = True
    BevelEdges = [beBottom]
    Color = clBtnFace
    DockSite = False
    ParentColor = False
    TabOrder = 1
    object tbMain: TToolBar
      Left = 11
      Top = 2
      Width = 86
      Height = 22
      AutoSize = True
      EdgeBorders = []
      Flat = True
      Images = dmImages.ilToolBarSmall
      TabOrder = 0
      object tbtNew: TToolButton
        Left = 0
        Top = 0
        Hint = 'Установить фильтр'
        DropdownMenu = pmFilter
        ImageIndex = 4
        ParentShowHint = False
        ShowHint = True
      end
      object ToolButton1: TToolButton
        Left = 23
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object ToolButton2: TToolButton
        Left = 31
        Top = 0
        Hint = 'Закрыть окно и перенести с\ф'
        Action = actOk
      end
      object ToolButton3: TToolButton
        Left = 54
        Top = 0
        Hint = 'Закрыть окно без выбора с\ф'
        Action = actCancel
      end
    end
  end
  object pmFilter: TPopupMenu
    Left = 136
    Top = 124
  end
  object ibdsMain: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_document'
      'where   id = :OLD_DOCUMENTKEY')
    RefreshSQL.Strings = (
      'SELECT '
      '  doc.number,'
      '  doc.documentdate,'
      '  docr.documentkey,'
      '  docr.transsumncu,'
      '  docr.transsumcurr,'
      '  doc.currkey,'
      '  docr.tocontactkey,'
      '  docr.fromcontactkey,'
      '  docr.rate,'
      '  docr.fromdocumentkey,'
      '  toc.name,'
      '  toc.phone,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_docrealization docr'
      'JOIN'
      '  gd_document doc ON doc.id = docr.documentkey '
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT '
      '  doc.number,'
      '  doc.documentdate,'
      '  docr.documentkey,'
      '  toc.name,'
      '  toc.city,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_docrealization docr'
      'JOIN'
      '  gd_document doc ON doc.id = docr.documentkey and'
      '  doc.documenttypekey = :dt'
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      'WHERE'
      '  doc.companykey = :ck AND'
      '  docr.ispermit = 1 AND'
      '  docr.documentkey IN '
      
        '  (SELECT docp.documentkey FROM gd_docrealpos docp JOIN gd_docum' +
        'ent doc ON docp.documentkey = doc.id and '
      'doc.documenttypekey = :dt'
      'WHERE docp.quantity > docp.performquantity)'
      '  '
      '  ')
    ModifySQL.Strings = (
      'update gd_docrealization'
      'set'
      '  ISPERMIT = :ISPERMIT'
      'where'
      '  documentkey = :OLD_DOCUMENTKEY')
    Left = 288
    Top = 80
  end
  object dsMain: TDataSource
    DataSet = ibdsMain
    Left = 320
    Top = 80
  end
  object gsqfChooseBill: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    IBDataSet = ibdsMain
    Left = 448
    Top = 80
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 344
    Top = 124
  end
  object ActionList1: TActionList
    Images = dmImages.ilToolBarSmall
    Left = 296
    Top = 228
    object actOk: TAction
      Caption = 'actOk'
      ImageIndex = 15
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ImageIndex = 16
      OnExecute = actCancelExecute
    end
  end
end
