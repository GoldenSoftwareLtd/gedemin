
{++

  Copyright (c) 1998-99 by Golden Software of Belarus

  Module

    xRestr.pas

  Abstract

    A delphi non visual component

  Author

    Romanovski Denis (xx.x.96)

  Revisions history

    Initial       xx-xx-1996     Michael     Initial version.
    Version 2.0   xx-xx-1998     TsAg        Exported to Delphi 32
    Version 3.0   22-03-2000     Dennis      Value check removed. All tables
                                             changed to Paradox 7.0,
                                             Some bugs fixed.

}

unit xRestr;

interface

uses
  dbiErrs,  dbiTypes, dbiProcs, SysUtils, WinTypes, WinProcs, Messages, Classes,
  Graphics, Controls, Forms,    Dialogs,  ExList, xUpgerr,
  xUpgpas, xPrgrFrm, DBTables;

type
  TxRestructTable = class(TComponent)
  private
    TablesInfo: TExList;
    FStructInfo: String;
    ErrorCode: Integer;
    xProgressForm: TxProgressForm;
    DatabasePath, NameErrTable, Password: String;

    function ReadStructInfo: Boolean;
    function DeleteIndex(Index: Integer): Boolean;
    function UpgradeTable(DBHandle: HDBIDB; Index: Integer): Boolean;
    function CreateTable(DBHandle: HDBIDB; Index: Integer): Boolean;
    function ReindexTable(DBHandle: HDBIDB; Index: Integer): Boolean;
    procedure GetErrorMessage;
    function OpenTable(DBHandle: HDBIDB; NameTable: String; var dbiCur: hDBICur): Integer;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpgradeTables(DBHandle: HDBIDB);

  published
    property StructInfo: String read FStructInfo write FStructInfo;
  end;

procedure Register;

implementation

const
  OrgFieldTypes: array[fldPDXCHAR..fldPDXUNICHAR] of String[10] =
  ('String', 'Float', 'Currency', 'Date', 'Smallint', 'Memo', 'Blob', 'Memo',
   'ParadoxOLE', 'Graphic', 'Integer', 'Time', 'DateTime', 'Boolean',
   'AutoInc', 'Bytes', 'BCD', '');

  IndexOptions: array[0..4] of string[20] =
    ('Primary', 'Unique', 'Descending', 'CaseInsensitive', 'Expression');

  StructOptions: array[0..3] of string[10] =
    ('%Table', 'type:', '%Fields', '%Indexes');

type
  TFieldInfo = class
    NameField: String;
    Size: Integer;
    TypeField: Word;
    IsRequred: Boolean;
    TypeOper: CROpType;
    NumField: Integer;
    HasDef: Boolean;
    DefVal: String;
    HasMin: Boolean;
    MinVal: Variant;
    HasMax: Boolean;
    MaxVal: Variant;
    constructor Create(const Line: String);
    constructor CreateNew(aNameField: String; aSize: Integer; aTypeField: Word;
      aisRequred: Boolean; aNumField: Integer);
  end;

  TIndexInfo = class
    NameIndex: String;
    NameIndexFields: String;
    IsPrimary: Boolean;
    IsUnique: Boolean;
    isCaseInsensitive: Boolean;
    isDescending: Boolean;
    isExpression: Boolean;

    constructor Create(const Line: String);
  end;

  TTableInfo = class
    NameTable: String;
    TypeTable: String;
    FieldsInfo: TExList;
    IndexsInfo: TExList;

    constructor Create(const Line: String);
    destructor Destroy; override;

    procedure SetTypeTable(const Line: String);
    procedure AddField(const Line: String);
    procedure AddIndex(const Line: String);
  end;

{ TFieldInfo }


//   REPLACE_COMMA
function ReplaceComma(Ch: Char; const S: String): String;
var
  i: Integer;
begin
  Result:= S;
  for i:= 1 to Length(S) do
    if Result[i] = Ch then
      Result[i]:= '&';
end;


//   TRIM
function Trim(const S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;


//   CREATE
constructor TFieldInfo.Create(const Line: String);
var
  S, S1: String;
  PerNum: Word;
begin
  // выделяем имя поля
  S := Trim(ReplaceComma(#39, Line));
  S := copy(S, Pos('&', S) + 1, 255);
  NameField:= copy(S, 1, Pos('&', S) - 1);
  // выделяем тип
  S := Trim(copy(S, Pos(';', S) + 1, 255));
  S1 := copy(S, 1, Pos(';', S) - 1);
  PerNum := fldPDXCHAR;
  while (CompareText(OrgFieldTypes[ PerNum ], S1) <> 0) do
    PerNum := Succ(PerNum);
  TypeField := PerNum;
  // выделяем размер
  S := copy(S, Pos(';', S) + 1, 255);
  S1 := copy(S, 1, Pos(';', S) - 1);
  Size := StrToInt(S1);
{!}  if Size = 0 then Size := 1;
  // выделяем REQUIRED
  S := Trim(copy(S, Pos(';', S) + 1, 255));
// если не послендний эл-т то  S1 := copy(S, 1, Pos(';', S) - 1);
  IsRequred := S = 'True';
{
  // выделяем имеет ли значение по умолчанию
  S := Trim(copy(S, Pos(';', S) + 1, 255));
  S1 := copy(S, 1, Pos(';', S) - 1);
  HasDef := S1 = 'True';
  // выделяем значение по умолчанию
  S := Trim(copy(S, Pos(';', S) + 1, 255));
// т.к. послений эл-т  S1 := copy(S, 1, Pos(';', S) - 1);
  DefVal := S;
}
  NumField:= 0;
  TypeOper:= crAdd;
end;


//   CREATE_NEW
constructor TFieldInfo.CreateNew(aNameField: String; aSize: Integer; aTypeField:
  Word;  aisRequred: Boolean; aNumField: Integer);
begin
  NameField:= aNameField;
  Size:= aSize;
  TypeField:= aTypeField;
  isRequred:= aIsRequred;
  TypeOper:= crDROP;
  NumField:= aNumField;
end;


{ TIndexInfo }


//   CREATE
constructor TIndexInfo.Create(const Line: String);
var
  S, S1: String;
begin
  S:= Trim(ReplaceComma(#39, Line));
  S1:= copy(S, 1, Pos(';', S) - 1);
  S1:= copy(S1, Pos('&', S1) + 1, 255);
  NameIndex:= Trim(copy(S1, 1, Pos('&', S1) - 1));
  S:= Trim(copy(S, Pos(';', S) + 1, 255));
  S:= Trim(copy(S, Pos('&', S) + 1, 255));
  NameIndexFields:= Trim(copy(S, 1, Pos('&', S) - 1));
  S:= Trim(copy(S, Pos('&', S) + 1, 255));
  S:= Trim(copy(S, Pos(';', S) + 1, 255));

  isPrimary:= Pos(IndexOptions[0], S) > 0;
  isUnique:= Pos(IndexOptions[1], S) > 0;
  isDescending:= Pos(IndexOptions[2], S) > 0;
  isCaseInsensitive:= Pos(IndexOptions[3], S) > 0;
  isExpression:= Pos(IndexOptions[4], S) > 0;
end;

{ TTableInfo }


//  CREATE
constructor TTableInfo.Create(const Line: String);
var
  S: String;
begin
  FieldsInfo:= TExList.Create;
  IndexsInfo:= TExList.Create;

  S:= Trim(Line);
  NameTable:= copy(S, Pos(' ', S) + 1, 255);
  TypeTable:= szParadox;
end;


//   DESTROY
destructor TTableInfo.Destroy;
begin
  FieldsInfo.Free;
  IndexsInfo.Free;
  inherited Destroy;
end;


//   SET_TYPE_TABLE
procedure TTableInfo.SetTypeTable(const Line: String);
var
  S: String;
begin
  S:= Trim(Line);
  TypeTable:= copy(S, Pos(' ', S) + 1, 255);
end;


//   ADD_FIELD
procedure TTableInfo.AddField(const Line: String);
begin
  FieldsInfo.Add(TFieldInfo.Create(Line));
end;


//   ADD_INDEX
procedure TTableInfo.AddIndex(const Line: String);
begin
  IndexsInfo.Add(TIndexInfo.Create(Line));
end;

{ TxRestructTable ------------------------------------------------------------}


//   CREATE
constructor TxRestructTable.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  TablesInfo:= TExList.Create;
  xProgressForm:= TxProgressForm.Create(Self);
  ErrorCode:= 0;
end;


//   DESTROY
destructor TxRestructTable.Destroy;
begin
  TablesInfo.Free;
  inherited Destroy;
end;


//   READ_STRUCT_INFO
function TxRestructTable.ReadStructInfo: Boolean;
var
  F: System.Text;
  S: String;
  isTableField, isIndex: Boolean;
  i, Nom: Integer;
begin
  TablesInfo.Free;
  TablesInfo:= TExList.Create;

  Result:= False;
  if StructInfo = '' then exit;
  AssignFile(F, StructInfo);
  Reset(F);
  if IOResult <> 0 then exit;

  isTableField:= False;
  isIndex:= False;
  while not EOF(F) do begin
    Readln(F, S);
    S:= Trim(S);
    if S <> '' then begin
      Nom:= -1;
      for i:= 0 to 3 do begin
        if Pos(StructOptions[i], S) > 0 then begin
          Nom:= i;
          Break;
        end;
      end;
      case Nom of
      0:
        begin
          isTableField:= False;
          isIndex:= False;
          TablesInfo.Add(TTableInfo.Create(S));
        end;
      1:
        begin
          TTableInfo(TablesInfo[TablesInfo.Count - 1]).SetTypeTable(S);
        end;
      2: isTableField:= True;
      3: begin
           isTableField:= False;
           isIndex:= True;
         end;
      else begin
        if isTableField then
          TTableInfo(TablesInfo[TablesInfo.Count - 1]).AddField(S)
        else
          if isIndex then
            TTableInfo(TablesInfo[TablesInfo.Count - 1]).AddIndex(S);
      end;
      end;
    end;
  end;
  CloseFile(F);
  Result:= True;
end;


//   OPEN_TABLE
function TxRestructTable.OpenTable(DBHandle: HDBIDB; NameTable: String;
  var dbiCur: hDBICur): Integer;
var
  ErrCode: Word;
begin
  Password := '';
  repeat
//  DbiOpenTable(DbHandle, PChar(TTableInfo(TablesInfo[Index]).NameTable),
//      nil, nil, nil, 0, dbiREADWRITE, dbiOPENEXCL, xltNONE, False, nil, dbiCur);

    ErrCode := DbiOpenTable(DbHandle, PChar(NameTable), nil, nil, nil, 0,
      dbiREADWRITE, dbiOPENEXCL, xltNONE, False, nil, dbiCur);

//    DbiOpenTable(DbHandle, StrPCopy(Temp, NameTable),
//      nil, nil, nil, 0, dbiREADWRITE, dbiOPENEXCL, xltFIELD, TRUE, nil, dbiCur);
    if ErrCode = DBIERR_NOTSUFFTABLERIGHTS then begin
      PasswordDlg:= TPasswordDlg.Create(Application);
      try
        if PasswordDlg.ShowModal = mrOk then begin
          Password:= PasswordDlg.Password.Text;
          dbiAddPassword(PChar(Password));
        end
        else
          Break;
      finally
        PasswordDlg.Free;
      end;
    end
    else
      if ErrCode <> 0 then
        Break;
  until (ErrCode = 0);
  Result:= ErrCode;
end;


//   DELETE_INDEX
function TxRestructTable.DeleteIndex(Index: Integer): Boolean;
var
  SearchRec: TSearchRec;
  Err: Integer;
  S: String;
begin
  Result := True;
  S := DatabasePath + '\' + TTableInfo(TablesInfo[Index]).NameTable;
  NameErrTable := TTableInfo(TablesInfo[Index]).NameTable;

  S := Copy(S, 1, Pos('.', S));

  Err := FindFirst(S + 'px', faAnyFile, SearchRec);
  if Err = 0 then
    DeleteFile(PChar(DatabasePath + '\' + SearchRec.Name));

  Err := FindFirst(S + 'x*', faAnyFile, SearchRec);
  while Err = 0 do begin
    DeleteFile(PChar(DatabasePath + '\' + SearchRec.Name));
    Err := FindFirst(S + 'x*', faAnyFile, SearchRec);
  end;

  Err := FindFirst(S + 'y*', faAnyFile, SearchRec);
  while Err = 0 do begin
    DeleteFile(PChar(DatabasePath + '\' + SearchRec.Name));
    Err := FindFirst(S + 'y*', faAnyFile, SearchRec);
  end;
end;


//   Upgrade_TABLE  ************************************************************
function TxRestructTable.UpgradeTable(DBHandle: HDBIDB; Index: Integer): Boolean;
var
  CProps: CurProps;
  dbiCur: hDBICur;
  FieldDesc: pFldDesc;
  OpType: pCROpType;
  VCOpType: pCROpType;
  Level: DBINAME;
  LvlFldDesc: FLDDesc;
  TheLevel: Integer;

  I, J: Integer;
  isModify: Bool;
  ErrCode: Word;
  tblDesc: CRTblDesc;
  St: String;
  Modified: Integer;
begin
  Result:= DeleteIndex(Index);
  if not Result then exit;

  ErrCode := OpenTable(DBHandle, PChar(TTableInfo(TablesInfo[Index]).NameTable), dbiCur);
//  DbiOpenTable(DbHandle, PChar(TTableInfo(TablesInfo[Index]).NameTable),
//      nil, nil, nil, 0, dbiREADWRITE, dbiOPENEXCL, xltNONE, False, nil, dbiCur);

  if ErrCode = 0 then
  begin
    Check(DbiGetCursorProps(dbiCur, CProps));
    TheLevel := CProps.iTblLevel;

    // отводим память под указатели
    FieldDesc := AllocMem(TTableInfo(TablesInfo[Index]).FieldsInfo.Count * sizeof(FLDDesc));
    OpType := AllocMem(TTableInfo(TablesInfo[Index]).FieldsInfo.Count * sizeof(CROpType));
    VCOpType := AllocMem(TTableInfo(TablesInfo[Index]).FieldsInfo.Count * sizeof(CROpType));

    // берем свойства курсора таблицы
    Check(dbiGetCursorProps(dbiCur, CProps));
    // заполняем дескриптор поля
    Check(dbiGetFieldDescs(dbiCur, FieldDesc));
    
    try
      for I := 0 to CProps.iFields - 1 do begin
        Inc(FieldDesc, I);
        St := StrPas(FieldDesc^.szName);

        for J := 0 to TTableInfo(TablesInfo[Index]).FieldsInfo.Count - 1 do
          with TFieldInfo(TTableInfo(TablesInfo[Index]).FieldsInfo[J]) do
          begin
            if CompareText(St, NameField) = 0 then
            begin
              TypeOper := crCopy;
              NumField := I + 1;
              if TypeField <> FieldDesc^.iFldType then TypeOper := crModify;
              if Size <> FieldDesc^.iUnits1 then TypeOper := crModify;
              if TheLevel < 7 then TypeOper := crModify;

              Break;
            end
            else begin

            end;
          end;
        Dec(FieldDesc, I);
      end;

      Modified := 0;
      for I := 0 to TTableInfo(TablesInfo[Index]).FieldsInfo.Count - 1 do
        if TFieldInfo(TTableInfo(TablesInfo[Index]).FieldsInfo[I]).TypeOper <> crCopy then
          Inc(Modified);

      if Modified > 0 then
        isModify := True
      else
        isModify := False;

      if TheLevel < 7 then
        TheLevel := 7;

      if isModify then
      begin
        for I := 0 to TTableInfo(TablesInfo[Index]).FieldsInfo.Count - 1 do begin
          Inc(FieldDesc, I);
          Inc(OpType, I);
          Inc(VCOpType, I);
          with TFieldInfo(TTableInfo(TablesInfo[Index]).FieldsInfo[I]) do begin
            // вид операции
            OpType^ := TypeOper;
            // имя поля
            StrPCopy(FieldDesc^.szName, NameField);
            // тил поля
            FieldDesc^.iFldType := TypeField;
            if TypeField = fldPDXMONEY then FieldDesc^.iSubType := fldPDXMONEY;
            // размер поля
            FieldDesc^.iUnits1 := Size;
            // номер по порядку
            if OpType^ = crAdd then FieldDesc^.iFldNum := I + 1
            else FieldDesc^.iFldNum := NumField;

            VCOpType^ := crModify;
          end;
          Dec(VCOpType, I);
          Dec(OpType, I);
          Dec(FieldDesc, I);
        end;                                

        FillChar(tblDesc, sizeof(tblDesc), #0);

        StrPCopy(tblDesc.szTblName, TTableInfo(TablesInfo[Index]).NameTable);
        StrPCopy(tblDesc.szTblType, szParadox);
        tblDesc.bPack:= True;
        tblDesc.iFldCount := TTableInfo(TablesInfo[Index]).FieldsInfo.Count;
        tblDesc.pecrFldOp := OpType;
        tblDesc.pFldDesc := FieldDesc;
        tblDesc.iValChkCount := 0;
        tblDesc.pvchkDesc := nil;

        tblDesc.iOptParams := 1;
        StrCopy(@Level, PChar(IntToStr(TheLevel)));
        tblDesc.pOptData := @Level;
        StrCopy(LvlFldDesc.szName, szCFGDRVLEVEL);
        LvlFldDesc.iLen := StrLen(Level) + 1;
        LvlFldDesc.iOffset := 0;
        tblDesc.pfldOptParams :=  @LvlFldDesc;

        dbiCloseCursor(dbiCur);

        Check(DbiDoRestructure(DBHandle, 1, @tblDesc, nil, nil, nil, False));
      end;
    finally
      if dbiCur <> nil then dbiCloseCursor(dbiCur);
      if FieldDesc <> nil then FreeMem(FieldDesc);
      if OpType <> nil then FreeMem(OpType);
      if VCOpType <> nil then FreeMem(VCOpType);
    end;
  end;
  ErrorCode := ErrCode;
  Result:= ErrorCode = 0;
end;


//   CREATE_TABLE
function TxRestructTable.CreateTable(DBHandle: HDBIDB; Index: Integer): Boolean;
var
  FieldDesc: pFldDesc;
  OpType: pCROpType;
  tblDesc: CRTblDesc;
  Level: DBINAME;
  LvlFldDesc: FLDDesc;
  
  I: Integer;
  ErrCode: Word;
  ErrInfo: DBIErrInfo;
begin
  FieldDesc:= AllocMem(TTableInfo(TablesInfo[Index]).FieldsInfo.Count * sizeof(FldDesc));
  OpType := AllocMem(TTableInfo(TablesInfo[Index]).FieldsInfo.Count * sizeof(CROpType));

  for I := 0 to TTableInfo(TablesInfo[Index]).FieldsInfo.Count - 1 do begin
    with TFieldInfo(TTableInfo(TablesInfo[Index]).FieldsInfo[I]) do begin
      Inc(FieldDesc, I);
      Inc(OpType, I);

      // тип поля
      FieldDesc^.iFldType := TypeField;
      if TypeField = fldPDXMONEY then FieldDesc^.iSubType := fldPDXMONEY;
      // имя поля
      StrPCopy(FieldDesc^.szName, NameField);
      // размер поля
      FieldDesc^.iUnits1 := Size;
      // номер по порядку
      FieldDesc^.iFldNum := I + 1;
      // тип операции (для всех crADD)
      OpType^ := TypeOper;

      Dec(OpType, I);
      Dec(FieldDesc, I);
    end;
  end;
  FillChar(tblDesc, SizeOf(tblDesc), 0);

  StrPCopy(TblDesc.szTblName, TTableInfo(TablesInfo[Index]).NameTable);
  StrPCopy(TblDesc.szTblType, szParadox);
  tblDesc.iFldCount:= TTableInfo(TablesInfo[Index]).FieldsInfo.Count;
  tblDesc.szPassword[0]:= #0;
  tblDesc.bProtected:= False;
  tblDesc.bPack:= True;

  tblDesc.pecrFldOp := OpType;
  tblDesc.pFldDesc := FieldDesc;
  tblDesc.pvchkDesc := nil;
  tblDesc.iValChkCount := 0;

  tblDesc.iOptParams := 1;
  StrCopy(@Level, PChar(IntToStr(7)));
  tblDesc.pOptData := @Level;
  StrCopy(LvlFldDesc.szName, szCFGDRVLEVEL);
  LvlFldDesc.iLen := StrLen(Level) + 1;
  LvlFldDesc.iOffset := 0;
  tblDesc.pfldOptParams :=  @LvlFldDesc;

  ErrCode:= dbiCreateTable(DBHandle, True, TblDesc);

  if ErrCode <> 0 then
  begin
    dbiGetErrorInfo(True, ErrInfo);
    showmessage(errinfo.szerrcode);
  end;

  if FieldDesc <> nil then FreeMem(FieldDesc);
  if OpType <> nil then FreeMem(OpType);
  ErrorCode:= ErrCode;
  Result:= ErrorCode = 0;
end;


//   REINDEX_TABLE
function TxRestructTable.ReindexTable(DBHandle: HDBIDB; Index: Integer): Boolean;
var
  CProps: CurProps;
  dbiCur: hDBICur;
  j, CountIndex: Integer;
  NewIndex: IDXDesc;
  Temp: array[0..255] of Char;
  S: String;
  FieldDesc: pFldDesc;
  ErrCode: Word;

  function GetFieldNum(const NameField: String): Integer;
  var
    k: Integer;
    S1: String;
  begin
    Result:= -1;
    dbiGetFieldDescs(dbiCur, FieldDesc);
    DbiTranslateRecordStructure(nil, CProps.iFields, FieldDesc, szParadox, nil, FieldDesc, False);

    for k:= 0 to CProps.iFields - 1 do
    begin
      S1:= StrPas(pFldDesc(Longint(Longint(FieldDesc)+SizeOf(FldDesc)*k))^.szName);
      
      if CompareText(S1, NameField) = 0 then
      begin
        Result:= k + 1;
        Break;
      end;
    end;
  end;

begin
  ErrCode:= OpenTable(dbHandle, TTableInfo(TablesInfo[Index]).NameTable, dbiCur);

  if ErrCode = 0 then
  begin
    dbiGetCursorProps(dbiCur, CProps);
    GetMem(FieldDesc, SizeOf(FldDesc) * CProps.iFields);

    for j:= 0 to TTableInfo(TablesInfo[Index]).IndexsInfo.Count - 1 do
    begin
      with TIndexInfo(TTableInfo(TablesInfo[Index]).IndexsInfo[j]) do
      begin
        NewIndex.bPrimary:= isPrimary;

        if NameIndex <> '' then
          StrPCopy(NewIndex.szName, NameIndex)
        else
          NewIndex.bPrimary:= True;

        S:= NameIndexFields;
        CountIndex:= 0;

        while (S <> '') and (Pos(';', S) > 0) do
        begin
          NewIndex.aiKeyFld[CountIndex]:= GetFieldNum(copy(S, 1, Pos(';', S) - 1));
          Inc(CountIndex);
          S:= copy(S, Pos(';', S) + 1, 255);
        end;

        NewIndex.aiKeyFld[CountIndex]:= GetFieldNum(S);
        NewIndex.iFldsInKey:= CountIndex + 1;
        NewIndex.bMaintained:= TRUE;
        NewIndex.bUnique:= isUnique;
        NewIndex.bDescending:= isDescending;
        NewIndex.bSubset:= FALSE;
        NewIndex.bExpIdx:= isExpression;
        NewIndex.bCaseInsensitive:= isCaseInsensitive;
      end;

      DbiAddIndex(DBhandle, dbiCur, Temp,  szParadox, NewIndex, nil);
    end;

    dbiCloseCursor(dbiCur);
    FreeMem(FieldDesc, SizeOf(FldDesc) * CProps.iFields);
  end;
  ErrorCode:= ErrCode;
  Result:= ErrorCode = 0;
end;


//   GET_ERROR_MESSAGE
procedure TxRestructTable.GetErrorMessage;
var
  ErrInfo: DBIErrInfo;
begin
  if ErrorCode <> 0 then begin
    frmErrorUpgrade:= TfrmErrorUpgrade.Create(Application);
    try
      if ErrorCode > 0 then begin
        dbiGetErrorInfo(True, ErrInfo);
        frmErrorUpgrade.xylErrorInfo.Caption:= StrPas(ErrInfo.szErrCode) + ', таблица ' +
          StrPas(ErrInfo.szContext[1]) + StrPas(ErrInfo.szContext[2]) + StrPas(ErrInfo.szContext[3]);
      end
      else begin
        frmErrorUpgrade.xylErrorInfo.Caption:=
          frmErrorUpgrade.xStrList.StrByIndex(1, abs(ErrorCode)) + ' , ' +
            NameErrTable;
      end;
      frmErrorUpgrade.ShowModal;
    finally
      frmErrorUpgrade.Free;
    end;
  end;
end;


//   Upgrade_TABLES
procedure TxRestructTable.UpgradeTables(DBHandle: HDBIDB);
var
  i: Integer;
  Temp: array[0..255] of Char;
begin
   dbiGetDirectory(DBHandle, False, Temp);
  DatabasePath:= StrPas(Temp);
  if ReadStructInfo then begin
    xProgressForm.Min:= 0;
    xProgressForm.Max:= TablesInfo.Count + 1;
    xProgressForm.Value:= 0;
    xProgressForm.Show;
    try
      for i:= 0 to TablesInfo.Count - 1 do begin
        xProgressForm.WaitMessage:= 'Проверка структуры ' +
          TTableInfo(TablesInfo[i]).NameTable;
        Application.ProcessMessages;
        if not UpgradeTable(DBHandle, i) then begin
          if ErrorCode = 10024 then
          begin
            xProgressForm.WaitMessage:= 'Создание таблицы ' +
              TTableInfo(TablesInfo[i]).NameTable;
            if not CreateTable(DBHandle, i) then Break;
          end
          else
            Break;
        end;
        xProgressForm.WaitMessage:= 'Создание индекса ' +
          TTableInfo(TablesInfo[i]).NameTable;
        Application.ProcessMessages;
        if not ReindexTable(DBHandle, i) then Break;
        if Password <> '' then
          dbiDropPassword(StrPCopy(Temp, Password));
        xProgressForm.Value:= xProgressForm.Value + 1;
      end;
    finally
      xProgressForm.Hide;
    end;
  end;
  GetErrorMessage;
end;


//   REGISTER
procedure Register;
begin
  RegisterComponents('xTool', [TxRestructTable]);
end;

end.

