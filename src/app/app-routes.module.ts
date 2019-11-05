import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';

import { CambioClaveComponent } from './cambio-clave/cambio-clave.component';
import { MenuFavoritosComponent } from './menu-favoritos/menu-favoritos.component';

const appRoutes: Routes = [
  { path: 'cambio-clave', component: CambioClaveComponent },
  { path: 'menu-favoritos', component: MenuFavoritosComponent }
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
