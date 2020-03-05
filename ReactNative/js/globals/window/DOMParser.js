/* eslint-disable import/prefer-default-export */
import jsdom from 'jsdom-jscore-rn';

export class DOMParser {
  // eslint-disable-next-line class-methods-use-this
  parseFromString(text /* , format */) {
    return jsdom.html(text);
  }
}
