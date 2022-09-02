// ShlTanya, 09.03.2019

unit gdv_dlgfrAcctAnalyticsGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frAcctAnalyticsGroup_unit, ActnList, StdCtrls, gdv_frAcctBaseAnalyticGroup,
  CheckLst;

type
  TdlgfrAcctAnalyticsGroup = class(TfrAcctBaseAnalyticsGroup)
    gbGroup: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    lbAvail: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    lbSelected: TCheckListBox;
    procedure lbSelectedClickCheck(Sender: TObject);
  private
    { Private declarations }
  protected
    function ListBoxSelected: TCheckListBox; override;
    function ListBoxAvail: TListBox; override;
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

{ TdlgfrAcctAnalyticsGroup }

function TdlgfrAcctAnalyticsGroup.ListBoxAvail: TListBox;
begin
  Result := lbAvail
end;

function TdlgfrAcctAnalyticsGroup.ListBoxSelected: TCheckListBox;
begin
  Result := lbSelected
end;

procedure TdlgfrAcctAnalyticsGroup.lbSelectedClickCheck(Sender: TObject);
begin
  SelectedFieldListClear
end;

end.
