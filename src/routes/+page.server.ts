import type { Actions, PageServerLoad } from './$types';
import { Query } from './query';

export const load = (({ cookies }) => {
  const query = new Query(cookies.get('wordacle'));

  return {
    guesses: query.guesses,
    states: query.states
  };
}) satisfies PageServerLoad;

export const actions = {} satisfies Actions;
