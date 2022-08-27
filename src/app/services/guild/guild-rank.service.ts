import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {GuildRank} from '../../models/guild-rank';

@Injectable({
  providedIn: 'root'
})
export class GuildRankService {
  constructor(private http: HttpClient) {}

  async insert(ranks: GuildRank[]): Promise<void> {
    await this.http.post('/api/guild/rank', ranks).toPromise()
  }

  async save(ranks: GuildRank[]): Promise<void> {
    await this.http.put('/api/guild/rank', ranks).toPromise()
  }

  async get(index: number): Promise<GuildRank> {
    return await this.http.get<GuildRank>(`/api/guild/rank/${index}`).toPromise()
  }

  async getAll(): Promise<GuildRank[]> {
    return await this.http.get<GuildRank[]>('/api/guild/rank').toPromise()
  }
}
