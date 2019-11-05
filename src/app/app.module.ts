import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';

import { PrimeNGModule } from './png';

import { AppComponent } from './app.component';
import { HeaderComponent } from './components/shared/header/header.component';
import { MenuComponent } from './components/shared/menu/menu.component';
import { ContentComponent } from './components/shared/content/content.component';
import { FooterComponent } from './components/shared/footer/footer.component';
import { SettingComponent } from './components/shared/setting/setting.component';
import { AppRoutesModule } from './app-routes.module';
import { CambioClaveComponent } from './cambio-clave/cambio-clave.component';
import { MenuFavoritosComponent } from './menu-favoritos/menu-favoritos.component';
import { ProcesarDocumentosElectronicosComponent } from './procesar-documentos-electronicos/procesar-documentos-electronicos.component';


@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,
    MenuComponent,
    ContentComponent,
    FooterComponent,
    SettingComponent,
    CambioClaveComponent,
    MenuFavoritosComponent,
    ProcesarDocumentosElectronicosComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    PrimeNGModule,
    AppRoutesModule,
    ReactiveFormsModule,
    FormsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
