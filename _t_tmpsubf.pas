unit _t_tmpsubf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dateutils, strutils, FileUtil, DateTimePicker, Forms,
  Controls, Graphics, Dialogs, Grids, ExtCtrls, StdCtrls, Buttons, ComCtrls,
  DBGrids, DbCtrls, IBQuery, IBCustomDataSet, IBStoredProc;

type

  { Tt_tmpsubf }

  Tt_tmpsubf = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    fromdatetimebox: TDateTimePicker;
    frompinbtn: TSpeedButton;
    exportbtn: TToolButton;
    Label7: TLabel;
    Label8: TLabel;
    Memo1: TMemo;
    Panel4: TPanel;
    ShowAllBtn: TToolButton;
    StaticText1: TStaticText;
    todatetimebox: TDateTimePicker;
    ToolBar1: TToolBar;
    fillbtn: TToolButton;
    topinbtn: TSpeedButton;
    t_tmpsubQ: TIBQuery;
    t_tmpsubQDTE: TDateTimeField;
    t_tmpsubQPNL1: TFloatField;
    t_tmpsubQPNL10: TFloatField;
    t_tmpsubQPNL11: TFloatField;
    t_tmpsubQPNL12: TFloatField;
    t_tmpsubQPNL13: TFloatField;
    t_tmpsubQPNL14: TFloatField;
    t_tmpsubQPNL15: TFloatField;
    t_tmpsubQPNL16: TFloatField;
    t_tmpsubQPNL17: TFloatField;
    t_tmpsubQPNL18: TFloatField;
    t_tmpsubQPNL19: TFloatField;
    t_tmpsubQPNL2: TFloatField;
    t_tmpsubQPNL20: TFloatField;
    t_tmpsubQPNL21: TFloatField;
    t_tmpsubQPNL22: TFloatField;
    t_tmpsubQPNL23: TFloatField;
    t_tmpsubQPNL24: TFloatField;
    t_tmpsubQPNL25: TFloatField;
    t_tmpsubQPNL26: TFloatField;
    t_tmpsubQPNL27: TFloatField;
    t_tmpsubQPNL28: TFloatField;
    t_tmpsubQPNL29: TFloatField;
    t_tmpsubQPNL3: TFloatField;
    t_tmpsubQPNL30: TFloatField;
    t_tmpsubQPNL31: TFloatField;
    t_tmpsubQPNL32: TFloatField;
    t_tmpsubQPNL33: TFloatField;
    t_tmpsubQPNL34: TFloatField;
    t_tmpsubQPNL35: TFloatField;
    t_tmpsubQPNL36: TFloatField;
    t_tmpsubQPNL37: TFloatField;
    t_tmpsubQPNL38: TFloatField;
    t_tmpsubQPNL39: TFloatField;
    t_tmpsubQPNL4: TFloatField;
    t_tmpsubQPNL40: TFloatField;
    t_tmpsubQPNL41: TFloatField;
    t_tmpsubQPNL42: TFloatField;
    t_tmpsubQPNL43: TFloatField;
    t_tmpsubQPNL44: TFloatField;
    t_tmpsubQPNL45: TFloatField;
    t_tmpsubQPNL46: TFloatField;
    t_tmpsubQPNL47: TFloatField;
    t_tmpsubQPNL48: TFloatField;
    t_tmpsubQPNL49: TFloatField;
    t_tmpsubQPNL5: TFloatField;
    t_tmpsubQPNL50: TFloatField;
    t_tmpsubQPNL51: TFloatField;
    t_tmpsubQPNL52: TFloatField;
    t_tmpsubQPNL53: TFloatField;
    t_tmpsubQPNL54: TFloatField;
    t_tmpsubQPNL55: TFloatField;
    t_tmpsubQPNL56: TFloatField;
    t_tmpsubQPNL57: TFloatField;
    t_tmpsubQPNL58: TFloatField;
    t_tmpsubQPNL59: TFloatField;
    t_tmpsubQPNL6: TFloatField;
    t_tmpsubQPNL60: TFloatField;
    t_tmpsubQPNL61: TFloatField;
    t_tmpsubQPNL62: TFloatField;
    t_tmpsubQPNL63: TFloatField;
    t_tmpsubQPNL64: TFloatField;
    t_tmpsubQPNL65: TFloatField;
    t_tmpsubQPNL66: TFloatField;
    t_tmpsubQPNL67: TFloatField;
    t_tmpsubQPNL68: TFloatField;
    t_tmpsubQPNL69: TFloatField;
    t_tmpsubQPNL7: TFloatField;
    t_tmpsubQPNL70: TFloatField;
    t_tmpsubQPNL71: TFloatField;
    t_tmpsubQPNL72: TFloatField;
    t_tmpsubQPNL73: TFloatField;
    t_tmpsubQPNL74: TFloatField;
    t_tmpsubQPNL75: TFloatField;
    t_tmpsubQPNL76: TFloatField;
    t_tmpsubQPNL77: TFloatField;
    t_tmpsubQPNL78: TFloatField;
    t_tmpsubQPNL79: TFloatField;
    t_tmpsubQPNL8: TFloatField;
    t_tmpsubQPNL80: TFloatField;
    t_tmpsubQPNL9: TFloatField;
    t_tmpsubQSUBID: TIntegerField;
    procedure deletebtnClick(Sender: TObject);
    procedure exportbtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure fillbtnClick(Sender: TObject);
    procedure fromdatetimeboxChange(Sender: TObject);
    procedure frompinbtnClick(Sender: TObject);
    procedure ShowAllBtnClick(Sender: TObject);
    procedure topinbtnClick(Sender: TObject);
  private
    StartTime, EndTime: TDateTime;
    procedure InitGrid;
    procedure Opent_tmpsubQ;
    function GetFirstDate: TDate;
    function GetLastDate: TDate;
  public
    SUBIDVal: Integer;
  end;

var
  t_tmpsubf: Tt_tmpsubf;

implementation

uses _t_panelsf, _dm;

{$R *.lfm}

{ Tt_tmpsubf }

procedure Tt_tmpsubf.FormCreate(Sender: TObject);
begin
  Width := Trunc(Screen.Width * 0.95);
  Height := Trunc(Screen.Height * 0.9);
  StaticText1.Caption := UpperCase(t_panelsf.SubsBox.Text);
end;

procedure Tt_tmpsubf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    fromdatetimebox.DateTime := t_panelsf.fromdatetimebox.DateTime;
    todatetimebox.DateTime := t_panelsf.todatetimebox.DateTime;
    Opent_tmpsubQ;
    InitGrid;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_tmpsubf.fillbtnClick(Sender: TObject);
begin
  if MessageDlg('Clear current substation information and repopulate table?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    deletebtnClick(Sender);
    dm.XSPQ.StoredProcName:= 'INIT_TMPSUB';
    dm.XSPQ.ParamByName('START_DATE').AsDateTime := fromdatetimebox.DateTime;
    dm.XSPQ.ParamByName('END_DATE').AsDateTime := todatetimebox.DateTime;
    dm.XSPQ.Prepare;
    dm.XSPQ.ExecProc;
    dm.XSPQ.Close;
    dm.IBTransaction1.CommitRetaining;
    dm.XSPQ.StoredProcName:= 'ADD_SUBLOADDATA_FROM_LOAD';
    dm.XSPQ.ParamByName('VSUBID').AsInteger := SUBIDVal;
    dm.XSPQ.Prepare;
    dm.XSPQ.ExecProc;
    dm.XSPQ.Close;
    dm.IBTransaction1.CommitRetaining;
    Opent_tmpsubQ;
  end;
end;

procedure Tt_tmpsubf.fromdatetimeboxChange(Sender: TObject);
begin
  Opent_tmpsubQ;
end;

procedure Tt_tmpsubf.deletebtnClick(Sender: TObject);
begin
  dm.RunSQL('DELETE FROM T_TMPSUB');
  Opent_tmpsubQ;
end;

procedure Tt_tmpsubf.exportbtnClick(Sender: TObject);
var
  FVar: TextFile;
  S,S1: string;
  i: integer;
begin
  if MessageDlg('Export current table from ' + DateTimeToStr(fromdatetimebox.datetime) + ' to ' + DateTimeToStr(todatetimebox.datetime) + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Try
      Screen.Cursor := crHourglass;
      StartTime := Time;
      AssignFile(FVar,'c:\EPROF Outputs\'+StaticText1.caption + '.csv');
      Rewrite(FVar);
      S := 'Date,Time';
      t_panelsf.t_panelsQ.First;
      While not t_panelsf.t_panelsQ.EOF do
      begin
        S := S + ',' +t_panelsf.t_panelsQDESCR.AsString;
        t_panelsf.t_panelsQ.Next;
      end;
      WriteLn(FVar,S);
      t_tmpsubQ.First;
      While not t_tmpsubQ.EOF do
      begin
        S1 := t_tmpsubQDTE.AsString;
        S := LeftStr(S1,10);
        S := S + ',' + RightStr(S1,8);
        i := 3;
        t_panelsf.t_panelsQ.First;
        While not t_panelsf.t_panelsQ.EOF do
        begin
          S := S + ',' + FormatFloat('0.0', t_tmpsubQ.Fields[i].AsFloat);
          inc(i);
          t_panelsf.t_panelsQ.Next;
        end;
        WriteLn(FVar,S);
        t_tmpsubQ.Next;
      end;
      EndTime := Time;
    finally
      Screen.Cursor := crDefault;
      CloseFile(FVar);
    end;
    MessageDlg('Export completed in ' + TimeToStr(EndTime - StartTime),mtInformation, [mbOK], 0);
  end;
end;

procedure Tt_tmpsubf.InitGrid;
var
  Q: TIBQuery;
  iPnl: Integer;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT * FROM T_PANELS WHERE SUBID = :SUBID');
    Q.ParamByName('SUBID').AsInteger := SUBIDVal;
    Q.Prepare;
    Q.Open;
    DBGrid1.Options := [dgTitles,dgIndicator,dgColumnResize,dgColumnMove,dgColLines,dgRowLines,dgTabs,dgAlwaysShowSelection,dgCancelOnExit,dgRowHighlight];
    DBGrid1.Columns.Add;
    DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'DTE';
    DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Date';
    DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := 'dd/mm/yyyy hh:mm:ss';
    DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
    DBGrid1.Columns[DBGrid1.Columns.Count - 1].Width := 130;
    iPnl:= 1;
    Memo1.Clear;
    while not Q.EOF do
    begin
      DBGrid1.Columns.Add;
      DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := t_tmpsubQ.Fields[iPnl+1].FieldName;
      DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Panel ' + IntToStr(iPnl);
      DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '### ### ### ##0.000';
      DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
      DBGrid1.Columns[DBGrid1.Columns.Count - 1].Width := 70;
      Memo1.Lines.Add('Panel ' + IntToStr(iPnl) + ' - ' + Q.Fields[1].Value);
      inc(iPnl);
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure Tt_tmpsubf.Opent_tmpsubQ;
begin
  t_tmpsubQ.Close;
  t_tmpsubQ.SQL.Clear;
  t_tmpsubQ.SQL.Add('SELECT * FROM T_TMPSUB WHERE SUBID >= :SUBID');
  t_tmpsubQ.SQL.Add('AND DTE >= :FROMDTE AND DTE <= :TODTE');
  t_tmpsubq.SQL.Add('ORDER BY DTE');
  t_tmpsubQ.ParamByName('SUBID').AsInteger := SUBIDVal;
  t_tmpsubQ.ParamByName('FROMDTE').AsDateTime := fromdatetimebox.DateTime;
  t_tmpsubQ.ParamByName('TODTE').AsDateTime := todatetimebox.DateTime;
  t_tmpsubQ.prepare;
  t_tmpsubQ.open;
end;

procedure Tt_tmpsubf.frompinbtnClick(Sender: TObject);
begin
  fromdatetimebox.DateTime:= t_tmpsubQDTE.AsDateTime;
  Opent_tmpsubQ;
end;

procedure Tt_tmpsubf.ShowAllBtnClick(Sender: TObject);
begin
  fromdatetimebox.DateTime:= GetFirstDate;
  todatetimebox.DateTime:= GetLastDate;
  Opent_tmpsubQ;
end;

procedure Tt_tmpsubf.topinbtnClick(Sender: TObject);
begin
  todatetimebox.DateTime:= t_tmpsubQDTE.AsDateTime;
  Opent_tmpsubQ;
end;
   
function Tt_tmpsubf.GetFirstDate: TDate;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT MIN(DTE) AS MINDATE FROM T_TMPSUB');
    Q.Prepare;
    Q.Open;
    if Q.FieldByName('MINDATE').IsNull then
      Result := Date - 31
    else
      Result := Q.FieldByName('MINDATE').AsDateTime;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function Tt_tmpsubf.GetLastDate: TDate;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT MAX(DTE) AS MAXDATE FROM T_TMPSUB');
    Q.Prepare;
    Q.Open;
    if Q.FieldByName('MAXDATE').IsNull then
      Result := Date - 31
    else
      Result := Q.FieldByName('MAXDATE').AsDateTime;
    Q.Close;
  finally
    Q.Free;
  end;
end;

end.

