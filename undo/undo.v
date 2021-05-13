// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module undo

//import x.json2 as json

//type Item = json.Any

interface IHistoryCommand {
	do()
	undo()
}


struct History {
pub mut:
	len int
mut:
	items []IHistoryCommand
}

pub fn (mut h History) push(object IHistoryCommand) {
	h.items << object
	h.len = h.items.len
}

pub fn (mut h History) pop() ?IHistoryCommand {
	if h.items.len > 0 {
		item := h.items.pop()
		h.len = h.items.len
		return item
	}
	return none
}
