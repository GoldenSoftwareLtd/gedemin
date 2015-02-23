{++

  Components: FReport and accompaning sub-components
  Copyright (c) 1996 - 97 by Golden Software of Belarus

  Module

    FReport.pas

  Abstract

    Fast report component.

  Author

    Vladimir Belyi (March, 1996)

  Contact address

    andreik@gs.minsk.by

  Uses

    Units:

      xBasics
      xText
      xAbout
      NumConv
      xWorld

    Forms:

      xFRepVw

    Other files:


  Revisions history

    1.00  01-mar-1996  belyi   Initial version.
    1.01  15-jul-1996  andreik Font property added.
    1.02  20-aug-1996  belyi   Records No support. /A option.
                               Group section added.
    1.03  30-dec-1996  belyi   PageWidth property and other changes.
    1.04   5-jan-1997  belyi   LongLine property. /S option. New events.
                               Some code optimization.
    1.05  16-jan-1997  belyi   Printing methods replaced. Print preview added.
    1.06  18-jan-1997  belyi   /T option.
    1.07  20-feb-1997  michael Add isLast
    1.08  17-oct-1997  michael Fixed bug.
    1.09  06-may-2000  michael Add variable section
    1.10  29-nov-2005  andreik _LinesOnPage variable added.

  Known bugs

    -

  Wishes

    -

  Notes / comments

    -

  Questions

    -

--}

unit xFReport;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, Printers,
  NumConv, ExList, xCalc,
  {$IFDEF GEDEMIN}
  xFRepView_unit,
  {$ELSE}
  xFRepVw,
  {$ENDIF}
  xText, xBasics;

type
  Outputs = (opFile, opPrinter);

const
  FormBlocks = 11;
  ObligatoryBlocks = 9;
  GroupID = 10; { which of them is group block }

type
  PElement = ^TElement;
  TElement = record
    Name: string;
    DataBaseField: Boolean;
    Start: integer;
    Size: integer;
    Align: char;
    Cut: Boolean;
    Summed: Boolean;
    MakeText: Boolean;
    Decimals: Boolean;
    Money: Boolean;
    QuantityFormat: Boolean;
    BlankZero: Boolean; 
    Row: Integer;
    Column: Integer;
    FirstOccurrence: Boolean;
    LastOccurrence: Boolean;
    Wrap: Boolean;
    Value: string;
    SumValue: string; { if summed then here is the current sum }
    Next: PElement;
  end;

  TBlock = class
    Owner: TComponent;
    List: TStringList;
    FirstField: TElement;
    FieldsCount: Integer;
    SwapList: TStringList;
    GoPrevious: Integer;  { if > 0, one of the previous record will be used
                            for the evaluation of this block }
    function GetField(Nom: integer): PElement;
    constructor create(AOwner: TComponent);
    destructor Destroy; override;
    procedure AddField(Name, Opt: string; Row, Column, Size: integer);
    procedure Add(s: string);
    procedure SetValue(i: integer; var s: string);
    function Evaluate: TStringList;
    procedure ClearSum;
    procedure UpdateSum;
    property Fields[index: integer]: PElement read GetField;
  end;

  TFormDef = record
    case boolean of
      true: (
              ReportStart: TBlock;
              PageStart: TBlock;
              TableHeader: TBlock;
              TableRecord: TBlock;
              TableSeparator: TBlock;
              TableFooter: TBlock;
              TableEnd: TBlock;
              PageEnd: TBlock;
              ReportEnd: TBlock;
              { optional blocks }
              Group: TBlock;
              GroupFooter: TBlock );
      false: ( Quick: array[1..FormBlocks] of TBlock);
  end;

const
  DefLinesOnPage = 40;
  DefPageBreak = #12;
//  DefPageHeight = 26; { in centimeters }
//  DefPageWidth = 20; { in centimeters }

type
  TExtTextMetric = record
    etmSize: SmallInt;
    etmPointSize: SmallInt;
    etmOrientation: SmallInt;
    etmMasterHeight: SmallInt;
    etmMinScale: SmallInt;
    etmMaxScale: SmallInt;
    etmMasterUnits: SmallInt;
    etmCapHeight: SmallInt;
    etmXHeight: SmallInt;
    etmLowerCaseAscent: SmallInt;
    etmLowerCaseDescent: SmallInt;
    etmSlant: SmallInt;
    etmSuperScript: SmallInt;
    etmSubScript: SmallInt;
    etmSuperScriptSize: SmallInt;
    etmSubScriptSize: SmallInt;
    etmUnderlineOffset: SmallInt;
    etmUnderlineWidth: SmallInt;
    etmDoubleUpperUnderlineOffset: SmallInt;
    etmDoubleLowerUnderlineOffset: SmallInt;
    etmDoubleUpperUnderlineWidth: SmallInt;
    etmDoubleLowerUnderlineWidth: SmallInt;
    etmStrikeOutOffset: SmallInt;
    etmStrikeOutWidth: SmallInt;
    etmKernPairs: word;
    etmKernTracks: word;
  end;

type
  TDestinations = (dsFile, dsPrinter);

type
  TEvalField = procedure(Sender: TComponent; const Field: string;
    var Value: string) of object;
  TCheckField = procedure(Sender: TComponent; const Field: string;
    var Value: string) of object;
  TReviewLine = procedure(Sender: TComponent; var ALine: string;
    var SkipIt: Boolean) of object;
  TWritePageLine = procedure(Sender: TComponent; Line: THyperArray;
    var SkipIt: Boolean) of object;
  TWritePageBody = procedure(Sender: TComponent; Lines: TClassList;
    var SkipIt: Boolean) of object;
  TWritePageEnd = procedure(Sender: TComponent; var SkipIt: Boolean)
    of object;
  TTruncateField = procedure(Sender: TComponent; var s: string;
    Size: integer) of object;
  TSetEmptyField = procedure(Sender: TComponent; const Field: string;
    var Value: string) of object;
  TSummarizeEvent = procedure(Sender: TObject; const Field: string;
    var Sum: string; const ToAdd: string; var RunStandard: Boolean) of object;

  TFROption = (frShowPreview);
  TFROptions = set of TFROption;

  TLongLine = (llTruncate, llMakeHorizontalPages);

  TVarReplace = class
    OldField: String;
    NewField: String;
    constructor Create(S: String);
  end;


type
  TxFastReport = class(TComponent)
  private
    { Private declarations }
    OutF: Text;
    ThisPage: TClassList;
    Report: TClassList;
    HaveRecord: Boolean;
    LastRecord: TStringList;
    NewPage: Boolean;
    NewTable: Boolean;
    FormDef: TFormDef;
    PrintingEmpty: Boolean;
    CurrentRecord: Integer;
    TableIsStarted: Boolean;
    CreateGroups: Boolean;
    GroupField: string;
    LastGValue: string;
    PrinterAssigned: Boolean;
    NumberConverter: TNumberConvert;

    VarReplaceList: TExList;

    FCompletePage: Boolean;
    FDestination: TDestinations;
    FVars: TStringList;
    FAliases: TStringList;
    FFormFile: string;
    FOutputFile: string;
    FDataSource: TDataSource;
    FLinesOnPage: Integer;
    FLinesOnPageSpecified: Boolean;
    FPageBreak: char;
    FFont: TFont;
    FOptions: TFROptions;
    FLongLine: TLongLine;
//    FAbout: TxAbout;

    TextMetric: TTextMetric;
    ExtTextMetric: TExtTextMetric;

    FOnEvalField: TEvalField;
    FOnCheckField: TCheckField;
    FOnReviewLine: TReviewLine;
    FOnWritePageLine: TWritePageLine;
    FOnWritePageBody: TWritePageBody;
    FOnWritePageEnd: TWritePageEnd;
    FOnTruncateField: TTruncateField;
    FOnSetEmptyField: TSetEmptyField;
    FOnSummarize: TSummarizeEvent;

    FDCPageWidth: Integer;
    FDCPageWidthM: Integer;
    FDCPageHeight: Integer;
    FDCPageHeightM: Integer;
    FDCLogPixelsX: Integer;
    FDCLogPixelsY: Integer;

    procedure SetVars(value: TStringList);
    procedure SetAliases(value: TStringList);
    procedure SetFont(AFont: TFont);
    function PrintLinesOnPage: Integer; { lines to print on a single page }
    procedure FontChanged(Sender: TObject);
//    procedure ReadVarReplace(var F: System.Text);
    procedure ReadVarReplace(Stream: TStream);
    function GetFieldName(S: String): String;
    function CalcField(S: String): String;
    function ReadStr(S: TStream): String;

  protected
    { Protected declarations }
    procedure ReadForm;
    procedure DestroyForm;
    procedure BuildReport;
    procedure PrintReport;
    procedure PrintReportPage(Page: TClassList; isLast: Boolean);
    procedure PreviewReport; virtual;
    procedure SendString(St: string); virtual;
    procedure OutBlock(Block: TStringList); virtual;
    function GetField(AVar: string):string; virtual;
    function GetDBField(AVar: string):string; virtual;
    procedure CheckPageEnd(Lines: Integer);
    procedure OutRecord;
    procedure PrinterInit; virtual;
    procedure PrinterDone; virtual;
    procedure PrintChars(Txt: THyperArray); virtual;
    procedure TruncateField(var s: string; Size: integer);
    function MakeHorizontalPages(Txt: THyperArray): TClassList;
    procedure GetPrinterInfo;
    procedure LoadFromStream(Stream: TStream); virtual;
    {$IFDEF GEDEMIN}
    procedure Preview(Form: TxFRepView);
    {$ELSE}
    procedure Preview(Form: TxReportView);
    {$ENDIF}
    procedure Prepare; virtual;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure Execute;

  published
    { Published declarations }
    property Options: TFROptions read FOptions write FOptions;
    property CompletePage: Boolean read FCompletePage write FCompletePage;
    property Destination: TDestinations read FDestination
      write FDestination;
    property FormFile: string read FFormFile write FFormFile;
    property OutputFile: string read FOutputFile write FOutputFile;
    property Vars: TStringList read FVars write SetVars;
    property Aliases: TStringList read FAliases write SetAliases;
    property DataSource: TDataSource read FDataSource write FDataSource;
    property LinesOnPage: Integer read FLinesOnPage write FLinesOnPage;
    property Font: TFont read FFont write SetFont;
    property LongLine: TLongLine read FLongLine write FLongLine;
//    property About: TxAbout read FAbout write FAbout;

    property OnEvalField: TEvalField read FOnEvalField write FOnEvalField;
    property OnCheckField: TCheckField read FOnCheckField write FOnCheckField;
    property OnReviewLine: TReviewLine read FOnReviewLine write FOnReviewLine;
    property OnWritePageLine: TWritePageLine read FOnWritePageLine
      write FOnWritePageLine;
    property OnWritePageBody: TWritePageBody read FOnWritePageBody
      write FOnWritePageBody;
    property OnWritePageEnd: TWritePageEnd read FOnWritePageEnd
      write FOnWritePageEnd;
    property OnTruncateField: TTruncateField read FOnTruncateField
      write FOnTruncateField;
    property OnSetEmptyField: TSetEmptyField read FOnSetEmptyField write FOnSetEmptyField;
    property OnSummarize: TSummarizeEvent read FOnSummarize
      write FOnSummarize;
  end;

type
  EFastReportError = class(Exception);

procedure Register;

implementation

constructor TVarReplace.Create(S: String);
begin
  OldField := Trim(copy(S, 1, Pos('=', S) - 1));
  NewField := Trim(copy(S, Pos('=', S) + 1, 255));
end;

{-------------------- TBlock ------------------------}
constructor TBlock.Create(AOwner: TComponent);
begin
  Inherited Create;
  Owner := AOwner;
  List := TStringList.Create;
  SwapList := TStringList.Create;
  FieldsCount := 0;
  GoPrevious := 0;
end;

destructor TBlock.Destroy;
var
  Next, Last: PElement;
  i: Integer;
begin
  SwapList.Free;
  List.Free;
  Next := FirstField.Next;
  i := 1; {zero's field shouldn't be deleted (it's permanent) }
  while i<FieldsCount do
    begin
      Last := next;
      Next := Next^.Next;
      Dispose(Last);
      inc(i);
    end;
  inherited Destroy;
end;

function TBlock.GetField(Nom: integer): PElement;
var
  i: integer;
begin
  if Nom >= FieldsCount then
    raise EFastreportError.Create('Attempt to read non-existing field');
  Result := @FirstField;
  for i := 1 to Nom do
    Result := Result^.Next;
end;

procedure TBlock.AddField(Name, Opt: string; Row, Column, Size: integer);
var
  i: integer;
  align: char;
  vol: char;
  NewField: PElement;
  s, st, InAlias: string;
  Cut: Boolean;
  Summed: Boolean;
  MakeText: Boolean;
  Decimals: Boolean;
  QuantityFormat: Boolean;
  Money: Boolean;
  BlankZero: Boolean;
begin
  align := 'L';
  vol := #0;
  Cut := true;
  Summed := false;
  MakeText := false;
  Decimals := False;
  QuantityFormat := False;
  BlankZero := False;
  Money := False;
  while length(opt) > 0 do
    begin
      if (Length(opt) = 1) or (opt[1] <> '/') then
        raise EFastReportError.Create('Invalid option for report');
      case opt[2] of
        'L', 'C', 'R': Align := opt[2];
        'V', 'W': Vol := opt[2];
        'A': Cut := false;
        'S': Summed := true;
        'T': MakeText := true;
        'F': Decimals := true;
        'M': Money := True;
        'Q': QuantityFormat := True; 
        'Z': BlankZero:= True;
        else
          raise EFastReportError.Create('Invalid option for report');
      end;
      delete(opt, 1, 2);
      opt := Trim(opt);
    end;

  if Length(Name) < 2 then
    raise EFastReportError.Create('Field name missing');

  if FieldsCount <> 0 then
    begin
      NewField := Fields[FieldsCount - 1];
      New(NewField^.Next);
      NewField := NewField^.next;
    end
  else
    NewField := @FirstField;
  inc(FieldsCount);

  if Name[1] = '#' then
    begin
      s := UpperCase(copy(Name, 2, Length(Name) - 1));
      i := 0;
      InAlias := '';
      while (i < (Owner as TxFastReport).Aliases.Count) and (s<>InAlias) do
        begin
          st := (Owner as TxFastReport).Aliases[i];
          InAlias := UpperCase(Trim(copy(st, 1, pos('=', st) - 1)));
          inc(i);
        end;
      if i > 0 then
        begin
          dec(i);
          st := (Owner as TxFastReport).Aliases[i];
          if s = InAlias then
            s := UpperCase(Trim(copy(st, pos('=', st) + 1, length(st))));
        end;
      NewField^.Name := s;
    end
  else
    NewField^.Name := Name;
  NewField^.Row := Row;
  NewField^.SumValue := '';
  NewField^.Column := Column;
  NewField^.Size := Size;
  NewField^.Start := 0;
  NewField^.DataBaseField := (Name[1] = '#') and (Name[2] <> '#');
  NewField^.FirstOccurrence := true;
  NewField^.LastOccurrence := true;
  NewField^.Align := Align;
  NewField^.Cut := Cut;
  NewField^.Summed := Summed;
  NewField^.MakeText := MakeText;
  NewField^.Decimals := Decimals;
  NewField^.QuantityFormat := QuantityFormat;
  NewField^.Money := Money; 
  NewField^.BlankZero := BlankZero;
  NewField^.Wrap := Vol = 'W';
  if vol <> #0 then
    if FieldsCount > 1 then
      for i := 0 to FieldsCount - 2 do
        if Fields[i]^.Name = NewField^.Name then
          begin
            NewField^.Start := NewField^.Start +
              Fields[i]^.Size;
            NewField^.FirstOccurrence := false;
            Fields[i]^.LastOccurrence := false;
          end;
end;

procedure TBlock.Add(s: string);
var
  i: integer;
  n: Integer;
  Avar: string;
  Opt: string;
begin
  i := 1;
  while i < Length(s) do
    begin
      if s[i] = '[' then
        begin
          n := 2;
          while (s[i + n - 1] <> ']') do
            if i + n - 1 > Length(s) then
              raise EFastReportError.Create('Field without closing delimiter')
            else inc(n);
          AVar := Trim(copy(s, i + 1, n - 2));
          if pos('/', AVar) <> 0 then
            begin
              Opt := Trim( UpperCase( Copy(AVar, pos('/', AVar), Length(Avar)) ) );
              Avar := Trim( Copy(AVar, 1, pos('/', AVar) - 1) );
            end
          else Opt := '/L';
          AddField(AVar, Opt, List.Count, i, n);
          s := copy(s, 1, i - 1) + copy(s, i + n, Length(s)-i-n+1);
        end

      else if (length(s) > i) and (s[i] = '#') and (s[i+1] = '#') then
        begin
          if (length(s) > i + 1) and (s[i+2] = '#') then
            begin
              delete(s, i, 1);
              inc(i, 2);
            end
          else
            begin
              delete(s, i, 2);
              AddField('##', '/R', List.Count, i, 2);
            end;
        end

      else
        inc(i);
    end;
  List.Add(s);
end;

procedure TBlock.SetValue(i: integer; var s: string);
var
  Ofs: integer;
  j: Integer;
  s1: string;
  Num: Double;
  IntNum: Integer;
begin
  if Fields[i]^.Decimals then
  begin
    if S <> '' then
    begin
      try
        Num := StrToFloat(S);
      except
        Num := 0;
      end;
    end
    else
      Num := 0;  
    IntNum := Round(Frac(Num) * 100);
    S := IntToStr(IntNum);
  end;
  if Fields[i]^.Money then
  begin
    if S <> '' then
    begin
      try
        Num := StrToFloat(S);
      except
        Num := 0;
      end;
    end
    else
      Num := 0;  
    S := Format('%.2f', [Num]);
  end;
  if Fields[i]^.QuantityFormat then
  begin
    if S <> '' then
    begin
      try
        Num := StrToFloat(S);
      except
        Num := 0;
      end;
    end
    else
      Num := 0;  
    S := Format('%.3f', [Num]);
  end;
  if Fields[i]^.MakeText then
  begin
    try
      Num := StrToFloat(s);
      if not Fields[i]^.BlankZero or (Num <> 0) then
      begin
        (Owner as TxFastReport).NumberConverter.Value := Num;
        (Owner as TxFastReport).NumberConverter.Language := NumConv.lRussian;
        s := AnsiUpperCase((Owner as TxFastReport).NumberConverter.Numeral[1]) +
          copy((Owner as TxFastReport).NumberConverter.Numeral, 2, 255);
      end
      else
        S := '';
    except
      S := '';
    end;
  end;
  with Fields[i]^ do
    begin
      if Cut then
        begin
          if size = 2 then { only ## field can have this size }
            begin
              if length(s) > 2 then
                s1 := copy(s, length(s) - 1, 2)
              else
                s1 := s;
            end
          else
            s1 := copy(s, 1, size + 1);

          if Wrap and (length(s1) > size) then
            if pos(' ', s1)<>0 then
              begin
                while s1[length(s1)] <> ' ' do delete(s1, length(s1), 1);
                delete(s, length(s1), 1);
                delete(s1, length(s1), 1);
              end
            else
              delete(s1, length(s1), 1);

          if Length(s1) > size then
            if LastOccurrence then
              begin
                (Owner as TxFastReport).TruncateField(s1, size);
                if Length(s1) > size then
                  s1 := Copy(s1, 1, size - 3) + '...';
              end
            else
              s1 := Copy(s1, 1, size);

          Value := s1;
          if BlankZero then
          begin
            try
              if StrToFloat(Value) = 0 then
                Value := '';
            except
              Value := '';
            end;
          end;
          delete(s, 1, length(s1));
          Ofs := ( Size - Length(Value) ) div 2;
          if Align = 'C' then
            for j := 1 to Ofs do Value := ' ' + Value;
          if Align = 'R' then
            while Length(Value) < Size do Value := ' ' + Value
          else
            while Length(Value) < Size do Value := Value + ' ';
        end
      else
        Value := s;
    end;
end;

function TBlock.Evaluate: TStringList;
var
  s: string;
  i, j: integer;
  Scrolled, ToScroll: Integer;
  f: boolean;
begin
  ToScroll := GoPrevious;
  Scrolled := 0;
  while (ToScroll > 0)
    and not((Owner as TxFastReport).FDataSource.DataSet.EOF)
    and not((Owner as TxFastReport).FDataSource.DataSet.BOF) do
    begin
      inc(Scrolled);
      dec(ToScroll);
      (Owner as TxFastReport).FDataSource.DataSet.Prior;
    end;
  try
    SwapList.Assign(List);
    f := False;
    for i := 0 to FieldsCount - 1 do
      begin
        if Fields[i]^.FirstOccurrence then
          begin
            if Fields[i]^.Summed then
             s := Fields[i]^.SumValue
            else
             begin
               if Fields[i]^.DataBaseField then
                 s := (Owner as TxFastReport).GetDBField(Fields[i]^.Name)
               else
                 s := (Owner as TxFastReport).GetField(Fields[i]^.Name);
             end;
            SetValue(i, s);
            for j := i + 1 to FieldsCount-1 do
              if (Fields[j]^.Name = Fields[i]^.Name) and
                 not(Fields[j]^.FirstOccurrence) then
              begin
                SetValue(j, s);
                f := True;
              end;
          end;
      end;
    for i := FieldsCount - 1 downto 0 do
      begin
        s := SwapList.strings[Fields[i]^.Row];
        insert(Fields[i]^.Value, s, Fields[i]^.Column);
        SwapList.strings[Fields[i]^.Row] := s;
      end;
    if f then
    begin
      for i := SwapList.Count - 1 downto 0 do
      begin
        if Trim(SwapList[i]) = '' then
          SwapList.Delete(i);
      end;
    end;
    Result := SwapList;
  finally
    while (Scrolled > 0) do
      begin
        dec(Scrolled);
        (Owner as TxFastReport).FDataSource.DataSet.Next;
      end;
  end;
end;

procedure TBlock.ClearSum;
var
  i: Integer;
begin
  for i := 0 to FieldsCount - 1 do
    Fields[i]^.SumValue := '';
end;

procedure TBlock.UpdateSum;
var
  i: Integer;
  s: string;
  std: Boolean;
  er1, er2: Integer;
  SrcFlt, DstFlt: Extended;
begin
  for i := 0 to FieldsCount - 1 do
   if Fields[i]^.Summed and Fields[i]^.FirstOccurrence then
    begin
      if Fields[i]^.DataBaseField then
        s := (Owner as TxFastReport).GetDBField(Fields[i]^.Name)
      else
        s := (Owner as TxFastReport).GetField(Fields[i]^.Name);
      std := true;
      if Assigned((Owner as TxFastReport).FOnSummarize) then
        (Owner as TxFastReport).FOnSummarize(Owner, Fields[i]^.Name,
          Fields[i]^.SumValue, s, std);
      if std then
        begin
           SrcFlt := 0;
           if s = '' then
             er1 := 0
           else
           begin
             {val(s, SrcFlt, er1)}
             try
               er1 := 0;
               SrcFlt := StrToFloat(ReplaceAll(S, ThousandSeparator, ''));
             except
               er1 := 1;
             end;
           end;

           DstFlt := 0;
           if Fields[i]^.SumValue = '' then
             er2 := 0
           else
           begin
             {val(Fields[i]^.SumValue, DstFlt, er2);}
             try
               er2 := 0;
               DstFlt := StrToFloat(ReplaceAll(Fields[i]^.SumValue, ThousandSeparator, ''));
             except
               er2 := 1;
             end;
           end;

           if (er1 <> 0) or (er2 <> 0) then
             raise EFastReportError.Create('Incorrect values to sum');

           Fields[i]^.SumValue := FloatToStr(SrcFlt + DstFlt);
        end;
    end;
end;

{--------------------------- TxFastReport ------------------------}
constructor TxFastReport.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited Create(AOwner);
  PrinterAssigned := false;
  TableIsStarted := false;
  CreateGroups := false;
  FOptions := [];
  FDestination := dsFile;
  FVars := TStringList.Create;
  FAliases := TStringList.Create;
  FPageBreak := DefPageBreak;
  FLinesOnPage := DefLinesOnPage;
  FCompletePage := false;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
  LastRecord := TStringList.Create;
  for i := 1 to FormBlocks do
    FormDef.Quick[i] := TBlock.Create(self);
  ThisPage := TClassList.Create;
  Report :=  TClassList.Create;
//  FAbout := TxAbout.Create;
//  FAbout.Add('xFastReport component is a delicate way to create simple '+
//    'reports with a few keystrokes. You should just do them!');
  NumberConverter := TNumberConvert.Create(self);
  VarReplaceList := TExList.Create;
  FOutputFile := 'temp.rpf';
end;

destructor TxFastReport.Destroy;
var
  i: integer;
begin
  for i := 1 to FormBlocks do
    FormDef.Quick[i].Free;
  LastRecord.Free;
  FVars.Free;
  FAliases.Free;
  FFont.Free;
  ThisPage.Free;
  Report.Free;
//  FAbout.Free;
  VarReplaceList.Free;
  inherited destroy;
end;

{
КОПИЯ
procedure TxFastReport.ReadVarReplace(var F: System.Text);
var
  S: String;
begin
  while not eof(F) do
  begin
    readln(F, S);
    if UPPERCASE(copy(S, 1, Length('%ENDVARIABLE'))) = '%ENDVARIABLE' then
      Break;
    VarReplaceList.Add(TVarReplace.Create(S));
  end;
end;

}

procedure TxFastReport.ReadVarReplace(Stream: TStream);
var
  S: String;
  OldField, NewField: String;
  I: Integer;
begin
  while Stream.Position < Stream.Size do
  begin
    S := ReadStr(Stream);

    if UPPERCASE(copy(S, 1, Length('%ENDVARIABLE'))) = '%ENDVARIABLE' then
      Break;

    OldField := Trim(copy(S, 1, Pos('=', S) - 1));
    if UpperCase(OldField) = '_LINESONPAGE' then
    begin
      NewField := Trim(copy(S, Pos('=', S) + 1, 255));
      I := StrToIntDef(NewField, 0);
      if I > 0 then
      begin
        FLinesOnPage := I;
        FLinesOnPageSpecified := True;
      end else
        raise EFastReportError.Create('Invalid LinesOnPage value specified.');  
    end else
      VarReplaceList.Add(TVarReplace.Create(S));
  end;
end;

procedure TxFastReport.LoadFromStream(Stream: TStream);
var
  FStream: TFileStream;
begin
  FStream := TFileStream.Create(FormFile, fmOpenRead);
  try
    Stream.CopyFrom(FStream, 0);
    Stream.Position := 0;
  finally
    FStream.Free;
  end;
end;

procedure TxFastReport.GetPrinterInfo;
var
  l: Word;
begin
  l := SizeOf(ExtTextMetric);
  Escape(Printer.Handle, GETEXTENDEDTEXTMETRICS, sizeof(WORD),
    @l, @ExtTextMetric);
  GetTextMetrics(Printer.Canvas.Handle, TextMetric);
  FDCPageWidth := GetDeviceCaps(Printer.Handle, HORZRES);
  FDCPageWidthM := GetDeviceCaps(Printer.Handle, HORZSIZE);
  FDCPageHeight := GetDeviceCaps(Printer.Handle, VERTRES);
  FDCPageHeightM := GetDeviceCaps(Printer.Handle, VERTSIZE);
  FDCLogPixelsX := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  FDCLogPixelsY := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
end;

function TxFastReport.PrintLinesOnPage: Integer;
begin
  if PrinterAssigned and (not FLinesOnPageSpecified) then
    Result := Trunc( Printer.PageHeight / (TextMetric.tmHeight + 2) ) - 1
  else
    Result := FLinesOnPage;
end;

procedure TxFastReport.FontChanged(Sender: TObject);
begin
  if PrinterAssigned then
    Printer.Canvas.Font := Sender as TFont;
end;

procedure TxFastReport.SetVars(Value: TStringList);
begin
  FVars.Assign(Value);
end;

procedure TxFastReport.SetAliases(Value: TStringList);
begin
  FAliases.Assign(Value);
end;

procedure TxFastReport.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
end;

{
копия

procedure TxFastReport.ReadForm;
var
  f: text;
  s: string;
  NextBlock: string;
  NextCode: Integer;
  i: Integer;
  ReadingGroup: Boolean;
  ReadingGroupFooter: Boolean;
begin
  CreateGroups := false;
  for i := 1 to FormBlocks do
    begin
      FormDef.Quick[i].Free;
      FormDef.Quick[i] := TBlock.Create(self);
    end;
  System.Assign(f, FormFile);
  FileMode := 0;
  System.reset(f);
  NextBlock := '%REPORT';
  NextCode := 0;
  ReadingGroup := false;
  ReadingGroupFooter := false;
  while not eof(f) do
    begin
      readln(f, s);
      if (UpperCase(copy(S, 1, Length('%VARIABLE'))) = '%VARIABLE') then
      begin
        ReadVarReplace(F);
        Continue;
      end;
      if (UpperCase(copy(s, 1, Length(NextBlock))) = NextBlock)
         and (NextCode < FormBlocks) then
        begin
          ReadingGroup := false;
          ReadingGroupFooter := false;
          inc(NextCode);
          case NextCode of
            1: NextBlock := '%PAGE';
            2: NextBlock := '%TABLEHEADER';
            3: NextBlock := '%TABLERECORD';
            4: NextBlock := '%TABLESEPARATOR';
            5: NextBlock := '%TABLEFOOTER';
            6: NextBlock := '%TABLEEND';
            7: NextBlock := '%PAGE';
            8: NextBlock := '%REPORT';
          end;
        end
      else if (UpperCase(copy(s, 1, Length('%GROUPFOOTER'))) = '%GROUPFOOTER')
              and (NextCode < FormBlocks) then
        begin
          ReadingGroupFooter := true;
          ReadingGroup := false;
        end
      else if (UpperCase(copy(s, 1, Length('%GROUP'))) = '%GROUP')
              and (NextCode < FormBlocks) then
        begin
          CreateGroups := true;
          ReadingGroup := true;
          ReadingGroupFooter := false;
          GroupField := Trim( copy(s, pos('[', s) + 1,
            pos(']', s) - pos('[', s) - 1) );
          if ( pos('[', s) = 0 ) or ( pos(']', s) = 0 ) or
             ( pos('[', s) > pos(']', s) ) then
             raise EFastReportError.Create('No field spoecified in '+
               'form file in %GROUP section');
        end
      else
        begin
          if ReadingGroup then
            FormDef.Group.Add(s)
          else if ReadingGroupFooter then
            FormDef.GroupFooter.Add(s)
          else
            if NextCode <> 0 then FormDef.Quick[NextCode].Add(s);
        end;
    end;
  System.Close(f);
  if NextCode < ObligatoryBlocks then
    raise EFastReportError.Create('Not enought blocks in form definition file');
  FormDef.GroupFooter.GoPrevious := 1;
  FormDef.TableFooter.GoPrevious := 2;
  FormDef.PageEnd.GoPrevious := 1;
end;

}


procedure TxFastReport.ReadForm;
var
//  f: text;
  s: string;
  NextBlock: string;
  NextCode: Integer;
  i: Integer;
  ReadingGroup: Boolean;
  ReadingGroupFooter: Boolean;
  Stream: TMemoryStream;

begin
  Stream := TMemoryStream.Create;
  try
    CreateGroups := false;
    for i := 1 to FormBlocks do
      begin
        FormDef.Quick[i].Free;
        FormDef.Quick[i] := TBlock.Create(self);
      end;

    LoadFromStream(Stream);

//    System.Assign(f, FormFile);
    FileMode := 0;
//    System.reset(f);
    NextBlock := '%REPORT';
    NextCode := 0;
    ReadingGroup := false;
    ReadingGroupFooter := false;
//    while not eof(f) do
    while Stream.Position < Stream.Size do
      begin
        S := ReadStr(Stream);
//        readln(f, s);
        if (UpperCase(copy(S, 1, Length('%VARIABLE'))) = '%VARIABLE') then
        begin
          ReadVarReplace(Stream);
          Continue;
        end;
        if (UpperCase(copy(s, 1, Length(NextBlock))) = NextBlock)
           and (NextCode < FormBlocks) then
          begin
            ReadingGroup := false;
            ReadingGroupFooter := false;
            inc(NextCode);
            case NextCode of
              1: NextBlock := '%PAGE';
              2: NextBlock := '%TABLEHEADER';
              3: NextBlock := '%TABLERECORD';
              4: NextBlock := '%TABLESEPARATOR';
              5: NextBlock := '%TABLEFOOTER';
              6: NextBlock := '%TABLEEND';
              7: NextBlock := '%PAGE';
              8: NextBlock := '%REPORT';
            end;
          end
        else if (UpperCase(copy(s, 1, Length('%GROUPFOOTER'))) = '%GROUPFOOTER')
                and (NextCode < FormBlocks) then
          begin
            ReadingGroupFooter := true;
            ReadingGroup := false;
          end
        else if (UpperCase(copy(s, 1, Length('%GROUP'))) = '%GROUP')
                and (NextCode < FormBlocks) then
          begin
            CreateGroups := true;
            ReadingGroup := true;
            ReadingGroupFooter := false;
            GroupField := Trim( copy(s, pos('[', s) + 1,
              pos(']', s) - pos('[', s) - 1) );
            if ( pos('[', s) = 0 ) or ( pos(']', s) = 0 ) or
               ( pos('[', s) > pos(']', s) ) then
               raise EFastReportError.Create('No field spoecified in '+
                 'form file in %GROUP section');
          end
        else
          begin
            if ReadingGroup then
              FormDef.Group.Add(s)
            else if ReadingGroupFooter then
              FormDef.GroupFooter.Add(s)
            else
              if NextCode <> 0 then FormDef.Quick[NextCode].Add(s);
          end;
      end;
//    System.Close(f);
    if NextCode < ObligatoryBlocks then
      raise EFastReportError.Create('Not enought blocks in form definition file');
    FormDef.GroupFooter.GoPrevious := 1;
    FormDef.TableFooter.GoPrevious := 2;
    FormDef.PageEnd.GoPrevious := 1;
  finally
    Stream.Free;
  end;
end;

procedure TxFastReport.DestroyForm;
var
  i: Integer;
begin
  for i := 1 to FormBlocks do
    { FormDef.Quick[i].Free }; { this is done destroy now }
end;

procedure TxFastReport.PrinterInit;
begin
  PrinterAssigned := false;
  if FDestination = dsFile then
  begin
    AssignFile(OutF, OutputFile);
    Rewrite(OutF);
  end
  else if FDestination = dsPrinter then
  begin
    AssignPrn(OutF);
    Rewrite(OutF);
    Printer.Canvas.Font.Assign(FFont);
    GetPrinterInfo;
    Printer.Canvas.Font.PixelsPerInch := FDCLogPixelsX;
    Printer.Canvas.Font.Assign(FFont);
    GetPrinterInfo;
    PrinterAssigned := true;
  end
  else
    raise EFastReportError.Create('not supported device');
end;

procedure TxFastReport.PrinterDone;
begin
  System.CloseFile(OutF);
  PrinterAssigned := false;
end;

procedure TxFastReport.TruncateField(var s: string; Size: integer);
begin
  if Assigned(FOnTruncateField) then
    FOnTruncateField(self, s, Size);
end;

function TxFastReport.GetField(AVar: string):string;
var
  i: Integer;
  st: string;
  Name: string;
  Value: string;
begin
  AVar := UpperCase(Trim(AVar));
  AVar := GetFieldName(AVar);
  if Pos('[', AVar) > 0 then
  begin
    Result := CalcField(aVar);
  end
  else
  begin
    if AVar = 'PAGE' then Result := IntToStr(Report.Count + 1)
    else if AVar = 'DATE' then Result := DateToStr(Date)
    else if AVar = 'TIME' then Result := TimeToStr(Date)
    else if AVar = 'PAGEBREAK' then Result := FPageBreak
    else if AVar = '#' then Result := IntToStr(CurrentRecord)
    else if PrintingEmpty then
      begin
        Value := '';
        if Assigned(FOnSetEmptyField) then
          FOnSetEmptyField(self, AVar, Value);
        Result := Value;
      end
    else
      begin
        i := 0;
        Name := '';
        while (i < Vars.Count) and (Name<>Avar) do
          begin
            st := Vars[i];
            Name := UpperCase(Trim(copy(st, 1, pos('=', st) - 1)));
            inc(i);
          end;
        if Name = AVar then
          begin
            Value := Trim(copy(st, pos('=', st) + 1, length(st)));
            if (Length(Value) > 0) and (Value[1] = '"') then delete(Value, 1, 1);
            if (Length(Value) > 0) and (Value[length(value)] = '"') then
              delete(Value, length(value), 1);
            Result := Value;
          end
        else
          begin
            Result := '';
            if Assigned(FOnEvalField) then
              FOnEvalField(self, AVar, Result)
            else
              Result := '0';  
          end;
      end;
  end;
end;

function TxFastReport.GetFieldName(S: String): String;
var
  i: Integer;
begin
  Result := S;
  for i:= 0 to VarReplaceList.Count - 1 do
  begin
    if UpperCase(TVarReplace(VarReplaceList[i]).NewField) = UpperCase(S) then
    begin
      Result := TVarReplace(VarReplaceList[i]).OldField;
      Break;
    end;
  end;
end;

function TxFastReport.ReadStr(S: TStream): String;
var
//  TempStr: String;
  C: Char;
begin
  // Может можно написать как нибудь красивее
  Result := '';
  S.Read(C, SizeOf(Char));
  while (C <> #13) and (C <> #10) and (S.Size > S.Position) do
  begin
    Result := Result + C;
    S.Read(C, SizeOf(Char));
  end;

  S.Read(C, SizeOf(Char));

  if (C <> #13) and (C <> #10) and (S.Size > S.Position) then
    S.Position := S.Position - 1;
end;

function TxFastReport.CalcField(S: String): String;
var
  i: Integer;
  Focal: TxFocal;
  FieldName: String;
  S1: String;
begin
  Result := S;
  Focal := TxFoCal.Create(Self);
  try
    while S <> '' do
    begin
      FieldName := copy(S, Pos('[', S) + 1, 255);
      FieldName := copy(FieldName, 1, Pos(']', FieldName) - 1);
      if FDataSource.DataSet.FindField(FieldName) <> nil then
      begin
        if FDataSource.DataSet.FieldByName(FieldName).IsNull then
          Focal.AssignVariable(FieldName, 0)
        else
        begin
          //ну тут бля ваще написано
          if (DecimalSeparator = ',') and (Pos('.', FDataSource.DataSet.FieldByName(FieldName).AsString) > 0) then
            Focal.AssignVariable(FieldName, StrToFloat(ReplaceAll(FDataSource.DataSet.FieldByName(FieldName).AsString, '.', ',')))
          else
            if (DecimalSeparator = '.') and (Pos(',', FDataSource.DataSet.FieldByName(FieldName).AsString) > 0) then
              Focal.AssignVariable(FieldName, StrToFloat(ReplaceAll(FDataSource.DataSet.FieldByName(FieldName).AsString, ',', '.')))
            else
              if FDataSource.DataSet.FieldByName(FieldName).AsString > '' then
                Focal.AssignVariable(FieldName, StrToFloat(FDataSource.DataSet.FieldByName(FieldName).AsString))
              else
                Focal.AssignVariable(FieldName, 0);
        end;
      end    
      else
      begin
        S1 := GetField(FieldName);
        if S1 <> '' then
        begin
          try
            Focal.AssignVariable(FieldName, StrToFloat(S1));
          except
            Focal.AssignVariable(FieldName, 0);
          end;
        end
        else
          Focal.AssignVariable(FieldName, 0);
      end;

      if Pos(']', S) > 0 then
        S := copy(S, Pos(']', S) + 1, 255)
      else
        S := '';
    end;
    Focal.StrictVars := False;
    for i:= 1 to Length(Result) do
      if Result[i] in ['[', ']'] then
        Result[i] := ' ';
    Focal.Expression := Result;
    Result := FloatToStr(Focal.Value);
  finally
    Focal.Free;
  end;
end;


function TxFastReport.GetDBField(AVar: string):string;
var
  Fld: TField;
begin
  if PrintingEmpty then Result := ''
  else
    begin
      AVar := GetFieldName(UpperCase(Trim(AVar)));
      if Pos('[', aVar) = 0 then
      begin
        fld := FDataSource.DataSet.FindField(AVar);
        if (Fld = nil) then
          Result := '?' + AVar + '?'
        else
          Result := Fld.AsString;
      end
      else
        Result := CalcField(aVar);
    end;
end;

procedure TxFastReport.SendString(St: string);
var
  SkipIt: Boolean;
  i: Integer;
  Txt: THyperText;
  TxtArray: THyperArray;
  Code: char;
begin
  SkipIt := false;
  if Assigned(FOnReviewLine) then
    FOnReviewLine(self, st, SkipIt);
  if not(SkipIt) then
    begin
      TxtArray := THyperArray.Create;
      try
        Txt.Text := '';
        Txt.Script := fsNormal;
        Txt.Style := [];
        i := 1;
        while i <= length(St) do
          begin
            if (st[i] = '@') and (i + 1 <= length(st)) then
              begin
                Code := UpCase(st[i + 1]);
                if Code in ['B', 'I', 'U'] then
                  begin
                    TxtArray.Add(Txt);
                    Txt.Text := '';
                    case Code of
                      'B': if fsBold in Txt.Style then
                             Txt.Style := Txt.Style - [fsBold]
                           else
                             Txt.Style := Txt.Style + [fsBold];
                      'I': if fsItalic in Txt.Style then
                             Txt.Style := Txt.Style - [fsItalic]
                           else
                             Txt.Style := Txt.Style + [fsItalic];
                      'U': if fsUnderline in Txt.Style then
                             Txt.Style := Txt.Style - [fsUnderline]
                           else
                             Txt.Style := Txt.Style + [fsUnderline];
                      'S': if fsStrikeOut in Txt.Style then
                             Txt.Style := Txt.Style - [fsStrikeOut]
                           else
                             Txt.Style := Txt.Style + [fsStrikeOut];
                    end;
                    inc(i);
                  end
                else
                  begin
                    Txt.Text := Txt.Text + st[i];
                    if Code = '@' then inc(i);
                  end;
              end
            else
              Txt.Text := Txt.Text + st[i];
            inc(i);
          end;
        if Txt.Text <> '' then
          TxtArray.Add(Txt);
        ThisPage.Add(TxtArray);
      except
        TxtArray.Free;
        raise;
      end;
    end;
end;

procedure TxFastReport.OutBlock(Block: TStringList);
var
  i: Integer;
begin
  for i := 0 to Block.Count - 1 do
    SendString(Block.Strings[i]);
end;

procedure TxFastReport.CheckPageEnd(Lines: Integer);
begin
  if NewPage then exit;
  if ThisPage.Count + Lines > PrintLinesOnPage - FormDef.PageEnd.List.Count then
    begin
      if TableIsStarted then
        OutBlock(FormDef.TableFooter.Evaluate);
      OutBlock(FormDef.PageEnd.Evaluate);
      Report.Add(ThisPage);
      ThisPage := TClassList.Create;
      OutBlock(FormDef.PageStart.Evaluate);
      if TableIsStarted then
        begin
          OutBlock(FormDef.TableHeader.Evaluate);
          NewTable := true;
        end;
      NewPage := true;
    end;
end;

procedure TxFastReport.OutRecord;
var
  NewGValue: string;
begin
  if HaveRecord then
    begin
      if not(NewPage) and not(NewTable) then
        CheckPageEnd(
          MaxInt(FormDef.TableSeparator.List.Count +
              LastRecord.Count +
              FormDef.GroupFooter.List.Count,
              FormDef.TableSeparator.List.Count +
              LastRecord.Count +
              FormDef.TableFooter.List.Count ) );
      { don't join this two if-clauses }
      if not NewTable then OutBlock(FormDef.TableSeparator.Evaluate);
      OutBlock(LastRecord);
      LastRecord.Clear;
      NewPage := false;
      NewTable := false;
    end
  else
    HaveRecord := true;
  if CreateGroups then
    begin
      if GroupField[1] = '#' then
        NewGValue := GetDBField(copy(GroupField, 2, Length(GroupField) - 1))
      else
        NewGValue := GetField(GroupField);
      if (CurrentRecord > 1) and (NewGValue <> LastGValue) then
        begin
          OutBlock(FormDef.GroupFooter.Evaluate);
          TableIsStarted := false;
          CheckPageEnd(
            MaxInt(
                FormDef.Group.List.Count +
                FormDef.TableHeader.List.Count +
                FormDef.TableRecord.List.Count +
                FormDef.TableFooter.List.Count,

                FormDef.Group.List.Count +
                FormDef.TableHeader.List.Count +
                FormDef.TableRecord.List.Count +
                FormDef.GroupFooter.List.Count) );
          FormDef.GroupFooter.ClearSum;
          OutBlock(FormDef.Group.Evaluate);
          OutBlock(FormDef.TableHeader.Evaluate);
          TableIsStarted := true;
          NewTable := true;
        end;
      LastGValue := NewGValue;
    end;
  LastRecord.Assign(FormDef.TableRecord.Evaluate);
  FormDef.GroupFooter.UpdateSum;
  FormDef.TableEnd.UpdateSum;
  FormDef.ReportEnd.UpdateSum;
end;

procedure TxFastReport.BuildReport;
var
  Mark: TBookMark;
begin
  HaveRecord := false;
  TableIsStarted := false;
  PrintingEmpty := false;
  Mark := FDataSource.DataSet.GetBookmark;
  FDataSource.DataSet.DisableControls;
  try
    ThisPage.Clear;
    NewPage := true;
    CurrentRecord := 1;
    FDataSource.DataSet.First;
    OutBlock(FormDef.ReportStart.Evaluate);
    OutBlock(FormDef.PageStart.Evaluate);
    if CreateGroups then
     begin
       FormDef.GroupFooter.ClearSum;
       OutBlock(FormDef.Group.Evaluate);
     end;
    OutBlock(FormDef.TableHeader.Evaluate);
    TableIsStarted := true;
    NewTable := true;
    LastGValue := '';
    while not FDataSource.DataSet.EOF do
      begin
        OutRecord;
        FDataSource.DataSet.Next;
        Inc(CurrentRecord);
      end;
    if HaveRecord then
      begin
        if not NewPage then
          CheckPageEnd(FormDef.TableSeparator.List.Count +
                       LastRecord.Count +
                       FormDef.ReportEnd.List.Count +
                       FormDef.TableEnd.List.Count);
        { don't join this two if-clauses }
        if not NewTable then OutBlock(FormDef.TableSeparator.Evaluate);
        OutBlock(LastRecord);
        LastRecord.Clear;
        NewPage := false;
        NewTable := false;
      end;
    if FCompletePage then
      begin
        PrintingEmpty := true;
        while
           ThisPage.Count
             + FormDef.TableSeparator.List.Count
             + FormDef.TableRecord.List.Count      <=
           PrintLinesOnPage
             - FormDef.GroupFooter.List.Count
             - FormDef.TableEnd.List.Count
             - FormDef.PageEnd.List.Count
             - FormDef.ReportEnd.List.Count       do
          begin
            OutBlock(FormDef.TableSeparator.Evaluate);
            OutBlock(FormDef.TableRecord.Evaluate);
          end;
        PrintingEmpty := false;
      end;
    if CreateGroups then
      OutBlock(FormDef.GroupFooter.Evaluate);
    OutBlock(FormDef.TableEnd.Evaluate);
    OutBlock(FormDef.PageEnd.Evaluate);
    OutBlock(FormDef.ReportEnd.Evaluate);
    if ThisPage.Count > 0 then
      begin
        Report.Add(ThisPage);
        ThisPage := TClassList.Create;
      end;
  finally
    FDataSource.DataSet.EnableControls;
  end;
  FDataSource.DataSet.GotoBookmark(Mark);
end;

function TxFastReport.MakeHorizontalPages(Txt: THyperArray): TClassList;
var
  List: TClassList;
  Line: THyperArray;
  Len: Integer; { current length }
  Extent: TSize;
  t: array[0..1000] of Char;
  i, Left, Right: Integer;
begin
  List := TClassList.Create;
  Line := THyperArray.Create;
  try
    Len := 0;
    if PrinterAssigned then
      begin
        for i := 0 to Txt.Count - 1 do
          begin
            Printer.Canvas.Font.Style := Txt[i].Style;
            Printer.Canvas.TextWidth('To escape some Delphi-Windows problems');
            left := 1;
            repeat
              right := Length(Txt[i].Text);
              StrPCopy(t, Copy(Txt[i].Text, left, right - left + 1));
              GetTextExtentPoint(Printer.Handle, t, right - left + 1, Extent);
              while Len + Extent.cX > Printer.PageWidth do
                begin
                  dec(right);
                  StrPCopy(t, Copy(Txt[i].Text, left, right - left + 1));
                  GetTextExtentPoint(Printer.Handle, t, right - left + 1,
                    Extent);
                end;
              Line.Add( HyperText(StrPas(t), Txt[i].Script, Txt[i].Style) );
              Len := Len + Extent.cX;
              Left := Right + 1;
              if Left <= Length(Txt[i].Text) then
                begin
                  List.Add(Line);
                  Line := THyperArray.Create;;
                  Len := 0;
                end;
            until Left > Length(Txt[i].Text);
          end;
        if Line.Count > 0 then
          List.Add(Line)
        else
          Line.Free;
      end
    else
      List.Add(Txt);
    Result := List;
    Printer.Canvas.Font.Style := Font.Style;
  except
    List.Free;
    Line.Free;
    raise;
  end;
end;

procedure TxFastReport.PrintChars(Txt: THyperArray);
var
  i: Integer;
begin
  for i := 0 to Txt.Count - 1 do
  begin
    Printer.Canvas.Font.Style := Txt[i].Style;
    Write(OutF, Txt[i].Text);
  end;
  Writeln(OutF);
  Printer.Canvas.Font.Style := Font.Style; { restore default style }
end;

procedure TxFastReport.PrintReportPage(Page: TClassList; isLast: Boolean);
var
  SkipIt: Boolean;
  i: Integer;
  NeedsPages: Integer;
  HPage: Integer;
  HPages: TClasslist;
  Emptyline: THyperArray;
begin
  EmptyLine := THyperArray.Create;
  try
    HPages := TClassList.Create;
    NeedsPages := 0;
    for i := 0 to Page.Count - 1 do
    begin
      HPages.Add(MakeHorizontalPages(THyperArray(Page[i])));
      NeedsPages := MaxInt(NeedsPages, TClasslist(HPages.Last).Count);
    end;

    if FLongLine = llTruncate then
      NeedsPages := 1;

    for HPage := 0 to NeedsPages - 1 do
    begin
      for i := 0 to HPages.Count - 1 do
      begin
        SkipIt := False;
        if Assigned(FOnWritePageLine) then
          FOnWritePageLine(self, THyperArray(HPages[i]), SkipIt);
        if not(SkipIt) then
          if HPage < TClassList(HPages[i]).Count then
            PrintChars(THyperArray(TClassList(HPages[i])[HPage]))
          else
            PrintChars(EmptyLine);
      end;
      SkipIt := False;
      if Assigned(FOnWritePageEnd) then
        FOnWritePageEnd(self, SkipIt);
      if not SkipIt and not isLast then
        Write(OutF, #12)
    end;
  finally
    EmptyLine.Free;
  end;
end;

procedure TxFastReport.PrintReport;
var
  i: Integer;
  SkipIt: Boolean;
begin
  for i := 0 to Report.Count - 1 do
  begin
    SkipIt := False;
    if Assigned(FOnWritePageBody) then
      FOnWritePageBody(self, TClassList(Report[i]), SkipIt);
    if not SkipIt then
      PrintReportPage(TClassList(Report[i]), i = Report.Count - 1);
  end;
end;

{$IFDEF GEDEMIN}
procedure TxFastReport.Preview(Form: TxFRepView);
{$ELSE}
procedure TxFastReport.Preview(Form: TxReportView);
{$ENDIF}
var
  i, j, k: Integer;
  s: string;
begin
  Form.Memo.Lines.Clear;
  { copying font, but skipping its size }
  for i := 0 to Report.Count - 1 do
  begin
    with TClassList(Report[i]) do
    begin
      for j := 0 to Count - 1 do
      begin
        s := '';
        with THyperArray(Items[j]) do
          for k := 0 to Count - 1 do s := s + Items[k].Text;
        if Form.Memo.Lines.Count < 20000 then
          Form.Memo.Lines.Add(s);
      end;
    end;
//    if Form.Memo.Lines.Count < 20000 then
//      Form.Memo.Lines.Add(' ----------------- end of page -----------------');
  end;
  if Form.Memo.Lines.Count >= 20000 then
    Form.Memo.Lines.Add(' ************* further output can be seen only if printed *********');
end;

procedure TxFastReport.PreviewReport;
var
  {$IFDEF GEDEMIN}
  Form: TxFRepView;
  {$ELSE}
  Form: TxReportView;
  {$ENDIF}
begin
  {$IFDEF GEDEMIN}
  Form := TxFRepView.Create(Application);
  {$ELSE}
  Form := TxReportView.Create(Application);
  {$ENDIF}
  try
    Preview(Form);
    case Form.ShowModal of
      mrOk: PrintReport;
    end;
  finally
    Form.Free;
  end;
end;

procedure TxFastReport.Execute;
begin
  Prepare;
  if FDataSource = nil then
  begin
    MessageBox(0,
      'Не подключен DataSource.',
      'Ошибка',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;

  if FDataSource.DataSet = nil then
  begin
    MessageBox(0,
      'Не подключен DataSet.',
      'Ошибка',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;

  {Assert(FDataSource <> nil, 'Не подключен DataSource');
  Assert(FDataSource.DataSet <> nil, 'Не подключен DateSet');}
  VarReplaceList.Clear;
  FLinesOnPageSpecified := False;
  PrinterInit;
  try
    ReadForm;
    try
      Report.Clear; { clear if there is an old report }
      BuildReport;
    finally
      DestroyForm;
    end;
    if frShowPreview in Options then
      PreviewReport
    else
      PrintReport;
  finally
    PrinterDone;
  end;
end;

procedure TxFastReport.Prepare;
begin
end;


{--------------------------- registration ------------------------}
procedure Register;
begin
  RegisterComponents('xStorm', [TxFastReport]);
end;

end.
