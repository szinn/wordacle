import type { Actions, PageServerLoad } from './$types';
import { Query } from './query';

export const load = (({ cookies }) => {
  const query = new Query(cookies.get('wordacle'));

  return {
    guesses: query.guesses,
    states: query.states
  };
}) satisfies PageServerLoad;

export const actions = {
  enter: async ({ request, cookies }) => {
    const query = new Query(cookies.get('wordacle'));

    const data = await request.formData();
    const guess = data.getAll('guess') as string[];
    const state = data.getAll('state') as string[];
    console.log('got guesses', guess);
    console.log('got states', state);

    cookies.set('wordacle', query.toString(), { path: '/' });
  },

  restart: async ({ cookies }) => {
    cookies.delete('wordacle', { path: '/' });
  }
} satisfies Actions;
