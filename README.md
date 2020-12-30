## This is another of my fork(s)

* **[Get the original lite here](https://github.com/rxi/lite)** — Download
  for unix and unix like.


* You'll need a patched SDL2 — **[mySDL2](https://github.com/HackIT/mySDL2)**
- this SDL supports default X11 clipboards commonly used with GNU/Linux®

### picz from the lab

![screenshot](https://raw.githubusercontent.com/HackIT/lite/master/screenshot.png)

![screenshot](https://raw.githubusercontent.com/HackIT/lite/master/workspace.png)

#### the console behavior is non-interactive, throw a cmd and get feedback... nah enouf? use your terminal...
- **ctrl+:** => open a console view...
- **ctrl+shift+:** => throw a command to your bash shell...

#### to keep track from runtime errors and information.
- **ctrl+!** => open up **the** log view

#### filemanager, a context menu is planned...
- **ctrl+shift+t** => open up a semi interactive file browser on the window's left side walking CWD...

#### walk through cmd by typing... it doesn't list entirely...
- **ctrl+shift+p** => open up internal command handler...

#### file related... should be common to writerz.
- **ctrl+o** => open up an existing file...
- **ctrl+n** => open up a new file...
- **ctrl+s** => save up the current files with modifs...
- **ctrl+shift+s** => save up current file to the desired filename
- **ctrl+z** => undo
- **ctrl+shift+z** => redo
- **ctrl+w** => to close the current file...

#### related to selection into a document...
- **ctrl+a** => select all from the current file.
- **ctrl+x** => cut selection
- **ctrl+c** => copy selection
- **ctrl+l** => select entire line
- **ctrl+d** => select word
- **ctrl+v** => paste selection to the current cursor position

#### split document workspace into multiple workspaces

see workspace screenshot for an overview...

- **alt+shift+l** => split to the right 
- **alt+shift+k** => split to down
- **alt+shift+j** => split to left
- **alt+shift+i** => split to up

Remember that you need to grab focus(click inside workspace)

from workspace you wish to work on... like opening new/existing document...

#### syntax based binding
- **ctrl+*** => comment up a line using syntax's pattern.

- **ctrl+q** => quit the software...

## DONE
- linux clipboards
- moved syntaxes and colors to their own dir...
- removed plugins and now loading them using a list.
- reloading modules works out of the box without overlaping...
- swapped some keybinding to more common one... (at least for me...)
- added accurate scrolling methods to every view needing a scroll method.
- added correct focus to let current doc keep focus as well.
- removed tabs to use that space for the documents which is better, to me.
- numerical file handler into statusview, mouse handling to be added still...
- add back ubuntu® fonts and struct access for futur usage...
- fixed workspaces partially, still need a driver to grab focus using kbd.
- more fix around workspaces, can't open copy from opened files (through nodes :)) and grab focus from original instead.

     # statusview scheme
     dirty | openfiles/index | filename | line/col percent    icon | total lines | line ending 

## TODO
- <s>independent documents</s> now needs to track on disk file changes?...
- need a way to switch between workspace(s) using the keyboard
- user styles loads after logging...
- a markdown viewer from lite engine... will need img renderer...
- multi selection/cursor
- highlight gutter instead line
- keep track/handling with mouse/key press events and feedback into statusview
- phased rendering, orchestration and composition (you wouldn't believe how short it's gonna be compared to the fancy words...)
- windowed plugins using lite
- audio engine
- binary report tools
- store session
- rounded rectangle
- code folding
- more plugins
- auto increase mouse selection for document while close to the frame edges
- scroll feedback using sort* icons into the statusview

## HACK lite/.lite_project.lua

- project session for rapid devel...


```lua
local core = require "core"

core.root_view:open_doc(core.open_doc("/home/<user>/lite/LICENSE"))
core.root_view:open_doc(core.open_doc("/home/<user>/lite/README.md"))
core.root_view:open_doc(core.open_doc("/home/<user>/lite/data/<file>"))

print("hello world o/")
```

## License
The code base is MIT licensed. I still didn't decide what license to use for my additions...

I retain copyright & terms from my additions following the BERN convention while deciding what I do.

You can read the terms of the MIT license for all code covered by rxi. See [LICENSE](LICENSE) for details.

###### Enjoy,                                               HackIT.

###### BTC: bc1q5jw0dsgc4x96l0um6vqexp5kq7wthlfvz944uc


