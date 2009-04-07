
{

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    xDateEdits.pas

  Abstract

    visual Components:
    
      xDateEdit - EditField to input Date more faster. 
                  Now and Time too;
      xDBDateEdit - DataBase EditField to input Date more faster. 
                    Now and Time too;

  Author

    Alex Tsobkalo (March-1999)

  Revisions history

    16-Mar-99  Initial Version
    05-Apr-99  Added ability to input Date or Time or DateTime separatly with 
               Property called Kind.

}

unit xDateEdits;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, dbctrls, DB;

const
  { Numbers of Long Monthes }
  LongMonthes = [1, 3, 5, 7, 8, 10, 12];

  { Show Present DateTime at Start or Witch was Writted in Object Inspector }
  defCurrentDateTimeAtStart = False;

  { Show Empty Text Field at Every  Condition or not}
  defEmptyAtStart = False;

type
  { Custom Type }
  TKind = (kDate, kTime, kDateTime);

{ TxDateEdit }

  TxCustomDateEdit = class(TCustomMaskEdit)
  private
    FCurrentDateTimeAtStart: Boolean;
    FStoredDateTime        : Boolean;
    FEmptyAtStart          : Boolean;
    FKind                  : TKind;
    FDate                  : TDate;
    FTime                  : TTime;
    FDateTime              : TDateTime;
    FConvertErrorMessage   : Boolean;

    function GetDate: TDate;
    function GetTime: TTime;
    procedure SetDate(const Value: TDate);
    procedure SetKind(const Value: TKind);
    procedure SetTime(const Value: TTime); virtual;
    procedure SetDay(const Value: Word);
    procedure SetMonth(const Value: Word);
    procedure SetYear(const Value: Word);
    procedure SetHour(const Value: Word);
    procedure SetMin(const Value: Word);
    procedure SetSec(const Value: Word);
    function GetDay: Word;
    function GetMonth: Word;
    function GetYear: Word;
    function GetHour: Word;
    function GetMin: Word;
    function GetSec: Word;
    function GetDateTime: TDateTime;
    procedure SetDateTime(const Value: TDateTime);
    procedure SetCurrentDateTimeAtStart(const Value: Boolean);
    procedure SetEmptyAtStart(const Value: Boolean);
    function IsEmpty(AnValue: String): Boolean;

    function GetTextDay: Word;
    function GetTextMonth: Word;
    function GetTextYear: Word;
    function GetTextHour: Word;
    function GetTextMin: Word;
    function GetTextSec: Word;
  protected
    { Kbd Events }
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

    { Custom Procedures and Functions }
    procedure LetInc(Value: Byte);
    procedure LetDec(Value: Byte);
    function EmptyInDate: Boolean;
    function GoodValue(Value: Word): Boolean;
    procedure ValidDate(Value: Byte);
    procedure SetRightText;

    { Standart Methods }
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure Loaded; override;

  public
    constructor Create(anOwner: TComponent); override;

    function DaysCount(nMonth: Word; nYear: Word): Integer;
    procedure GetDateInStr(aDate: TDateTime; var sYear, sMonth, sDay: String);
    procedure GetTimeInStr(aTime: TDateTime; var sHour, sMin, sSec: String);
    function GetLength: Word;

    property Date: TDate read GetDate write SetDate
      stored FStoredDateTime;
    property Time: TTime read GetTime write SetTime
      stored FStoredDateTime;
    property DateTime: TDateTime read GetDateTime write SetDateTime
      stored FStoredDateTime;

    property Year: Word read GetYear write SetYear
      stored FStoredDateTime;
    property Month: Word read GetMonth write SetMonth
      stored FStoredDateTime;
    property Day: Word read GetDay write SetDay
      stored FStoredDateTime;

    property Hour: Word read GetHour write SetHour
      stored FStoredDateTime;
    property Min: Word read GetMin write SetMin
      stored FStoredDateTime;
    property Sec: Word read GetSec write SetSec
      stored FStoredDateTime;

    property Kind: TKind read FKind write SetKind
      default kDateTime;
    property CurrentDateTimeAtStart: Boolean read FCurrentDateTimeAtStart write SetCurrentDateTimeAtStart
      default defCurrentDateTimeAtStart;
    property EmptyAtStart: Boolean read FEmptyAtStart write SetEmptyAtStart
      default defEmptyAtStart;
    property ConvertErrorMessage: Boolean read FConvertErrorMessage write FConvertErrorMessage;
  end;

  TxDateEdit = class(TxCustomDateEdit)
  published
    property Kind;
    property CurrentDateTimeAtStart;
    property EmptyAtStart;

  published
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property EditMask;
    property Font;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

{ TxDateDBEdit}

  TxDateDBEdit = class(TxCustomDateEdit)
  private
    FDataLink: TFieldDataLink;

    procedure DataChange(Sender: TObject);
    function GetDataField: String;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    procedure SetDataField(const Value: String);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure WMCut(var Message: TMessage);
      message WM_CUT;
    procedure WMPaste(var Message: TMessage);
      message WM_PASTE;
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure SetTime(const Value: TTime); override;

  protected
    function EditCanModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Reset; override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
    procedure Change; override;

    property Day stored False;
    property Month stored False;
    property Year stored False;
    property Text stored False;
    property Hour stored False;
    property Min stored False;
    property Sec stored False;

  published
    property DataField: String read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly
      default False;

  published
    property Kind;
    property CurrentDateTimeAtStart;
    property EmptyAtStart;

  published
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property EditMask;
    property Font;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
//    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
//    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

type
  TWinControlCrack = class(TWinControl);

const
  { Used Formats }

  DateFormat     = '!99\.99\.9999;1;_';

  TimeFormat     = '!99\:99\:99;1;_';

  DateTimeFormat = '!99\.99\.9999 99\:99\:99;1;_';


{function DateFormat: String;
var
  I: Integer;
begin
  Result := ShortDateFormat;
  for I := 1 to Length(Result) do
    case Result[I] of
      'a'..'z', 'A'..'Z': Result[I] := '9';
      ' ': Result[I] := '_';
    else
      Result[I] := '/';
    end;
  Result := '!' + Result + ';1;_';
end;

function DateTimeFormat: String;
begin
  Result := DateFormat;
  Result := Copy(Result, 1, Length(Result) - 4) + ' ';
  Result := Result + Copy(TimeFormat, 2, 255);
end;
}
{****************************   TxDateEdit   **********************************}

//   CREATE
constructor TxCustomDateEdit.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);

  FConvertErrorMessage := True;

  FKind := kDateTime;
  EditMask := DateTimeFormat;

  FCurrentDateTimeAtStart := defCurrentDateTimeAtStart;
  FStoredDateTime := not defCurrentDateTimeAtStart;
  FEmptyAtStart := defEmptyAtStart;

  Date := Now;
  FDate := Now;
  Time := Now;
  FTime := Now;
  FDateTime := Now;

  SetRightText;
end;

//   LOADED
procedure TxCustomDateEdit.Loaded;
begin
  inherited Loaded;
  
  SetRightText;
end;

//   SET_CURRENT_DATE_TIME_AT_START
procedure TxCustomDateEdit.SetCurrentDateTimeAtStart(const Value: Boolean);
begin
  if FCurrentDateTimeAtStart <> Value then
  begin
    FCurrentDateTimeAtStart := Value;
    FStoredDateTime := not FCurrentDateTimeAtStart;
  end;
end;

//   SET_EMPTY_AT_START
procedure TxCustomDateEdit.SetEmptyAtStart(const Value: Boolean);
begin
  if FEmptyAtStart <> Value then
  begin
    FEmptyAtStart := Value;
    SetRightText;
  end;  
end;

//   SET_RIGHT_TEXT
procedure TxCustomDateEdit.SetRightText;
var
  stYear, stMonth, stDay: String;
  stHour, stMin, stSec: String;
begin
  if FEmptyAtStart then
  begin
    case FKind of
      kDate: 
        EditText := '__.__.____';
        
      kTime:
        EditText := '__:__:__';
        
      kDateTime:
        EditText := '__.__.____ __:__:__';
    end;
  end
  else
    if FCurrentDateTimeAtStart then
    begin
      Date := Now;
      FDate := Now;
      Time := Now;
      FTime := Now;
      FDateTime := Now;
  
      GetDateInStr(Date, stYear, stMonth, stDay);
      GetTimeInStr(Time, stHour, stMin, stSec);

      case FKind of
        kDate: 
          EditText := stDay + '.' + stMonth + '.' + stYear;
        
        kDateTime:
          EditText := stDay + '.' + stMonth + '.' + stYear + ' ' + 
            stHour + ':' + stMin + ':' + stSec;
        
        kTime:
          EditText := stHour + ':' + stMin + ':' + stSec;
      end;
    end
end;

//   SET_KIND
procedure TxCustomDateEdit.SetKind(const Value: TKind);
var
  stYear, stMonth, stDay: String;
  stHour, stMin, stSec: String;
begin
  if FKind <> Value then
  begin
    GetDateInStr(FDate, stYear, stMonth, stDay);
    GetTimeInStr(FTime, stHour, stMin, stSec);

    FKind := Value;
    case FKind of
      kDate:
        begin
          EditMask := DateFormat;
          Text := stDay + '.' + stMonth + '.' + stYear;
        end;

      kTime:
        begin
          EditMask := TimeFormat;
          Text := stHour + ':' + stMin + ':' + stSec;
        end;

      kDateTime:
        begin
          EditMask := DateTimeFormat;
          Text := stDay + '.' + stMonth + '.' + stYear + ' ' + 
            stHour + ':' + stMin + ':' + stSec;
        end;    
    end;
  end;
end;

//   GET_DATE
function TxCustomDateEdit.GetDate: TDate;
var
  stDate: String;
begin
  case FKind of
    kDate, kDateTime:
      begin
        stDate := Copy(EditText, 1, 10);
        if IsEmpty(stDate) then
          Result := 0
        else
          Result := EncodeDate(GetTextYear, GetTextMonth, GetTextDay);
      end
    else
      Result := FDate;  
  end;
end;

//   SET_DATE
procedure TxCustomDateEdit.SetDate(const Value: TDate);
var
  stDate: String;
  St: String;
begin
  FDate := Value;

  if Value = 0 then
    stDate := '__.__.____'
  else
    DateTimeToString(stDate, 'dd.mm.yyyy', Value);

  case FKind of
    kDate:
      Text := stDate;

    kDateTime:
      begin
        St := Copy(EditText, 12, 8);
        Text := stDate + ' ' + St;
      end;
  end;
end;

//   GET_TIME
function TxCustomDateEdit.GetTime: TTime;
var
  stTime: String;
begin
  case FKind of
    kTime:
      stTime := Copy(EditText, 1, 8);

    kDateTime:
      stTime := Copy(EditText, Pos('99:99:99', EditMask) - 1, 8)

    else
      stTime := TimeToStr(FTime);
  end;

  if IsEmpty(stTime) then
    Result := 0
  else
    Result := EncodeTime(GetTextHour, GetTextMin, GetTextSec, 0);
end;

//   SET_TIME
procedure TxCustomDateEdit.SetTime(const Value: TTime);
var
  stTime: String;
  St: String;
begin
  FTime := Value;

  if EditMask = '!99\.99\.9999 99\:99;1;_' then
  begin
    if Value = 0 then
      stTime := '00:00'
    else
      DateTimeToString(stTime, 'hh:nn', Value);
  end else
  begin
    if Value = 0 then
      stTime := '00:00:00'
    else
      DateTimeToString(stTime, 'hh:nn:ss', Value);
  end;

  case FKind of
    kTime:
      EditText := stTime;

    kDateTime:
      begin
        St := Copy(EditText, 1, 10);
        EditText := St + ' ' + stTime;
      end;
  end;
end;

//   SET_YEAR
procedure TxCustomDateEdit.SetYear(const Value: Word);
var
  aYear, aMonth, aDay: Word;
begin
  DecodeDate(Date, aYear, aMonth, aDay);
  if (aYear <> Value) and (Value <> 0) then
  begin
    aYear := Value;
    try
      Date := EncodeDate(aYear, aMonth, aDay);
    except
      on Exception do Date := Now;
    end;
  end;
end;

//   SET_MONTH
procedure TxCustomDateEdit.SetMonth(const Value: Word);
var
  aYear, aMonth, aDay: Word;
begin
  DecodeDate(Date, aYear, aMonth, aDay);
  if (aMonth <> Value) and (Value >= 1) and (Value <= 12) then
  begin
    aMonth := Value;
    try
      Date := EncodeDate(aYear, aMonth, aDay);
    except
      on Exception do Date := Now;
    end;
  end;
end;

//   SET_DAY
procedure TxCustomDateEdit.SetDay(const Value: Word);
var
  aYear, aMonth, aDay: Word;
begin
  DecodeDate(Date, aYear, aMonth, aDay);
  if (aDay <> Value) and (Value <> 0) then
  begin
    if Value > DaysCount(Month, Year) then
      aDay := DaysCount(Month, Year)
    else
      aDay := Value;
    try
      Date := EncodeDate(aYear, aMonth, aDay);
    except
      on Exception do Date := Now;
    end;
  end;
end;

//   GET_DAY
function TxCustomDateEdit.GetDay: Word;
var
  aYear, aMonth, aDay: Word;
begin
  DecodeDate(Date, aYear, aMonth, aDay);
  Result := aDay;
end;

//   GET_MONTH
function TxCustomDateEdit.GetMonth: Word;
var
  aYear, aMonth, aDay: Word;
begin
  DecodeDate(Date, aYear, aMonth, aDay);
  Result := aMonth;
end;

//   GET_YEAR
function TxCustomDateEdit.GetYear: Word;
var
  aYear, aMonth, aDay: Word;
begin
  DecodeDate(Date, aYear, aMonth, aDay);
  Result := aYear;
end;

//   DAYS_COUNT
function TxCustomDateEdit.DaysCount(nMonth: Word; nYear: Word): Integer;
begin
  if nMonth = 2 then
    if isLeapYear(nYear) then
      Result := 29
    else
      Result := 28
  else
    if nMonth in LongMonthes then
      Result := 31
    else
      Result := 30;
end;

//   GET_DATE_IN_STR
procedure TxCustomDateEdit.GetDateInStr(aDate: TDateTime; var sYear, sMonth, sDay: String);
begin
  DateTimeToString(sDay, 'dd', aDate);
  DateTimeToString(sMonth, 'mm', aDate);
  DateTimeToString(sYear, 'yyyy', aDate);
end;

//   GET_TIME_IN_STR
procedure TxCustomDateEdit.GetTimeInStr(aTime: TDateTime; var sHour, sMin, sSec: String);
begin
  DateTimeToString(sHour, 'hh', aTime);
  DateTimeToString(sMin, 'nn', aTime);
  DateTimeToString(sSec, 'ss', aTime);
end;

//   SET_HOUR
procedure TxCustomDateEdit.SetHour(const Value: Word);
var
  aHour, aMin, aSec, aMSec: Word;
begin
  DecodeTime(Time, aHour, aMin, aSec, aMSec);
  if (aHour <> Value) and (Value <= 23) then
  begin
    aHour := Value;
    try
      Time := EncodeTime(aHour, aMin, aSec, 0);
    except
      on Exception do Time := Now;
    end;  
  end;
end;

//   SET_MIN
procedure TxCustomDateEdit.SetMin(const Value: Word);
var
  aHour, aMin, aSec, aMSec: Word;
begin
  DecodeTime(Time, aHour, aMin, aSec, aMSec);
  if (aMin <> Value) and (Value <= 59) then
  begin
    aMin := Value;
    try
      Time := EncodeTime(aHour, aMin, aSec, 0);
    except
      on Exception do Time := Now;
    end;  
  end;
end;

//   SET_SEC
procedure TxCustomDateEdit.SetSec(const Value: Word);
var
  aHour, aMin, aSec, aMSec: Word;
begin
  DecodeTime(Time, aHour, aMin, aSec, aMSec);
  if (aSec <> Value) and (Value <= 59) then
  begin
    aSec := Value;
    try
      Time := EncodeTime(aHour, aMin, aSec, 0);
    except
      on Exception do Time := Now;
    end;  
  end;
end;

//   GET_HOUR
function TxCustomDateEdit.GetHour: Word;
var
  aHour, aMin, aSec, aMSec: Word;
begin
  DEcodeTime(Time, aHour, aMin, aSec, aMSec);
  Result := aHour;
end;

//   GET_MIN
function TxCustomDateEdit.GetMin: Word;
var
  aHour, aMin, aSec, aMSec: Word;
begin
  DEcodeTime(Time, aHour, aMin, aSec, aMSec);
  Result := aMin
end;

//   GET_SEC
function TxCustomDateEdit.GetSec: Word;
var
  aHour, aMin, aSec, aMSec: Word;
begin
  DEcodeTime(Time, aHour, aMin, aSec, aMSec);
  Result := aSec
end;

//   KEY_DOWN
procedure TxCustomDateEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
  Pos: Byte;
begin
  if ((Key = VK_UP) or (Key = VK_DOWN)) and (not EmptyInDate)
    and (not ReadOnly) then
  begin
    Pos := 0;
    case SelStart of
      0..2:
        begin
          SelStart := 0;
          SelLength := 2;
          Pos := 1;
        end;

      3..5:
        begin
          SelStart := 3;
          SelLength := 2;
          Pos := 2;
        end;

      6..10:
        begin
          SelStart := 6;
          SelLength := 4;
          Pos := 3;
        end;

      11..13:
        begin
          SelStart := 11;
          SelLength := 2;
          Pos := 4;
        end;

      14..16:
        begin
          SelStart := 14;
          SelLength := 2;
          Pos := 5;
        end;

      17..19:
        begin
          SelStart := 17;
          SelLength := 2;
          Pos := 6;
        end;
    end;

    if Key = VK_UP then
      LetInc(Pos)
    else
      LetDec(Pos);

    Key := VK_CLEAR;
  end;

  if (Key = VK_RIGHT) and (SelLength > 1) then
    case SelStart of
      0:  SelStart := 3;
      3:  SelStart := {6}8;
      {6}8:  SelStart := 11;
      11: SelStart := 14;
      14: SelStart := 17;
      17: SelStart := 19;
    end;

  if (Key = VK_LEFT) and (SelLength > 1) then
    case SelStart of
      0:  SelStart := 0;
      3:  SelStart := 2;
      6:  SelStart := 5;
      11: SelStart := 10;
      14: SelStart := 13;
      17: SelStart := 16;
    end;

  inherited KeyDown(Key, Shift);
end;

//   LET_DEC
procedure TxCustomDateEdit.LetDec(Value: Byte);
var
  M: Integer;
begin
  if (FKind = kDate) or (FKind = kDateTime) then
    case Value of
      1:
        begin
          if Day = 1 then
          begin
            if Month = 1 then
            begin
              Month := 12;
              Year := Year - 1;
            end
            else
              Month := Month - 1;
            Day := DaysCount(Month, Year);
          end    
          else
            Day := Day - 1;
          SelStart := 0;
          SelLength := 2;
        end;

      2:
        begin
          M := Month;
          if M = 1 then 
          begin
            M := 12;
            Year := Year - 1;
          end  
          else  
            M := M - 1;

          if Day > DaysCount(M, Year) then
            Day := DaysCount(M, Year);
          Month := M;  

          SelStart := 3;
          SelLength := 2;
        end;  

      3:
        begin
          Year := Year - 1;  
          SelStart := 6;
          SelLength := 4;
        end;  

      4:
        begin
          if Hour = 0 then 
            Hour := 23
          else
            Hour := Hour - 1;
          SelStart := 11;
          SelLength := 2;
        end;

      5:
        begin
          if Min = 0 then
          begin
            Min := 59;
            if Hour = 0 then
              Hour := 23
            else
              Hour := Hour - 1;
          end  
          else  
            Min := Min - 1;
          SelStart := 14;
          SelLength := 2;
        end;

      6:
        begin
          if Sec = 0 then
          begin
            Sec := 59;
            if Min = 0 then
            begin
              Min := 59;
              if Hour = 0 then
                Hour := 23
              else
                Hour := Hour - 1;
            end
            else
              Min := Min - 1;
          end  
          else  
            Sec := Sec - 1;
          SelStart := 17;
          SelLength := 2;
        end;  
    end
  else
    case Value of
      1:
        begin
          if Hour = 0 then 
            Hour := 23
          else
            Hour := Hour - 1;  
          SelStart := 0;
          SelLength := 2;
        end;

      2:
        begin
          if Min = 0 then
          begin
            Min := 59;
            if Hour = 0 then
              Hour := 23
            else
              Hour := Hour - 1;
          end
          else
            Min := Min - 1;
          SelStart := 3;
          SelLength := 2;
        end;  

      3:
        begin
          if Sec = 0 then
          begin
            Sec := 59;
            if Min = 0 then
            begin
              Min := 59;
              if Hour = 0 then
                Hour := 23
              else
                Hour := Hour - 1;  
            end
            else
              Min := Min - 1;
          end
          else
            Sec := Sec - 1;
          SelStart := 6;
          SelLength := 2;
        end;  
    end;      
end;

//   LET_INC
procedure TxCustomDateEdit.LetInc(Value: Byte);
var
  M: Integer;
begin
  if (FKind = kDate) or (FKind = kDateTime) then
    case Value of
      1:
        begin
          if Day = DaysCount(Month, Year) then
          begin
            Day := 1;
            if Month = 12 then 
            begin
              Month := 1;
              Year := Year + 1;
            end  
            else  
              Month := Month + 1;
          end    
          else  
            Day := Day + 1;
          SelStart := 0;
          SelLength := 2;  
        end;

      2:
        begin
          M := Month;
          if M = 12 then 
          begin
            M := 1;
            Year := Year + 1;
          end  
          else  
            M := M + 1;

          if Day > DaysCount(M, Year) then
            Day := DaysCount(M, Year);
          Month := M;  
                    
          SelStart := 3;
          SelLength := 2;
        end;  

      3:
        begin
          Year := Year + 1;  
          SelStart := 6;
          SelLength := 4;
        end;  

      4:
        begin
          if Hour = 23 then
            Hour := 0
          else
            Hour := Hour + 1;
            SelStart := 11;
            SelLength := 2;
        end;

      5:
        begin
          if Min = 59 then
          begin
            Min := 0;
            if Hour = 23 then
              Hour := 0
            else
              Hour := Hour + 1;
          end
          else
            Min := Min + 1;
          SelStart := 14;
          SelLength := 2;
        end;

      6:
        begin
          if Sec = 59 then
          begin
            Sec := 0;
            if Min = 59 then
            begin
              Min := 0;
              if Hour = 23 then 
                Hour := 0
              else
                Hour := Hour + 1;  
            end
            else
              Min := Min + 1;
          end
          else
            Sec := Sec + 1;
          SelStart := 17;
          SelLength := 2;
        end;      
    end
  else
    case Value of
      1:
        begin
          if Hour = 23 then
            Hour := 0
          else
            Hour := Hour + 1;  
          SelStart := 0;
          SelLength := 2;  
        end;

      2:
        begin
          if Min = 59 then
          begin
            Min := 0;
            if Hour = 23 then
              Hour := 0
            else
              Hour := Hour + 1;  
          end
          else
            Min := Min + 1;
          SelStart := 3;
          SelLength := 2;
        end;  

      3:
        begin
          if Sec = 59 then
          begin
            Sec := 0;
            if Min = 59 then
            begin
              Min := 0;
              if Hour = 23 then
                Hour := 0
              else
                Hour := Hour + 1;
            end
            else
              Min := Min + 1;
          end
          else
            Sec := Sec + 1;
          SelStart := 6;
          SelLength := 4;
        end;
    end;   
end;


//   KEY_PRESS
procedure TxCustomDateEdit.KeyPress(var Key: Char);
var
  Len: Integer;
  stDay, stMonth, stYear: String;
  stHour, stMin, stSec: String;
  {S,} Y: String;
  ToNext: Boolean;
  W: TWinControl;
begin
  if not (Key in [' ', #0, '0'..'9']) then
  begin
    inherited KeyPress(Key);
  end else
  begin
    ToNext := False;
    Len := SelStart;
    case Key of
      #32:
        if ReadOnly then
          Key := #0
        else begin
          case FKind of
            kDate, kDateTime:
              begin
                GetDateInStr(Now, stYear, stMonth, stDay);
                GetTimeInStr(Now, stHour, stMin, stSec);
                if Len < 3 then Text := stDay;
                if Len in [3..5] then Text := Copy(Text, 1, 3) + stMonth;
                if Len in [6..10] then
                begin
                  Text := Copy(Text, 1, 6) + stYear;
                  SelStart := 11;
                  ToNext := FKind = kDate;
                end;
                if Len in [11..14] then Text := Copy(Text, 1, 11) + stHour;
                if Len in [13..15] then Text := Copy(Text, 1, 15) + stMin;
                if Len in [16..18] then
                begin
                  Text := Copy(Text, 1, 18) + stSec;
                  ToNext := True;
                end;
                Key := #0;
                if SelStart <> 11 then
                  SelStart := GetLength;
                SelLength := 1;
              end;

            kTime:
              begin
                GetTimeInStr(Now, stHour, stMin, stSec);
                if Len < 3 then Text := stHour;
                if Len in [3..5] then Text := Copy(Text, 1, 3) + stMin;
                if Len > 5 then
                begin
                  Text := Copy(Text, 1, 6) + stSec;
                  ToNext := True;
                end;
                Key := #0;
                SelStart := GetLength;
                SelLength := 1;
              end;
          end;
        end;

      else
        if ReadOnly or (not GoodValue(StrToInt(Key))) then
          Key := #0;
      end;

    inherited KeyPress(Key);

    if (FKind = kDate) or (FKind = kDateTime) then
    begin
      if SelStart = 3 then
      begin
        ValidDate(2);
        SelStart := 3;
        SelLength := 1;
      end;

      if SelStart = 6 then
      begin
        ValidDate(1);
        SelStart := 6;
        SelLength := 1;
      end;

      if (Pos('yyyy', ShortDateFormat) = 0)
        and (Pos('yy', ShortDateFormat) > 0)
        and (SelStart = 6) then
      begin
        if Length(Text) > 7 then
        begin
          Y := FormatDateTime('yyyy', Now);
          SelStart := 6;
          SelLength := 2;
          SelText := Copy(Y, 1, 2);
        end;

        SelStart := 8;
        SelLength := 1;
      end;
    end;

    if ToNext then
    begin
      if Parent is TWinControl then
      begin
        W := TWinControlCrack(Parent).FindNextControl(Self, True, True, True);
        if W <> nil then W.SetFocus;
      end;
    end;
  end;
end;

//   GOOD_VALUE
function TxCustomDateEdit.GoodValue(Value: Word): Boolean;
var
  St: String;
begin
  Result := False;
  
  case FKind of
    kDate, kDateTime:
      case SelStart of
        0:
          if Value < 4 then 
          begin
            Result := True;
            St := Text;
            Delete(St, 2, 1);
            Insert(' ', St, 2);
            Text := St;
          end;
      
        1:
          if Text[1] <> ' ' then
            case StrToInt(Text[1]) of
              0:
                if Value <> 0 then Result := True;
              3:
                if Value < 2 then Result := True;
              else
                Result := True;  
            end;
      
        3:
          if Value < 2 then 
          begin
            Result := True;
            St := Text;
            Delete(St, 4, 2);
            Insert(IntToStr(Value) + ' ', St, 4);
            Text := St;
            SelStart := 4;
          end;  
            
        4:
          if Text[4] <> ' ' then
            case StrToInt(Text[4]) of
              0:
                if Value > 0 then Result := True;
              1:
                if Value < 3 then Result := True;
              else
                Result := True;  
            end;

        11:
          if Value < 2 then
            Result := True
          else
            if Value = 2 then  
            begin
              St := Text;
              Delete(St, 12, 2); {26.01.1997 12.12.12}
              Insert('2 ', St, 12);
              Text := St;
              SelStart := 12;
            end;

        12:
          if Text[12] <> ' ' then
            case StrToInt(Text[12]) of
              2:
                if Value < 4 then Result := True;
              else
                Result := True;  
            end;
      
        14:
          if Value < 6 then
            Result := True;

        17:
          if Value < 6 then
            Result := True;

        else
          Result := True;
      end;

    kTime:
      case SelStart of
        0:
          if Value < 2 then
            Result := True
          else
            if Value = 2 then  
            begin
              St := Text;
              Delete(St, 1, 2); {26.01.1997 12.12.12}
              Insert('2 ', St, 1);
              Text := St;
              SelStart := 1;
            end;

        1:
          if Text[1] <> ' ' then
            case StrToInt(Text[1]) of
              2:
                if Value < 4 then Result := True;
              else
                Result := True;  
            end;
      
        3:
          if Value < 6 then
            Result := True;
      
        6:
          if Value < 6 then
            Result := True;

        else
          Result := True;
      end;
  end;
end;

//   GET_LENGTH
function TxCustomDateEdit.GetLength: Word;
var
  Len: Integer;
begin
  Len := MaxLength;
  while (not (Text[Len] in ['0'..'9'])) and (Len <> 0) do
    Dec(Len);

  if (Len = 2) or (Len = 5) or (Len = 13) or (Len = 16) then
    Inc(Len);
    
  Result := Len;
end;

//   EMPTY_IN_DATE
function TxCustomDateEdit.EmptyInDate: Boolean;
begin
  Result := Pos('_', EditText) <> 0;
end;

//   VALID_DATE
procedure TxCustomDateEdit.ValidDate(Value: Byte);
var
  sDate, sDay, sMonth, sYear: String;
  aDay, aMonth, aYear: Integer;
  Code: Integer;
begin
  sDate := Text;
  sDay := Copy(sDate, 1, 2);
  sMonth := Copy(sDate, 4, 2);
  sYear := Copy(sDate, 7, 4);
  Val(sDay, aDay, Code);
  Val(sMonth, aMonth, Code);
  Val(sYear, aYear, Code);

  case Value of
    1:
      begin
        if aDay > DaysCount(aMonth, aYear) then
          aDay := DaysCount(aMonth, aYear);
        Delete(sDate, 1, 2);
        if aDay > 10 then
          sDay := IntToStr(aDay)
        else
          if aDay > 0 then
            sDay := '0' + IntToStr(aDay);
        Insert(sDay, sDate, 1);
        Text := sDate;
      end;

    2:
      if aDay > DaysCount(aMonth, aYear) then
      begin
        Delete(sDate, 4, 2);
        Insert('  ', sDate, 4);
        Text := sDate;
      end;
  end;
end;

//   CM_EXIT
procedure TxCustomDateEdit.CMExit(var Message: TCMExit);
var
  Pch: array [0..255] of Char;
  Error: Boolean;
begin
  Error := True;

  case FKind of
    kDate:
      try
        if IsEmpty(EditText) then
          Date := 0
        else
          Date := EncodeDate(GetTextYear, GetTextMonth, GetTextDay);
      except
        on EConvertError do
        begin
          Error := True;
          if FConvertErrorMessage then
          begin
            StrPCopy(Pch, 'Дата  "' + EditText + '"  некорректна!');
            MessageBox(Parent.Handle, Pch, 'Ошибка!', MB_OK or MB_ICONSTOP);
            SetFocus;
            SelectAll;
          end;
        end
        else
         raise;
      end;

    kTime:
      try
        if IsEmpty(EditText) then
          Time := 0
        else
          Time := EncodeTime(GetTextHour, GetTextMin, GetTextSec, 0);
      except
        on EConvertError do
        begin
          Error := True;
          if FConvertErrorMessage then
          begin
            StrPCopy(Pch, 'Время  "' + EditText + '"  некорректно!');
            MessageBox(Parent.Handle, Pch, 'Ошибка!', MB_OK or MB_ICONSTOP);
            SetFocus;
            SelectAll;
          end;
        end
        else
         raise;
      end;

    kDateTime:
      try
        if IsEmpty(EditText) then
          DateTime := 0
        else
          DateTime := EncodeDate(GetTextYear, GetTextMonth, GetTextDay) + EncodeTime(GetTextHour, GetTextMin, GetTextSec, 0);
      except
        on EConvertError do
        begin
          Error := True;
          if FConvertErrorMessage then
          begin
            StrPCopy(Pch, '"' + EditText + '" некорректная Дата и Время!');
            MessageBox(Parent.Handle, Pch, 'Ошибка!', MB_OK or MB_ICONSTOP);
            SetFocus;
            SelectAll;
          end;
        end
        else
         raise;
      end;
  end;

  if not Error then
    SetCursor(0);

  DoExit;
end;

//   GET_DATE_TIME
function TxCustomDateEdit.GetDateTime: TDateTime;
begin
  case Kind of
    kDateTime: Result := Date + Time;
    kDate: Result := Date;
  else
    Result := Time;
  end;
end;

//   SET_DATE_TIME
procedure TxCustomDateEdit.SetDateTime(const Value: TDateTime);
begin
  FDateTime := Value;

  case Kind of
    kDateTime:
    begin
      Date := Value;
      Time := Value;
    end;

    kDate:
    begin
      Date := Value;
      Time := 0;
    end;

    kTime:
    begin
      Date := 0;
      Time := Value;
    end;
  end;
end;

{**************************   TxDateDBEdit   **********************************}

//   CREATE
constructor TxDateDBEdit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  
  inherited ReadOnly := false;
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FCurrentDateTimeAtStart := False;
  FStoredDateTime := False;
end;

//   DESTROY
destructor TxDateDBEdit.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  
  inherited Destroy;
end;

//   NOTIFICATION
procedure TxDateDBEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

//   KEY_DOWN
procedure TxDateDBEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) or (Key = VK_DOWN) then
  begin
    if FDataLink.ReadOnly then
      inherited ReadOnly := True
    else
    begin
      if not FDataLink.Editing then
        FDataLink.Edit;
    end;
  end;

  inherited KeyDown(Key, Shift);

  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
    if not FDataLink.Editing then
      FDataLink.Edit;
end;

//   KEY_PRESS
procedure TxDateDBEdit.KeyPress(var Key: Char);
begin
  if (not (Key in [' ', #0, #13, #27, '0'..'9'])) then
  begin
    inherited KeyPress(Key);
    exit;
  end;

  if (not FDataLink.Active) then
    exit;

  if FDataLink.ReadOnly then
    inherited ReadOnly := True;  

  if FDataLink.DataSource <> nil then
    if (Key <> #27) and (not (DataSource.DataSet.State in [dsEdit, dsInsert])) then
      DataSource.DataSet.Edit;

  case Key of
    #27:
      begin
        if (DataSource.DataSet.State in [dsEdit, dsInsert]) then
          FDataLink.Reset;
        SelectAll;
        Key := #0;
      end;  

    #13:
      begin
        FDataLink.UpdateRecord;
        FDataLink.Modified;
        Key := #0;
      end;
    else
    begin
      inherited KeyPress(Key);
      FDataLink.Modified;
    end;  
  end;  
end;

//   EDIT_CAN_MODIFY
function TxDateDBEdit.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

//   RESET
procedure TxDateDBEdit.Reset;
begin
  FDataLink.Reset;
  SelectAll;
end;

//   GET_DATA_SOURCE
function TxDateDBEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

//   SET_DATA_SOURCE
procedure TxDateDBEdit.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

//   GET_DATA_FIELD
function TxDateDBEdit.GetDataField: String;
begin
  Result := FDataLink.FieldName;
end;

//   SET_DATA_FIELD
procedure TxDateDBEdit.SetDataField(const Value: String);
begin
  if FDataLink.FieldName <> Value then
  begin
    if FDataLink.Active then
      FDataLink.UpdateRecord;
    FDataLink.FieldName := Value;
  end;
end;

//   GET_READ_ONLY
function TxDateDBEdit.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

//   SET_READ_ONLY
procedure TxDateDBEdit.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

//   GET_FIELD
function TxDateDBEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

//   DATA_CHANGE
procedure TxDateDBEdit.DataChange(Sender: TObject);
begin
  if FDataLink <> nil then
    if FDataLink.Field <> nil then
    case Kind of
      kDate:
        Date := FDataLink.Field.AsDateTime;

      kDateTime:
        DateTime := FDataLink.Field.AsDateTime;

      kTime:
        Time := FDataLink.Field.AsDateTime;
    end;        
end;

//   CHANGE
procedure TxDateDBEdit.Change;
begin
  inherited Change;

  if FDataLink <> nil then
    if FDataLink.Field <> nil then
      FDataLink.Modified;
end;

//   UPDATE_DATA
procedure TxDateDBEdit.UpdateData(Sender: TObject);

  function IsAlpha: Boolean;
  var
    I: Integer;
  begin
    for I := 1 to Length(Text) do
    begin
      if Text[I] in ['0'..'9'] then
      begin
        Result := True;
        exit;
      end;
    end;
    Result := False;
  end;

begin
  ValidateEdit;
  if IsAlpha then
    case Kind of
      kDate:
        FDataLink.Field.AsDateTime := Date;

      kDateTime:
        FDataLink.Field.AsDateTime := DateTime;

      kTime:
        FDataLink.Field.AsDateTime := Time;
    end
  else
    FDataLink.Field.Clear;
end;

//   WM_PASTE
procedure TxDateDBEdit.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

//   WM_CUT
procedure TxDateDBEdit.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

//   CM_EXIT
procedure TxDateDBEdit.CMExit(var Message: TCMExit);
var
  Pch: array [0..255] of Char;
  Error: Boolean;
begin
  Error := True;

  if not ((Owner is TCustomForm)
    and (TCustomForm(Owner).ActiveControl is TButton)
    and TButton(TCustomForm(Owner).ActiveControl).Cancel) then
  begin
    try
      FDataLink.UpdateRecord;
    except
      on EConvertError do
      begin
        Error := True;
        if ConvertErrorMessage then
        begin
          StrPCopy(Pch, 'Дата  "' + EditText + '"  некорректна!');
          MessageBox(Parent.Handle, Pch, 'Ошибка!', MB_OK or MB_ICONSTOP);
          SetFocus;
          SelectAll;
        end;
      end
      else
       raise;
    end;
  end;

  if not Error then
    SetCursor(0);

  if not Focused then
    FDataLink.Reset;

  DoExit;
end;

procedure Register;
begin
  RegisterComponents('x-VisualControl', [TxDateEdit, TxDateDBEdit]);
end;

function TxCustomDateEdit.IsEmpty(AnValue: String): Boolean;
const
  NoEmpt = '123456789';
var
  I: Integer;
begin
  Result := True;
  for I := 1 to Length(AnValue) do
    if Pos(AnValue[I], NoEmpt) > 0 then
    begin
      Result := False;
      Break;
    end;
end;

function TxCustomDateEdit.GetTextDay: Word;
var
  Code: Integer;
begin
  Result := 0;
  if FKind <> kTime then
  begin
    Val(Copy(Text, 1, 2), Result, Code);
    if Code <> 0 then
      raise EConvertError.Create('Некорректная дата.');
  end;
end;

function TxCustomDateEdit.GetTextHour: Word;
var
  Code: Integer;
begin
  Result := 0;
  Code := 0;
  if FKind = kTime then
    Val(Copy(Text, 1, 2), Result, Code)
  else
    if FKind = kDateTime then
      Val(Copy(Text, 12, 2), Result, Code);
  if Code <> 0 then
    raise EConvertError.Create('Некорректное время.');
end;

function TxCustomDateEdit.GetTextMin: Word;
var
  Code: Integer;
begin
  Result := 0;
  Code := 0;
  if FKind = kTime then
    Val(Copy(Text, 4, 2), Result, Code)
  else
    if FKind = kDateTime then
      Val(Copy(Text, 15, 2), Result, Code);
  if Code <> 0 then
    raise EConvertError.Create('Некорректное время.');
end;

function TxCustomDateEdit.GetTextMonth: Word;
var
  Code: Integer;
begin
  Result := 0;
  if FKind <> kTime then
  begin
    Val(Copy(Text, 4, 2), Result, Code);
    if Code <> 0 then
      raise EConvertError.Create('Некорректная дата.');
  end;
end;

function TxCustomDateEdit.GetTextSec: Word;
var
  Code: Integer;
  S: String;
begin
  Result := 0;
  Code := 0;

  if FKind = kTime then
    S := Copy(Text, 7, 2)
  else if FKind = kDateTime then
    S := Copy(Text, 18, 2);

  if S > '' then
    Val(S, Result, Code);
  if Code <> 0 then
    raise EConvertError.Create('Некорректное время.');
end;

function TxCustomDateEdit.GetTextYear: Word;
var
  Code: Integer;
begin
  Result := 0;
  if FKind <> kTime then
  begin
    Val(Copy(Trim(Text), 7, 4), Result, Code);

    if Code <> 0 then
      raise EConvertError.Create('Некорректная дата.');
  end;    

  { TODO : н-да. после 2050 года программа будет работать не всегда удобно }
  if Result < 100 then
  begin
    if Result < 50 then
      Result := 2000 + Result
    else
      Result := 1900 + Result;
  end;
end;

procedure TxDateDBEdit.Loaded;
begin
  inherited;

  FStoredDateTime := False;
end;

procedure TxDateDBEdit.SetTime(const Value: TTime);
begin
  if (Kind = kTime) and FDataLink.Field.IsNull then
  begin
    FTime := Value;
    EditText := '__:__:__';
  end else
    inherited;
end;

end.
