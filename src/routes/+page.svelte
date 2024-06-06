<script lang="ts">
  import type { PageData } from './$types';
  import { enhance } from '$app/forms';

  export let data: PageData;

  $: index = data.guesses.length;

  $: {
    for (let i = 0; i < data.guesses.length; i += 1) {
      if (data.guesses[i].length != 5) {
        index = i;
      }
    }
  }

  $: currentGuess = data.guesses[index] || '';
  $: currentState = data.states[index] || '';
  $: currentMatches = data.matches || '';
  $: submittable = (index > 0 && currentGuess.length == 0) || currentGuess.length === 5;

  /**
   * Modify the game state without making a trip to the server,
   * if client-side JavaScript is enabled
   * @param {MouseEvent} event Event to process
   */
  function update(event: MouseEvent) {
    const key = (event.target as HTMLButtonElement).getAttribute('data-key');

    if (key === 'backspace') {
      currentGuess = currentGuess.slice(0, -1);
      currentState = currentState.slice(0, -1);
    } else if (key?.startsWith('guess')) {
      const [, c] = key.split('-');
      const column = +c;

      let state = currentState[column];
      if (state == 'x') {
        state = '/';
      } else {
        state = state == '/' ? '+' : 'x';
      }
      currentState = currentState.substring(0, column) + state + currentState.substring(column + 1);
    } else if (currentGuess.length < 5) {
      currentGuess += key;
      currentState += 'x';
    }
  }

  /**
   * Trigger form logic in response to a keydown event, so that
   * desktop users can use the keyboard to play the game
   * @param {KeyboardEvent} event Event to process
   */
  function keydown(event: KeyboardEvent) {
    if (event.metaKey) return;

    if (event.key === 'Enter' && !submittable) return;

    document.querySelector(`[data-key="${event.key}" i]`)?.dispatchEvent(new MouseEvent('click', { cancelable: true }));
  }
</script>

<svelte:window on:keydown={keydown} />

<svelte:head>
  <title>Wordacle</title>
  <meta name="description" content="A Wordle Oracle" />
</svelte:head>

<h1>Welcome to Wordacle</h1>

<form
  action="?/enter"
  method="POST"
  use:enhance={() => {
    // prevent default callback from resetting the form
    return ({ update }) => {
      update({ reset: false });
    };
  }}
>
  <div class="grid" class:playing={1}>
    {#each Array.from(Array(5).keys()) as row (row)}
      {@const current = row === index}
      <h2 class="visually-hidden">Row {row + 1}</h2>
      <div class="row" class:current>
        {#each Array.from(Array(5).keys()) as column (column)}
          {@const guess = current ? currentGuess : data.guesses[row]}
          {@const states = current ? currentState : data.states[row]}
          {@const state = states?.[column] ?? 'x'}
          {@const value = guess?.[column] ?? ''}
          {@const selected = current && column === guess.length}
          {@const exact = state === '+'}
          {@const close = state === '/'}
          {@const missing = state === 'x'}
          <button
            class="letter"
            class:close
            class:exact
            class:missing
            class:selected
            data-key="guess-{column}"
            disabled={!current || value == ''}
            on:click|preventDefault={update}
          >
            {value}
            <span class="visually-hidden">
              {#if exact}
                (correct)
              {:else if close}
                (present)
              {:else if missing}
                (absent)
              {:else}
                empty
              {/if}
            </span>
            <input name="guess" disabled={value == ''} type="hidden" {value} />
            <input name="state" disabled={value == ''} type="hidden" value={state} />
          </button>
        {/each}
      </div>
    {/each}
  </div>
  <div class="controls">
    <div class="keyboard">
      <button class:selected={submittable} data-key="enter" disabled={!submittable}> submit </button>

      <button name="key" data-key="backspace" formaction="?/update" value="backspace" on:click|preventDefault={update}> back </button>

      {#each ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'] as row}
        <div class="row">
          {#each row as letter}
            <button name="key" aria-label="{letter} {''}" data-key={letter} formaction="?/update" value={letter} on:click|preventDefault={update}>
              {letter}
            </button>
          {/each}
        </div>
      {/each}
    </div>
    <button class="restart selected" data-key="restart" formaction="?/restart"> Restart? </button>
  </div>
  <div class="hints">
    {currentMatches}
  </div>
</form>

<style>
  form {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    flex: 1;
  }

  .grid {
    --width: min(100vw, 40vh, 380px);
    max-width: var(--width);
    align-self: center;
    justify-self: center;
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
  }

  .grid .row {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    grid-gap: 0.2rem;
    margin: 0 0 0.2rem 0;
  }

  .grid.playing .row.current {
    filter: drop-shadow(3px 3px 10px var(--color-bg-0));
  }

  .letter {
    aspect-ratio: 1;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    box-sizing: border-box;
    text-transform: lowercase;
    border: none;
    font-size: calc(0.08 * var(--width));
    border-radius: 2px;
    background: white;
    margin: 0;
    color: rgba(0, 0, 0, 0.7);
  }

  .letter.missing {
    background: rgba(255, 255, 255, 0.5);
    color: rgba(0, 0, 0, 0.5);
  }

  .letter.exact {
    background: var(--color-theme-2);
    color: white;
  }

  .letter.close {
    border: 2px solid var(--color-theme-2);
  }

  .selected {
    outline: 2px solid var(--color-theme-1);
  }

  .keyboard {
    --gap: 0.2rem;
    position: relative;
    display: flex;
    flex-direction: column;
    gap: var(--gap);
    height: 100%;
  }

  .keyboard .row {
    display: flex;
    justify-content: center;
    gap: 0.2rem;
    flex: 1;
  }

  .keyboard button,
  .keyboard button:disabled {
    --size: min(8vw, 4vh, 40px);
    background-color: white;
    color: black;
    width: var(--size);
    border: none;
    border-radius: 2px;
    font-size: calc(var(--size) * 0.5);
    margin: 0;
  }

  .keyboard button:focus {
    background: var(--color-theme-1);
    color: white;
    outline: none;
  }

  .keyboard button[data-key='enter'],
  .keyboard button[data-key='backspace'] {
    position: absolute;
    bottom: 0;
    width: calc(1.5 * var(--size));
    height: calc(1 / 3 * (100% - 2 * var(--gap)));
    text-transform: uppercase;
    font-size: calc(0.3 * var(--size));
    padding-top: calc(0.15 * var(--size));
  }

  .keyboard button[data-key='enter'] {
    right: calc(50% + 3.5 * var(--size) + 0.8rem);
  }

  .keyboard button[data-key='backspace'] {
    left: calc(50% + 3.5 * var(--size) + 0.8rem);
  }

  .keyboard button[data-key='enter']:disabled {
    opacity: 0.5;
  }

  .restart {
    width: 100%;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.5);
    border-radius: 2px;
    border: none;
  }

  .restart:focus,
  .restart:hover {
    background: var(--color-theme-1);
    color: white;
    outline: none;
  }

  .hints {
    width: 100%;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.5);
    border-radius: 2px;
    border: none;
  }
</style>
