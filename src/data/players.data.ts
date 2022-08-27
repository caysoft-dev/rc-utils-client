export const PLAYER_DATA: Player[] = [
  {
    name: 'Asgierr',
    class: 'warrior'
  },
  {
    name: 'Riest',
    class: 'warlock'
  },
  {
    name: 'Jonesyhaize',
    class: 'priest'
  },
  {
    name: 'Mcstubbs',
    class: 'hunter'
  },
  {
    name: 'Nørgaard',
    class: 'warrior'
  },
  {
    name: 'Mewiyn',
    class: 'paladin'
  },
  {
    name: 'Aladach',
    class: 'hunter'
  },
  {
    name: 'Nihth',
    class: 'druid'
  },
  {
    name: 'Aeluna',
    class: 'druid'
  },
  {
    name: 'Luminati',
    class: 'priest'
  },
  {
    name: 'Anoos',
    class: 'shaman'
  },
  {
    name: 'Zafer',
    class: 'hunter'
  },
  {
    name: 'ßounty',
    class: 'hunter'
  },
  {
    name: 'Pino',
    class: 'paladin'
  },
  {
    name: 'Cayd',
    class: 'mage'
  },
  {
    name: 'Bozn',
    class: 'warlock'
  },
  {
    name: 'Bananayamal',
    class: 'shaman'
  },
  {
    name: 'Ewlf',
    class: 'druid'
  },
  {
    name: 'Cogblocked',
    class: 'warrior'
  },
  {
    name: 'Jowlock',
    class: 'warlock'
  },
  {
    name: 'Stirling',
    class: 'priest'
  },
  {
    name: 'Testes',
    class: 'rogue'
  },
  {
    name: 'Choo',
    class: 'mage'
  },
  {
    name: 'Warape',
    class: 'warrior'
  },
  {
    name: 'Crixzu',
    class: 'shaman'
  },
  {
    name: 'Surerabbit',
    class: 'paladin'
  },
  {
    name: 'Entíe',
    class: 'druid'
  },
  {
    name: 'Junkstar',
    class: 'warlock'
  },
  {
    name: 'Melolina',
    class: 'mage'
  },
  {
    name: 'Wavez',
    class: 'rogue'
  },
  {
    name: 'Gnomair',
    class: 'mage'
  },
  {
    name: 'Odeza',
    class: 'paladin'
  },
  {
    name: 'Havvy',
    class: 'warlock'
  },
  {
    name: 'Ivis',
    class: 'warrior'
  },
  {
    name: 'Jowrog',
    class: 'rogue'
  },
  {
    name: 'Tessyre',
    class: 'priest'
  },
  {
    name: 'Ugyes',
    class: 'hunter'
  },
  {
    name: 'Breverton',
    class: 'priest'
  },
  {
    name: 'Forcina',
    class: 'paladin'
  },
  {
    name: 'Keeto',
    class: 'druid'
  },
  {
    name: 'Feeltheheal',
    class: 'priest'
  },
  {
    name: 'Scuffeddots',
    class: 'warlock'
  },
  {
    name: 'Ballseye',
    class: 'hunter'
  },
  {
    name: 'Jowzermage',
    class: 'mage'
  },
  {
    name: 'Saqran',
    class: 'mage'
  },
  {
    name: 'Blackbolt',
    class: 'warlock'
  },
  {
    name: 'Onesock',
    class: 'hunter'
  },
  {
    name: 'Donfelak',
    class: 'rogue'
  },
  {
    name: 'Caydi',
    class: 'shaman'
  },
  {
    name: 'Starlean',
    class: 'paladin'
  },
  {
    name: 'Evildude',
    class: 'warrior'
  },
  {
    name: 'Ghostwrld',
    class: 'warlock'
  }
]

export type Player = {
  name: string;
  class: string;
}

export type PlayerClassMap = {[index: string]: Player[]}

export class PlayerData {
  static groupByClass(): PlayerClassMap {
    const result: PlayerClassMap = {}
    for (let player of PLAYER_DATA.sort((a, b) => a.class.localeCompare(b.class))) {
      if (!result[player.class])
        result[player.class] = []
      result[player.class].push(player)
    }
    return result
  }
  static getClasses(): string[] {
    return [...new Set(PLAYER_DATA.sort((a, b) => a.class.localeCompare(b.class)).map(x => x.class))]
  }
  static toArray(): Player[] {
    return PLAYER_DATA.sort((a, b) => a.class.localeCompare(b.class))
  }
}
