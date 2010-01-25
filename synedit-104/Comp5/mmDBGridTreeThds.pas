
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridTreeThds.pas

  Abstract

    A part of a lagre component "mmDBGridTree.pas" 

  Author

    Romanovski Denis (09-03-99)

  Revisions history

    Initial  09-03-99  Dennis  Initial version.

    Beta1    13-03-99  Dennis  You can't put any work shit-thing simply,
                               but you'd put it through synchronize.

    Beta2    13-03-99  Dennis  There's still a bug. It just destroy's the project
                               complitely, but I'm fighting with it.
--}

unit mmDBGridTreeThds;

interface

uses
  Classes, Windows, Forms, DB, DBTables, DBClient, mmDBGridTree;

type
  TmmDBGridTreeThd = class(TThread)
  private
    FTree: TClientDataSet; // Таблица, представляющая дерево
    FSource, FDetail: TDataSet; // Источник данных для дерева, зависимый источник данных для дерева
    FFieldKey, FFieldParent: String; // Поля: ключевое, на родителя
    FGrid: TmmDBGridTree; // Дерево!
    CurrBM, OldBM: TBookMark;

    procedure ScanData;
    procedure Start;
    procedure FullFinish;
    procedure FullStart;
    procedure CheckChildren;
  protected
    procedure Execute; override;

  public
    constructor Create(Tree: TClientDataSet; Source, Detail: TDataSet;
      FieldKey, FieldParent: String; Grid: TmmDBGridTree);

  end;

implementation

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TmmDBGridTreeThd.Create(Tree: TClientDataSet; Source, Detail: TDataSet;
  FieldKey, FieldParent: String; Grid: TmmDBGridTree);
begin
  Priority := tpIdle;

  FTree := Tree;
  FSource := Source;
  FDetail := Detail;

  FFieldKey := FieldKey;
  FFieldParent := FieldParent;

  FGrid := Grid;

  OldBM := nil;
  FreeOnTerminate := True;

  inherited Create(False);
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Производит запуск нити параллельного процесса.
}

procedure TmmDBGridTreeThd.Execute;
begin
  // Запускаем режим установки определенности
  ScanData;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Производим сканирование таблицы.
}

procedure TmmDBGridTreeThd.ScanData;
begin
  Synchronize(FullStart);
  while not Terminated do Synchronize(Start);
end;

procedure TmmDBGridTreeThd.Start;
begin
  if not Terminated then
  begin
    FTree.DisableControls;
    OldBM := FTree.GetBookMark;

    // Производится переход на следующую запись
    if (CurrBM <> nil) and FTree.BookmarkValid(CurrBM) then
    begin
      FTree.GotoBookmark(CurrBM);
      FTree.FreeBookmark(CurrBM);
      FTree.Next;
    end;

    // Если переход произведен, то производим проверку
    if FSource.Active and not FTree.EOF then
    begin
      CurrBM := FTree.GetBookmark;

      FSource.DisableControls;
      CheckChildren;
      FSource.EnableControls;

      if (OldBM <> nil) and FTree.BookmarkValid(OldBM) then
      begin
        FTree.GotoBookMark(OldBM);
        FTree.FreeBookmark(OldBM);
      end;

    end else begin
      // Если же нет, то выходим
      FullFinish;
      Terminate;
    end;

    FTree.EnableControls;
  end else
    FullFinish;
end;

procedure TmmDBGridTreeThd.FullFinish;
begin
  if (OldBM <> nil) and FTree.BookmarkValid(OldBM) then
  begin
    FTree.GotoBookmark(OldBM);
    FTree.FreeBookmark(OldBM);
  end;
end;

procedure TmmDBGridTreeThd.FullStart;
begin
  OldBM := FTree.GetBookmark;
end;

{
  Производит проверку наличия детей.
}

procedure TmmDBGridTreeThd.CheckChildren;
var
  HasChildren: Boolean;
begin
  if FSource.Active and FTree.FieldByName(NAME_BRANCHFIELD).IsNull then
  begin
    // Нельзя допустить рекурсии из-за detail данных
    if FTree.FieldByName(FFieldParent).IsNull and
      (Length(FTree.FieldByName(NAME_GROUPFIELD).AsString) div SymbolsPerLevel > 1)
    then
      HasChildren := False
    else begin
      if FSource.Active then
        HasChildren := FSource.Locate(FFieldParent, FTree.FieldByName(FFieldKey).Value, [])
      else
        HasChildren := False;

      // Если отсутствуют данные по дереву, то смотрим зависимую таблицу
      if not HasChildren and Assigned(FDetail) and FDetail.Active then
      begin
        HasChildren := FSource.Locate(FFieldKey + ';' + FFieldParent,
          VarArrayOf([FTree.FieldByName(FFieldKey).Value,
            FTree.FieldByName(FFieldParent).Value]), []) and
          (FDetail.RecordCount > 0);
      end;
    end;

    FTree.Edit;
    FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(Word(HasChildren), 0);
    FTree.Post;
  end;
end;

end.

