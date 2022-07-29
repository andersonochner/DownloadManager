object FormDownloadHistory: TFormDownloadHistory
  Left = 0
  Top = 0
  Caption = 'Hist'#243'rico de downloads'
  ClientHeight = 561
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gdDownloadHistory: TcxGrid
    Left = 0
    Top = 0
    Width = 784
    Height = 561
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 650
    ExplicitHeight = 375
    object gdDownloadHistoryDBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = datasource
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.ColumnAutoWidth = True
      object gdDownloadHistoryDBTableView1CODIGO: TcxGridDBColumn
        DataBinding.FieldName = 'CODIGO'
        BestFitMaxWidth = 50
        Width = 60
      end
      object gdDownloadHistoryDBTableView1URL: TcxGridDBColumn
        DataBinding.FieldName = 'URL'
      end
      object gdDownloadHistoryDBTableView1DATAINICIO: TcxGridDBColumn
        DataBinding.FieldName = 'DATAINICIO'
        PropertiesClassName = 'TcxDateEditProperties'
      end
      object gdDownloadHistoryDBTableView1DATAFIM: TcxGridDBColumn
        DataBinding.FieldName = 'DATAFIM'
        PropertiesClassName = 'TcxDateEditProperties'
      end
    end
    object gdDownloadHistoryLevel1: TcxGridLevel
      GridView = gdDownloadHistoryDBTableView1
    end
  end
  object connection: TSQLConnection
    ConnectionName = 'SQLITECONNECTION'
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Sqlite'
      'Database=DOWNLOADMANAGER.db')
    Connected = True
    Left = 448
    Top = 16
  end
  object datasource: TDataSource
    AutoEdit = False
    DataSet = query
    Left = 560
    Top = 16
  end
  object query: TSQLQuery
    Active = True
    MaxBlobSize = 1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM DOWNLOADLOG')
    SQLConnection = connection
    Left = 504
    Top = 16
  end
end
