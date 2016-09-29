## Objetivo de la validación del XML.
 
Este módulo tiene como objetivo asegurar que la Factura Electrónica recibida cumpla con las definiciones técnicas especificadas en las hojas de esquema.

Para poder validar sus archivos, requiere de que cuente con conexión a internet, ya que se realizan accesos a las direcciones especificadas dentro del documento XML.

Esta aplicación esta dirigida al departamento de soporte técnico en sistemas, al departamento contable y/o al departamento de auditoría interna.

### Riesgos a considerar.

-	El archivo de factura electrónica es un archivo editable (XML), que puede ser modificado en forma deliberada o accidental.
-	Las modificaciones no necesariamente son detectables a simple vista.
-	Las modificaciones pueden suceder aún después de haber validado su comprobante por cualquiera de los medios disponibles.
-	El Emisor, puede ser que no cuente con los elementos técnicos computacionales para poder emitir un documento completo.

### Beneficios

-	Esta utilería le sirve para revisar el contenido de sus archivos XML.
-	Facilita la revisión técnica del archivo, verificacion de esquemas, namespaces y referencias de busqueda por medio de prefijos.
-	Desmitificación del contenido de los archivos de Factura Electrónica.

### Program instructions.

- *This program uses basic libraries to read xml files, transform them with xsl templates and validate the document structure with a xsd definition file.*
- *Screens texts are in Spanish, due this project was developed to validate the Mexican Electronic Invoice*
- *It is necessary to modify the IneedXML.INI file to setup the user preferences*
- *Logos and images can be changed dynamically, or you can edit the hardcode section.*
- *In the UINeedValidate.pas line 218, modify the _URL_ where the banner image is stored, this allow you to change that image dynamically* 

Load the XML document to validate, then you can review the content and finally you can validate it.
*The Invoice (XML) should contain the reference for the valids XSD files

<code>
<?xml version="1.0" encoding="UTF-8"?><cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital" xsi:schemaLocation="http://www.sat.gob.mx/cfd/3 http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv32.xsd">

</code>
The process will present the screen in green color if the document matched with the xsd specified.

![Alt text](img/ineedvalidatescr01.jpg?raw=true "Valid document")

