/* valaclassinstancetype.vala
 *
 * Copyright (C) 2007-2008  Jürg Billeter
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
 * 	Jürg Billeter <j@bitron.ch>
 */

using GLib;

/**
 * A class type.
 */
public class Vala.ClassInstanceType : ReferenceType {
	/**
	 * The referred class.
	 */
	public weak Class class_symbol { get; set; }

	public ClassInstanceType (Class class_symbol) {
		this.class_symbol = class_symbol;
		data_type = class_symbol;
	}

	public override DataType copy () {
		var result = new ClassInstanceType (class_symbol);
		result.source_reference = source_reference;
		result.transfers_ownership = transfers_ownership;
		result.takes_ownership = takes_ownership;
		result.nullable = nullable;
		result.is_dynamic = is_dynamic;
		result.floating_reference = floating_reference;
		
		foreach (DataType arg in get_type_arguments ()) {
			result.add_type_argument (arg.copy ());
		}
		
		return result;
	}

	public override string? get_cname () {
		return "%s*".printf (class_symbol.get_cname (!takes_ownership && !transfers_ownership));
	}
}