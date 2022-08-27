import { Component, OnInit } from '@angular/core';
import {GuildMemberService} from '../../services/guild/guild-member.service';
import {GuildRankService} from '../../services/guild/guild-rank.service';
import {GuildMember} from '../../models/guild-member';
import {AuthService} from '../../services/auth/auth.service';
import {Player} from '../../models/player';

@Component({
  selector: 'app-manage-characters',
  templateUrl: './manage-characters.component.html',
  styleUrls: ['./manage-characters.component.scss']
})
export class ManageCharactersComponent implements OnInit {
  members: GuildMember[]
  authInfo: Player;

  constructor(private memberService: GuildMemberService,
              private rankService: GuildRankService,
              private authService: AuthService)
  {
    this.members = []
  }

  async fetchAuthInfo() {
    this.authInfo = await this.authService.getUser()
  }

  async fetchGuildMembers() {
    this.members = await this.memberService.getAll()
  }

  ngOnInit() {
    this.fetchAuthInfo()
    this.fetchGuildMembers()
  }
}
