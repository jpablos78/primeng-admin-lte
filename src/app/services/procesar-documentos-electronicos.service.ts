import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { BehaviorSubject } from 'rxjs';
import { Observable, throwError } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

import { environment } from '../../environments/environment';

import ITB_FAC_DOCUMENTOS from '../model/ITB_FAC_DOCUMENTOS';
import IMensaje from '../model/IMensaje';

@Injectable({
  providedIn: 'root'
})
export class ProcesarDocumentosElectronicosService {
  url = environment.baseUrl + 'procesarDocumentos.php';
  private totalRecords: BehaviorSubject<number> = new BehaviorSubject<number>(0);

  constructor(
    private http: HttpClient
  ) { }

  getTotalRecords() {
    return this.totalRecords.asObservable();
  }

  //getDocumentos(event): Observable<ITB_FAC_DOCUMENTOS[]> {

  //console.log(event.first);
  //console.log(event.rows);
  //console.log(event.sortField);
  //console.log(event.sortOrder);
  //console.log(event.filters);

  /*
      return this.http.get<any>('/assets/data/TB_FAC_DOCUMENTOS.json')
        .pipe(
          map(res => res.data as ITB_FAC_DOCUMENTOS[])
        );
        */


  //}

  getDocumentos(postData): Observable<ITB_FAC_DOCUMENTOS[]> {
    return this.http.post<any>(this.url, postData)
      .pipe(
        map(res => {
          if (res.success) {
            //alert('fddddd');
            //if (res.ok === 'S') {
            //  alert(res);
            //this.totalRecords.next(res.total);
            this.totalRecords.next(res.total);
            return res.data as ITB_FAC_DOCUMENTOS[];
            //} else {
            //  throw (res.mensaje);
            //}
          } else {
            console.log('error');
            console.log('res.mensaje');
            throw (res.mensaje);
          }
        }),
        //catchError(transformError)
      );
  }

  imprimirDocumento(postData): Observable<IMensaje> {
    return this.http.post(this.url, postData)
      .pipe(
        map(res => {
          return res as IMensaje;
        })
      )
  }

  procesarDocumento(postData): Observable<IMensaje> {
    return this.http.post(this.url, postData)
      .pipe(
        map(res => {
          return res as IMensaje;
        })
      )
  }

  //  imprimirDocumento(postData) {
  //    return this.http.post(this.url, postData)

  //    return this.http.post<any>(this.url, postData)
  //      .pipe(
  //        map(res => {
  //          return res.data;

  /*  if (res.success) {
      //alert('fddddd');
      //if (res.ok === 'S') {
      //  alert(res);
      //this.totalRecords.next(res.total);
      //this.totalRecords.next(res.total);
      return res.data;
      //} else {
      //  throw (res.mensaje);
      //}
    } else {
      console.log('error');
      console.log('res.mensaje');
      throw (res.mensaje);
    }*/
  //        }),

  //catchError(transformError)
  //      );
  //  }
}
