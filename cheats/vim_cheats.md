# VIM-Cheatsheet
## ToDo
:

## System
<multiplier><action><direction>

## Movement
Move Up by paragraph: (
Move Down by paragraph: )

## Actions
GoTo: <linenumber> g
* Insert
   * Char: i(insert), a(ppend)
   * Line: I(nsert), A(ppend)
* Mark: v
   * Block: ctrl+v
Delete: d
Change: c
Paste: p
Indent: >

## Search and Replace
current file, globally, ask: :%s/<find>/<replace>/gc
all files in tree: 
* All tex-files in current/sub directories: `:arg **/*.tex`
* S&R globally but ask:`:argdo %s/pattern/replace/ge | update`

### Directions
#### What
* Next word: w(ord), e(nd
* Backwords: b
* In Between: i (next or surrounding)
   * HTML Tag: cit

#### Up To
Beginning of Line: 0
End of Line: $
First occurence: f


Repeat Last Command: .

Scroll Page up: Ctrl+u
Scroll Page down: Ctrl+d

Find first right occurance in line: f+<symbol>
Find first left occurance in line: F+<symbol>

### Common Tasks
Copy to system clipboard: " + y
Insert in front on multiple lines: ctrl+v I
Insert behind multiple lines: ctrl+v $ A

 %s/foo/bar/gc
