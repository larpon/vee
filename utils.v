// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

[if vee_debug ?]
fn dbg(str string) {
	eprintln(str)
}
