import { Component, OnInit } from '@angular/core';
import {Player, PlayerClassMap, PlayerData} from '../../data/players.data';
import {CdkDrag, CdkDragDrop, CdkDropList, transferArrayItem} from '@angular/cdk/drag-drop';

@Component({
  selector: 'app-raid-comp',
  templateUrl: './raid-comp.component.html',
  styleUrls: ['./raid-comp.component.scss']
})
export class RaidCompComponent implements OnInit {
  groupData: Array<any[][]> =  [
    [[null], [null], [null], [null], [null]],
    [[null], [null], [null], [null], [null]],
    [[null], [null], [null], [null], [null]],
    [[null], [null], [null], [null], [null]],
    [[null], [null], [null], [null], [null]]
  ]

  groupDataPool: string[] = [
    'Cayd', 'Cogblocked', 'Stirling', 'Jowzer'
  ]

  playerClassMap: PlayerClassMap = {};
  players: Player[] = PlayerData.toArray();
  classes: string[] = PlayerData.getClasses();

  eventCall(name: string, event: any) {
    console.log(name, event);
  }

  sort(index: number, drag: CdkDrag, drop: CdkDropList): boolean {
    //console.log(index, drag, drop)
    return false
  }

  drop(event: CdkDragDrop<any[]>) {
    console.log('dropped on', event, event.container.data, event.currentIndex)
    if (event.previousContainer === event.container) {
      //moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);
    } else {
      const handles = event.container.getSortedItems()
      if (event.container.data[0] === null) {
        event.container.removeItem(handles[0])
        event.container.data.splice(0, 1)
      } else {
        transferArrayItem(
          event.container.data,
          event.previousContainer.data,
          event.currentIndex,
          event.previousIndex+1
        )
      }

      transferArrayItem(
        event.previousContainer.data,
        event.container.data,
        event.previousIndex,
        event.currentIndex
      )
    }
  }

  ngOnInit() {
    this.playerClassMap = PlayerData.groupByClass()
    console.log(this.playerClassMap)
  }
}
