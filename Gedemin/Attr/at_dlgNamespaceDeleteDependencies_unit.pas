unit at_dlgNamespaceDeleteDependencies_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tat_dlgNamespaceDeleteDependencies = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    rbDeleteAll: TRadioButton;
    rbDeleteOne: TRadioButton;
    Panel4: TPanel;
    Button1: TButton;
    Button2: TButton;
    mObjects: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  at_dlgNamespaceDeleteDependencies: Tat_dlgNamespaceDeleteDependencies;

implementation

{$R *.DFM}

end.
