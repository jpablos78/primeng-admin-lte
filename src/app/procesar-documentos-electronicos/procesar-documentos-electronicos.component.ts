import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';

@Component({
  selector: 'app-procesar-documentos-electronicos',
  templateUrl: './procesar-documentos-electronicos.component.html',
  styleUrls: ['./procesar-documentos-electronicos.component.css']
})
export class ProcesarDocumentosElectronicosComponent implements OnInit {
  cols: any[];
  docs: any[];
  items: MenuItem[];

  constructor() { }

  ngOnInit() {

    this.docs = [
      { cci_empresa: 'GLOBALTEX', cci_tipocmpr: 'FAC', nci_documento: '10011235', ces_fe: 'A' },
      { cci_empresa: 'GLOBALTEX', cci_tipocmpr: 'FAC', nci_documento: '10011236', ces_fe: 'A' },
      { cci_empresa: 'GLOBALTEX', cci_tipocmpr: 'FAC', nci_documento: '10011237', ces_fe: 'A' },
      { cci_empresa: 'GLOBALTEX', cci_tipocmpr: 'FAC', nci_documento: '10011238', ces_fe: 'A' },
      { cci_empresa: 'GLOBALTEX', cci_tipocmpr: 'FAC', nci_documento: '10011239', ces_fe: 'A' }
    ]

    this.cols = [
      { field: 'cci_empresa', header: 'Empresa' },
      { field: 'cci_tipocmpr', header: 'Tipo' },
      { field: 'nci_documento', header: 'Documento' },
      { field: 'ces_fe', header: 'Estado' }
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
  }

}
