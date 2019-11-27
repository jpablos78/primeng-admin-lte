import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { BehaviorSubject } from 'rxjs';
import { Observable, throwError } from 'rxjs';
import { map, catchError } from 'rxjs/operators';
import { environment } from '../../environments/environment';
//import { transformError } from '../../common/common';

import ITB_SEG_EMPRESA from '../model/ITB_SEG_EMPRESA';

@Injectable({
  providedIn: 'root'
})
export class EmpresasService {
  url = environment.baseUrl + 'empresa.php';

  constructor(
    private http: HttpClient
  ) { }

  getEmpresas(postData): Observable<ITB_SEG_EMPRESA[]> {
    return this.http.post<any>(this.url, postData)
      .pipe(
        map(res => {
          if (res.success) {
            //alert('fddddd');
            //if (res.ok === 'S') {
            //  alert(res);
            //this.totalRecords.next(res.total);
            return res.data as ITB_SEG_EMPRESA[];
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
}
