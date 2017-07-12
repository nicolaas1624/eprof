unit _snapshotf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, StdCtrls, Controls, Forms, Dialogs, Buttons, ExtCtrls,
  IBServices, IB;

type

  { Tsnapshotf }

  Tsnapshotf = class(TForm)
    IBBackupService1: TIBBackupService;
    IBServerProperties1: TIBServerProperties;
    Memo1: TMemo;
    Panel1: TPanel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    procedure DoBackup(Data: PtrInt);
  public
  end;

var
  snapshotf: Tsnapshotf;

implementation

{$R *.lfm}

uses _global, _dm, _misc;

procedure Tsnapshotf.FormShow(Sender: TObject);
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

procedure Tsnapshotf.DoBackup(Data: PtrInt);
var
  bakfile: TFileStream;
begin
  bakfile := nil;
  IBBackupService1.ServiceIntf := IBServerProperties1.ServiceIntf;
  IBBackupService1.Active := true;
  Memo1.Lines.Add('Starting Backup');
  IBBackupService1.ServiceStart;
  try
    if IBBackupService1.BackupFileLocation = flClientSide then
      bakfile := TFileStream.Create(IBBackupService1.BackupFile[0], fmCreate);
    while not IBBackupService1.Eof do
    begin
      case IBBackupService1.BackupFileLocation of
        flServerSide: Memo1.Lines.Add(IBBackupService1.GetNextLine);
        flClientSide: IBBackupService1.WriteNextChunk(bakfile);
      end;
      Application.ProcessMessages;
    end;
  finally
    if bakfile <> nil then
      bakfile.Free;
  end;
  Memo1.Lines.Add('Write config file');
  WriteCnfFile;
  Memo1.Lines.Add('Snapshot completed');
  MessageDlg('Snapshot finished.', mtInformation, [mbOk], 0);
end;

procedure Tsnapshotf.OkBtnClick(Sender: TObject);
begin
  if MessageDlg('Make a snapshot?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  try
    Screen.cursor := crHourGlass;
    OkBtn.Enabled := false;
    cnf.SnapShotFileName := GenBackupFilename(cnf.DBFileName, 'fbk');

    IBBackupService1.ServerName := cnf.ServerName;
    IBBackupService1.DatabaseName := LowerCase(cnf.DBFileName);
    IBBackupService1.BackupFile.Clear;
    IBBackupService1.BackupFile.Add(cnf.SnapShotFileName);
    IBBackupService1.BackupFileLocation := flServerSide;
    IBBackupService1.Params.Values['user_name'] := dm.IBDatabase1.Params.Values['user_name'];
    IBBackupService1.Params.Values['password'] := dm.IBDatabase1.Params.Values['password'];

    Application.QueueAsyncCall(@DoBackup, 0);
  finally
    Screen.cursor := crDefault;
  end;
end;

end.
