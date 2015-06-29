unit xUp_Uni;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, StdCtrls, Xupgrade, ExtCtrls, xWorld,
  xBasics;

type
  TForm1 = class(TForm)
    xDBUpgrade1: TxDBUpgrade;
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    xWorld1: TxWorld;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure xDBUpgrade1BeforeTransform(Sender: TObject; OldField,
      NewField: TField; var RunDefault: Boolean);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure Setup;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Setup;
begin
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  xDBUpgrade1.CreateStructure;
  Memo1.Lines.LoadFromFile(xDBUpgrade1.StructureFile);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  xDBUpgrade1.CreateTables(cmUpdate);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  xDBUpgrade1.CreateAliasStructure;
  Memo1.Lines.LoadFromFile(xDBUpgrade1.StructureFile);
end;

procedure TForm1.xDBUpgrade1BeforeTransform(Sender: TObject; OldField,
  NewField: TField; var RunDefault: Boolean);
begin
  NewField.AsString := ReplaceAll(OldField.AsString, ',', '.'); 
  RunDefault := false;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  xDBUpgrade1.CreateTables(cmCreate);
end;

end.
