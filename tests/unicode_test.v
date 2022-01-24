module main

import vee

fn test_unicode() {
	mut ed := vee.new(vee.VeeConfig{})
	buf := ed.active_buffer()

	ed.put('Hello World')
	assert buf.flat() == 'Hello World'

	assert buf.cursor_index() == 11

	ed.del(-5) // 'Hello '
	assert buf.cursor_index() == 6
	ed.put('🌐')
	assert buf.flat() == 'Hello 🌐'
	assert buf.cursor_index() == 7

	ed.del(-1) // 'Hello '
	assert buf.cursor_index() == 6
	ed.put('World')
	assert buf.flat() == 'Hello World'
	assert buf.cursor_index() == 11

	ed.del(-5) // 'Hello '
	assert buf.cursor_index() == 6
	ed.put('🌐 and 🌐')
	assert buf.flat() == 'Hello 🌐 and 🌐'
	assert buf.cursor_index() == 13

	ed.move_cursor(7, .left) //@<🌐> and...
	assert buf.cursor_index() == 6
	ed.del(2) // 'Hello and 🌐'
	assert buf.cursor_index() == 6
	assert buf.flat() == 'Hello and 🌐'

	// Hello |and 🌐
	ed.put('"ƒ ✔ ❤ ☆" ')
	assert buf.flat() == 'Hello "ƒ ✔ ❤ ☆" and 🌐'

	// Hello "ƒ ✔ ❤ ☆" |and 🌐
	assert buf.cursor_index() == 16

	ed.del(-1) // 'Hello "ƒ ✔ ❤ ☆"and 🌐'
	assert buf.flat() == 'Hello "ƒ ✔ ❤ ☆"and 🌐'
	ed.del(5) // 'Hello "ƒ ✔ ❤ ☆"'
	assert buf.flat() == 'Hello "ƒ ✔ ❤ ☆"'

	assert buf.cursor_index() == 15

	ed.move_cursor(9, .left)
	ed.del(9) // 'Hello '
	assert buf.flat() == 'Hello '

	ed.put('ƒ ✔ ❤')
	assert buf.flat() == 'Hello ƒ ✔ ❤'

	// Hello| ƒ ✔ ❤
	ed.move_to_word(.left)
	assert buf.cursor_index() == 5
}
