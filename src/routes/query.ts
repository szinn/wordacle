import { words } from './words.server';

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
      this.guesses = [];
      this.states = [];
    }
  }

  update(guesses: string[], states: string[]) {
    const guessCount = guesses.length / 5;

    this.guesses = [];
    this.states = [];

    for (let i = 0; i < guessCount; i += 1) {
      let guess = '';
      let state = '';

      for (let j = 0; j < 5; j += 1) {
        guess = guess + guesses[i * 5 + j];
        state = state + states[i * 5 + j];
      }
      this.guesses.push(guess);
      this.states.push(state);
    }
  }

  apply(guesses: string[], states: string[]) {
    const tuples = zip(guesses, states);
    const guessCount = guesses.length / 5;
    console.log('Guesses to process', guessCount);
    console.log('Processing', tuples);

    const candidates = [
      'abcdefghijklmnopqrstuvwxyz',
      'abcdefghijklmnopqrstuvwxyz',
      'abcdefghijklmnopqrstuvwxyz',
      'abcdefghijklmnopqrstuvwxyz',
      'abcdefghijklmnopqrstuvwxyz'
    ];

    // Remove not present letters and mark must be present
    for (let i = 0; i < guesses.length; i += 1) {
      const index = i % 5;

      if (states[i] == 'x') {
        for (let j = 0; j < 5; j += 1) {
          candidates[j] = removeLetter(candidates[j], guesses[i]);
        }
      } else if (states[i] == '+') {
        candidates[index] = guesses[i];
      } else {
        candidates[index] = removeLetter(candidates[index], guesses[i]);
      }
      console.log('Candidates', candidates);
    }

    const initialRegex = '[' + candidates.join('][') + ']';

    console.log('Candidates', candidates);
    console.log('Regex', initialRegex);

    let matches = [];
    for (let i = 0; i < words.length; i += 1) {
      if (words[i].match(initialRegex)) {
        matches.push(words[i]);
      }
    }

    for (let i = 0; i < guessCount; i += 1) {
      let prevMatches: string[] = matches;
      matches = [];

      for (let j = 0; j < 5; j += 1) {
        if (states[i * 5 + j] == '/') {
          for (let k = 0; k < prevMatches.length; k += 1) {
            if (prevMatches[k].match('.*' + guesses[i * 5 + j] + '.*')) {
              matches.push(prevMatches[k]);
            }
          }
          prevMatches = matches;
          matches = [];
        }
      }
      matches = prevMatches;
    }
    console.log('Found ', matches.length, 'words');
    console.log('Matches: ', matches);

    this.update(guesses, states);
  }

  /**
   * Serialize game state so it can be set as a cookie
   * @returns {string} The query encoded in a string
   */
  toString(): string {
    return `${this.guesses.join(' ')}-${this.states.join(' ')}`;
  }
}

/**
 * Remove a letter from a list of letters if it is present
 * @param {string} letters The list of letters
 * @param {string} letter The letter to remove
 * @returns {string} The processed letters
 */
function removeLetter(letters: string, letter: string): string {
  const index = letters.indexOf(letter);

  if (index == -1) {
    return letters;
  }

  return letters.substring(0, index) + letters.substring(index + 1);
}

/**
 * Zip multiple arrays together
 * @param {...any} args The arrays to zip
 * @returns {[any]} The result
 */
function zip<T extends unknown[][]>(...args: T): { [K in keyof T]: T[K] extends (infer V)[] ? V : never }[] {
  const minLength = Math.min(...args.map((arr) => arr.length));
  // @ts-expect-error This is too much for ts
  return [...Array(minLength).keys()].map((i) => args.map((arr) => arr[i]));
}
