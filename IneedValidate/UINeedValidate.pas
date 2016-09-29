unit UINeedValidate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ComCtrls, ExtCtrls, jpeg, IniFiles,
  ActiveX, MSXML2_TLB, XMLSchema, XMLDataToSchema, xmldom, XMLIntf, msxmldom,
  XMLDoc, Menus;

type
  TfrmIneedValidate = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    PgctlXML: TPageControl;
    tabXmlDoc: TTabSheet;
    tabDOM: TTabSheet;
    XMLDoc: TMemo;
    SbLoadFile: TSpeedButton;
    OpDlgXML: TOpenDialog;
    Label1: TLabel;
    lblFile: TLabel;
    Label2: TLabel;
    Image1: TImage;
    trvDOM: TTreeView;
    SpeedButton1: TSpeedButton;
    tabXSD: TTabSheet;
    MXSD: TMemo;
    TabData: TTabSheet;
    trvData: TTreeView;
    tabReadme: TTabSheet;
    RE_ReadMe: TRichEdit;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    Salir1: TMenuItem;
    CargarArchivo1: TMenuItem;
    procedure Salir1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SbLoadFileClick(Sender: TObject);
  private
    { Private declarations }
     iddXML  : IXMLDOMDocument2;
     iddXSL  : IXMLDOMDocument;
     idnNode : IXMLDOMNode;

  public
    { Public declarations }
    RazonSocial, RFC, TmpFiles,Dir_Unit,Dir_Recep,Dir_Sent : string;
  end;

var
  frmIneedValidate: TfrmIneedValidate;

implementation

uses URutinasXML, UHttpRutinas;

{$R *.dfm}

resourcestring
   sXMLFilter = 'Archivos XML (*.xml)|*.xml|Todos los archivos(*.*)|*.*';
   sXMLOpen   = 'Abrir archivo XML';
   sNoDOM = 'No se puede crear el DOM';
   sNoOutput  = 'Nothing generated by the transformation';

procedure TfrmIneedValidate.SbLoadFileClick(Sender: TObject);
var
  XMLDocument1: TXMLDocument;
  Prefidx : TStringList;
  i : integer;

begin
   if not OpDlgXML.Execute then
      exit;

   PgctlXML.ActivePage := tabXmlDoc;
   trvData.Color := clWindow;
   lblFile.Caption := OpDlgXML.FileName;
   XMLDoc.Lines.Clear;
   XMLDoc.Lines.LoadFromFile(lblFile.Caption);

   {
      Load XML File
      y Definiciones Tecnicas
   }
   ClearTreeView(trvDOM);
   if not iddXML.load(OpDlgXML.FileName) then
      MessageDlg(iddXML.parseError.reason,mtError, [mbOK], 0 )
   else
   begin
      LoadElements(iddXML, nil, '',trvDOM);
      trvDOM.Items[0].Expand(True);
      trvDOM.TopItem := trvDOM.Items[0];
      treeDOMChange(trvDOM.Items[0]);
      trvDOM.FullExpand;
      trvDOM.Selected := trvDOM.Items.GetFirstNode;

      MXSD.Lines.Clear;

   {
      Despliega los datos Codificados en el XML
   }
   XMLDocument1 := TXMLDocument.Create(Self);
   try
      Prefidx := TStringList.Create;
      Prefidx.Sorted := true;
      Prefidx.Duplicates := dupIgnore;
      Prefidx.CaseSensitive := False;

      XMLDocument1.LoadFromFile(lblFile.Caption);
      ClearTreeView(trvData);
      DomToTree(XMLDocument1.DocumentElement ,nil,trvData,Prefidx);
      trvData.FullExpand;
      trvData.Selected := trvData.Items.GetFirstNode;
      {
         Name Space, Prefijos de NameSpaces y Schema
      }
      if Prefidx.Count > 0 then
      begin
         MXSD.Lines.Add('------- Referencia Esquema -------');
         for i := 0 to Prefidx.Count -1 do
            if AnsiPos('schemalocation',Ansilowercase(Prefidx.Strings[i])) <> 0 then
               MXSD.Lines.Add('Esquema: '+ Prefidx.Strings[i]);
      end;
      if Prefidx.Count > 0 then
      begin
         MXSD.Lines.Add('------- Prefijos NameSpace -------');
         for i := 0 to Prefidx.Count -1 do
            if ( AnsiPos('schemalocation',Ansilowercase(Prefidx.Strings[i])) = 0  ) and
               ( AnsiPos('xmlns',Ansilowercase(Prefidx.Strings[i])) = 0  ) then
               MXSD.Lines.Add('Prefijo: '+ Prefidx.Strings[i]);
      end;
      if Prefidx.Count > 0 then
      begin
         MXSD.Lines.Add('------- NameSpace XML -------');
         for i := 0 to Prefidx.Count -1 do
            if ( AnsiPos('schemalocation',Ansilowercase(Prefidx.Strings[i])) = 0 ) and
               ( ( AnsiPos('xmlns:',Ansilowercase(Prefidx.Strings[i])) <> 0 ) or
                 ( AnsiPos('xmlns=',Ansilowercase(Prefidx.Strings[i])) <> 0 ) ) then
               MXSD.Lines.Add('Namespace: ' + Prefidx.Strings[i]);
      end;


   finally
      XMLDocument1.Free;
      if Assigned(Prefidx) then Prefidx.Free;
   end;

      {
        Carga de definiciones de los NameSpaces
        Se ponen al final para facilitar la busqueda en el armado
        de la secuencia schema.add
      }
      MXSD.Lines.Add('------- NameSpace DOM -------');
      for i := 0 to iddXML.namespaces.length -1 do
      begin
         MXSD.Lines.Add(iddXML.namespaces.namespaceURI[i]);
      end;

   end; // End Load XML
   PgctlXML.ActivePage := TabData;

end;

procedure TfrmIneedValidate.FormShow(Sender: TObject);
var
  jIco, JImage : string;
  IneedXMLIni : TiniFile;

  internetFile, localFilename : string;
  urlImage : TJpegImage;
begin

   // Datos de la Empresa
   jIco := ExtractFilePath(Application.ExeName) + 'validate.ico';
   if FileExists(jIco) then
      frmIneedValidate.Icon.LoadFromFile(jIco);

   JImage := ExtractFilePath(Application.ExeName) + 'companyLogo.jpg';
    if FileExists(JImage) then
       frmIneedValidate.Image1.Picture.LoadFromFile(JImage);

   OpDlgXML.Filter := sXMLFilter;
   OpDlgXML.Title := sXMLOpen;
   OpDlgXML.InitialDir := ExtractFilePath(Application.ExeName);

    {
     Verifica existencia de archivo INI
    }
    IneedXMLINI := TiniFile.Create(ExtractFilePath(Application.ExeName) + 'IneedXML.INI');

    try
    { Obtiene la configuracion }
    RazonSocial := IneedXMLIni.ReadString('COMPANY','Nombre','');
    RFC := IneedXMLIni.ReadString('COMPANY','RFC','');
    Tmpfiles := IneedXMLIni.ReadString('ARCHIVE','tempo','');
    Dir_Unit := IneedXMLIni.ReadString('ARCHIVE','RUTA','');
    Dir_Recep := IneedXMLIni.ReadString('ARCHIVE','RUTA_RECEP','');
    Dir_Sent := IneedXMLIni.ReadString('ARCHIVE','RUTA_SENT','');

    finally
       IneedXMLIni.Free;
    end;

    if FileExists(ExtractFilePath(Application.ExeName) + 'Readme.rtf') then
       RE_ReadMe.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Readme.rtf');

    if IsConnectedToInternet then
    begin
       {
          Obtencion de Publicidad Internet
       }
       internetFile := 'http://myurl.com/logistica/publicity/pub_banner.jpg';
       localFileName := 'banner.jpg';

       if GetInetFile(internetFile, localFileName) then
       begin
          JImage := ExtractFilePath(Application.ExeName) + 'banner.jpg';
          if FileExists(JImage) then
             frmIneedValidate.Image1.Picture.LoadFromFile(JImage);
       end;
    end;

   PgctlXML.ActivePage := tabReadme;

end;

procedure TfrmIneedValidate.FormDestroy(Sender: TObject);
begin
  ClearTreeView(trvDOM);
  idnNode := nil;
  iddXML := nil;
  iddXSL := nil;

end;

procedure TfrmIneedValidate.FormCreate(Sender: TObject);
var
   hRes : HResult;
begin

  { Inicializa the DOMs }
  hRes := CoCreateInstance(CLASS_DOMDocument, nil,
         CLSCTX_INPROC_SERVER, IID_IXMLDOMDocument, iddXML);
  if hRes <> S_OK then
     raise Exception.Create(sNoDOM);

  hRes := CoCreateInstance(CLASS_DOMDocument, nil,
         CLSCTX_INPROC_SERVER, IID_IXMLDOMDocument, iddXSL);
  if hRes <> S_OK then
       raise Exception.Create(sNoDOM);

end;

procedure TfrmIneedValidate.SpeedButton1Click(Sender: TObject);
var
  DOMDocument: IXMLDOMDocument2;
  ParseError: IXMLDOMParseError;
  Schema: XMLSchemaCache60;

  targetNamespaceNode: IXMLDOMNode;

  i, posURI,posXSD : integer;
  strURI, strXSD : string;

  fl_Proc : boolean;

begin
  if lblFile.Caption = '' then
  begin
     ShowMessage('No hay archivo cargado para validar');
     exit;
  end;

  fl_Proc := False;
  MXSD.Lines.Add('------- Resultados de la Validación -------');

  try
     CoInitialize(Nil);

     DOMDocument := CoDOMDocument60.Create;

     DOMDocument.async := False;
     DOMDocument.resolveExternals := True;
     DOMDocument.validateOnParse := False;

     if DOMDocument.load(lblFile.Caption) then
        begin
        {
          Creacion de un esquema a partir del XML
        }
           Schema := CoXMLSchemaCache60.Create;
           {
              Obtrencion de valores de los Esquemas
              Definiciones en schemaLocation, en varias versiones en XML
              schemalocation=refhttp refhttp/xsd
           }
           strURI := '';
           strXSD := '';
           for i := 0 to DOMDocument.namespaces.length -1 do
           begin
              posURI := AnsiPos(DOMDocument.namespaces.namespaceURI[i],MXSD.Text);
              if posURI > 0 then
              begin
                 strURI := DOMDocument.namespaces.namespaceURI[i];
                 {
                   Se asume que la siguiente seccion contiene el xsd
                 }
                 strXSD := Copy(MXSD.Text,posURI+Length(strURI)+1,4);
                 if strXSD = 'http' then
                 begin
                    strXSD := Copy(MXSD.Text,posURI+Length(strURI)+1,Length(strURI)+80);
                    {
                      busca extension xsd
                    }
                    posXSD := AnsiPos('.xsd',strXSD);
                    if posXSD = 0 then
                       strXSD := ''
                    else
                       strXSD := Copy(strXSD,1,posXSD+4);
                    {
                       Adiciona el Schema
                    }
                    if ( Length(strURI) > 0 ) and ( Length(strXSD) > 0 )then
                    begin
                       Schema.add(strURI,strXSD);
                       MXSD.Lines.Add('Esquema adicionado: ' + strXSD);
//                       ShowMessage('Esquema adicionado: ' + strXSD);
                    end;
                 end;

              end;
           end;

           if Schema.length > 1 then
              DOMDocument.schemas := Schema;

           { Ejemplos de Schemas }
//           Schema.add('http://www.sat.gob.mx/cfd/3','http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv32.xsd');
//           Schema.add('http://www.sat.gob.mx/TimbreFiscalDigital','http://www.sat.gob.mx/sitio_internet/TimbreFiscalDigital/TimbreFiscalDigital.xsd');
//           Schema.add('http://repository.edicomnet.com/schemas/mx/cfd/addenda','http://repository.edicomnet.com/schemas/mx/cfd/addenda/Centel.xsd');


           ParseError := DOMDocument.validate;
           if(ParseError.errorCode = 0)
            then
              begin
                 MXSD.Lines.Add('Estructura validada');
//                 ShowMessage('Estructura validada');
                 fl_Proc := True;
              end
            else
              begin
//                 ShowMessage(String(ParseError.reason));
                 MXSD.Lines.Add(String(ParseError.reason));
              end;
        end
     else
        MXSD.Lines.Add('Documento No Validado : ' + lblFile.Caption);
//        ShowMessage('Documento No Validado : ' + lblFile.Caption);

  finally
     DOMDocument := nil;
     ParseError := nil;
     Schema := nil;
     targetNamespaceNode := nil;
     CoUninitialize;
  end;
  If fl_Proc then
  begin
     trvData.Color := $005BD79C;
     MXSD.Color := $005BD79C;
  end
  else
     begin
        trvData.Color := $0051A8FF;
        MXSD.Color := $0051A8FF;
     end;

  PgctlXML.ActivePage := tabXSD;

end;

procedure TfrmIneedValidate.Salir1Click(Sender: TObject);
begin
   Close;
end;

end.
