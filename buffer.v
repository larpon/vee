// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

pub enum Movement {
	up
	down
	left
	right
	home
	end
}

struct Buffer {
pub mut:
	lines  []string
	cursor Cursor
	i      int
}

pub fn (b Buffer) flat() string {
	return b.raw().replace('\n',r'\n')
}

pub fn (b Buffer) raw() string {
	return b.lines.join('\n')
}

pub fn (b Buffer) cur_line() string {
	_, y := b.cursor.xy()
	if b.lines.len == 0 {
		return ''
	}
	return b.lines[y]
}

pub fn (b Buffer) cursor_index() int {
	mut i := 0
	for y, line in b.lines {
		if b.cursor.pos.y == y {
			i += b.cursor.pos.x
			break
		}
		i += line.len+1
	}
	return i
}

pub fn (mut b Buffer) put(ipt InputType) {
	s := ipt.str()
	has_line_ending := s.contains('\n')
	x, y := b.cursor.xy()
	if b.lines.len == 0 { b.lines.prepend('') }
	line := b.lines[y]
	l := line[..x]
	r := line[x..]
	if has_line_ending {
		mut lines := s.split('\n')
		lines[0] = l + lines[0]
		lines[lines.len - 1] += r
		b.lines.delete(y)
		b.lines.insert(y, lines)
		last := lines[lines.len - 1]
		b.cursor.set(last.len, y + lines.len - 1)
	} else {
		b.lines[y] = l + s + r
		b.cursor.set(x + s.len, y)
	}
	$if debug {
		flat := s.replace('\n',r'\n')
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' "$flat"')
	}
}

pub fn (mut b Buffer) del(amount int) string {
	if amount == 0 { return '' }
	x, y := b.cursor.xy()
	if amount < 0 {
		if x == 0 && y == 0 { return '' }
	} else {
		if x >= b.cur_line().len && y >= b.lines.len-1 { return '' }
	}
	mut removed := ''
	//line := b.lines[y]
	if amount < 0 { // backspace (backward)
		i := b.cursor_index()
		removed = b.raw()[i+amount..i]
		mut left := amount * -1
		for li := y; li >= 0 && left > 0; li-- {
			ln := b.lines[li]
			if left > ln.len {
				b.lines.delete(li)
				if ln.len == 0 { // TODO line break delimiter
					left--
					if y == 0 { return '' }
					line_above := b.lines[li-1]
					b.cursor.pos.x = line_above.len
				} else {
					left -= ln.len
				}
				b.cursor.pos.y--
			} else {
				if x == 0 {
					if y == 0 { return '' }
					line_above := b.lines[li-1]
					if ln.len == 0 { // at line break
						b.lines.delete(li)
						b.cursor.pos.y--
						b.cursor.pos.x = line_above.len
					} else {
						b.lines[li-1] = line_above + ln
						b.lines.delete(li)
						b.cursor.pos.y--
						b.cursor.pos.x = line_above.len
					}
				} else if x == 1 {
					b.lines[li] = b.lines[li][left..]
					b.cursor.pos.x = 0
				} else {
					b.lines[li] = ln[..x-left]+ln[x..]
					b.cursor.pos.x -= left
				}
				left = 0
				break
			}
		}
	} else { // delete (forward)
		i := b.cursor_index()+1
		removed = b.raw()[i-amount..i]
		mut left := amount
		for li := y; li >= 0 && left > 0; li++ {
			ln := b.lines[li]
			if x == ln.len { // at line end
				if y + 1 <= b.lines.len {
					b.lines[li] = ln + b.lines[y + 1]
					b.lines.delete(y + 1)
					left--
					b.del(left)
				}
			} else if left > ln.len {
				b.lines.delete(li)
				left -= ln.len
			} else {
				b.lines[li] = ln[..x]+ln[x+left..]
				left = 0
			}
		}
	}
	$if debug {
		flat := removed.replace('\n',r'\n')
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' "$flat"')
	}
	return removed
}

fn (b Buffer) dump() {
	eprintln('$b.cursor.pos\n${b.raw()}')
}

fn (mut b Buffer) free() {
	$if debug { eprintln(@MOD+'.'+@STRUCT+'::'+@FN) }
	for line in b.lines {
		line.free()
	}
	unsafe {
		b.lines.free()
	}
}

// move_cursor will navigate the cursor within the buffer bounds
pub fn (mut b Buffer) move_cursor(amount int, movement Movement) {
	pos := b.cursor.pos
	cur_line := b.cur_line()
	match movement {
		.up {
			if pos.y - amount >= 0 {
				b.cursor.move(0, -amount)
				// Check the move
				line := b.cur_line()
				if b.cursor.pos.x > line.len {
					b.cursor.set(line.len, b.cursor.pos.y)
				}
			}
		}
		.down {
			if pos.y + amount < b.lines.len {
				b.cursor.move(0, amount)
				// Check the move
				line := b.cur_line()
				if b.cursor.pos.x > line.len {
					b.cursor.set(line.len, b.cursor.pos.y)
				}
			}
		}
		.left {
			if pos.x - amount >= 0 {
				b.cursor.move(-amount,0)
			}
		}
		.right {
			if pos.x + amount <= cur_line.len {
				b.cursor.move(amount,0)
			}
		}
		.home {
			b.cursor.set(0,b.cursor.pos.y)
		}
		.end {
			b.cursor.set(cur_line.len, b.cursor.pos.y)
		}
	}
}

struct CursorPosition {
pub mut:
	x int
	y int
}

struct Cursor {
pub mut:
	pos CursorPosition
}

pub fn (mut c Cursor) set(x int, y int) {
	c.pos.x = x
	c.pos.y = y
}

pub fn (mut c Cursor) move(x int, y int) {
	c.pos.x += x
	c.pos.y += y
}

fn (c Cursor) xy() (int, int) {
	return c.pos.x, c.pos.y
}
