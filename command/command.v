// Copyright (c) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module command

pub enum QueueType {
	execute
	undo
	redo
}

interface ICommand {
mut:
	do()
	undo()
	redo()
}

struct Invoker {
mut:
	command_queue []ICommand
	undo_stack    []ICommand
	redo_stack    []ICommand
}

pub fn (mut i Invoker) add_and_execute(cmd ICommand) {
	i.add(cmd)
	i.execute()
}

pub fn (mut i Invoker) add(cmd ICommand) {
	i.command_queue << cmd
}

pub fn (mut i Invoker) peek(queue_type QueueType) ?ICommand {
	dbg(@MOD + '.' + @STRUCT + '::' + @FN + '(' + queue_type.str() + ')')

	match queue_type {
		.execute {
			if i.command_queue.len > 0 {
				return i.command_queue.last()
			}
		}
		.undo {
			if i.undo_stack.len > 0 {
				return i.undo_stack.last()
			}
		}
		.redo {
			if i.redo_stack.len > 0 {
				return i.redo_stack.last()
			}
		}
	}

	return none
}

pub fn (mut i Invoker) execute() bool {
	if i.command_queue.len > 0 {
		dbg(@MOD + '.' + @STRUCT + '::' + @FN)

		i.redo_stack.clear()
		mut cmd := i.command_queue.pop()
		cmd.do()
		i.undo_stack << cmd
		return true
	}
	return false
}

pub fn (mut i Invoker) undo() ?ICommand {
	if i.undo_stack.len > 0 {
		dbg(@MOD + '.' + @STRUCT + '::' + @FN)

		mut cmd := i.undo_stack.pop()
		cmd.undo()
		i.redo_stack << cmd
		return cmd
	}
	return none
}

pub fn (mut i Invoker) redo() ?ICommand {
	if i.redo_stack.len > 0 {
		dbg(@MOD + '.' + @STRUCT + '::' + @FN)

		mut cmd := i.redo_stack.pop()
		cmd.redo()
		i.undo_stack << cmd
		return cmd
	}
	return none
}

[if vee_debug ?]
fn dbg(str string) {
	eprintln(str)
}
