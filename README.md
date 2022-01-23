# Worjle

Your diligent Wordle assistant, written in Julia.

## Usage

Start the program with

```bash
$ cd Worjle
$ julia --project -e 'using Worjle; Worjle.play()'
```

Then watch it make guesses, and provide feedback with 5-character strings
made of `b` (black), `y` (yellow), or `g` (green):

<pre>
  <b>serai</b>
> bbbgb
  <b>canal</b>
> bbbgg
  <b>podal</b>
> bybgg
  <b>offal</b>
>
</pre>

That's right, [offal](https://en.wikipedia.org/wiki/Offal).
You can simply hit `<enter>` to accept a guess and terminate the program.

If for some reason a guess is rejected, you can issue the special feedback `!`
to ask for a new guess. In the previous example, let's say that `podal` is not
recognized as a word, then:

<pre>
  <b>serai</b>
> bbbgb
  <b>canal</b>
> bbbgg
  <b>podal</b>
> !
  <b>dotal</b>
> bybgg
  <b>offal</b>
>
</pre>
