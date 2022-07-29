unit FrmDownloadHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DbxSqlite, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges,
  dxScrollbarAnnotations, Data.DB, cxDBData, Data.FMTBcd, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, Data.SqlExpr, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, cxCalendar;

type
  TFormDownloadHistory = class(TForm)
    connection: TSQLConnection;
    datasource: TDataSource;
    gdDownloadHistoryDBTableView1: TcxGridDBTableView;
    gdDownloadHistoryLevel1: TcxGridLevel;
    gdDownloadHistory: TcxGrid;
    query: TSQLQuery;
    gdDownloadHistoryDBTableView1CODIGO: TcxGridDBColumn;
    gdDownloadHistoryDBTableView1URL: TcxGridDBColumn;
    gdDownloadHistoryDBTableView1DATAINICIO: TcxGridDBColumn;
    gdDownloadHistoryDBTableView1DATAFIM: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDownloadHistory: TFormDownloadHistory;

implementation

{$R *.dfm}

procedure TFormDownloadHistory.FormShow(Sender: TObject);
begin
  gdDownloadHistoryDBTableView1.ApplyBestFit;
end;

end.
