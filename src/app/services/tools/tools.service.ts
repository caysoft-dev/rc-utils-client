import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {GuildMember} from '../../models/guild-member';
import {DiscordRole} from '../../models/discord-role';

@Injectable({
  providedIn: 'root'
})
export class ToolsService {
  constructor(private http: HttpClient) {}

  async parseRaidHelperSignUps(data: string): Promise<{ url: string }> {
    const rows = data.split('\n')
    for (let i in rows) {
      if (rows[i].startsWith('Role,Spec,Name,ID,Timestamp,Status')) {
        data = rows.slice(+i).join('\n')
        break;
      }
      if (+i === rows.length - 1)
        throw new Error()
    }
    console.log('data', data)
    return await this.http.post<{ url: string }>('/api/tools/rh/parse', {data}).toPromise()
  }
}
