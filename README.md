## This is another of my fork(s)

* **[Get the original lite here](https://github.com/rxi/lite)** — Download
  for unix and unix like.


* You'll need a custom SDL2 — **[mySDL2](https://github.com/HackIT/mySDL2)**
* And also SDL2_image

### picz from the lab


![screenshot](https://raw.githubusercontent.com/HackIT/lite/master/screenshot.png)

#### the console behavior is non-interactive, throw a cmd and get feedback... nah enouf? use your terminal...
- ctrl+: => open a console view...
- ctrl+shift+: => throw a command to your bash shell...

#### to keep track from runtime errors and information.
- ctrl+! => open up **the** log view

#### filemanager, a context menu is planned...
- ctrl+shift+t => open up a semi interactive file browser on the window's left side walking CWD...

#### walk through cmd by typing... it doesn't list entirely...
- ctrl+shift+p => open up internal command handler...

#### file related... should be common to writerz.
- ctrl+o => open up an existing file...
- ctrl+n => open up a new file...
- ctrl+s => save up the current files with modifs...
- ctrl+w => to close the current file...

#### syntax based binding
- ctrl+* => comment up a line using syntax's pattern.

- ctrl+q => quit the software...

## DONE
- linux clipboards
- moved syntaxes and colors to their own dir...
- removed plugins and now loading them using a list
- reloading modules works out of the box without overlaping...
- swapped some keybinding to more common one... (at least for me...)

## TODO
- auto increase mouse selection for document while close to the frame edges 
- audio engine
- binary report tools
- store session
- rounded rectangle
- code folding
- more plugins
- remove the ugly tabs
- keep track/handling with mouse/key press events and feedback into statusview
- scroll feedback using sort* icons into the statusview

## HACK lite/.lite_project.lua

- project session for rapid devel...


	local core = require "core"

	core.root_view:open_doc(core.open_doc("/home/<user>/lite/LICENSE"))
	core.root_view:open_doc(core.open_doc("/home/<user>/lite/README.md"))
	core.root_view:open_doc(core.open_doc("/home/<user>/lite/data/<file>"))

	print("hello world o/")

## License
This project is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

