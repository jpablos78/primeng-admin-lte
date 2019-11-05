import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ProcesarDocumentosElectronicosComponent } from './procesar-documentos-electronicos.component';

describe('ProcesarDocumentosElectronicosComponent', () => {
  let component: ProcesarDocumentosElectronicosComponent;
  let fixture: ComponentFixture<ProcesarDocumentosElectronicosComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ProcesarDocumentosElectronicosComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ProcesarDocumentosElectronicosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
