import { Component, OnInit } from '@angular/core';
import {ToolsService} from '../services/tools/tools.service';

@Component({
  selector: 'app-raid-parser',
  templateUrl: './raid-parser.component.html',
  styleUrls: ['./raid-parser.component.scss']
})
export class RaidParserComponent implements OnInit {
  data: string;
  url: string;
  importState = {
    success: '',
    error: ''
  }

  constructor(private toolsApi: ToolsService) { }

  async parse(data) {
    try {
      this.url = (await this.toolsApi.parseRaidHelperSignUps(data)).url
      this.importState.error = ''
    } catch (e) {
      this.importState.error = 'The provided data format is invalid!'
    }
  }

  ngOnInit() {}
}
