// Copyright (c) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

struct Cursor {
pub mut:
	pos Position
}

fn (mut c Cursor) set(x int, y int) {
	c.pos.x = x
	c.pos.y = y
}

fn (mut c Cursor) move(x int, y int) {
	c.pos.x += x
	c.pos.y += y
}

fn (c Cursor) xy() (int, int) {
	return c.pos.x, c.pos.y
}
