unit ct_frmblob;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, StdCtrls, DBCtrls;

type
  TfrmBlob = class(TForm)
    dbmemo: TDBMemo;
    dsMemo: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBlob: TfrmBlob;

implementation

{$R *.DFM}

end.
