---
title: Let's Algorave!
slug: lets-algorave
date: '2026-07-09'
summary: Coding can be fun — making music and visuals with Strudel, and jamming together with Konditorei.
---

Today, why don't we code something just for fun? You heard me right — coding can be fun. We can do games, music, trippy visuals. And with all this AI around, we have to have some fun ourselves: AI is not going to have fun for you. So in this video, let's go algoraving with [Strudel](https://strudel.cc/), and I'll show you a little game I built so we can jam together.

## What is Strudel?

Open [strudel.cc](https://strudel.cc/) and you land on the main interface: essentially a synthesizer that you control with a weird-looking language. Don't worry — it's just [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) with a few hacks, a browser port of the [TidalCycles](https://tidalcycles.org/) pattern language. With `$:` you start a new track, and `s()` selects the sounds:

```js
$: s("[bd ~ bd <hh oh>]*2").bank("tr909").dec(.4)
```

That's a bass drum, hi-hats doubling the tempo, and an open hat, sounding like a [TR-909](https://www.roland.com/global/promos/roland_tr-909/). Every sound is enveloped, so you can set a decay to control how long it takes to fade out. A tilde (`~`) is a silence. From these few elements you can build up patterns any way you want.

The [workshop](https://strudel.cc/workshop/getting-started/) in the Learn section covers notes, sounds, effects — everything. One example plays like a Casio watch; change the sound to `metal`, refresh, and it sounds like little metal. I do recommend going through the tutorial to understand notes, the drum notation, and the many functions you can play — and visualize — with.

## Jamming with Konditorei

The next question is how to jam with it, and for that I have a repo to share: [Konditorei](https://github.com/prodbytes/Konditorei), in our [ProdBytes org](https://github.com/prodbytes) on GitHub. It holds audio samples, code samples, and a little game I built for playing with friends. The easiest way in is the button to launch a [GitHub Codespace](https://github.com/features/codespaces) — the defaults work fine.

Under `loops/faermanj` you'll find my attempts at loops, and you are most welcome to send a PR and contribute to our bank. Since it's just JavaScript, you can create variables, functions, and constants as you like. A `samples()` call maps which file you want for each element of the sound notation, `setcps()` sets the tempo, and there are randomization functions like `perlin.range()` and `irand()`.

My simple drum loop is a stack of bass drums scattered in the proper timings, a snare, a crash every four measures, and four hi-hats — except that every four measures I take out the first two hi-hats so they don't clash with the crash cymbal. The `punchcard()` function is a nice way to visualize all of this: you can see the crash, the hi-hats, the two muted ones. I won't dive deep into Strudel here — this is just to show the kind of things you can do. It's a very powerful language with a very powerful synthesizer in the back, and honestly quite fun to work with.

## The game: two tracks, one vote

Even more fun if we do it together. The Konditorei game runs on port 3000 of your Codespace, exposed publicly, so you just open it in a browser. You get two panels of Strudel code — an A track and a B track — that you can play, flipping between one and the other. And there are visuals too, because Strudel includes [Hydra](https://hydra.ojack.xyz/): the pixelated Voronoi loop you see in the background is coded right next to the stack of bass drums, snares, hi-hats, and a C–E–G–B note sequence with a square wave, a low-pass filter, and gain.

Each sample has a QR code that opens it on a wider screen — on that machine or any other — where you can play it, or generate a new one if you don't like it. And you can vote for the side you prefer. The idea is that in a workshop, or a little competition, you can see which track gets more votes. The fun part is changing things and seeing what happens: swap the Roland kit for another one — there's a library of hundreds of sounds, all browsable in the [sounds tab](https://strudel.cc/learn/sounds/) of the REPL — and hear what comes out.

And again: it's just JavaScript. If you want to practice functions, encapsulation, functional programming, even object orientation, all of that is at your fingertips — with a beat as your test output.

## Inspiration and References

I wouldn't be able to do any of this if it weren't for some fantastic people in the live coding community:

- [Sam Aaron](https://www.youtube.com/@SamAaron), the inventor of [Sonic Pi](https://sonic-pi.net/) — another live coding synthesizer. His talks are great; start with [this one](https://www.youtube.com/watch?v=TK1mBqKvIyU).
- [Switch Angel](https://www.instagram.com/_switch_angel/), doing amazing things with code on stage.
- And most importantly, the one and only [DJ Dave](https://www.instagram.com/dj_dave____/): a huge inspiration, lots of good Strudel tips, great music, and a fantastic person. Thank you, DJ Dave.

I hope you get inspired to play with us in Strudel and Konditorei. I can't wait to hear what you build — what does YOUR first loop sound like? Share it in the comments, or send a PR to [Konditorei](https://github.com/prodbytes/Konditorei)!
