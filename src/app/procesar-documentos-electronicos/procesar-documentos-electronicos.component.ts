import { Component, OnInit, ViewChild } from '@angular/core';
import { MenuItem, LazyLoadEvent } from 'primeng/api';

import { ProcesarDocumentosElectronicosService } from '../services/procesar-documentos-electronicos.service';

import ITB_FAC_DOCUMENTOS from '../model/ITB_FAC_DOCUMENTOS';

@Component({
  selector: 'app-procesar-documentos-electronicos',
  templateUrl: './procesar-documentos-electronicos.component.html',
  styleUrls: ['./procesar-documentos-electronicos.component.css']
})
export class ProcesarDocumentosElectronicosComponent implements OnInit {
  @ViewChild('dt', { static: false, }) dt: any;
  grades: any[];
  empresas: any[];
  tipo: any[];
  filtering() {
    //alert('fffff');
    this.dt.reset();
  }

  cols: any[];
  docs: any[];
  items: MenuItem[];
  documentos: ITB_FAC_DOCUMENTOS[];
  first = 0;
  totalRecords: number;

  txtDocumento: string;

  constructor(
    private procesarDocumentosElectronicosService: ProcesarDocumentosElectronicosService,
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
        width: '20%'
      },
      {
        field: 'cci_tipocmpr',
        header: 'Tipo',
        width: '20%'
      },
      {
        field: 'nci_documento',
        header: 'Documento',
        width: '15%'
      },
      {
        field: 'ces_fe',
        header: 'Estado',
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
        }
      },
      {
        label: 'Solo enviar Mail', icon: 'fa fa-envelope', command: () => {
          console.log('delete');
        }
      }
    ];

    this.grades = [];
    this.grades.push({ label: 'ACTIVO', value: 'ACTIVO' });
    this.grades.push({ label: 'INACTIVO', value: 'INACTIVO' });

    this.empresas = [];
    this.empresas.push({ label: 'GLOBALTEX', value: '008' });
    this.empresas.push({ label: 'TEXFASHION', value: '009' });
    this.empresas.push({ label: 'PASSARELA', value: '012' });

    this.tipo = [];
    this.tipo.push({ label: 'FACTURA', value: 'FAC' });
    this.tipo.push({ label: 'NOTA DE CREDITO', value: 'NC' });
    this.tipo.push({ label: 'RETENCION', value: 'RET' });
    this.tipo.push({ label: 'GUIA', value: 'GUI' });
  }

  loadLazy(event: LazyLoadEvent) {
    this.totalRecords = 10;
    this.procesarDocumentosElectronicosService.getDocumentos(event).subscribe(
      data => {
        this.documentos = data;
        console.log(this.documentos);
      }
    );
  }
}
