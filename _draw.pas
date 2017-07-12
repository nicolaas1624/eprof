unit _draw;

interface

uses SysUtils, Windows, Printers, Graphics, IBQuery, Math, Classes, DB;

type
  pGraphTypes = (pLineGraph, pDateGraph, pDayGraph, pDOYGraph, pTimeGraph, pOtherGraph, pMonthGraph);
  pptTypes    = (pptBox, pptBoxR, pptHGlass, pptCircle, pptTriangleB, pptTriangleT, pptTriangleF);

  grRec = record
    GraphType: pGraphTypes;
    xMin,
    xMax,
    yMin,
    yMax,
    dx,
    dxi,
    dy,
    dyi: double;
    lTick: double;
    sTick: double;
    xDecPlaces: Integer;
    yDecPlaces: Integer;
  end;

var
  gr: grRec;

  bDefFontSize: Integer;
  pTitleFontSize: Integer;
  pSubTitleFontSize: Integer;
  pXlargeFontSize: Integer;
  pLargeFontSize: Integer;
  pMedFontSize: Integer;
  pDefFontSize: Integer;

  pWidth_mm: Integer = 210;  // A4 page size = 210 x 297 mm
  pHeight_mm: Integer = 297;
  pDefFontColor: TColor = clBlack;
  pDefFontStyle: TFontStyles = [];
  pDefPenWidth: Integer = 1;
  pDefPenColor: TColor = clBlack;
  pDefPenStyle: TPenStyle = psSolid;
  pDefBrushColor: TColor = clWhite;
  pDefBrushStyle: TBrushStyle = bsSolid;
  pDefFontName: String = 'Tahoma';
  pOrientation: TPrinterOrientation = poPortrait;
  pX,
  pY,
  pXf,
  pYf,
  pXsf,
  pYsf,
  pXoffset,
  pYoffset: double;
  pPageNo,
  pNoOfPages: Integer;

function pXmm(XVal: double): Integer;
function pYmm(YVal: double): Integer;

procedure pInit(dCanvas: TCanvas; pWidth, pHeight: Integer; pOrientation: TPrinterOrientation);
procedure pDrawTemplate(dCanvas: TCanvas; pWidth, pHeight, pLH, PenWidth: Integer; PenColor, FontSize: Integer; FontColor, BrushColor: TColor);
procedure pRect(dCanvas: TCanvas; x1, y1, x2, y2: double; PenWidth: Integer; PenStyle: TPenStyle; PenColor, BrushColor: TColor);
procedure pLine(dCanvas: TCanvas; x1, y1, x2, y2: double; PenWidth: Integer; PenStyle: TPenStyle; PenColor: TColor);
procedure pText(dCanvas: TCanvas; x1, y1: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pCText(dCanvas: TCanvas; x1, y1, x2: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pRJText(dCanvas: TCanvas; x1, y1: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pAngleText(dCanvas: TCanvas; x1, y1, angle: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pCAngleText(dCanvas: TCanvas; x1, y1, y2, angle: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pRJAngleText(dCanvas: TCanvas; x1, y1, angle: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pSetTextAngle(dCanvas: TCanvas; pAngle: double);
procedure pImage(dCanvas: TCanvas; Width_mm, Height_mm, X_mm, Y_mm: String; PICTIDVal, PICTNOVal: Integer);

// graph procedures & functions
function niceNum(range: double): double;
function gGetStep(Range: double): double;
function gGetDecStr(Val: double; DecPlaces: Integer): String;
procedure gDrawXaxis(dCanvas: TCanvas; GraphType: pGraphTypes; x1, x2, y: double;
  FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure gDrawYLeftaxis(dCanvas: TCanvas; GraphType: pGraphTypes; x1, x2, y1, y2: double;
  FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure gMoveTo(dCanvas: TCanvas; x, y: double);
procedure gLineTo(dCanvas: TCanvas; x, y: double; PenWidth: Integer; PenStyle: TPenStyle; PenColor: TColor);
procedure gVertBar(dCanvas: TCanvas; x1, y2, dx: double; Justify: String;
  PenWidth: Integer; PenColor, BrushColor: TColor; BrushStyle: TBrushStyle);

implementation

uses _dm, _Date;

function pXmm(XVal: double): Integer;
begin
  Result := Round(XVal * pXf);
end;

function pYmm(YVal: double): Integer;
begin
  Result := Round(YVal * pYf);
end;

procedure pInit(dCanvas: TCanvas; pWidth, pHeight: Integer; pOrientation: TPrinterOrientation);
var
  R: TRect;
begin
  //  dCanvas.Clear;
  R.Left := 0;
  R.Top := 0;
  R.Width := pWidth;
  R.Height := pHeight;
  dCanvas.FillRect(R);
  dCanvas.Font.Size := bDefFontSize;

  if pOrientation = poPortrait then
  begin
    pWidth_mm := 210; // portrait: A4 page size = 210 x 297 mm
    pHeight_mm := 297;
  end
  else
  begin
    pWidth_mm := 297;
    pHeight_mm := 210;
  end;
  pXf := pWidth / pWidth_mm;                    // X factor in Pixels per mm
  pYf := pHeight / pHeight_mm;                  // Y factor in Pixels per mm
  pNoOfPages := 1;

  pTitleFontSize := Round(bDefFontSize * pYmm(7) / dCanvas.Font.Height);
  pSubTitleFontSize := Round(bDefFontSize * pYmm(6) / dCanvas.Font.Height);
  pXlargeFontSize := Round(bDefFontSize * pYmm(4.5) / dCanvas.Font.Height);
  pLargeFontSize := Round(bDefFontSize * pYmm(4) / dCanvas.Font.Height);
  pMedFontSize := Round(bDefFontSize * pYmm(3.5) / dCanvas.Font.Height);
  pDefFontSize := Round(bDefFontSize * pYmm(3) / dCanvas.Font.Height);
end;

procedure pDrawTemplate(dCanvas: TCanvas; pWidth, pHeight, pLH, PenWidth: Integer; PenColor, FontSize: Integer; FontColor, BrushColor: TColor);
var
  i: Integer;
begin
  dCanvas.Font.Size := FontSize;
  dCanvas.Pen.Style := psDot;
  dCanvas.Pen.Width := PenWidth;
  dCanvas.Pen.Color := PenColor;
  dCanvas.Font.Color := FontColor;
  dCanvas.Brush.Color := BrushColor;
  i := 0;
  repeat
    dCanvas.MoveTo(0, pYmm(i));
    dCanvas.LineTo(pWidth, pYmm(i));
    if i > 0 then
      dCanvas.TextOut(pXmm(1), pYmm(i) - Abs(dCanvas.Font.Height) div 2, IntToStr(i));
    Inc(i, pLH);
  until i >= pHeight_mm;
  i := 0;
  repeat
    dCanvas.MoveTo(pXmm(i), 0);
    dCanvas.LineTo(pXmm(i), pHeight);
    if i > 0 then
      dCanvas.TextOut(pXmm(i) - dCanvas.TextWidth(IntToStr(i)) div 2, pYmm(1), IntToStr(i));
    Inc(i, pLH);
  until i >= pWidth_mm;
  dCanvas.Font.Size := bDefFontSize;
  dCanvas.Pen.Style := psSolid;
  dCanvas.Pen.Width := pDefPenWidth;
  dCanvas.Pen.Color := pDefPenColor;
  dCanvas.Font.Color := pDefFontColor;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pRect(dCanvas: TCanvas; x1, y1, x2, y2: double; PenWidth: Integer; PenStyle: TPenStyle; PenColor, BrushColor: TColor);
begin
  dCanvas.Pen.Width := PenWidth;
  dCanvas.Pen.Style := PenStyle;
  dCanvas.Pen.Color := PenColor;
  dCanvas.Brush.Color := BrushColor;
  dCanvas.Rectangle(pXmm(x1), pYmm(y1), pXmm(x2), pYmm(y2));
  dCanvas.Pen.Width := pDefPenWidth;
  dCanvas.Pen.Style := pDefPenStyle;
  dCanvas.Pen.Color := pDefPenColor;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pLine(dCanvas: TCanvas; x1, y1, x2, y2: double; PenWidth: Integer; PenStyle: TPenStyle; PenColor: TColor);
begin
  dCanvas.Pen.Width := PenWidth;
  dCanvas.Pen.Style := PenStyle;
  dCanvas.Pen.Color := PenColor;
  dCanvas.MoveTo(pXmm(x1), pYmm(y1));
  dCanvas.LineTo(pXmm(x2), pYmm(y2));
  dCanvas.Pen.Width := pDefPenWidth;
  dCanvas.Pen.Style := pDefPenStyle;
  dCanvas.Pen.Color := pDefPenColor;
end;

procedure pText(dCanvas: TCanvas; x1, y1: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  dCanvas.Font.Name := FontName;
  dCanvas.Font.Size := FontSize;
  dCanvas.Font.Color := FontColor;
  dCanvas.Font.Style := FontStyle;
  dCanvas.Brush.Color := BrushColor;
  dCanvas.TextOut(pXmm(x1), pYmm(y1), S);
  dCanvas.Font.Name := pDefFontName;
  dCanvas.Font.Size := pDefFontSize;
  dCanvas.Font.Color := pDefFontColor;
  dCanvas.Font.Style := pDefFontStyle;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pCText(dCanvas: TCanvas; x1, y1, x2: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  dCanvas.Font.Name := FontName;
  dCanvas.Font.Size := FontSize;
  dCanvas.Font.Color := FontColor;
  dCanvas.Font.Style := FontStyle;
  dCanvas.Brush.Color := BrushColor;
  dCanvas.TextOut(pXmm(x1 + (x2 - x1) / 2) - dCanvas.TextWidth(S) div 2, pYmm(y1), S);
  dCanvas.Font.Name := pDefFontName;
  dCanvas.Font.Size := pDefFontSize;
  dCanvas.Font.Color := pDefFontColor;
  dCanvas.Font.Style := pDefFontStyle;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pRJText(dCanvas: TCanvas; x1, y1: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  dCanvas.Font.Name := FontName;
  dCanvas.Font.Size := FontSize;
  dCanvas.Font.Color := FontColor;
  dCanvas.Font.Style := FontStyle;
  dCanvas.Brush.Color := BrushColor;
  dCanvas.TextOut(pXmm(x1) - dCanvas.TextWidth(S), pYmm(y1), S);
  dCanvas.Font.Name := pDefFontName;
  dCanvas.Font.Size := pDefFontSize;
  dCanvas.Font.Color := pDefFontColor;
  dCanvas.Font.Style := pDefFontStyle;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pSetTextAngle(dCanvas: TCanvas; pAngle: double);
var
  LFont: TLogFont;
  NFont: TFont;
begin
  NFont := TFont.Create;
  try
    NFont.Name := 'Arial';
    NFont.Color := dCanvas.Font.Color;
    GetObject(NFont.Handle, SizeOf(LFont), @LFont);
    LFont.lfEscapement := Round(pAngle * 10);
    LFont.lfOrientation := LFont.lfEscapement;
    LFont.lfOutPrecision := OUT_TT_ONLY_PRECIS;
    if dCanvas.Font.Style = [fsBold] then
      LFont.lfWeight := FW_BOLD;
    LFont.lfHeight := -MulDiv(dCanvas.Font.Size, GetDeviceCaps(dCanvas.Handle, LOGPIXELSY), 72);
    dCanvas.Font.Handle := CreateFontIndirect(LFont);
  finally
    NFont.Free;
  end;
end;

procedure pAngleText(dCanvas: TCanvas; x1, y1, angle: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  dCanvas.Font.Name := FontName;
  dCanvas.Font.Size := FontSize;
  dCanvas.Font.Color := FontColor;
  dCanvas.Font.Style := FontStyle;
  dCanvas.Brush.Color := BrushColor;
  pSetTextAngle(dCanvas, angle);
  dCanvas.TextOut(pXmm(x1), pYmm(y1), S);
  pSetTextAngle(dCanvas, 0);
  dCanvas.Font.Name := pDefFontName;
  dCanvas.Font.Size := pDefFontSize;
  dCanvas.Font.Color := pDefFontColor;
  dCanvas.Font.Style := pDefFontStyle;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pCAngleText(dCanvas: TCanvas; x1, y1, y2, angle: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  dCanvas.Font.Name := FontName;
  dCanvas.Font.Size := FontSize;
  dCanvas.Font.Color := FontColor;
  dCanvas.Font.Style := FontStyle;
  dCanvas.Brush.Color := BrushColor;
  pSetTextAngle(dCanvas, angle);
  dCanvas.TextOut(pXmm(x1), pYmm(y1 + (y2 - y1) / 2) + dCanvas.TextWidth(S) div 2, S);
  pSetTextAngle(dCanvas, 0);
  dCanvas.Font.Name := pDefFontName;
  dCanvas.Font.Size := pDefFontSize;
  dCanvas.Font.Color := pDefFontColor;
  dCanvas.Font.Style := pDefFontStyle;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pRJAngleText(dCanvas: TCanvas; x1, y1, angle: double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  dCanvas.Font.Name := FontName;
  dCanvas.Font.Size := FontSize;
  dCanvas.Font.Color := FontColor;
  dCanvas.Font.Style := FontStyle;
  dCanvas.Brush.Color := BrushColor;
  pSetTextAngle(dCanvas, angle);
  dCanvas.TextOut(pXmm(x1), pYmm(y1) + dCanvas.TextWidth(S), S);
  pSetTextAngle(dCanvas, 0);
  dCanvas.Font.Name := pDefFontName;
  dCanvas.Font.Size := pDefFontSize;
  dCanvas.Font.Color := pDefFontColor;
  dCanvas.Font.Style := pDefFontStyle;
  dCanvas.Brush.Color := pDefBrushColor;
end;

procedure pImage(dCanvas: TCanvas; Width_mm, Height_mm, X_mm, Y_mm: String;
  PICTIDVal, PICTNOVal: Integer);
var
  Q: TIBQuery;
  bf: TBlobField;
  Graphic: TGraphic;
  Stream: TMemoryStream;
  PICTFORMATVal: String;
  ImageWidth, ImageHeight, ImageX, ImageY: Integer;
begin
  ImageWidth := pXmm(StrToInt(dm.GetParamValue(Width_mm)));
  ImageHeight := pYmm(StrToInt(dm.GetParamValue(Height_mm)));
  ImageX := pXmm(StrToInt(dm.GetParamValue(X_mm)));
  ImageY := pYmm(StrToInt(dm.GetParamValue(Y_mm)));
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT PICTFORMAT, PICT FROM T_PICT WHERE PICTID = :PICTID AND PICTNO = :PICTNO');
    Q.ParamByName('PICTID').AsInteger := PICTIDVal;
    Q.ParamByName('PICTNO').AsInteger := PICTNOVal;
    Q.Prepare;
    Q.Open;
    Graphic := nil;
    PICTFORMATVal := Q.FieldByName('PICTFORMAT').AsString;
    if PICTFORMATVal = 'BMP' then
      Graphic := TBitMap.Create
    else if PICTFORMATVal = 'ICO' then
      Graphic := TIcon.Create
    else if (PICTFORMATVal = 'JPG') or (PICTFORMATVal = 'JPEG') then
      Graphic := TJPEGImage.Create;
    if Graphic <> nil then
    begin
      Stream := TMemoryStream.Create;
      try
        bf := Q.FieldByName('PICT') as TBlobField;
        bf.SaveToStream(Stream);
        Stream.Position := 0;
        Graphic.LoadFromStream(Stream);
        dCanvas.StretchDraw(Rect(ImageX, ImageY, ImageX + ImageWidth, ImageY + ImageHeight), Graphic);
      finally
        Stream.Free;
      end;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

{  * Returns a "nice" number approximately equal to range Rounds
   * the number if round = true Takes the ceiling if round = false.
   *
   * @param range the data range
   * @param round whether to round the result
   * @return a "nice" number to be used for the data range }
function niceNum(range: double): double;
var
  exponent: double;  // exponent of range
  fraction: double;  // fractional part of range
  niceFraction: double;  // nice, rounded fraction
begin
  if range <> 0 then
  begin
    exponent := trunc(Log10(abs(range)));
    fraction := abs(range) / power(10, exponent);

    if fraction <= 1 then
      niceFraction := 1
    else if fraction <= 2 then
      niceFraction := 2
    else if fraction <= 3 then
      niceFraction := 3
    else if fraction <= 4 then
      niceFraction := 4
    else if fraction <= 5 then
      niceFraction := 5
    else if fraction <= 6 then
      niceFraction := 6
    else if fraction <= 7 then
      niceFraction := 7
    else if fraction <= 8 then
      niceFraction := 8
    else if fraction <= 9 then
      niceFraction := 9
    else
      niceFraction := 10;

    result := niceFraction * power(10, exponent);
    if range < 0 then
      result := -result;
  end
  else
    result := 0;
end;

function gGetStep(Range: double): double;
var
  RowDiv,ColDiv: Array[1..4] of double;       {row and column divisors}
  RealStep,                                   {basic step}
  LogStep,                                    {log of basic step}
  Step:          Array[1..4, 1..3] of double; {rounded step}
  Stepi,                                      {row index of best step}
  Stepj,                                      {column index of best step}
  i,j:           Word;                        {counters}
begin
  if Range <= 0 then
    Range := 10;
  ColDiv[1] := 1.0;
  ColDiv[2] := 2.0;
  ColDiv[3] := 5.0;

  RowDiv[1] := 6.0;
  RowDiv[2] := 7.0;
  RowDiv[3] := 8.0;
  RowDiv[4] := 9.0;

  for i := 1 to 4 do
    for j := 1 to 3 do
    begin
      RealStep[i, j] := Range / RowDiv[i] / ColDiv[j];
      LogStep[i, j] := Log10(RealStep[i, j]);
      Step[i, j] :=  Exp(ln(10) * Round(LogStep[i, j])) * ColDiv[j];
    end;
  Stepi := 1;
  Stepj := 1;
  for i := 1 to 4 do
    for j := 1 to 3 do
      if Abs(Round(LogStep[i, j]) - LogStep[i, j]) < Abs(Round(LogStep[Stepi, Stepj]) - LogStep[Stepi, Stepj]) then
      begin
        Stepi := i;
        Stepj := j;
      end;
  Result := Step[Stepi, Stepj];
end;

function gGetDecStr(Val: double; DecPlaces: Integer): String;
begin
  case DecPlaces of
    0: Result := FormatFloat('### ### ### ##0',Val);
    1: Result := FormatFloat('### ### ### ##0.0',Val);
    2: Result := FormatFloat('### ### ### ##0.00',Val);
    3: Result := FormatFloat('### ### ### ##0.000',Val);
    4: Result := FormatFloat('### ### ### ##0.0000',Val);
    5: Result := FormatFloat('### ### ### ##0.00000',Val);
    else
      Result := FormatFloat('### ### ### ##0.00E+00',Val);
  end;
end;

procedure gDrawXaxis(dCanvas: TCanvas; GraphType: pGraphTypes; x1, x2, y: double;
  FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
var
  xVal: double;
  xValStr1, xValStr2: String;
begin
  pXsf := (x2 - x1) / (gr.xMax - gr.xMin);
  pXoffset := gr.xMin * pXsf;
  xVal := gr.xMin;
  repeat
    xValStr2 := '';
    case gr.GraphType of
      pLineGraph:  xValStr1 := gGetDecStr(xVal, gr.xDecPlaces);
      pDateGraph:  xValStr1 := FormatDateTime('dd/mm/yy', xVal);
      pDayGraph:   begin
                    xValStr1 := FormatDateTime('ddd', xVal);
                    xValStr2 := FormatDateTime('dd/mm/yy', xVal);
                   end;
      pMonthGraph: xValStr1  := FormatSettings.ShortMonthNames[Round(xVal)];
      pDOYGraph:   xValStr1 := IntToStr(DayOfYear(xVal));
      pTimeGraph:  begin
                    xValStr1 := FormatDateTime('dd/mm/yy', xVal);
                    xValStr2 := FormatDateTime('hh:nn', xVal);
                   end;
      pOtherGraph: xValStr1 := gGetDecStr(xVal, gr.xDecPlaces);
    end;
    pLine(dCanvas, x1 + xVal * pXsf - pXoffset, y, x1 + xVal * pXsf - pXoffset, y + gr.lTick, pDefPenWidth, pDefPenStyle, pDefPenColor);
    pCText(dCanvas, x1 + xVal * pXsf - 10 - pXoffset, y + gr.lTick, x1 + xVal * pXsf + 10 - pXoffset, xValStr1,
      FontName, FontSize, FontColor, BrushColor, FontStyle);
    if xValStr2 <> '' then
      pCText(dCanvas, x1 + xVal * pXsf - 10 - pXoffset, y + 5 + gr.lTick, x1 + xVal * pXsf + 10 - pXoffset, xValStr2,
        FontName, FontSize, FontColor, BrushColor, FontStyle);
    xVal := xVal + gr.dx;
  until xVal > gr.xMax;

  xVal := gr.xMin;
  repeat
    pLine(dCanvas, x1 + xVal * pXsf - pXoffset, y, x1 + xVal * pXsf - pXoffset, y + gr.sTick, pDefPenWidth, pDefPenStyle, pDefPenColor);
    xVal := xVal + gr.dxi;
  until xVal > gr.xMax;
end;

procedure gDrawYLeftaxis(dCanvas: TCanvas; GraphType: pGraphTypes; x1, x2, y1, y2: double;
  FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
var
  yVal: double;
  yValStr: String;
begin
  pYsf := (y2 - y1) / (gr.yMax - gr.yMin);
  pYoffset := gr.yMin * pYsf;
  if gr.yMin < 0.0 then
    pLine(dCanvas, x1, y2 + pYoffset, x2, y2 + pYoffset, pDefPenWidth, pDefPenStyle, pDefPenColor);

  yVal := gr.yMin;
  repeat
    yValStr := gGetDecStr(yVal, gr.yDecPlaces);
    pLine(dCanvas, x1, y2 - yVal * pYsf + pYoffset, x1 - gr.lTick, y2 - yVal * pYsf + pYoffset, pDefPenWidth, pDefPenStyle, pDefPenColor);
    pRJText(dCanvas, x1 - gr.lTick - 1, y2 - yVal * pYsf - 2.5 + pYoffset, yValStr,
      pDefFontName, pLargeFontSize, pDefFontColor, BrushColor, pDefFontStyle);
    yVal := yVal + gr.dy;
  until yVal > gr.yMax;

  yVal := gr.yMin;
  repeat
    pLine(dCanvas, x1, y2 - yVal * pYsf + pYoffset, x1 - gr.sTick, y2 - yVal * pYsf + pYoffset, pDefPenWidth, pDefPenStyle, pDefPenColor);
    yVal := yVal + gr.dyi;
  until yVal > gr.yMax;
end;

procedure gMoveTo(dCanvas: TCanvas; x, y: double);
begin
  dCanvas.MoveTo(pXmm(x + pX * pXsf - pXoffset), pYmm(y - pY * pYsf + pYoffset));
end;

procedure gLineTo(dCanvas: TCanvas; x, y: double; PenWidth: Integer; PenStyle: TPenStyle; PenColor: TColor);
begin
  dCanvas.Pen.Width := PenWidth;
  dCanvas.Pen.Style := PenStyle;
  dCanvas.Pen.Color := PenColor;
  dCanvas.LineTo(pXmm(x + pX * pXsf - pXoffset), pYmm(y - pY * pYsf + pYoffset));
  dCanvas.Pen.Width := pDefPenWidth;
  dCanvas.Pen.Style := pDefPenStyle;
  dCanvas.Pen.Color := pDefPenColor;
end;

procedure gVertBar(dCanvas: TCanvas; x1, y2, dx: double; Justify: String;
  PenWidth: Integer; PenColor, BrushColor: TColor; BrushStyle: TBrushStyle);
begin
  dCanvas.Pen.Width := PenWidth;
  dCanvas.Pen.Color := PenColor;
  dCanvas.Brush.Color := BrushColor;
  dCanvas.Brush.Style := BrushStyle;
  if Justify = 'RJ' then
    dCanvas.Polygon([Point(pXmm(x1 + pX * pXsf      - pXoffset), pYmm(y2             + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf      - pXoffset), pYmm(y2 - pY * pYsf + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf + dx - pXoffset), pYmm(y2 - pY * pYsf + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf + dx - pXoffset), pYmm(y2             + pYoffset))])
  else if Justify = 'LJ' then
    dCanvas.Polygon([Point(pXmm(x1 + pX * pXsf - dx - pXoffset), pYmm(y2             + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf - dx - pXoffset), pYmm(y2 - pY * pYsf + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf      - pXoffset), pYmm(y2 - pY * pYsf + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf      - pXoffset), pYmm(y2             + pYoffset))])
  else
    dCanvas.Polygon([Point(pXmm(x1 + pX * pXsf - dx - pXoffset), pYmm(y2             + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf - dx - pXoffset), pYmm(y2 - pY * pYsf + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf + dx - pXoffset), pYmm(y2 - pY * pYsf + pYoffset)),
                     Point(pXmm(x1 + pX * pXsf + dx - pXoffset), pYmm(y2             + pYoffset))]);
  dCanvas.Pen.Width := pDefPenWidth;
  dCanvas.Pen.Color := pDefPenColor;
  dCanvas.Brush.Color := pDefBrushColor;
  dCanvas.Brush.Style := pDefBrushStyle;
end;

begin
  bDefFontSize := 10;
  pWidth_mm := 210;  // A4 page size = 210 x 297 mm
  pHeight_mm := 297;
  pDefFontColor := clBlack;
  pDefFontStyle := [];
  pDefPenWidth := 1;
  pDefPenColor := clBlack;
  pDefPenStyle := psSolid;
  pDefBrushColor := clWhite;
  pDefFontName := 'Tahoma';
  pOrientation := poPortrait;
  gr.lTick := 2.0;
  gr.sTick := 1.0;
  gr.xDecPlaces := 1;
  gr.yDecPlaces := 1;
end.

