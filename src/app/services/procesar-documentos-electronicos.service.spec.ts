import { TestBed } from '@angular/core/testing';

import { ProcesarDocumentosElectronicosService } from './procesar-documentos-electronicos.service';

describe('ProcesarDocumentosElectronicosService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: ProcesarDocumentosElectronicosService = TestBed.get(ProcesarDocumentosElectronicosService);
    expect(service).toBeTruthy();
  });
});
