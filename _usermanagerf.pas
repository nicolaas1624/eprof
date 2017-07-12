unit _usermanagerf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, FBAdmin;

type

  { Tusermanagerf }

  Tusermanagerf = class(TForm)
    DeleteBtn: TToolButton;
    EditBtn: TToolButton;
    FBAdmin1: TFBAdmin;
    InsertBtn: TToolButton;
    lvUsers: TListView;
    ToolBar1: TToolBar;
    procedure DeleteBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure InsertBtnClick(Sender: TObject);
  private
    UserName, Password, RoleName, GroupName, FirstName, MiddleName, LastName: string;
    UserID, GroupID: longint;
    procedure DisplayUsers;
  public
  end;

var
  usermanagerf: Tusermanagerf;

implementation

uses _dm, _capusermanager, _global;

{$R *.lfm}

procedure Tusermanagerf.FormShow(Sender: TObject);
begin
  //FBAdmin1.UseExceptions := True;
  //FBAdmin1.Host := cnf.ServerName;
  //FBAdmin1.Protocol := IBSPTCPIP;  //IBSPLOCAL;
  //FBAdmin1.User := dm.IBDatabase1.Username;
  //FBAdmin1.Password := dm.IBDatabase1.Password;
  //FBAdmin1.Connect;
  DisplayUsers;
end;

procedure Tusermanagerf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FBAdmin1.DisConnect;
end;

procedure Tusermanagerf.InsertBtnClick(Sender: TObject);
begin
  CapUserManager := TCapUserManager.Create(Application);
  try
    CapUserManager.Caption := 'New User';
    if CapUserManager.ShowModal = mrOK then
    begin
      UserName := CapUserManager.UsernameBox.Text;
      Password := CapUserManager.PasswordBox.Text;
      RoleName := '';
      GroupName := '';
      FirstName := CapUserManager.FirstNameBox.Text;
      MiddleName := CapUserManager.MiddleNameBox.Text;
      LastName := CapUserManager.LastNameBox.Text;
      if FBAdmin1.AddUser(UserName, Password, RoleName, GroupName, FirstName, MiddleName, LastName, UserID, GroupID) then
      begin
        if CapUserManager.RoleBox.Text <> '' then
          dm.RunSQL('GRANT ' + CapUserManager.RoleBox.Text + ' TO ' + UserName)
        else
          dm.RunSQL('GRANT WATER TO ' + UserName);
        DisplayUsers;
      end
      else
        MessageDlg('Sorry, could not add user.', mtInformation, [mbOK], 0);
    end;
    finally
      FreeAndNil(CapUserManager);
    end;
end;

procedure Tusermanagerf.EditBtnClick(Sender: TObject);
var
  i: Integer;
begin
  if lvUsers.ItemIndex >= 0 then
  begin
    i := lvUsers.ItemIndex;
    CapUserManager := TCapUserManager.Create(Application);
    try
      CapUserManager.Caption := 'Edit User';
      CapUserManager.UsernameBox.Text := lvUsers.Items[lvUsers.ItemIndex].Caption;
      CapUserManager.FirstNameBox.Text := lvUsers.Items[lvUsers.ItemIndex].SubItems[0];
      CapUserManager.MiddleNameBox.Text := lvUsers.Items[lvUsers.ItemIndex].SubItems[1];
      CapUserManager.LastNameBox.Text := lvUsers.Items[lvUsers.ItemIndex].SubItems[2];
      CapUserManager.UsernameBox.ReadOnly := True;
      CapUserManager.UsernameBox.Color := clSkyBlue;
      CapUserManager.ActiveControl := CapUserManager.PasswordBox;
      if CapUserManager.ShowModal = mrOK then
      begin
        UserName := CapUserManager.UsernameBox.Text;
        Password := CapUserManager.PasswordBox.Text;
        RoleName := '';
        GroupName := '';
        FirstName := CapUserManager.FirstNameBox.Text;
        MiddleName := CapUserManager.MiddleNameBox.Text;
        LastName := CapUserManager.LastNameBox.Text;
        if FBAdmin1.ModifyUser(UserName, Password, RoleName, GroupName, FirstName, MiddleName, LastName, UserID, GroupID) then
        begin
          dm.RunSQL('REVOKE WATER FROM ' + UserName);
          dm.RunSQL('REVOKE FINANCE FROM ' + UserName);
          if CapUserManager.RoleBox.Text <> '' then
            dm.RunSQL('GRANT ' + CapUserManager.RoleBox.Text + ' TO ' + UserName)
          else
            dm.RunSQL('GRANT WATER TO ' + UserName);
          DisplayUsers;
          lvUsers.ItemIndex := i;
        end
        else
          MessageDlg('Sorry, could not update user.', mtInformation, [mbOK], 0);
      end;
      finally
        FreeAndNil(CapUserManager);
      end;
  end
  else
    MessageDlg('Select a user first.', mtConfirmation, [mbOk], 0);
end;

procedure Tusermanagerf.DeleteBtnClick(Sender: TObject);
begin
  if lvUsers.ItemIndex >= 0 then
  begin
    UserName := lvUsers.Items[lvUsers.ItemIndex].Caption;
    RoleName := '';
    if MessageDlg('Delete user ' + UserName + '?', mtWarning, [mbYes, mbNo], 0) = mrYes then
    begin
      if FBAdmin1.DeleteUser(UserName, RoleName) then
      begin
        DisplayUsers;
        lvUsers.ItemIndex := lvUsers.Items.Count - 1;
      end
      else
        MessageDlg('Sorry, could not delete user.', mtInformation, [mbOK], 0);
    end;
  end
  else
    MessageDlg('Select a user first.', mtConfirmation, [mbOk], 0);
end;

procedure Tusermanagerf.DisplayUsers;
var
  i: integer;
  Users: TStringList;
begin
  Users := TStringList.Create;
  try
    if FBAdmin1.GetUsers(Users) then
    begin
      lvUsers.Clear;
      for i := 0 to Users.Count - 1 do
      begin
        with lvUsers.Items.Add do
        begin
          FBAdmin1.GetUser(Users.Strings[i], GroupName, FirstName, MiddleName, LastName, UserID, GroupID);
          Caption := Users.Strings[i];
          SubItems.Add(FirstName);
          SubItems.Add(MiddleName);
          SubItems.Add(LastName);
        end;
      end;
    end
    else
      MessageDlg('Sorry, could not get user list.', mtInformation, [mbOK], 0);
  finally
    Users.Free;
  end;
end;

end.
