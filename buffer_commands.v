// Copyright (c) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

/*
* Buffer commands
*/
struct PutCmd {
mut:
	buffer &Buffer
	input  InputType
}

fn (cmd PutCmd) str() string {
	return @STRUCT + ' {
	buffer: ${ptr_str(cmd.buffer)}
	input: ${cmd.input}
}'
}

fn (mut cmd PutCmd) do() {
	mut b := cmd.buffer
	b.put(cmd.input)
}

fn (mut cmd PutCmd) undo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	b.del(-cmd.input.len())
}

fn (mut cmd PutCmd) redo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	b.put(cmd.input)
}

//
struct PutLineBreakCmd {
mut:
	buffer &Buffer
}

fn (cmd PutLineBreakCmd) str() string {
	return @STRUCT + ' {
	buffer: ${ptr_str(cmd.buffer)}
}'
}

fn (mut cmd PutLineBreakCmd) do() {
	cmd.buffer.put_line_break()
}

fn (mut cmd PutLineBreakCmd) undo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	b.del(-1)
}

fn (mut cmd PutLineBreakCmd) redo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	cmd.buffer.put_line_break()
}

//
struct DelCmd {
mut:
	buffer  &Buffer
	amount  int
	deleted string
	pos     Position
}

fn (cmd DelCmd) str() string {
	return @STRUCT +
		' {
	buffer: ${ptr_str(cmd.buffer)}
	amount: ${cmd.amount}
	deleted: ${cmd.deleted}
	pos: ${cmd.pos}
}'
}

fn (mut cmd DelCmd) do() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	cmd.pos = b.cursor.pos
	cmd.deleted = b.del(cmd.amount)
}

fn (mut cmd DelCmd) undo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

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
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

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
	buffer   &Buffer
	amount   int
	movement Movement
	from_pos Position
	to_pos   Position
}

fn (cmd MoveCursorCmd) str() string {
	return @STRUCT + ' {
	buffer: ${ptr_str(cmd.buffer)}
	movement: ${cmd.movement}
}'
}

fn (mut cmd MoveCursorCmd) do() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	cmd.from_pos = b.cursor.pos
	b.move_cursor(cmd.amount, cmd.movement)
	cmd.to_pos = b.cursor.pos
}

fn (mut cmd MoveCursorCmd) undo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	b.cursor_to(cmd.from_pos.x, cmd.from_pos.y)
}

fn (mut cmd MoveCursorCmd) redo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	b.cursor_to(cmd.to_pos.x, cmd.to_pos.y)
}

/*
* MoveToWord
*/
struct MoveToWordCmd {
mut:
	buffer   &Buffer
	movement Movement
	from_pos Position
	to_pos   Position
}

fn (cmd MoveToWordCmd) str() string {
	return @STRUCT + ' {
	buffer: ${ptr_str(cmd.buffer)}
	movement: ${cmd.movement}
}'
}

fn (mut cmd MoveToWordCmd) do() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	cmd.from_pos = b.cursor.pos
	b.move_to_word(cmd.movement)
	cmd.to_pos = b.cursor.pos
}

fn (mut cmd MoveToWordCmd) undo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	b.cursor_to(cmd.from_pos.x, cmd.from_pos.y)
}

fn (mut cmd MoveToWordCmd) redo() {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN)

	mut b := cmd.buffer
	b.cursor_to(cmd.to_pos.x, cmd.to_pos.y)
}
