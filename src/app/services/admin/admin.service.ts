import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {GuildMember} from '../../models/guild-member';
import {DiscordRole} from '../../models/discord-role';

@Injectable({
  providedIn: 'root'
})
export class AdminService {
  constructor(private http: HttpClient) {}

  async getDiscordRoles(): Promise<any[]> {
    return await this.http.get<any[]>('/api/admin/discord/roles').toPromise()
  }

  async updateDiscordRoles(): Promise<any[]> {
    return await this.http.post<any[]>('/api/admin/discord/fetch/roles', { }).toPromise()
  }

  async saveDiscordRoles(roles: DiscordRole[]): Promise<any[]> {
    return await this.http.put<any[]>('/api/admin/discord/roles', roles).toPromise()
  }
}
