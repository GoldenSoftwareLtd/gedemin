{
  Form for the Intern.pas
  (C) Golden Software of Belarus
  Author: Vladimir Belyi
  1996, August-September
}

unit xWo_edit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TMEditor = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Panel1: TPanel;
    Label2: TLabel;
    ComboBox1: TComboBox;
    Edit2: TEdit;
    Panel2: TPanel;
    Label3: TLabel;
    ComboBox2: TComboBox;
    Edit3: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Modified: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    Current: Integer;
    DoSave: Boolean;
    procedure Renew;
    procedure Save;
  public
    { Public declarations }
  end;

var
  MEditor: TMEditor;

implementation

{$R *.DFM}

uses
  xWorld, xWo_add;

procedure TMEditor.Save;
begin
  if not DoSave then exit;
  Phrases.FindID(Current).WasChanged := true;
  Phrases.AddTranslation(
    Current,
    Phrases.FindLanguage(ComboBox1.Text),
    Edit2.Text );
  Phrases.AddTranslation(
    Current,
    Phrases.FindLanguage(ComboBox2.Text),
    Edit3.Text );
  DoSave := false;
end;

procedure TMEditor.Renew;
begin
  Edit1.Text := Phrases.GetPhraseOrigin( Current );
  Edit2.Text := Phrases.GetPhrase( Current,
    Phrases.FindLanguage(ComboBox1.Text) );
  Edit3.Text := Phrases.GetPhrase( Current,
    Phrases.FindLanguage(ComboBox2.Text) );
  Modified.Checked := Phrases.FindID(Current).WasChanged;
end;

procedure TMEditor.FormShow(Sender: TObject);
begin
  ComboBox1.Items.Assign( Phrases.LNames );
  ComboBox1.Text := 'English';
  ComboBox2.Items.Assign( Phrases.LNames );
  ComboBox2.Text := ComboBox2.Items[ Phrases.Language ];
  if Phrases.LNames[ Phrases.Language ] = 'English' then
    try
      if Phrases.LNames[0] = 'English' then
        ComboBox2.Text := Phrases.LNames[1]
      else
        ComboBox2.Text := Phrases.LNames[0];
    except
    end;
  Renew;
end;

procedure TMEditor.Button3Click(Sender: TObject);
begin
  Save;
  Close;
end;

procedure TMEditor.FormCreate(Sender: TObject);
begin
  Current := 0;
  DoSave := false;
end;

procedure TMEditor.Button2Click(Sender: TObject);
begin
  if Current < Phrases.Count - 1 then
    begin
      Save;
      inc(Current);
      Renew;
      DoSave := false;
    end;
end;

procedure TMEditor.Button1Click(Sender: TObject);
begin
  if Current > 0 then
    begin
      Save;
      dec(Current);
      Renew;
      DoSave := false;
    end;
end;

procedure TMEditor.ComboBox1Change(Sender: TObject);
begin
  Renew;
end;

procedure TMEditor.ComboBox2Change(Sender: TObject);
begin
  Renew;
end;

procedure TMEditor.Edit2Change(Sender: TObject);
begin
  Modified.Checked := true;
  DoSave := true;
end;

procedure TMEditor.Button4Click(Sender: TObject);
begin
  Edit2.Text := Phrases.GetRescuePhrase( Current,
    Phrases.FindLanguage(ComboBox1.Text) );
end;

procedure TMEditor.Button5Click(Sender: TObject);
begin
  Edit3.Text := Phrases.GetRescuePhrase( Current,
    Phrases.FindLanguage(ComboBox2.Text) );
end;

procedure TMEditor.Button6Click(Sender: TObject);
var
  s: string;
begin
  Save;
  Application.CreateForm(TNewLang, NewLang);
  try
    NewLang.ShowModal;
    s := NewLang.ALanguage;
  finally
    NewLang.Free;
    ComboBox1.Items.Assign( Phrases.LNames );
    ComboBox2.Items.Assign( Phrases.LNames );
    if s <> '' then
      begin
        ComboBox2.Text := s;
        Edit3.SetFocus;
      end;
    Renew;
  end;
end;

end.
