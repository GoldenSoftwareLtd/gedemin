unit rtf_TemplateBuilder;

interface

uses
  Word97, Windows, SysUtils, Classes, Forms;

type
  TgsWord97 = class(TComponent)
  private
    FWordApplication: TWordApplication;
    FWordDocument: TWordDocument;
    FWordAppl, FTemplateBuild: Boolean;
    FWorkFileName: OleVariant;

    procedure WordApplicationQuit(Sender: TObject);
    procedure WordDocumentClose(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Execute(const AnStream: TStream): Boolean;
  end;

implementation

uses
  gd_SetDatabase;

{ TgsWord97 }

constructor TgsWord97.Create(AOwner: TComponent);
begin
  inherited Create(Owner);

  FWordApplication := TWordApplication.Create(nil);
  FWordApplication.OnQuit := WordApplicationQuit;
  FWordDocument := TWordDocument.Create(nil);
  FWordDocument.OnClose := WordDocumentClose;
end;

destructor TgsWord97.Destroy;
begin
  FreeAndNil(FWordDocument);
  FreeAndNil(FWordApplication);

  inherited Destroy;
end;

procedure TgsWord97.WordApplicationQuit(Sender: TObject);
begin
  FWordApplication.Disconnect;
  FTemplateBuild := False;
  FWordAppl := False;
end;

procedure TgsWord97.WordDocumentClose(Sender: TObject);
var
  FileFormat: OleVariant;
begin
  FileFormat := wdFormatRTF;
  if not FWordDocument.Saved then
  begin
    FWordDocument.SaveAs(FWorkFileName, FileFormat);
  end;
//  FWordDocument.Disconnect;
  FTemplateBuild := False;
end;

function TgsWord97.Execute(const AnStream: TStream): Boolean;
var
  FWorkFile: TFileStream;
  Template, NewTemplate: OleVariant;
  WindowList: Pointer;
begin
  // Чтобы два раза не вызывали. Хотя уже не получится.
  if FTemplateBuild then
    MessageBox(0,
      'Шаблон уже редактируется.', 'Внимание', MB_OK or MB_ICONWARNING or MB_TASKMODAL);

  FTemplateBuild := True;
  try
    // Создаем темп файл для редактирования шаблона
    FWorkFileName := rpGetTempFileName('rtftmp');
    try
      // Помещаем в него данные
      FWorkFile := TFileStream.Create(FWorkFileName, fmCreate);
      try
        FWorkFile.CopyFrom(AnStream, AnStream.Size);
      finally
        FWorkFile.Free;
      end;

      // Подключаемся к Word
      FWordApplication.Connect;
      FWordApplication.Visible := True;
      FWordApplication.Caption := 'Редактирование шаблона RTF';
      FWordAppl := True;

      // Параметры для создания нового документа
      Template := EmptyParam;
      NewTemplate := False;

      FWordDocument.ConnectTo(FWordApplication.Documents.Open(FWorkFileName, EmptyParam,
       EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
       EmptyParam));

      // Выводим на верх по z
      FWordApplication.Activate;
      FWordDocument.Activate;

      // Деактивируем все окна приложения
      WindowList := DisableTaskWindows(0);
      try
        // Цикл. Ожидаем закрытие Word.
        while FTemplateBuild do
        begin
          Application.ProcessMessages;
          Sleep(50);
        end;

        // Пытаемся закрыть документ. Однозначного решения найти не удалось.
        // Поэтому в зависимости от способа закрытия может возникать ошибка.
        // Если убрать не успевает отпустить файл (в зависимости от способа закрытия).
        try
          FWordDocument.Close;
        except
        end;
        FWordDocument.Disconnect;

        // Если нет открытых документов, то закрываем Word.
        if FWordAppl then
        begin
          if FWordApplication.Documents.Count = 0 then
            FWordApplication.Quit;
          FWordApplication.Disconnect;
        end;

      finally
        Result := (MessageBox(0, 'Сохранить изменения в шаблоне?',
         'Вопрос', MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES);
        // Активируем все окна
        EnableTaskWindows(WindowList);
      end;

      if Result then
      begin
        // Открываем файл и считываем из него данные.
        FWorkFile := TFileStream.Create(FWorkFileName, fmOpenRead);
        try
          AnStream.Position := 0;
          AnStream.Size := 0;
          AnStream.CopyFrom(FWorkFile, FWorkFile.Size);
        finally
          FWorkFile.Free;
        end;
      end;
    finally
      // Удаляем темп файл.
      DeleteFile(FWorkFileName);
    end;
  finally
    // Обнуляем флаги.
    FWordAppl := False;
    FTemplateBuild := False;
  end;
end;

end.
