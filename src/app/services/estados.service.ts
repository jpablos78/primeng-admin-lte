import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { map } from 'rxjs/operators';


import IEstados from '../model/IEstados'

@Injectable({
  providedIn: 'root'
})
export class EstadosService {

  constructor(
    private http: HttpClient

  ) { }

  getEstados() {
    return this.http.get<any>('/assets/data/estados.json')
      .pipe(
        map(res => res.data as IEstados[])
      );
  }
}
