object frmDeleteProp_MainForm: TfrmDeleteProp_MainForm
  Left = 275
  Top = 142
  BorderStyle = bsDialog
  Caption = 'Delphi DFM Property remover'
  ClientHeight = 343
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 168
    Width = 32
    Height = 13
    Caption = 'Folder:'
  end
  object Label2: TLabel
    Left = 8
    Top = 232
    Width = 168
    Height = 13
    Caption = 'Names of properties to be removed:'
  end
  object Shape1: TShape
    Left = 416
    Top = 312
    Width = 41
    Height = 9
    Pen.Style = psClear
  end
  object Shape2: TShape
    Left = 416
    Top = 320
    Width = 41
    Height = 9
    Brush.Color = clRed
    Pen.Color = clRed
    Pen.Style = psClear
  end
  object Shape3: TShape
    Left = 416
    Top = 328
    Width = 41
    Height = 9
    Pen.Style = psClear
  end
  object edPath: TEdit
    Left = 8
    Top = 184
    Width = 449
    Height = 21
    TabOrder = 0
    Text = 'c:\my project'
  end
  object mPropList: TMemo
    Left = 8
    Top = 248
    Width = 369
    Height = 89
    Lines.Strings = (
      'PropertyName1'
      'PropertyName2'
      '...'
      'PropertyNameN')
    TabOrder = 2
  end
  object Button2: TButton
    Left = 384
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 3
    OnClick = Button2Click
  end
  object chbxSubFolders: TCheckBox
    Left = 8
    Top = 208
    Width = 129
    Height = 17
    Caption = 'Scan subdirectories'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 449
    Height = 155
    Color = 13427942
    Lines.Strings = (
      
        'Some times you need to delete one or more properties from Delphi' +
        ' DFM files.'
      'Not an easy task if your project consists of hundreds of them.'
      ''
      
        'This utility allows you to do such work fast and easy. Just spec' +
        'ify folder name, check'
      
        'whether you want to process subfolders, and enter list of proper' +
        'ties to be removed.'
      'Then, click Start button.'
      ''
      
        'For every changed file utility will create backup copy in the sa' +
        'me folder.'
      ''
      
        'Have some questions or suggestions? Feel free to ask: andreik@gs' +
        'belarus.com'
      
        'Andrei Kireev (Golden Software of Belarus). http://gsbelarus.com' +
        '. '
      ' '
      ' ')
    ReadOnly = True
    TabOrder = 5
  end
  object Button1: TButton
    Left = 384
    Top = 280
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Close'
    Default = True
    TabOrder = 4
    OnClick = Button1Click
  end
end
