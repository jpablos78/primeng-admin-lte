import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { map } from 'rxjs/operators';

import ICCI_TIPOCMPR from '../model/ICCI_TIPOCMPR'

@Injectable({
  providedIn: 'root'
})
export class CciTipocmprService {

  constructor(
    private http: HttpClient
  ) { }

  getTipoDocumentos() {
    return this.http.get<any>('/assets/data/cci_tipocmpr.json')
      .pipe(
        map(res => res.data as ICCI_TIPOCMPR[])
      );
  }
}
