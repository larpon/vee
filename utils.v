// Copyright (c) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

[if debug_vee ?]
fn dbg(str string) {
	eprintln(str)
}
