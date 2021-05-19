module main

import vee

fn test_basics() {
	mut ed := vee.new({})
	mut buf := ed.active_buffer()

	ed.put('Hello World')
	assert buf.flat() == 'Hello World'

	ed.del(-1) // 'Hello Worl'
	assert buf.flat() == 'Hello Worl'

	ed.del(-5) // 'Hello'
	assert buf.flat() == 'Hello'

	ed.move_cursor(1, .left) //@<o>
	ed.del(1) // 'Hell'
	assert buf.flat() == 'Hell'

	ed.put('\nand hallo Vee')
	// println('"${buf.flat()}" (${buf.cursor.pos.x},${buf.cursor.pos.y})/${buf.cursor_index()}')
	// 'Hell'
	// 'and hallo Vee'
	assert buf.flat() == r'Hell\nand hallo Vee'

	ed.move_cursor(4, .left) //@< >Vee
	ed.del(4)
	// 'Hell'
	// 'and hallo'
	assert buf.flat() == r'Hell\nand hallo'

	ed.move_cursor(9, .left) //@<a>nd hal...
	ed.del(-1) // 'Helland hallo'
	assert buf.flat() == 'Helland hallo'
	// println('"${buf.flat()}" (${buf.cursor.pos.x},${buf.cursor.pos.y}/${buf.cursor_index()})')

	ed.move_cursor(1, .home) //@<H>elland ...
	// println('"${buf.raw()}" (${buf.cursor.pos.x},${buf.cursor.pos.y}/${buf.cursor_index()})')
	ed.del(9) // 'allo'
	ed.put('H') // 'H█allo'
	assert buf.flat() == 'Hallo'

	ed.move_cursor(1, .end)
	ed.put(' again') // 'Hallo again█'
	assert buf.flat() == 'Hallo again'

	ed.put('\nTEST') // 'Hallo again\nTEST█'
	// println('"${buf.flat()}" (${buf.cursor.pos.x},${buf.cursor.pos.y}/${buf.cursor_index()})')

	ed.undo() // Undo all put commands so far (which is ' again','\nTEST')
	assert buf.flat() == 'Hallo'

	ed.redo()
	assert buf.flat() == r'Hallo again\nTEST'

	ed.undo()
	assert buf.flat() == 'Hallo'

	ed.put('\n') // 'Hallo\n█'
	assert buf.flat() == r'Hallo\n'
	ed.put_line_break() // 'Hallo\n\n█'
	assert buf.flat() == r'Hallo\n\n'
	ed.put_line_break() // 'Hallo\n\n█'
	assert buf.flat() == r'Hallo\n\n\n'

	ed.undo()
	assert buf.flat() == 'Hallo'

	// println('"${buf.raw()}" (${buf.cursor.pos.x},${buf.cursor.pos.y}/${buf.cursor_index()})')

	ed.free()
}
