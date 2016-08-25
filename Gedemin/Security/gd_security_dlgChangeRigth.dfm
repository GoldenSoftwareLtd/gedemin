object dlgChangeRight: TdlgChangeRight
  Left = 262
  Top = 127
  BorderStyle = bsDialog
  Caption = 'Изменение прав доступа к таблице'
  ClientHeight = 236
  ClientWidth = 308
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
    Left = 8
    Top = 8
    Width = 76
    Height = 13
    Caption = 'Наименование'
    Visible = False
  end
  object edName: TEdit
    Left = 96
    Top = 8
    Width = 209
    Height = 21
    Enabled = False
    TabOrder = 0
    Text = 'edName'
    Visible = False
  end
  object btnOk: TButton
    Left = 138
    Top = 208
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 226
    Top = 208
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object pcFull: TPageControl
    Left = 6
    Top = 0
    Width = 299
    Height = 204
    ActivePage = tsChag
    TabOrder = 3
    object tsFull: TTabSheet
      Caption = 'Полный'
      object clbFull: TCheckListBox
        Left = 0
        Top = 0
        Width = 291
        Height = 176
        OnClickCheck = clbFullClickCheck
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 0
      end
    end
    object tsChag: TTabSheet
      Caption = 'Изменение'
      ImageIndex = 1
      object clbChag: TCheckListBox
        Left = 0
        Top = 0
        Width = 291
        Height = 176
        OnClickCheck = clbChagClickCheck
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 0
      end
    end
    object tsView: TTabSheet
      Caption = 'Просмотр'
      ImageIndex = 2
      object clbView: TCheckListBox
        Left = 0
        Top = 0
        Width = 291
        Height = 176
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 0
      end
    end
  end
  object ActionList1: TActionList
    Left = 112
    Top = 8
    object actShow: TAction
      Caption = 'act'
      OnExecute = actShowExecute
    end
  end
  object ibqryWork: TIBQuery
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT * FROM gd_usergroup'
      '')
    Left = 146
    Top = 8
  end
end
