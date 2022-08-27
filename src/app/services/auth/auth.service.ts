import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {Player} from '../../models/player';

@Injectable({providedIn: 'root'})
export class AuthService {
  private user: Player;

  constructor(private http: HttpClient) {}

  async getUser(): Promise<Player> {
    if (this.user)
      return this.user

    try {
      this.user = await this.http.get<Player>('/api/auth/info').toPromise()
      return this.user
    } catch (e) {
      return null
    }
  }
}
