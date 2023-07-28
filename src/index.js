import { Elm } from './Main.elm';
import { getGame, saveGame } from './persistence';


const logoUrl = new URL(
  '../static/trains.jpg?as=webp&width=400',
  import.meta.url
);

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: {
    assets: {
        logo: logoUrl.href
    },
    viewport: {
      width: window.innerWidth,
      height: window.innerHeight
    }
  }
});


app.ports.persistGame.subscribe(function (gameData) {
  console.log('>> Updating library ', gameData);
  saveGame(gameData);
});

app.ports.requestPersistedGame.subscribe(function () {
  console.log('>> Reloading saved game');
  const game = getGame();
  console.log('>> ', game);
  app.ports.receivePersistedGame.send(game);
});

