import { TestBed } from '@angular/core/testing';

import { CciTipocmprService } from './cci-tipocmpr.service';

describe('CciTipocmprService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: CciTipocmprService = TestBed.get(CciTipocmprService);
    expect(service).toBeTruthy();
  });
});
