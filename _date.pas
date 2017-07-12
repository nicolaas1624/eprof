Unit _date;

{$mode objfpc}{$H+}

interface

uses SysUtils, Dialogs;

function TimeStrToMin(TimeStr: String): Word;
function FloatToTimeStr(Time: Double): String;
function DateDiffToTimeStr(DateDiffVar: TDateTime): String; // DateTime -> hhh:mm:ss
function TimeStrToFloat(TimeStr: String): Double; { hh:mm -> float }
function IncDate(DateStr: String; Days: Integer): String;
function DayOfYear(DateVar: TDateTime): Integer;
function DateFromDOY(DOY, Year: Word): String;
function CalcDays(Paid, PrevDate, Payable: TDateTime): Integer;
function IncMnth(Month: Integer): Integer;
function DecMnth(Month: Integer): Integer;
function SetMonth(Text: String): Integer;
function ShortDayToInt(DayName: String): Integer;
function ShortMnthToInt(MonthName: String): Integer;
procedure DecodeDateStr(FormatStr, DateStr: String; YearVal, DOYVal: Integer; var Year, Month, Day: Word);
procedure DecodeTimeStr(FormatStr, TimeStr: String;
  var Hours, Minutes, Secs: Integer);

implementation

uses _misc;

function TimeStrToMin(TimeStr: String): Word;
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(StrToTime(TimeStr), Hour, Min, Sec, MSec);
  Result := Round((Hour * 3600 + Min * 60 + Sec) / 60);
end;

function FloatToTimeStr(Time: Double): String; { float -> hh:mm }
var
  h, m: Integer;
begin
  h := Trunc(Time);
  m := Round(Frac(Time) * 60);
  if h < 10 then
    Result := Result + '0' + IntToStr(h)
  else
    Result := IntToStr(h);
  if m < 10 then
    Result := Result + ':0' + IntToStr(m)
  else
    Result := Result + ':' + IntToStr(m);
end;

function DateDiffToTimeStr(DateDiffVar: TDateTime): String;
{ DateTime -> hhh:mm:ss }
var
  Hour, Min, Sec, MSec: Word;
begin
  if DateDiffVar >= 0 then
  begin
    DecodeTime(Frac(DateDiffVar), Hour, Min, Sec, MSec);
    Hour := Trunc(DateDiffVar) * 24 + Hour;
    if Hour < 10 then
      Result := Result + '0' + IntToStr(Hour)
    else
      Result := IntToStr(Hour);
    if Min < 10 then
      Result := Result + ':0' + IntToStr(Min)
    else
      Result := Result + ':' + IntToStr(Min);
    if Sec < 10 then
      Result := Result + ':0' + IntToStr(Sec)
    else
      Result := Result + ':' + IntToStr(Sec);
  end
  else
    Result := '00:00:00';
end;

function TimeStrToFloat(TimeStr: String): Double; { hh:mm -> float }
var
  i, h, m: Integer;
begin
  if Trim(TimeStr) <> '' then
  begin
    TimeStr := '0' + TimeStr;
    i := Pos(':', TimeStr);
    if i > 0 then
    begin
      h := StrToInt(Copy(TimeStr, 0, i - 1));
      m := StrToInt('0' + Copy(TimeStr, i + 1, Length(TimeStr) - i));
    end
    else
    begin
      h := StrToInt(TimeStr);
      m := 0;
    end;
    Result := h + m / 60;
  end;
end;

function IncDate(DateStr: String; Days: Integer): String;
begin
  IncDate := DateToStr(StrToDate(DateStr) + Days);
end;

function DayOfYear(DateVar: TDateTime): Integer;
var
  Date1: TDateTime;
  Y, m, D: Word;
begin
  DecodeDate(DateVar, Y, m, D);
  Date1 := EncodeDate(Y, 1, 1);
  Result := Trunc(DateVar - Date1) + 1;
end;

function DateFromDOY(DOY, Year: Word): String;
begin
  DateFromDOY := DateToStr(EncodeDate(Year, 1, 1) + DOY - 1);
end;

function CalcDays(Paid, PrevDate, Payable: TDateTime): Integer;
begin
  if PrevDate > Payable then
    Result := Trunc(Paid) - Trunc(PrevDate) - 1
  else
    Result := Trunc(Paid) - Trunc(Payable) - 1;
end;

function IncMnth(Month: Integer): Integer;
begin
  if Month = 12 then
    Month := 1
  else
    Inc(Month);
  Result := Month;
end;

function DecMnth(Month: Integer): Integer;
begin
  if Month = 1 then
    Month := 12
  else
    Dec(Month);
  Result := Month;
end;

function SetMonth(Text: String): Integer;
var
  i: Integer;
begin
  Result := 1;
  for i := 1 to 12 do
    if Text = FormatSettings.LongMonthNames[i] then
    begin
      Result := i;
      Break;
    end;
end;

function ShortDayToInt(DayName: String): Integer;
var
  i: Integer;
begin
  Result := 1;
  for i := 1 to 7 do
    if DayName = FormatSettings.ShortDayNames[i] then
    begin
      Result := i;
      Break;
    end;
end;

function ShortMnthToInt(MonthName: String): Integer;
var
  i: Integer;
begin
  Result := 1;
  for i := 1 to 12 do
    if MonthName = FormatSettings.ShortMonthNames[i] then
    begin
      Result := i;
      Break;
    end;
end;

procedure DecodeDateStr(FormatStr, DateStr: String; YearVal, DOYVal: Integer; var Year, Month, Day: Word);
var
  P1, P2: Integer;
  TmpDate: TDateTime;
begin
  if FormatStr <> '' then
  begin
    if FormatStr = 'dd/mm/yyyy' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'dd.mm.yyyy' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'mm/dd/yyyy' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, 1, P1 - 1));
      Day := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
    end
    else if FormatStr = 'mm.dd.yyyy' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, 1, P1 - 1));
      Day := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
    end
    else if FormatStr = 'dd/mm/yy' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'dd.mm.yy' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'yyyy/mm/dd' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yyyy.mm.dd' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yyyy-mm-dd' then
    begin
      P1 := Pos('-', DateStr);
      P2 := LastDelimiter('-', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yy/mm/dd' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yy.mm.dd' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'ddmmyyyy' then
    begin
      Year := StrToInt(Copy(DateStr, 5, 4));
      Month := StrToInt(Copy(DateStr, 3, 2));
      Day := StrToInt(Copy(DateStr, 1, 2));
    end
    else if FormatStr = 'ddmmyy' then
    begin
      Year := StrToInt(Copy(DateStr, 5, 2)) + 2000;
      Month := StrToInt(Copy(DateStr, 3, 2));
      Day := StrToInt(Copy(DateStr, 1, 2));
    end
    else if FormatStr = 'ddmmmyyyy' then
    begin
      if Length(DateStr) = 8 then
      begin
        Year := StrToInt(Copy(DateStr, 5, 4));
        Month := ShortMnthToInt(Copy(DateStr, 2, 3));
        Day := StrToInt(Copy(DateStr, 1, 1));
      end
      else
      begin
        Year := StrToInt(Copy(DateStr, 6, 4));
        Month := ShortMnthToInt(Copy(DateStr, 3, 3));
        Day := StrToInt(Copy(DateStr, 1, 2));
      end
    end
    else if FormatStr = 'yyyymmdd' then
    begin
      Year := StrToInt(Copy(DateStr, 1, 4));
      Month := StrToInt(Copy(DateStr, 5, 2));
      Day := StrToInt(Copy(DateStr, 7, 2));
    end
    else if FormatStr = 'yymmdd' then
    begin
      Year := StrToInt(Copy(DateStr, 1, 2)) + 2000;
      Month := StrToInt(Copy(DateStr, 3, 2));
      Day := StrToInt(Copy(DateStr, 5, 2));
    end
    else if FormatStr = 'DOY' then
    begin
      TmpDate := EncodeDate(YearVal, 1, 1) + DOYVal - 1;
      DecodeDate(TmpDate, Year, Month, Day);
    end;
  end;
end;

procedure DecodeTimeStr(FormatStr, TimeStr: String;
  var Hours, Minutes, Secs: Integer);
var
  S: String;
  AMPMStr: String;
  P1: Integer;
begin
  if FormatStr <> '' then
  begin
    AMPMStr := Copy(TimeStr, Length(TimeStr) - 1, 2);
    if FormatStr = 'hh:mm' then
    begin
      P1 := Pos(':', TimeStr);
      Hours := StrToInt(Copy(TimeStr, 1, P1 - 1));
      Minutes := StrToInt(Copy(TimeStr, P1 + 1, 2));
      Secs := 0;
    end
    else if FormatStr = 'hh:mm AM' then
    begin
      P1 := Pos(':', TimeStr);
      Hours := StrToInt(Copy(TimeStr, 1, P1 - 1));
      Minutes := StrToInt(Copy(TimeStr, P1 + 1, 2));
      Secs := 0;
    end
    else if FormatStr = 'hhmm' then
    begin
      P1 := Length(TimeStr);
      S := Trim(TimeStr);
      Delete(S, Length(S) - 1, 2);
      Hours := StrToInt(S);
      Minutes := StrToInt(Copy(TimeStr, P1 - 1, 2));
      Secs := 0;
    end
    else if FormatStr = 'hhmmss' then
    begin
      S := PadLeft(TimeStr, '0', 6);
      Hours := StrToInt(Copy(S, 1, 2));
      Minutes := StrToInt(Copy(S, 3, 2));
      Secs := StrToInt(Copy(S, 5, 2));
    end
    else if FormatStr = 'hhmm AM' then
    begin
      P1 := Length(TimeStr);
      S := Trim(TimeStr);
      Delete(S, Length(S) - 4, 5);
      Hours := StrToInt(S);
      Minutes := StrToInt(Copy(TimeStr, P1 - 4, 2));
      Secs := 0;
    end
    else if FormatStr = 'hh:mm:ss' then
    begin
      P1 := Pos(':', TimeStr);
      Hours := StrToInt(Copy(TimeStr, 1, P1 - 1));
      Minutes := StrToInt(Copy(TimeStr, P1 + 1, 2));
      Secs := StrToInt(Copy(TimeStr, P1 + 4, 2));
    end
    else if FormatStr = 'hh:mm:ss AM' then
    begin
      P1 := Pos(':', TimeStr);
      Hours := StrToInt(Copy(TimeStr, 1, P1 - 1));
      Minutes := StrToInt(Copy(TimeStr, P1 + 1, 2));
      Secs := StrToInt(Copy(TimeStr, P1 + 4, 2));
    end;
    if Uppercase(AMPMStr) = 'PM' then
      Hours := Hours + 12
    else
    begin
      if Hours = 12 then
        Hours := 0;
    end;
  end;
end;

end.
