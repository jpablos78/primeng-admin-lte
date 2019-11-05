import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-cambio-clave',
  templateUrl: './cambio-clave.component.html',
  styleUrls: ['./cambio-clave.component.css']
})
export class CambioClaveComponent implements OnInit {
  form: FormGroup;

  constructor(
    private fb: FormBuilder
  ) { }

  ngOnInit() {
    this.buildForm();
  }

  buildForm() {
    // TODO: no olvidar poner mas validators a los campos, y su respectivo mensaje controlar la
    //       longitud de la cadena para que coincida con la de la tabla
    this.form = this.fb.group({
      txtClave: ['', Validators.required],
      txtClaveNueva: ['', Validators.required]
    });
  }
}
