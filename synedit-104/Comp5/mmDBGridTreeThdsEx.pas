
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridTreeThdsEx.pas

  Abstract

    A part of a lagre component "mmDBGridTreeEx.pas" 

  Author

    Romanovski Denis (09-03-99)

  Revisions history

    Initial  22-03-99  Dennis  Initial version.

--}

unit mmDBGridTreeThdsEx;

interface

uses
  Classes, Windows, Forms, DB, DBTables, DBClient, mmDBGridTreeEx;

type
  TmmDBGridTreeThdEx = class(TThread)
  private
    FTree: TClientDataSet; // �������, �������������� ������
    FSource, FDetail: TStoredProc; // �������� ������ ��� ������, ��������� �������� ������ ��� ������
    FFieldKey, FFieldParent: String; // ����: ��������, �� ��������
    FGrid: TmmDBGridTreeEx; // ������!
    CurrBM, BM: TBookMark; // ��������

    procedure ScanData;
    procedure Start;
    procedure FullFinish;
    procedure FullStart;
    procedure CheckChildren;
  protected
    procedure Execute; override;

  public
    constructor Create(Tree: TClientDataSet; Source, Detail: TStoredProc;
      FieldKey, FieldParent: String; Grid: TmmDBGridTreeEx);

  end;

implementation

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  ������ ��������� ���������.
}

constructor TmmDBGridTreeThdEx.Create(Tree: TClientDataSet; Source, Detail: TStoredProc;
  FieldKey, FieldParent: String; Grid: TmmDBGridTreeEx);
begin
  inherited Create(False);
  
  Priority := tpIdle;

  FTree := Tree;
  FSource := Source;
  FDetail := Detail;

  FFieldKey := FieldKey;
  FFieldParent := FieldParent;

  FGrid := Grid;

  BM := nil;
  FreeOnTerminate := True;

  //inherited Create(False);
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  ���������� ������ ���� ������������� ��������.
}

procedure TmmDBGridTreeThdEx.Execute;
begin
  // ��������� ����� ��������� ��������������
  ScanData;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  ���������� ������������ �������.
}

procedure TmmDBGridTreeThdEx.ScanData;
begin
  Synchronize(FullStart);
  while not Terminated and FGrid.IsThreaded do Synchronize(Start);
  Synchronize(FullFinish);
end;

procedure TmmDBGridTreeThdEx.Start;
begin
  if BM <> nil then FTree.FreeBookmark(BM);
  BM := FTree.GetBookMark;

  FTree.DisableControls;

  if CurrBM <> nil then
  begin
    FTree.GotoBookmark(CurrBM);
    FTree.FreeBookmark(CurrBM);
    FTree.Next;
  end;

  if not FTree.EOF then
  begin
    CurrBM := FTree.GetBookmark;
    CheckChildren;
  end else
    Terminate;

  FTree.GotoBookMark(BM);
  FTree.EnableControls; 
end;

procedure TmmDBGridTreeThdEx.FullFinish;
begin
  if BM <> nil then
  begin
    FTree.GotoBookmark(BM);
    FTree.FreeBookmark(BM);
  end; 
end;

procedure TmmDBGridTreeThdEx.FullStart;
begin
  BM := FTree.GetBookmark;
end;

{
  ���������� �������� ������� �����.
}

procedure TmmDBGridTreeThdEx.CheckChildren;
var
  HasChildren: Boolean;
begin

  if FTree.FieldByName(NAME_BRANCHFIELD).IsNull then
  begin
    // ������ ��������� �������� ��-�� detail ������
    if FGrid.IsDetail then
      HasChildren := False
    else begin
      // ����� "�����"

      if not FSource.Prepared then FSource.Prepare;

      if FTree.FieldByName(FFieldKey).IsNull then
        FSource.Params[0].Clear
      else
        FSource.Params[0].AsInteger := FTree.FieldByName(FFieldKey).AsInteger;

      try
        FSource.ExecProc;
      except
      end;
      HasChildren := FSource.Params[1].AsBoolean;

      // ���� ����������� ������ �� ������, �� ������� ��������� �������
      if not HasChildren and Assigned(FDetail) then
      begin
        if FDetail.Prepared then FDetail.UnPrepare;
        if not FDetail.Prepared then FDetail.Prepare;
        FDetail.Params[0].AsInteger := FTree.FieldByName(FFieldKey).AsInteger;
        try
          FDetail.ExecProc;
        except
        end;
        HasChildren := FDetail.Params[1].AsBoolean;
      end;
    end;

    FTree.Edit;
    FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(Word(HasChildren), 0);
    FTree.Post;
  end;

end;

end.

