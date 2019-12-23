import { Component, OnInit, ViewChild } from '@angular/core';
import { MenuItem, LazyLoadEvent, MessageService } from 'primeng/api';

import { ProcesarDocumentosElectronicosService } from '../services/procesar-documentos-electronicos.service';
import { EstadosService } from '../services/estados.service';
import { CciTipocmprService } from '../services/cci-tipocmpr.service';
import { EmpresasService } from '../services/empresas.service';

import { environment } from '../../environments/environment';

import { Observable } from 'rxjs';

import ITB_FAC_DOCUMENTOS from '../model/ITB_FAC_DOCUMENTOS';
import IEstados from '../model/IEstados';
import ICCI_TIPOCMPR from '../model/ICCI_TIPOCMPR';
import ITB_SEG_EMPRESA from '../model/ITB_SEG_EMPRESA';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { takeWhile } from 'rxjs/operators';
//import IMensaje from '../model/IMensaje';

@Component({
  selector: 'app-procesar-documentos-electronicos',
  templateUrl: './procesar-documentos-electronicos.component.html',
  styleUrls: ['./procesar-documentos-electronicos.component.css']
})
export class ProcesarDocumentosElectronicosComponent implements OnInit {
  @ViewChild('dt', { static: false, }) dt: any;
  grades: any[];
  //empresas: any[];
  tipo: any[];
  filtering() {
    //alert('fffff');
    this.dt.reset();
  }

  cols: any[];
  docs: any[];
  items: MenuItem[];
  documentos: ITB_FAC_DOCUMENTOS[];
  //selectedDocumentos: ITB_FAC_DOCUMENTOS[];
  documento: ITB_FAC_DOCUMENTOS = {};
  estados: IEstados[];
  empresas: ITB_SEG_EMPRESA[];
  cci_tipocmpr: ICCI_TIPOCMPR[];
  //mensaje: IMensaje = {};
  first = 0;
  //totalRecords: number;

  totalRecords$: Observable<number>;

  txtDocumento: string;
  txtTipocmpr: any;
  txtEmpresa: any;
  txtEstado: any;

  documentosSeleccionados: any[];

  url = environment.baseUrl;
  displayDialogEmail: boolean;
  displayDialogAddEmail: boolean;

  emails: any[];
  colsEmail: any[];
  form: FormGroup;

  constructor(
    private procesarDocumentosElectronicosService: ProcesarDocumentosElectronicosService,
    private estadosService: EstadosService,
    private cciTipoCmprService: CciTipocmprService,
    private empresasService: EmpresasService,
    private fb: FormBuilder,
    private messageService: MessageService
  ) { }

  ngOnInit() {

    this.inicializarPantalla();

  }

  inicializarPantalla() {
    this.buildFormAddMail();
    this.txtDocumento = '';
    this.documentosSeleccionados = [];

    this.cols = [
      {
        field: 'cci_empresa',
        header: 'Empresa',
        filterMatchMode: 'in',
        width: '20%'
      },
      {
        field: 'cci_tipocmpr',
        header: 'Tipo',
        filterMatchMode: 'in',
        width: '20%'
      },
      {
        field: 'nci_documento',
        header: 'Documento',
        filterMatchMode: 'contains',
        width: '15%'
      },
      {
        field: 'ces_fe',
        header: 'Estado',
        filterMatchMode: 'in',
        width: '15%'
      },
      {
        field: 'pdf',
        header: 'PDF',
        width: '9em'
      }
    ];

    this.items = [
      {
        label: 'Solo Procesar', icon: 'pi pi-cog', command: () => {
          console.log('update');
          alert('update');
        }
      },
      {
        label: 'Solo enviar Mail', icon: 'fa fa-envelope', command: () => {
          console.log('delete');
          alert('delete');
        }
      }
    ];

    /*this.grades = [];
    this.grades.push({ label: 'ACTIVO', value: 'ACTIVO' });
    this.grades.push({ label: 'INACTIVO', value: 'INACTIVO' });
    */
    /*
    this.empresas = [];
    this.empresas.push({ label: 'GLOBALTEX', value: '008' });
    this.empresas.push({ label: 'TEXFASHION', value: '009' });
    this.empresas.push({ label: 'PASSARELA', value: '012' });
    */

    /*this.tipo = [];
    this.tipo.push({ label: 'FACTURA', value: 'FAC' });
    this.tipo.push({ label: 'NOTA DE CREDITO', value: 'NC' });
    this.tipo.push({ label: 'RETENCION', value: 'RET' });
    this.tipo.push({ label: 'GUIA', value: 'GUI' });
    */

    this.estadosService.getEstados().subscribe(
      data => {
        this.estados = data;
        //this.selectedMultipleEstadoFilter = { label: "ACTIVO", value: "A" };
        console.log(this.estados);
      }
    )

    this.cciTipoCmprService.getTipoDocumentos().subscribe(
      data => {
        this.cci_tipocmpr = data;
        //this.selectedMultipleEstadoFilter = { label: "ACTIVO", value: "A" };
        console.log(this.cci_tipocmpr);
      }
    )


    const postData = new FormData();
    postData.append('action', 'getEmpresas');

    this.empresasService.getEmpresas(postData).subscribe(
      data => {
        //alert(data);

        //this.totalRecords$ = this.mantenimientoUsuarioService.getTotalRecords();
        this.totalRecords$ = this.procesarDocumentosElectronicosService.getTotalRecords();
        this.empresas = data;
        //console.log(this.perfiles);
        console.log(data);
      },
      error => {
        //this.displayWait = false;
        //this.errorMsg = error;
        //console.log(this.errorMsg);

        //this.displayWait = false;
        //this.displayMensaje = true;
        //this.tipoMensaje = 'ERROR';
      }
    );
  }

  loadLazy(event: LazyLoadEvent) {
    console.log(event);
    console.log(event.filters);


    const postData = new FormData();
    //alert(event.first.toString());
    //alert(event.rows.toString());
    postData.append('start', event.first.toString());
    postData.append('limit', event.rows.toString());

    if (event.sortField) {
      postData.append('sortField', event.sortField);
      postData.append('sortOrder', event.sortOrder.toString());
    }



    postData.append('filters', JSON.stringify(event.filters));
    postData.append('action', 'getDocumentos');

    this.procesarDocumentosElectronicosService.getDocumentos(postData).subscribe(
      data => {

        //alert(data);

        //this.totalRecords$ = this.mantenimientoUsuarioService.getTotalRecords();
        //this.documentos = data;
        //console.log(this.perfiles);

        //if (this.documentosSeleccionados.length == 0) {
        this.documentos = data;
        //}

        this.marcarDocumentos(this.documentos)

        console.log(data);
      },
      error => {
        //this.displayWait = false;
        //this.errorMsg = error;
        //console.log(this.errorMsg);

        //this.displayWait = false;
        //this.displayMensaje = true;
        //this.tipoMensaje = 'ERROR';
      }
    );


    /*this.totalRecords = 10;
    this.procesarDocumentosElectronicosService.getDocumentos(event).subscribe(
      data => {
        this.documentos = data;
        console.log(this.documentos);
      }
    );*/
  }


  marcarDocumentos(documentos) {
    this.documentosSeleccionados.forEach(function (documento, index) {
      documentos.forEach(function (data1, index1) {
        if (data1['cci_empresa'] == documento['cci_empresa']
          && data1['cci_sucursal'] == documento['cci_sucursal']
          && data1['cci_tipocmpr'] == documento['cci_tipocmpr']
          && data1['nci_documento'] == documento['nci_documento']) {
          alert('encontrado');
          console.log(data1);
          data1['check'] = true;
          console.log(data1);
        }
      });

      //this.documentos = data;
    }

    );

  }

  save() {
    alert('save');

  }

  resetFilter() {
    this.dt.reset();
    this.txtDocumento = '';
    this.txtTipocmpr = '';
    this.txtEmpresa = '';
    this.txtEstado = '';
  }

  imprimirDocumento(documento: ITB_FAC_DOCUMENTOS) {
    let imprimirDocumento = [];
    this.documento = this.cloneRegistro(documento);
    //alert(this.documento.cci_empresa);
    //alert(this.documento.ambiente);

    imprimirDocumento.push({
      "cci_empresa": this.documento.cci_empresa,
      "cci_sucursal": this.documento.cci_sucursal,
      "cci_tipocmpr": this.documento.cci_tipocmpr,
      "nci_documento": this.documento.nci_documento,
      "ces_fe": this.documento.ces_fe,
      "ambiente": this.documento.ambiente,
      "opcion": 'P'
    });

    console.log(imprimirDocumento);

    const postData = new FormData();

    postData.append('json', JSON.stringify(imprimirDocumento));
    postData.append('action', 'generarProcesoFE');

    this.procesarDocumentosElectronicosService.imprimirDocumento(postData).subscribe(

      data => {
        //alert(data.mensaje);

        //this.totalRecords$ = this.mantenimientoUsuarioService.getTotalRecords();
        //this.documentos = data;
        //console.log(this.perfiles);
        console.log(data);

        window.open(this.url + 'descargas/' + data.mensaje, '_blank');

        /*
        if (data.mensaje2 != '') {
          window.open(this.url + 'descargas/' + data.mensaje2, '_blank');
        }
        */
      },
      error => {
        //this.displayWait = false;
        //this.errorMsg = error;
        //console.log(this.errorMsg);

        //this.displayWait = false;
        //this.displayMensaje = true;
        //this.tipoMensaje = 'ERROR';
      }
    );
  }

  procesarDocumento(documento: ITB_FAC_DOCUMENTOS) {
    let procesarDocumento = [];
    this.documento = this.cloneRegistro(documento);
    //alert(this.documento.cci_empresa);
    //alert(this.documento.ambiente);

    procesarDocumento.push({
      "cci_empresa": this.documento.cci_empresa,
      "cci_sucursal": this.documento.cci_sucursal,
      "cci_tipocmpr": this.documento.cci_tipocmpr,
      "nci_documento": this.documento.nci_documento,
      "ces_fe": this.documento.ces_fe,
      "ambiente": this.documento.ambiente,
      "opcion": 'T'
    });

    console.log(procesarDocumento);

    const postData = new FormData();

    postData.append('json', JSON.stringify(procesarDocumento));
    postData.append('action', 'generarProcesoFE');

    this.procesarDocumentosElectronicosService.imprimirDocumento(postData).subscribe(

      data => {
        //alert(data.mensaje);

        //this.totalRecords$ = this.mantenimientoUsuarioService.getTotalRecords();
        //this.documentos = data;
        //console.log(this.perfiles);
        console.log(data);

        //window.open(this.url + 'descargas/' + data.mensaje, '_blank');

        //if (data.mensaje2 != '') {
        //  window.open(this.url + 'descargas/' + data.mensaje2, '_blank');
        //}
      },
      error => {
        //this.displayWait = false;
        //this.errorMsg = error;
        //console.log(this.errorMsg);

        //this.displayWait = false;
        //this.displayMensaje = true;
        //this.tipoMensaje = 'ERROR';
      }
    );
  }

  enviarMailDocumento(documento: ITB_FAC_DOCUMENTOS) {
    this.documento = this.cloneRegistro(documento);

    this.colsEmail = [
      {
        field: 'nombre',
        header: 'Nombre',
        width: '45%'
      },
      {
        field: 'mail',
        header: 'Email',
        width: '45%'
      },
    ]

    this.emails = [];
    //this.emails.push({ a: 1, nombre: 'Bryan Cantos', mail: 'bcantos@inti-moda.com', check: false });
    //this.emails.push({ a: 1, nombre: 'Edison Figueroa', mail: 'efigueroa@inti-moda.com', check: false });
    //this.emails.push({ a: 1, nombre: 'Gloria Arreaga', mail: 'garreaga@inti-moda.com', check: false });
    //this.emails.push({ a: 1, nombre: 'Hector Lara', mail: 'hlara@inti-moda.com', check: false });
    //this.emails.push({ a: 1, nombre: 'Juan Pablo Sanchez', mail: 'jpsanchez@inti-moda.com', check: false });
    //this.emails.push({ a: 1, nombre: 'Laura Hanna', mail: 'lhanna@inti-moda.com', check: false });
    //this.emails.push({ a: 1, nombre: 'Lexy Leon', mail: 'lleon@inti-moda.com', check: false });
    //this.emails.push({ a: 1, nombre: 'PASSARELA TEXTILES S.A. TEXTIPASS', mail: 'lhanna@inti-moda.com', check: false });


    const postData = new FormData();

    postData.append('cci_empresa', this.documento.cci_empresa);
    postData.append('cci_sucursal', this.documento.cci_sucursal);
    postData.append('cci_tipocmpr', this.documento.cci_tipocmpr);
    postData.append('nci_documento', this.documento.nci_documento.toString());
    postData.append('action', 'getMailsDocumento');

    this.procesarDocumentosElectronicosService.getMailsDocumento(postData).subscribe(

      data => {
        //alert(data.mensaje);

        //this.totalRecords$ = this.mantenimientoUsuarioService.getTotalRecords();
        //this.documentos = data;
        //console.log(this.perfiles);
        console.log(data);

        this.emails = data;

        console.log(this.emails);

        this.displayDialogEmail = true;

        //window.open(this.url + 'descargas/' + data.mensaje, '_blank');

        //if (data.mensaje2 != '') {
        //  window.open(this.url + 'descargas/' + data.mensaje2, '_blank');
        //}
      },
      error => {
        //this.displayWait = false;
        //this.errorMsg = error;
        //console.log(this.errorMsg);

        //this.displayWait = false;
        //this.displayMensaje = true;
        //this.tipoMensaje = 'ERROR';
      }
    );


    console.log(this.emails);

  }

  onHeaderCheckboxToggle(event: any) {
    //this.selectedDocumentos.length = 0;

    //if (event.checked === true) {
    //this.selectedDocumentos = this.documentos
    //alert('goku');
    //for (let m of this.documentos) {
    //  //if (/* Make your test here if the array does not contain the element*/) {
    //  this.selectedDocumentos.push(m);
    //  //}
    //}
    //console.log(this.documentos);
    //} else {
    //this.selectedDocumentos.length = 0;
    //}


    //this.documentos.forEach(d => {
    //console.log(d.);

    //console.log(event.checked);

    //d.estado_menu_favoritos = (event.checked === true ? 'A' : 'I');

    //this.perfilesActivos.push({ label: d.descripcion_perfil, value: d.id_perfil });
    //});
  }

  cloneRegistro(c: ITB_FAC_DOCUMENTOS): ITB_FAC_DOCUMENTOS {
    const documento = {};
    for (const prop in c) {
      if (c) {
        documento[prop] = c[prop];
      }

    }
    return documento;
  }

  addMail() {
    this.form.controls.txtNombre.setValue('');
    this.form.controls.txtEmail.setValue('');
    this.displayDialogAddEmail = true;
  }

  buildFormAddMail() {
    this.form = this.fb.group({
      txtNombre: ['', [Validators.required, Validators.maxLength(100)]],
      txtEmail: ['', [Validators.email, Validators.maxLength(50)]]
    });
  }

  saveMail() {
    if (!this.validateForm()) {
      return;
    }

    this.emails.unshift({ a: 1, nombre: this.form.controls.txtNombre.value, mail: this.form.controls.txtEmail.value, check: true });
    this.displayDialogAddEmail = false;
  }

  closeEmail() {
    this.displayDialogAddEmail = false;
  }

  sendMail() {
    let sendMail = this.emails.filter(email => email.check);
    let enviarMailDocumento = [];
    //this.documento = this.cloneRegistro(documento);
    //alert(this.documento.cci_empresa);
    //alert(this.documento.ambiente);

    enviarMailDocumento.push({
      "cci_empresa": this.documento.cci_empresa,
      "cci_sucursal": this.documento.cci_sucursal,
      "cci_tipocmpr": this.documento.cci_tipocmpr,
      "nci_documento": this.documento.nci_documento,
      "ces_fe": this.documento.ces_fe,
      "ambiente": this.documento.ambiente,
      "opcion": 'M',
      "mail": sendMail

    });

    console.log(enviarMailDocumento);

    console.log(sendMail);
    console.log(this.documento);

    if (sendMail.length <= 0) {
      this.showErrorMessage('Error en envio de correo', 'No ha seleccionado ningun correo.', '');
      return;
    }

    const postData = new FormData();

    postData.append('json', JSON.stringify(enviarMailDocumento));
    postData.append('action', 'generarProcesoFE');

    this.procesarDocumentosElectronicosService.enviarMailDocumento(postData).subscribe(

      data => {
        //alert(data.mensaje);

        //this.totalRecords$ = this.mantenimientoUsuarioService.getTotalRecords();
        //this.documentos = data;
        //console.log(this.perfiles);
        console.log(data);

        //window.open(this.url + 'descargas/' + data.mensaje, '_blank');

        //if (data.mensaje2 != '') {
        //  window.open(this.url + 'descargas/' + data.mensaje2, '_blank');
        //}
      },
      error => {
        //this.displayWait = false;
        //this.errorMsg = error;
        //console.log(this.errorMsg);

        //this.displayWait = false;
        //this.displayMensaje = true;
        //this.tipoMensaje = 'ERROR';
      }
    );
  }

  validateForm() {
    let ok = true;

    if (this.form.controls['txtNombre'].invalid) {
      if (this.form.controls['txtNombre'].errors.required) {
        this.showErrorMessage('Mensaje de Error en Nombre', 'El campo Nombre es obligatorio', 'txtNombre');
      }

      if (this.form.controls['txtNombre'].errors.maxlength) {
        this.showErrorMessage('Mensaje de Error en Nombre', 'La longitud del campo no puede ser mayor a 100 caracteres', 'txtNombre');
      }
      ok = false;
    }

    if (this.form.controls['txtEmail'].invalid) {
      if (this.form.controls['txtEmail'].errors.email) {
        this.showErrorMessage('Mensaje de Error en Email', 'El formato del Email es incorrecto', 'txtEmail');
      }

      if (this.form.controls['txtEmail'].errors.maxlength) {
        this.showErrorMessage('Mensaje de Error en Email', 'La longitud del campo no puede ser mayor a 50 caracteres', 'txtEmail');
      }
      ok = false;
    }

    return ok;
  }

  showErrorMessage(summary: string, detail: string, field: string) {
    this.messageService.add({ severity: 'error', summary: summary, detail: detail });

    if (field != '') {
      this.form.get(field).markAsDirty();
    }
  }
  onChangeCheckbox() {
    console.log(this.emails);
  }

  onChangeCheckboxAll(documento) {
    console.log(documento);

    this.documentosSeleccionados.push({
      "cci_empresa": documento.cci_empresa,
      "cci_sucursal": documento.cci_sucursal,
      "cci_tipocmpr": documento.cci_tipocmpr,
      "nci_documento": documento.nci_documento,
    });
  }

  paginate(event) {
    //alert('paginacion');
    console.log(this.documentosSeleccionados);
  }
}
