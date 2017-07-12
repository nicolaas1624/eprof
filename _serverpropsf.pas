unit _serverpropsf;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FBAdmin, Forms, Dialogs, ExtCtrls, StdCtrls;

type

  { Tserverpropsf }

  Tserverpropsf = class(TForm)
    ClientLibBox: TLabeledEdit;
    FBAdmin1: TFBAdmin;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Panel1: TPanel;
    PasswordBox: TLabeledEdit;
    ProtocolBox: TLabeledEdit;
    RoleBox: TLabeledEdit;
    ServerNameBox: TLabeledEdit;
    UsernameBox: TLabeledEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    ServerVersion: String;
    ServerImplementation: String;
    ServiceVersion: Integer;
    NoOfAttachments: Integer;
    NoOfDatabases: Integer;
    DbName: Array [0 .. 4] of String;
    BaseLocation: String;
    LockFileLocation: String;
    MessageFileLocation: String;
    SecurityDatabaseLocation: String;
    procedure ServerProperties;
    procedure OnDatabaseLog(Sender: TObject; msg: string; IBAdminAction: string);
  public
  end;

var
  serverpropsf: Tserverpropsf;

implementation

uses _dm, _global, _misc;

{$R *.lfm}

{ Tserverpropsf }

procedure Tserverpropsf.FormShow(Sender: TObject);
begin
  //FBAdmin1.UseExceptions := True;
  //FBAdmin1.Host := cnf.ServerName;
  //FBAdmin1.Protocol := IBSPTCPIP;  //IBSPLOCAL;
  //FBAdmin1.User := dm.fDatabase.UserName;
  //FBAdmin1.Password := dm.fDatabase.Password;
  //FBAdmin1.Connect;
  //FBAdmin1.OnOutput := @OnDatabaseLog;
  //ServerNameBox.Text := cnf.ServerName;
  //UsernameBox.Text := dm.fDatabase.UserName;
  //PasswordBox.Text := dm.fDatabase.Password;
  //RoleBox.Text := dm.fDatabase.Role;
  ServerProperties;
end;

procedure Tserverpropsf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FBAdmin1.DisConnect;
end;

procedure Tserverpropsf.OnDatabaseLog(Sender: TObject; msg: string; IBAdminAction: string);
begin
  Memo1.Lines.Add(IBAdminAction + ' : ' + msg);
end;

procedure Tserverpropsf.ServerProperties;
var
  i: Integer;
  Users: TStringList;
  Memory: TMemoryStatus;
begin
  Memory.dwLength := SizeOf(Memory);
  GlobalMemoryStatus(Memory);

  with Memo1.Lines do
  begin
    Add('Total memory:     ' + FormatFloat('#.## bytes', Memory.dwTotalPhys) + ' (' + FormatByteSize(Memory.dwTotalPhys) + ')');
    Add('Available memory: ' + FormatFloat('#.## bytes', Memory.dwAvailPhys) + ' (' + FormatByteSize(Memory.dwAvailPhys) + ')');
//    Add('OrderBuff memory: ' + FormatFloat('#.## bytes', SizeOf(OrderBuff)) + ' (' + FormatByteSize(SizeOf(OrderBuff)) + ')');
    Add('');
    Add('Server Version:             ' + FBAdmin1.ServerVersion);
    Add('Server Implementation:      ' + FBAdmin1.ServerImplementation);
    Add('Server root directory:      ' + FBAdmin1.ServerRootDir);
    Add('Lock File location:         ' + FBAdmin1.ServerLockDir);
    Add('Message File location:      ' + FBAdmin1.ServerMsgDir);
    Add('Security Database location: ' + FBAdmin1.ServerSecDBDir);
    Add('Port:                       ' + IntToStr(FBAdmin1.Port));
    //Add('Transaction count:          ' + IntToStr(dm.fDatabase.TransactionCount));
    //Add('');
    //Add('Attached Database:');
    //Add(dm.fDatabase.DatabaseName);
    //Add(dm.fDatabase.Password);
    Add('');
    Add('List of users:');
    Users := TStringList.Create;
    try
      if FBAdmin1.GetUsers(Users) then
        Add(Trim(Users.Text))
      else
        Add('Sorry, could not get user list.');
    finally
      Users.Free;
    end;
    Add('');
    Add('Database log:');
    if FBAdmin1.GetDatabaseLog then
      AddStrings(FBAdmin1.Output)
    else
      Add('Could not get database log, sorry.');
  end;
end;

end.

