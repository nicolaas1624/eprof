unit _t_panelsf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, DB, Forms, Controls, Graphics, ComCtrls, ExtCtrls, StdCtrls,
  DBGrids, DBCtrls, _global, IBQuery, IBCustomDataSet, IBSQL,
  Buttons, Dialogs, EditBtn,
  DateTimePicker, Classes, windows;

type

  { Tt_panelsf }

  Tt_panelsf = class(TForm)
    editchkbox: TCheckBox;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBNavigator1: TDBNavigator;
    EditBtn: TToolButton;
    fromdatetimebox: TDateTimePicker;
    frompinbtn1: TSpeedButton;
    Label3: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Panel4: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    PageControl1: TPageControl;
    BatchUpdBtn: TToolButton;
    ClearSubBtn: TToolButton;
    DeleteBtn: TToolButton;
    Panel3: TPanel;
    SearchBox: TLabeledEdit;
    SortBox: TComboBox;
    searchclrbtn: TSpeedButton;
    frompinbtn: TSpeedButton;
    StaticText1: TStaticText;
    SubsBox: TComboBox;
    ToolButton2: TToolButton;
    subbtn: TToolButton;
    typebox: TComboBox;
    subslubtn: TSpeedButton;
    PanelsTab: TTabSheet;
    LoadsTab: TTabSheet;
    countbtn: TToolButton;
    todatetimebox: TDateTimePicker;
    topinbtn: TSpeedButton;
    t_loadQ: TIBQuery;
    t_loadQDTE: TDateTimeField;
    t_loadQLOAD: TFloatField;
    t_loadQRECNO: TIntegerField;
    t_panelsQ: TIBQuery;
    ShowAllBtn: TToolButton;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    t_panelsQDESCR: TIBStringField;
    t_panelsQPANELID: TIntegerField;
    t_panelsQPANELTPE: TIBStringField;
    t_panelsQRECNO: TIntegerField;
    t_panelsQSUBID: TIntegerField;
    t_panelsQSUBIDDESCR: TIBStringField;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure editchkboxChange(Sender: TObject);
    procedure subbtnClick(Sender: TObject);
    procedure BatchUpdBtnClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure frompinbtnClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ShowAllBtnClick(Sender: TObject);
    procedure SortBoxChange(Sender: TObject);
    procedure searchclrbtnClick(Sender: TObject);
    procedure subslubtnClick(Sender: TObject);
    procedure ClearSubBtnClick(Sender: TObject);
    procedure countbtnClick(Sender: TObject);
    procedure topinbtnClick(Sender: TObject);
  private
    RECNOVal: integer;
    DESCRVal: string;
    SUBIDVal: integer;
    PANELTPEVal : String;
    PANELIDVal : Integer;
    OLDDESCRVal: string;
    procedure InitGrid1;
    procedure InitGrid2;
    procedure InitSubsBox;
    procedure Opent_panelsQ(Order: string);
    procedure Opent_loadQ;
    procedure InsUpdDelT_PANELS(CaptureState: TCaptureState);
    procedure ShowCapT_PANELS(CaptureState: TCaptureState; Sender: TObject);
    function GetFirstDate: TDate;
    function GetLastDate: TDate;
  public
    function GetRecordCount: Integer;
  end;

var
  t_panelsf: Tt_panelsf;

implementation

uses _dm, _capt_panelsf, _t_subsf, _t_tmpsubf;

{$R *.lfm}

{ Tt_panelsf }

procedure Tt_panelsf.FormCreate(Sender: TObject);
begin
  Height := Trunc(Screen.Height * 0.9);
  InitGrid1;
  InitGrid2;
end;

procedure Tt_panelsf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    if dm.IBTransaction1.Active then
      dm.IBTransaction1.Commit;
    dm.IBTransaction1.Active := true;
    SortBox.Items.CommaText := 'Substation, Description';
    SortBox.Text := 'Description';
    typebox.Items.CommaText := '*ALL*,P,Q,S,F';
    typebox.Text := '*ALL*';
    subbtn.Enabled:= false;

    InitSubsBox;
    SubsBox.Text := '*ALL*';
    SortBoxChange(Sender);
    fromdatetimebox.DateTime:= GetFirstDate;
    todatetimebox.DateTime:= GetLastDate;
    editchkboxChange(Sender);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_panelsf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  t_loadQ.Close;
  t_panelsQ.Close;
  dm.IBTransaction1.Commit;
end;
    
procedure Tt_panelsf.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  S: String;
  i: integer;
begin
  RECNOVal := t_panelsQRECNO.AsInteger;
  S := '';
  if (Key = VK_P) then { P }
  begin
    S := 'UPDATE T_PANELS SET PANELTPE = ''P'' WHERE RECNO =' + IntToStr(t_panelsQRECNO.AsInteger);
  end;
  if (Key = VK_Q) then { Q }
  begin
    S := 'UPDATE T_PANELS SET PANELTPE = ''Q'' WHERE RECNO =' + IntToStr(t_panelsQRECNO.AsInteger);
  end;
  if (Key = VK_S) then { S }
  begin
    S := 'UPDATE T_PANELS SET PANELTPE = ''S'' WHERE RECNO =' + IntToStr(t_panelsQRECNO.AsInteger);
  end;
  if (Key = VK_F) then { F }
  begin
    S := 'UPDATE T_PANELS SET PANELTPE = ''F'' WHERE RECNO =' + IntToStr(t_panelsQRECNO.AsInteger);
  end;
  if (Key = VK_D) then { D }
  begin
    i := t_panelsQRECNO.AsInteger;
    S := 'UPDATE T_PANELS SET PANELID = '+ IntToStr(i) +' WHERE RECNO = ' + IntToStr(t_panelsQRECNO.AsInteger);
    dm.RunSQL(S);
    t_panelsQ.Next;
    S := 'UPDATE T_PANELS SET PANELID = '+ IntToStr(i) +' WHERE RECNO = ' + IntToStr(t_panelsQRECNO.AsInteger);
  end;
  if S <> '' then
  begin
    dm.RunSQL(S);
    SortBoxChange(Sender);
  end;
end;

procedure Tt_panelsf.editchkboxChange(Sender: TObject);
begin
  if editchkbox.Checked = True then
  begin
    Panel3.Color := $008080FF;
    DBGrid1.OnKeyDown:= @FormKeyDown;
    DBGrid1.SetFocus;
  end;
  if editchkbox.Checked = False then
  begin
    Panel3.Color := clGradientInactiveCaption;
    DBGrid1.OnKeyDown := nil;
  end;
end;

procedure Tt_panelsf.subbtnClick(Sender: TObject);
begin
  t_tmpsubf := Tt_tmpsubf.Create(Application);
  try
    t_tmpsubf.SUBIDVal:= t_panelsQSUBID.AsInteger;
    t_tmpsubf.ShowModal;
  finally
    FreeAndNil(t_tmpsubf);
  end;
end;

procedure Tt_panelsf.InitSubsBox;
begin
  SubsBox.Items.Clear;
  SubsBox.Items.Add('*ALL*');
  dm.OpenQ('SELECT DESCR FROM T_SUBS ORDER BY DESCR');
  while not dm.XQ.EOF do
  begin
    SubsBox.Items.Add(dm.XQ.FieldByName('DESCR').AsString);
    dm.XQ.Next;
  end;
  dm.XQ.Close;
end;

procedure Tt_panelsf.InitGrid1;
begin
  DBGrid1.Options := [dgTitles, dgIndicator, dgColumnResize, dgColumnMove,
    dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit,
    dgAutoSizeColumns, dgRowHighlight];
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'RECNO';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Rec no';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clGradientInactiveCaption;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'DESCR';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Description';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'PANELID';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Panel id';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'PANELTPE';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Type';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clGradientInactiveCaption;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'SUBIDDESCR';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Substation';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
end;

procedure Tt_panelsf.InitGrid2;
begin
  DBGrid2.Options := [dgTitles, dgIndicator, dgColumnResize, dgColumnMove,
    dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit,
    dgAutoSizeColumns, dgRowHighlight];
  DBGrid2.Columns.Add;
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].FieldName := 'RECNO';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].Title.Caption := 'Rec no';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].DisplayFormat := '';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].Color := clGradientInactiveCaption;
  DBGrid2.Columns.Add;
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].FieldName := 'DTE';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].Title.Caption := 'Date & Time';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].DisplayFormat := 'dd/mm/yyyy hh:mm:ss';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].Color := clWindow;
  DBGrid2.Columns.Add;
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].FieldName := 'LOAD';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].Title.Caption := 'Load';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].DisplayFormat := '### ### ### ##0.000';
  DBGrid2.Columns[DBGrid2.Columns.Count - 1].Color := clWindow;
end;

procedure Tt_panelsf.Opent_panelsQ(Order: string);
begin
  t_panelsQ.Close;
  t_panelsQ.SQL.Clear;
  t_panelsQ.SQL.Add('SELECT * FROM V_PANELS WHERE RECNO >= 0');
  if SubsBox.Text <> '*ALL*' then
  begin
    t_panelsQ.SQL.Add('AND SUBIDDESCR = :SUBIDDESCR');
    subbtn.Enabled:= true;
  end
  else
    subbtn.Enabled:= false;
  if SearchBox.Text <> '' then
    t_panelsQ.SQL.Add('AND (DESCR CONTAINING :SEARCHSTR)');
  If typebox.Text <> '*ALL*' then
    t_panelsQ.SQL.Add('AND PANELTPE = :PANELTPE');
  t_panelsQ.SQL.Add('ORDER BY ' + Order);


  if SubsBox.Text <> '*ALL*' then
    t_panelsQ.ParamByName('SUBIDDESCR').AsString := SubsBox.Text;
  if SearchBox.Text <> '' then
    t_panelsQ.ParamByName('SEARCHSTR').AsString := SearchBox.Text;
  if typebox.Text <> '*ALL*' then
    t_panelsQ.ParamByName('PANELTPE').AsString := typebox.Text;

  t_panelsQ.Prepare;
  t_panelsQ.Open;
end;

procedure Tt_panelsf.Opent_loadQ;
begin
  t_loadQ.Close;
  t_loadQ.SQL.Clear;
  t_loadQ.SQL.Add('SELECT * FROM T_LOAD WHERE RECNO = :RECNO');
  t_loadQ.SQL.Add('AND DTE >= :FROMDTE AND DTE <= :TODTE');
  t_loadQ.SQL.Add('ORDER BY DTE');
  t_loadQ.ParamByName('RECNO').AsInteger := t_panelsQRECNO.AsInteger;
  t_loadQ.ParamByName('FROMDTE').AsDateTime := fromdatetimebox.DateTime;
  t_loadQ.ParamByName('TODTE').AsDateTime := todatetimebox.DateTime;
  t_loadQ.Prepare;
  t_loadQ.Open;
end;

procedure Tt_panelsf.SortBoxChange(Sender: TObject);
var
  S: string;
begin
  try
    Screen.Cursor := crHourglass;
    if PageControl1.ActivePage = PanelsTab then
    begin
      DBNavigator1.DataSource := DataSource1;
      if SortBox.Text = 'Substation' then
        S := 'SUBIDDESCR'
      else
        S := 'DESCR';
      OpenT_PANELSQ(S);
      t_panelsQ.Locate('RECNO', RECNOVal, []);
    end
    else if PageControl1.ActivePage = LoadsTab then
    begin
      DBNavigator1.DataSource := DataSource2;
      RECNOVal := t_panelsQRECNO.AsInteger;
      Opent_loadQ;
      StaticText1.Caption := t_panelsQDESCR.AsString + ': ' + t_panelsQSUBIDDESCR.AsString;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_panelsf.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = PanelsTab then
  begin
    EditBtn.Enabled := true;
    BatchUpdBtn.Enabled := true;
    ClearSubBtn.Enabled := true;
    DeleteBtn.Enabled := true;
    countbtn.Visible:= False;
  end
  else if PageControl1.ActivePage = LoadsTab then
  begin
    EditBtn.Enabled := false;
    BatchUpdBtn.Enabled := false;
    ClearSubBtn.Enabled := false;
    DeleteBtn.Enabled := false;
    countbtn.Visible:= True;
    fromdatetimebox.DateTime := GetFirstDate;
    todatetimebox.DateTime := GetLastDate;
  end;
  SortBoxChange(Sender);
end;

procedure Tt_panelsf.searchclrbtnClick(Sender: TObject);
begin
  SearchBox.Text := '';
end;

procedure Tt_panelsf.subslubtnClick(Sender: TObject);
begin
  t_subsf := Tt_subsf.Create(Application);
  try
    t_subsf.ShowModal;
    InitSubsBox;
  finally
    FreeAndNil(t_subsf);
  end;
  SortBoxChange(Sender);
end;

procedure Tt_panelsf.ClearSubBtnClick(Sender: TObject);
var
  Q: TIBSQL;
begin
  if MessageDlg('Reset current record?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    RECNOVal := t_panelsQRECNO.AsInteger;
    Q := TIBSQL.Create(nil);
    try
      Q.Database := dm.IBDatabase1;
      Q.Transaction := dm.IBTransaction1;
      Q.SQL.Add('UPDATE T_PANELS SET SUBID = Null, PANELID = NULL, PANELTPE = NULL WHERE RECNO = :RECNO');
      Q.ParamByName('RECNO').AsInteger := t_panelsQRECNO.AsInteger;
      Q.Prepare;
      Q.ExecQuery;
      Q.Close;
    finally
      Q.Free;
    end;
    SortBoxChange(Sender);
  end;
end;

procedure Tt_panelsf.InsUpdDelT_PANELS(CaptureState: TCaptureState);
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    if CaptureState = csInsert then
    begin
      Q.SQL.Add('INSERT INTO T_PANELS(DESCR,SUBID,PANELID,PANELTPE)');
      Q.SQL.Add('VALUES(:DESCR,:SUBID,:PANELID,:PANELTPE)');
    end
    else if CaptureState = csEdit then
    begin
      Q.SQL.Add('UPDATE T_PANELS SET DESCR = :DESCR,SUBID = :SUBID,');
      Q.SQL.Add('PANELID = :PANELID, PANELTPE = :PANELTPE');
      Q.SQL.Add('WHERE DESCR = :OLDDESCR');
      Q.ParamByName('OLDDESCR').AsString := OLDDESCRVal;
    end
    else if CaptureState = csDelete then
      Q.SQL.Add('DELETE FROM T_PANELS WHERE DESCR = :DESCR');
    Q.ParamByName('DESCR').AsString := DESCRVal;
    if CaptureState in [csInsert, csEdit] then
    begin
      Q.ParamByName('SUBID').AsInteger := SUBIDVal;
      Q.ParamByName('PANELID').AsInteger := PANELIDVal;
      Q.ParamByName('PANELTPE').AsString := PANELTPEVal;
    end;
    Q.Prepare;
    Q.ExecSQL;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure Tt_panelsf.ShowCapT_PANELS(CaptureState: TCaptureState; Sender: TObject);
var
  Q: TIBSQL;

  procedure AssignT_PANELSValues;
  begin
    DESCRVal := t_panelsQDESCR.Value;
    SUBIDVal := dm.GetT_SUBSID(capt_panelsf.SUBIDBox.Text);
    PANELTPEVal := capt_panelsf.paneltypebox.Text;
    PANELIDVal := StrToInt(capt_panelsf.panelidbox.Text);
  end;

begin
  RECNOVal := t_panelsQRECNO.AsInteger;
  capt_panelsf := Tcapt_panelsf.Create(Application);
  if Sender = BatchUpdBtn then
  begin
    Q := TIBSQL.Create(nil);
    capt_panelsf.Width := 275;
    capt_panelsf.panelidbox.Visible:= false;
    capt_panelsf.paneltypebox.Visible:= false;
    capt_panelsf.label2.Visible:= false;
    capt_panelsf.label3.Visible:= false;
    try
      Screen.Cursor := crHourglass;
      Q.Database := dm.IBDatabase1;
      Q.Transaction := dm.IBTransaction1;
      capt_panelsf.Caption := 'Batch Update';
      capt_panelsf.OkBtn.Caption := '&Update';
      capt_panelsf.FillForm(csEdit);
      if capt_panelsf.ShowModal = mrOk then
      begin
        SUBIDVal := dm.GetT_SUBSID(capt_panelsf.SUBIDBox.Text);
        Q.SQL.Add('UPDATE T_PANELS SET SUBID = :SUBID');
        Q.SQL.Add('WHERE RECNO >= 0');
        if SubsBox.Text <> '*ALL*' then
          Q.SQL.Add('AND SUBID = (SELECT SUBID FROM T_SUBS WHERE DESCR = :SUBIDDESCR)');
        if SearchBox.Text <> '' then
          Q.SQL.Add('AND DESCR CONTAINING :SEARCHSTR');
        If typebox.Text <> '*ALL*' then
          Q.SQL.Add('AND PANELTPE = :PANELTPE');

        if SubsBox.Text <> '*ALL*' then
          Q.ParamByName('SUBIDDESCR').AsString := SubsBox.Text;
        if SearchBox.Text <> '' then
          Q.ParamByName('SEARCHSTR').AsString := SearchBox.Text;
        If typebox.Text <> '*ALL*' then
          Q.ParamByName('PANELTPE').AsString := typebox.Text;
        Q.ParamByName('SUBID').AsInteger := SUBIDVal;
        Q.Prepare;
        Q.ExecQuery;
        SortBoxChange(t_panelsf);
      end;
    finally
      Q.Free;
      FreeAndNil(capt_panelsf);
      Screen.Cursor := crDefault;
    end;
  end
  else
  begin
    capt_panelsf.Width := 475;
    capt_panelsf.panelidbox.Visible:= true;
    capt_panelsf.paneltypebox.Visible:= true;
    capt_panelsf.label2.Visible:= true;
    capt_panelsf.label3.Visible:= true;
    try
      if CaptureState = csInsert then
      begin
        capt_panelsf.Caption := 'Insert';
        capt_panelsf.OkBtn.Caption := '&Insert';
      end
      else if CaptureState = csEdit then
      begin
        capt_panelsf.Caption := 'Edit';
        capt_panelsf.OkBtn.Caption := '&Update';
        OLDDESCRVal := t_panelsQDESCR.Value;
      end;
      capt_panelsf.FillForm(CaptureState);
      if capt_panelsf.ShowModal = mrOk then
      begin
        AssignT_PANELSValues;
        InsUpdDelT_PANELS(CaptureState);
        SortBoxChange(t_panelsf);
      end;
    finally
      FreeAndNil(capt_panelsf);
    end;
  end;
end;

procedure Tt_panelsf.EditBtnClick(Sender: TObject);
begin
  if not t_panelsQ.IsEmpty then
    ShowCapT_PANELS(csEdit,EditBtn);
end;

procedure Tt_panelsf.BatchUpdBtnClick(Sender: TObject);// TODO : Maybe do this more elegantly
begin
  ShowCapT_PANELS(csEdit,BatchUpdBtn);
end;

procedure Tt_panelsf.DBGrid1DblClick(Sender: TObject);
begin
  PageControl1.ActivePage := LoadsTab;
  todatetimebox.DateTime := GetLastDate;
  fromdatetimebox.DateTime:= Date - 183;
  PageControl1Change(Sender);
end;

procedure Tt_panelsf.DeleteBtnClick(Sender: TObject);
begin
  if MessageDlg('Delete current Panel and all associated Load records?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DESCRVal := t_panelsQDESCR.AsString;
    InsUpdDelT_PANELS(csDelete);
    SortBoxChange(Sender);
  end;
end;

procedure Tt_panelsf.ShowAllBtnClick(Sender: TObject);
begin
  SubsBox.Text := '*ALL*';
  SearchBox.Text := '';
  typebox.Text := '*ALL*';
  PageControl1Change(Sender);
  SortBoxChange(Sender);
end;

procedure Tt_panelsf.countbtnClick(Sender: TObject);
begin
  ShowMessage('Records - ' + Inttostr(GetRecordCount));
end;

procedure Tt_panelsf.frompinbtnClick(Sender: TObject);
begin
  fromdatetimebox.DateTime:= t_loadQDTE.AsDateTime;
  SortBoxChange(Sender);
end;

procedure Tt_panelsf.topinbtnClick(Sender: TObject);
begin
  todatetimebox.DateTime:= t_loadQDTE.AsDateTime;
  SortBoxChange(Sender);
end;

function Tt_panelsf.GetFirstDate: TDate;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT MIN(DTE) AS MINDATE FROM T_LOAD WHERE RECNO = :RECNO');
    Q.ParamByName('RECNO').AsInteger := t_panelsQRECNO.AsInteger;
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
  
function Tt_panelsf.GetLastDate: TDate;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT MAX(DTE) AS MAXDATE FROM T_LOAD WHERE RECNO = :RECNO');
    Q.ParamByName('RECNO').AsInteger := t_panelsQRECNO.AsInteger;
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

function Tt_panelsf.GetRecordCount: Integer;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT COUNT(*) AS RECORDS FROM T_LOAD WHERE RECNO = :RECNO');
    Q.SQL.Add('AND DTE >= :FROMDTE AND DTE <= :TODTE');
    Q.ParamByName('RECNO').AsInteger := t_panelsQRECNO.AsInteger;
    Q.ParamByName('FROMDTE').AsDateTime := fromdatetimebox.DateTime;
    Q.ParamByName('TODTE').AsDateTime := todatetimebox.DateTime;
    Q.Prepare;
    Q.Open;
    Result := Q.FieldByName('RECORDS').AsInteger;
    Q.Close;
  finally
    Q.Free;
  end;
end;

end.
