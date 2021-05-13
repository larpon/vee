// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

import vee.undo

[heap]
struct Vee {
mut:
	buffers       []&Buffer
	active_buffer_index int
	command_history undo.History
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
		buf_idx = v.active_buffer_index
	}
	return v.buffers[buf_idx]

}

pub fn (mut v Vee) active_buffer() &Buffer {
	return v.buffer_at(v.active_buffer_index)
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
 * Undo/redo -able buffer commands
 */
pub fn (mut v Vee) put(input InputType) {
	v.buf_put(v.active_buffer_index, input)
}

pub fn (mut v Vee) buf_put(buffer_id int, input InputType) {
	mut cmd := PutCmd{
		vee: v
		buffer_id: buffer_id
		input: input
	}
	println(voidptr(&v))
	println(voidptr(v))
	cmd.do()
	v.command_history.push(cmd)
}

pub fn (mut v Vee) del(amount int) string {
	return v.buf_del(v.active_buffer_index, amount)
}

pub fn (mut v Vee) buf_del(buffer_id int, amount int) string {
	mut b := v.buffer_at(buffer_id)
	return b.del(amount)
}

/*
 * Commands
 */
struct PutCmd {
mut:
	vee &Vee
	buffer_id int
	pos Position
	input InputType
}
fn (cmd PutCmd) str() string {
	return 'PutCmd {
	vee: ${ptr_str(cmd.vee)}
	buffer_id: $cmd.buffer_id
	pod: $cmd.pos
	input: $cmd.input
}'
}

fn (mut cmd PutCmd) do() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+'\n$cmd $cmd.buffer_id')
	}
	mut b := cmd.vee.buffer_at(cmd.buffer_id)
	b.put(cmd.input)
	cmd.pos = b.cursor.pos
}

fn (mut cmd PutCmd) undo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+'\n$cmd $cmd.buffer_id')
	}
	mut b := cmd.vee.buffer_at(cmd.buffer_id)
	b.move_cursor_to(cmd.pos.x, cmd.pos.y)
	b.del(-cmd.input.len())
}

//
pub fn (mut v Vee) undo() bool {
	if v.command_history.len > 0 {
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
		}
		cmd := v.command_history.pop() or { return false }
		cmd.undo()
		return true
	}
	return false
}

pub fn (mut v Vee) redo() bool {
	if v.command_history.len > 0 {
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
		}
		//v.command_history.push(cmd)
		//TODO v.command_history.pop().redo()
		return true
	}
	return false
}

