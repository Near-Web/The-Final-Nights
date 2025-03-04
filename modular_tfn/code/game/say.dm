/// Transforms the speech emphasis mods from [/atom/movable/proc/say_emphasis] into the appropriate HTML tags. Includes escaping.
#define ENCODE_HTML_EMPHASIS(input, char, html, varname) \
	var/static/regex/##varname = regex("(?<!\\\\)[char](.+?)(?<!\\\\)[char]", "g");\
	input = varname.Replace_char(input, "<[html]>$1</[html]>&#8203;") //zero-width space to force maptext to respect closing tags.

/// Scans the input sentence for speech emphasis modifiers, notably |italics|, +bold+, and _underline_ -mothblocks
/atom/movable/proc/say_emphasis(input)
	ENCODE_HTML_EMPHASIS(input, "\\|", "i", italics)
	ENCODE_HTML_EMPHASIS(input, "\\+", "b", bold)
	ENCODE_HTML_EMPHASIS(input, "_", "u", underline)
	var/static/regex/remove_escape_backlashes = regex("\\\\(_|\\+|\\|)", "g") // Removes backslashes used to escape text modification.
	input = remove_escape_backlashes.Replace_char(input, "$1")
	return input

#undef ENCODE_HTML_EMPHASIS
