unit xComponent;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables;

type
  TxComponent = class(TComponent)
  private
    { Private declarations }
    tblOperation: TTable;
    tblDocOperation: TTable;
    tblEntryOper: TTable;
    tblTypeEntry: TTable;

    FOpType: Integer;
    FDocumentKey: Integer;
    FFinishTime: TDateTime;
    FStartTime: TDateTime;

  protected
    { Protected declarations }
    destructor Destroy; override;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent);
      override;
  published
    { Published declarations }

    property DocumentKey: Integer read FDocumentKey write FDocumentKey;
    property OpType: Integer read FOpType write FOpType;
    property StartTime: TDateTime read FStartTime write FStartTime;
    property FinishTime: TDateTime read FFinishTime write FFinishTime;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('x-DataBase', [TxComponent]);
end;

{ TxComponent }

constructor TxComponent.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  tblOperation := TTable.Create(Self);
  tblDocOperation := TTable.Create(Self);
  tblEntryOper := TTable.Create(Self);
  tblTypeEntry := TTable.Create(Self);

end;

destructor TxComponent.Destroy;
begin
  tblOperation.Free;
  tblDocOperation.Free;
  tblEntryOper.Free;
  tblTypeEntry.Free;
  inherited Destroy;
end;

end.
