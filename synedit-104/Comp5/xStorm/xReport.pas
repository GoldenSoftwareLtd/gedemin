

{++

  Components: xReport and accompaning sub-components
  Copyright (c) 1996 - 97 by Golden Software of Belarus

  Module

    xReport.pas

  Abstract

    Enhanced report component with RTF file support.

  Author

    Vladimir Belyi (February, 1997)

  Contact address

    andreik@gs.minsk.by
    vladimir@belyi.minsk.by

  Uses

    Units:

      xBasics
      xAbout
      NumConv
      xWorld
      xRTF

    Forms:

      xRepPrvF

    Other files:


  Revisions history

    1.00  14-mar-1997  belyi   Initial version.
    1.01   5-apr-1997  belyi   User fields. Memo fields. Bugs.
    1.02   7-apr-1997  belyi   Now RTF file structure can be sent to viewer
                               without memory consuming copying.
    1.03   9-apr-1997  belyi   Quicker and takes less memory. Vars property.
    1.04  15-apr-1997  belyi   Graphic fields.
    1.05  21-apr-1997  belyi   Multiple tables. Bugs.
    1.06   8-may-1997  belyi   Subgroups.
    1.07  17-may-1997  belyi   Bugs with empty blocks, with subgroups killed.
    1.08  27-jul-1997  belyi   Minor bugs and updates. Support for single-record
                               reports.
    1.09  14-aug-1997  belyi   Bug with number-text conversion.
    1.10  29-aug-1997  belyi   Updates with summed fields formatting.
    1.11   5-oct-1997  belyi   Minor updates.
    1.12  11-oct-1997  belyi   Direct on-disk report creation (now size
                               limitations).
    1.13  26-oct-1997  belyi   Formula evaluation in group and table end fields.
    1.14  10-oct-1997  belyi   Float Fields format added
    1.15  14-nov-1997  belyi   Groups with limited fields count added. Bug with
    1.16  22-nov-1997  belyi   Arithmetics in all fields added. A lot of bugs killed.
    1.17   1-dec-1997  belyi   Updates for reports with empty TableRow section
    1.18  14-jan-1998  belyi   Field result limit option added.
    1.19  24-feb-1998  belyi   Termination button added.
    1.20  27-oct-1999  JKL     Translate component.
    1.21  27-oct-1999  JKL     Replace xWorld to gsMultilingualSupport.
    1.22  23-jan-2001  andreik Added RuntimePath & DesigntimePath properties.
                               Changed def. charset for font from DEFAULT to
                               RUSSIAN (fuck 'em!). 

  Known bugs

    - CompletePage won't work

  Wishes

    -

  Notes / comments

    23-янв-01:

    Я добавил два свойста RuntimePath & DesigntimePath для того чтобы можно было
    удобно работать с путем к файлу формы при разработке программы. Теперь
    в FormFile указывается только имя файла формы. В DesigntimePath указывается только
    путь к каталогу, где находится файл формы в момент отладки/разработки, а
    в RuntimePath -- путь к каталогу, где находится файл формы при выполнении
    приложения.

    Все существующие приложения, где полное имя файла указано в FormFile будут
    работать как и раньше.

    -- andreik

  Questions

    -

--}

{$A+,B-,D+,F-,G+,I+,K+,L+,N+,P+,Q-,R-,S+,T-,V+,W-,X+,Y+}

unit xReport;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, Printers, StdCtrls, DsgnIntF,
  xBasics, xAbout, NumConv, {xWorld,} xRTF, xRTFSubs, xCalc, xRTFPrgF,
  gsMultilingualSupport;

type
  TDestinations = (dsScreen, dsFile, dsPrinter, dsUserEvent);

type
  TReportReadyEvent = procedure(Sender: TObject; var RTFFile: TxRTFFile)
    of object; { fill free to replace RTFFile while in event handler -
      this is up to you. BUT be carefull - the component will try to free
      the object which will be returned by the event handler.
      E.g.: you may exchange RTFFile with the one stored in Data property
      of RTF file Viewer.
      NOTE: preview will show the object you will return from event handler.
      So, either don't replace the RTFFile referenced object, or do not use
      standard preview/printing. }
  TUserFieldEvent = procedure(Sender: TObject; FieldName: string;
    var FieldResult: string) of object;

  TxRepOption = (frMsgIfTerminated, frAlwaysOpenDataSet, frSingleRecord);
  TxRepOptions = set of TxRepOption;

const
  MaxGroupCount = 10;
  OptionsChar: char = '/';
  OptionCount = 21;
  OptionsList: array[0..OptionCount - 1] of string =
    ('S', 'TEXT', 'T', 'USER', 'NOZERO', 'NEGATIVE', 'POSITIVE',
     'Z+', 'Z-', 'NONPOSITIVE', 'NONNEGATIVE', 'Z!-', 'Z!+', 'Z',
     'RESETON', 'FORMFIELD', 'F', 'R', 'SUM', 'LENGTHLIMIT', 'L');

type
  TxGroup = class
    GroupField: string;
    RescueGroupField: string;
    GroupValue: string;
    LongGroupValue: Integer; { for rows with fised number of rows }
    GroupLastPage: Integer; { if group requires certain number of rows on last page }
    GroupTotal: Integer; { if group requires to have at least this number of rows }
    { next TxRTFBlock fields are just references - they should not be
      destroyed in destructor! }
    GroupHeader: TxRTFBlock;
    GroupEnd: TxRTFBlock;
    GroupSummedFields: TClassList;
    GroupEndFields: TClassList;
    function LastPageFinished: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function NumberedGroupLimit: Boolean;
    function NumberedGroup: Boolean;
    procedure IncRecNo;
    procedure ZeroGroup(ZeroLong: Boolean);
  end;

  TxDef = class
    TableName: string;
    { next TxRTFBlock fields are just references - they should not be
      destroyed in destructor! }
    TableStart: TxRTFBlock; {i.e. the text an DATA section of RTF file }
    TableHeader: TxRTFBlock;
    TableRow: TxRTFBlock;
    TableEnd: TxRTFBlock;
    Groups: TClassList;
    TableSummedFields: TClassList;
    TableEndFields: TClassList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  PxRTFBlock = ^TxRTFBlock;

  TxReportRTF = class(TxRTFFile)
  private
    { to store blocks ID's for different report parts }
    Defs: TClassList;

    { next to fields are valid only during reading of RTF file }
    CurrentGroup: TxGroup;

    LastAssigner: PxRTFBlock;

  protected
    procedure NextParaLoaded; override;
    procedure StartNewTable(TableName: string);

  public
    constructor Create; override;
    destructor Destroy; override;

    property LocDefs: TClassList read Defs;
  end;

  TxRepField = class
    Name: string;
    Value: string;
    ResetOn: Integer;
    TotalRows: Integer;
  end;

  TSingleSource = class
    Name: string;
    Source: TDataSource;
  end;

  TxMathField = class(TxElementList)
  protected
    procedure FillList; override;
    procedure SetText(Value: string); override;
  end;

  TToText = (ttDoNot, ttLower, ttFirstCap, ttUpper);
  TNoZero = (nzAny, nzNoZero, nzPositive, nzNegative,
    nzNonPositive, nzNonNegative);

  TFormatOptions = record
    ToText: TToText;
    NoZero: TNoZero;
    FloatFormat: string;
    RoundLimit: Extended;
    LengthLimit: Integer;
  end;

  TxReport = class(TComponent)
  private
    { Private declarations }
    Executing: Boolean;
    FCaption: string;

    TableIsStarted: Boolean;
    Terminated: Boolean;
    RepeatLoop: Boolean; {true если Execute должно самовыполниться еще раз
                          (например, если нехватило памяти при построении отчета)}

    NumberConverter: TNumberConvert;

    FDestination: TDestinations;
    NewDestination: TDestinations; { used in conjunction with RepeatLoop }
    FVars: TxValueList;
    FAliases: TStringList;
    FFormFile, FDesignTimePath, FRunTimePath: String;
    FOutputFile: String;
    FDataSources: TxValueList;
    FAbout: TxAbout;

    FOnReportReady: TReportReadyEvent;
    FOnUserField: TUserFieldEvent;
    FShowPrintDialog: Boolean;

    procedure SetVars(Value: TxValueList);

    function IsSummedField(FldName: string): Boolean;
    procedure ZeroFields(List: TClassList; ChangeLevel: Integer);
    procedure UpdateFields(List: TClassList; ActiveBlock: TxRTFBlock);
    procedure SetDataSources(Value: TxValueList);
    function FindToText(const s: string): TToText;
    function FindNoZero(s: string): TNoZero;
    function FindFloatFormat(const s: string): string;
    function FindFormatOptions(const s: string): TFormatOptions;
    function OptFloatValue(const s: string; OptName: string): Extended;
    function GetTextField(FldName: string): string;
    function NormalizeFieldName(FldName: string): string;
    function GetRealFormFileName: String;

  protected
    RTFFile: TxReportRTF;
    RTFOut: TxRTFFile;
    RTFOutputFile: TxRTFWriter;

    FDataSource: TDataSource;
    FOptions: TxRepOptions;
    TableIndex: Integer; { index of the table in print }
    CurrentTableDef: TxDef;

    FCheckFileExsist: Boolean;
    function CreateOutputFile: Boolean; virtual;

    procedure AddTableStart;
    procedure AddTableHeader;
    procedure AddTableRecord(CheckGroups: Boolean);
    procedure AddTableEnd;
    procedure AddGroupHeader(Index: Integer);
    procedure AddGroupEnd(Index: Integer);
    procedure SendData;
    { Protected declarations }
    procedure BuildReport;
    procedure PrintReport;
    procedure PreviewReport; virtual;
    function GetField(AVar: string):string; virtual;
    function GetGraphicField(MFld: TxMathField): TGraphicField;
    function GetMemoField(MFld: TxMathField): TMemoField;
    procedure FillField(Fld: TxRTFField);
    procedure FillFields(Block: TxRTFBlock);
    procedure FillEndFields(Block: TxRTFBlock; Fields: TClassList);
    function MakeText(Value: string; Opt: TFormatOptions): string;
    procedure MoveToRTFOut(Block: TxRTFBlock);
    procedure SendTable(Index: Integer); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadDataSource(Reader: TReader); { for compatibility with
      old versions }
    procedure PrepareSummedFields;
    function ExtractFieldName(Fld: TxRTFField): string;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Execute: Boolean;

    property RealFormFileName: String read GetRealFormFileName;

    property ShowPrintDialog: Boolean read FShowPrintDialog write FShowPrintDialog;

  published
    { Published declarations }
    property Options: TxRepOptions read FOptions write FOptions;
    property Destination: TDestinations read FDestination
      write FDestination;
    property FormFile: string read FFormFile write FFormFile;
    property RunTimePath: string read FRunTimePath write FRunTimePath;
    property DesignTimePath: string read FDesignTimePath write FDesignTimePath;
    property OutputFile: string read FOutputFile write FOutputFile;
    property Vars: TxValueList read FVars write SetVars;
    property DataSources: TxValueList read FDataSources write SetDataSources;
    property About: TxAbout read FAbout write FAbout;
    property Caption: string read FCaption write FCaption;
    property OnReportReady: TReportReadyEvent read FOnReportReady
      write FOnReportReady;
    property OnUserField: TUserFieldEvent read FOnUserField
      write FOnUserField;
  end;

type
  ExReport = class(ExStorm);

var
  lnRecNo: Integer;
  lnNotCreated: Integer;
  lnFileNotFound: Integer;

procedure Register;

implementation

{.$R XREPORT.RES}

uses
  xRepPrvF,
//  xRepPrgF,
  xRepDSF,
  jclSysUtils;

const
  RESOURCE_BASE = 19000;

const
  optDBField = '#';
  optUserField = '@';
  optGroupLimitField = '/';
  optFormField = ':';

function FindOption(Opt: string; s: string): Integer;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
   if (copy(s, i, Length(Opt) + 1) = OptionsChar + Opt) and
     ( (i + Length(Opt) + 1 > Length(s)) or
       not(s[i + Length(Opt) + 1] in ['a'..'z','A'..'Z', '0'..'9']) ) then
    begin
      Result := i;
      exit;
    end;
  Result := 0;
end;

{ TxGroup }
constructor TxGroup.Create;
begin
  inherited Create;
  GroupSummedFields := TClassList.Create;
  GroupEndFields := TClassList.Create;
  GroupLastPage := -1;
  GroupTotal := -1;
end;

destructor TxGroup.Destroy;
begin
  GroupSummedFields.Free;
  GroupEndFields.Free;
  inherited Destroy;
end;

function TxGroup.LastPageFinished: Boolean;
begin
  if (GroupField <> '') and (GroupField[1] = optGroupLimitField) and (GroupLastPage <> -1) then
    Result := StrToInt(GroupValue) >= GroupLastPage

  else if (GroupField <> '') and (GroupField[1] = optGroupLimitField) and (GroupTotal <> -1) then
    Result := LongGroupValue >= GroupTotal

  else
    Result := true;
end;

function TxGroup.NumberedGroupLimit: Boolean;
var
  s, s1: string;
begin
  { check for changing numbers }
  s := Trim(EndOfString(GroupField, 2));
  if pos(',', s) <> 0 then
    s1 := copy(s, 1, pos(',', s) - 1)
  else
    s1 := s;

  Result := Trim(s1) = GroupValue;

  if Result then
   begin
     if pos(',', s) <> 0 then
      GroupField := optGroupLimitField + Trim(EndOfString(s, pos(',', s) + 1));
   end;
end;

function TxGroup.NumberedGroup: Boolean;
begin
  Result := GroupField[1] = optGroupLimitField;
end;

procedure TxGroup.IncRecNo;
begin
  GroupValue := IntToStr(StrToInt(GroupValue) + 1);
  inc(LongGroupValue);
end;

procedure TxGroup.ZeroGroup(ZeroLong: Boolean);
begin
  GroupValue := '0';
  if ZeroLong then
    LongGroupValue := 0;
end;


{ TxDef }
constructor TxDef.Create;
begin
  inherited Create;
  TableSummedFields := TClassList.Create;
end;

destructor TxDef.Destroy;
begin
  if Groups <> nil then Groups.Free;
  TableSummedFields.Free;
  inherited Destroy;
end;


{ ================= TxReportRTF ================= }

constructor TxReportRTF.Create;
begin
  inherited Create;
  Defs := TClassList.Create;
  LastAssigner := nil;
end;

destructor TxReportRTF.Destroy;
begin
  Defs.Free;
  inherited Destroy;
end;

procedure TxReportRTF.StartNewTable(TableName: string);
var
  ADef: TxDef;
begin
  ADef := TxDef.Create;
  ADef.TableName := TableName;
  Defs.Add(ADef);
end;

procedure TxReportRTF.NextParaLoaded;
var
  LastPara: TxRTFPara;
  ParaText: string;
  BlockName: string;
  j: Integer;
  Assigner: PxRTFBlock;
begin
  LastPara := TxRTFPara(TxRTFBlock(LastItem).LastItem);
  if not(CurrentBlock.ReadingTableRow) and
    (LastPara is TxRTFTextPara) then
   begin
     ParaText := UpperCase(Trim(TxRTFTextPara(LastPara).AsText));
     if (Length(ParaText) > 0) and
        (ParaText[1] = '%') then
       begin
         { read block-name word }
         j := 2;
         while (j <= Length(ParaText)) and (ParaText[j] in ['A'..'Z']) do
           inc(j);
         dec(j);
         BlockName := Copy(ParaText, 2, j - 1);
         ParaText := Trim(EndOfString(ParaText, j + 1));

         if (BlockName = 'TABLEHEADER') or
            (BlockName = 'TABLEROW') or
            (BlockName = 'TABLEEND') or
            (BlockName = 'GROUP') or
            (BlockName = 'GROUPEND') or
            (BlockName = 'END') or
            (BlockName = 'DATA') then
          begin
            if (BlockName = 'DATA') then
              StartNewTable(ParaText)
            else if Defs.Count = 0 then
              StartNewTable('DefaultTable');

            { remove the last para loaded - it has the next block name }
            CurrentBlock.Data.Remove(CurrentBlock.LastItem);

            if not CurrentBlock.IsEmpty then
             begin
               CurrentBlock := TxRTFBlock.CreateChild(self);
               AddData(CurrentBlock);
             end
            else
             begin
               if (LastAssigner <> nil) and
                  (LastAssigner^ = CurrentBlock) then
                LastAssigner^ := nil;
             end;

            Assigner := nil;

            if BlockName = 'TABLEHEADER' then
              Assigner := addr(TxDef(Defs.Last).TableHeader)
            else if BlockName = 'TABLEROW' then
              Assigner := addr(TxDef(Defs.Last).TableRow)
            else if BlockName = 'TABLEEND' then
              Assigner := addr(TxDef(Defs.Last).TableEnd)
            else if BlockName = 'GROUP' then
             begin
               if TxDef(Defs.Last).Groups = nil then
                 TxDef(Defs.Last).Groups := TClassList.Create;
               CurrentGroup := TxGroup.Create;
               TxDef(Defs.Last).Groups.Add(CurrentGroup);
               {CurrentGroup.GroupHeader := CurrentBlock;}

               if xParamIndex(ParaText, 'RowLimit') <> -1 then
                begin
                  CurrentGroup.GroupField := optGroupLimitField +
                    xParamValue(ParaText, xParamIndex(ParaText, 'RowLimit'));

                  if xParamIndex(ParaText, 'LastPage') <> -1 then
                    CurrentGroup.GroupLastPage :=
                      StrToInt(Trim(xParamValue(ParaText, xParamIndex(ParaText, 'LastPage'))));

                  if xParamIndex(ParaText, 'TotalRows') <> -1 then
                    CurrentGroup.GroupTotal :=
                      StrToInt(Trim(xParamValue(ParaText, xParamIndex(ParaText, 'TotalRows'))));
                end
               else
                 CurrentGroup.GroupField := optDBField + ParaText;
               Assigner := addr(CurrentGroup.GroupHeader);
             end
            else if BlockName = 'GROUPEND' then
              Assigner := addr(CurrentGroup.GroupEnd)
            else if BlockName = 'DATA' then
              Assigner := addr(TxDef(Defs.Last).TableStart)
            else if BlockName = 'END' then
              { this is the Report Form File end - just omitting all text after };

            if Assigner <> nil then
              Assigner^ := CurrentBlock;

            LastAssigner := Assigner;
          end;
       end;
   end;
end;

{ ================= TxMathField ================= }

procedure TxMathField.FillList;
var
  s1, s2: string;
  i, j: Integer;
  x: Extended;
  er: Integer;

  function OptionStart(Index: Integer): Integer;
  var
    k: Integer;
  begin
    for k := 0 to OptionCount - 1 do
     if (UpperCase(copy(FText, Index, 1 + Length(OptionsList[k]))) =
        '/' + OptionsList[k]) and
        ( (Index + 1 + Length(OptionsList[k]) >= Length(FText)) or
          not(FText[Index + 1 + Length(OptionsList[k])] in ['a'..'z', 'A'..'Z', '0'..'9'])) then
      begin
        Result := 1 + Length(OptionsList[k]);

        if OptionsList[k] = 'F' then
         begin
           while FText[Result + Index] = ' ' do inc(Result);
           if FText[Result + Index] <> '"' then
             raise ExReport.Create('Form file error: incorrect /F field format')
           else inc(Result);
           while FText[Result + Index] <> '"' do inc(Result);
           inc(Result);
         end;

        if OptionsList[k] = 'R' then
          while FText[Result + Index] in [' ', DecimalSeparator, '0'..'9'] do inc(Result);

        exit;
      end;
    Result := 0;
  end;

begin
  FText := Trim(FText);
  i := 1;
  while (i <= Length(FText)) and (pos(FText[i], '-(){}[] ') <> 0) do inc(i);
  while i <= Length(FText) do
   begin
     if (FText[i] = '/') and (OptionStart(i) > 0) then
      j := i + OptionStart(i)
     else
      begin
        j := i + 1;
        while (j <= Length(FText)) and
              ( (UpCase(FText[j]) in ['A'..'Z', ' ', '_', '0'..'9']) or
                ( (FText[j] = '/') and (OptionStart(j) > 0) ) ) do
         begin
           if FText[j] = '/' then
             inc(j, OptionStart(j))
           else
             inc(j);
         end;
      end;
     s1 := copy(FText, i, j - i);

     //val(Trim(s1), x, er);
     // Bug was here!!!!!!!!!!!!!
        
     try
       if not ((s1 = 'ROUND') or (s1 = 'ROUND10') or (S1 = 'ROUND100') or (S1 = 'ROUND1000')) then
       begin
         if not TextToFloat(PChar(Trim(s1)), x, fvExtended) then
         begin
           x := 0;
           er := 1;
         end else
           er := 0;
       end else begin
         x := 0;
         er := 0;
       end;
     except
       er := 1;
       x := 0;
     end;

     if x <> 0 then {bad Delphi even if else};
     if (er <> 0) then
      begin
        s1 := Trim(s1);
        delete(FText, i, j - i);
        s2 := '#' + IntToStr(FElements.Add(s1)) + '';
        if s1[1] <> OptionsChar then
         begin
           insert(s2, FText, i);
           inc(i, Length(s2));
         end;
      end
     else
        inc(i, Length(s1));

     while (i <= Length(FText)) and
           ( (pos(FText[i], '-+*(){}[]<>= ') <> 0) or
             ((FText[i] = '/') and not(OptionStart(i) > 0)) ) do inc(i);
   end;
end;

procedure TxMathField.SetText(Value: string);
begin
  inherited SetText(Value);
  if not Evaluated then Evaluate;
end;

{ ================= TxReport ================= }

constructor TxReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TableIsStarted := false;
  FOptions := [frMsgIfTerminated, frAlwaysOpenDataSet];
  FShowPrintDialog := True;
  FDestination := dsScreen;
  FVars := TxValueList.Create;
  FOutputFile := '';
  FCaption := '';

  FAbout := TxAbout.Create;

  FAbout.Add(LoadStr(RESOURCE_BASE)); {!!!}
  FAbout.Add('');
  FAbout.Add(LoadStr(RESOURCE_BASE + 1));
{
  FAbout.Add('  xReport component is a delicate way to create great '+
    'reports with a few keystrokes.');
  FAbout.Add('');
  FAbout.Add('  You just should create an RTF file ' +
    'with your favourite text processor and pass it to this component!');
}

  FCheckFileExsist := True;
  NumberConverter := TNumberConvert.Create(self);
  Executing := false;

  FDataSources := TxValueList.Create;
end;

destructor TxReport.Destroy;
begin
  FVars.Free;
  FAliases.Free;
  FAbout.Free;
  DataSources.Free;
  inherited destroy;
end;

procedure TxReport.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('DataSource', ReadDataSource, nil, false);
end;

procedure TxReport.ReadDataSource(Reader: TReader);
var
  x: TValueType;
begin
  Reader.Read(x, SizeOf(x));
  FDataSources.Add('DefaultTable = ''' + Reader.ReadStr + '''');
end;

procedure TxReport.SetVars(Value: TxValueList);
begin
  FVars.Assign(Value);
end;

function TxReport.GetField(AVar: string): string;
var
  Fld: TField;
  OptChar: Char;
  UserNum: Integer;
begin
  OptChar := AVar[1];
  AVar := Trim(AVar);
  Delete(AVar, 1, 1);
  case OptChar of
    optDBField:
     if FDataSource <> nil then
      begin
        Fld := FDataSource.DataSet.FindField(AVar);
        if (Fld = nil) then
          Result := '?' + AVar + '?'
        else
          Result := Fld.Text;
      end
     else Result := LoadStr(RESOURCE_BASE + 2);
    optUserField:
     begin
       UserNum := Vars.VarIndex(AVar);
       if UserNum <> -1 then
         Result := Vars.Values[UserNum]
       else
        begin
          Result := '?' + AVar + '?';
          if Assigned(FOnUserField) then
            FOnUserField(self, AVar, Result);
        end;
     end;
  end;
end;

procedure TxReport.BuildReport;
begin
end;

procedure TxReport.PrintReport;
begin
end;

procedure TxReport.PreviewReport;
var
  Form: TxReportPreviewForm;
begin
  Form := TxReportPreviewForm.Create(Application);
  try
    Form.Viewer.ExchangeData(RTFOut);
    if FCaption <> '' then
      Form.Caption := Format(FCaption, [RealFormFileName])
    else
      Form.Caption := TranslateText('Отчет по файлу ') + RealFormFileName;
    Form.SourceFileName := RealFormFileName;
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TxReport.FillFields(Block: TxRTFBlock);
var
  i: Integer;
begin
  for i := 0 to Block.FormFields.Count - 1 do
    FillField(Block.FormFields[i]);
end;

function TxReport.MakeText(Value: string; Opt: TFormatOptions): string;
var
  Buf: array[1..1000] of char;
  FloatValue: Extended;
  x, x1: Extended;
  WithError: Boolean;
begin
  Result := Value;
  WithError := false;

  if Opt.RoundLimit <> 0 then
   begin
     x := xStrToFloat(Result) / Opt.RoundLimit;
     x1 := Abs(Frac(x));
     if x1 >= 0.5 then x1 := 1 else x1 := 0;
     if x <> 0 then
       x := Int(x) + x1 * x / Abs(x);
     Result := FloatToStr(x * Opt.RoundLimit);
   end;

  if (Opt.NoZero <> nzAny) or (Opt.ToText <> ttDoNot) or (Opt.FloatFormat <> '') then
   begin
     try
       FloatValue := xStrToFloat(Result)
     except
       on exception do
        begin
          FloatValue := 0;
          WithError := true;
        end;
     end
   end
  else
    FloatValue := 0;

  if Opt.FloatFormat <> '' then
   Result := FormatFloat(Opt.FloatFormat, FloatValue);

  { through away numbers above/below zero, if necessary }
  case Opt.NoZero of
    nzAny: ; { with this line it is supposed to work faster }
    nzNoZero: if Result = '0' then Result := '';
    nzPositive: if FloatValue <= 0 then Result := '';
    nzNegative: if FloatValue >= 0 then Result := '';
    nzNonPositive: if FloatValue > 0 then Result := '';
    nzNonNegative: if FloatValue < 0 then Result := '';
  end;

  { convert to text if necessary }
  if (Opt.ToText <> ttDoNot) and (Result <> '') then
   begin
     NumberConverter.Value := FloatValue;
     if GetCurrentLang = 'rus' then
     {Поменял местами then и else. Один проблема. 'eng' не фиксирована}
     //if Phrases.Language = xWorld.lRussian then
       NumberConverter.Language := NumConv.lRussian
     else
       NumberConverter.Language := NumConv.lEnglish;
     Result := NumberConverter.Numeral;
     StrPCopy(@Buf, Result);
     if Opt.ToText = ttUpper then
       AnsiUpperBuff(@Buf, StrLen(@Buf))
     else if Opt.ToText = ttFirstCap then
       AnsiUpperBuff(@Buf, 1);
     Result := StrPas(@Buf);
   end;

  if (Opt.LengthLimit <> 0) and (Length(Result) > Opt.LengthLimit) then
   begin
     if Opt.LengthLimit > 3 then
       Result := copy(Result, 1, Opt.LengthLimit - 3) + '...'
     else
       Result := '...';
   end;

  if WithError then
    Result := TranslateText('>>Ошибка<<');

  if Result = '' then Result := ' '; { to escape errors with empty field height }
end;

function TxReport.GetGraphicField(MFld: TxMathField): TGraphicField;
var
  Name: string;
  Fld: TField;
begin
  Result := nil;
  if FDataSource = nil then exit;
  if (MFld.ElementCount <> 1)  then exit;
  Name := NormalizeFieldName(MFld.Elements[0]);
  delete(Name, 1, 1);
  Fld := FDataSource.DataSet.FindField(Name);
  if (Fld <> nil) and (Fld is TGraphicField) then
    Result := TGraphicField(Fld);
end;

function TxReport.GetMemoField(MFld: TxMathField): TMemoField;
var
  Name: string;
  Fld: TField;
begin
  Result := nil;
  if FDataSource = nil then exit;
  if (MFld.ElementCount <> 1) then exit;
  Name := NormalizeFieldName(MFld.Elements[0]);
  delete(Name, 1, 1);
  Fld := FDataSource.DataSet.FindField(Name);
  if (Fld <> nil) and (Fld is TMemoField) then
    Result := TMemoField(Fld);
end;

{ checks whether field should be cenverted to text }
function TxReport.FindToText(const s: string): TToText;
begin
  if (FindOption('T', s) <> 0) or (FindOption('TEXT', s) <> 0) then
    Result := ttUpper
  else if FindOption('Text', s) <> 0 then
    Result := ttFirstCap
  else if FindOption('t', s) <> 0 then
    Result := ttLower
  else if FindOption('text', s) <> 0 then
    Result := ttLower
  else if FindOption('text', LowerCase(s)) <> 0 then
    Result := ttLower
  else
    Result := ttDoNot;
end;

{ checks whether field should not be printed if above/below zero }
function TxReport.FindNoZero(s: string): TNoZero;
begin
  Result := nzAny;

  s := UpperCase(s); { these options are not case insensitive }

  {note: do not join ifs through 'else if' }
  if (FindOption('NOZERO', s) <> 0) or (FindOption('Z', s) <> 0) then
    Result := nzNoZero;

  if (FindOption('POSITIVE', s) <> 0) or (FindOption('Z+', s) <> 0) then
    Result := nzPositive;

  if (FindOption('NEGATIVCE', s) <> 0) or (FindOption('Z-', s) <> 0) then
    Result := nzNegative;

  if (FindOption('NONPOSITIVE', s) <> 0) or (FindOption('Z!+', s) <> 0) then
    Result := nzNonPositive;

  if (FindOption('NONNEGATIVE', s) <> 0) or (FindOption('Z!-', s) <> 0) then
    Result := nzNonNegative;
end;

{ checks whether field has specific float format }
function TxReport.FindFloatFormat(const s: string): string;
var
  FPos: Integer;
begin
  Result := '';
  FPos := FindOption('F', UpperCase(s));
  if FPos > 0 then
   begin
     inc(FPos, 2);
     while (FPos <= Length(s)) and (s[FPos] <> '"') do inc(FPos);
     if FPos > Length(s) then
       raise ExReport.Create('Float format error: ' + s);

     inc(FPos);

     while (FPos <= Length(s)) and (s[FPos] <> '"') do
      begin
        Result := Result + s[FPos];
        inc(FPos);
      end;
     if FPos > Length(s) then
       raise ExReport.Create('Float format error: ' + s);
   end;
end;

{ возвращает значение в числовой опции, например '/example 67.5' вернет 67.5 }
function TxReport.OptFloatValue(const s: string; OptName: string): Extended;
var
  FPos: Integer;
  s1: string;
begin
  Result := 0;
  FPos := FindOption(OptName, UpperCase(s));
  if FPos > 0 then
   begin
     inc(FPos, 1 + Length(OptName));
     s1 := '';
     while (FPos <= Length(s)) and (s[FPos] in [' ']) do inc(FPos);
     while (FPos <= Length(s)) and (s[FPos] in ['0'..'9', DecimalSeparator]) do
       begin
         s1 := s1 + s[FPos];
         inc(FPos);
       end;

     Result := xStrToFloat(s1);
   end;
end;

{ checks whether field should be rounded }
function TxReport.FindFormatOptions(const s: string): TFormatOptions;
begin
  Result.ToText := FindToText(s);
  Result.NoZero := FindNoZero(s);
  Result.FloatFormat := FindFloatFormat(s);
  Result.RoundLimit := OptFloatValue(s, 'R');
  Result.LengthLimit := Round(OptFloatValue(s, 'L'));
  if Result.LengthLimit = 0 then
    Result.LengthLimit := Round(OptFloatValue(s, 'LENGTHLIMIT'));
end;

function TxReport.GetTextField(FldName: string): string;
begin
  Result := MakeText( GetField( NormalizeFieldName(FldName)),
    FindFormatOptions(FldName) );
end;

procedure TxReport.FillField(Fld: TxRTFField);
var
  GrFld: TGraphicField;
  MemoFld: TMemoField;
  b: Graphics.TBitmap;
  bInfo: WinTypes.TBitmap;
  Strings: TStringList;
  i, j: Integer;
  RTFBitmap: TxRTFBitmap;
  FormatOptions, xFormatOptions: TFormatOptions;
  MFld: TxMathField;
  s, s1, sx: string;
  px: Integer;
  Calc: TxFoCal;
  CalcField: Boolean;
begin
  { fill text/number fields }
  Calc := TxFoCal.Create(nil);
  try
    MFld := TxMathField(Fld.iReportPointer);
    s := MFld.Text;
    CalcField := StringsIntersect('-+/*()', s);

    { find whether this field should be converted to text or so on }
    s1 := '';
    for j := 0 to MFld.ElementCount - 1 do
     if MFld.Elements[j][1] = OptionsChar then
       s1 := s1 + MFld.Elements[j];

    FormatOptions := FindFormatOptions(s1);

    for j := 0 to MFld.ElementCount - 1 do
     if MFld.Elements[j][1] <> OptionsChar then
      begin
        s1 := NormalizeFieldName(MFld.Elements[j]);

        xFormatOptions := FindFormatOptions(MFld.Elements[j]);
        xFormatOptions.LengthLimit := 0;

        s1 := GetTextField(MFld.Elements[j]);

        if CalcField and (Trim(s1) = '') then
          s1 := '0';

        if CalcField then
          s1 := '(' + s1 + ')';

        sx := '#' + IntToStr(j);
        px := Pos(sx, s);
        if px = 0 then
          MessageDlg(LoadStr(RESOURCE_BASE + 3), mtError, [mbOk], 0)
        else
         begin
           delete(s, px, Length(sx));
           insert(s1, s, px);
         end;
      end;

    if CalcField then
     begin
       Calc.Expression := s;
       TxRTFField(Fld).SetResult(
         MakeText(FloatToStr(Calc.Value), FormatOptions));
     end
    else
      TxRTFField(Fld).SetResult(s);
  finally
    Calc.Free;
  end;


   GrFld := GetGraphicField(MFld);
  if GrFld <> nil then
   begin
     Fld.ClearResult;

     b := TBitmap.Create;
     try
       b.Assign(GrFld);

       RTFBitmap := TxRTFBitmap.CreateChild(Fld);
       RTFBitmap.BM := DuplicateBitmap( b.Handle );
       GetObject(RTFBitmap.BM, SizeOf(bInfo), @bInfo);
       with RTFBitmap.Info do
        begin
          PicWidth := bInfo.bmWidth;
          PicHeight := bInfo.bmHeight;
          DesiredWidth := 1000;
          DesiredHeight := 1000;
          ScaleX := 100;
          ScaleY := 100;
        end;
       Fld.AppendResult(RTFBitmap);

     finally
       b.Free;
     end;
   end;


  MemoFld := GetMemoField(MFld);
  if MemoFld <> nil then
   begin
     Strings := TStringList.Create;
     try
       Strings.Assign(MemoFld);

       Fld.ClearResult;

       for i := 0 to Strings.Count - 1 do
        if i = 0 then
          Fld.FieldResult := StrAdd(Fld.FieldResult, Strings[i])
        else
          Fld.FieldResult := StrAdd(Fld.FieldResult, ' ' + Strings[i]);

       Fld.RegisterResult;
     finally
       Strings.Free;
     end;
   end;
end;

procedure TxReport.FillEndFields(Block: TxRTFBlock; Fields: TClassList);
var
  i, j: Integer;
  FormatOptions, xFormatOptions: TFormatOptions;
  MFld: TxMathField;
  s, s1, sx: string;
  px: Integer;
  Calc: TxFoCal;
  CalcField: Boolean;

  function GetSummedValue(FldName: string): string;
  var
    j: Integer;
    Fld: TField;
  begin
    for j := 0 to Fields.Count - 1 do
      if FldName = TxRepField(Fields[j]).Name then
       begin
         if FldName[1] = optDBField then
          begin
            if FDataSource <> nil then
             begin
               Fld := FDataSource.DataSet.FindField(EndOfString(FldName, 2));
               if (Fld <> nil) then
                begin
                  if Fld is TFloatField then
                    TxRepField(Fields[j]).Value :=
                      FormatFloat((Fld as TFloatField).DisplayFormat,
                      xStrToFloat(TxRepField(Fields[j]).Value))

                  else if Fld is TWordField then
                    TxRepField(Fields[j]).Value :=
                      FormatFloat((Fld as TWordField).DisplayFormat,
                      xStrToFloat(TxRepField(Fields[j]).Value))

                  else if Fld is TIntegerField then
                    TxRepField(Fields[j]).Value :=
                      FormatFloat((Fld as TIntegerField).DisplayFormat,
                      xStrToFloat(TxRepField(Fields[j]).Value));
                end;
             end
          end;
         Result := TxRepField(Fields[j]).Value;
        end;
  end;

begin
  Calc := TxFoCal.Create(nil);
  try
    for i := 0 to Block.FormFields.Count - 1 do
     begin
       MFld := TxMathField(TxRTFField(Block.FormFields[i]).iReportPointer);
       s := MFld.Text;
       CalcField := StringsIntersect('-+/*()', s);

       { find whether this field should be converted to text or so on }
       s1 := '';
       for j := 0 to MFld.ElementCount - 1 do
        if MFld.Elements[j][1] = OptionsChar then
          s1 := s1 + MFld.Elements[j];

       FormatOptions := FindFormatOptions(s1);

       for j := 0 to MFld.ElementCount - 1 do
        if MFld.Elements[j][1] <> OptionsChar then
         begin
           s1 := NormalizeFieldName(MFld.Elements[j]);

           xFormatOptions := FindFormatOptions(MFld.Elements[j]);
           xFormatOptions.LengthLimit := 0;

           if (FindOption('S', UpperCase(MFld.Elements[j])) <> 0) or
              (FindOption('SUM', UpperCase(MFld.Elements[j])) <> 0) then
            begin
              s1 := GetSummedValue(s1);
              if MFld.ElementCount = 1 then
                s1 := MakeText(s1, xFormatOptions);
            end
           else
             s1 := GetTextField(MFld.Elements[j]);

           if CalcField and (Trim(s1) = '') then
             s1 := '0';

           if CalcField then
             s1 := '(' + s1 + ')';

           sx := '#' + IntToStr(j);
           px := Pos(sx, s);
           if px = 0 then
             MessageDlg(LoadStr(RESOURCE_BASE + 3), mtError, [mbOk], 0)
           else
            begin
              delete(s, px, Length(sx));
              insert(s1, s, px);
            end;
         end;

       if CalcField then
        begin
          Calc.Expression := s;
          TxRTFField(Block.FormFields[i]).SetResult(
            MakeText(FloatToStr(Calc.Value), FormatOptions));
        end
       else
         TxRTFField(Block.FormFields[i]).SetResult(s);
     end;
  finally
    Calc.Free;
  end;
end;

procedure TxReport.AddTableStart;
var
  Block: TxRTFBlock;
begin
  if CurrentTableDef.TableStart <> nil then
   begin
     Block := TxRTFBlock.CreateChild(RTFOut);
     Block.Assign(CurrentTableDef.TableStart);
     FillFields(Block);{ really, there shoul be no fields in this section }

     MoveToRTFOut(Block);
   end;
end;

procedure TxReport.AddTableHeader;
var
  Block: TxRTFBlock;
begin
  if CurrentTableDef.TableHeader <> nil then
   begin
     Block := TxRTFBlock.CreateChild(RTFOut);
     Block.Assign(CurrentTableDef.TableHeader);
     FillFields(Block);

     MoveToRTFOut(Block);
   end;
end;

procedure TxReport.AddTableEnd;
var
  Block: TxRTFBlock;
begin
  if CurrentTableDef.TableEnd <> nil then
   begin
     Block := TxRTFBlock.CreateChild(RTFOut);
     Block.Assign(CurrentTableDef.TableEnd);
     FillEndFields(Block, CurrentTableDef.TableSummedFields);

     MoveToRTFOut(Block);
   end;
end;

procedure TxReport.AddGroupHeader(Index: Integer);
var
  Block: TxRTFBlock;
  i: Integer;
begin
  for i := MaxInt(Index, 0) to CurrentTableDef.Groups.Count - 1 do
   begin
     if i > Index then
      TxGroup(CurrentTableDef.Groups[i]).RescueGroupField :=
        TxGroup(CurrentTableDef.Groups[i]).GroupField;

     if TxGroup(CurrentTableDef.Groups[i]).GroupHeader <> nil then
      begin
        Block := TxRTFBlock.CreateChild(RTFOut);
        Block.Assign(TxGroup(CurrentTableDef.Groups[i]).GroupHeader);
        FillFields(Block);

        MoveToRTFOut(Block);
      end;

     ZeroFields(TxGroup(CurrentTableDef.Groups[i]).GroupSummedFields, Index);

     if TxGroup(CurrentTableDef.Groups[i]).GroupField <> '' then
      begin
        if TxGroup(CurrentTableDef.Groups[i]).GroupField[1] = optGroupLimitField then
          TxGroup(CurrentTableDef.Groups[i]).ZeroGroup(Index < i)
        else
          TxGroup(CurrentTableDef.Groups[i]).GroupValue :=
            GetField(TxGroup(CurrentTableDef.Groups[i]).GroupField);
      end;
   end;
end;

procedure TxReport.AddGroupEnd(Index: Integer);
var
  Block: TxRTFBlock;
  i: Integer;
  Over: Boolean;
begin
  Application.ProcessMessages;
  { check if there are some groups with fixed number of rows }
  if Index < CurrentTableDef.Groups.Count - 1 then
   repeat
     Over := TxGroup(CurrentTableDef.Groups[Index + 1]).LastPageFinished;

     if not(Over) and (CurrentTableDef.TableRow <> nil) then
      begin
        Block := TxRTFBlock.CreateChild(RTFOut);
        Block.Assign(CurrentTableDef.TableRow);

        for i := 0 to Block.FormFields.Count - 1 do
          TxRTFField(Block.FormFields[i]).SetResult('');

        MoveToRTFOut(Block);

        if CurrentTableDef.Groups <> nil then
         begin
           for i := 0 to CurrentTableDef.Groups.Count - 1 do
            if TxGroup(CurrentTableDef.Groups[i]).NumberedGroup then
              TxGroup(CurrentTableDef.Groups[i]).IncRecNo;

           for i := Index + 1 to CurrentTableDef.Groups.Count - 1 do
            if TxGroup(CurrentTableDef.Groups[i]).NumberedGroup and
              TxGroup(CurrentTableDef.Groups[i]).NumberedGroupLimit then
               begin
                 AddGroupEnd(i);
                 if TxGroup(CurrentTableDef.Groups[Index + 1]).LastPageFinished then
                   exit;
                 AddGroupHeader(i);
                 AddTableHeader;
                 //i := CurrentTableDef.Groups.Count - 1;
                 break;
               end;
         end;
      end;
   until Over;

  { finish groups below Index }
  for i := CurrentTableDef.Groups.Count - 1 downto MaxInt(Index, 0) do
   begin
     if i > Index then
      TxGroup(CurrentTableDef.Groups[i]).GroupField :=
        TxGroup(CurrentTableDef.Groups[i]).RescueGroupField;
     if TxGroup(CurrentTableDef.Groups[i]).GroupEnd <> nil then
      begin
        Block := TxRTFBlock.CreateChild(RTFOut);
        Block.Assign(TxGroup(CurrentTableDef.Groups[i]).GroupEnd);
        FillEndFields(Block, TxGroup(CurrentTableDef.Groups[i]).GroupSummedFields);

        MoveToRTFOut(Block);
      end;
   end;
end;

procedure TxReport.MoveToRTFOut(Block: TxRTFBlock);
var
  aBlock: TxRTFBlock;
begin
  aBlock := TxRTFBlock.CreateChild(RTFOut);
  xRTFCopyFormFields := false;
  try
    aBlock.Assign(Block);
    Block.Free;
  finally
    xRTFCopyFormFields := true;
  end;

  if RTFOut.Count = 0 then
    RTFOut.AddData(aBlock)
  else
   begin
     TxRTFBlock(RTFOut.LastItem).JoinBlock(aBlock);
     aBlock.Free;
   end;

  if Destination = dsFile then
   while RTFOut.Count > 0 do
    begin
      RTFOut.Items[0].WriteRTF(RTFOutputFile);
      RTFOut.DeleteItem(0);
    end;
end;

procedure TxReport.AddTableRecord(CheckGroups: Boolean);
var
  Block: TxRTFBlock;
  i: Integer;

  procedure UpdateSummedFields;
  var
    i: Integer;
  begin
    if CurrentTableDef.Groups <> nil then
     begin
       for i := 0 to CurrentTableDef.Groups.Count - 1 do
         UpdateFields(TxGroup(CurrentTableDef.Groups[i]).GroupSummedFields, Block);
     end;

    UpdateFields(CurrentTableDef.TableSummedFields, Block);
  end;

begin
  { check for group change }
  if CurrentTableDef.Groups <> nil then
   begin
     i := 0;
     while i < CurrentTableDef.Groups.Count do
      begin
        { check if this groups terminates on rows amount }
        if TxGroup(CurrentTableDef.Groups[i]).NumberedGroup then
         begin
           if TxGroup(CurrentTableDef.Groups[i]).NumberedGroupLimit then
            begin
              AddGroupEnd(i);
              AddGroupHeader(i);
              AddTableHeader;
              i := CurrentTableDef.Groups.Count;
            end;
         end

        else if CheckGroups then
         begin
           if GetField(TxGroup(CurrentTableDef.Groups[i]).GroupField) <>
              TxGroup(CurrentTableDef.Groups[i]).GroupValue then
            begin
              AddGroupEnd(i);
              AddGroupHeader(i);
              AddTableHeader;
              i := CurrentTableDef.Groups.Count;
            end;
         end;

        inc(i);
      end;
   end;

  { add record }
  if CurrentTableDef.TableRow <> nil then
   begin
     Block := TxRTFBlock.CreateChild(RTFOut);
     Block.Assign(CurrentTableDef.TableRow);
     FillFields(Block);

     UpdateSummedFields;

     MoveToRTFOut(Block);
   end
  else
   begin
     Block := nil;
     UpdateSummedFields;
   end;

   if CurrentTableDef.Groups <> nil then
    begin
      for i := 0 to CurrentTableDef.Groups.Count - 1 do
        if TxGroup(CurrentTableDef.Groups[i]).GroupField[1] = optGroupLimitField then
          TxGroup(CurrentTableDef.Groups[i]).IncRecNo;
    end;

  { go to next record }
  if FDataSource <> nil then
    FDataSource.DataSet.Next;
end;

procedure TxReport.SendData;
const
  TimesNo = 20;
type
  TTimes = array[0..TimesNo - 1] of Cardinal;
var
//  Form: TReportProgressForm;
  RecNo, LastNo, RecCount: Cardinal;
  Times: ^TTimes;
  i: Integer;
  ThresholdTime, NewThreshold: LongInt;
  WastedTime: Cardinal; { time wasted while waiting for user input }
  DialogStart: Cardinal;
  SaveDialog: TSaveDialog;

  procedure SendSingleRecord;
  var
    i: Integer;
  begin
    AddTableRecord(true);
    inc(RecNo);
    if RecNo - LastNo > 4 then
     begin
       LastNo := RecNo;               {Здесь использовалось Phrases[lnRecNo]}
       RTFProgress.Update(RecNo, Format(TranslateText('Обработано %d записей из %d.'), [RecNo, RecCount]));
       {Form.ProgressLbl.Caption :=
         Format(Phrases[lnRecNo], [RecNo, RecCount]);}

       if RecNo div 5 < TimesNo then
        begin
          Times^[RecNo div 5] := GetTickCount - WastedTime;
          if RecNo div 5 > 0 then
            ThresholdTime := (Times^[RecNo div 5] - Times^[0]) div (RecNo div 5);
        end
       else
        begin
          for i := 0 to TimesNo - 2 do
            Times^[i] := Times^[i + 1];
          Times^[TimesNo - 1] := GetTickCount - WastedTime;

          NewThreshold := (Times^[TimesNo - 1] - Times^[0]) div TimesNo;
          if (NewThreshold > ThresholdTime * 5) and not(RTFProgress.Terminated)
             and (FDestination <> dsFile) then
           begin
             SaveDialog := TSaveDialog.Create(Application);
             try
               DialogStart := GetTickCount;
               //Form.FormStyle := fsNormal;
               SaveDialog.DefaultExt := 'rtf';
               SaveDialog.Filter := 'RTF|*.RTF';
               SaveDialog.Options := [ofOverwritePrompt, ofPathMustExist,
                 ofNoReadOnlyReturn];
               if (MessageBox(0,
                 PChar(TranslateText('Скорость построения отчета резко упала. ') +
                 TranslateText('Вероятно у Вас недостаточно оперативной памяти. ') +
                 TranslateText('Настоятельно рекомендуется создать отчет в файл и затем распечатать ') +
                 TranslateText('его из Microsoft Word.')),
                 PChar(TranslateText('Нехватка оперативной памяти')), MB_YESNO) = IDYES) and
                 SaveDialog.Execute then
                begin
                  RTFProgress.Terminated := true;
                  RepeatLoop := true;
                  NewDestination := dsFile;
                  OutputFile := SaveDialog.FileName;
                end;
               WastedTime := WastedTime + GetTickCount - DialogStart;
               ThresholdTime := (ThresholdTime * 3) div 2;
             finally
               SaveDialog.Free;
             end;
           end;

          ThresholdTime := MinInt(ThresholdTime, NewThreshold);
        end;

       Application.ProcessMessages;
     end;
  end;

begin
  New(Times);
  //Form := TReportProgressForm.Create(self);
  RTFProgress.Start(TranslateText('Идет обработка базы данных для формирования отчета.') + #13 +
    TranslateText('Подождите немного, пока программа просканирует все записи...'), '',
    'Прервать создание отчета?', 0);
  try
    RecNo := 0; LastNo := 0; RecCount := 0;
    for i := 0 to TimesNo - 1 do
      Times^[i] := GetTickCount;
    WastedTime := 0;

    { data sending block }
    if (FDataSource <> nil) and not(frSingleRecord in FOptions) then
     begin
       RecCount := FDataSource.DataSet.RecordCount;
       RTFProgress.UpdateMaxValue(RecCount);
       while not(FDataSource.DataSet.EOF) and
             not(RTFProgress.Terminated) do SendSingleRecord;
     end
    else
      SendSingleRecord;
  finally
    Terminated := Terminated or RTFProgress.Terminated;
    RTFProgress.Stop;
    Dispose(Times);
    Application.ProcessMessages;
  end;
end;

function TxReport.IsSummedField(FldName: string): Boolean;
begin
  Result := (FindOption('S', UpperCase(FldName)) <> 0) or
            (FindOption('SUM', UpperCase(FldName)) <> 0);
end;

function TxReport.NormalizeFieldName(FldName: string): string;
var
  OptPos: Integer;
begin
  { read field name }
  OptPos := pos(OptionsChar, FldName);
  if OptPos <> 0 then
    Result := Trim( copy( FldName, 1, OptPos - 1 ) )
  else
    Result := FldName;

  { distinguish dbase and user fields }
  if FindOption('USER', UpperCase(FldName)) <> 0 then
    Result := optUserField + Result
  else if FindOption('FORMFIELD', UpperCase(FldName)) <> 0 then
    Result := optFormField + Result
  else
    Result := optDBField + Result;
end;

function TxReport.ExtractFieldName(Fld: TxRTFField): string;
begin
  Result := NormalizeFieldName(Fld.DataField.DefaultText);
end;

procedure TxReport.ZeroFields(List: TClassList; ChangeLevel: Integer);
var
  i: Integer;
begin
  for i := 0 to List.Count - 1 do
   begin
     if TxRepField(List[i]).ResetOn >= ChangeLevel then
       TxRepField(List[i]).Value := '0';
   end;
end;

procedure TxReport.UpdateFields(List: TClassList; ActiveBlock: TxRTFBlock);
var
  i, j: Integer;
  Index: Integer;
  s1, s2: string;
begin
  for i := 0 to List.Count - 1 do
   try
    if (TxRepField(List[i]).Name[1] = optFormField) and (ActiveBlock <> nil) then
     begin
       Index := -1;
       for j := 0 to ActiveBlock.FormFields.Count - 1 do
         if CompareText(TxRTFField(ActiveBlock.FormFields[j]).DataField.Name,
           EndOfString(TxRepField(List[i]).Name, 2)) = 0 then Index := j;

     s1 := TxRepField(List[i]).Name;
     s2 := TxRepField(List[i]).Value;
       if Index <> -1 then
        TxRepField(List[i]).Value := FloatToStr(
          StringToFloat(TxRepField(List[i]).Value) +
          StringToFloat(StrPas(TxRTFField(ActiveBlock.FormFields[Index]).FieldResult)));
     s2 := TxRepField(List[i]).Value;
     end
    else
     begin
     s1 := TxRepField(List[i]).Name;
     s2 := TxRepField(List[i]).Value;
     TxRepField(List[i]).Value := FloatToStr(
       StringToFloat(TxRepField(List[i]).Value) +
       StringToFloat(GetField(TxRepField(List[i]).Name)));
     s2 := TxRepField(List[i]).Value;
     end;
   except
     on EConvertError do ; { ignore errors with number conversions }
   end;
end;

function TxReport.CreateOutputFile: Boolean;
var
  TI: Integer;
  i: Integer;
begin
  Result := false; { was not created }

  if not RTFFile.LoadRTF(RealFormFileName) then
   begin
     if frMsgIfTerminated in FOptions then  {Здесь использовалось Phrases[lnNotCreated]}
       MessageDlg(TranslateText('Отчет не был создан вероятно из-за прерывания пользователем.'), mtInformation, [mbOk], 0);
     exit;
   end;

  for TI := 0 to RTFFile.Defs.Count - 1 do
   begin
     if TxDef(RTFFile.Defs[TI]).TableHeader <> nil then
      begin
        for i := 0 to TxDef(RTFFile.Defs[TI]).TableHeader.Count - 1 do
          if TxDef(RTFFile.Defs[TI]).TableHeader.Items[i] is TxRTFTableRow then
            (TxDef(RTFFile.Defs[TI]).TableHeader.Items[i] as TxRTFTableRow).IsHeader := true;
      end;
   end;

  RTFOut.AssignFormat(RTFFile);
  RTFOut.CopyHeaderFooter(RTFFile);

  if Destination = dsFile then
    RTFOut.WriteRTFHeader(RTFOutputFile);

  Result := true;
end;

procedure TxReport.PrepareSummedFields;
var
  i, j: Integer;
  Fld: TxRepField;
  MFld: TxMathField;
  Gr: Integer;
  ResetPos: Integer;

  function GroupIndex(s: string): Integer;
  var
    i, ps: Integer;
    ss: string;
  begin
    s := UpperCase(s);
    ps := pos(OptionsChar, s);
    if ps <> 0 then
      s := Trim(copy(s, 1, ps - 1));
    for i := 0 to CurrentTableDef.Groups.Count - 1 do
     begin
       ss := TxGroup(CurrentTableDef.Groups[i]).GroupField;
       if (TxGroup(CurrentTableDef.Groups[i]).GroupField[1] <> optGroupLimitField) and
          (UpperCase(EndOfString(TxGroup(CurrentTableDef.Groups[i]).GroupField, 2)) = s) then
        begin
          Result := i;
          exit;
        end;
     end;
    raise ExReport.Create('Form File Error: Reference to undeclared group!');
  end;

begin
  { create a list of summed fields: }
  CurrentTableDef.TableSummedFields.Clear;

  for i := 0 to RTFFile.FormFields.Count - 1 do
   begin
     MFld := TxMathField.Create;
     MFld.Text :=
       TxRTFField(RTFFile.FormFields[i]).DataField.DefaultText;
     TxRTFField(RTFFile.FormFields[i]).iReportPointer := MFld;
   end;

  if CurrentTableDef.Groups <> nil then
   for Gr := 0 to CurrentTableDef.Groups.Count - 1 do
    begin
      TxGroup(CurrentTableDef.Groups[Gr]).GroupSummedFields.Clear;
      if TxGroup(CurrentTableDef.Groups[Gr]).GroupEnd <> nil then
       begin
         for i := 0 to TxGroup(CurrentTableDef.Groups[Gr]).GroupEnd.FormFields.Count - 1 do
          begin
            MFld := TxMathField(TxRTFField(TxGroup(CurrentTableDef.Groups[Gr]).GroupEnd.FormFields[i]).iReportPointer);
            for j := 0 to MFld.ElementCount - 1 do
             if IsSummedField(MFld.Elements[j]) then
              begin
                Fld := TxRepField.Create;
                Fld.Name := NormalizeFieldName(MFld.Elements[j]);
                ResetPos := FindOption('RESETON', UpperCase(MFld.Elements[j]));
                if ResetPos <> 0 then
                  Fld.ResetOn := GroupIndex(Trim(EndOfString(MFld.Elements[j], ResetPos + 8)))
                else
                  Fld.ResetOn := Gr;
                TxGroup(CurrentTableDef.Groups[Gr]).GroupSummedFields.Add(Fld);
              end;
          end;
         ZeroFields(TxGroup(CurrentTableDef.Groups[Gr]).GroupSummedFields, 0);
       end;
    end;

  if CurrentTableDef.TableEnd <> nil then
   begin
     for i := 0 to CurrentTableDef.TableEnd.FormFields.Count - 1 do
      begin
        {MFld := TxMathField.Create;
        MFld.Text := TxRTFField(CurrentTableDef.TableEnd.FormFields[i]).DataField.DefaultText;
        TxRTFField(CurrentTableDef.TableEnd.FormFields[i]).iReportPointer := MFld;}
        MFld := TxMathField(TxRTFField(CurrentTableDef.TableEnd.FormFields[i]).iReportPointer);
        for j := 0 to MFld.ElementCount - 1 do
         if IsSummedField(MFld.Elements[j]) then
          begin
            Fld := TxRepField.Create;
            Fld.Name := NormalizeFieldName(MFld.Elements[j]);
            Fld.ResetOn := 0; { this parameter is valid for group fields only }
            CurrentTableDef.TableSummedFields.Add(Fld);
          end;
      end;
     ZeroFields(CurrentTableDef.TableSummedFields, 0);
   end;
end;

procedure TxReport.SendTable(Index: Integer);
var
  BookMark: TBookmark;
  Comp: TComponent;
  UseDataSource: Boolean;
  s: string;
  TheTableName: string;
  i: Integer;
begin
  Bookmark := nil; // Delphi is fucker

  { fix current table }
  TableIndex := Index;
  CurrentTableDef := TxDef(RTFFile.Defs[TableIndex]);

  PrepareSummedFields;

  s := FDataSources.GetVarValue(TxDef(RTFFile.Defs[Index]).TableName);
  UseDataSource := FDataSources.GetVarValue(TxDef(RTFFile.Defs[Index]).TableName) <> '';

  { find data source for current table }
  if UseDataSource then
   begin
     TheTableName := FDataSources.GetVarValue(TxDef(RTFFile.Defs[Index]).TableName);
     if pos('.', TheTableName) = 0 then
       Comp := Owner.FindComponent(TheTableName)
     else
      begin
        i := 0;
        while (i < Screen.DataModuleCount) and
              (CompareText( Screen.DataModules[i].Name,
                            Copy(TheTableName, 1, pos('.', TheTableName) - 1)) <> 0) do
          inc(i);

        if i < Screen.DataModuleCount then
          Comp := Screen.DataModules[i].FindComponent(
            EndOfString(TheTableName, pos('.', TheTableName) + 1))
        else
          Comp := nil; // datasource is in unknown datamodule
      end;

     if not(Comp is TDataSource) then
      begin
        raise ExReport.Create('Could not locate datasource ' +
          FDataSources.GetVarValue(TxDef(RTFFile.Defs[Index]).TableName));
      end;
     FDataSource := Comp as TDataSource;
     if frAlwaysOpenDataSet in FOptions then
       FDataSource.DataSet.Open;

     { proceed with the data }
     Bookmark := FDataSource.DataSet.GetBookmark;
     FDataSource.DataSet.DisableControls;
   end
  else
   FDataSource := nil;

  try
    if (FDataSource <> nil) and not(frSingleRecord in FOptions) then
      FDataSource.DataSet.First;

    AddTableStart;

    if (FDataSource = nil) or
       ((FDataSource <> nil) and not(FDataSource.DataSet.EOF)) then
     begin
       if CurrentTableDef.Groups <> nil then
         AddGroupHeader(-1);

       AddTableHeader;

       SendData;

       if CurrentTableDef.Groups <> nil then
         AddGroupEnd(-1);
     end;

    AddTableEnd;

  finally
    if FDataSource <> nil then
     begin
       FDataSource.DataSet.GotoBookmark(Bookmark);
       FDataSource.DataSet.EnableControls;
       FDataSource.DataSet.FreeBookmark(Bookmark);
     end;
  end;
  TableIndex := -1;
end;

function TxReport.Execute: Boolean;
var
  i: Integer;
begin
  Result := false;

  if Executing then
    raise ExReport.Create(LoadStr(RESOURCE_BASE + 5));

  if FCheckFileExsist and not(FileExists(RealFormFileName)) then {Здесь использовалось Phrases[lnFileNotFound]}
    raise ExReport.Create( Format(TranslateText('Файл формы %s не найден...'), [RealFormFileName]));

  Executing := true;
  repeat
    Terminated := false;
    RepeatLoop := false;

    try
      RTFFile := TxReportRTF.Create;
      RTFOut := TxRTFFile.Create;
      try
        RTFProgress.Start(TranslateText('Создание отчета'), '', TranslateText('Прервать создание отчета?'), 1);
        try
          if Destination = dsFile then
            RTFOutputFile := TxRTFWriter.Create(RealFileName(OutputFile));

          try
            if not CreateOutputFile then exit;

            for i := 0 to RTFFile.Defs.Count - 1 do
             if not Terminated then
               SendTable(i);

          finally
            if Destination = dsFile then
              RTFOutputFile.Free;
          end;
        finally
          RTFProgress.Stop;
        end;

        if Assigned(FOnReportReady) and not Terminated then
          FOnReportReady(self, RTFOut);

        if (Destination = dsScreen) and not Terminated then
          PreviewReport;

        if (Destination = dsPrinter) and not Terminated then
          RTFOut.PrintRTF2(ShowPrintDialog);

      finally
        RTFFile.Free;
        RTFOut.Free;
      end;

    finally
      Executing := false;
    end;

    if RepeatLoop then
      FDestination := NewDestination;

  until not RepeatLoop;

  Result := not Terminated;
end;

procedure TxReport.SetDataSources(Value: TxValueList);
begin
  FDataSources.Assign(Value);
end;

{ ========= TDataSourcesProperty =============== }

type
  TDataSourcesProperty = class(TPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    function GetValue: string; override;
  end;

function TDataSourcesProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TDataSourcesProperty.GetValue: string;
begin
  Result := 'DataSources';
end;

procedure TDataSourcesProperty.Edit;
var
  Form: TDataSourcesForm;
  i, j: Integer;
  RTF: TxReportRTF;
  List: TxValueList;
  AName: string;
  Present: Boolean;
begin
  List := TxReport(GetComponent(0)).DataSources;
  Application.CreateForm(TDataSourcesForm, Form);
  try
    RTF := TxReportRTF.Create;
    try
      if not RTF.LoadRTF((GetComponent(0) as TxReport).RealFormFileName) then
       begin
         if MessageDlg(LoadStr(RESOURCE_BASE + 6),
           mtError, [mbOk, mbCancel], 0) = mrCancel then Abort;
       end
      else
       begin
         { delete not present tables }
         i := 0;
         while i < List.Count do
          begin
            AName := List.Names[i];
            Present := false;
            for j := 0 to RTF.Defs.Count - 1 do
              Present := Present or
                (CompareText(AName, TxDef(RTF.Defs[j]).TableName) = 0);
            if not Present then
              List.Delete(i)
            else
             inc(i);
          end;

         { add new tables }
         for i := 0 to RTF.Defs.Count - 1 do
           if List.VarIndex(TxDef(RTF.Defs[i]).TableName) = -1 then
             List.Add(TxDef(RTF.Defs[i]).TableName + ' = ' + '''''');
       end;
    finally
      RTF.Free;
    end;

    Form.List.Items.Assign(List);
    Form.List.ItemIndex := 0;
    Form.FormDesigner := Designer;
    Form.SList := TxValueList.Create;
    try
      Form.SList.Assign(List);
      Form.ShowModal;
    finally
      Form.SList.Free;
    end;
    List.Assign(Form.List.Items);
  finally
    Form.Free;
  end;
end;


{--------------------------- registration ------------------------}
procedure Register;
begin
  RegisterComponents('xStorm', [TxReport]);
  RegisterPropertyEditor(TypeInfo(TxValueList), TxReport, 'DataSources',
    TDataSourcesProperty);
end;

function TxReport.GetRealFormFileName: String;
begin
  if csDesigning in ComponentState then
    Result := RealFileName(iff(FDesignTimePath > '', IncludeTrailingBackslash(FDesignTimePath) + FFormFile, FFormFile))
  else
    Result := RealFileName(iff(FRunTimePath > '', IncludeTrailingBackslash(FRunTimePath) + FFormFile, FFormFile));
end;

initialization
  {Phrases.SetOrigin('xTools: Report components');

  lnRecNo := Phrases.AddPhrase(lEnglish, '%d of %d records processed so far.');
  Phrases.AddTranslation(lnRecNo, lRussian, 'Обработано %d записей из %d.');

  lnNotCreated := Phrases.AddPhrase(lEnglish,
    'Report was not created probably due to user termination.');
  Phrases.AddTranslation(lnNotCreated, lRussian,
    'Отчет не был создан вероятно из-за прерывания пользователем.');

  lnFileNotFound := Phrases.AddPhrase(lEnglish, 'Form file %s could not be found...');
  Phrases.AddTranslation(lnFileNotFound, lRussian, 'Файл формы %s не найден...');


  Phrases.ClearOrigin;}

end.

