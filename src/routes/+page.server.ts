import type { Actions, PageServerLoad } from './$types';
import { Query } from './query';

export const load = (({ cookies }) => {
  const query = new Query(cookies.get('wordacle'));

  return {
    guesses: query.guesses,
    states: query.states,
    matches: query.matches
  };
}) satisfies PageServerLoad;

export const actions = {
  enter: async ({ request, cookies }) => {
    const query = new Query(cookies.get('wordacle'));

    const data = await request.formData();
    const guesses = data.getAll('guess') as string[];
    const states = data.getAll('state') as string[];
    console.log('got guesses', guesses);
    console.log('got states', states);

    query.apply(guesses, states);

    cookies.set('wordacle', query.toString(), { path: '/' });
  },

  restart: async ({ cookies }) => {
    cookies.delete('wordacle', { path: '/' });
  }
} satisfies Actions;
