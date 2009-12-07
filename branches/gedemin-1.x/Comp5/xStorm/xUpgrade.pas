{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection                    }
{                                                       }
{       Copyright (c) 1995,96 Stefan Bother             }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    xUpgrade.pas

  Abstract

    A component for upgrading existing databases.

  Author

    Vladimir Belyi (3-September-1996)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00  10-Sep-1996  Belyi   First approximation.
    1.01  12-Sep-1996  Belyi   Multi table support. More stability.
                               Easier interface. Wider fields transfer.
    1.03  17-Sep-1996  Belyi   Events added. Icon developed.
                               Some more enhancements.
    1.04  20-Sep-1996  Belyi   uoAlwaysUpdate option added.
                               CreateAliasStructure procedure;
    1.05  25-Sep-1996  Belyi   TxBlockFile enhanced. Comments in structure
                               file added. Different types of tables
                               supported. WhoAreYou property with beginners
                               support added. OnConfirmReplace event.
                               Multilangual support.
    1.06  26-Sep-1996  Belyi   Russian language messages. Some minor bugs
                               killed. New windows.
    1.07   1-Sep-1996  Belyi   Bug with uoAlwaysUpdate killed.
    1.08   5-Dec-1996    >      Running progress for cmCreate mode.
           18-Dec-1999 Agafonov Add FieldTypes for 32-bit version
--}


unit xUpgrade;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, DsgnIntF, Buttons,
  xBasics, xDBases, xWorld;

type
  TBlockOption = (boSkipEmptyLines, boTrimLines, boSkipCommentLines,
    boCaseInsensitive);
  TBlockOptions = set of TBlockOption;

type
  TxBlockFile = class
  private
    FileName: TFileName;
    FileMode: Word;
    TheFile: text;
    HaveLine: Boolean;
    SavedLine: string;
    HaveBlock: Boolean;
    FBlock: TStringList;
    FBlockName: string;
    FOptions: TBlockOptions;
    FComment: string;
    EndOfFile: Boolean; { usage of the field is not recommended:
                          use EOF method instead }

    function GetBlock: TStringList;
    procedure SetOptions(Value: TBlockOptions);

  public
    constructor Create(Name: string; Mode: Word);
    destructor Destroy; override;
    function GoNextBlock: Boolean;
    function SkipNextLine: string;
    function NextLine: string;
    function InputLine: string;
    function EOF: Boolean;
    function IsBlockStart(Line: string; var Name: string): boolean; virtual;
    procedure GoToBlockStart;
    { next func finds the line in the current block starting with
      '<Start>:' and then returns everything that follows this start }
    function FindBlockLine(Start: string; var Param: string): Boolean;

    property Block: TStringList read GetBlock;
    property BlockName: string read FBlockName;
    property Options: TBlockOptions read FOptions write SetOptions;
    property CommentStart: string read FComment write FComment;
  end;

const { sting values to store in structure file }
   FieldTypes: array[TFieldType] of string[15] =
     ('Unknown', 'String', 'Smallint', 'Integer', 'Word', 'Boolean',
      'Float', 'Currency', 'BCD', 'Date', 'Time', 'DateTime', 'Bytes',
      'VarBytes', 'AutoInc', 'Blob', 'Memo', 'Graphic', 'FmtMemo',
      'ParadoxOLE', 'DBaseOLE', 'TypedBinary', 'Cursor', 'FixedChar',
      'WideString', 'Largeint', 'ADT', 'Array', 'Reference', 'DateSet',
      'OraBlob', 'OraClob', 'Variant', 'Interface', 'IDispatch', 'Guid');

  TableTypes: array[TTableType] of string[10] =
    ('Default' , 'Paradox', 'DBase', 'ASCII', 'FoxPro');
  IndexOptions: array[0..4] of string[20] =
    ('Primary', 'Unique', 'Descending', 'CaseInsensitive', 'Expression');
  BoolStr: array[False .. True] of string[5] = ('False', 'True');

type
  TUpgradeOption = (uoTrimStrings, uoAlwaysUpdate, uoSkipComments,
    uoChangeTypes);
  TUpgradeOptions = set of TUpgradeOption;

  TCreateModes = (cmCreate, cmUpdate);

  TUserTypes = (IamProfessional, IamBeginner);

  TOperation = (opTable, opTableName, opStatus, opNewRec, opErrors, opWarnings);

  { types for events }
  TBeforeTransform = procedure (Sender: TObject; OldField, NewField: TField;
    var RunDefault: Boolean) of object;
  TAfterTransform = procedure (Sender: TObject; OldField, NewField: TField)
    of object;
  TTransformWarning = procedure (Sender: TObject; OldField, NewField: TField;
    const WarningName: string; var MarkError: Boolean) of object;
  TTransformError = procedure (Sender: TObject; OldField, NewField: TField;
    const ErrorName: string; var MarkError: Boolean) of object;
  TConfirmReplace = procedure (Sender: TObject; TheTableName: string;
    var ReplaceTable: Boolean; var ShowDialog: Boolean) of object;
  TVerifyStatistics = procedure (Sender: TObject; Errors: TStringList;
    var ShowDialog: Boolean) of object;

const
  SwapTableName = 'xUpSwpTb'; { better find better way then constant }

type
  TxDBUpgrade = class(TComponent)
  private
    { Private declarations }
    SFile: System.text;
    ATable: TTable;
    CurrentRecord: Integer;
    CurrentTable: TFileName;
    CurrentTableType: TTableType;
    ErrorCount: Integer;
    WarningCount: Integer;
    TotalErrorCount: Integer;
    TotalWarningCount: Integer;
    RecWithErrors: Boolean;
    Errors: TStringList;
    Statistics: TStringList;
    TableHasErrors: Boolean;
    ProcessWasOk: Boolean;

    FDatabaseName: TFileName;
    FTables: TStringList;
    FStructureFile: TFileName;
    FTableType: TTableType;
    FOptions: TUpgradeoptions;
    FCommentStart: string;
    FWhoAreYou: TUserTypes;

    FOnBeforeTransform: TBeforeTransform;
    FOnAfterTransform: TAfterTransform;
    FOnTransformError: TTransformError;
    FOnTransformWarning: TTransformWarning;
    FOnConfirmReplace: TConfirmReplace;
    FOnVerifyStatistics: TVerifyStatistics;

    procedure AddtableError(Name: string);
    procedure AddError( Src, Dest: TField; Name: string);
    procedure AddWarning( Src, Dest: TField; Name: string);
    procedure AddrecNo;
    procedure SetTables(Value: TStringlist);
    procedure FillTable(Mode: TCreateModes; ATable: TTable;
      SourceTableName: TFileName; SourceTableType: TTableType);
    procedure MoveTable(ATable: TTable; SourceTableName: TFileName;
      SourceTableType: TTableType);

    procedure SkipSpace(From: string; var Next: Integer);
    function GetString(From: string; Start: Integer; var Next: Integer): string;
    function GetExpr(From: string; Start: Integer; var Next: Integer): string;
    function GetBool(From: string; Start: Integer; var Next: Integer): Boolean;
    function ExpandOptionsSum(s: string): TIndexOptions;

  protected
    { Protected declarations }
    procedure CheckInput; virtual;

    function MemoToString( Src: TField ): string;
    procedure TransferField( Src, Dest: TField); virtual;
    procedure TransferToString( Src, Dest: TField); virtual;
    procedure TransferToMemo( Src, Dest: TField); virtual;
    procedure TransferToInteger( Src, Dest: TField); virtual;
    procedure TransferToSmallInt( Src, Dest: TField); virtual;
    procedure TransferToFloat( Src, Dest: TField); virtual;
    procedure TransferToBCD( Src, Dest: TField); virtual;
    procedure TransferToWord( Src, Dest: TField); virtual;
    procedure DefaultTransfer( Src, Dest: TField); virtual;
    function CountTables: Integer;

    { updates the contents of progress window }
    procedure UpdateScreen(Op: TOperation; Msg: string; Int: Integer); virtual;

    function UpdateTable(ATable: TTable; SourceTableName: TFileName): Boolean;

  public
    { Public declarations }
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    procedure CreateAliasStructure;
    procedure CreateStructure;
    procedure CreateTables(Mode: TCreateModes);

  published
    { Published declarations }
    property DatabaseName: TFileName read FDatabaseName write FDatabaseName;
    property Tables: TStringList read FTables write SetTables;
    property TableType: TTableType read FTableType write FTableType;
    property StructureFile: TFileName read FStructureFile
      write FStructureFile;
    property Options: TUpgradeOptions read FOptions write FOptions;
    property CommentStart: string read FCommentStart write FCommentStart;
    property WhoAreYou: TUserTypes read FWhoAreYou write FWhoAreYou;

    property OnBeforeTransform: TBeforeTransform read FOnBeforeTransform
      write FOnBeforeTransform;
    property OnAfterTransform: TAfterTransform read FOnAfterTransform
      write FOnAfterTransform;
    property OnTransformError: TTransformError read FOnTransformError
      write FOnTransformError;
    property OnTransformWarning: TTransformWarning read FOnTransformWarning
      write FOnTransformWarning;
    property OnConfirmReplace: TConfirmReplace read FOnConfirmReplace
      write FOnConfirmReplace;
    property OnVerifyStatistics: TVerifyStatistics read FOnVerifyStatistics
      write FOnVerifyStatistics;

  end;

  var { var's to store messages }
    lnSkipMsgs,
    lnCreateFault,
    lnFatal,
    lnReplaceFault,
    lnRenaming,
    lnReplaceFailed,
    lnTableSkipped,
    lnUpdateFailed,
    lnCreating,
    lnCannotCreate1,
    lnCannotCreate2,
    lnSuccess,
    lnTerminated,
    lnCritical,
    lnError,
    lnWarning,
    lnDTrunc,
    lnDToInt,
    lnDToSmallInt,
    lnDToBCD,
    lnDToFloat,
    lnDToWord,
    lnFieldRemove,
    lnTransferSuccess,
    lnCopying,
    lnFromTo,
    lnCurrentTable,
    lnCurrentRecord,
    lnErrors,
    lnTotalErrors,
    lnWarnings,
    lnTotalWarnings,
    lnStatus,
    lnTerminate,
    lnBadFinal,
    lnTableName,
    lnErrsWars,
    lnErrPrompt,
    lnCopy,
    lnSkip,
    lnTerminateQuery : Integer;

  type
    ExBlockFile = class(Exception);
    ExDBUpgrade = class(Exception);

  procedure Register;

implementation

uses
  xUpPos, xUpTbl, xUpErr, xUpBFin;

const
  CriticalCount = 990;
    { max number of error messages in list
      This is due to Delphi (or Windows) limit for maximum number of
      lines in TMemo = 999 }

{  ============== TxBlockFile ==================}
constructor TxBlockFile.Create(Name: string; Mode: Word);
begin
  inherited Create;
  FileName := Name;
  FileMode := Mode;
  CommentStart := '';
  AssignFile(TheFile, RealFileName(Name));
  case Mode of
    fmOpenRead:
      begin
        System.FileMode := 0;
        Reset(TheFile)
      end;
    fmOpenWrite:
      Rewrite(TheFile);
  end;
  HaveLine := false;
  HaveBlock := false;
  EndOfFile := false;
  FBlock := TStringList.Create;
end;

destructor TxBlockFile.Destroy;
begin
  CloseFile(TheFile);
  inherited Destroy;
end;

function TxBlockFile.InputLine: string;
var
  s: string;
  BadLine: Boolean;
begin
  if EndOfFile then
    begin
      Result := '';
      exit;
    end;
  BadLine := false;
  if HaveLine then
    Result := SavedLine
  else
    begin
      Result := '';
      repeat
        BadLine := false;
        if system.eof(TheFile) then
          EndOfFile := true;
        Readln(TheFile, Result);
        if boTrimLines in Options then
          Result := Trim(Result);
        if boSkipCommentLines in Options then
          begin
            if length(CommentStart) <= length(Result) then
              begin
                s := copy(result, 1, length(CommentStart));
                if boCaseInsensitive in Options then
                  if UpperCase(s) = UpperCase(CommentStart) then
                    BadLine := true
                  else
                else
                  if s = CommentStart then BadLine := true else;
              end;
          end;
      until ( ( (Result <> '') or not (boSkipEmptyLines in Options) ) and
            not BadLine ) or EndOfFile;
    end;
  if BadLine then Result := '';
end;

function TxBlockFile.SkipNextLine: string;
begin
  Result := InputLine;
  HaveLine := false;
end;

function TxBlockFile.NextLine: string;
begin
  Result := InputLine;
  SavedLine := Result;
  HaveLine := not EndOfFile;
end;

function TxBlockFile.EOF: Boolean;
begin
  if not EndOfFile then NextLine; { next line exists? }
  Result := EndOfFile;
end;

procedure TxBlockFile.GoToBlockStart;
var
  s: string;
begin
  while ( not EOF ) and ( not IsBlockStart(NextLine, s) ) do
    SkipNextLine;
end;

function TxBlockFile.GoNextBlock: Boolean;
var
  s: string;
begin
  Result := false;
  FBlock.Clear;
  HaveBlock := false;
  FBlockName := '';
  GoToBlockStart;
  if eof then exit;
  IsBlockStart(SkipNextLine, FBlockName);
  while ( not eof ) and (not IsBlockStart(NextLine, s)) do
    begin
      FBlock.Add(SkipNextLine);
    end;
  HaveBlock := true;
  Result := true;
end;

function TxBlockFile.IsBlockStart(Line: string; var Name: string): boolean;
begin
  if ( Length(Line) > 0 ) and ( Line[1] = '%' ) then
    begin
      Result := true;
      Name := copy(Line, 2, Length(Line) - 1 );
    end
  else
    Result := false;
end;

function TxBlockFile.GetBlock: TStringList;
begin
  if not HaveBlock then
    GoNextBlock;
  Result := FBlock;
end;

procedure TxBlockFile.SetOptions(Value: TBlockOptions);
begin
  FOptions := Value;
end;

function TxBlockFile.FindBlockLine(Start: string; var Param: string): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to Block.Count - 1 do
    if ( length(Block[i]) >= length(start) + 1 ) and
       ( ( boCaseInsensitive in Options ) and
         ( UpperCase( copy( Block[i], 1, length(Start) ) ) =
           UpperCase(Start) ) or
           not( boCaseInsensitive in Options ) and
         ( copy( Block[i], 1, length(Start) ) = Start ) ) then
      begin
        Param := copy(Block[i], length(Start) + 2,
          Length(Block[i]) - Length(Start) -1 );
        if boTrimLines in Options then
          Param := Trim(Param);
        Result := true;
      end;
end;

{ ============== TxDBUpgrade ===================}
constructor TxDBUpgrade.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FDatabaseName := '';
  FTables := TStringList.create;
  FTableType := ttDefault;
  FStructureFile := '';
  FOptions := [uoSkipComments];
  FCommentStart := ';';
  FWhoAreYou := IamBeginner;
  ATable := TTable.Create(self);
  Errors := TStringList.Create;
  Statistics := TStringList.Create;
end;

destructor TxDBUpgrade.Destroy;
begin
  ATable.Free;
  FTables.Free;
  Errors.Free;
  Statistics.Free;
  inherited Destroy;
end;

procedure TxDBUpgrade.SetTables(Value: TStringlist);
begin
  Ftables.Assign(Value);
end;

procedure TxDBUpgrade.CheckInput;
begin
  if FStructureFile = '' then
    raise ExDBUpgrade.Create('No structure file name specified.');
  if FTables.Count < 1 then
    raise ExDBUpgrade.Create('No table specified.');
end;

procedure TxDBUpgrade.CreateStructure;
var
  i: Integer;
  CurrentTable: Integer;

  function OptionsToStr(Opt: TIndexOptions): string;
  var
    s: string;

    procedure Add(s1: string);
    begin
      if s<>'' then s:= s + '+' + s1 else s := s1;
    end;

  begin
    s := '';
    if ixPrimary in Opt then Add( IndexOptions[0] );
    if ixUnique in Opt then Add( IndexOptions[1] );
    if ixDescending in Opt then Add( IndexOptions[2] );
    if ixCaseInsensitive in Opt then Add( IndexOptions[3] );
    if ixExpression in Opt then Add( IndexOptions[4] );
    Result := s;
  end;

begin
  CheckInput;
  CurrentTable := 0;
  AssignFile(SFile, StructureFile);
  Rewrite(SFile);
  try
    while Currenttable < Tables.Count do
      begin
        Writeln(SFile, '%Table ' + Tables[CurrentTable] );
        ATable.Active := false;
        ATable.DatabaseName := DatabaseName;
        ATable.TableName := Tables[CurrentTable];
        ATable.TableType := TableType;
        ATable.Active := true;
        if GetTableType(ATable) <> ttdefault then
          Writeln(SFile, '  type: ' + TableTypes[GetTableType(ATable)] );
        try
          Writeln(SFile, '%Fields');
          with ATable.FieldDefs do
            begin
              Update;
              for i := 0 to Count - 1 do
                Writeln(SFile, '  ''' + Items[i].Name + '''; ' +
                             FieldTypes[ Items[i].DataType ] + '; ' +
                             IntToStr( Items[i].Size ) + '; ' +
                               BoolStr[ Items[i].Required ] );
            end;
          Writeln(SFile, '%Indexes');
          with ATable.IndexDefs do
            begin
              Update;
              for i := 0 to Count - 1 do
                Writeln(SFile, '  ''' + Items[i].Name + '''; ' +
                               '''' + Items[i].Fields + '''; ' +
                               OptionsToStr( Items[i].Options ) );
            end;
          Writeln(SFile);
        finally
          ATable.Active := false;
        end;

        Inc(Currenttable);
      end;
  finally
    CloseFile(SFile);
  end;
end;

procedure TxDBUpgrade.CreateAliasStructure;
const
  Masks: array[TTableType] of string[5] = ('', '*.DB', '*.DBF', '*.TXT', '*.DB');
var
  l: TStringList;
begin
  l := TStringList.Create;
  try
    l.Assign(Tables);
    try
      Session.GetTableNames(DatabaseName,
        Masks[TableType], TableType = ttDefault, False, Tables);
      CreateStructure;
    finally
      Tables.Assign(l);
    end;
  finally
    l.Free;
  end;
end;

procedure TxDBUpgrade.SkipSpace(From: string; var Next: Integer);
begin
  while ( Next <= length(From) ) and ( From[Next] = ' ' ) do inc(next);
end;

function TxDBUpgrade.GetString(From: string; Start: Integer; var Next: Integer): string;
begin
  Result := '';
  if Start < 1 then
    raise ExDBUpgrade.Create('Missing parameters');
  Next := Start;
  SkipSpace(From, Next);
  if From[Next]<>'''' then
    raise ExDBUpgrade.Create('Not a string in structure file');
  inc(Next);
  while (From[Next] <> '''') and (Next <= Length(From) ) do
    begin
      Result := Result + From[Next];
      inc(Next);
    end;
  inc(next);
  SkipSpace(From, Next);
  inc(next);
  if ( Next > Length(From) + 1 ) then Next := 0;
end;

function TxDBUpgrade.GetExpr(From: string; Start: Integer; var Next: Integer): string;
begin
  if Start < 1 then
    raise ExDBUpgrade.Create('Missing parameters');
  Result := '';
  Next := Start;
  SkipSpace(From, Next);
  while (From[Next] <> ';') and (Next <= Length(From) ) do
    begin
      Result := Result + From[Next];
      inc(Next);
    end;
  inc(next);
  if ( Next > Length(From) ) then Next := 0;
  Result := Trim(Result);
end;

function TxDBUpgrade.GetBool(From: string; Start: Integer; var Next: Integer): Boolean;
var
  s: string;
begin
  s := GetExpr(From, Start, Next);
  if UpperCase(s) = UpperCase('True') then Result := true
  else if UpperCase(s) = UpperCase('False') then Result := false
    else raise ExDBUpgrade.Create('Not a boolean parameter in structure');
end;

procedure TxDBUpgrade.AddTableError(Name: string);
begin
  if not TableHasErrors then
    begin
      if Statistics.Count > 0 then
        Statistics.Add('');
      Statistics.Add('Table : ' + CurrentTable);
    end;
  Statistics.Add('  ' + Name);
  TableHasErrors := true;
  ProcessWasOk := false;
end;

procedure TxDBUpgrade.FillTable(Mode: TCreateModes; ATable: TTable;
  SourceTableName: TFileName; SourceTableType: TTableType);
begin
  if Mode = cmUpdate then
    begin
      if ( uoAlwaysUpdate in Options ) or
         ( TableExists(DatabaseName, SourceTableName, SourceTableType) and
           not(TablesHaveEqualStructure(DatabaseName, ATable.TableName,
               ATable.TableType, DatabaseName, SourceTableName,
               SourceTableType)) )
      then
        MoveTable(ATable, SourceTableName, SourceTableType)
      else
        begin
          if TableExists(DatabaseName, SourceTableName, SourceTableType) then
            DeleteTable( DatabaseName, SwapTableName, TableType )
          else
            if not CopyTable(DatabaseName, ATable.tableName,
              ATable.TableType, DatabaseName, SourceTableName,
              ATable.TableType, [cmCopyIndex, cmRename]) then
              begin
                AddTableError(Phrases[ lnFatal ] +
                              Phrases[ lnReplaceFailed ]);
              end;
        end;
    end;
end;

procedure TxDBUpgrade.MoveTable(ATable: TTable; SourceTableName: TFileName;
  SourceTableType: TTableType);
var
  XTable: TTable;
  UpdateResult: Boolean;
  SourceExists: Boolean;
  Deleted: Boolean;
  Cancel: Boolean;
  ShowDlg: Boolean;
begin
  Cancel := false;
  Errors.Clear;
  ErrorCount := 0;
  WarningCount := 0;
  try
    SourceExists := TableExists(databaseName, SourceTableName,
      SourceTableType);
    if SourceExists then
      UpdateResult := UpdateTable(ATable, SourceTableName)
    else
      UpdateResult := true;
    if Progress.Continue then
      begin
        if not UpdateResult then
          begin
            ShowDlg := WhoAreYou = IamProfessional;
            UpdateResult := not ShowDlg;
            if Assigned(FOnConfirmReplace) then
              FOnConfirmReplace(self, SourceTableName, UpdateResult, ShowDlg);
            if ShowDlg then
              begin
                Application.CreateForm(TErrorsDlg, ErrorsDlg);
                try
                  ErrorsDlg.TableName.Caption := SourceTableName;
                  if Errors.Count >= CriticalCount then
                    begin
                      Errors.Add('*******************');
                      Errors.Add( Phrases[lnSkipMsgs] );
                      Errors.Add('*******************');
                    end;
                  ErrorsDlg.Errors.Lines.Assign( Errors );
                  if ErrorsDlg.ShowModal = mrOk then
                    UpdateResult := true;
                finally
                  ErrorsDlg.Free;
                end;
              end;
          end;
        if UpdateResult then
          begin
            XTable := TTable.create(self);
            try
              Deleted := false;
              if SourceExists then
                repeat
                  try
                    XTable.DatabaseName := DatabaseName;
                    XTable.TableName := SourceTableName;
                    XTable.DeleteTable;
                  except
                    if MessageDlg( Format( Phrases[ lnCreateFault ],
                       [SourceTableName] ), mtError, [mbRetry, mbCancel],
                       0) = mrCancel then
                        begin
                          Cancel := true;
                          AddTableError(Phrases[lnFatal] +
                                        Phrases[lnReplaceFault]);
                        end;
                  end;
                  Deleted := not TableExists(databaseName,
                    SourceTableName, SourceTableType);
                until Deleted or Cancel;

              if not(cancel) then
                begin
                  ATable.Close;

                  UpdateScreen(opStatus, Phrases[ lnRenaming ], 0);

                  if not CopyTable(DatabaseName, ATable.tableName,
                    ATable.TableType, DatabaseName, SourceTableName,
                    ATable.TableType, [cmCopyIndex, cmRename]) then
                    begin
                      AddTableError(Phrases[ lnFatal ] +
                                    Phrases[ lnReplaceFailed ]);
                    end;
                end;

            finally
              XTable.Free;
            end;
          end
        else { do not update table }
          AddTableError(Phrases[lnFatal] + Phrases[lnTableSkipped]);
      end;

  except { failed to update }
    on E: Exception do
      begin
        AddTableError(Format( Phrases[lnUpdateFailed],  [E.Message] ) );
        ATable.Active := false;
        ATable.DeleteTable;
      end;
  end;
end;

function TxDBUpgrade.ExpandOptionsSum(s: string): TIndexOptions;
var
  i: integer;
  ss: string;
begin
  Result := [];
  while length(s) > 0 do
   begin
     i := pos('+', s);
     if i <> 0 then
       begin
         ss := copy(s, 1, i - 1);
         delete(s, 1, i);
       end
     else
       begin
         ss := s;
         s := '';
       end;
     ss := trim(ss);
     if UpperCase(ss) = UpperCase(IndexOptions[0]) then
       Result := Result + [ixPrimary];
     if UpperCase(ss) = UpperCase(IndexOptions[1]) then
       Result := Result + [ixUnique];
     if UpperCase(ss) = UpperCase(IndexOptions[2]) then
       Result := Result + [ixDescending];
     if UpperCase(ss) = UpperCase(IndexOptions[3]) then
       Result := Result + [ixCaseInsensitive];
     if UpperCase(ss) = UpperCase(IndexOptions[4]) then
       Result := Result + [ixExpression];
   end;
end;

function TxDBUpgrade.CountTables: Integer;
var
  BlockFile: TxBlockFile;
  TablesCount: Integer;
begin
  BlockFile := TxBlockFile.Create(StructureFile, fmOpenRead);
  try
    BlockFile.CommentStart := CommentStart;
    if uoSkipComments in Options then
      BlockFile.Options := BlockFile.Options + [boSkipCommentLines]
    else
      BlockFile.Options := BlockFile.Options - [boSkipCommentLines];
    BlockFile.Options := BlockFile.Options + [boCaseInsensitive,
      boSkipEmptyLines, boTrimLines];

    TablesCount := 0;
    while BlockFile.GoNextBlock do
      if UpperCase(copy(BlockFile.BlockName,1,5)) = 'TABLE' then
        Inc(TablesCount);
  finally
    BlockFile.Destroy;
  end;
  Result := TablesCount;
end;

type
  TCreateStates = (csWaiting, csAssigned, csTableBuilt, csSkipping);

procedure TxDBUpgrade.CreateTables(Mode: TCreateModes);
var
  i: Integer;
  s, s1, s2, s3: string;
  Next: Integer;
  BlockFile: TxBlockFile;
  State: TCreateStates;
  ShowDlg: Boolean;
  TablesCount, TableNo: Integer; 

  function WhichField(s: string): TFieldType;
  begin
    Result := ftUnknown;
    while ( UpperCase(FieldTypes[Result]) <> UpperCase(s) ) do
      Result := Succ(Result);
  end;

begin
  if FStructureFile = '' then
    raise ExDBUpgrade.Create('No structure file name specified.');
  Statistics.Clear;
  State := csWaiting;
  ProcessWasOk := true;
  TablesCount := CountTables;
  TableNo := 0;
  BlockFile := TxBlockFile.Create(StructureFile, fmOpenRead);
  try
    BlockFile.CommentStart := CommentStart;
    if uoSkipComments in Options then
      BlockFile.Options := BlockFile.Options + [boSkipCommentLines]
    else
      BlockFile.Options := BlockFile.Options - [boSkipCommentLines];
    BlockFile.Options := BlockFile.Options + [boCaseInsensitive,
      boSkipEmptyLines, boTrimLines];
    Application.CreateForm(TProgress, Progress);
    try
      try
        Progress.CanHide := false;
        Progress.Continue := true;
        case WhoAreYou of
          IamProfessional: Progress.Notebook.ActivePage := 'Professional';
          IamBeginner: Progress.Notebook.ActivePage := 'Beginner';
        end;
        Errors.Clear;
        Progress.Show;
        if Mode = cmCreate then
        begin
          Progress.xProgress.Min := 0;
          Progress.xProgress.Max := TablesCount;
          Progress.xProgress.Value := 0;
        end;
        TotalErrorCount := 0;
        TotalWarningCount := 0;
        while BlockFile.GoNextBlock and Progress.Continue do
          begin
            if UpperCase(copy(BlockFile.BlockName,1,5)) = 'TABLE' then
              begin
                inc(TableNo);
                if Mode = cmCreate then
                  Progress.xProgress.Value := TableNo;
                if State = csTableBuilt then
                  FillTable(Mode, ATable, CurrentTable, CurrentTableType);
                ATable.Active := false; { for sure }
                s := BlockFile.BlockName;
                delete(s, 1, 5);
                s := trim(s);
                CurrentTable := s;
                if CurrentTable = '' then
                  raise ExDBUpgrade.Create('Table name not specified '+
                   'in structure file.');
                CurrentTableType := ttDefault;
                if BlockFile.Block.Count > 0 then
                  begin
                    if BlockFile.FindBlockLine('type', s) then
                      begin
                        if UpperCase(s) = 'PARADOX' then
                          CurrentTableType := ttParadox
                        else if UpperCase(s) = 'DBASE' then
                          CurrentTableType := ttDBase
                        else if UpperCase(s) = 'ASCII' then
                          CurrentTableType := ttASCII
                        else
                          raise ExDBUpgrade.Create('Unsupported table type '+
                           'in table structure: ' + CurrentTable);
                      end;
                  end;
                if CurrentTableType = ttDefault then
                  CurrentTableType := TableTypeByExt(CurrentTable);
                TableHasErrors := false;
                if Mode = cmCreate then
                  UpdateScreen(opTableName, CurrentTable, 0)
                else
                  UpdateScreen(opTable, CurrentTable, 0);
                UpdateScreen(opStatus, Phrases[lnCreating], 0);
                ATable.DatabaseName := DatabaseName;
                case Mode of
                  cmUpdate: ATable.TableName := SwapTableName;
                  cmCreate: ATable.TableName := CurrentTable;
                  else raise ExDBUpgrade.create('Internal error #2B5R$1. ' +
                    'Unknown mode.');
                end;
                if (uoChangeTypes in Options) and
                   (TableType <> ttDefault) then
                  ATable.TableType := TableType
                else
                  ATable.tableType := CurrentTableType;
                State := csAssigned;
                Application.ProcessMessages;
              end
            else if UpperCase(BlockFile.BlockName) = 'FIELDS' then
              begin
                if State <> csAssigned then
                  raise ExDBUpgrade.Create('Fields definition should follow '+
                                           'table name (file ''' +
                                           StructureFile + ''')' );
                ATable.FieldDefs.Clear;
                for i := 0 to BlockFile.Block.Count - 1 do
                  begin
                    s := BlockFile.Block[i];
                    s1 := GetString(s, 1, Next);
                    s2 := GetExpr(s, Next, Next);
                    s3 := GetExpr(s, Next, Next);
                    ATable.FieldDefs.Add( s1, WhichField(s2),
                      StrToInt(s3), GetBool(s, Next, Next) );
                  end;
                ATable.IndexDefs.Clear;
                try
                  ATable.CreateTable;
                  State := csTableBuilt;
                  Application.ProcessMessages;
                except
                  on E: Exception do
                    begin
                      MessageDlg(Format(Phrases[lnCannotCreate1], [E.Message]),
                        mtError, [mbOk], 0);
                      AddTableError(Phrases[lnFatal] +
                        Format(Phrases[lnCannotCreate2], [E.Message]) );
                      State := csSkipping;
                    end;
                end;
              end
            else if UpperCase(BlockFile.BlockName) = 'INDEXES' then
              begin
                if not (state in [csTableBuilt, csSkipping]) then
                  raise ExDBUpgrade.Create('Fields definition should be prior '+
                                          'to index definitions in ''' +
                                          StructureFile + '''' );
                if state = csTableBuilt then
                  begin
                    ATable.IndexDefs.Clear;
                    for i := 0 to BlockFile.Block.Count - 1 do
                      begin
                        s := BlockFile.Block[i];
                        s1 := GetString(s, 1, Next);
                        s2 := GetString(s, Next, Next);
                        s3 := GetExpr(s, Next, Next);
                        ATable.AddIndex( s1, s2, ExpandOptionsSum(s3));
                      end;
                    Application.ProcessMessages;
                  end;
              end;
          end;
        if Progress.Continue then
          begin
            if State = csTableBuilt then
              FillTable(Mode, ATable, CurrentTable, CurrentTableType);
            Progress.Hide;
          end;
        if not(ProcessWasOk and Progress.Continue) then
          begin
            if not Progress.Continue then
              begin
                Statistics.Add('*******************************');
                Statistics.Add( Phrases[lnFatal] + Phrases[lnTerminated] );
                Statistics.Add('*******************************');
              end;
          end;
        ShowDlg := WhoAreYou = IamProfessional;
        if Assigned(FOnVerifyStatistics) then
          FOnVerifyStatistics(self, Statistics, ShowDlg);
        if ShowDlg then
          begin
            if ProcessWasOk and Progress.Continue then
              MessageDlg(Phrases[lnSuccess], mtInformation, [mbOk], 0)
            else
              begin
                Application.CreateForm(TBadFinal, BadFinal);
                try
                  BadFinal.Stat.Lines.Assign(Statistics);
                  BadFinal.ShowModal;
                finally
                  BadFinal.Free;
                end;
              end;
          end;
      except
        on E: Exception do
          MessageDlg( Format( Phrases[lnCritical], [E.Message]), mtError,
            [mbOk], 0);
      end;
    finally
      Progress.Free;
    end;
  finally
    BlockFile.Destroy;
  end;
end;

procedure TxDBUpgrade.AddRecNo;
begin
  RecWithErrors := true;
{  if Errors.Count < CriticalCount then
    Errors.Add( '#' + IntToStr(CurrentRecord) );}
end;

procedure TxDBUpgrade.AddError(Src, Dest: TField; Name: string);
var
  Mark: Boolean;
begin
  Mark := true;
  if Assigned(FOnTransformError) then
    FOnTransformError( Self, Src, Dest, Name, Mark );
  if Mark then
    begin
      if CurrentRecord <> -1 then
        begin
          if not RecWithErrors then AddRecNo;
          if Errors.Count < CriticalCount then
             Errors.Add( Format( Phrases[lnError], [CurrentRecord,
               Src.Fieldname, Name] ) );
        end
      else
        if Errors.Count < CriticalCount then
          Errors.Add(Name);
      inc(ErrorCount);
      inc(TotalErrorCount);
      UpdateScreen(opErrors, '', 0);
    end;
end;

procedure TxDBUpgrade.AddWarning(Src, Dest: TField; Name: string);
var
  Mark: Boolean;
begin
  Mark := true;
  if Assigned(FOnTransformWarning) then
    FOnTransformWarning( Self, Src, Dest, Name, Mark );
  if Mark then
    begin
      if CurrentRecord <> -1 then
        begin
          if not RecWithErrors then AddRecNo;
          if Errors.Count < CriticalCount then
             Errors.Add( Format( Phrases[lnWarning], [CurrentRecord,
               Src.Fieldname, Name] ) );
        end
      else
        if Errors.Count < CriticalCount then
          Errors.Add(Name);
      inc(WarningCount);
      inc(TotalWarningCount);
      UpdateScreen(opWarnings, '', 0);
    end;
end;

procedure TxDBUpgrade.DefaultTransfer( Src, Dest: TField); 
begin
  Dest.Assign( Src );
end;

function TxDBUpgrade.MemoToString( Src: TField ): string;
var
  ss: TStringList;
  i: Integer;
begin
  Result := '';
  ss := TStringlist.Create;
  try
    ss.Assign( Src );
    i := 0;
    while ( Length(Result) < 255 ) and  ( i < ss.Count) do
      begin
        if i > 0 then Result := Result + ' ';
        Result := Result + ss[i];
        inc(i);
      end;
  finally
    ss.destroy;
  end;
end;

procedure TxDBUpgrade.TransferToString( Src, Dest: TField);
var
  s: string;
  Default: Boolean;
begin
  Default := false;
  case Src.DataType of
    ftString, ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency,
    ftBCD, ftDate, ftTime, ftDateTime:
      begin
        s := Src.AsString;
      end;
    ftMemo, ftBytes, ftVarBytes, ftBlob, ftGraphic:
      begin
        s := MemoToString( Src );
      end;
    else 
      begin
        Default := true;
        DefaultTransfer( Src, Dest);
      end;
  end;

  if not default then
    begin
      if uoTrimStrings in FOptions then
        s := Trim(s);
      if length(s) > dest.DataSize - 1 then
        AddWarning(Src, Dest, Phrases[lnDTrunc]);
      Dest.AsString := s;
    end;
end;

procedure TxDBUpgrade.TransferToInteger( Src, Dest: TField);
var
  s: string;
  x: Extended;
  er: Integer;
  Default: Boolean;
begin
  Default := false;
  case Src.DataType of
    ftString, ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat,
    ftBCD, ftDate, ftTime, ftDateTime:
      begin
        s := Src.AsString;
      end;
    ftCurrency:
      s := FloatToStr( Src.AsFloat );
    ftMemo, ftBytes, ftVarBytes, ftBlob, ftGraphic:
      begin
        s := MemoToString( Src );
      end;
    else
      begin
        Default := true;
        DefaultTransfer( Src, Dest);
      end;
  end;

  if not Default then
    begin
      Val(s, x, er);
      if er <> 0 then
        AddError(Src, Dest, Phrases[lnDToInt])
      else
        Dest.AsInteger := Round(x);
    end;
end;

procedure TxDBUpgrade.TransferToSmallInt( Src, Dest: TField);
var
  s: string;
  x: Extended;
  er: Integer;
  Default: Boolean;
begin
  Default := false;
  case Src.DataType of
    ftString, ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat,
    ftBCD, ftDate, ftTime, ftDateTime:
      begin
        s := Src.AsString;
      end;
    ftCurrency:
      s := FloatToStr( Src.AsFloat );
    ftMemo, ftBytes, ftVarBytes, ftBlob, ftGraphic:
      begin
        s := MemoToString( Src );
      end;
    else
      begin
        Default := true;
        DefaultTransfer( Src, Dest);
      end;
  end;

  if not Default then
    begin
      Val(s, x, er);
      if er <> 0 then
        AddError( Src, Dest, Phrases[lnDToSmallInt])
      else
        Dest.AsInteger := Round(x);
    end;
end;

procedure TxDBUpgrade.TransferToBCD( Src, Dest: TField);
var
  s: string;
  x: Extended;
  er: Integer;
  Default: Boolean;
begin
  Default := false;
  case Src.DataType of
    ftString, ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat,
    ftBCD, ftDate, ftTime, ftDateTime:
      begin
        s := Src.AsString;
      end;
    ftCurrency:
      s := FloatToStr( Src.AsFloat );
    ftMemo, ftBytes, ftVarBytes, ftBlob, ftGraphic:
      begin
        s := MemoToString( Src );
      end;
    else
      begin
        Default := true;
        DefaultTransfer( Src, Dest);
      end;
  end;

  if not Default then
    begin
      Val(trim(s), x, er);
      if er <> 0 then
        AddError( Src, Dest, Phrases[lnDToBCD])
      else
        Dest.AsFloat := x;
    end;
end;

procedure TxDBUpgrade.TransferToFloat( Src, Dest: TField);
var
  s: string;
  x: Extended;
  er: Integer;
  Default: Boolean;
begin
  Default := false;
  case Src.DataType of
    ftString, ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat,
    ftBCD, ftDate, ftTime, ftDateTime:
      begin
        s := Src.AsString;
      end;
    ftCurrency:
      s := FloatToStr( Src.AsFloat );
    ftMemo, ftBytes, ftVarBytes, ftBlob, ftGraphic:
      begin
        s := MemoToString( Src );
      end;
    else
      begin
        Default := true;
        DefaultTransfer( Src, Dest);
      end;
  end;

  if not Default then
    begin
      Val( trim(s), x, er);
      if er <> 0 then
        AddError( Src, Dest, Phrases[lnDToFloat])
      else
        Dest.AsFloat := x;
    end;
end;

procedure TxDBUpgrade.TransferToWord( Src, Dest: TField);
var
  s: string;
  x: Extended;
  er: Integer;
  Default: Boolean;
begin
  Default := false;
  case Src.DataType of
    ftString, ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat,
    ftBCD, ftDate, ftTime, ftDateTime:
      begin
        s := Src.AsString;
      end;
    ftCurrency:
      s := FloatToStr( Src.AsFloat );
    ftMemo, ftBytes, ftVarBytes, ftBlob, ftGraphic:
      begin
        s := MemoToString( Src );
      end;
    else
      begin
        Default := true;
        DefaultTransfer( Src, Dest);
      end;
  end;

  if not Default then
    begin
      Val( trim(s), x, er);
      if er <> 0 then
        AddError( Src, Dest, Phrases[lnDToWord])
      else
        Dest.AsInteger := Round(x);
    end;
end;

procedure TxDBUpgrade.TransferToMemo( Src, Dest: TField);
var
  s: string;
  ss: TStringList;
begin
  case Src.DataType of
    ftString, ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency,
    ftBCD, ftDate, ftTime, ftDateTime:
      begin
        s := Src.AsString;
        if uoTrimStrings in FOptions then
          s := Trim(s);
        ss := TStringlist.Create;
        try
          ss.Add(s);
          Dest.Assign( ss );
        finally
          ss.destroy;
        end;
      end;
    ftMemo, ftBytes, ftVarBytes, ftBlob, ftGraphic:
      begin
        Dest.Assign( Src );
      end;
    else DefaultTransfer(Src, Dest);
  end;
end;

procedure TxDBUpgrade.TransferField(Src, Dest: TField);
var
  Default: Boolean;
begin
  try
    Default := True;
    if Assigned(FOnBeforeTransform) then
      FOnBeforeTransform( self, Src, Dest, Default);
    if Default then
      begin
        if Src.IsNull then
          Dest.Clear
        else
          case Dest.DataType of
            ftString: TransferToString( Src, Dest );
            ftMemo: TransferToMemo( Src, Dest );
            ftInteger: TransferToInteger( Src, Dest );
            ftSmallInt: TransferToSmallInt( Src, Dest );
            ftFloat: TransferToFloat( Src, Dest );
            ftBCD: TransferToBCD( Src, Dest );
            ftWord: TransferToWord( Src, Dest );
            else DefaultTransfer(Src, Dest);
          end;
        if Assigned(FOnAfterTransform) then
          FOnAfterTransform(Self, Src, Dest);
      end;

  except
    on E: Exception do
      AddError(Src, Dest, E.Message);
  end;
end;

function TxDBUpgrade.UpdateTable(Atable: TTable; SourceTableName: TFileName):
  Boolean;
type
  TConnect = array[0..255] of TField;
var
  STable: TTable;
  Connect: ^TConnect;
  i: Integer;
  Total: LongInt;
begin
  Result := false;
  ATable.Active := true;
  STable := TTable.Create(self);
  try
    STable.DatabaseName := DatabaseName;
    STable.TableName := SourceTableName;
    STable.Exclusive := false;
    STable.Active := true;
    GetMem( Connect, Stable.FieldCount * SizeOf(TField) );
    try
      CurrentRecord := -1;
      for i := 0 to Stable.FieldCount - 1 do
        begin
          Connect^[i] := ATable.FindField(STable.Fields[i].FieldName);
          if Connect^[i] = nil then
           begin
             Errors.Add( Format( Phrases[lnFieldRemove],
               [STable.Fields[i].FieldName] ) );
           end;
        end;
      try
        STable.First;
        CurrentRecord := 0;
        total := Stable.RecordCount;
        while not(STable.EOF) and (Progress.Continue) do
          begin
            ATable.Append;
            RecWithErrors := false;
            try
              for i := 0 to Stable.FieldCount - 1 do
                if Connect^[i] <> nil then
                  TransferField( STable.Fields[i], Connect^[i] );
            finally
              ATable.post;
            end;
            Stable.Next;
            inc(CurrentRecord);
            UpdateScreen(opNewRec, '', Total);
          end;
      finally
        if not STable.EOF then
          Errors.Add(Phrases[lnFatal] + Phrases[lnTerminated]);
        if Errors.Count = 0 then
          begin
            Errors.Add(Phrases[lnTransferSuccess]);
            Result := true;
          end;
      end;
    finally
      FreeMem( Connect, Stable.FieldCount * SizeOf(TField) );
    end;
  finally
    STable.free;
    Atable.Active := false;
    ATable.Exclusive := false;
  end;
end;

procedure TxDBUpgrade.UpdateScreen(Op: TOperation; Msg: string;
  Int: Integer); 
begin
  case Op of
    opStatus:
      begin
        Progress.RecNo.Text := Msg;
        Progress.Status.Caption := Msg;
      end;
    opTable:
      begin
        Progress.TableName.Text := Msg;
        Progress.TableName1.Caption := Msg;
        Progress.xProgress.Value := 0;
      end;
    opTableName:
      begin
        Progress.TableName.Text := Msg;
        Progress.TableName1.Caption := Msg;
      end;
    opErrors:
      begin
        Progress.ErrCount.Caption := IntToStr(ErrorCount);
        Progress.TotalErrCount.Caption := IntToStr(TotalErrorCount);
      end;
    opWarnings:
      begin
        Progress.WarCount.Caption := IntToStr(WarningCount);
        Progress.TotalWarCount.Caption := IntToStr(TotalWarningCount);
      end;
    opNewRec:
      begin
        Progress.RecNo.Text := Format( Phrases[lnFromTo],
          [CurrentRecord, Int] );
        Progress.xProgress.Max := int;
        Progress.xProgress.Value := Currentrecord;
        Progress.Status.Caption := Phrases[lnCopying];
      end
    else
      raise ExDBUpgrade.Create('Internal error #345$53.');
  end;
  Application.ProcessMessages;
end;


{ property editors ---------------------------------------}

{ TDBStringProperty }

type
  TDBStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual; abstract;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

function TDBStringProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TDBStringProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

{ TDatabaseNameProperty }

type
  TDatabaseNameProperty = class(TDBStringProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

procedure TDatabaseNameProperty.GetValueList(List: TStrings);
begin
  Session.GetDatabaseNames(List);
end;

{ TTableNameProperty }

type
  TTableNameProperty = class(TDBStringProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

procedure TTableNameProperty.GetValueList(List: TStrings);
const
  Masks: array[TTableType] of string[5] = ('', '*.DB', '*.DBF', '*.TXT', '*.DB');
var
  Comp: TxDBUpgrade;
begin
  Comp := GetComponent(0) as TxDBUpgrade;
  Session.GetTableNames(Comp.DatabaseName,
    Masks[Comp.TableType], Comp.TableType = ttDefault, False, List)
end;

{ TTablesProperty }

type
  TTablesProperty = class(TStringProperty)
  public
    procedure Edit; override;
  end;

procedure TTablesProperty.Edit;
const
  Masks: array[TTableType] of string[5] = ('', '*.DB', '*.DBF', '*.TXT', '*.DB');
var
  Comp: TxDBUpgrade;
  List: TStringList;
begin
  Application.CreateForm(TTablesList, TablesList);
  try
    Comp := GetComponent(0) as TxDBUpgrade;
    List := TStringList.create;
    try
      Session.GetTableNames(Comp.DatabaseName,
        Masks[Comp.TableType], Comp.TableType = ttDefault, False, List);
      TablesList.Srclist.Items := List;
    finally
      List.Free;
    end;
    TablesList.ShowModal;
  finally
    TablesList.Free;
  end;
end;


procedure Register;
begin
  RegisterComponents('xStorm', [TxDBUpgrade]);
  RegisterPropertyEditor(TypeInfo(TFileName), TxDBUpgrade,
    'DatabaseName', TDatabaseNameProperty);
{  RegisterPropertyEditor(TypeInfo(TFileName), TxDBUpgrade,
    'TableName', TTableNameProperty);
  RegisterPropertyEditor(TypeInfo(TStringList), TxDBUpgrade,
    'Tables', TTablesProperty);}
end;


initialization
  Phrases.SetOrigin('xTools: TxDBUpgrade component');

  { english messages }
  lnSkipMsgs := Phrases.AddPhrase(lEnglish,
    'FURTHER MESSAGES ARE NOT LISTED HERE!!!');
  lnCreateFault := Phrases.AddPhrase(lEnglish,
    'Cannot delete table %s. Probably it is in use by another application. '+
    'Quit the application and press ''Retry''');
  lnFatal := Phrases.AddPhrase(lEnglish, 'FATAL ERROR: ');
  lnReplaceFault := Phrases.AddPhrase(lEnglish,
    'Could not replace old table.');
  lnRenaming := Phrases.AddPhrase(lEnglish, 'Renaming swap table...');
  lnReplaceFailed := Phrases.AddPhrase(lEnglish, 'Failed to replace old table.');
  lnTableSkipped := Phrases.AddPhrase(lEnglish, 'table is skiped.');
  lnUpdateFailed := Phrases.AddPhrase(lEnglish,
    'Failed to update table. Exception %s');
  lnCreating := Phrases.AddPhrase(lEnglish, 'Creating structure');
  lnCannotCreate1 := Phrases.AddPhrase(lEnglish,
    'Cannot create table due to exception : %s');
  lnCannotCreate2 := Phrases.AddPhrase(lEnglish,
    'Could not create table. Exception : %s');
  lnSuccess := Phrases.AddPhrase(lEnglish,
    'Tables have been successfully created.');
  lnTerminated := Phrases.AddPhrase(lEnglish, 'PROCESS TERMINATED');
  lnCritical := Phrases.AddPhrase(lEnglish,
    'Critical error. Process terminated. Exception %s');
  lnError := Phrases.AddPhrase(lEnglish, '  Error  (%d): Copying ''%s'': %s');
  lnWarning := Phrases.AddPhrase(lEnglish, '  Warning(%d): Copying ''%s'': %s');
  lnDTrunc := Phrases.AddPhrase(lEnglish, 'data truncated.');
  lnDToInt := Phrases.AddPhrase(lEnglish, 'Could not transfer to integer.');
  lnDToSmallInt := Phrases.AddPhrase(lEnglish,
    'Could not transfer to SmallInt.');
  lnDToBCD := Phrases.AddPhrase(lEnglish, 'Could not transfer to BCD.');
  lnDToFloat := Phrases.AddPhrase(lEnglish, 'Could not transfer to float.');
  lnDToWord := Phrases.AddPhrase(lEnglish, 'Could not transfer to word.');
  lnFieldRemove := Phrases.AddPhrase(lEnglish, 'Field ''%s'' is removed.');
  lnTransferSuccess := Phrases.AddPhrase(lEnglish, 'Transfer completed ' +
    'successfully');
  lnCopying := Phrases.AddPhrase(lEnglish, 'Copying records...');
  lnFromTo := Phrases.AddPhrase(lEnglish, '%d from %d');
  lnCurrentTable := Phrases.AddPhrase(lEnglish, 'Current table:');
  lnCurrentRecord := Phrases.AddPhrase(lEnglish, 'Current record:');
  lnErrors := Phrases.AddPhrase(lEnglish, 'Errors:');
  lnTotalErrors := Phrases.AddPhrase(lEnglish, 'Total errors:');
  lnWarnings := Phrases.AddPhrase(lEnglish, 'Warnings:');
  lnTotalWarnings := Phrases.AddPhrase(lEnglish, 'Total warnings:');
  lnTerminate := Phrases.AddPhrase(lEnglish, 'Terminate');
  lnStatus := Phrases.AddPhrase(lEnglish, 'Status:');
  lnBadFinal := Phrases.AddPhrase(lEnglish, 'Tables not copied/updated');
  lnTableName := Phrases.AddPhrase(lEnglish, 'Table name:');
  lnErrsWars := Phrases.AddPhrase(lEnglish, 'Errors and warnings');
  lnErrPrompt := Phrases.AddPhrase(lEnglish, 'Some errors and warnings ' +
    'were reported while updating table. Decide whether you want to ' +
    'replace the old table with the new one.');
  lnCopy := Phrases.AddPhrase(lEnglish, 'Replace');
  lnSkip := Phrases.AddPhrase(lEnglish, 'Skip');
  lnTerminateQuery := Phrases.AddPhrase(lEnglish,
    'Process is not over. Terminate?');

  Phrases.AddTranslation(lnSkipMsgs, lRussian,
   'ПОСЛЕДУЮЩИЕ СООБЩЕНИЯ ЗДЕСЬ НЕ ОТОБРАЖЕНЫ!!!');
  Phrases.AddTranslation(lnCreateFault, lRussian,
   'Невозможно удалить таблицу %s. Вероятно она используется другим ' +
   'приложением. Выйдите из приложения и нажмите ''Retry''');
  Phrases.AddTranslation(lnFatal, lRussian, 'ФАТАЛЬНАЯ ОШИБКА: ');
  Phrases.AddTranslation(lnReplaceFault, lRussian,
   'Невозможно заменить старую таблицу.');
  Phrases.AddTranslation(lnRenaming, lRussian,
    'Переименование временной таблицы...');
  Phrases.AddTranslation(lnReplaceFailed, lRussian,
    'Провал перезаписи старой таблицы.');
  Phrases.AddTranslation(lnTableSkipped, lRussian, 'таблица пропущена.');
  Phrases.AddTranslation(lnUpdateFailed, lRussian,
   'Провал попытки обновить таблицу. Exception %s');
  Phrases.AddTranslation(lnCreating, lRussian, 'Создание структуры');
  Phrases.AddTranslation(lnCannotCreate1, lRussian,
   'Невозможно создать таблицу из-за exception : %s');
  Phrases.AddTranslation(lnCannotCreate2, lRussian,
   'Провал попытки создать таблицу. Exception : %s');
  Phrases.AddTranslation(lnSuccess, lRussian,
   'Создание/обновление таблиц успешно завершено.');
  Phrases.AddTranslation(lnTerminated, lRussian, 'ПРОЦЕСС ПРЕРВАН');
  Phrases.AddTranslation(lnCritical, lRussian,
   'Критическая ошибка. Процесс прерван. Exception %s');
  Phrases.AddTranslation(lnError, lRussian,
    '  Ошибка   (%d): Копирую ''%s'': %s');
  Phrases.AddTranslation(lnWarning, lRussian,
    '  Замечание(%d): Копирую ''%s'': %s');
  Phrases.AddTranslation(lnDTrunc, lRussian, 'часть данных отброшена.');
  Phrases.AddTranslation(lnDToInt, lRussian,
    'Невозможно перевести в integer.');
  Phrases.AddTranslation(lnDToSmallInt, lRussian,
    'Невозможно перевести в SmallInt.');
  Phrases.AddTranslation(lnDToBCD, lRussian,
    'Невозможно перевести в BCD.');
  Phrases.AddTranslation(lnDToFloat, lRussian,
    'Невозможно перевести в float.');
  Phrases.AddTranslation(lnDToWord, lRussian,
    'Невозможно перевести в word.');
  Phrases.AddTranslation(lnFieldRemove, lRussian, 'Поле ''%s'' удалено.');
  Phrases.AddTranslation(lnTransferSuccess, lRussian, 'Перенос завершен ' +
   'удачно');
  Phrases.AddTranslation(lnCopying, lRussian, 'Копирую записи...');
  Phrases.AddTranslation(lnFromTo, lRussian, '%d из %d');
  Phrases.AddTranslation(lnCurrentTable, lRussian, 'Текущая таблица:');
  Phrases.AddTranslation(lnCurrentRecord, lRussian, 'Текущая запись:');
  Phrases.AddTranslation(lnErrors, lRussian, 'Ошибок:');
  Phrases.AddTranslation(lnTotalErrors, lRussian, 'Всего ошибок:');
  Phrases.AddTranslation(lnWarnings, lRussian, 'Замечаний:');
  Phrases.AddTranslation(lnTotalWarnings, lRussian, 'Всего замечаний:');
  Phrases.AddTranslation(lnTerminate, lRussian, 'Прервать');
  Phrases.AddTranslation(lnStatus, lRussian, 'Состояние:');
  Phrases.AddTranslation(lnBadFinal, lRussian,
    'Не скопированные/не обновленные таблицы');
  Phrases.AddTranslation(lnTableName, lRussian, 'Имя таблицы:');
  Phrases.AddTranslation(lnErrsWars, lRussian, 'Ошибки и предупреждения');
  Phrases.AddTranslation(lnErrPrompt, lRussian, 'Во время обновления ' +
    'таблицы было зарегистрировано несколько ошибок и замечаний.' +
   ' Решите, хотите ли вы перезаписать старую таблицу?');
  Phrases.AddTranslation(lnCopy, lRussian, 'Перезаписать');
  Phrases.AddTranslation(lnSkip, lRussian, 'Пропустить');
  Phrases.AddTranslation(lnTerminateQuery, lRussian,
    'Процесс не завершен. Прервать?');

  Phrases.ClearOrigin;

end.
