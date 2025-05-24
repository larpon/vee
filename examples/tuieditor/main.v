module main

import os
import term
import term.ui
import vee
import encoding.utf8.east_asian

const space_unicode = [
	`\u0009`, // U+0009 CHARACTER TABULATION
	`\u0020`, // U+0020 SPACE
	`\u00ad`, // U+00AD SOFT HYPHEN
	`\u115f`, // U+115F HANGUL CHOSEONG FILLER
	`\u1160`, // U+1160 HANGUL JUNGSEONG FILLER
	`\u2000`, // U+2000 EN QUAD
	`\u2001`, // U+2001 EM QUAD
	`\u2002`, // U+2002 EN SPACE
	`\u2003`, // U+2003 EM SPACE
	`\u2004`, // U+2004 THREE-PER-EM SPACE
	`\u2005`, // U+2005 FOUR-PER-EM SPACE
	`\u2006`, // U+2006 SIX-PER-EM SPACE
	`\u2007`, // U+2007 FIGURE SPACE
	`\u2008`, // U+2008 PUNCTUATION SPACE
	`\u2009`, // U+2009 THIN SPACE
	//`\u200a`, // U+200A HAIR SPACE
	`\u202f`, // U+202F NARROW NO-BREAK SPACE
	`\u205f`, // U+205F MEDIUM MATHEMATICAL SPACE
	`\u3000`, // U+3000 IDEOGRAPHIC SPACE
	`\u2800`, // U+2800 BRAILLE PATTERN BLANK
	`\u3164`, // U+3164 HANGUL FILLER
	`\uffa0`, // U+FFA0 HALFWIDTH HANGUL FILLER
]

const no_space_unicode = [
	`\u034f`, // U+034F COMBINING GRAPHEME JOINER
	`\u061c`, // U+061C ARABIC LETTER MARK
	`\u17b4`, // U+17B4 KHMER VOWEL INHERENT AQ
	`\u17b5`, // U+17B5 KHMER VOWEL INHERENT AA
	`\u200a`, // U+200A HAIR SPACE
	`\u200b`, // U+200B ZERO WIDTH SPACE
	`\u200c`, // U+200C ZERO WIDTH NON-JOINER
	`\u200d`, // U+200D ZERO WIDTH JOINER
	`\u200e`, // U+200E LEFT-TO-RIGHT MARK
	`\u200f`, // U+200F RIGHT-TO-LEFT MARK
	`\u2060`, // U+2060 WORD JOINER
	`\u2061`, // U+2061 FUNCTION APPLICATION
	`\u2062`, // U+2062 INVISIBLE TIMES
	`\u2063`, // U+2063 INVISIBLE SEPARATOR
	`\u2064`, // U+2064 INVISIBLE PLUS
	`\u206a`, // U+206A INHIBIT SYMMETRIC SWAPPING
	`\u206b`, // U+206B ACTIVATE SYMMETRIC SWAPPING
	`\u206c`, // U+206C INHIBIT ARABIC FORM SHAPING
	`\u206d`, // U+206D ACTIVATE ARABIC FORM SHAPING
	`\u206e`, // U+206E NATIONAL DIGIT SHAPES
	`\u206f`, // U+206F NOMINAL DIGIT SHAPES
	`\ufeff`, // U+FEFF ZERO WIDTH NO-BREAK SPACE
]

const invisible_unicode = [
	`\u0009`, // U+0009 CHARACTER TABULATION
	`\u0020`, // U+0020 SPACE
	`\u00ad`, // U+00AD SOFT HYPHEN
	`\u034f`, // U+034F COMBINING GRAPHEME JOINER
	`\u061c`, // U+061C ARABIC LETTER MARK
	`\u115f`, // U+115F HANGUL CHOSEONG FILLER
	`\u1160`, // U+1160 HANGUL JUNGSEONG FILLER
	`\u17b4`, // U+17B4 KHMER VOWEL INHERENT AQ
	`\u17b5`, // U+17B5 KHMER VOWEL INHERENT AA
	`\u180e`, // U+180E MONGOLIAN VOWEL SEPARATOR
	`\u2000`, // U+2000 EN QUAD
	`\u2001`, // U+2001 EM QUAD
	`\u2002`, // U+2002 EN SPACE
	`\u2003`, // U+2003 EM SPACE
	`\u2004`, // U+2004 THREE-PER-EM SPACE
	`\u2005`, // U+2005 FOUR-PER-EM SPACE
	`\u2006`, // U+2006 SIX-PER-EM SPACE
	`\u2007`, // U+2007 FIGURE SPACE
	`\u2008`, // U+2008 PUNCTUATION SPACE
	`\u2009`, // U+2009 THIN SPACE
	`\u200a`, // U+200A HAIR SPACE
	`\u200b`, // U+200B ZERO WIDTH SPACE
	`\u200c`, // U+200C ZERO WIDTH NON-JOINER
	`\u200d`, // U+200D ZERO WIDTH JOINER
	`\u200e`, // U+200E LEFT-TO-RIGHT MARK
	`\u200f`, // U+200F RIGHT-TO-LEFT MARK
	`\u202f`, // U+202F NARROW NO-BREAK SPACE
	`\u205f`, // U+205F MEDIUM MATHEMATICAL SPACE
	`\u2060`, // U+2060 WORD JOINER
	`\u2061`, // U+2061 FUNCTION APPLICATION
	`\u2062`, // U+2062 INVISIBLE TIMES
	`\u2063`, // U+2063 INVISIBLE SEPARATOR
	`\u2064`, // U+2064 INVISIBLE PLUS
	`\u206a`, // U+206A INHIBIT SYMMETRIC SWAPPING
	`\u206b`, // U+206B ACTIVATE SYMMETRIC SWAPPING
	`\u206c`, // U+206C INHIBIT ARABIC FORM SHAPING
	`\u206d`, // U+206D ACTIVATE ARABIC FORM SHAPING
	`\u206e`, // U+206E NATIONAL DIGIT SHAPES
	`\u206f`, // U+206F NOMINAL DIGIT SHAPES
	`\u3000`, // U+3000 IDEOGRAPHIC SPACE
	`\u2800`, // U+2800 BRAILLE PATTERN BLANK
	`\u3164`, // U+3164 HANGUL FILLER
	`\ufeff`, // U+FEFF ZERO WIDTH NO-BREAK SPACE
	`\uffa0`, // U+FFA0 HALFWIDTH HANGUL FILLER
	/*
		`\u1d159`, // U+1D159 MUSICAL SYMBOL NULL NOTEHEAD
		`\u1d173`, // U+1D173 MUSICAL SYMBOL BEGIN BEAM
		`\u1d174`, // U+1D174 MUSICAL SYMBOL END BEAM
		`\u1d175`, // U+1D175 MUSICAL SYMBOL BEGIN TIE
		`\u1d176`, // U+1D176 MUSICAL SYMBOL END TIE
		`\u1d177`, // U+1D177 MUSICAL SYMBOL BEGIN SLUR
		`\u1d178`, // U+1D178 MUSICAL SYMBOL END SLUR
		`\u1d179`, // U+1D179 MUSICAL SYMBOL BEGIN PHRASE
		`\u1d17a`, // U+1D17A MUSICAL SYMBOL END PHRASE
		*/
]

struct App {
mut:
	tui            &ui.Context = unsafe { nil }
	ed             &vee.Vee    = unsafe { nil }
	file           string
	status         string
	status_timeout int
	footer_height  int = 2
	viewport       int
	debug_mode     bool = true
}

fn (mut a App) set_status(msg string, duration_ms int) {
	a.status = msg
	a.status_timeout = duration_ms
}

fn (mut a App) undo() {
	if a.ed.undo() {
		a.set_status('Undid', 2000)
	}
}

fn (mut a App) redo() {
	if a.ed.redo() {
		a.set_status('Redid', 2000)
	}
}

fn (mut a App) save() {
	if a.file.len > 0 {
		b := a.ed.active_buffer()
		os.write_file(a.file, b.raw()) or { panic(err) }
		a.set_status('Saved', 2000)
	} else {
		a.set_status('No file loaded', 4000)
	}
}

fn (a &App) view_height() int {
	return a.tui.window_height - a.footer_height - 1
}

fn (mut a App) footer() {
	w, h := a.tui.window_width, a.tui.window_height
	// term.set_cursor_position({x: 0, y: h-1})

	mut b := a.ed.active_buffer()

	mut finfo := ''
	if a.file.len > 0 {
		finfo = ' (' + os.file_name(a.file) + ')'
	}

	mut status := a.status
	a.tui.draw_text(0, h - 1, '─'.repeat(w))
	footer := '${finfo} Line ${b.cursor.pos.y + 1:4}/${b.lines.len:-4}, Column ${b.cursor.pos.x + 1:3}/${b.cur_line().len:-3} index: ${b.cursor_index():5} (ESC = quit, Ctrl+s = save)'
	if footer.len < w {
		a.tui.draw_text((w - footer.len) / 2, h, footer)
	} else if footer.len == w {
		a.tui.draw_text(0, h, footer)
	} else {
		a.tui.draw_text(0, h, footer[..w])
	}
	if a.status_timeout <= 0 {
		status = ''
	} else {
		a.tui.set_bg_color(
			r: 200
			g: 200
			b: 200
		)
		a.tui.set_color(
			r: 0
			g: 0
			b: 0
		)
		a.tui.draw_text((w + 4 - status.len) / 2, h - 1, ' ${status} ')
		a.tui.reset()

		if a.status_timeout <= 0 {
			a.status_timeout = 0
		} else {
			a.status_timeout -= int(1000 / 60) // a.tui.cfg.frame_rate
		}
	}

	if a.status_timeout <= 0 {
		status = ''
	}
}

fn (mut a App) dbg_overlay() {
	if !a.debug_mode {
		return
	}
	w, h := a.tui.window_width, a.tui.window_height
	w050 := int(f32(w) * 0.5)
	// term.set_cursor_position({x: w050, y: 0})
	mut b := a.ed.active_buffer()

	cur_line := b.cur_line_flat().runes()
	line_snippet := if cur_line.len > w050 - 30 { cur_line[..w050 - 30 - 1] } else { cur_line }.string()
	// buffer_flat := b.flat()
	// buffer_snippet := if flat.len > w050-30 { flat[..w050-30] } else { flat }

	text := 'PID ${os.getpid()}
Char bytes    "${b.cur_char().bytes()}"
PrevChar "${literal(b.prev_char())}/${east_asian.display_width(b.prev_char(),
		1)}"
Char     "${literal(b.cur_char())}/${east_asian.display_width(b.cur_char(),
		1)}"
Slice    "${literal(b.cur_slice())} ${b.cur_slice().len}/${b.cur_slice().runes().len}/${east_asian.display_width(b.cur_slice(),
		1)}"
Line     "${line_snippet}  ${line_snippet.len}/${line_snippet.runes().len}/${east_asian.display_width(line_snippet,
		1)}"
EOL      ${b.eol()}
EOF      ${b.eof()}
Buffer lines ${b.lines.len}
${flatten(b.cursor.str())}
${flatten(b.magnet.str())}
'
	a.tui.reset_bg_color()
	a.tui.reset_color()
	a.tui.draw_rect(w050, 0, w, h - a.footer_height)
	lines := text.split('\n')
	for i, line in lines {
		a.tui.draw_text(w050 + 2, 1 + i, line)
	}
	a.tui.set_bg_color(
		r: 200
		g: 200
		b: 200
	)
	a.tui.draw_line(w050, 0, w050, h - a.footer_height)
	a.tui.reset_bg_color()
}

fn flatten(s string) string {
	return s.replace('\t', ' ').replace('  ', ' ').replace('\n', ' ').replace('  ', ' ').replace('  ',
		' ').replace('  ', ' ')
}

fn literal(s string) string {
	return s.replace('\t', r'\t').replace('\n', r'\n')
}

fn init(x voidptr) {
	mut a := unsafe { &App(x) }
	a.ed = vee.new(vee.VeeConfig{})
	mut init_x := 0
	mut init_y := 0
	if a.file.len > 0 {
		if !os.is_file(a.file) && a.file.contains(':') {
			// support the file:line:col: format
			fparts := a.file.split(':')
			if fparts.len > 0 {
				a.file = fparts[0]
			}
			if fparts.len > 1 {
				init_y = fparts[1].int() - 1
			}
			if fparts.len > 2 {
				init_x = fparts[2].int() - 1
			}
		}
		if os.is_file(a.file) {
			a.tui.set_window_title(a.file)
			mut b := a.ed.active_buffer()
			content := os.read_file(a.file) or { panic(err) }
			b.put(content)
			b.cursor_to(init_x, init_y)
		}
	}
}

fn frame(x voidptr) {
	mut a := unsafe { &App(x) }
	mut buf := a.ed.active_buffer()
	a.tui.clear()
	scroll_limit := a.view_height()
	// scroll down
	if buf.cursor.pos.y > a.viewport + scroll_limit { // scroll down
		a.viewport = buf.cursor.pos.y - scroll_limit
	} else if buf.cursor.pos.y < a.viewport { // scroll up
		a.viewport = buf.cursor.pos.y
	}
	view := a.ed.view(a.viewport, scroll_limit + a.viewport)

	a.tui.draw_text(0, 0, view.raw)
	a.footer()
	a.dbg_overlay()

	mut ch_x := view.cursor.pos.x

	mut sl := buf.cur_slice().replace('\t', ' '.repeat(buf.tab_width))
	if sl.len > 0 {
		sl = sl.runes().filter(it !in no_space_unicode).string()
		ch_x = east_asian.display_width(sl, 1)
	}
	ch_x++

	a.tui.set_cursor_position(ch_x, buf.cursor.pos.y + 1 - a.viewport)
	a.tui.flush()
}

fn cleanup(x voidptr) {
	mut a := unsafe { &App(x) }
	a.ed.free()
	unsafe {
		free(a)
	}
}

fn fail(error string) {
	eprintln(error)
}

fn event(e &ui.Event, x voidptr) {
	mut a := unsafe { &App(x) }
	eprintln(e)
	if e.typ == .key_down {
		match e.code {
			.escape {
				term.set_cursor_position(x: 0, y: 0)
				exit(0)
			}
			.backspace {
				a.ed.del(-1)
			}
			.delete {
				a.ed.del(1)
			}
			.left {
				if e.modifiers == .ctrl {
					a.ed.move_to_word(.left)
				} else {
					a.ed.move_cursor(1, .left)
				}
			}
			.right {
				if e.modifiers == .ctrl {
					a.ed.move_to_word(.right)
				} else {
					a.ed.move_cursor(1, .right)
				}
			}
			.up {
				a.ed.move_cursor(1, .up)
			}
			.down {
				a.ed.move_cursor(1, .down)
			}
			.page_up {
				a.ed.move_cursor(a.view_height(), .page_up)
			}
			.page_down {
				a.ed.move_cursor(a.view_height(), .page_down)
			}
			.home {
				a.ed.move_cursor(1, .home)
			}
			.end {
				a.ed.move_cursor(1, .end)
			}
			48...57, 97...122 { // 0-9a-zA-Z
				if e.modifiers.has(.ctrl) {
					if e.code == .d {
						a.debug_mode = !a.debug_mode
					}
					if e.code == .s {
						a.save()
					}
					if e.code == .z {
						a.undo()
					}
					if e.code == .y {
						a.redo()
					}
				} else if e.modifiers.has(.alt) {
					if e.code == .z {
						a.redo()
					}
				} else if e.modifiers.has(.shift) || e.modifiers.is_empty() {
					a.ed.put(e.ascii.ascii_str())
				}
			}
			else {
				a.ed.put(e.utf8)
			}
		}
	} else if e.typ == .mouse_scroll {
		direction := if e.direction == .up { vee.Movement.down } else { vee.Movement.up }
		a.ed.move_cursor(3, direction)
	}
}

fn main() {
	mut file := ''
	if os.args.len > 1 {
		file = os.args[1]
	}
	mut a := &App{
		file: file
	}
	a.tui = ui.init(
		user_data:      a
		init_fn:        init
		frame_fn:       frame
		cleanup_fn:     cleanup
		event_fn:       event
		fail_fn:        fail
		capture_events: true
		frame_rate:     60
	)
	a.tui.run() or { panic(err) }
}
