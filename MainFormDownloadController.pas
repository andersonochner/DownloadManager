unit MainFormDownloadController;


interface

uses
  DownloadLog,
  DownloadLogDAO,
  ObserverInterface;

type
  TMainFormDownloadController = class
  protected
    fDownloadLogDAO : IDownloadLogDAO;
    fView : IObserver;

  public
    function InsertNewDownload(const DownloadLink : String) : TDownloadLog;
    procedure UpdateDownloadFinishTime(DownloadLog : TDownloadLog);

    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  FileDownloadThread,
  DownloadLogSQLiteDAO;

{ TMainFormDownloadController }

constructor TMainFormDownloadController.Create;
begin
//O fDownloadLogDAO poderia ser criado usando o padrão de projeto abstract factory para que decida qual DAO retornar.
//Aqui vou instanciar fixo com essa classe, mas vou deixar o atributo fDownloadLogDAO declarado generico.
  fDownloadLogDAO := TDownloadLogSQLiteDAO.Create;
end;

destructor TMainFormDownloadController.Destroy;
begin
  fDownloadLogDAO := nil;

  inherited;
end;

function TMainFormDownloadController.InsertNewDownload(const DownloadLink: String) : TDownloadLog;
var
  DownloadLog : TDownloadLog;
begin
  result := nil;
  DownloadLog := TDownloadLog.Create;
  try
    DownloadLog.URL := DownloadLink;
    DownloadLog.DataInicio := now;
    fDownloadLogDAO.AddNewDownload(DownloadLog);
    result := DownloadLog;
  except
    DownloadLog.Free;
  end;
end;

procedure TMainFormDownloadController.UpdateDownloadFinishTime(DownloadLog: TDownloadLog);
begin
  DownloadLog.DataFim := Now;
  fDownloadLogDAO.UpdateDownloadEndDate(DownloadLog);
end;

end.
