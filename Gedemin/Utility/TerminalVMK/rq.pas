unit rq; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, rqoperation, LMessages, BaseAddInformation;

type
  TRQParams = record
    Data: String;
    RQname: String;
  end;

  { TRQ }

  TRQ = class(TBaseAddInformation)
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
    FRQName: String;
  protected
    { public declarations }
    function CheckCode(const ACode: String): boolean; override;
    procedure Enter; override;
  public
    class function ExecuteWithParams: TRQParams;
  end;

implementation

{$R *.lfm}

uses
  JcfStringUtils, MessageForm;

const
  PrefixLoad = 'cl';
  PrefixSave = 'ov';
  PrefixDelay = 'dl';

class function TRQ.ExecuteWithParams: TRQParams;
begin
  Result.Data := '';
  Result.RQname := '';
  with TRQ.Create(nil) do
  try
    ShowModal;
    Result.Data := Data;
    Result.RQname := FRQName;
  finally
    Free;
  end;
end;

{ TRQ }

procedure TRQ.FormCreate(Sender: TObject);
begin
  inherited;
  lInfo.Caption := 'Код заявки: ';
  FRQName := '';
end;

procedure TRQ.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
end;


procedure TRQ.Enter;
var
  Temps: String;
begin
  Temps := Trim(eInfo.Text);
  if CheckCode(Temps) then
  begin
    Data := Temps;
    ModalResult := mrOk;
  end;
end;

function TRQ.CheckCode(const ACode: String): boolean;
var
  OL: TStringList;
  Index: Integer;
  TempValue: String;
  SearchResult : TSearchRec;
  SearchResOv : TSearchRec;
begin
  Result := True;

  if Length(ACode) >= 11 then
  begin
    if  FileExists(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT') then
    begin
      OL := TStringList.Create;
      try
        OL.LoadFromFile(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
        Index := OL.IndexOfName(ACode);

        if Index > - 1 then
        begin
          if FileExists(ExtractFilePath(Application.ExeName) + DelayPath + OL.ValueFromIndex[Index] + '.txt') then
          begin
            FRQName := OL.ValueFromIndex[Index];
            OL.Delete(Index);
            OL.SaveToFile(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
            Exit;
          end;
          if (MessageForm.MessageDlg('Заявка уже отгружена!Пересоздать?', 'Внимание',
            mtInformation, [mbYes, mbNo]) = mrYes) then
          begin
            SysUtils.DeleteFile(ExtractFilePath(Application.ExeName) + SavePath + OL.Values[OL.Names[Index]] + '.txt');
            OL.Delete(Index);
            OL.SaveToFile(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
          end else
            Result := False;
        end
        else
          begin
            TempValue := 'ov3';
            TempValue := TempValue + Copy(ACode, 12, Length(ACode) - 11);
            if FindFirst(ExtractFilePath(Application.ExeName) + DelayPath + TempValue + '*', faAnyFile, SearchResult ) = 0  then
              begin
              if FindFirst(ExtractFilePath(Application.ExeName) + SavePath + TempValue + '*', faAnyFile, SearchResOv ) = 0  then
                begin
                if (MessageForm.MessageDlg('Заявка уже отгружена!Пересоздать?', 'Внимание',
                  mtInformation, [mbYes, mbNo]) = mrYes) then
                   begin
                     FRQName := SearchResult.name;
                     FRQName := Copy(FRQName, 1, Length(FRQName) - 4) ;
                   end else
                     Result := False;
                SysUtils.FindClose(SearchResOv);
                end else
                begin
                  FRQName := SearchResult.name;
                  FRQName := Copy(FRQName, 1, Length(FRQName) - 4) ;
                end;
                SysUtils.FindClose(searchResult);
              end;
          end;

      finally
        OL.Free;
      end;
    end;
    if Result then
    begin
      if not FileExists(ExtractFilePath(Application.ExeName) + LoadPath + PrefixLoad + ACode + '.TXT') then
      begin
        MessageForm.MessageDlg('Отсутствует файл заявки!', 'Внимание',
          mtInformation, [mbOK]);
        Result := False;
      end;
    end;
  end else
  begin
    MessageForm.MessageDlg('Код заявки неверен', 'Внимание',
      mtInformation, [mbOk]);
    Result := False;
  end;
end;
end.

