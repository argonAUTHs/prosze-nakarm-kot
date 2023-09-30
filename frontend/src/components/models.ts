export class Home {
  doors: Door[];
  lights: Light[];
  catFeeders: CatFeeder[];

  constructor() {
    this.doors = [
      new Door(0, 'Front Door'),
      new Door(1, 'Back Door'),
    ];
    this.lights = [
      new Light(0, 'Living Room'),
      new Light(1, 'Kitchen'),
      new Light(2, 'Bedroom'),
    ];
    this.catFeeders = [
      new CatFeeder(0, 'Cat Feeder 1'),
    ]
  }
}

export class Door {
  id: number;
  name: string;
  state: boolean;

  constructor(id: number, name: string) {
    this.id = id;
    this.name = name;
    this.state = false;
  }
}

export class Light {
  id: number;
  name: string;
  state: boolean;

  constructor(id: number, name: string) {
    this.id = id;
    this.name = name;
    this.state = false;
  }
}

export class CatFeeder {
  id: number;
  name: string;
  state: boolean;

  constructor(id: number, name: string) {
    this.id = id;
    this.name = name;
    this.state = false;
  }
}
