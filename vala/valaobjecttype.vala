/* valaobjecttype.vala
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
public class Vala.ObjectType : ReferenceType {
	/**
	 * The referred class or interface.
	 */
	public weak ObjectTypeSymbol type_symbol { get; set; }

	public ObjectType (ObjectTypeSymbol type_symbol) {
		this.type_symbol = type_symbol;
		data_type = type_symbol;
	}

	public override DataType copy () {
		var result = new ObjectType (type_symbol);
		result.source_reference = source_reference;
		result.value_owned = value_owned;
		result.nullable = nullable;
		result.is_dynamic = is_dynamic;
		result.floating_reference = floating_reference;
		
		foreach (DataType arg in get_type_arguments ()) {
			result.add_type_argument (arg.copy ());
		}
		
		return result;
	}

	public override string? get_cname () {
		return "%s*".printf (type_symbol.get_cname (!value_owned));
	}

	public override bool stricter (DataType target_type) {
		var obj_target_type = target_type as ObjectType;
		if (obj_target_type == null) {
			return false;
		}

		if (value_owned != target_type.value_owned) {
			return false;
		}
		
		if (nullable && !target_type.nullable) {
			return false;
		}

		return type_symbol.is_subtype_of (obj_target_type.type_symbol);
	}

	public override bool is_invokable () {
		var cl = type_symbol as Class;
		if (cl != null && cl.default_construction_method != null) {
			return true;
		} else {
			return false;
		}
	}

	public override DataType? get_return_type () {
		var cl = type_symbol as Class;
		if (cl != null && cl.default_construction_method != null) {
			return cl.default_construction_method.return_type;
		} else {
			return null;
		}
	}

	public override List<FormalParameter>? get_parameters () {
		var cl = type_symbol as Class;
		if (cl != null && cl.default_construction_method != null) {
			return cl.default_construction_method.get_parameters ();
		} else {
			return null;
		}
	}

	public override bool check (SemanticAnalyzer analyzer) {
		return type_symbol.check (analyzer);
	}
}
