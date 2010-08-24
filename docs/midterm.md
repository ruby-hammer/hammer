# RubySoC Midterm

## Week 1 - Beginning

I had some basic tests before RSoC started. But it was just scribbled code. So first week was
about setting up proper development environment:

- Central logger
- Automatic loading of all files and reloading on file-change.
  - gem require_all
  - rack/reloader
- environments: development, production etc...
- yard documentation
- prepare rspec
- make gem
- etc.

## Week 2 - I love EventMachine

From start I did some minor improvements:
- central configuration, gem configliere
- auto wrapping of widgets with a element properly css-classed and identified

This week was mainly about EventMachine, Fibers and WebSsocket. Core was almost completely rewritten.

Originally a was planing to transport all requests with AJAX and later add some tool for server-side pushes.
But as I dive in to it, I decided to go on even more unconventional path.

All communication between client and server is moved to a bidirectional connection. Right now it's based on
WebSocket and gem em-websocket therefore framework supports only Chrome and theoretically Safari for now.
There is a fiberpool in core where scheduled blocks of code are running. Fibers can be paused during
IO operations (like in em-symphony) so they are nonblocking. Additionally each context (tab in browser) can run
only one scheduled block of code at the time (next blocks are added to queue) for state not to mess up.

Scheduled blocks can be client's requests to run a action, some server-side initialized actualization etc.
It's a block so whatever you need can be scheduled to execution and actualization of web page can be easily pushed
to client.

I wrote the log observer to test it. It's on #devel and it actualize clients web page as new log are coming.

## Week 3 - Core improvements

I continued to work and improve core.

- Communication between server and client was simplified.
- Context releasing was corrected and observer with event channels was added.
- Errors became safely caught and a communication with user was added besides debug in JS console.

And:

To test how writing components and widgets feel I wrote Object inspectors. It also helped me to find leaks.
But in the end I correct a few things to make it runnable on 1.8.7 and used gem memprof.

## Week 4 - Forms, Rspec, Chat

- Basic forms was added and sub-widgets for input, select, textarea.
- Rspec tests was added to ensure at least a little that it works as supposed to.
- I wrote simple implementation of Chat. It does not have any persistence. Chat rooms are dropped from memory
after 4 hours of inactivity and messages are limited to 50 per room. But it nicely demonstrate where this framework
will be good at.

## Week 5 - New name, Chat hosting, Midterm, Refactoring

- New final name was picked for framework - Hammer. I hope framework will fulfill its name.
- I started to preparing server to support hammer's chat. It was not as easy as I hoped.
  I had to remove gem require_all for unreliability and fix some other bugs to make it a little stable.
- I looked at performance and tweaked rendering by 10-20%.
- **Finally I bumped version to 0.0.1 !**

In the rest of the week I refactored and restructured source to use module pattern - used by i18n 0.4 and erector 0.8.

## Future

### Rendering

Is slow so what to do with it? Plan is to:
1. implement layer to monitor changes and render and send to client just changes not entire page.
2. look at speed again.
3. try to move rendering to other processes ? Test it if it gives any improvement.

### Other

- WebSocket flash fallback for Firebox
- Nice urls
- CSS definitions on widget's class level
- Internationalization
- General improvements:
  - Richer objects for prototyping
  - Js callbacks
  - Smarter forms
  - etc.

