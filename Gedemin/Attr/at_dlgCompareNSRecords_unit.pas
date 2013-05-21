unit at_dlgCompareNSRecords_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls;

type
  TLoadRecord = (lrNone, lrFromFile, lrNotLoad);

  TdlgCompareNSRecords = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    ActionList1: TActionList;
    actDB: TAction;
    actFromFile: TAction;
    lCaption: TLabel;
    procedure actDBExecute(Sender: TObject);
    procedure actFromFileExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    LoadRecord: TLoadRecord;
  end;

var
  dlgCompareNSRecords: TdlgCompareNSRecords;

implementation

{$R *.DFM}

procedure TdlgCompareNSRecords.actDBExecute(Sender: TObject);
begin
  LoadRecord := lrNotLoad;
  ModalResult := mrOk;
end;

procedure TdlgCompareNSRecords.actFromFileExecute(Sender: TObject);
begin
  LoadRecord := lrFromFile;
  ModalResult := mrOk;
end;

procedure TdlgCompareNSRecords.FormCreate(Sender: TObject);
begin
  LoadRecord := lrNone; 
end;

end.
