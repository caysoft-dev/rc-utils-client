import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import {RaidCompComponent} from './raid-comp/raid-comp.component';
import {HomeComponent} from './home/home.component';
import {GuildComponent} from './guild/guild.component';
import {AdminComponent} from './admin/admin.component';
import {ManageCharactersComponent} from './profile/manage-characters/manage-characters.component';
import {RaidParserComponent} from './raid-parser/raid-parser.component';

const routes: Routes = [
  { path: 'raid-settings', component: RaidCompComponent },
  { path: 'guild', component: GuildComponent },
  { path: 'profile', component: ManageCharactersComponent },
  { path: 'admin', component: AdminComponent },
  { path: 'tools/raid-parser', component: RaidParserComponent },
  { path: '', component: HomeComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
