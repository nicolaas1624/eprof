unit _mainf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PrintersDlgs, Forms, Controls, Dialogs, Menus, ComCtrls, ExtCtrls,
  IBQuery, IBSQL, Classes;

type

  { Tmainf }

  Tmainf = class(TForm)
    FontDialog1: TFontDialog;
    Helpmenu1: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Output1: TMenuItem;
    PDFReader1: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem3: TMenuItem;
    Usermanager1: TMenuItem;
    Serverproperties1: TMenuItem;
    RunSQLscript: TMenuItem;
    InitHelptopics1: TMenuItem;
    Initlookups1: TMenuItem;
    MenuItem9: TMenuItem;
    pLogo: TImage;
    Database1: TMenuItem;
    Emaillog1: TMenuItem;
    Emailsetup1: TMenuItem;
    Exit1: TMenuItem;
    ExitBtn: TToolButton;
    ImageList1: TImageList;
    Images1: TMenuItem;
    ImagesBtn: TToolButton;
    InputMenu: TMenuItem;
    LoginBtn: TToolButton;
    Lookup1: TMenuItem;
    MainMenu1: TMainMenu;
    Printerinformation1: TMenuItem;
    MenuItem2: TMenuItem;
    N1: TMenuItem;
    N3: TMenuItem;
    Open1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Parameters1: TMenuItem;
    ParametersLookups1: TMenuItem;
    PrintDialog1: TPrintDialog;
    Restoresnapshot1: TMenuItem;
    Snapshot1: TMenuItem;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    SnapshotBtn: TToolButton;
    ToolButton3: TToolButton;
    procedure Emaillog1Click(Sender: TObject);
    procedure Emailsetup1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Images1Click(Sender: TObject);
    procedure Lookup1Click(Sender: TObject);
    procedure Helpmenu1Click(Sender: TObject);
    procedure Initlookups1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure Parameters1Click(Sender: TObject);
    procedure PDFReader1Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure Printerinformation1Click(Sender: TObject);
    procedure RunSQLscriptClick(Sender: TObject);
    procedure Usermanager1Click(Sender: TObject);
    procedure Serverproperties1Click(Sender: TObject);
    procedure InitHelptopics1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Restoresnapshot1Click(Sender: TObject);
    procedure Snapshot1Click(Sender: TObject);
  private
    procedure EnableControls;
    procedure DisableControls;
    procedure OpenDatabase;
  public
    procedure ShowPDFHelp(HelpID: integer);
  end;

var
  mainf: Tmainf;

implementation

uses _global, _dm, _loginf, _aboutf, _lookupf, _t_pictf, _snapshotf, _restoref,
  _printerinfof, _emailsetupf, _emaillogf, _usermanagerf, _serverpropsf,
  _initlookupsf, _t_helpf, _t_paramvaluesf, _zipfilef, _unzipfilef, _t_loadf,
  _t_panelsf, _t_tmploadf;

{$R *.lfm}

procedure Tmainf.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels.Items[0].Text := '';
  StatusBar1.Panels.Items[1].Text := '';
  StatusBar1.Panels.Items[2].Text := DateToStr(Date);
end;

procedure Tmainf.FormShow(Sender: TObject);
begin
  WindowState := wsMaximized;
  FormResize(Sender);
  Caption := AppName + ': ' + pVersion;
  PDFReader1.Caption := 'PDF Reader: ' + cnf.PDFReader;

  // create folders
  appPath := application.Location;
  HelpfilesPath := appPath + 'docs';
  CreateDir(HelpfilesPath);
  EmailFolder := appPath + 'email';
  CreateDir(EmailFolder);
  SMSFolder := appPath + 'sms';
  CreateDir(SMSFolder);

  OpenDatabase;

  StatusBar1.Panels.Items[1].Text := '';
  StatusBar1.Panels.Items[2].Text := DateToStr(Date);
end;

procedure Tmainf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  WriteCnfFile;
  dm.CloseDatabase;
end;

procedure Tmainf.FormResize(Sender: TObject);
begin
  pLogo.Top := Height div 2 - pLogo.Height div 2 - StatusBar1.Height div 2;
  pLogo.Left := Width div 2 - pLogo.Width div 2;
  StatusBar1.Panels[0].Width := Round(ClientWidth * 0.3);
  StatusBar1.Panels[1].Width := Round(ClientWidth * 0.58);
  StatusBar1.Panels[2].Width := Round(ClientWidth * 0.12);
end;

procedure Tmainf.OpenDatabase;
begin
  DisableControls;
  StatusBar1.Panels.Items[0].Text := '';
  StatusBar1.Panels.Items[1].Text := '';
  if dm.IBDatabase1.Connected then
  begin
    if dm.IBTransaction1.Active then
      dm.IBTransaction1.Commit;
    dm.IBDatabase1.Close;
  end;
  loginf := Tloginf.Create(Application);
  try
    if loginf.ShowModal = mrOk then
      try
        Screen.cursor := crHourGlass;
        try
          cnf.DBFileName := loginf.DBNameBox.Text;
          dm.IBDatabase1.Params.Clear;
          dm.IBDatabase1.DatabaseName := loginf.ServerBox.Text + ':' + cnf.DBFileName;
          dm.IBDatabase1.Params.Add('user_name=' + loginf.UsernameBox.Text);
          dm.IBDatabase1.Params.Add('password=' + loginf.PasswordBox.Text);
          dm.IBDatabase1.Params.Add('sql_role_name=' + loginf.RoleBox.Text);
          dm.IBDatabase1.Open;
          dm.IBTransaction1.Active := true;
          EnableControls;
          cnf.ServerName := loginf.ServerBox.Text;
          cnf.UserName := loginf.UsernameBox.Text;
          cnf.Role := loginf.RoleBox.Text;
          StatusBar1.Panels.Items[0].Text := LowerCase(cnf.ServerName + ':' + cnf.DBFileName);
          StatusBar1.Panels.Items[1].Text := '';
        except
          ShowMessage('Could not open database, password probably incorrect!');
          DisableControls;
        end;
      finally
        Screen.cursor := crDefault;
      end;
  finally
    FreeAndNil(loginf);
  end;
end;

procedure Tmainf.EnableControls;
begin
  ImagesBtn.Enabled := True;
  Snapshot1.Enabled := True;
  SnapshotBtn.Enabled := True;
  Restoresnapshot1.Enabled := True;
  InputMenu.Enabled := True;
  Usermanager1.Enabled := True;
  Serverproperties1.Enabled := True;
  InitHelptopics1.Enabled := True;
  Initlookups1.Enabled := True;
  RunSQLscript.Enabled := True;
  Helpmenu1.Enabled := True;
  Output1.Enabled := True;
end;

procedure Tmainf.DisableControls;
begin
  ImagesBtn.Enabled := False;
  Snapshot1.Enabled := False;
  SnapshotBtn.Enabled := False;
  Restoresnapshot1.Enabled := False;
  InputMenu.Enabled := False;
  Usermanager1.Enabled := False;
  Serverproperties1.Enabled := False;
  InitHelptopics1.Enabled := False;
  Initlookups1.Enabled := False;
  RunSQLscript.Enabled := False;
  Helpmenu1.Enabled := False;
  Output1.Enabled := False;
  StatusBar1.Panels.Items[0].Text := '';
  StatusBar1.Panels.Items[1].Text := '';
end;

procedure Tmainf.Emaillog1Click(Sender: TObject);
begin
  emaillogf := Temaillogf.Create(Application);
  try
    emaillogf.ShowModal;
  finally
    FreeAndNil(emaillogf);
  end;
end;

procedure Tmainf.Emailsetup1Click(Sender: TObject);
begin
  emailsetupf := Temailsetupf.Create(Application);
  try
    emailsetupf.ShowModal;
  finally
    FreeAndNil(emailsetupf);
  end;
end;

procedure Tmainf.Open1Click(Sender: TObject);
begin
  OpenDatabase;
end;

procedure Tmainf.Restoresnapshot1Click(Sender: TObject);
begin
  if dm.IBDatabase1.Connected then
  begin
    dm.CloseDatabase;
    DisableControls;
  end;
  restoref := Trestoref.Create(Application);
  try
    restoref.ShowModal;
  finally
    FreeAndNil(restoref);
  end;
end;

procedure Tmainf.Snapshot1Click(Sender: TObject);
begin
  snapshotf := Tsnapshotf.Create(Application);
  try
    snapshotf.ShowModal;
  finally
    FreeAndNil(snapshotf);
  end;
end;

procedure Tmainf.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure Tmainf.Lookup1Click(Sender: TObject);
begin
  lookupf := Tlookupf.Create(Application);
  try
    lookupf.ShowModal;
  finally
    FreeAndNil(lookupf);
  end;
end;

procedure Tmainf.Helpmenu1Click(Sender: TObject);
begin
  t_helpf := Tt_helpf.Create(Application);
  try
    t_helpf.ShowModal;
  finally
    FreeAndNil(t_helpf);
  end;
end;

procedure Tmainf.Initlookups1Click(Sender: TObject);
begin
  if MessageDlg('Initialize lookups?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    initlookupsf := Tinitlookupsf.Create(Application);
    try
      initlookupsf.InitFlag := 0; // 0 = lookups, 1 = Help
      initlookupsf.ShowModal;
    finally
      FreeAndNil(initlookupsf);
    end;
  end;
end;

procedure Tmainf.MenuItem1Click(Sender: TObject);
begin
  zipfilef := Tzipfilef.Create(Application);
  try
    zipfilef.ShowModal;
  finally
    FreeAndNil(zipfilef);
  end;
end;

procedure Tmainf.MenuItem4Click(Sender: TObject);
begin
  unzipfilef := Tunzipfilef.Create(Application);
  try
    unzipfilef.ShowModal;
  finally
    FreeAndNil(unzipfilef);
  end;
end;

procedure Tmainf.MenuItem5Click(Sender: TObject);
begin
  t_loadf := Tt_loadf.Create(Application);
  try
    t_loadf.ShowModal;
  finally
    FreeAndNil(t_loadf);
  end;
end;

procedure Tmainf.MenuItem6Click(Sender: TObject);
begin
  t_panelsf := Tt_panelsf.Create(Application);
  try
    t_panelsf.ShowModal;
  finally
    FreeAndNil(t_panelsf);
  end;
end;

procedure Tmainf.MenuItem7Click(Sender: TObject);
begin
  t_tmploadf := Tt_tmploadf.Create(Application);
  try
    t_tmploadf.ShowModal;
  finally
    FreeAndNil(t_tmploadf);
  end;
end;

procedure Tmainf.Parameters1Click(Sender: TObject);
begin
  if dm.IBDatabase1.Params.Values['user_name'] = 'SYSDBA' then
  begin
    t_paramvaluesf := Tt_paramvaluesf.Create(Application);
    try
      t_paramvaluesf.ShowModal;
    finally
      FreeAndNil(t_paramvaluesf);
    end;
  end
  else
    MessageDlg(dm.IBDatabase1.Params.Values['user_name'] + ' does not have rights to setup parameters.',
      mtInformation, [mbOK], 0);
end;

procedure Tmainf.PDFReader1Click(Sender: TObject);
begin
  OpenDialog1.Filter := 'Application files (*.exe)|*.exe';
  if OpenDialog1.Execute then
  begin
    cnf.PDFReader := LowerCase(OpenDialog1.FileName);
    PDFReader1.Caption := 'PDF Reader: ' + cnf.PDFReader;
  end;
end;

procedure Tmainf.MenuItem13Click(Sender: TObject);
begin
  aboutf := Taboutf.Create(Application);
  try
    aboutf.ShowModal;
  finally
    FreeAndNil(aboutf);
  end;
end;

procedure Tmainf.Printerinformation1Click(Sender: TObject);
begin
  printerinfof := Tprinterinfof.Create(Application);
  try
    printerinfof.ShowModal;
  finally
    FreeAndNil(printerinfof);
  end;
end;

procedure Tmainf.RunSQLscriptClick(Sender: TObject);
var
  FVar: TextFile;
  Q: TIBSQL;
  S: string;
begin
  if MessageDlg('Did you make a snapshot of the database?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    OpenDialog1.Filter :=
      'SQL files (*.sql)|*.sql|Text files (*.txt)|*.txt|All files (*.*)|*.*';
    if OpenDialog1.Execute then
      try
        Q := TIBSQL.Create(nil);
        Q.Database := dm.IBDatabase1;
        Q.Transaction := dm.IBTransaction1;
        AssignFile(FVar, OpenDialog1.FileName);
        Reset(FVar);
        while not EOF(FVar) do
        begin
          ReadLn(FVar, S);
          if Pos('//', S) > 0 then
          begin
            Q.Prepare;
            Q.ExecQuery;
            Q.SQL.Clear;
            dm.IBTransaction1.CommitRetaining;
          end
          else
            Q.SQL.Add(S);
        end;
        Q.Close;
        MessageDlg(OpenDialog1.FileName + ' update successful.',
          mtInformation, [mbOK], 0);
      finally
        CloseFile(FVar);
        Q.Free;
      end;
    dm.IBTransaction1.Commit;
  end;
end;

procedure Tmainf.Usermanager1Click(Sender: TObject);
begin
  if Uppercase(dm.IBDatabase1.Params.Values['user_name']) = 'SYSDBA' then
  begin
    usermanagerf := Tusermanagerf.Create(Application);
    try
      usermanagerf.ShowModal;
    finally
      FreeAndNil(usermanagerf);
    end;
  end
  else
    MessageDlg(dm.IBDatabase1.Params.Values['user_name'] + ' does not have rights to database services.',
      mtInformation, [mbOK], 0);
end;

procedure Tmainf.Serverproperties1Click(Sender: TObject);
begin
  serverpropsf := Tserverpropsf.Create(Application);
  try
    serverpropsf.ShowModal;
  finally
    FreeAndNil(serverpropsf);
  end;
end;

procedure Tmainf.InitHelptopics1Click(Sender: TObject);
var
  s: string;
begin
  s := dm.GetParamValue('DEL_PASSW');
  if MessageDlg('Initialize help topics?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    initlookupsf := Tinitlookupsf.Create(Application);
    try
      initlookupsf.InitFlag := 1; // 0 = lookups, 1 = Help
      initlookupsf.ShowModal;
    finally
      FreeAndNil(initlookupsf);
    end;
  end;
end;

procedure Tmainf.Images1Click(Sender: TObject);
begin
  t_pictf := Tt_pictf.Create(Application);
  try
    t_pictf.ShowModal;
  finally
    FreeAndNil(t_pictf);
  end;
end;

procedure Tmainf.ShowPDFHelp(HelpID: integer);

  function GetHelpfileFromID(IDVal: integer): string;
  var
    Q: TIBQuery;
  begin
    Q := TIBQuery.Create(nil);
    try
      Q.Database := dm.IBDatabase1;
      Q.Transaction := dm.IBTransaction1;
      Q.SQL.Add('SELECT * FROM GET_HELPFILE_FROMID(:IDVAL)');
      Q.ParamByName('IDVAL').AsInteger := IDVal;
      Q.Prepare;
      Q.Open;
      Result := HelpfilesPath + '\' + Q.FieldByName('RESULT').AsString;
      Q.Close;
    finally
      Q.Free;
    end;
  end;

begin
  PDFFileName := GetHelpfileFromID(HelpID);
  ExecuteProcess(cnf.PDFReader, PDFFileName, []);
end;

end.
