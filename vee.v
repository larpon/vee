// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

import vee.undo

struct Vee {
mut:
	buffers       []&Buffer
	active_buffer int
	history       undo.History
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

/*
pub fn (mut v Vee) put(ipt InputType) {
	v.put_buf(ipt, v.active_buffer)
}

pub fn (mut v Vee) put_buf(ipt InputType, id int) {
	//v.snapshots << v.snapshot()
	mut b := v.buffer(id)
	b.put(ipt)
}*/

pub fn (mut v Vee) buffer(id int) &Buffer {
	mut bid := id
	if v.buffers.len == 0 {
		// Add default buffer
		b := &Buffer{}
		v.add_buffer(b)
		bid = 0
		return b
	}
	if bid >= v.buffers.len || bid < 0 {
		bid = v.active_buffer
	}
	return v.buffers[bid]

}

pub fn (mut v Vee) active() &Buffer {
	return v.buffer(v.active_buffer)
}

pub fn (v Vee) dump() {
	for buffer in v.buffers {
		buffer.dump()
	}
}

pub fn (mut v Vee) add_buffer(b &Buffer) {
	v.buffers << b
	// TODO signal_buffer_added(b)
}
/*
pub fn (mut v Vee) del(amount int) string {
	return v.del_buf(amount, v.active_buffer)
}

pub fn (mut v Vee) del_buf(amount int, id int) string {
	mut b := v.buffer(id)
	return b.del(amount)
}*/

pub fn (mut v Vee) undo() {
	/*
	snapshot := v.snapshots.pop()
	//println(snapshot)
	//prev := json.raw_decode(snapshot) or { panic(err) }
	prev := json.decode<Vee>(snapshot)
	v.buffers = prev.buffers*/
}

/*
fn (v Vee) snapshot() string {
	//item := []undo.Item{}
	//v.undo.push()
	//vs := { v | active_buffer: 0 }
	return json.encode<Vee>(v)
}

pub fn (mut v Vee) from_json(f json.Any) {
	obj := f.as_map()
	for k, val in obj {
		match k {
			'buffers' {
				//println(val)
				//ba := val.arr()
				//for ab in ba {
				//	println(ab)
				//}
				//v.buffers = val.arr().map(
				//	json.decode<Buffer>(json.raw_decode(it.str())?.as_map())
				//)
			}
			else {}
		}
	}
}

pub fn (v Vee) to_json() string {
	mut obj := map[string]json.Any
	mut buffers := []json.Any{}
	for buffer in v.buffers {
		buffers << json.encode<Buffer>(buffer)
	}
    obj['buffers'] = buffers
    return obj.str()
}
*/
