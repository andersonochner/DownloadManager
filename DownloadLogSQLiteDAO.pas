unit DownloadLogSQLiteDAO;

interface

uses
  DownloadLogDAO, DownloadLog, Generics.Collections, Uni, Data.SqlExpr;

type
  TDownloadLogSQLiteDAO = class(TInterfacedObject, IDownloadLogDAO)

  private

  protected
    fconnection : TSqlConnection;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddNewDownload(downloadLog : TDownloadLog);
    procedure UpdateDownloadEndDate(downloadLog : TDownloadLog);
    procedure Connect;

    function ListDownloads : TOBjectList<TDownloadLog>;
    function ConvertDateTimeToSQLiteText(DateTime : TDateTime) : String;
  end;

implementation

uses
  System.AnsiStrings, Vcl.Forms, Sysutils;

const
  CNT_DATABASENAME = 'DOWNLOADMANAGER.DB';
  CNT_SQLITEDATETIMEFORMAT = 'YYYY-MM-DD HH:MM:SS';


{ TDownloadLogSQLiteDAO }

procedure TDownloadLogSQLiteDAO.AddNewDownload(downloadLog: TDownloadLog);
var
  SqlQuery : TSQLQuery;
begin
  try
    Connect;

    SqlQuery := TSQLQuery.Create(nil);
    try
      SqlQuery.SQLConnection := fconnection;
      SqlQuery.SQL.Add('INSERT INTO DOWNLOADLOG (URL, DATAINICIO) ');
      SqlQuery.SQL.Add('VALUES(:pURL, :pDataInicio ) ');
      SqlQuery.SQL.Add('RETURNING CODIGO');
      SqlQuery.ParamByName('pUrl').AsString := downloadLog.URL;
      SqlQuery.ParamByName('pDataInicio').AsString := ConvertDateTimeToSQLiteText(downloadLog.DataInicio);
      SqlQuery.Open;
      if   not SqlQuery.EOF then
           downloadLog.Codigo := SqlQuery.FieldByName('Codigo').asinteger;
    finally
      SqlQuery.Free;
    end;
  except
    On E: Exception do
       E.Message := 'Não foi possível gravar o histórico. Código do erro:'+#13#10+
                     E.Message;
  end;
end;

procedure TDownloadLogSQLiteDAO.Connect;
begin
  if   not Assigned(fconnection) then
       begin
         fConnection := TSQLConnection.Create(nil);
         fConnection.KeepConnection := true;
         fConnection.LoginPrompt := false;
         fConnection.DriverName := 'Sqlite';
         fConnection.Params.Values['Database'] := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName))+CNT_DATABASENAME;
       end;

  if   Assigned(fconnection)
  and  not fconnection.Connected then
       fconnection.Connected := true;
end;

function TDownloadLogSQLiteDAO.ConvertDateTimeToSQLiteText(
  DateTime: TDateTime): String;
begin
  result := FormatDateTime(CNT_SQLITEDATETIMEFORMAT, DateTime);
end;

constructor TDownloadLogSQLiteDAO.Create;
begin
  fconnection := nil;
end;

destructor TDownloadLogSQLiteDAO.Destroy;
begin
  fconnection.Free;
  inherited;
end;

function TDownloadLogSQLiteDAO.ListDownloads: TObjectList<DownloadLog.TDownloadLog>;
begin
  result := nil;
end;

procedure TDownloadLogSQLiteDAO.UpdateDownloadEndDate(
  downloadLog: TDownloadLog);
var
  SqlQuery : TSQLQuery;
begin
  try
    Connect;

    SqlQuery := TSQLQuery.Create(nil);
    try
      SqlQuery.SQLConnection := fconnection;
      SqlQuery.SQL.Add('UPDATE DOWNLOADLOG ');
      SqlQuery.SQL.Add('SET DATAFIM = :pDataFim');
      SqlQuery.SQL.Add('WHERE CODIGO = :pCodigo');
      SqlQuery.ParamByName('pDataFim').AsString := ConvertDateTimeToSQLiteText(downloadLog.DataFim);
      SqlQuery.ParamByName('pCodigo').AsInteger := downloadLog.Codigo;
      SqlQuery.ExecSQL;
    finally
      SqlQuery.Free;
    end;
  except
    On E: Exception do
       E.Message := 'Não foi possível gravar o histórico. Código do erro:'+#13#10+
                     E.Message;
  end;
end;

end.
