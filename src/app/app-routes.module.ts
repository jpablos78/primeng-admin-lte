import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';

import { CambioClaveComponent } from './cambio-clave/cambio-clave.component';
import { MenuFavoritosComponent } from './menu-favoritos/menu-favoritos.component';
import { ProcesarDocumentosElectronicosComponent } from './procesar-documentos-electronicos/procesar-documentos-electronicos.component';

const appRoutes: Routes = [
  { path: 'cambio-clave', component: CambioClaveComponent },
  { path: 'menu-favoritos', component: MenuFavoritosComponent },
  { path: 'procesar-documentos-electronicos', component: ProcesarDocumentosElectronicosComponent }
]

@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    RouterModule.forRoot(appRoutes)
  ],
  exports: [
    RouterModule
  ]
})
export class AppRoutesModule { }
