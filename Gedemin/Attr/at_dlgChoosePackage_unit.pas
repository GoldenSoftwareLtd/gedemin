unit at_dlgChoosePackage_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, Buttons, CheckLst, ExtCtrls;

type
  Tat_dlgChoosePackage = class(TForm)
    mGSFInfo: TMemo;
    btnChoose: TBitBtn;
    btnCancel: TBitBtn;
    btnExist: TBitBtn;
    lbPackage: TListBox;
    Memo1: TMemo;
    Bevel1: TBevel;
    btnHelp: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnChooseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbPackageClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    IDChooseList: TStringGrid;
    SelectedID: Integer;
    spForInstall, spForChoose: String;
  end;

{const
  InfoMessage = 'Пакет настроек %s зависит от %s. По указанному пути и/или в базе данных обнаружено несколько ' +
' версий данного пакета настроек. Укажите пакет, который вы хотите установить. ';}
                                                                                 
var
  at_dlgChoosePackage: Tat_dlgChoosePackage;

implementation

{$R *.DFM}

uses
  gdcSetting;

procedure Tat_dlgChoosePackage.FormCreate(Sender: TObject);
begin
  IDChooseList := TStringGrid.Create(Self);
  IDChooseList.ColCount := 2;
  IDChooseList.RowCount := 1;

  SelectedID := -1;
end;

procedure Tat_dlgChoosePackage.FormDestroy(Sender: TObject);
begin
  IDChooseList.Free;
end;

procedure Tat_dlgChoosePackage.btnChooseClick(Sender: TObject);
begin
//  SelectedID := StrToInt(IDChooseList.Cells[0, sgrPackage.Selection.Top]);
  SelectedID := StrToInt(IDChooseList.Cells[0, lbPackage.ItemIndex]);
end;

procedure Tat_dlgChoosePackage.FormShow(Sender: TObject);
begin
{      clbPackages.ItemIndex := 0;
    clbPackagesClick(clbPackages);}
                                                             
//  InfoMessage.
{  Memo1.Clear;
  Memo1.Lines.Add(Format(InfoMessage, ['1', '2']))}
    
  lbPackage.ItemIndex := 0;
  lbPackageClick(lbPackage);
end;

procedure Tat_dlgChoosePackage.lbPackageClick(Sender: TObject);
var
  Ver: String;
begin
  if Assigned(lbPackage.Items.Objects[lbPackage.ItemIndex]) then
  begin
    mGSFInfo.Clear;

    with lbPackage.Items.Objects[lbPackage.ItemIndex] as TGSFHeader do
    begin
      mGSFInfo.Lines.Add(Comment);
      case VerInfo of
        svNotInstalled: Ver := ' - пакет не установлен';
        svNewer: Ver := ' - новая версия';   
        svEqual: Ver := ' - версии совпадают';
//        svOlder: Ver := ' - старая версия';
//        svIncorrect: mGSFInfo.Lines.Add('Некорректна');
        svIndefinite: Ver := ' - INDEFINITE';
      else
        Ver := '';
      end;
      mGSFInfo.Lines.Add('Версия: ' + IntToStr(Version) + Ver);
      mGSFInfo.Lines.Add('Изменен: ' + DateToStr(Date));
      mGSFInfo.Lines.Add('Путь: ' + FilePath);
      mGSFInfo.Lines.Add('Имя файла: ' + FileName);

    end; // with
  end;   // Assigned
end;

procedure Tat_dlgChoosePackage.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
