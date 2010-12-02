object dlgViewReportServer: TdlgViewReportServer
  Left = 297
  Top = 218
  Width = 343
  Height = 267
  BorderIcons = [biSystemMenu]
  Caption = 'Сервера отчетов'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object lvReportServer: TListView
    Left = 0
    Top = 0
    Width = 335
    Height = 234
    Align = alClient
    Columns = <
      item
        Caption = 'Наименование'
        Width = 406
      end>
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = actServerParamExecute
  end
  object btnOK: TButton
    Left = 217
    Top = 256
    Width = 92
    Height = 31
    Caption = 'OK'
    Default = True
    TabOrder = 1
    Visible = False
  end
  object btnCancel: TButton
    Left = 315
    Top = 256
    Width = 92
    Height = 31
    Cancel = True
    Caption = 'Отмена'
    TabOrder = 2
    Visible = False
  end
  object ibtrServer: TIBTransaction
    Active = False
    DefaultDatabase = ibdbGAdmin
    AutoStopAction = saNone
    Left = 40
    Top = 208
  end
  object ActionList1: TActionList
    Left = 72
    Top = 208
    object actServerParam: TAction
      Caption = 'Параметры сервера отчетов'
      OnExecute = actServerParamExecute
    end
    object actDeleteServer: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteServerExecute
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 144
    Top = 88
    object actServerParam1: TMenuItem
      Action = actServerParam
    end
    object N1: TMenuItem
      Action = actDeleteServer
    end
  end
  object ibdsServer: TIBDataSet
    Database = ibdbGAdmin
    Transaction = ibtrServer
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from rp_reportserver'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into rp_reportserver'
      
        '  (ID, COMPUTERNAME, RESULTPATH, STARTTIME, ENDTIME, FRQDATAREAD' +
        ', '
      'ACTUALREPORT, '
      '   UNACTUALREPORT, IBPARAMS, LOCALSTORAGE, USEDORDER, '
      'SERVERPORT, RESERVED)'
      'values'
      '  (:ID, :COMPUTERNAME, :RESULTPATH, :STARTTIME, :ENDTIME, '
      ':FRQDATAREAD, '
      '   :ACTUALREPORT, :UNACTUALREPORT, :IBPARAMS, :LOCALSTORAGE, '
      ':USEDORDER, '
      '   :SERVERPORT, :RESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  *'
      'from rp_reportserver '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportserver')
    ModifySQL.Strings = (
      'update rp_reportserver'
      'set'
      '  ID = :ID,'
      '  COMPUTERNAME = :COMPUTERNAME,'
      '  RESULTPATH = :RESULTPATH,'
      '  STARTTIME = :STARTTIME,'
      '  ENDTIME = :ENDTIME,'
      '  FRQDATAREAD = :FRQDATAREAD,'
      '  ACTUALREPORT = :ACTUALREPORT,'
      '  UNACTUALREPORT = :UNACTUALREPORT,'
      '  IBPARAMS = :IBPARAMS,'
      '  LOCALSTORAGE = :LOCALSTORAGE,'
      '  USEDORDER = :USEDORDER,'
      '  SERVERPORT = :SERVERPORT,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 8
    Top = 208
  end
  object ibdbGAdmin: TIBDatabase
    DatabaseName = 'win2000server:K:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    AllowStreamedConnected = False
    Left = 8
    Top = 172
  end
end
