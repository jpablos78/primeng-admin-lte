import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MenuFavoritosComponent } from './menu-favoritos.component';

describe('MenuFavoritosComponent', () => {
  let component: MenuFavoritosComponent;
  let fixture: ComponentFixture<MenuFavoritosComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ MenuFavoritosComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MenuFavoritosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
