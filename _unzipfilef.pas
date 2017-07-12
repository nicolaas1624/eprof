unit _unzipfilef;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls, EditBtn;

type

  { Tunzipfilef }

  Tunzipfilef = class(TForm)
    CancelBtn: TBitBtn;
    OutputFolderBox: TDirectoryEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    OkBtn: TBitBtn;
    ZipFilenameBox: TFileNameEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure OkBtnClick(Sender: TObject);
  private
  public
  end;

var
  unzipfilef: Tunzipfilef;

implementation

uses zipper;

{$R *.lfm}

{ Tunzipfilef }

procedure Tunzipfilef.OkBtnClick(Sender: TObject);
var
  UnZipper: TUnZipper;
begin
  UnZipper := TUnZipper.Create;
  try
    Screen.Cursor := crHourglass;
    UnZipper.FileName := ZipFilenameBox.Text;
    UnZipper.OutputPath := OutputFolderBox.Text;
    UnZipper.Examine;
    UnZipper.UnZipAllFiles;
  finally
    UnZipper.Free;
    Screen.Cursor := crDefault;
  end;
end;

end.

