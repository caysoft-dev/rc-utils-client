import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {GuildMember} from '../../models/guild-member';

@Injectable({
  providedIn: 'root'
})
export class GuildMemberService {
  constructor(private http: HttpClient) {}

  async insert(members: GuildMember[]): Promise<void> {
    await this.http.post('/api/guild/member', members).toPromise()
  }

  async save(members: GuildMember[]): Promise<void> {
    await this.http.put('/api/guild/member', members).toPromise()
  }

  async get(key: string): Promise<GuildMember> {
    return await this.http.get<GuildMember>(`/api/guild/member/${key}`).toPromise()
  }

  async getAll(): Promise<GuildMember[]> {
    return await this.http.get<GuildMember[]>('/api/guild/member').toPromise()
  }
}
