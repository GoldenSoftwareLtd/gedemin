// ShlTanya, 12.03.2019

unit st_dlgfolderprop_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tst_dlgfolderprop = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Button2: TButton;
    Bevel4: TBevel;
    Bevel5: TBevel;
    lName: TLabel;
    lFolders: TLabel;
    lValues: TLabel;
    lSize: TLabel;
    Label3: TLabel;
    lModified: TLabel;
    eLocation: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  st_dlgfolderprop: Tst_dlgfolderprop;

implementation

{$R *.DFM}

procedure Tst_dlgfolderprop.Button1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
