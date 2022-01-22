# Worjle

Your diligent Wordle assistant, written in Julia.

## Usage

Start the program as follows, watch it make its guesses, and provide feedback
with 5-character strings made of 'b' (black), 'y' (yellow), or 'g' (green).

```bash
$ cd Worjle
$ julia --project -e 'using Worjle; Worjle.play()'
  serai
> bbbgb
  canal
> bbbgg
  podal
> bybgg
  offal
>
```

You can simply hit `<enter>` to accept a guess and terminate the program.
