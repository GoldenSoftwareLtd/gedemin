// ShlTanya, 26.02.2019

unit dmTestReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase;

type
  TdmTestReport = class(TDataModule)
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    procedure IBDatabase1AfterConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmTestReport: TdmTestReport;

implementation

{$R *.DFM}

uses at_classes;

procedure TdmTestReport.IBDatabase1AfterConnect(Sender: TObject);
begin
  atDatabase.Database := IBDatabase1;
  atDatabase.Transaction := IBTransaction1;

  atDatabase.ProceedLoading;
end;

end.
