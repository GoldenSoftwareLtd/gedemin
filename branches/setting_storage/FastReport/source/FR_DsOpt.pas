
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Designer options             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DsOpt;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, FR_Combo;

type
  TfrDesOptionsForm = class(TForm)
    PageControl1: TPageControl;
    Tab1: TTabSheet;
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    RB6: TRadioButton;
    RB7: TRadioButton;
    RB8: TRadioButton;
    GroupBox4: TGroupBox;
    RB1: TRadioButton;
    RB2: TRadioButton;
    RB3: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    GroupBox5: TGroupBox;
    CB3: TCheckBox;
    CB4: TCheckBox;
    CB5: TCheckBox;
    GroupBox6: TGroupBox;
    RB9: TRadioButton;
    RB10: TRadioButton;
    RB11: TRadioButton;
    CB6: TCheckBox;
    Label1: TLabel;
    Tab2: TTabSheet;
    GroupBox7: TGroupBox;
    ERB1: TRadioButton;
    ERB2: TRadioButton;
    Label2: TLabel;
    TextFontNameCB: TfrFontComboBox;
    Label3: TLabel;
    TextFontSizeCB: TfrComboBox;
    SampleTextPanel: TPanel;
    GroupBox8: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    ScriptFontNameCB: TfrFontComboBox;
    ScriptFontSizeCB: TfrComboBox;
    SampleScriptPanel: TPanel;
    CB7: TCheckBox;
    CB8: TCheckBox;
    GroupBox9: TGroupBox;
    CB9: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure ERB1Click(Sender: TObject);
    procedure TextFontNameCBChange(Sender: TObject);
    procedure ScriptFontNameCBChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses Registry, FR_Class, FR_Utils, FR_Const, FR_Dock;


procedure TfrDesOptionsForm.Localize;
begin
  Caption := frLoadStr(frRes + 280);
  Tab1.Caption := frLoadStr(frRes + 281);
  GroupBox1.Caption := frLoadStr(frRes + 282);
  GroupBox2.Caption := frLoadStr(frRes + 283);
  GroupBox3.Caption := frLoadStr(frRes + 284);
  GroupBox4.Caption := frLoadStr(frRes + 285);
  GroupBox5.Caption := frLoadStr(frRes + 297);
  GroupBox6.Caption := frLoadStr(frRes + 300);
  CB1.Caption := frLoadStr(frRes + 286);
  CB2.Caption := frLoadStr(frRes + 287);
  CB3.Caption := frLoadStr(frRes + 288);
  CB4.Caption := frLoadStr(frRes + 298);
  CB5.Caption := frLoadStr(frRes + 299);
  CB7.Caption := frLoadStr(frRes + 311);
  RB1.Caption := frLoadStr(frRes + 289);
  RB2.Caption := frLoadStr(frRes + 290);
  RB3.Caption := frLoadStr(frRes + 291);
  Label1.Caption := frLoadStr(frRes + 293);
  RB6.Caption := frLoadStr(frRes + 294);
  RB7.Caption := frLoadStr(frRes + 295);
  RB8.Caption := frLoadStr(frRes + 296);
  RB9.Caption := frLoadStr(frRes + 301);
  RB10.Caption := frLoadStr(frRes + 302);
  RB11.Caption := frLoadStr(frRes + 303);

  Tab2.Caption := frLoadStr(frRes + 304);
  GroupBox7.Caption := frLoadStr(frRes + 305);
  GroupBox8.Caption := frLoadStr(frRes + 310);
  ERB1.Caption := frLoadStr(frRes + 306);
  ERB2.Caption := frLoadStr(frRes + 307);
  Label2.Caption := frLoadStr(frRes + 308);
  Label3.Caption := frLoadStr(frRes + 309);
  Label4.Caption := frLoadStr(frRes + 308);
  Label5.Caption := frLoadStr(frRes + 309);

  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);

  GroupBox9.Caption := frLoadStr(frRes + 2650);
  CB9.Caption := frLoadStr(frRes + 2651);
  CB8.Caption := frLoadStr(frRes + 2652);

end;

procedure TfrDesOptionsForm.FormCreate(Sender: TObject);
var
  Ini: TRegIniFile;
  Nm: String;
begin
  Localize;
  Ini := TRegIniFile.Create(RegRootKey);
  Nm := rsForm + frDesigner.ClassName;
  TextFontNameCB.Text := Ini.ReadString(Nm, 'TextFontName', 'Arial');
  TextFontSizeCB.Text := Ini.ReadString(Nm, 'TextFontSize', '10');
  ScriptFontNameCB.Text := Ini.ReadString(Nm, 'ScriptFontName', 'Courier New');
  ScriptFontSizeCB.Text := Ini.ReadString(Nm, 'ScriptFontSize', '10');
  ERB1.Checked := Ini.ReadBool(Nm, 'UseDefaultFont', True);
  ERB2.Checked := not ERB1.Checked;
  Ini.Free;

  ERB1Click(nil);
  TextFontNameCBChange(nil);
  ScriptFontNameCBChange(nil);
end;

procedure TfrDesOptionsForm.FormHide(Sender: TObject);
var
  Ini: TRegIniFile;
  Nm: String;
begin
  if ModalResult = mrOk then
  begin
    Ini := TRegIniFile.Create(RegRootKey);
    Nm := rsForm + frDesigner.ClassName;
    Ini.WriteString(Nm, 'TextFontName', TextFontNameCB.Text);
    Ini.WriteString(Nm, 'TextFontSize', TextFontSizeCB.Text);
    Ini.WriteString(Nm, 'ScriptFontName', ScriptFontNameCB.Text);
    Ini.WriteString(Nm, 'ScriptFontSize', ScriptFontSizeCB.Text);
    Ini.WriteBool(Nm, 'UseDefaultFont', ERB1.Checked);
    Ini.Free;
  end;
end;

procedure TfrDesOptionsForm.Label1Click(Sender: TObject);
begin
  CB6.Checked := not CB6.Checked;
end;

procedure TfrDesOptionsForm.ERB1Click(Sender: TObject);
begin
  frEnableControls([Label2, TextFontNameCB, Label3, TextFontSizeCB], ERB2.Checked);
end;

procedure TfrDesOptionsForm.TextFontNameCBChange(Sender: TObject);
begin
{$IFNDEF Delphi2}
  SampleTextPanel.Font.Charset := frCharset;
{$ENDIF}
  SampleTextPanel.Font.Name := TextFontNameCB.Text;
  SampleTextPanel.Font.Size := StrToInt(TextFontSizeCB.Text);
end;

procedure TfrDesOptionsForm.ScriptFontNameCBChange(Sender: TObject);
begin
{$IFNDEF Delphi2}
  SampleScriptPanel.Font.Charset := frCharset;
{$ENDIF}
  SampleScriptPanel.Font.Name := ScriptFontNameCB.Text;
  SampleScriptPanel.Font.Size := StrToInt(ScriptFontSizeCB.Text);
end;

end.

