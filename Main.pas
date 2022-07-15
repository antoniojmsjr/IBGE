unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  System.JSON, REST.Json, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, REST.JSon.Types, Vcl.Grids, Vcl.DBGrids;

type
  TfrmMain = class(TForm)
    FDConnection: TFDConnection;
    qryEstado: TFDQuery;
    qryMunicipio: TFDQuery;
    qryMesorregiao: TFDQuery;
    qryRegiao: TFDQuery;
    pnlHeader: TPanel;
    btnConectar: TButton;
    btnProcessar: TButton;
    DBGrid1: TDBGrid;
    dstEstados: TFDMemTable;
    dstEstadosID: TIntegerField;
    dstEstadosNOME: TStringField;
    dstEstadosQTD: TIntegerField;
    dsEstados: TDataSource;
    pnlTotal: TPanel;
    qryMicrorregiao: TFDQuery;
    procedure btnConectarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnProcessarClick(Sender: TObject);
  private
    { Private declarations }
    function ConsultarIBGE(const pEstadoID: Integer; out poMunicipiosJSON: string): Boolean;
    function ConsultarEstados(out poEstadosJSON: string): Boolean;
    procedure ProcessarEstado;
    procedure ProcessarLocalidade;
    procedure InsertMunicipio(const pMunicipio: TJSONObject; const pMicrorregiao: TJSONObject);
    procedure InsertMicrorregiao(const pMicrorregiao: TJSONObject; const pMesorregiao: TJSONObject);
    procedure InsertMesorregiao(const pMesorregiao: TJSONObject; const pEstado: TJSONObject);
    procedure InsertEstado(const pEstado: TJSONObject; const pRegiao: TJSONObject);
    procedure InsertRegiao(const pRegiao: TJSONObject);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.Generics.Collections;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  dstEstados.CreateDataSet;
  dstEstados.LogChanges := False;
end;

procedure TfrmMain.btnConectarClick(Sender: TObject);
begin
  FDConnection.Connected := False;
  FDConnection.Connected := True;
  btnProcessar.Enabled := True;
end;

procedure TfrmMain.btnProcessarClick(Sender: TObject);
begin
  ProcessarEstado;

  ProcessarLocalidade;
end;

function TfrmMain.ConsultarEstados(out poEstadosJSON: string): Boolean;
var
  lHttpRequest: TNetHTTPRequest;
  lHttpClient: TNetHTTPClient;
  lIHTTPResponse: IHTTPResponse;
begin
  Result := False;
  poEstadosJSON := '';

  lHttpRequest := nil;
  lHttpClient := nil;
  try
    lHttpClient := TNetHTTPClient.Create(nil);
    {$IFDEF VER330}
    lHttpClient.SecureProtocols := [];
    lHttpClient.SecureProtocols := [THTTPSecureProtocol.TLS1,
                                    THTTPSecureProtocol.TLS11,
                                    THTTPSecureProtocol.TLS12];
    {$ENDIF}
    lHttpRequest := TNetHTTPRequest.Create(nil);
    lHttpRequest.Client := lHttpClient;

    lHttpRequest.Client.Accept := 'application/json';
    lIHTTPResponse := lHttpRequest.Get('https://servicodados.ibge.gov.br/api/v1/localidades/estados');

    if (lIHTTPResponse.StatusCode = 200) then
    begin
      poEstadosJSON := lIHTTPResponse.ContentAsString;
      Result := True;
    end;
  finally
    lHttpRequest.Free;
    lHttpClient.Free;
  end;
end;

function TfrmMain.ConsultarIBGE(const pEstadoID: Integer;
  out poMunicipiosJSON: string): Boolean;
var
  lHttpRequest: TNetHTTPRequest;
  lHttpClient: TNetHTTPClient;
  lIHTTPResponse: IHTTPResponse;
begin
  Result := False;
  poMunicipiosJSON := '';

  lHttpRequest := nil;
  lHttpClient := nil;
  try
    lHttpClient := TNetHTTPClient.Create(nil);
    {$IFDEF VER330}
    lHttpClient.SecureProtocols := [];
    lHttpClient.SecureProtocols := [THTTPSecureProtocol.TLS1,
                                    THTTPSecureProtocol.TLS11,
                                    THTTPSecureProtocol.TLS12];
    {$ENDIF}
    lHttpRequest := TNetHTTPRequest.Create(nil);
    lHttpRequest.Client := lHttpClient;

    lHttpRequest.Client.Accept := 'application/json';
    lIHTTPResponse := lHttpRequest.Get(Format('https://servicodados.ibge.gov.br/api/v1/localidades/estados/%d/municipios', [pEstadoID]));

    if (lIHTTPResponse.StatusCode = 200) then
    begin
      poMunicipiosJSON := lIHTTPResponse.ContentAsString;
      Result := True;
    end;
  finally
    lHttpRequest.Free;
    lHttpClient.Free;
  end;
end;

procedure TfrmMain.InsertEstado(const pEstado: TJSONObject;
  const pRegiao: TJSONObject);
begin
  qryEstado.Unprepare;
  qryEstado.Close;

  qryEstado.SQL.Clear;
  qryEstado.SQL.Add('UPDATE OR INSERT INTO ESTADO(ID, NOME, SIGLA, REGIAO_ID)');
  qryEstado.SQL.Add('VALUES(:ID, :NOME, :SIGLA, :REGIAO_ID) MATCHING (ID)');

  qryEstado.Prepare;

  qryEstado.ParamByName('ID').AsInteger := pEstado.GetValue('id').AsType<Integer>;
  qryEstado.ParamByName('NOME').AsString := pEstado.GetValue('nome').AsType<string>;
  qryEstado.ParamByName('SIGLA').AsString := pEstado.GetValue('sigla').AsType<string>;
  qryEstado.ParamByName('REGIAO_ID').AsInteger := pRegiao.GetValue('id').AsType<Integer>;

  qryEstado.ExecSQL;
end;

procedure TfrmMain.InsertMesorregiao(const pMesorregiao: TJSONObject;
  const pEstado: TJSONObject);
begin
  qryMesorregiao.Unprepare;
  qryMesorregiao.Close;

  qryMesorregiao.SQL.Clear;
  qryMesorregiao.SQL.Add('UPDATE OR INSERT INTO MESORREGIAO(ID, NOME, ESTADO_ID)');
  qryMesorregiao.SQL.Add('VALUES(:ID, :NOME, :ESTADO_ID) MATCHING (ID)');

  qryMesorregiao.Prepare;

  qryMesorregiao.ParamByName('ID').AsInteger := pMesorregiao.GetValue('id').AsType<Integer>;
  qryMesorregiao.ParamByName('NOME').AsString := pMesorregiao.GetValue('nome').AsType<string>;
  qryMesorregiao.ParamByName('ESTADO_ID').AsInteger := pEstado.GetValue('id').AsType<Integer>;

  qryMesorregiao.ExecSQL;
end;

procedure TfrmMain.InsertMicrorregiao(const pMicrorregiao: TJSONObject;
  const pMesorregiao: TJSONObject);
begin
  qryMesorregiao.Unprepare;
  qryMesorregiao.Close;

  qryMesorregiao.SQL.Clear;
  qryMesorregiao.SQL.Add('UPDATE OR INSERT INTO MICRORREGIAO(ID, NOME, MESORREGIAO_ID)');
  qryMesorregiao.SQL.Add('VALUES(:ID, :NOME, :MESORREGIAO_ID) MATCHING (ID)');

  qryMesorregiao.Prepare;

  qryMesorregiao.ParamByName('ID').AsInteger := pMicrorregiao.GetValue('id').AsType<Integer>;
  qryMesorregiao.ParamByName('NOME').AsString := pMicrorregiao.GetValue('nome').AsType<string>;
  qryMesorregiao.ParamByName('MESORREGIAO_ID').AsInteger := pMesorregiao.GetValue('id').AsType<Integer>;

  qryMesorregiao.ExecSQL;
end;

procedure TfrmMain.InsertMunicipio(const pMunicipio: TJSONObject;
  const pMicrorregiao: TJSONObject);
begin
  qryMunicipio.Unprepare;
  qryMunicipio.Close;

  qryMunicipio.SQL.Clear;
  qryMunicipio.SQL.Add('UPDATE OR INSERT INTO MUNICIPIO(ID, NOME, MICRORREGIAO_ID)');
  qryMunicipio.SQL.Add('VALUES(:ID, :NOME, :MICRORREGIAO_ID) MATCHING (ID)');

  qryMunicipio.Prepare;

  qryMunicipio.ParamByName('ID').AsInteger := pMunicipio.GetValue('id').AsType<Integer>;
  qryMunicipio.ParamByName('NOME').AsString := pMunicipio.GetValue('nome').AsType<string>;
  qryMunicipio.ParamByName('MICRORREGIAO_ID').AsInteger := pMicrorregiao.GetValue('id').AsType<Integer>;

  qryMunicipio.ExecSQL;
end;

procedure TfrmMain.InsertRegiao(const pRegiao: TJSONObject);
begin
  qryRegiao.Unprepare;
  qryRegiao.Close;

  qryRegiao.SQL.Clear;
  qryRegiao.SQL.Add('UPDATE OR INSERT INTO REGIAO(ID, NOME, SIGLA)');
  qryRegiao.SQL.Add('VALUES(:ID, :NOME, :SIGLA) MATCHING (ID)');

  qryRegiao.Prepare;

  qryRegiao.ParamByName('ID').AsInteger := pRegiao.GetValue('id').AsType<Integer>;
  qryRegiao.ParamByName('NOME').AsString := pRegiao.GetValue('nome').AsType<string>;
  qryRegiao.ParamByName('SIGLA').AsString := pRegiao.GetValue('sigla').AsType<string>;

  qryRegiao.ExecSQL;
end;

procedure TfrmMain.ProcessarLocalidade;
var
  lJSON: string;
  lMunicipios: TJSONArray;
  lMunicipio: TJSONObject;
  lMesorregiao: TJSONObject;
  lMicrorregiao: TJSONObject;
  lEstado: TJSONObject;
  lRegiao: TJSONObject;
  I: Integer;
  lQTD: Integer;
begin
  lQTD := 0;
  dstEstados.First;
  while not dstEstados.Eof do
  begin  
    
    if not ConsultarIBGE(dstEstadosID.AsInteger, lJSON) then
      Continue;
  
    lMunicipios := TJSONObject.ParseJSONValue(lJSON) as TJSONArray;

    dstEstados.Edit;
    dstEstadosQTD.AsInteger := lMunicipios.Count;
    lQTD := (lQTD + dstEstadosQTD.AsInteger);
    pnlTotal.Caption := IntToStr(lQTD);
    dstEstados.Post;
    
    Application.ProcessMessages;
    try
      for I := 0 to Pred(lMunicipios.Count) do
      begin
  
        lMunicipio := lMunicipios.Items[I] as TJSONObject;

        lMicrorregiao := lMunicipio.GetValue<TJSONObject>('microrregiao');
        lMesorregiao := lMicrorregiao.GetValue<TJSONObject>('mesorregiao');
        lEstado := lMesorregiao.GetValue<TJSONObject>('UF');
        lRegiao := lEstado.GetValue<TJSONObject>('regiao');
  
        FDConnection.StartTransaction;
        try
          InsertRegiao(lRegiao);
          InsertEstado(lEstado, lRegiao);
          InsertMesorregiao(lMesorregiao, lEstado);
          InsertMicrorregiao(lMicrorregiao, lMesorregiao);
          InsertMunicipio(lMunicipio, lMicrorregiao);
  
          FDConnection.Commit;
        except
          FDConnection.Rollback;
          raise;
        end;
      end;
    finally
      lMunicipios.Free;
    end;

    Application.ProcessMessages;
    dstEstados.Next;  
  end;
end;

procedure TfrmMain.ProcessarEstado;
var
  lJSON: string;
  lEstados: TJSONArray;
  lEstado: TJSONObject;
  I: Integer;
begin
  if not ConsultarEstados(lJSON) then
    Exit;

  dstEstados.EmptyDataSet;
  
  lEstados := TJSONObject.ParseJSONValue(lJSON) as TJSONArray;
  try
    for I := 0 to Pred(lEstados.Count) do
    begin
      lEstado := lEstados.Items[I] as TJSONObject;
    
      dstEstados.AppendRecord([
        lEstado.GetValue<Integer>('id'),
        lEstado.GetValue<string>('nome'),
        0]);
    end;
  finally
    lEstados.Free;
  end;  
end;

end.
