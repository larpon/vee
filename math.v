// Copyright (c) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by the MIT license distributed with this software.
module vee

[inline]
fn imax(x int, y int) int {
	return if x < y { y } else { x }
}

[inline]
fn imin(x int, y int) int {
	return if x < y { x } else { y }
}
