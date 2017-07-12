unit _emaillogf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Controls, Forms, Dialogs, DBGrids, DB, DBCtrls, StdCtrls,
  ExtCtrls, ComCtrls, Printers, IBQuery, IBSQL, IBCustomDataSet, DateTimePicker;

type

  { Temaillogf }

  Temaillogf = class(TForm)
    FromDateBox: TDateTimePicker;
    T_EMAILLOGQ: TIBQuery;
    T_EMAILLOGQCLIENTID: TIBStringField;
    T_EMAILLOGQCOMPID: TSmallintField;
    T_EMAILLOGQDESCR: TIBStringField;
    T_EMAILLOGQDTETME: TDateTimeField;
    T_EMAILLOGQRECNO: TIntegerField;
    T_EMAILLOGQTPE: TSmallintField;
    T_EMAILLOGQTPEDESCR: TIBStringField;
    T_EMAILLOGQUSERID: TIBStringField;
    ToDateBox: TDateTimePicker;
    ToolBar1: TToolBar;
    PrintBtn: TToolButton;
    DBNavigator1: TDBNavigator;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    ToolButton2: TToolButton;
    Panel2: TPanel;
    TotalBox: TLabeledEdit;
    Panel3: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label2: TLabel;
    CUSTIDBox: TComboBox;
    Label3: TLabel;
    TYPEBox: TComboBox;
    Label1: TLabel;
    USERIDBox: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SortBoxChange(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
  private
    procedure OpenT_EMAILLOGQ;
    function GetTotalEMails: integer;
    procedure DeleteEMails;
  public
  end;

var
  emaillogf: Temaillogf;

implementation

uses _global, _print, _mainf, _dm;

{$R *.lfm}

procedure Temaillogf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    CUSTIDBox.Items.Add('*ALL*');
    DM.OpenQ('SELECT DISTINCT CLIENTID FROM T_EMAILLOG WHERE COMPID = ' + IntToStr(cnf.DefComp) + ' ORDER BY CLIENTID');
    while not DM.XQ.EOF do
    begin
      CUSTIDBox.Items.Add(DM.XQ.FieldByName('CLIENTID').AsString);
      DM.XQ.Next;
    end;
    DM.XQ.Close;
    CUSTIDBox.Text := '*ALL*';

    USERIDBox.Items.Add('*ALL*');
    DM.OpenQ('SELECT DISTINCT USERID FROM T_EMAILLOG WHERE COMPID = ' + IntToStr(cnf.DefComp) + ' ORDER BY USERID');
    while not DM.XQ.EOF do
    begin
      USERIDBox.Items.Add(DM.XQ.FieldByName('USERID').AsString);
      DM.XQ.Next;
    end;
    DM.XQ.Close;
    USERIDBox.Text := '*ALL*';

    TYPEBox.Items.CommaText := DM.GetLookupItems(1, 'EMAILLOGTYPES', 'DESCR');
    TYPEBox.Text := '*ALL*';
{
    BMIni := TRegistryIniFile.Create(IniFileName);
    FromDateBox.Date := BMIni.ReadDateTime('EMailLog','FromDateBox',Date-90);
    BMIni.Free;
}
    ToDateBox.Date := Date + 1;

    SortBoxChange(Sender);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Temaillogf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
{
  BMIni := TRegistryIniFile.Create(IniFileName);
  BMIni.WriteDateTime('EMailLog','FromDateBox',FromDateBox.Date);
  BMIni.Free;
}
  T_EMAILLOGQ.Close;
  DM.IBTransaction1.CommitRetaining;
end;

procedure Temaillogf.OpenT_EMAILLOGQ;
begin
  T_EMAILLOGQ.Close;
  T_EMAILLOGQ.SQL.Clear;
  T_EMAILLOGQ.SQL.Add('SELECT * FROM V_EMAILLOG WHERE DTETME >= :FROMDATE AND DTETME <= :TODATE');
  if CUSTIDBox.Text <> '*ALL*' then
  begin
    T_EMAILLOGQ.SQL.Add('AND CLIENTID = :CLIENTID');
    T_EMAILLOGQ.ParamByName('CLIENTID').Value := CUSTIDBox.Text;
  end;
  if USERIDBox.Text <> '*ALL*' then
  begin
    T_EMAILLOGQ.SQL.Add('AND USERID = :USERID');
    T_EMAILLOGQ.ParamByName('USERID').Value := USERIDBox.Text;
  end;
  if TYPEBox.Text <> '*ALL*' then
  begin
    T_EMAILLOGQ.SQL.Add('AND TPEDESCR = :TPEDESCR');
    T_EMAILLOGQ.ParamByName('TPEDESCR').Value := TYPEBox.Text;
  end;
  T_EMAILLOGQ.ParamByName('FROMDATE').Value := FromDateBox.DateTime;
  T_EMAILLOGQ.ParamByName('TODATE').Value := ToDateBox.DateTime;
  T_EMAILLOGQ.SQL.Add('ORDER BY DTETME');
  T_EMAILLOGQ.Prepare;
  T_EMAILLOGQ.Open;
end;

function Temaillogf.GetTotalEMails: integer;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.DataBase := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT COUNT(RECNO) AS TOTAL FROM V_EMAILLOG WHERE DTETME >= :FROMDATE AND DTETME <= :TODATE');
    if CUSTIDBox.Text <> '*ALL*' then
      Q.SQL.Add('AND CLIENTID = :CLIENTID');
    if USERIDBox.Text <> '*ALL*' then
      Q.SQL.Add('AND USERID = :USERID');
    if TYPEBox.Text <> '*ALL*' then
      Q.SQL.Add('AND TPEDESCR = :TPEDESCR');
    if CUSTIDBox.Text <> '*ALL*' then
      Q.ParamByName('CLIENTID').Value := CUSTIDBox.Text;
    if USERIDBox.Text <> '*ALL*' then
      Q.ParamByName('USERID').Value := USERIDBox.Text;
    if TYPEBox.Text <> '*ALL*' then
      Q.ParamByName('TPEDESCR').Value := TYPEBox.Text;
    Q.ParamByName('FROMDATE').Value := FromDateBox.DateTime;
    Q.ParamByName('TODATE').Value := ToDateBox.DateTime;
    Q.Prepare;
    Q.Open;
    Result := Q.FieldByName('TOTAL').AsInteger;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure Temaillogf.DeleteEMails;
var
  Q: TIBSQL;
begin
  Q := TIBSQL.Create(nil);
  try
    Q.DataBase := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('DELETE FROM V_EMAILLOG WHERE DTETME >= :FROMDATE AND DTETME <= :TODATE');
    if CUSTIDBox.Text <> '*ALL*' then
      Q.SQL.Add('AND CLIENTID = :CLIENTID');
    if USERIDBox.Text <> '*ALL*' then
      Q.SQL.Add('AND USERID = :USERID');
    if TYPEBox.Text <> '*ALL*' then
      Q.SQL.Add('AND TPEDESCR = :TPEDESCR');
    if CUSTIDBox.Text <> '*ALL*' then
      Q.ParamByName('CLIENTID').Value := CUSTIDBox.Text;
    if USERIDBox.Text <> '*ALL*' then
      Q.ParamByName('USERID').Value := USERIDBox.Text;
    if TYPEBox.Text <> '*ALL*' then
      Q.ParamByName('TPEDESCR').Value := TYPEBox.Text;
    Q.ParamByName('FROMDATE').Value := FromDateBox.DateTime;
    Q.ParamByName('TODATE').Value := ToDateBox.DateTime;
    Q.Prepare;
    Q.ExecQuery;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure Temaillogf.SortBoxChange(Sender: TObject);
begin
  OpenT_EMAILLOGQ;
  TotalBox.Text := IntToStr(GetTotalEMails);
end;

procedure Temaillogf.ToolButton2Click(Sender: TObject);
begin
  if MessageDlg('Do you really want to delete all the records currently displayed?', mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    DeleteEMails;
    SortBoxChange(Sender);
  end;
end;

procedure Temaillogf.PrintBtnClick(Sender: TObject);

  procedure PrintT_EMAILLOGData;

    procedure InitReport;
    begin
      with Prn do
      begin
        LJSet := [1..6];
        Title := 'E-mail log';
        FooterStr := DateToStr(Date);
        Titles := 'Client ID;Type;Date&Time;Description;User ID;';
        ColWidths := VarArrayOf([0, 12, 12, 20, 40, 15]);
        SetReportParams(Printer.Canvas, 10, 2, 3, 3, mainf.FontDialog1.Font);
      end;
    end;

  begin
    Prn := TPrn.Create;
    with Prn do
      try
        Printer.Orientation := poPortrait;
        Printer.BeginDoc;
        InitReport;
        PrnHeader(Printer.Canvas);
        T_EMAILLOGQ.First;
        while not T_EMAILLOGQ.EOF do
        begin
          ColDet[1] := T_EMAILLOGQCLIENTID.AsString;
          ColDet[2] := T_EMAILLOGQTPEDESCR.AsString;
          ColDet[3] := T_EMAILLOGQDTETME.AsString;
          ColDet[4] := T_EMAILLOGQDESCR.AsString;
          ColDet[5] := T_EMAILLOGQUSERID.AsString;
          PrnNextLine(Printer.Canvas, False, True);
          T_EMAILLOGQ.Next;
        end;
        PrnFinish(Printer.Canvas);
      finally
        Prn.Free;
      end;
  end;

begin
  if mainf.PrintDialog1.Execute then
    try
      Screen.Cursor := crHourglass;
      PrintT_EMAILLOGData;
    finally
      Screen.Cursor := crDefault;
    end;
end;

end.
