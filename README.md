## AwfuLite - My next text editor ...

![screenshot](https://raw.githubusercontent.com/752963e64/AwfuLite/master/screenshot.png)

![screenshot](https://raw.githubusercontent.com/752963e64/AwfuLite/master/workspace.png)

2 way to demo something... you fuel the engine or you engineering the fuel.

HackIT is me, also [Awaxx] and 752963e64. I'm not schizo :)

### How to install

depends on SDL2 and xsel & hexdump comand line tools.

```bash
git clone https://github.com/752963e64/AwfuLite
cd AwfuLite
./build.sh
./lite
```

### How to handle the beast

#### the console behavior is non-interactive, throw a cmd and get feedback... nah enouf? use your terminal...
- **ctrl+:** => open a console view...
- **ctrl+shift+:** => throw a command to your bash shell...

#### to keep track from runtime errors and information.
- **ctrl+!** => open up **the** log view

#### filemanager, a context menu is planned...
- **ctrl+shift+t** => open up a semi interactive file browser on the window's left side walking CWD...

#### walk through cmd by typing... it doesn't list entirely...
- **ctrl+shift+p** => open up internal command handler...
- **escape** => close the command handler if opened...
- **up|down** => select command into the list if opened...
- **return** => throw the choosen command if opened...
- **tab** => autocomplete commands if opened...

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
- **ctrl+v** => paste selection to the current text cursor position
- **ctrl+up|down** => hold entire line from current text cursor position and swap to the given direction

#### split document workspace into multiple workspaces

see workspace screenshot for an overview...

- **alt+shift+l** => split to the right 
- **alt+shift+k** => split to down
- **alt+shift+j** => split to left
- **alt+shift+i** => split to up

- **alt+j** => switch to left workspace
- **alt+l** => switch right workspace
- **alt+i** => switch up workspace
- **alt+k** => switch down workspace


#### syntax based binding
- **ctrl+*** => comment up a line using syntax's pattern.

- **ctrl+q** => quit the software...



### Stuff DONE

```
- linux clipboards
- added more font icons
- moved syntaxes and colors to their own dir...
- removed plugins and now loading them using a list.
- reloading modules works out of the box without overlaping...
- swapped some keybinding to more common one... (at least for me...)
- added accurate scrolling methods to every view needing a scroll method.
- added correct focus to let current doc keep focus as well.
- removed tabs to use that space for the documents which is better, to me.
- numerical file handler into statusview, mouse handling to be added still...
- add back ubuntu® fonts and struct access for futur usage...
- more fix around workspaces, can't open copy from opened files (through nodes :)) and grab focus from original instead.
- ( ctrl+a, ctrl+c, alt+shift+j, ctrl+n, ctrl+v ) is the way to open a copy from the current document...
- autoscroll (up'n down)
- mouse scroll feedback into statusview
- added show_block_rulers to docview.
- added space and tab rendering.
- improved tokenizer to catch more token
- added markers to docview. original implementation by Petri Häkkinen
- added dynamic current working directory, changeable from commands
- improved selection engine to handle multiselection modes
- ( ctrl + left mouse button => permits to place cursors anywhere you wish )
- ( shift + right mouse button => permits to select vertically up'n down right'to left )
- added correct column tracking over unicode
- fixed focus through nodes...

     # statusview scheme
     (document changes appears orange) dirty | openfiles/index | filename | line/col percent    icon | total lines | line ending | (mixed tab/space document ~= config appears orange) tabtype tabsize
```

### Some TODO

```
- I want selection store to atleast work in lite... workaround can be applied with xsel if it exists.
- bottom file navigator is a bit ill... to be reworked with abrain :Ð.
- dynamic font scaling...
- add a debug mode to docview... surface usually split verticaly to print step information
- abrupt selections kills the feel someone human did it... gotta test smooth methods :Ð
- implement a timeline player.
- overlaping box which act as menu pop... 
- mouse feedback in statusview doesn't handle multiple workspace
- git driver driven by commands/shortcuts
- add an acceleration method for autoscroll
- add pattern text matching methods to multi selection
- fix undo/redo with multi selection
- <s>independent documents</s> now needs to track on disk file changes?...
- user styles loads after logging...
- a markdown viewer from lite engine... will need img renderer...
- highlight gutter instead line
- phased rendering, orchestration and composition
- windowed plugins using lite
- audio engine
- binary report tools
- store session
- rounded rectangle
- code folding
- more plugins
```

### HACK lite/.lite_project.lua

- project session for rapid devel...

```lua
local core = require "core"

core.root_view:open_doc(core.open_doc("/home/<user>/lite/LICENSE"))
core.root_view:open_doc(core.open_doc("/home/<user>/lite/README.md"))
core.root_view:open_doc(core.open_doc("/home/<user>/lite/data/<file>"))

print("hello world o/")
```

## License
**[lite](https://github.com/rxi/lite)** is MIT licensed. I still didn't decide what license to use for my additions...

I retain copyright & terms from my additions following the BERN convention while deciding what I do.

To be clear I do not accept someone making money from my fork while I starve... however you can use it and modify it personally or even get inspired of it ... just don't fucking copy for a bad context :)

You can read the terms of the MIT license for all code covered by rxi & contributors. See [LICENSE](LICENSE) for details.

###### All been told, Enjoy.                                              by HackIT.


