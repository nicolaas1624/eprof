unit _t_tmploadf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, DBCtrls, DBGrids, IBQuery, IBCustomDataSet, IBStoredProc,
  IBSQL;

type

  { Tt_tmploadf }

  Tt_tmploadf = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    DeleteBtn: TToolButton;
    InsQ: TIBSQL;
    ImportBtn: TToolButton;
    Label1: TLabel;
    Panel1: TPanel;
    Panel3: TPanel;
    SortBox: TComboBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    UpdateBtn: TToolButton;
    t_tmploadQ: TIBQuery;
    t_loadQDTE1: TDateTimeField;
    t_loadQLOAD1: TFloatField;
    t_loadQPANELDESCR1: TIBStringField;
    t_loadQRECNO1: TIntegerField;
    t_loadQSUBIDDESCR1: TIBStringField;
    t_tmploadQDESCR: TIBStringField;
    t_tmploadQDTE: TDateTimeField;
    t_tmploadQLOAD: TFloatField;
    t_tmploadQRECNO: TIntegerField;
    procedure CountBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
    procedure SortBoxChange(Sender: TObject);
    procedure SplitBtnClick(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
  private
    StartTime, EndTime: TDateTime;
    procedure InitGrid;
    procedure Opent_tmploadQ(Order: string);
  public

  end;

var
  t_tmploadf: Tt_tmploadf;

implementation

uses _dm, _mainf, _misc;

{$R *.lfm}

{ Tt_tmploadf }

procedure Tt_tmploadf.FormCreate(Sender: TObject);
begin
  Width := Trunc(Screen.Width * 0.5);
  Height := Trunc(Screen.Height * 0.9);
  InitGrid;
end;

procedure Tt_tmploadf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    if dm.IBTransaction1.Active then
      dm.IBTransaction1.Commit;
    dm.IBTransaction1.Active := True;
    SortBox.Items.CommaText := '"Rec no", Description';
    SortBox.Text := 'Rec no';
    SortBoxChange(Sender);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_tmploadf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  t_tmploadQ.Close;
  dm.IBTransaction1.Commit;
end;

procedure Tt_tmploadf.InitGrid;
begin
  DBGrid1.Options := [dgTitles, dgIndicator, dgColumnResize, dgColumnMove,
    dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit,
    dgAutoSizeColumns, dgRowHighlight];
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'RECNO';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Rec no';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'DESCR';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Panel';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'DTE';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Date & Time';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := 'dd/mm/yyyy hh:mm:ss';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'LOAD';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Load';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '### ### ### ##0.000';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
end;

procedure Tt_tmploadf.Opent_tmploadQ(Order: string);
begin
  t_tmploadQ.Close;
  t_tmploadQ.SQL.Clear;
  t_tmploadQ.SQL.Add('SELECT FIRST 10000 * FROM T_TMPLOAD ORDER BY ' + Order);
  t_tmploadQ.Prepare;
  t_tmploadQ.Open;
end;

procedure Tt_tmploadf.ImportBtnClick(Sender: TObject);
var
  FVar: TextFile;
  S, S1, S2: string;
  RECNOVal: integer;
  DESCRVal: string;
  DTEVal: TDateTime;
  LOADVal: double;
  Year, Month, Day: word;
  Hours, Minutes, Secs: integer;
  TmpDate: TDate;
  TmpTime: TTime;
  P1: integer;

  procedure InsertT_TMPLOAD;
  begin
    InsQ.ParamByName('RECNO').AsInteger := RECNOVal;
    InsQ.ParamByName('DESCR').AsString := DESCRVal;
    InsQ.ParamByName('DTE').AsDateTime := DTEVal;
    InsQ.ParamByName('LOAD').AsFloat := LOADVal;
    InsQ.Prepare;
    InsQ.ExecQuery;
    InsQ.Close;
  end;

  procedure ImportTmpLoads;
  begin
    RECNOVal := 0;
    Reset(FVar);
    ReadLn(FVar, S);
    while not EOF(FVar) do
    begin
      Inc(RECNOVal);
      ReadLn(FVar, S);
      S := ',' + S + ',';
      DESCRVal := GetSubStr1(S, ',', 1, ',', 2);
      if DESCRVal <> 'Description' then
      begin
        S1 := GetSubStr1(S, ',', 2, ',', 3);
        S1 := ',' + S1 + ',';

        S2 := GetSubStr1(S1, ',', 1, ' ', 1);
        try
          DecodeDateStr('yyyy-mm-dd', S2, 0, 0, Year, Month, Day);
        except
        end;
        try
          TmpDate := EncodeDate(Year, Month, Day);
        except
          TmpDate := 0;
        end;

        S2 := GetSubStr1(S1, ' ', 1, ',', 2);  // time
        try
          P1 := Pos(':', S2);
          Hours := StrToInt(Copy(S2, 1, P1 - 1));
          Minutes := StrToInt(Copy(S2, P1 + 1, 2));
          Secs := 0;
        except
        end;
        try
          TmpTime := EncodeTime(Hours, Minutes, Secs, 0);
        except
          TmpTime := 0;
        end;
        DTEVal := TmpDate;
        ReplaceTime(DTEVal, TmpTime);

        LOADVal := StrToFloat(GetSubStr1(S, ',', 3, ',', 4));
        try
          InsertT_TMPLOAD;
        except
        end;
      end;
    end;
  end;

begin
  mainf.OpenDialog1.Filter :=
    'Comma delimited files (*.csv)|*.csv|Text files (*.txt)|*.txt|All files (*.*)|*.*';
  if mainf.OpenDialog1.Execute then
  begin
    StartTime := Time;
    try
      DeleteBtnClick(Sender); // TODO : Should check back with this later
      Screen.Cursor := crHourglass;
      AssignFile(FVar, mainf.OpenDialog1.FileName);
      ImportTmpLoads;
    finally
      CloseFile(FVar);
      Screen.Cursor := crDefault;
    end;
    dm.IBTransaction1.CommitRetaining;
    SortBoxChange(Sender);
    EndTime := Time;
    MessageDlg('Finished in ' + TimeToStr(EndTime - StartTime),
      mtInformation, [mbOK], 0);
  end;
end;

procedure Tt_tmploadf.SortBoxChange(Sender: TObject);
var
  S: string;
begin
  try
    Screen.Cursor := crHourglass;
    if SortBox.Text = 'Rec no' then
      S := 'RECNO'
    else
      S := 'DESCR';
    Opent_tmploadQ(S);
    DBGrid1.Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_tmploadf.UpdateBtnClick(Sender: TObject);
var
  Q: TIBStoredProc;
begin
  if MessageDlg('Update Panel and Load data records?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    StartTime := Time;
    try
      Screen.Cursor := crHourglass;
      Q := TIBStoredProc.Create(nil);
      try
        Q.DataBase := dm.IBDatabase1;
        Q.Transaction := dm.IBTransaction1;
        Q.StoredProcName := 'ADD_PANELS_FROM_TMPLOAD';
        Q.Prepare;
        Q.ExecProc;
        Q.Close;
        Q.StoredProcName := 'ADD_LOADDATA_FROM_TMPLOAD';
        Q.Prepare;
        Q.ExecProc;
        Q.Close;
      finally
        Q.Free;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
    EndTime := Time;
    MessageDlg('Finished in ' + TimeToStr(EndTime - StartTime),
      mtInformation, [mbOK], 0);
  end;
end;

procedure Tt_tmploadf.DeleteBtnClick(Sender: TObject);
begin
  if MessageDlg('Delete all records?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dm.RunSQL('DELETE FROM T_TMPLOAD');
    SortBoxChange(Sender);
  end;
end;

procedure Tt_tmploadf.CountBtnClick(Sender: TObject);
var
  FVar: TextFile;
  S: string;
  i, j: integer;
begin
  i := 0;
  j := 0;
  mainf.OpenDialog1.Filter :=
    'Comma delimited files (*.csv)|*.csv|Text files (*.txt)|*.txt|All files (*.*)|*.*';
  if mainf.OpenDialog1.Execute then
    try
      AssignFile(FVar, mainf.OpenDialog1.FileName);
      Reset(FVar);
      ReadLn(FVar, S);
      while not EOF(FVar) do
      begin
        Inc(i);
        Inc(j);
        ReadLn(FVar, S);
        if j >= 100000 then
        begin
          Caption := IntToStr(i);
          j := 0;
        end;
      end;
      MessageDlg('Record count: ' + IntToStr(i), mtInformation, [mbOK], 0);
    finally
      CloseFile(FVar);
    end;
end;

procedure Tt_tmploadf.SplitBtnClick(Sender: TObject);
var
  FVar1, FVar2: TextFile;
  S: string;
  i: integer;
begin
  mainf.OpenDialog1.Filter :=
    'Comma delimited files (*.csv)|*.csv|Text files (*.txt)|*.txt|All files (*.*)|*.*';
  if mainf.OpenDialog1.Execute then
  begin
    i := 0;
    StartTime := Time;
    try
      Screen.Cursor := crHourglass;
      AssignFile(FVar1, mainf.OpenDialog1.FileName);
      AssignFile(FVar2, 'c:\skemas\nugen\outputfile.csv');
      Reset(FVar1);
      Rewrite(FVar2);
      while not EOF(FVar1) and (i <= 100000) do
      begin
        Inc(i);
        ReadLn(FVAr1, S);
        WriteLn(FVar2, S);
      end;
    finally
      CloseFile(FVar1);
      CloseFile(FVar2);
      Screen.Cursor := crDefault;
    end;
    EndTime := Time;
    MessageDlg('Finished 100 000 records in ' + TimeToStr(EndTime - StartTime),
      mtInformation, [mbOK], 0);
  end;
end;

end.
