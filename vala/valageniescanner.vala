/* valageniescanner.vala
 *
 * Copyright (C) 2008  Jamie McCracken, Jürg Billeter
 * Based on code by Jürg Billeter
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jamie McCracken jamiemcc gnome org
 */

using GLib;

/**
 * Lexical scanner for Genie source files.
 */
public class Vala.Genie.Scanner {
	public SourceFile source_file { get; private set; }

	public int indent_spaces { get; set;}

	char* begin;
	char* current;
	char* end;

	int line;
	int column;

	int current_indent_level;
	int indent_level;
	int pending_dedents;

	TokenType last_token;
	bool parse_started;

	Comment _comment;
	
	Conditional[] conditional_stack;

	struct Conditional {
		public bool matched;
		public bool else_found;
		public bool skip_section;
	}
	
	public Scanner (SourceFile source_file) {
		this.source_file = source_file;

		begin = source_file.get_mapped_contents ();
		end = begin + source_file.get_mapped_length ();

		current = begin;

		_indent_spaces = 0;
		line = 1;
		column = 1;
		current_indent_level = 0;
		indent_level = 0;
		pending_dedents = 0;

		parse_started = false;
		last_token = TokenType.NONE;
		
	}

	bool is_ident_char (char c) {
		return (c.isalnum () || c == '_');
	}

	TokenType get_identifier_or_keyword (char* begin, int len) {
		switch (len) {
		case 2:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "as")) return TokenType.AS;
				break;
			case 'd':
				if (matches (begin, "do")) return TokenType.DO;
				break;
			case 'i':
				switch (begin[1]) {
				case 'f':
					return TokenType.IF;
				case 'n':
					return TokenType.IN;
				case 's':
					return TokenType.IS;
				}
				break;
			case 'o':
				if (matches (begin, "of")) return TokenType.OF;
				
				if (matches (begin, "or")) return TokenType.OP_OR;
				break;
			case 't':
				if (matches (begin, "to")) return TokenType.TO;
				break;
			}
			break;
		case 3:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "and")) return TokenType.OP_AND;
				break;
			case 'd':
				if (matches (begin, "def")) return TokenType.DEF;
				break;
			case 'f':
				if (matches (begin, "for")) return TokenType.FOR;
				break;
			case 'g':
				if (matches (begin, "get")) return TokenType.GET;
				break;
			case 'i':
				if (matches (begin, "isa")) return TokenType.ISA;
				break;
			case 'n':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "new")) return TokenType.NEW;
					break;
				case 'o':
					if (matches (begin, "not")) return TokenType.OP_NEG;
					break;
				}
				break;
			case 'o':
				if (matches (begin, "out")) return TokenType.OUT;
				break;
			case 'r':
				if (matches (begin, "ref")) return TokenType.REF;
				break;
			case 's':
				if (matches (begin, "set")) return TokenType.SET;
				break;
			case 't':
				if (matches (begin, "try")) return TokenType.TRY;
				break;
			case 'v':
				if (matches (begin, "var")) return TokenType.VAR;
				break;
			}
			break;
		case 4:
			switch (begin[0]) {
			case 'c':
				if (matches (begin, "case")) return TokenType.CASE;
				break;
			case 'd':
				if (matches (begin, "dict")) return TokenType.DICT;
				break;
			case 'e':
				switch (begin[1]) {
				case 'l':
					if (matches (begin, "else")) return TokenType.ELSE;
					break;
				case 'n':
					if (matches (begin, "enum")) return TokenType.ENUM;
					break;
				}
				break;
			case 'i':
				if (matches (begin, "init")) return TokenType.INIT;
				break;
			case 'l':
				switch (begin[1]) {
				case 'i':
					if (matches (begin, "list")) return TokenType.LIST;
					break;
				case 'o':
					if (matches (begin, "lock")) return TokenType.LOCK;
					break;
				}
				break;
				
			case 'n':
				if (matches (begin, "null")) return TokenType.NULL;
				break;
			case 'p':
				switch (begin[1]) {
				case 'a':
					if (matches (begin, "pass")) return TokenType.PASS;
					break;
				case 'r':
					if (matches (begin, "prop")) return TokenType.PROP;
					break;
				}
				break;
			case 's':
				if (matches (begin, "self")) return TokenType.THIS;
				break;	
			case 't':
				if (matches (begin, "true")) return TokenType.TRUE;
				break;
			case 'u':
				if (matches (begin, "uses")) return TokenType.USES;
				break;
			case 'v':
				if (matches (begin, "void")) return TokenType.VOID;
				break;
			case 'w':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "weak")) return TokenType.WEAK;
					break;
				case 'h':
					if (matches (begin, "when")) return TokenType.WHEN;
					break;
				}
				break;
			}
			break;
		case 5:
			switch (begin[0]) {
			case 'a':
				switch (begin[1]) {
				case 'r':
					if (matches (begin, "array")) return TokenType.ARRAY;
					break;
				case 's':
					if (matches (begin, "async")) return TokenType.ASYNC;
					break;	
				}
				break;
			case 'b':
				if (matches (begin, "break")) return TokenType.BREAK;
				break;
			case 'c':
				switch (begin[1]) {
				case 'l':
					if (matches (begin, "class")) return TokenType.CLASS;
					break;
				case 'o':
					if (matches (begin, "const")) return TokenType.CONST;
					break;
				}
				break;
			case 'e':
				if (matches (begin, "event")) return TokenType.EVENT;
				break;
			case 'f':
				switch (begin[1]) {
				case 'a':
					if (matches (begin, "false")) return TokenType.FALSE;
					break;
				case 'i':
					if (matches (begin, "final")) return TokenType.FINAL;
					break;
				}
				break;
			case 'o':
				if (matches (begin, "owned")) return TokenType.OWNED;
				break;	
			case 'p':
				if (matches (begin, "print")) return TokenType.PRINT;
				break;
			case 's':
				if (matches (begin, "super")) return TokenType.SUPER;
				break;
			case 'r':
				if (matches (begin, "raise")) return TokenType.RAISE;
				break;
			case 'w':
				if (matches (begin, "while")) return TokenType.WHILE;
				break;
			case 'y':
				if (matches (begin, "yield")) return TokenType.YIELD;
				break;
			}
			break;
		case 6:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "assert")) return TokenType.ASSERT;
				break;
			case 'd':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "delete")) return TokenType.DELETE;
					break;
				case 'o':
					if (matches (begin, "downto")) return TokenType.DOWNTO;
					break;
				}
				break;
			case 'e':
				switch (begin[1]) {
				case 'x':
					switch (begin[2]) {
					case 'c':
						if (matches (begin, "except")) return TokenType.EXCEPT;
						break;
					case 't':
						if (matches (begin, "extern")) return TokenType.EXTERN;
						break;
					}
					break;
				}
				break;
			case 'i':
				if (matches (begin, "inline")) return TokenType.INLINE;
				break;
			case 'p':
				switch (begin[1]) {
				case 'a':
					if (matches (begin, "params")) return TokenType.PARAMS;
					break;
				case 'u':
					if (matches (begin, "public")) return TokenType.PUBLIC;
					break;
				}
				break;
			case 'r':
				switch (begin[1]) {
				case 'a':
					if (matches (begin, "raises")) return TokenType.RAISES;
					break;
				case 'e':
					if (matches (begin, "return")) return TokenType.RETURN;
					break;
				}
				break;
			case 's':
				switch (begin[1]) {
				case 'i':
					if (matches (begin, "sizeof")) return TokenType.SIZEOF;
					break;
				case 't':
					switch (begin[2]) {
					case 'a':
						if (matches (begin, "static")) return TokenType.STATIC;
						break;
					case 'r':
						if (matches (begin, "struct")) return TokenType.STRUCT;
						break;
					}
					break;
				}
				break;
			case 't':
				if (matches (begin, "typeof")) return TokenType.TYPEOF;
				break;
			}
			break;
		case 7:
			switch (begin[0]) {
			case 'd':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "default")) return TokenType.DEFAULT;
					break;
				case 'y':
					if (matches (begin, "dynamic")) return TokenType.DYNAMIC;
					break;
				}
				break;
			case 'e':
				if (matches (begin, "ensures")) return TokenType.ENSURES;
				break;
			case 'f':
				switch (begin[1]) {
				case 'i':
					if (matches (begin, "finally")) return TokenType.FINALLY;
					break;
				case 'o':
					if (matches (begin, "foreach")) return TokenType.FOREACH;
					break;
				}
				break;
			case 'p':
				if (matches (begin, "private")) return TokenType.PRIVATE;
				break;
			case 'u':
				if (matches (begin, "unowned")) return TokenType.UNOWNED;
				break;
			case 'v':
				if (matches (begin, "virtual")) return TokenType.VIRTUAL;
				break;
			}
			break;
		case 8:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "abstract")) return TokenType.ABSTRACT;
				break;
			case 'c':
				if (matches (begin, "continue")) return TokenType.CONTINUE;
				break;
			case 'd':
				if (matches (begin, "delegate")) return TokenType.DELEGATE;
				break;
			case 'i':
				if (matches (begin, "internal")) return TokenType.INTERNAL;
				break;
			case 'o':
				if (matches (begin, "override")) return TokenType.OVERRIDE;
				break;
			case 'r':
				switch (begin[2]) {
				case 'a':
					if (matches (begin, "readonly")) return TokenType.READONLY;
					break;
				case 'q':
					if (matches (begin, "requires")) return TokenType.REQUIRES;
					break;
				}
				break;
			case 'v':
				if (matches (begin, "volatile")) return TokenType.VOLATILE;
				break;
			}
			break;
		case 9:
			switch (begin[0]) {
			case 'c':
				if (matches (begin, "construct")) return TokenType.CONSTRUCT;
				break;
			case 'e':
				if (matches (begin, "exception")) return TokenType.ERRORDOMAIN;
				break;
			case 'i':
				if (matches (begin, "interface")) return TokenType.INTERFACE;
				break;
			case 'n':
				if (matches (begin, "namespace")) return TokenType.NAMESPACE;
				break;
			case 'p':
				if (matches (begin, "protected")) return TokenType.PROTECTED;
				break;
			case 'w':
				if (matches (begin, "writeonly")) return TokenType.WRITEONLY;
				break;
			}
			break;
		case 10:
			switch (begin[0]) {
			case 'i':
				if (matches (begin, "implements")) return TokenType.IMPLEMENTS;
				break;	
			}
			break;
		}
		return TokenType.IDENTIFIER;
	}

	public TokenType read_token (out SourceLocation token_begin, out SourceLocation token_end) {
		/* emit dedents if outstanding before checking any other chars */

		if (pending_dedents > 0) {
			pending_dedents--;
			indent_level--;


			token_begin.pos = current;
			token_begin.line = line;
			token_begin.column = column;

			token_end.pos = current;
			token_end.line = line;
			token_end.column = column;

			last_token = TokenType.DEDENT;

			return TokenType.DEDENT;
		}


		if ((_indent_spaces == 0 ) || (last_token != TokenType.EOL)) {
			/* scrub whitespace (excluding newlines) and comments */		
			space ();
		}
		
		/* handle line continuation (lines ending with \) */
		while (current < end && current[0] == '\\' && current[1] == '\n') {
			current += 2;
			line++;
			skip_space_tabs ();
		}

		/* handle non-consecutive new line once parsing is underway - EOL */
		if (newline () && parse_started && last_token != TokenType.EOL && last_token != TokenType.SEMICOLON) {
			token_begin.pos = current;
			token_begin.line = line;
			token_begin.column = column;

			token_end.pos = current;
			token_end.line = line;
			token_end.column = column;

			last_token = TokenType.EOL;

			return TokenType.EOL;
		} 


		while (skip_newlines ()) {
			token_begin.pos = current;
			token_begin.line = line;
			token_begin.column = column;

			current_indent_level = count_tabs ();

			/* if its an empty new line then ignore */
			if (current_indent_level == -1)  {
				continue;
			} 

			if (current_indent_level > indent_level) {
				indent_level = current_indent_level;

				token_end.pos = current;
				token_end.line = line;
				token_end.column = column;

				last_token = TokenType.INDENT;

				return TokenType.INDENT;
			} else if (current_indent_level < indent_level) {
				indent_level--;

				pending_dedents = (indent_level - current_indent_level);

				token_end.pos = current;
				token_end.line = line;
				token_end.column = column;

				last_token = TokenType.DEDENT;

				return TokenType.DEDENT;
			}
		}

		TokenType type;
		char* begin = current;
		token_begin.pos = begin;
		token_begin.line = line;
		token_begin.column = column;

		int token_length_in_chars = -1;

		parse_started = true;

		if (current >= end) {
			if (indent_level > 0) {
				indent_level--;

				pending_dedents = indent_level;

				type = TokenType.DEDENT;
			} else {
				type = TokenType.EOF;
			}
		} else if (current[0].isalpha () || current[0] == '_') {
			int len = 0;
			while (current < end && is_ident_char (current[0])) {
				current++;
				len++;
			}
			type = get_identifier_or_keyword (begin, len);
		} else if (current[0] == '@') {
			int len = 0;
			if (current[1] == '@') {
				token_begin.pos += 2; // @@ is not part of the identifier
				current += 2;
			} else {
				current++;
				len = 1;
			}
			while (current < end && is_ident_char (current[0])) {
				current++;
				len++;
			}
			type = TokenType.IDENTIFIER;
		} else if (current[0].isdigit ()) {
			while (current < end && current[0].isdigit ()) {
				current++;
			}
			type = TokenType.INTEGER_LITERAL;
			if (current < end && current[0].tolower () == 'l') {
				current++;
				if (current < end && current[0].tolower () == 'l') {
					current++;
				}
			} else if (current < end && current[0].tolower () == 'u') {
				current++;
				if (current < end && current[0].tolower () == 'l') {
					current++;
					if (current < end && current[0].tolower () == 'l') {
						current++;
					}
				}
			} else if (current < end - 1 && current[0] == '.' && current[1].isdigit ()) {
				current++;
				while (current < end && current[0].isdigit ()) {
					current++;
				}
				if (current < end && current[0].tolower () == 'e') {
					current++;
					if (current < end && (current[0] == '+' || current[0] == '-')) {
						current++;
					}
					while (current < end && current[0].isdigit ()) {
						current++;
					}
				}
				if (current < end && current[0].tolower () == 'f') {
					current++;
				}
				type = TokenType.REAL_LITERAL;
			} else if (current < end && current == begin + 1
			           && begin[0] == '0' && begin[1] == 'x' && begin[2].isxdigit ()) {
				// hexadecimal integer literal
				current++;
				while (current < end && current[0].isxdigit ()) {
					current++;
				}
			} else if (current < end && is_ident_char (current[0])) {
				// allow identifiers to start with a digit
				// as long as they contain at least one char
				while (current < end && is_ident_char (current[0])) {
					current++;
				}
				type = TokenType.IDENTIFIER;
			}
		} else {
			switch (current[0]) {
			case '{':
				type = TokenType.OPEN_BRACE;
				current++;
				break;
			case '}':
				type = TokenType.CLOSE_BRACE;
				current++;
				break;
			case '(':
				type = TokenType.OPEN_PARENS;
				current++;
				break;
			case ')':
				type = TokenType.CLOSE_PARENS;
				current++;
				break;
			case '[':
				type = TokenType.OPEN_BRACKET;
				current++;
				break;
			case ']':
				type = TokenType.CLOSE_BRACKET;
				current++;
				break;
			case '.':
				type = TokenType.DOT;
				current++;
				if (current < end - 1) {
					if (current[0] == '.' && current[1] == '.') {
						type = TokenType.ELLIPSIS;
						current += 2;
					}
				}
				break;
			case ':':
				type = TokenType.COLON;
				current++;
				break;
			case ',':
				type = TokenType.COMMA;
				current++;
				break;
			case ';':
				type = TokenType.SEMICOLON;
				current++;
				break;
			case '#':
				type = TokenType.HASH;
				current++;
				break;
			case '?':
				type = TokenType.INTERR;
				current++;
				break;
			case '|':
				type = TokenType.BITWISE_OR;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_BITWISE_OR;
						current++;
						break;
					case '|':
						type = TokenType.OP_OR;
						current++;
						break;
					}
				}
				break;
			case '&':
				type = TokenType.BITWISE_AND;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_BITWISE_AND;
						current++;
						break;
					case '&':
						type = TokenType.OP_AND;
						current++;
						break;
					}
				}
				break;
			case '^':
				type = TokenType.CARRET;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_BITWISE_XOR;
					current++;
				}
				break;
			case '~':
				type = TokenType.TILDE;
				current++;
				break;
			case '=':
				type = TokenType.ASSIGN;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.OP_EQ;
						current++;
						break;
					case '>':
						type = TokenType.LAMBDA;
						current++;
						break;
					}
				}
				break;
			case '<':
				type = TokenType.OP_LT;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.OP_LE;
						current++;
						break;
					case '<':
						type = TokenType.OP_SHIFT_LEFT;
						current++;
						if (current < end && current[0] == '=') {
							type = TokenType.ASSIGN_SHIFT_LEFT;
							current++;
						}
						break;
					}
				}
				break;
			case '>':
				type = TokenType.OP_GT;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.OP_GE;
					current++;
				}
				break;
			case '!':
				type = TokenType.OP_NEG;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.OP_NE;
					current++;
				}
				break;
			case '+':
				type = TokenType.PLUS;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_ADD;
						current++;
						break;
					case '+':
						type = TokenType.OP_INC;
						current++;
						break;
					}
				}
				break;
			case '-':
				type = TokenType.MINUS;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_SUB;
						current++;
						break;
					case '-':
						type = TokenType.OP_DEC;
						current++;
						break;
					case '>':
						type = TokenType.OP_PTR;
						current++;
						break;
					}
				}
				break;
			case '*':
				type = TokenType.STAR;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_MUL;
					current++;
				}
				break;
			case '/':
				type = TokenType.DIV;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_DIV;
					current++;
				}
				break;
			case '%':
				type = TokenType.PERCENT;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_PERCENT;
					current++;
				}
				break;
			case '\'':
			case '"':
				if (begin[0] == '\'') {
					type = TokenType.CHARACTER_LITERAL;
				} else if (current < end - 6 && begin[1] == '"' && begin[2] == '"') {
					type = TokenType.VERBATIM_STRING_LITERAL;
					token_length_in_chars = 6;
					current += 3;
					while (current < end - 4) {
						if (current[0] == '"' && current[1] == '"' && current[2] == '"') {
							break;
						} else if (current[0] == '\n') {
							current++;
							line++;
							column = 1;
							token_length_in_chars = 3;
						} else {
							unichar u = ((string) current).get_char_validated ((long) (end - current));
							if (u != (unichar) (-1)) {
								current += u.to_utf8 (null);
								token_length_in_chars++;
							} else {
								Report.error (new SourceReference (source_file, line, column + token_length_in_chars, line, column + token_length_in_chars), "invalid UTF-8 character");
							}
						}
					}
					if (current[0] == '"' && current[1] == '"' && current[2] == '"') {
						current += 3;
					} else {
						Report.error (new SourceReference (source_file, line, column + token_length_in_chars, line, column + token_length_in_chars), "syntax error, expected \"\"\"");
					}
					break;
				} else {
					type = TokenType.STRING_LITERAL;
				}
				token_length_in_chars = 2;
				current++;
				while (current < end && current[0] != begin[0]) {
					if (current[0] == '\\') {
						current++;
						token_length_in_chars++;
						if (current >= end) {
							break;
						}

						switch (current[0]) {
						case '\'':
						case '"':
						case '\\':
						case '0':
						case 'b':
						case 'f':
						case 'n':
						case 'r':
						case 't':
							current++;
							token_length_in_chars++;
							break;
						case 'x':
							// hexadecimal escape character
							current++;
							token_length_in_chars++;
							while (current < end && current[0].isxdigit ()) {
								current++;
								token_length_in_chars++;
							}
							break;
						default:
							Report.error (new SourceReference (source_file, line, column + token_length_in_chars, line, column + token_length_in_chars), "invalid escape sequence");
							break;
						}
					} else if (current[0] == '\n') {
						break;
					} else {
						unichar u = ((string) current).get_char_validated ((long) (end - current));
						if (u != (unichar) (-1)) {
							current += u.to_utf8 (null);
							token_length_in_chars++;
						} else {
							current++;
							Report.error (new SourceReference (source_file, line, column + token_length_in_chars, line, column + token_length_in_chars), "invalid UTF-8 character");
						}
					}
				}
				if (current < end && current[0] != '\n') {
					current++;
				} else {
					Report.error (new SourceReference (source_file, line, column + token_length_in_chars, line, column + token_length_in_chars), "syntax error, expected %c".printf (begin[0]));
				}
				break;
			default:
				unichar u = ((string) current).get_char_validated ((long) (end - current));
				if (u != (unichar) (-1)) {
					current += u.to_utf8 (null);
					Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, unexpected character");
				} else {
					current++;
					Report.error (new SourceReference (source_file, line, column, line, column), "invalid UTF-8 character");
				}
				column++;
				last_token = TokenType.STRING_LITERAL;
				return read_token (out token_begin, out token_end);
			}
		}

		if (token_length_in_chars < 0) {
			column += (int) (current - begin);
		} else {
			column += token_length_in_chars;
		}

		token_end.pos = current;
		token_end.line = line;
		token_end.column = column - 1;
		
		last_token = type;

		return type;
	}

	int count_tabs ()
	{
		
		int tab_count = 0;


		if (_indent_spaces == 0) {
			while (current < end && current[0] == '\t') {
				current++;
				column++;
				tab_count++;
			}
		} else {
			int space_count = 0;
			while (current < end && current[0] == ' ') {
				current++;
				column++;
				space_count++;
			}
			
			tab_count = space_count / _indent_spaces;
		
		}

		/* ignore comments and whitspace and other lines that contain no code */

		space ();

		if ((current < end) && (current[0] == '\n')) return -1;

		return tab_count;
	}

	bool matches (char* begin, string keyword) {
		char* keyword_array = (char *) keyword;
		long len = keyword.len ();
		for (int i = 0; i < len; i++) {
			if (begin[i] != keyword_array[i]) {
				return false;
			}
		}
		return true;
	}

	bool whitespace () {
		bool found = false;
		while (current < end && current[0].isspace () && current[0] != '\n' ) {
			
			found = true;
			current++;
			column++;
		}
		
		if ((column == 1) && (current < end) && (current[0] == '#')) {
			pp_directive ();
			return true;
		}
		
		return found;
	}

	inline bool newline () {
		if (current[0] == '\n') {
			return true;
		}

		return false;
	}

	bool skip_newlines () {
		bool new_lines = false;

		while (newline ()) {
			current++;

			line++;
			column = 1;
			current_indent_level = 0;

			new_lines = true;
		}

		return new_lines;
	}

	bool comment (bool file_comment = false) {
		if (current > end - 2
		    || current[0] != '/'
		    || (current[1] != '/' && current[1] != '*')) {
			return false;
		}


		if (current[1] == '/') {
			// single-line comment
			
			SourceReference source_reference = null;
			if (file_comment) {
				source_reference = new SourceReference (source_file, line, column, line, column);
			}
			
			current += 2;

			// skip until end of line or end of file
			while (current < end && current[0] != '\n') {
				current++;
			}

			/* do not ignore EOL if comment does not exclusively occupy the line */
			if (current[0] == '\n' && last_token == TokenType.EOL) {
				current++;
				line++;
				column = 1;
				current_indent_level = 0;
			}
			
			if (source_reference != null) {
				push_comment (((string) begin).ndup ((long) (current - begin)), source_reference, file_comment);
			}
			
		} else {
			// delimited comment
			SourceReference source_reference = null;
			if (file_comment && current[2] == '*') {
				return false;
			}

            if (current[2] == '*' || file_comment) {
				source_reference = new SourceReference (source_file, line, column, line, column);
			}

			current += 2;
			char* begin = current;

			while (current < end - 1
			       && (current[0] != '*' || current[1] != '/')) {
				if (current[0] == '\n') {
					line++;
					column = 0;
				}
				current++;
				column++;
			}
			if (current == end - 1) {
				Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, expected */");
				return true;
			}

			if (source_reference != null) {
				string comment = ((string) begin).ndup ((long) (current - begin));
				push_comment (comment, source_reference, file_comment);
			}

			current += 2;
			column += 2;
		}

		return true;
	}

	bool skip_tabs () {
		bool found = false;
		while (current < end && current[0] == '\t' ) {
			current++;
			column++;
			found = true;
		}
		
		return found;
	}

	void skip_space_tabs () {
		while (whitespace () || skip_tabs () || comment () ) {
		}
	
	}

	void space () {
		while (whitespace () || comment ()) {
		}
	}

    public void parse_file_comments () {
		while (whitespace () || comment (true)) {
		}
		
	}

	void push_comment (string comment_item, SourceReference source_reference, bool file_comment) {
		if (comment_item[0] == '*') {
			_comment = new Comment (comment_item, source_reference);
		}

		if (file_comment) {
			source_file.add_comment (new Comment (comment_item, source_reference));
			_comment = null;
		}
	}

	/**
	 * Clears and returns the content of the comment stack.
	 *
	 * @return saved comment
	 */
	public Comment? pop_comment () {
		if (_comment == null) {
			return null;
		}

		var comment = _comment;
		_comment = null;
		return comment;
	}

	bool pp_whitespace () {
		bool found = false;
		while (current < end && current[0].isspace () && current[0] != '\n') {
			found = true;
			current++;
			column++;
		}
		return found;
	}

	void pp_directive () {
		// hash sign
		current++;
		column++;

		pp_whitespace ();

		char* begin = current;
		int len = 0;
		while (current < end && current[0].isalnum ()) {
			current++;
			column++;
			len++;
		}

		if (len == 2 && matches (begin, "if")) {
			parse_pp_if ();
		} else if (len == 4 && matches (begin, "elif")) {
			parse_pp_elif ();
		} else if (len == 4 && matches (begin, "else")) {
			parse_pp_else ();
		} else if (len == 5 && matches (begin, "endif")) {
			parse_pp_endif ();
		} else {
			Report.error (new SourceReference (source_file, line, column - len, line, column), "syntax error, invalid preprocessing directive");
		}

		if (conditional_stack.length > 0
		    && conditional_stack[conditional_stack.length - 1].skip_section) {
			// skip lines until next preprocessing directive
			bool bol = false;
			while (current < end) {
				if (bol && current[0] == '#') {
					// go back to begin of line
					current -= (column - 1);
					column = 1;
					return;
				}
				if (current[0] == '\n') {
					line++;
					column = 0;
					bol = true;
				} else if (!current[0].isspace ()) {
					bol = false;
				}
				current++;
				column++;
			}
		}
	}

	void pp_eol () {
		pp_whitespace ();
		if (current >= end || current[0] != '\n') {
			Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, expected newline");
		}
	}

	void parse_pp_if () {
		pp_whitespace ();

		bool condition = parse_pp_expression ();

		pp_eol ();

		conditional_stack += Conditional ();

		if (condition && (conditional_stack.length == 1 || !conditional_stack[conditional_stack.length - 2].skip_section)) {
			// condition true => process code within if
			conditional_stack[conditional_stack.length - 1].matched = true;
		} else {
			// skip lines until next preprocessing directive
			conditional_stack[conditional_stack.length - 1].skip_section = true;
		}
	}

	void parse_pp_elif () {
		pp_whitespace ();

		bool condition = parse_pp_expression ();

		pp_eol ();

		if (conditional_stack.length == 0 || conditional_stack[conditional_stack.length - 1].else_found) {
			Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, unexpected #elif");
			return;
		}

		if (condition && !conditional_stack[conditional_stack.length - 1].matched
		    && (conditional_stack.length == 1 || !conditional_stack[conditional_stack.length - 2].skip_section)) {
			// condition true => process code within if
			conditional_stack[conditional_stack.length - 1].matched = true;
			conditional_stack[conditional_stack.length - 1].skip_section = false;
		} else {
			// skip lines until next preprocessing directive
			conditional_stack[conditional_stack.length - 1].skip_section = true;
		}
	}

	void parse_pp_else () {
		pp_eol ();

		if (conditional_stack.length == 0 || conditional_stack[conditional_stack.length - 1].else_found) {
			Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, unexpected #else");
			return;
		}

		if (!conditional_stack[conditional_stack.length - 1].matched
		    && (conditional_stack.length == 1 || !conditional_stack[conditional_stack.length - 2].skip_section)) {
			// condition true => process code within if
			conditional_stack[conditional_stack.length - 1].matched = true;
			conditional_stack[conditional_stack.length - 1].skip_section = false;
		} else {
			// skip lines until next preprocessing directive
			conditional_stack[conditional_stack.length - 1].skip_section = true;
		}
	}

	void parse_pp_endif () {
		pp_eol ();

		if (conditional_stack.length == 0) {
			Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, unexpected #endif");
			return;
		}

		conditional_stack.length--;
	}

	bool parse_pp_symbol () {
		int len = 0;
		while (current < end && is_ident_char (current[0])) {
			current++;
			column++;
			len++;
		}

		if (len == 0) {
			Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, expected identifier");
			return false;
		}

		string identifier = ((string) (current - len)).ndup (len);
		bool defined;
		if (identifier == "true") {
			defined = true;
		} else if (identifier == "false") {
			defined = false;
		} else {
			defined = source_file.context.is_defined (identifier);
		}

		return defined;
	}

	bool parse_pp_primary_expression () {
		if (current >= end) {
			Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, expected identifier");
		} else if (is_ident_char (current[0])) {
			return parse_pp_symbol ();
		} else if (current[0] == '(') {
			current++;
			column++;
			pp_whitespace ();
			bool result = parse_pp_expression ();
			pp_whitespace ();
			if (current < end && current[0] ==  ')') {
				current++;
				column++;
			} else {
				Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, expected `)'");
			}
			return result;
		} else {
			Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, expected identifier");
		}
		return false;
	}

	bool parse_pp_unary_expression () {
		if (current < end && current[0] == '!') {
			current++;
			column++;
			pp_whitespace ();
			return !parse_pp_unary_expression ();
		}

		return parse_pp_primary_expression ();
	}

	bool parse_pp_equality_expression () {
		bool left = parse_pp_unary_expression ();
		pp_whitespace ();
		while (true) {
			if (current < end - 1 && current[0] == '=' && current[1] == '=') {
				current += 2;
				column += 2;
				pp_whitespace ();
				bool right = parse_pp_unary_expression ();
				left = (left == right);
			} else if (current < end - 1 && current[0] == '!' && current[1] == '=') {
				current += 2;
				column += 2;
				pp_whitespace ();
				bool right = parse_pp_unary_expression ();
				left = (left != right);
			} else {
				break;
			}
		}
		return left;
	}

	bool parse_pp_and_expression () {
		bool left = parse_pp_equality_expression ();
		pp_whitespace ();
		while (current < end - 1 && current[0] == '&' && current[1] == '&') {
			current += 2;
			column += 2;
			pp_whitespace ();
			bool right = parse_pp_equality_expression ();
			left = left && right;
		}
		return left;
	}

	bool parse_pp_or_expression () {
		bool left = parse_pp_and_expression ();
		pp_whitespace ();
		while (current < end - 1 && current[0] == '|' && current[1] == '|') {
			current += 2;
			column += 2;
			pp_whitespace ();
			bool right = parse_pp_and_expression ();
			left = left || right;
		}
		return left;
	}

	bool parse_pp_expression () {
		return parse_pp_or_expression ();
	}
}

