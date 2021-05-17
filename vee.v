// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

import vee.undo

[heap]
struct Vee {
mut:
	buffers       []&Buffer
	active_buffer_id int
	invoker undo.Invoker
}

pub struct VeeConfig {
}

pub fn new(config VeeConfig) &Vee {
	ed := &Vee{}
	return ed
}

pub fn (mut v Vee) free() {
	$if debug { eprintln(@MOD+'.'+@STRUCT+'::'+@FN) }
	unsafe {
		for b in v.buffers {
			b.free()
			free(b)
		}
		v.buffers.free()
	}
}

pub fn (mut v Vee) new_buffer() int {
	b := new_buffer()
	return v.add_buffer(b)
}

pub fn (mut v Vee) buffer_at(id int) &Buffer {
	mut buf_idx := id
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' get buffer $id/${v.buffers.len}')
	}
	if v.buffers.len == 0 {
		// Add default buffer
		buf_idx = v.new_buffer()
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' added initial buffer')
		}
	}
	if buf_idx < 0 || buf_idx >= v.buffers.len {
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' invalid index "$buf_idx". Returning active')
		}
		// TODO also check that the active index can be reached
		buf_idx = v.active_buffer_id
	}
	return v.buffers[buf_idx]
}

pub fn (mut v Vee) active_buffer() &Buffer {
	return v.buffer_at(v.active_buffer_id)
}

pub fn (v Vee) dmp() {
	for buffer in v.buffers {
		buffer.dmp()
	}
}

pub fn (mut v Vee) add_buffer(b &Buffer) int {
	v.buffers << b
	// TODO signal_buffer_added(b)
	return v.buffers.len-1 // buffers.len-1, i.e. the index serves as the id
}

/*
 * Cursor movement
 */
pub fn (mut v Vee) cursor_to(pos Position) {
	v.active_buffer().cursor_to(pos.x, pos.y)
}
/*
fn (mut v Vee) buf_cursor_to(buffer_id int, pos Position) {
	v.buffer_at(buffer_id).cursor_to(pos.x, pos.y)
}*/

// move_cursor will navigate the cursor within the buffer bounds
pub fn (mut v Vee) move_cursor(amount int, movement Movement) {
	//v.active_buffer().move_cursor(amount, movement)

	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	mut cmd := &MoveCursorCmd{
		buffer: v.active_buffer()
		amount: amount
		movement: movement
	}
	v.invoker.add_and_execute(cmd)
}

pub fn (mut v Vee) move_to_word(movement Movement) {
	//v.active_buffer().move_to_word(movement)

	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	mut cmd := &MoveToWordCmd{
		buffer: v.active_buffer()
		movement: movement
	}
	v.invoker.add_and_execute(cmd)
}

/*
 * Undo/redo -able buffer commands
 */
pub fn (mut v Vee) put(input InputType) {
	// TODO CRITICAL it should be on the stack but there's a bug with interfaces preventing/corrupting the value of "vee"
	// NOTE that these aren't freed
	// See: https://discord.com/channels/592103645835821068/592294828432424960/842463741308436530
	mut cmd := &PutCmd{
		buffer: v.active_buffer()
		input: input
	}
	v.invoker.add_and_execute(cmd)
}

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

//
pub fn (mut v Vee) undo() bool {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut cmd := v.invoker.undo() or { return false }

	if cmd is MoveCursorCmd || cmd is MoveToWordCmd {
		cmd = v.invoker.peek(.undo) or { return true }
		for cmd is MoveCursorCmd || cmd is MoveToWordCmd {
			v.invoker.undo() or { return true }
			cmd = v.invoker.peek(.undo) or { return true }
		}
	}

	if cmd is PutCmd {
		cmd = v.invoker.peek(.undo) or { return true }
		for cmd is PutCmd {
			if mut cmd is PutCmd {
				str := cmd.input.str()
				if str.contains('\n') {
					return true
				}
			}
			v.invoker.undo() or { return true }
			cmd = v.invoker.peek(.undo) or { return true }
		}
	}

	if cmd is DelCmd {
		cmd = v.invoker.peek(.undo) or { return true }
		for cmd is DelCmd {
			if mut cmd is DelCmd {
				str := cmd.deleted.str()
				if str.contains('\n') {
					return true
				}
			}
			v.invoker.undo() or { return true }
			cmd = v.invoker.peek(.undo) or { return true }
		}
	}

	return true
}

pub fn (mut v Vee) redo() bool {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut cmd := v.invoker.redo() or { return false }

	if cmd is MoveCursorCmd || cmd is MoveToWordCmd {
		cmd = v.invoker.peek(.redo) or { return true }
		for cmd is MoveCursorCmd || cmd is MoveToWordCmd {
			v.invoker.redo() or { return true }
			cmd = v.invoker.peek(.redo) or { return true }
		}
	}

	if cmd is PutCmd {
		cmd = v.invoker.peek(.redo) or { return true }
		for cmd is PutCmd {
			if mut cmd is PutCmd {
				str := cmd.input.str()
				if str.contains('\n') {
					return true
				}
			}
			v.invoker.redo() or { return true }
			cmd = v.invoker.peek(.redo) or { return true }
		}
	}

	if cmd is DelCmd {
		cmd = v.invoker.peek(.redo) or { return true }
		for cmd is DelCmd {
			if mut cmd is DelCmd {
				str := cmd.deleted.str()
				if str.contains('\n') {
					return true
				}
			}
			v.invoker.redo() or { return true }
			cmd = v.invoker.peek(.redo) or { return true }
		}
	}
	return true
}


