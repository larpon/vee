// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module undo

import x.json2 as json

//type Item = json.Any

struct History {
mut:
	items []json.Any
}

fn (mut h History) push(object json.Any) {
	h.items << object
}

fn (mut h History) pop() ?json.Any {
	if h.items.len > 0 {
		return h.items.pop()
	}
	return none
}
