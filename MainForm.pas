unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ImgList, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Data.DbxSqlite, Data.DB, Data.SqlExpr, Data.FMTBcd, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, DirectoryValidation, ObserverInterface, DownloadLog, MainFormDownloadController,
  FileDownloadThread;

type
  TMainFrm = class(TForm, ObserverInterface.IObserver)
    pnlTop: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edDownloadLink: TEdit;
    btnDownload: TBitBtn;
    edDownloadedFileDirectory: TButtonedEdit;
    imgListIcones: TImageList;
    pnlCenter: TPanel;
    pnlProgress: TPanel;
    pbDownloadProgress: TProgressBar;
    btnCancelDownload: TButton;
    Label3: TLabel;
    btnShowProgressMessage: TButton;
    btnShowDownloadHistory: TButton;
    procedure btnDownloadClick(Sender: TObject);
    procedure edDownloadedFileDirectoryRightButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelDownloadClick(Sender: TObject);
    procedure btnShowProgressMessageClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnShowDownloadHistoryClick(Sender: TObject);

  private
    fDownloadController : TMainFormDownloadController;
    fRunningDownloadLog : TDownloadLog;
    fRunningDownloadThread : TFileDownloadThread;
    fCurrentDownloadProgress : Integer;
    function getDownloadController: TMainFormDownloadController;

  protected
    fDirectoryValidation : IDirectoryValidation;
    procedure UpdateProgressControls;
    procedure UpdateProgress(Progress : Integer);
    procedure ResetProgressPanel;
    procedure ShowProgressPanel;
    procedure StartDownload;
    procedure CancelDownload;
    procedure OnDownloadThreadTerminate(Sender : TObject);

    function QueryDirectoryPath(out Path : String) : Boolean;
    function ValidateDownloadLink(const DownloadLink : String) : Boolean;
    function DownloadInProgress : Boolean;

    property DownloadController : TMainFormDownloadController read getDownloadController;

  public
    destructor Destroy; override;
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  System.IOUtils, Vcl.FileCtrl, WindowsDirectoryValidation,
  FrmDownloadHistory;

{$R *.dfm}

procedure TMainFrm.btnCancelDownloadClick(Sender: TObject);
begin
  CancelDownload;
end;

procedure TMainFrm.btnDownloadClick(Sender: TObject);
begin
  StartDownload;
end;

procedure TMainFrm.btnShowDownloadHistoryClick(Sender: TObject);
var
  frmDownloadHistory : TFormDownloadHistory;
begin
  frmDownloadHistory := TFormDownloadHistory.Create(self);
  try
    frmDownloadHistory.ShowModal
  finally
    frmDownloadHistory.Free;
  end;
end;

procedure TMainFrm.btnShowProgressMessageClick(Sender: TObject);
begin
  Application.MessageBox(PWideChar(Format('Progresso Atual: %d %%', [fCurrentDownloadProgress])),'Informações do Download', MB_OK + MB_ICONINFORMATION);
end;

procedure TMainFrm.CancelDownload;
begin
  if   DownloadInProgress then
       begin
         fRunningDownloadThread.CancelDownload;
         ResetProgressPanel;
       end;
end;

destructor TMainFrm.Destroy;
begin
  fDownloadController.Free;
  inherited;
end;

function TMainFrm.DownloadInProgress: Boolean;
begin
  result := Assigned(fRunningDownloadThread);
end;

procedure TMainFrm.edDownloadedFileDirectoryRightButtonClick(Sender: TObject);
var
  directoryPath : String;
begin
  if   QueryDirectoryPath(directoryPath) then
       edDownloadedFileDirectory.Text := directoryPath;
end;

procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if   DownloadInProgress then
       CanClose := Application.MessageBox('Existe um download em andamento, deseja interrompe-lo?', 'Download em andamento', MB_YESNO + MB_ICONQUESTION) = ID_YES;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  fDownloadController := nil;
//Se houvesse uma lógica para cada S.O, essa interface viria por injeção de dependência, ou alguma outra forma
//Separei em uma classe separada para poder usar as funções do delphi de manipulação de diretórios que são exclusivas pra windows.
  fDirectoryValidation := TWindowsDirectoryValidation.Create;
  fRunningDownloadLog := nil;
  fCurrentDownloadProgress := 0;
end;

function TMainFrm.getDownloadController: TMainFormDownloadController;
begin
  if   not Assigned(fDownloadController) then
       fDownloadController := TMainFormDownloadController.Create;
  result := fDownloadController;
end;

procedure TMainFrm.OnDownloadThreadTerminate(Sender: TObject);
begin
  fRunningDownloadThread := nil;
end;

function TMainFrm.QueryDirectoryPath(out Path: String): Boolean;
begin
  try
    result := SelectDirectory('Diretório de salvamento', GetEnvironmentVariable('HOMEPATH'), Path);
  except
    On e: Exception do
       begin
         e.Message := Format('O diretório selecionado não pode ser utilizado. Favor selecionar outro caminho para o salvamento.'+#13+#10+
                      'Descrição do erro: %s', [E.Message]);
         raise;
       end;
  end;
end;

procedure TMainFrm.ResetProgressPanel;
begin
  pnlProgress.Visible := false;
  btnCancelDownload.Visible := True;
  pbDownloadProgress.Position := 0;
end;

procedure TMainFrm.ShowProgressPanel;
begin
  pnlProgress.Visible := true;
end;

procedure TMainFrm.StartDownload;
begin
  ResetProgressPanel;
  if   fDirectoryValidation.ValidateDirectory(edDownloadedFileDirectory.Text) then
       begin
         if  (ValidateDownloadLink(edDownloadLink.Text)) then
              begin
                fRunningDownloadLog := DownloadController.InsertNewDownload(edDownloadLink.Text);
                fRunningDownloadThread := TFileDownloadThread.Create(edDownloadedFileDirectory.Text, edDownloadLink.Text);
                fRunningDownloadThread.AddObserver(Self);
                fRunningDownloadThread.Start;
                fRunningDownloadThread.OnTerminate := OnDownloadThreadTerminate;
                ShowProgressPanel;
              end
         else Application.MessageBox('Informe um link de download', 'Link de Download', MB_OK + MB_ICONERROR);
       end
  else Application.MessageBox('O diretório informado não pode ser usado para salvamento. Favor selecionar outro diretório', 'Diretório de salvamento', MB_OK + MB_ICONERROR);
end;

procedure TMainFrm.UpdateProgressControls;
begin
  if  (fCurrentDownloadProgress = 100)
  and (Assigned(fRunningDownloadLog)) then
       begin
         fDownloadController.UpdateDownloadFinishTime(fRunningDownloadLog);
         pbDownloadProgress.Position := 100;
         FreeAndNil(fRunningDownloadLog);
         ResetProgressPanel;
         ShowMessage('Download Concluído');
       end
  else
       if   fCurrentDownloadProgress > 0 then
            begin
              Application.ProcessMessages;
              pbDownloadProgress.Position := fCurrentDownloadProgress;
              if   fCurrentDownloadProgress = 100 then
                   btnCancelDownload.Visible := false;
            end;
end;

procedure TMainFrm.UpdateProgress(Progress: Integer);
begin
//meu XE3 não suporta métodos anônimos.
  fCurrentDownloadProgress := Progress;
  TThread.Synchronize(nil, UpdateProgressControls);
end;

function TMainFrm.ValidateDownloadLink(const DownloadLink: String): Boolean;
begin
  result := not SameText(DownloadLink, EmptyStr);
end;

end.
