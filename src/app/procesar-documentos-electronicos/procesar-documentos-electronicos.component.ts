import { Component, OnInit, ViewChild } from '@angular/core';
import { MenuItem, LazyLoadEvent } from 'primeng/api';

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
  selectedDocumentos: ITB_FAC_DOCUMENTOS[];
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

  url = environment.baseUrl;

  constructor(
    private procesarDocumentosElectronicosService: ProcesarDocumentosElectronicosService,
    private estadosService: EstadosService,
    private cciTipoCmprService: CciTipocmprService,
    private empresasService: EmpresasService
  ) { }

  ngOnInit() {

    this.inicializarPantalla();

  }

  inicializarPantalla() {
    this.txtDocumento = '';

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
        this.documentos = data;
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


    /*this.totalRecords = 10;
    this.procesarDocumentosElectronicosService.getDocumentos(event).subscribe(
      data => {
        this.documentos = data;
        console.log(this.documentos);
      }
    );*/
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
    alert(this.documento.nci_documento);
    console.log(this.selectedDocumentos);
    window.open('http://localhost/FE/descargas/2811201901099265673500110010010000173621234567815_G.pdf');
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
}
