import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

import ITB_FAC_DOCUMENTOS from '../model/ITB_FAC_DOCUMENTOS';

@Injectable({
  providedIn: 'root'
})
export class ProcesarDocumentosElectronicosService {

  constructor(
    private http: HttpClient
  ) { }

  getDocumentos(event): Observable<ITB_FAC_DOCUMENTOS[]> {

    //console.log(event.first);
    //console.log(event.rows);
    //console.log(event.sortField);
    //console.log(event.sortOrder);
    //console.log(event.filters);


    return this.http.get<any>('/assets/data/TB_FAC_DOCUMENTOS.json')
      .pipe(
        map(res => res.data as ITB_FAC_DOCUMENTOS[])
      );
  }
}
