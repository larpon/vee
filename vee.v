// Copyright (c) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

import strings
import vee.command

@[heap]
pub struct Vee {
mut:
	buffers          []&Buffer
	active_buffer_id int
	invoker          command.Invoker
}

pub struct View {
pub:
	raw    string
	cursor Cursor
}

pub struct VeeConfig {
}

// new returns a new heap-allocated `Vee` instance.
pub fn new(config VeeConfig) &Vee {
	ed := &Vee{}
	return ed
}

// view returns a `View` of the buffer between `from` and `to`.
pub fn (mut v Vee) view(from int, to int) View {
	mut b := v.active_buffer()

	b.magnet.activate()

	slice := b.cur_slice().runes()
	mut tabs := 0
	mut vx := 0
	for i := 0; i < slice.len; i++ {
		if slice[i] == `\t` {
			vx += b.tab_width
			tabs++
			continue
		}
		vx++
	}
	x := vx

	/*
	if tabs > 0 && x > b.magnet.x {
		x = b.magnet.x
		b.cursor.pos.x = x
	}*/

	mut lines := []string{}
	for i, line in b.lines {
		if i >= from && i <= to {
			lines << line
		}
	}
	raw := lines.join(b.line_break)
	return View{
		raw:    raw.replace('\t', strings.repeat(` `, b.tab_width))
		cursor: Cursor{
			pos: Position{
				x: x
				y: b.cursor.pos.y
			}
		}
	}
}

// free frees resources from this `Vee` instance.
pub fn (mut v Vee) free() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)
	unsafe {
		for b in v.buffers {
			b.free()
			free(b)
		}
		v.buffers.free()
	}
}

// new_buffer creates a new buffer and returns it's id for later reference.
pub fn (mut v Vee) new_buffer() int {
	b := new_buffer(BufferConfig{})
	return v.add_buffer(b)
}

// buffer_at returns the `Buffer` instance with `id`.
pub fn (mut v Vee) buffer_at(id int) &Buffer {
	mut buf_idx := id
	// dbg(@MOD+'.'+@STRUCT+'::'+@FN+' get buffer $id/${v.buffers.len}')
	if v.buffers.len == 0 {
		// Add default buffer
		buf_idx = v.new_buffer()
		dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' added initial buffer')
	}
	if buf_idx < 0 || buf_idx >= v.buffers.len {
		dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' invalid index "${buf_idx}". Returning active')
		// TODO also check that the active index can be reached
		buf_idx = v.active_buffer_id
	}
	return v.buffers[buf_idx]
}

// active_buffer returns the currently active `Buffer` instance.
pub fn (mut v Vee) active_buffer() &Buffer {
	return v.buffer_at(v.active_buffer_id)
}

// dmp dumps all buffers to std_err.
pub fn (v Vee) dmp() {
	for buffer in v.buffers {
		buffer.dmp()
	}
}

// add_buffer adds the `Buffer` `b` and returns it's `id`.
pub fn (mut v Vee) add_buffer(b &Buffer) int {
	v.buffers << b
	// TODO signal_buffer_added(b)
	return v.buffers.len - 1 // buffers.len-1, i.e. the index serves as the id
}

/*
* Cursor movement
*/
// cursor_to move the cursor position to `pos`.
pub fn (mut v Vee) cursor_to(pos Position) {
	mut b := v.active_buffer()
	b.cursor_to(pos.x, pos.y)
}

// move_cursor navigates the cursor within the buffer bounds
pub fn (mut v Vee) move_cursor(amount int, movement Movement) {
	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	mut cmd := &MoveCursorCmd{
		buffer:   v.active_buffer()
		amount:   amount
		movement: movement
	}
	v.invoker.add_and_execute(cmd)
}

// move_to_word navigates the cursor to the nearst word in the given direction.
pub fn (mut v Vee) move_to_word(movement Movement) {
	// v.active_buffer().move_to_word(movement)

	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	mut cmd := &MoveToWordCmd{
		buffer:   v.active_buffer()
		movement: movement
	}
	v.invoker.add_and_execute(cmd)
}

/*
* Undo/redo -able buffer commands
*/
// put adds `input` to the active `Buffer`.
pub fn (mut v Vee) put(input InputType) {
	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	b := v.active_buffer()
	if input is string && input.str() == b.line_break {
		mut cmd := &PutLineBreakCmd{
			buffer: b
		}
		v.invoker.add(cmd)
	} else {
		mut cmd := &PutCmd{
			buffer: b
			input:  input
		}
		v.invoker.add(cmd)
	}
	v.invoker.execute()
}

// put_line_break adds a line break to the active `Buffer`.
pub fn (mut v Vee) put_line_break() {
	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	mut cmd := &PutLineBreakCmd{
		buffer: v.active_buffer()
	}
	v.invoker.add_and_execute(cmd)
}

// del deletes `amount` of characters from the active `Buffer`.
// An `amount` > 0 will delete `amount` characters to the *right* of the cursor.
// An `amount` < 0 will delete `amount` characters to the *left* of the cursor.
pub fn (mut v Vee) del(amount int) {
	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	mut cmd := &DelCmd{
		buffer: v.active_buffer()
		amount: amount
	}
	v.invoker.add_and_execute(cmd)
}

// undo undo the last executed command.
pub fn (mut v Vee) undo() bool {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut cmd := v.invoker.undo() or { return false }

	match cmd {
		MoveCursorCmd, MoveToWordCmd {
			cmd = v.invoker.peek(.undo) or { return true }
			for cmd is MoveCursorCmd || cmd is MoveToWordCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' MoveXXXCmd streak')

				v.invoker.undo() or { return true }
				cmd = v.invoker.peek(.undo) or { return true }
			}
		}
		PutCmd {
			cmd = v.invoker.peek(.undo) or { return true }
			for cmd is PutCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' PutCmd streak')

				v.invoker.undo() or { return true }
				cmd = v.invoker.peek(.undo) or { return true }
			}
		}
		PutLineBreakCmd {
			cmd = v.invoker.peek(.undo) or { return true }
			for cmd is PutLineBreakCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' PutLineBreakCmd streak')

				v.invoker.undo() or { return true }
				cmd = v.invoker.peek(.undo) or { return true }
			}
		}
		DelCmd {
			cmd = v.invoker.peek(.undo) or { return true }
			for cmd is DelCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' DelCmd streak')

				v.invoker.undo() or { return true }
				cmd = v.invoker.peek(.undo) or { return true }
			}
		}
		else {
			return true
		}
	}

	return true
}

// redo redo the last undone command.
pub fn (mut v Vee) redo() bool {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut cmd := v.invoker.redo() or { return false }
	match cmd {
		MoveCursorCmd, MoveToWordCmd {
			cmd = v.invoker.peek(.redo) or { return true }
			for cmd is MoveCursorCmd || cmd is MoveToWordCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' MoveXXXCmd streak')

				v.invoker.redo() or { return true }
				cmd = v.invoker.peek(.redo) or { return true }
			}
		}
		PutCmd {
			cmd = v.invoker.peek(.redo) or { return true }
			for cmd is PutCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' PutCmd streak')

				v.invoker.redo() or { return true }
				cmd = v.invoker.peek(.redo) or { return true }
			}
		}
		PutLineBreakCmd {
			cmd = v.invoker.peek(.redo) or { return true }
			for cmd is PutLineBreakCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' PutLineBreakCmd streak')

				v.invoker.redo() or { return true }
				cmd = v.invoker.peek(.redo) or { return true }
			}
		}
		DelCmd {
			cmd = v.invoker.peek(.redo) or { return true }
			for cmd is DelCmd {
				dbg(@MOD + '.' + @STRUCT + '::' + @FN + ' DelCmd streak')

				v.invoker.redo() or { return true }
				cmd = v.invoker.peek(.redo) or { return true }
			}
		}
		else {
			return true
		}
	}
	return true
}
