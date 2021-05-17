// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

/*
 * Buffer commands
 */
struct PutCmd {
mut:
	buffer &Buffer
	input InputType
}

fn (cmd PutCmd) str() string {
	return @STRUCT+' {
	buffer: ${ptr_str(cmd.buffer)}
	input: $cmd.input
}'
}

fn (mut cmd PutCmd) do() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	b.put(cmd.input)
}

fn (mut cmd PutCmd) undo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	b.del(-cmd.input.len())
}

fn (mut cmd PutCmd) redo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	b.put(cmd.input)
}

//
struct DelCmd {
mut:
	buffer &Buffer
	amount int
	deleted string
	pos Position
}

fn (cmd DelCmd) str() string {
	return @STRUCT+' {
	buffer: ${ptr_str(cmd.buffer)}
	amount: $cmd.amount
	deleted: $cmd.deleted
	pos: $cmd.pos
}'
}

fn (mut cmd DelCmd) do() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	cmd.pos = b.cursor.pos
	cmd.deleted = b.del(cmd.amount)
}

fn (mut cmd DelCmd) undo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	if cmd.amount < 0 {
		b.put(cmd.deleted)
	} else {
		b.cursor_to(cmd.pos.x, cmd.pos.y)
		b.put(cmd.deleted)
		b.cursor_to(cmd.pos.x, cmd.pos.y)
	}
}


fn (mut cmd DelCmd) redo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	if cmd.amount < 0 {
		b.del(cmd.amount)
	} else {
		b.cursor_to(cmd.pos.x, cmd.pos.y)
		b.del(cmd.amount)
	}
}

//
struct MoveCursorCmd {
mut:
	buffer &Buffer
	amount int
	movement Movement
	from_pos Position
	to_pos Position
}

fn (cmd MoveCursorCmd) str() string {
	return @STRUCT+' {
	buffer: ${ptr_str(cmd.buffer)}
	movement: $cmd.movement
}'
}

fn (mut cmd MoveCursorCmd) do() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	cmd.from_pos = b.cursor.pos
	b.move_cursor(cmd.amount, cmd.movement)
	cmd.to_pos = b.cursor.pos
}

fn (mut cmd MoveCursorCmd) undo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	b.cursor_to(cmd.from_pos.x, cmd.from_pos.y)
}

fn (mut cmd MoveCursorCmd) redo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	b.cursor_to(cmd.to_pos.x, cmd.to_pos.y)
}

/*
 * MoveToWord
 */
struct MoveToWordCmd {
mut:
	buffer &Buffer
	movement Movement
	from_pos Position
	to_pos Position
}

fn (cmd MoveToWordCmd) str() string {
	return @STRUCT+' {
	buffer: ${ptr_str(cmd.buffer)}
	movement: $cmd.movement
}'
}

fn (mut cmd MoveToWordCmd) do() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	cmd.from_pos = b.cursor.pos
	b.move_to_word(cmd.movement)
	cmd.to_pos = b.cursor.pos
}

fn (mut cmd MoveToWordCmd) undo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	b.cursor_to(cmd.from_pos.x, cmd.from_pos.y)
}


fn (mut cmd MoveToWordCmd) redo() {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
	}
	mut b := cmd.buffer
	b.cursor_to(cmd.to_pos.x, cmd.to_pos.y)
}
