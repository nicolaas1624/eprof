unit _restoref;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Controls, Dialogs, ExtCtrls, Buttons, StdCtrls, IBServices,
  db, Classes, IB;

type

  { Trestoref }

  Trestoref = class(TForm)
    CancelBtn: TBitBtn;
    IBRestoreService1: TIBRestoreService;
    IBServerProperties1: TIBServerProperties;
    Memo1: TMemo;
    OkBtn: TBitBtn;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    procedure DoRestore(Data: PtrInt);
  public
  end;

var
  restoref: Trestoref;

implementation

uses _dm, _global, _mainf, _misc, _password;

{$R *.lfm}

procedure Trestoref.FormShow(Sender: TObject);
var
  i: integer;
begin
  IBServerProperties1.ServerName := cnf.ServerName;
  IBServerProperties1.Params.Values['user_name'] := dm.IBDatabase1.Params.Values['user_name'];
  IBServerProperties1.Params.Values['password'] := dm.IBDatabase1.Params.Values['password'];
  with IBServerProperties1 do
  begin
    repeat
      try
        Active := true;
      except
       on E:EIBClientError do
        begin
          Close;
          Exit;
        end;
       On E:Exception do
         MessageDlg(E.Message,mtError,[mbOK],0);
      end;
    until Active; {Loop until logged in or user cancels}
    FetchVersionInfo;
    Memo1.Lines.Add('Server Version = ' + VersionInfo.ServerVersion);
    Memo1.Lines.Add('Server Implementation = ' + VersionInfo.ServerImplementation);
    Memo1.Lines.Add('Service Version = ' + IntToStr(VersionInfo.ServiceVersion));
    FetchDatabaseInfo;
    Memo1.Lines.Add('No. of attachments = ' + IntToStr(DatabaseInfo.NoOfAttachments));
    Memo1.Lines.Add('No. of databases = ' + IntToStr(DatabaseInfo.NoOfDatabases));
    for i := 0 to DatabaseInfo.NoOfDatabases - 1 do
      Memo1.Lines.Add('DB Name = ' + DatabaseInfo.DbName[i]);
    FetchConfigParams;
    Memo1.Lines.Add('Base Location = ' + ConfigParams.BaseLocation);
    Memo1.Lines.Add('Lock File Location = ' + ConfigParams.LockFileLocation);
    Memo1.Lines.Add('Security Database Location = ' + ConfigParams.SecurityDatabaseLocation);
  end;
end;

procedure Trestoref.DoRestore(Data: PtrInt);
var
  bakfile: TFileStream;
  line: string;
begin
  bakfile := nil;
  IBRestoreService1.ServiceIntf := IBServerProperties1.ServiceIntf;
  IBRestoreService1.Active := true;
  if IBRestoreService1.IsServiceRunning then
    Exception.Create('A Service is still running');
  IBRestoreService1.ServiceStart;
  Memo1.Lines.Add('Restore Started');
  try
    if IBRestoreService1.BackupFileLocation = flClientSide then
      bakfile := TFileStream.Create(IBRestoreService1.BackupFile[0], fmOpenRead);
    while not IBRestoreService1.Eof do
    begin
      case IBRestoreService1.BackupFileLocation of
      flServerSide:
        Memo1.Lines.Add(Trim(IBRestoreService1.GetNextLine));
      flClientSide:
        begin
          IBRestoreService1.SendNextChunk(bakfile, line);
          if line <> '' then
            Memo1.Lines.Add(line);
        end;
      end;
      Application.ProcessMessages
    end;
  finally
    if bakfile <> nil then
      bakfile.Free;
  end;
  Memo1.Lines.Add('Restore Completed');
  MessageDlg('Restore Completed', mtInformation, [mbOK], 0);
end;

procedure Trestoref.OkBtnClick(Sender: TObject);
var
  BackupFileName: String;
begin
  if GetPassWord('Restore') then
  begin
    mainf.OpenDialog1.FileName := cnf.SnapShotFileName;
    mainf.OpenDialog1.Title := 'Restore snapshot';
    mainf.OpenDialog1.Filter := 'Database backup files (*.fbk*)|*.fbk*';
    if mainf.OpenDialog1.Execute then
    begin
      OkBtn.Enabled := false;
      cnf.SnapShotFileName := mainf.OpenDialog1.FileName;
      BackupFileName := GenBackupFilename(cnf.DBFileName, 'fdb');
      if not RenameFile(cnf.DBFileName, BackupFileName) then
        raise Exception.Create('Unable to create backup file.');

      IBRestoreService1.ServerName := cnf.ServerName;
      IBRestoreService1.DatabaseName.Add(LowerCase(cnf.DBFileName));
      IBRestoreService1.BackupFile.Clear;
      IBRestoreService1.BackupFile.Add(cnf.SnapShotFileName);
      IBRestoreService1.BackupFileLocation := flServerSide;
      IBRestoreService1.Verbose := true; 
      IBRestoreService1.Params.Values['user_name'] := dm.IBDatabase1.Params.Values['user_name'];
      IBRestoreService1.Params.Values['password'] := dm.IBDatabase1.Params.Values['password'];

      Application.QueueAsyncCall(@DoRestore, 0);
    end;
  end;
end;

end.

