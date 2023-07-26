import { Elm } from './Main.elm';

const logoUrl = new URL(
  '../static/trains.jpg?as=webp&width=400',
  import.meta.url
);

Elm.Main.init({
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
