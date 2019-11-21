import jsdom from 'jsdom-jscore-rn';

class DOMParser {
  // eslint-disable-next-line class-methods-use-this
  parseHTML(text /* , format */) {
    return jsdom.html(text);
  }
}

window.DOMParser = DOMParser;
