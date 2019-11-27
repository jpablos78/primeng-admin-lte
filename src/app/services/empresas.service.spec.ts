import { TestBed } from '@angular/core/testing';

import { EmpresasService } from './empresas.service';

describe('EmpresasService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: EmpresasService = TestBed.get(EmpresasService);
    expect(service).toBeTruthy();
  });
});
