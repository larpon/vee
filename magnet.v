// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

struct Magnet {
mut:
	buffer &Buffer
	//	record bool = true
	x int
}

pub fn (m Magnet) str() string {
	mut s := @MOD + '.Magnet{
	x: $m.x'
	s += '\n}'
	return s
}

// activate will adjust the cursor to as close valuses as the magnet as possible
pub fn (mut m Magnet) activate() {
	if m.x == 0 || isnil(m.buffer) {
		return
	}
	mut b := m.buffer
	// x, _ := m.buffer.cursor.xy()
	// line := b.cur_line()

	// if line.len == 0 {
	//	b.cursor.pos.x = 0
	//} else {
	b.cursor.pos.x = m.x
	//}
	b.sync_cursor()
}

// record will record the placement of the cursor
fn (mut m Magnet) record() {
	//!m.record ||
	if isnil(m.buffer) {
		return
	}
	m.x = m.buffer.cursor.pos.x
}

/*
fn (mut m Magnet) move_offrecord(amount int, movement Movement) {
	if isnil(m.buffer) { return }
	prev_recording_state := m.record
	m.record = false
	m.buffer.move_cursor(amount, movement)
	m.record = prev_recording_state
}*/
