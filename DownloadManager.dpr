program DownloadManager;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainFrm},
  WindowsDirectoryValidation in 'WindowsDirectoryValidation.pas',
  DirectoryValidation in 'DirectoryValidation.pas',
  DownloadLog in 'DownloadLog.pas',
  DownloadLogDAO in 'DownloadLogDAO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
