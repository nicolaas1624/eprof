unit _t_loadf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, DBCtrls, DBGrids, IBQuery, IBCustomDataSet, IBStoredProc;

type

  { Tt_loadf }

  Tt_loadf = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    DeleteBtn: TToolButton;
    GRPBox: TComboBox;
    t_loadQ: TIBQuery;
    ImportBtn: TToolButton;
    Label2: TLabel;
    Panel1: TPanel;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    t_loadQDTE: TDateTimeField;
    t_loadQLOAD: TFloatField;
    t_loadQRECNO: TIntegerField;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GRPBoxChange(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
  private
    procedure InitGrid;
    procedure Opent_loadQ;
  public

  end;

var
  t_loadf: Tt_loadf;

implementation

uses _mainf, _dm, _misc;

{$R *.lfm}

procedure Tt_loadf.FormCreate(Sender: TObject);
begin
  Width := Trunc(Screen.Width * 0.5);
  Height := Trunc(Screen.Height * 0.9);
  InitGrid;
end;

procedure Tt_loadf.FormShow(Sender: TObject);
begin
  if dm.IBTransaction1.Active then
    dm.IBTransaction1.Commit;
  dm.IBTransaction1.Active := True;
  dm.OpenQ('SELECT RECNO FROM T_PANELS ORDER BY RECNO');
  while not dm.XQ.EOF do
  begin
    GRPBox.Items.Add(dm.XQ.FieldByName('RECNO').AsString);
    dm.XQ.Next;
  end;
  dm.XQ.Close;

  Opent_loadQ;
end;

procedure Tt_loadf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  t_loadQ.Close;
  dm.IBTransaction1.CommitRetaining;
end;

procedure Tt_loadf.InitGrid;
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

procedure Tt_loadf.Opent_loadQ;
begin
  t_loadQ.Close;
  t_loadQ.SQL.Clear;
  t_loadQ.SQL.Add('SELECT * FROM T_LOAD WHERE RECNO = :RECNO ORDER BY RECNO, DTE');
  t_loadQ.ParamByName('RECNO').AsInteger := StrToInt(GRPBox.Text);
  t_loadQ.Prepare;
  t_loadQ.Open;
end;

procedure Tt_loadf.GRPBoxChange(Sender: TObject);
begin
  Opent_loadQ;
end;

procedure Tt_loadf.ImportBtnClick(Sender: TObject);
var
  FVar: TextFile;
  S, S1, S2: string;
  PREVVal, DESCRVal: string;
  DTEVal: TDateTime;
  LOADVal: double;
  Year, Month, Day: word;
  Hours, Minutes, Secs: integer;
  TmpDate: TDate;
  TmpTime: TTime;
  P1: integer;
  RECNOVal: integer;

  procedure InsertPanel;
  var
    Q: TIBStoredProc;
  begin
    Q := TIBStoredProc.Create(nil);
    try
      Q.DataBase := dm.IBDatabase1;
      Q.Transaction := dm.IBTransaction1;
      Q.StoredProcName := 'T_PANELS_IU';
      Q.ParamByName('DESCR').AsString := DESCRVal;
      Q.ParamByName('SUBID').Value := Null;
      Q.Prepare;
      Q.ExecProc;
      Q.Close;
    finally
      Q.Free;
    end;
  end;

  procedure InsertT_LOAD;
  var
    Q: TIBStoredProc;
  begin
    Q := TIBStoredProc.Create(nil);
    try
      Q.DataBase := dm.IBDatabase1;
      Q.Transaction := dm.IBTransaction1;
      Q.StoredProcName := 'T_LOAD_INS';
      Q.ParamByName('RECNO').AsInteger := RECNOVal;
      Q.ParamByName('DTE').AsDateTime := DTEVal;
      Q.ParamByName('LOAD').AsFloat := LOADVal;
      Q.Prepare;
      Q.ExecProc;
      Q.Close;
    finally
      Q.Free;
    end;
  end;

  function GetRecnoFromDescr(DESCRVal: string): integer;
  var
    Q: TIBQuery;
  begin
    Q := TIBQuery.Create(nil);
    try
      Q.DataBase := dm.IBDatabase1;
      Q.Transaction := dm.IBTransaction1;
      Q.SQL.Add('SELECT RECNO FROM T_PANELS WHERE DESCR = :DESCR');
      Q.ParamByName('DESCR').AsString := DESCRVal;
      Q.Prepare;
      Q.Open;
      Result := Q.FieldByName('RECNO').AsInteger;
      Q.Close;
    finally
      Q.Free;
    end;
  end;

  procedure ImportPanels;
  begin
    Reset(FVar);
    ReadLn(FVar, S);
    PREVVal := '';
    while not EOF(FVar) do
    begin
      ReadLn(FVar, S);
      S := ',' + S + ',';
      DESCRVal := GetSubStr1(S, ',', 1, ',', 2);
      if DESCRVal <> 'Description' then
      begin
        if DESCRVal <> PREVVal then
          try
            InsertPanel;
            PREVVal := DESCRVal;
          except
          end;
      end;
    end;
  end;

  procedure ImportLoads;
  begin
    Reset(FVar);
    ReadLn(FVar, S);
    while not EOF(FVar) do
    begin
      ReadLn(FVar, S);
      S := ',' + S + ',';
      DESCRVal := GetSubStr1(S, ',', 1, ',', 2);
      if DESCRVal <> 'Description' then
      begin
        RECNOVal := GetRecnoFromDescr(DESCRVal);
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
          InsertT_LOAD;
        except
        end;
      end;
    end;
  end;

begin
  mainf.OpenDialog1.Filter :=
    'Comma delimited files (*.csv)|*.csv|Text files (*.txt)|*.txt|All files (*.*)|*.*';
  if mainf.OpenDialog1.Execute then
    try
      Screen.Cursor := crHourglass;
      AssignFile(FVar, mainf.OpenDialog1.FileName);
      ImportPanels;
      ImportLoads;
      MessageDlg('Finished!', mtInformation, [mbOK], 0);
    finally
      CloseFile(FVar);
      Screen.Cursor := crDefault;
    end;
  dm.IBTransaction1.CommitRetaining;
  Opent_loadQ;
end;

end.
