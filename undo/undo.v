// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module undo

pub enum QueueType {
	command
	undo
	redo
}

interface ICommand {
	do()
	undo()
	redo()
}

struct Invoker {
mut:
	queue []ICommand
	undo_stack []ICommand
	redo_stack []ICommand
}

pub fn (mut i Invoker) add_and_execute(cmd ICommand) {
	i.add(cmd)
	i.execute()
}

pub fn (mut i Invoker) add(cmd ICommand) {
	i.queue << cmd
}

pub fn (mut i Invoker) peek(queue_type QueueType) ?ICommand {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+'('+typeof(queue_type).name+')')
	}
	match queue_type {
		.command {
			if i.queue.len > 0 {
				cmd := i.queue.last()
				return cmd
			}
		}
		.undo {
			if i.undo_stack.len > 0 {
				cmd := i.undo_stack.last()
				return cmd
			}
		}
		.redo {
			if i.redo_stack.len > 0 {
				cmd := i.redo_stack.last()
				return cmd
			}
		}
	}

	return none
}

pub fn (mut i Invoker) execute() bool {
	if i.queue.len > 0 {
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
		}
		i.redo_stack.clear()
		cmd := i.queue.pop()
		cmd.do()
		i.undo_stack << cmd
		return true
	}
	return false
}

pub fn (mut i Invoker) undo() ?ICommand {
	if i.undo_stack.len > 0 {
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
		}
		cmd := i.undo_stack.pop()
		cmd.undo()
		i.redo_stack << cmd
		return cmd
	}
	return none
}

pub fn (mut i Invoker) redo() ?ICommand {
	if i.redo_stack.len > 0 {
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN)
		}
		cmd := i.redo_stack.pop()
		cmd.redo()
		i.undo_stack << cmd
		return cmd
	}
	return none
}
