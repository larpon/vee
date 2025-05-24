// Copyright (c) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

import encoding.utf8

const rune_digits = [`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`]

struct Position {
pub mut:
	x int
	y int
}

struct Selection {
	buffer &Buffer
mut:
	from Position
	to   Position
}

@[heap]
struct Buffer {
	line_break string = '\n'
pub:
	tab_width int = 4
mut:
	mode       Mode = .edit
	selections []Selection
pub mut:
	lines  []string
	cursor Cursor
	magnet Magnet
}

pub struct BufferConfig {
	line_break string = '\n'
	tab_width  int    = 4
}

// new_buffer returns a new heap-allocated `Buffer` instance.
pub fn new_buffer(config BufferConfig) &Buffer {
	mut b := &Buffer{
		line_break: config.line_break
	}
	m := Magnet{
		buffer: b
	}
	b.magnet = m
	return b
}

// set_mode sets the edit mode to `mode`.
pub fn (mut b Buffer) set_mode(mode Mode) {
	b.mode = mode
}

// flatten returns `s` as a "flat" `string`.
// Escape characters are visible.
pub fn (b Buffer) flatten(s string) string {
	return s.replace(b.line_break, r'\n').replace('\t', r'\t')
}

// flat returns the buffer as a "flat" `string`.
// Escape characters are visible.
pub fn (b Buffer) flat() string {
	return b.flatten(b.raw())
}

// raw returns the contents of the buffer as-is.
pub fn (b Buffer) raw() string {
	return b.lines.join(b.line_break)
}

// eol returns `true` if the cursor is at the end of a line.
pub fn (b Buffer) eol() bool {
	x, y := b.cursor.xy()
	line := b.line(y).runes()
	return x >= line.len
}

// eof returns `true` if the cursor is at the end of the file/buffer.
pub fn (b Buffer) eof() bool {
	_, y := b.cursor.xy()
	return y >= b.lines.len - 1
}

// cur_char returns the character at the cursor.
pub fn (b Buffer) cur_char() string {
	x, y := b.cursor.xy()
	line := b.line(y).runes()
	if x >= line.len {
		return ''
	}
	// TODO check if this is needed
	return [line[x]].string()
}

// cur_rune returns the character at the cursor.
pub fn (b Buffer) cur_rune() rune {
	c := b.cur_char().runes()
	if c.len > 0 {
		return c[0]
	}
	return rune(0)
}

// prev_rune returns the previous rune.
pub fn (b Buffer) prev_rune() rune {
	c := b.prev_char().runes()
	if c.len > 0 {
		return c[0]
	}
	return rune(0)
}

// prev_char returns the previous character.
pub fn (b Buffer) prev_char() string {
	mut x, y := b.cursor.xy()
	x--
	line := b.line(y).runes()
	if x >= line.len || x < 0 {
		return ''
	}
	// TODO check if this is needed
	return [line[x]].string()
}

// cur_slice returns the contents from start of
// the current line up until the cursor.
pub fn (b Buffer) cur_slice() string {
	x, y := b.cursor.xy()
	line := b.line(y).runes()
	if x == 0 || x > line.len {
		return ''
	}
	return line[..x].string()
}

// line returns the contents of the line at `y`.
pub fn (b Buffer) line(y int) string {
	if y < 0 || y >= b.lines.len {
		return ''
	}
	return b.lines[y]
}

// line returns the contents of the line the cursor is at.
pub fn (b Buffer) cur_line() string {
	_, y := b.cursor.xy()
	return b.line(y)
}

// cur_line_flat returns the "flat" contents of the line the cursor is at.
pub fn (b Buffer) cur_line_flat() string {
	return b.flatten(b.cur_line())
}

// cursor_index returns the linear index of the cursor.
pub fn (b Buffer) cursor_index() int {
	mut i := 0
	for y, line in b.lines {
		if b.cursor.pos.y == y {
			i += b.cursor.pos.x
			break
		}
		i += line.runes().len + 1
	}
	return i
}

// put adds `input` to the buffer.
pub fn (mut b Buffer) put(ipt InputType) {
	s := ipt.str()
	dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' "${b.flatten(s)}"')

	// println('s.len: $s.len, s.runes().len: ${s.runes().len} `$s.runes()`')

	has_line_ending := s.contains(b.line_break)
	x, y := b.cursor.xy()
	if b.lines.len == 0 {
		b.lines.prepend('')
	}
	line := b.lines[y].runes()
	l, r := line[..x].string(), line[x..].string()
	if has_line_ending {
		mut lines := s.split(b.line_break)
		lines[0] = l + lines[0]
		lines[lines.len - 1] += r
		b.lines.delete(y)
		b.lines.insert(y, lines)
		last := lines[lines.len - 1].runes()
		b.cursor.set(last.len, y + lines.len - 1)
		if s == b.line_break {
			b.cursor.set(0, b.cursor.pos.y)
		}
	} else {
		b.lines[y] = l + s + r
		b.cursor.set(x + s.runes().len, y)
	}
	b.magnet.record()
	// dbg(@MOD+'.'+@STRUCT+'::'+@FN+' "${b.flat()}"')
}

// put_line_break adds a line break to the buffer.
pub fn (mut b Buffer) put_line_break() {
	b.put(b.line_break)
	dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' "${b.flat()}"')
}

// del deletes `amount` of characters from the buffer.
// An `amount` > 0 will delete `amount` characters to the *right* of the cursor.
// An `amount` < 0 will delete `amount` characters to the *left* of the cursor.
pub fn (mut b Buffer) del(amount int) string {
	if amount == 0 {
		return ''
	}
	x, y := b.cursor.xy()
	if amount < 0 { // don't delete left if we're at 0,0
		if x == 0 && y == 0 {
			return ''
		}
	} else if x >= b.cur_line().runes().len && y >= b.lines.len - 1 {
		return ''
	}
	mut removed := ''
	if amount < 0 { // backspace (backward)
		i := b.cursor_index()
		raw_runes := b.raw().runes()
		// println('raw_runes: $raw_runes')
		// println('amount: $amount, i: $i')

		removed = raw_runes[i + amount..i].string()
		mut left := amount * -1

		// println('removed: `$removed`')
		// println(@MOD+'.'+@STRUCT+'::'+@FN+' "${b.flat()}" (${b.cursor.pos.x},${b.cursor.pos.y}/$i) $amount')

		for li := y; li >= 0 && left > 0; li-- {
			ln := b.lines[li].runes()
			// println(@MOD+'.'+@STRUCT+'::'+@FN+' left: $left, line length: $ln.len')
			if left == ln.len + 1 { // All of the line + 1 - since we're going backwards the "+1" is the line break delimiter.
				b.lines.delete(li)
				left = 0
				if y == 0 {
					return ''
				}
				line_above := b.lines[li - 1].runes()
				b.cursor.pos.x = line_above.len
				b.cursor.pos.y--
				break
			} else if left > ln.len {
				b.lines.delete(li)
				if ln.len == 0 { // line break delimiter
					left--
					if y == 0 {
						return ''
					}
					line_above := b.lines[li - 1].runes()
					b.cursor.pos.x = line_above.len
				} else {
					left -= ln.len
				}
				b.cursor.pos.y--
			} else {
				if x == 0 {
					if y == 0 {
						return ''
					}
					line_above := b.lines[li - 1].runes()
					if ln.len == 0 { // at line break
						b.lines.delete(li)
						b.cursor.pos.y--
						b.cursor.pos.x = line_above.len
					} else {
						b.lines[li - 1] = line_above.string() + ln.string()
						b.lines.delete(li)
						b.cursor.pos.y--
						b.cursor.pos.x = line_above.len
					}
				} else if x == 1 {
					runes := b.lines[li].runes()
					b.lines[li] = runes[left..].string()
					b.cursor.pos.x = 0
				} else {
					b.lines[li] = ln[..x - left].string() + ln[x..].string()
					b.cursor.pos.x -= left
				}
				left = 0
				break
			}
		}
	} else { // delete (forward)
		i := b.cursor_index() + 1
		raw_buffer := b.raw().runes()
		from_i := i
		mut to_i := i + amount

		if to_i > raw_buffer.len {
			to_i = raw_buffer.len
		}
		removed = raw_buffer[from_i..to_i].string()

		mut left := amount
		for li := y; li >= 0 && left > 0; li++ {
			ln := b.lines[li].runes()
			if x == ln.len { // at line end
				if y + 1 <= b.lines.len {
					b.lines[li] = ln.string() + b.lines[y + 1]
					b.lines.delete(y + 1)
					left--
					b.del(left)
				}
			} else if left > ln.len {
				b.lines.delete(li)
				left -= ln.len
			} else {
				b.lines[li] = ln[..x].string() + ln[x + left..].string()
				left = 0
			}
		}
	}
	b.magnet.record()
	// dbg(@MOD+'.'+@STRUCT+'::'+@FN+' "${b.flat()}"')

	dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' "${b.flat()}"-"${b.flatten(removed)}"')

	return removed
}

fn (b Buffer) dmp() {
	eprintln('${b.cursor.pos}\n${b.raw()}')
}

// free frees all buffer memory
fn (mut b Buffer) free() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	unsafe {
		for line in b.lines {
			line.free()
		}
		b.lines.free()
	}
}

// cursor_to sets the cursor within the buffer bounds
pub fn (mut b Buffer) cursor_to(x int, y int) {
	b.cursor.set(x, y)
	b.sync_cursor()
	b.magnet.record()
}

// sync_cursor syncs the cursor position to be within the buffer bounds
fn (mut b Buffer) sync_cursor() {
	x, y := b.cursor.xy()
	if x < 0 {
		b.cursor.pos.x = 0
	}
	if y < 0 {
		b.cursor.pos.y = 0
	}
	line := b.cur_line().runes()
	if x >= line.len {
		if line.len <= 0 {
			b.cursor.pos.x = 0
		} else {
			b.cursor.pos.x = line.len
		}
	}
	if y > b.lines.len {
		if b.lines.len <= 0 {
			b.cursor.pos.y = 0
		} else {
			b.cursor.pos.y = b.lines.len - 1
		}
	}
}

// move_cursor navigates the cursor within the buffer bounds
pub fn (mut b Buffer) move_cursor(amount int, movement Movement) {
	pos := b.cursor.pos
	match movement {
		.up {
			if pos.y - amount >= 0 {
				b.cursor.move(0, -amount)
				b.sync_cursor()
				// b.magnet.activate()
			}
		}
		.down {
			if pos.y + amount < b.lines.len {
				b.cursor.move(0, amount)
				b.sync_cursor()
				// b.magnet.activate()
			}
		}
		.left {
			if pos.x - amount >= 0 {
				b.cursor.move(-amount, 0)
				b.sync_cursor()
				b.magnet.record()
			}
		}
		.right {
			if pos.x + amount <= b.cur_line().runes().len {
				b.cursor.move(amount, 0)
				b.sync_cursor()
				b.magnet.record()
			}
		}
		.page_up {
			dlines := imin(b.cursor.pos.y, amount)
			b.cursor.move(0, -dlines)
			b.sync_cursor()
			// b.magnet.activate()
		}
		.page_down {
			dlines := imin(b.lines.len - 1, b.cursor.pos.y + amount) - b.cursor.pos.y
			b.cursor.move(0, dlines)
			b.sync_cursor()
			// b.magnet.activate()
		}
		.home {
			b.cursor.set(0, b.cursor.pos.y)
			b.sync_cursor()
			b.magnet.record()
		}
		.end {
			b.cursor.set(b.cur_line().runes().len, b.cursor.pos.y)
			b.sync_cursor()
			b.magnet.record()
		}
	}
}

// move_to_word navigates the cursor to the nearst word in the given direction.
pub fn (mut b Buffer) move_to_word(movement Movement) {
	a := if movement == .left { -1 } else { 1 }

	mut line := b.cur_line().runes()
	mut x, mut y := b.cursor.pos.x, b.cursor.pos.y
	if x + a < 0 && y > 0 {
		y--
		line = b.line(b.cursor.pos.y - 1).runes()
		x = line.len
	} else if x + a >= line.len && y + 1 < b.lines.len {
		y++
		line = b.line(b.cursor.pos.y + 1).runes()
		x = 0
	}
	// first, move past all non-`a-zA-Z0-9_` characters
	for x + a >= 0 && x + a < line.len && !(utf8.is_letter(line[x + a])
		|| line[x + a] in rune_digits || line[x + a] == `_`) {
		x += a
	}
	// then, move past all the letters and numbers
	for x + a >= 0 && x + a < line.len && (utf8.is_letter(line[x + a])
		|| line[x + a] in rune_digits || line[x + a] == `_`) {
		x += a
	}
	// if the cursor is out of bounds, move it to the next/previous line
	if x + a >= 0 && x + a <= line.len {
		x += a
	} else if a < 0 && y + 1 > b.lines.len && y - 1 >= 0 {
		y += a
		x = 0
	}
	b.cursor.set(x, y)
	b.magnet.record()
}

/*
* Selections
*/
// set_default_select sets the default selection.
pub fn (mut b Buffer) set_default_select(from Position, to Position) {
	b.set_select(0, from, to)
}

// set_select sets the selection `index`.
pub fn (mut b Buffer) set_select(index int, from Position, to Position) {
	if b.mode != .@select {
		b.mode = .@select
	}
	if b.selections.len == 0 {
		b.selections << Selection{
			from:   from
			to:     to
			buffer: b
		}
	} else {
		// TODO bounds check or map ??
		b.selections[index].from = from
		b.selections[index].to = to
	}
}

// selection_at sets the default selection at `index`.
pub fn (b Buffer) selection_at(index int) Selection {
	// TODO bounds check or map ??
	return b.selections[index]
}
