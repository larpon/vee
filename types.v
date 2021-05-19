// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

pub enum Movement {
	up
	down
	left
	right
	page_up
	page_down
	home
	end
}

pub enum Mode {
	edit
	@select
}

type InputType = byte | rune | string

fn (ipt InputType) len() int {
	match ipt {
		byte, rune {
			return 1
		}
		string {
			return ipt.len
		}
	}
}

fn (ipt InputType) str() string {
	match ipt {
		byte, rune {
			return ipt.str()
		}
		string {
			return ipt.str()
		}
	}
}
