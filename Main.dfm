object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'https://servicodados.ibge.gov.br/api/docs/localidades'
  ClientHeight = 613
  ClientWidth = 494
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 494
    Height = 41
    Align = alTop
    Caption = 'pnlHeader'
    ShowCaption = False
    TabOrder = 0
    object btnProcessar: TButton
      Left = 409
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Processar'
      Enabled = False
      TabOrder = 0
      OnClick = btnProcessarClick
    end
  end
  object btnConectar: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Conectar DB'
    TabOrder = 1
    OnClick = btnConectarClick
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 41
    Width = 494
    Height = 531
    Align = alClient
    DataSource = dsEstados
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'ID'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NOME'
        Width = 200
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'QTD'
        Width = 80
        Visible = True
      end>
  end
  object pnlTotal: TPanel
    Left = 0
    Top = 572
    Width = 494
    Height = 41
    Align = alBottom
    Caption = '000'
    TabOrder = 3
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\Administrador\Documents\Embarcadero\Studio\Pro' +
        'jects\IBGE\Database\LOCALIDADES.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'CharacterSet=WIN1252'
      'DriverID=FB')
    ConnectedStoredUsage = [auDesignTime]
    LoginPrompt = False
    Left = 16
    Top = 8
  end
  object qryEstado: TFDQuery
    Connection = FDConnection
    Left = 16
    Top = 216
  end
  object qryMunicipio: TFDQuery
    Connection = FDConnection
    Left = 16
    Top = 64
  end
  object qryMesorregiao: TFDQuery
    Connection = FDConnection
    Left = 16
    Top = 168
  end
  object qryRegiao: TFDQuery
    Connection = FDConnection
    Left = 16
    Top = 272
  end
  object dstEstados: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 16
    Top = 328
    object dstEstadosID: TIntegerField
      FieldName = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object dstEstadosNOME: TStringField
      FieldName = 'NOME'
    end
    object dstEstadosQTD: TIntegerField
      DisplayLabel = 'QUANTIDADE'
      FieldName = 'QTD'
    end
  end
  object dsEstados: TDataSource
    AutoEdit = False
    DataSet = dstEstados
    Left = 64
    Top = 328
  end
  object qryMicrorregiao: TFDQuery
    Connection = FDConnection
    Left = 16
    Top = 120
  end
end
