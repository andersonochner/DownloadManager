program DownloadManager;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainFrm},
  WindowsDirectoryValidation in 'WindowsDirectoryValidation.pas',
  DirectoryValidation in 'DirectoryValidation.pas',
  MainFormDownloadController in 'MainFormDownloadController.pas',
  DownloadLog in 'DownloadLog.pas',
  DownloadLogDAO in 'DownloadLogDAO.pas',
  DownloadLogSQLiteDAO in 'DownloadLogSQLiteDAO.pas',
  FileDownloadThread in 'FileDownloadThread.pas',
  ObserverInterface in 'ObserverInterface.pas',
  FrmDownloadHistory in 'FrmDownloadHistory.pas' {FormDownloadHistory};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
