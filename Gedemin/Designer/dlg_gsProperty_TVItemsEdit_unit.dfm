object dlgPropertyTVItemsEdit: TdlgPropertyTVItemsEdit
  Left = 341
  Top = 236
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'TreeView Items Editor'
  ClientHeight = 178
  ClientWidth = 494
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object gbItems: TGroupBox
    Left = 8
    Top = 4
    Width = 289
    Height = 141
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Items'
    TabOrder = 0
    object tvShow: TTreeView
      Left = 8
      Top = 16
      Width = 169
      Height = 113
      Anchors = [akLeft, akTop, akRight]
      DragMode = dmAutomatic
      Indent = 19
      TabOrder = 0
      OnChange = tvShowChange
      OnDragDrop = tvShowDragDrop
    end
    object btnNewItem: TBitBtn
      Left = 184
      Top = 16
      Width = 89
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'New Item'
      TabOrder = 1
      OnClick = btnNewItemClick
    end
    object btnNewSubItem: TBitBtn
      Left = 184
      Top = 46
      Width = 89
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'New SubItem'
      TabOrder = 2
      OnClick = btnNewSubItemClick
    end
    object btnDelete: TBitBtn
      Left = 184
      Top = 75
      Width = 89
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Delete'
      TabOrder = 3
      OnClick = btnDeleteClick
    end
  end
  object OKButton: TButton
    Left = 255
    Top = 152
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object CancelButton: TButton
    Left = 335
    Top = 152
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'О&тмена'
    ModalResult = 2
    TabOrder = 2
  end
  object HelpButton: TButton
    Left = 414
    Top = 152
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Помощь'
    TabOrder = 3
    OnClick = HelpButtonClick
  end
  object gbItemProperties: TGroupBox
    Left = 304
    Top = 4
    Width = 185
    Height = 141
    Anchors = [akTop, akRight]
    Caption = 'Item Properties'
    TabOrder = 4
    object Label1: TLabel
      Left = 6
      Top = 19
      Width = 21
      Height = 13
      Caption = 'Text'
    end
    object Label2: TLabel
      Left = 6
      Top = 51
      Width = 58
      Height = 13
      Caption = 'Image Index'
    end
    object Label3: TLabel
      Left = 6
      Top = 83
      Width = 71
      Height = 13
      Caption = 'Selected Index'
    end
    object Label4: TLabel
      Left = 6
      Top = 115
      Width = 54
      Height = 13
      Caption = 'State Index'
    end
    object edtText: TEdit
      Left = 80
      Top = 16
      Width = 97
      Height = 21
      TabOrder = 0
      OnChange = edtTextChange
    end
    object edtImageIndex: TEdit
      Left = 80
      Top = 48
      Width = 54
      Height = 21
      TabOrder = 1
      OnExit = edtImageIndexExit
    end
    object edtSelectedIndex: TEdit
      Left = 80
      Top = 80
      Width = 54
      Height = 21
      TabOrder = 2
      OnExit = edtSelectedIndexExit
    end
    object edtStateIndex: TEdit
      Left = 80
      Top = 112
      Width = 54
      Height = 21
      TabOrder = 3
      OnExit = edtStateIndexExit
    end
  end
end
