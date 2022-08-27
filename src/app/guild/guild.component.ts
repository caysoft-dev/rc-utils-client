import {AfterViewInit, Component, OnInit, ViewChild} from '@angular/core';
import {GuildMemberService} from '../services/guild/guild-member.service';
import {GuildMember} from '../models/guild-member';
import {MatTableDataSource} from '@angular/material/table';
import {MatSort} from '@angular/material/sort';
import { base64Decode } from '../base64';
import {GuildRank} from '../models/guild-rank';
import {GuildRankService} from '../services/guild/guild-rank.service';

@Component({
  selector: 'app-guild',
  templateUrl: './guild.component.html',
  styleUrls: ['./guild.component.scss']
})
export class GuildComponent implements OnInit, AfterViewInit {
  displayedColumns = ['name', 'class', 'level', 'rankIndex', 'note']
  dataSource?: MatTableDataSource<GuildMember>;
  encodedData?: string;
  decodedData?: { members: GuildMember[], ranks: GuildRank[] }
  members: GuildMember[]
  memberMap: {[index: string]: GuildMember}
  showImport: boolean;
  loading: boolean;
  importState = {
    success: '',
    error: ''
  }

  @ViewChild(MatSort) sort: MatSort;

  constructor(private memberService: GuildMemberService, private rankService: GuildRankService) {
    this.members = []
    this.loading = false;
    this.showImport = false;
  }

  decodeDataString(data: string) {
    this.importState.error = ''
    this.importState.success = ''

    if (!data)
      return;

    try {
      console.log(base64Decode(data))
      this.decodedData = JSON.parse(base64Decode(data))
      this.importState.success = `${this.decodedData?.members?.length || 0} member(s) and ${this.decodedData?.ranks?.length || 0} rank(s) has been loaded from your data. You can upload them now!`
    } catch (e) {
      console.error(e)
      this.importState.error = 'An error occurred on the attempt to parse your data. Please verify if your data is encoded correctly.'
    }
  }

  async push() {
    if (!this.decodedData?.members || !this.decodedData?.ranks)
      return;

    this.importState.error = ''
    this.importState.success = ''

    await this.memberService.save(this.decodedData.members)
    await this.rankService.save(this.decodedData.ranks)
    await this.reload()

    this.showImport = false
  }

  async reload() {
    this.loading = true
    this.memberMap = {}
    this.members = await this.memberService.getAll()

    for (let member of this.members)
      this.memberMap[member.key] = member

    if (this.dataSource) {
      this.dataSource.data = this.members
    } else {
      this.dataSource = new MatTableDataSource(this.members)
      this.dataSource.sort = this.sort;
    }
    this.loading = false
  }

  ngOnInit() {
    this.reload()
  }

  ngAfterViewInit() {
  }
}
