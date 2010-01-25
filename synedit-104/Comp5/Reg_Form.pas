
unit Reg_Form;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, xMemTable, Grids, DBGrids, ExtCtrls, Xtable,
  Buttons, xbkIni, ExList, Menus, xReport;

type
  TSaveRegisterForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    DBGrid1: TDBGrid;
    memRegSave: TxMemTable;
    memRegSaveDate: TDateTimeField;
    memRegSaveDebet: TStringField;
    memRegSaveKredit: TStringField;
    memRegSaveDebetKAU: TStringField;
    memRegSaveKreditKAU: TStringField;
    memRegSaveSum: TFloatField;
    memRegSaveNameOper: TStringField;
    DSRegSave: TDataSource;
    memRegSaveDebetKAUName: TStringField;
    memRegSaveKreditKAUName: TStringField;
    memRegSaveDeleted: TBooleanField;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    memRegSaveSumCur: TCurrencyField;
    memRegSaveNameCur: TStringField;
    memRegSaveNumber: TIntegerField;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    SpeedButton1: TSpeedButton;
    xReport: TxReport;

    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure DBGrid1DrawDataCell(Sender: TObject; const Rect: TRect;
      Field: TField; State: TGridDrawState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure memRegSaveDeletedGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);

  public
    WorkDir, MainDir: String;
    ConstractReg: TExList;
    KAUTable: TTable;
  end;

var
  SaveRegisterForm: TSaveRegisterForm;


implementation

{$R *.DFM}

uses
  MakeReg;

procedure TSaveRegisterForm.SpeedButton3Click(Sender: TObject);
begin
  Close;
end;

procedure TSaveRegisterForm.SpeedButton2Click(Sender: TObject);
begin
  if (memRegSave.RecordCount > 0) and
     (MessageBox(HANDLE, 'Удалить проводку ?', 'Внимание', mb_YesNo or mb_IconQuestion)
    = idYes)
  then begin
    TxSaveRegList(ConstractReg).DeleteRecord(memRegSaveNumber.Value);
    memRegSave.Edit;
    memRegSaveDeleted.Value:= True;
    memRegSave.Post;
    DBGrid1.Invalidate;
  end;
end;

procedure TSaveRegisterForm.DBGrid1DrawDataCell(Sender: TObject;
  const Rect: TRect; Field: TField; State: TGridDrawState);
begin
  if memRegSaveDeleted.AsBoolean then begin
    DBGrid1.Canvas.FillRect(Rect);
    DBGrid1.Canvas.Font.Color:= clGrayText;
    DBGrid1.Canvas.TextRect(Rect, Rect.left, Rect.top, Field.Text);
  end
  else
    DBGrid1.Canvas.Font.Color:= clWindowText;
end;

procedure TSaveRegisterForm.SpeedButton1Click(Sender: TObject);
begin
  xReport.FormFile:= ExtractFilePath(Application.ExeName) + 'register.rtf';
  xReport.Execute;
end;

procedure TSaveRegisterForm.memRegSaveDeletedGetText(Sender: TField;
  var Text: String; DisplayText: Boolean);
begin
  if Sender.AsBoolean then
    Text:= 'Удалена';
end;

end.
