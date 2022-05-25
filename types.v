// Copyright (c) 2020-2022 Lars Pontoppidan. All rights reserved.
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

type InputType = rune | string | u8

fn (ipt InputType) len() int {
	match ipt {
		u8, rune {
			return 1
		}
		string {
			return ipt.len
		}
	}
}

fn (ipt InputType) str() string {
	match ipt {
		u8 {
			return ipt.ascii_str()
		}
		rune {
			return [ipt].string()
		}
		string {
			return ipt.str()
		}
	}
}
