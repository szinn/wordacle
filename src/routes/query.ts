// import { allowed, words } from './words.server';

export class Query {
  guesses: string[];
  // x: not present
  // /: present, wrong location
  // +: present, right location
  states: string[];

  constructor(serialized: string | undefined = undefined) {
    if (serialized) {
      const [guesses, states] = serialized.split('-');

      this.guesses = guesses ? guesses.split(' ') : [];
      this.states = states ? states.split(' ') : [];
    } else {
      this.guesses = ['slats', 'fists'];
      this.states = ['/xx++', 'xxxxx', 'xxxxx', 'xxxxx'];
    }
  }

  /**
   * Serialize game state so it can be set as a cookie
   * @returns {string} The query encoded in a string
   */
  toString() {
    return `${this.guesses.join(' ')}-${this.states.join(' ')}`;
  }
}
