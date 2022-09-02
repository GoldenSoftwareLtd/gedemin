// ShlTanya, 27.02.2019

unit to_fr_ReportPage;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrReportPage = class(TFrame)
    mmScript: TMemo;
    Panel3: TPanel;
    cbLanguage: TComboBox;
    edName: TEdit;
    cbModule: TComboBox;
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.DFM}

constructor TfrReportPage.Create(AOwner: TComponent);
begin
  inherited;

{  cbLanguage.ItemIndex := 0;
  cbModule.ItemIndex := 0;}
end;

end.
