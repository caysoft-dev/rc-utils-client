import {Component, OnInit} from '@angular/core';
import {AdminService} from '../services/admin/admin.service';
import {DiscordRole} from '../models/discord-role';
import {GuildRankService} from '../services/guild/guild-rank.service';
import {GuildRank} from '../models/guild-rank';

@Component({
  selector: 'app-admin',
  templateUrl: './admin.component.html',
  styleUrls: ['./admin.component.scss']
})
export class AdminComponent implements OnInit {
  hideHoist: boolean = true
  rankMapping: boolean[][]
  discordRoles: DiscordRole[]
  guildRanks: GuildRank[]

  constructor(private adminService: AdminService, private guildRankService: GuildRankService) {}

  async updateRoles() {
    await this.adminService.updateDiscordRoles()
    await this.fetchRoles();
  }

  async fetchRoles() {
    this.discordRoles = await this.adminService.getDiscordRoles()
    console.log('this.discordRoles', this.discordRoles)
  }

  async fetchGuildRanks() {
    this.guildRanks = await this.guildRankService.getAll()
    console.log('this.guildRanks', this.guildRanks)
  }

  mapGuildRanks() {
    this.rankMapping = []
    this.guildRanks.forEach(rank => this.rankMapping[rank.index] = [])
    this.discordRoles.forEach((value, index) => {
      this.rankMapping[index] = []
      value.settings.characterAssignment.assignableGuildRanks.forEach(x => this.rankMapping[index][x] = true)
    })
  }

  onRoleGroupCheckboxChange(roleIndex, field1, field2) {
    const role = this.discordRoles[roleIndex]
    if (role.settings.characterAssignment[field1]) {
      role.settings.characterAssignment[field2] = false
    }
  }

  onRankMapChange(roleIndex) {
    console.log('this.rankMapping[roleIndex]', this.rankMapping[roleIndex])
    this.discordRoles[roleIndex].settings.characterAssignment.assignableGuildRanks = this.rankMapping[roleIndex]
      .map((x, i) => !!x ? i : -1)
      .filter((x) => x > 0)
  }

  save() {
    this.adminService.saveDiscordRoles(this.discordRoles)
  }

  ngOnInit() {
    this.fetchGuildRanks()
      .then(() => this.fetchRoles())
      .then(() => this.mapGuildRanks())
  }
}
