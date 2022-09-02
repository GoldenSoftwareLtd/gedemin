// ShlTanya, 24.02.2019

unit dlgClassInfo_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TdlgClassInfo = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    btnOk: TButton;
    lblClassName: TLabel;
    lblSubType: TLabel;
    lblParentClass: TLabel;
    lblMainTable: TLabel;
    lblName: TLabel;
    Bevel1: TBevel;
    btnCreate: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgClassInfo: TdlgClassInfo;

implementation

{$R *.DFM}

end.
