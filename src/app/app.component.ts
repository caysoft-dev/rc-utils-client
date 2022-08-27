import {Component, OnInit} from '@angular/core';
import {AuthService} from './services/auth/auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  loaded: boolean = false;

  constructor(private auth: AuthService) {}

  ngOnInit() {
    this.auth.getUser().then(x => {
      if (x) {
        this.loaded = true
        console.log('user', x)
      } else {
        window.location.href = '/api/auth/login'
      }
    })
  }
}
