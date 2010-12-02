object frmSaveAttachment: TfrmSaveAttachment
  Left = 294
  Top = 163
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsDialog
  Caption = 'Сохранение вложений'
  ClientHeight = 220
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 126
    Height = 13
    Caption = 'Сохраняемые вложения:'
  end
  object Label2: TLabel
    Left = 8
    Top = 168
    Width = 53
    Height = 13
    Caption = 'Сохранить'
  end
  object BtnSave: TButton
    Left = 280
    Top = 32
    Width = 81
    Height = 25
    Caption = 'Сохранить'
    TabOrder = 0
    OnClick = BtnSaveClick
  end
  object BtnCancel: TButton
    Left = 280
    Top = 64
    Width = 81
    Height = 25
    Caption = 'Отмена'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object BtnSelectAll: TButton
    Left = 280
    Top = 128
    Width = 81
    Height = 25
    Caption = 'Выделить все'
    TabOrder = 2
    OnClick = BtnSelectAllClick
  end
  object EditDirectory: TEdit
    Left = 8
    Top = 192
    Width = 265
    Height = 21
    TabOrder = 3
  end
  object BtnView: TButton
    Left = 280
    Top = 192
    Width = 81
    Height = 25
    Caption = 'Каталог'
    TabOrder = 4
    OnClick = BtnViewClick
  end
  object LstBxSaveAtt: TListBox
    Left = 8
    Top = 32
    Width = 265
    Height = 121
    ItemHeight = 13
    MultiSelect = True
    Sorted = True
    TabOrder = 5
  end
  object Panel1: TPanel
    Left = 72
    Top = 175
    Width = 201
    Height = 2
    BevelOuter = bvLowered
    TabOrder = 6
  end
  object msgSaveAttDataSource: TDataSource
    DataSet = gdcAttachmentSave
    Left = 152
    Top = 8
  end
  object gdcAttachmentSave: TgdcAttachment
    MasterSource = msgMessageDataSource
    MasterField = 'id'
    DetailField = 'messagekey'
    SubSet = 'ByMessage'
    Left = 208
    Top = 8
  end
  object msgMessageDataSource: TDataSource
    Left = 248
    Top = 8
  end
end
