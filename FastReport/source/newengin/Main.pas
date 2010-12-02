unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    AbbrE: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    TableE: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    QueryE: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    DatabaseE: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    UTableE: TEdit;
    UQueryE: TEdit;
    UDatabaseE: TEdit;
    Button1: TButton;
    Button2: TButton;
    Bevel1: TBevel;
    procedure Button1Click(Sender: TObject);
    procedure AbbrEExit(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
{$I-}

type
  PCharArray = ^TCharArray;
  TCharArray = Array[0..32767] of Char;

procedure TForm1.Button1Click(Sender: TObject);
var
  BaseDir, NewDir: String;
  SearchRec: TSearchRec;
  r: Word;
  mem: PCharArray;
  memSize: Integer;

  procedure Replace(sFrom, sTo: String);
  var
    i, j: Integer;
    Flag: Boolean;
  begin
    while Pos('?', sFrom) <> 0 do
      sFrom[Pos('?', sFrom)] := #0;
    i := 0;
    while i < memSize do
    begin
      Flag := True;
      for j := 1 to Length(sFrom) do
        if AnsiCompareText(mem^[i + j - 1], sFrom[j]) <> 0 then
        begin
          Flag := False;
          break;
        end;
      if Flag then
      begin
        Move((PChar(mem) + i + Length(sFrom))^,
             (PChar(mem) + i + Length(sTo))^, memSize - (i + Length(sFrom)));
        for j := 1 to Length(sTo) do
          mem^[i + j - 1] := sTo[j];
        Inc(memSize, Length(sTo) - Length(sFrom));
      end;
      Inc(i);
    end;
  end;

  procedure ProcessFile(s: String);
  var
    n: Integer;
    stm: TMemoryStream;
    stm1: TFileStream;

    function MakeTwoChar(s: String): String;
    var
      i: Integer;
    begin
      Result := '';
      for i := 1 to Length(s) do
        Result := Result + s[i] + #0;
    end;

  begin
    stm := TMemoryStream.Create;
    stm.LoadFromFile(BaseDir + '\' + s);
    FillChar(mem^, 32768, 0);
    Move(stm.Memory^, mem^, stm.Size);
    memSize := stm.Size;

    Replace('frXXX', 'fr' + AbbrE.Text);
    Replace('TXXXTable', 'T' + TableE.Text + 'Table');
    Replace('TXXXQuery', 'T' + QueryE.Text + 'Query');
    Replace('TXXXDatabase', 'T' + DatabaseE.Text + 'Database');
    Replace('UXXXTable', UTableE.Text);
    Replace('UXXXQuery', UQueryE.Text);
    Replace('UXXXDatabase', UDatabaseE.Text);
    Replace('F?R?_?X?X?X?', MakeTwoChar('FR_' + AbbrE.Text));
    Replace('F?R?X?X?X?', MakeTwoChar('FR' + AbbrE.Text));
    Replace('FR_XXX', 'FR_' + AbbrE.Text);
    Replace(' XXX ', ' ' + AbbrE.Text + ' ');
    Replace('TfrQBXXXEngine', 'TfrQB' + AbbrE.Text + 'Engine');

    n := Pos('XXX', AnsiUpperCase(s));
    if n <> 0 then
    begin
      Delete(s, n, 3);
      Insert(AbbrE.Text, s, n);
    end;
    stm1 := TFileStream.Create(NewDir + '\' + s, fmCreate);
    stm1.Write(mem^, memSize);
    stm1.Free;

    stm.Free;
  end;

begin
  if (Trim(AbbrE.Text) = '') or (Trim(TableE.Text) = '') or
     (Trim(QueryE.Text) = '') or (Trim(DatabaseE.Text) = '') or
     (Trim(UTableE.Text) = '') or (Trim(UQueryE.Text) = '') or
     (Trim(UDatabaseE.Text) = '') then
  begin
    MessageBox(0, PChar('You must fill all fields!'), PChar('Error'),
      mb_OK + mb_IconError);
    AbbrE.SetFocus;
    Exit;
  end;

  SetCurrentDir(ExtractFilePath(ParamStr(0)));
  ChDir('..');
  BaseDir := GetCurrentDir + '\XXX';
  NewDir := GetCurrentDir + '\' + AbbrE.Text;
  New(mem);

// make dir
  MkDir(AbbrE.Text);

// processing files
  R := FindFirst(BaseDir + '\*.*', faAnyFile, SearchRec);
  while R = 0 do
  begin
    if (SearchRec.Attr and faDirectory) = 0 then
      ProcessFile(SearchRec.Name);
    R := FindNext(SearchRec);
  end;
  FindClose(SearchRec);

  Dispose(mem);

  MessageBox(0, PChar('Files are converted and placed in the SOURCE\' +
    AbbrE.Text + ' folder.'), '', mb_OK + mb_IconInformation);
  Close;
end;

procedure TForm1.AbbrEExit(Sender: TObject);
begin
  if AbbrE.Text = '' then Exit;
  TableE.Text := AbbrE.Text;
  QueryE.Text := AbbrE.Text;
  DatabaseE.Text := AbbrE.Text;
  UTableE.Text := AbbrE.Text + 'Table';
  UQueryE.Text := AbbrE.Text + 'Query';
  UDatabaseE.Text := AbbrE.Text + 'Database';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
