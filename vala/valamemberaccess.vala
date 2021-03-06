/* valamemberaccess.vala
 *
 * Copyright (C) 2006-2009  Jürg Billeter
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
 * Represents an access to a type member in the source code.
 */
public class Vala.MemberAccess : Expression {
	/**
	 * The parent of the member.
	 */
	public Expression? inner {
		get {
			return _inner;
		}
		set {
			_inner = value;
			if (_inner != null) {
				_inner.parent_node = this;
			}
		}
	}
	
	/**
	 * The name of the member.
	 */
	public string member_name { get; set; }

	/**
	 * Pointer member access.
	 */
	public bool pointer_member_access { get; set; }

	/**
	 * Represents access to an instance member without an actual instance,
	 * e.g. `MyClass.an_instance_method`.
	 */
	public bool prototype_access { get; set; }

	/**
	 * Specifies whether the member is used for object creation.
	 */
	public bool creation_member { get; set; }

	/**
	 * Qualified access to global symbol.
	 */
	public bool qualified { get; set; }

	private Expression? _inner;
	private List<DataType> type_argument_list = new ArrayList<DataType> ();
	
	/**
	 * Creates a new member access expression.
	 *
	 * @param inner            parent of the member
	 * @param member_name      member name
	 * @param source_reference reference to source code
	 * @return                 newly created member access expression
	 */
	public MemberAccess (Expression? inner, string member_name, SourceReference? source_reference = null) {
		this.inner = inner;
		this.member_name = member_name;
		this.source_reference = source_reference;
	}

	public MemberAccess.simple (string member_name, SourceReference? source_reference = null) {
		this.member_name = member_name;
		this.source_reference = source_reference;
	}

	public MemberAccess.pointer (Expression inner, string member_name, SourceReference? source_reference = null) {
		this.inner = inner;
		this.member_name = member_name;
		this.source_reference = source_reference;
		pointer_member_access = true;
	}

	/**
	 * Appends the specified type as generic type argument.
	 *
	 * @param arg a type reference
	 */
	public void add_type_argument (DataType arg) {
		type_argument_list.add (arg);
		arg.parent_node = this;
	}
	
	/**
	 * Returns a copy of the list of generic type arguments.
	 *
	 * @return type argument list
	 */
	public List<DataType> get_type_arguments () {
		return new ReadOnlyList<DataType> (type_argument_list);
	}

	public override void accept (CodeVisitor visitor) {
		visitor.visit_member_access (this);

		visitor.visit_expression (this);
	}

	public override void accept_children (CodeVisitor visitor) {
		if (inner != null) {
			inner.accept (visitor);
		}
		
		foreach (DataType type_arg in type_argument_list) {
			type_arg.accept (visitor);
		}
	}

	public override string to_string () {
		if (symbol_reference.is_instance_member ()) {
			if (inner == null) {
				return member_name;
			} else {
				return "%s.%s".printf (inner.to_string (), member_name);
			}
		} else {
			// ensure to always use fully-qualified name
			// to refer to static members
			return symbol_reference.get_full_name ();
		}
	}

	public override void replace_expression (Expression old_node, Expression new_node) {
		if (inner == old_node) {
			inner = new_node;
		}
	}

	public override bool is_pure () {
		// accessing property could have side-effects
		return (inner == null || inner.is_pure ()) && !(symbol_reference is Property);
	}

	public override void replace_type (DataType old_type, DataType new_type) {
		for (int i = 0; i < type_argument_list.size; i++) {
			if (type_argument_list[i] == old_type) {
				type_argument_list[i] = new_type;
				return;
			}
		}
	}

	public override bool is_constant () {
		if (symbol_reference is Constant || symbol_reference is EnumValue) {
			return true;
		} else {
			return false;
		}
	}

	public override bool is_non_null () {
		var c = symbol_reference as Constant;
		if (c != null) {
			return !c.type_reference.nullable;
		} else {
			return false;
		}
	}

	public override bool check (SemanticAnalyzer analyzer) {
		if (checked) {
			return !error;
		}

		checked = true;

		if (inner != null) {
			inner.check (analyzer);
		}
		
		foreach (DataType type_arg in type_argument_list) {
			type_arg.check (analyzer);
		}

		Symbol base_symbol = null;
		FormalParameter this_parameter = null;
		bool may_access_instance_members = false;
		bool may_access_klass_members = false;

		symbol_reference = null;

		if (qualified) {
			base_symbol = analyzer.root_symbol;
			symbol_reference = analyzer.root_symbol.scope.lookup (member_name);
		} else if (inner == null) {
			if (member_name == "this") {
				if (!analyzer.is_in_instance_method ()) {
					error = true;
					Report.error (source_reference, "This access invalid outside of instance methods");
					return false;
				}
			}

			base_symbol = analyzer.current_symbol;

			var sym = analyzer.current_symbol;
			while (sym != null && symbol_reference == null) {
				if (this_parameter == null) {
					if (sym is CreationMethod) {
						var cm = (CreationMethod) sym;
						this_parameter = cm.this_parameter;
						may_access_instance_members = true;
						may_access_klass_members = true;
					} else if (sym is Property) {
						var prop = (Property) sym;
						this_parameter = prop.this_parameter;
						may_access_instance_members = (prop.binding == MemberBinding.INSTANCE);
						may_access_klass_members = (prop.binding != MemberBinding.STATIC);
					} else if (sym is Constructor) {
						var c = (Constructor) sym;
						this_parameter = c.this_parameter;
						may_access_instance_members = (c.binding == MemberBinding.INSTANCE);
						may_access_klass_members = true;
					} else if (sym is Destructor) {
						var d = (Destructor) sym;
						this_parameter = d.this_parameter;
						may_access_instance_members = (d.binding == MemberBinding.INSTANCE);
						may_access_klass_members = true;
					} else if (sym is Method) {
						var m = (Method) sym;
						this_parameter = m.this_parameter;
						may_access_instance_members = (m.binding == MemberBinding.INSTANCE);
						may_access_klass_members = (m.binding != MemberBinding.STATIC);
					}
				}

				symbol_reference = analyzer.symbol_lookup_inherited (sym, member_name);
				sym = sym.parent_symbol;
			}

			if (symbol_reference == null && source_reference != null) {
				foreach (UsingDirective ns in source_reference.using_directives) {
					var local_sym = ns.namespace_symbol.scope.lookup (member_name);
					if (local_sym != null) {
						if (symbol_reference != null && symbol_reference != local_sym) {
							error = true;
							Report.error (source_reference, "`%s' is an ambiguous reference between `%s' and `%s'".printf (member_name, symbol_reference.get_full_name (), local_sym.get_full_name ()));
							return false;
						}
						symbol_reference = local_sym;
					}
				}
			}
		} else {
			if (inner.error) {
				/* if there was an error in the inner expression, skip this check */
				error = true;
				return false;
			}

			if (pointer_member_access) {
				var pointer_type = inner.value_type as PointerType;
				if (pointer_type != null && pointer_type.base_type is ValueType) {
					// transform foo->bar to (*foo).bar
					inner = new PointerIndirection (inner, source_reference);
					inner.check (analyzer);
					pointer_member_access = false;
				}
			}

			if (inner is MemberAccess) {
				var ma = (MemberAccess) inner;
				if (ma.prototype_access) {
					error = true;
					Report.error (source_reference, "Access to instance member `%s' denied".printf (inner.symbol_reference.get_full_name ()));
					return false;
				}
			}

			if (inner is MemberAccess || inner is BaseAccess) {
				base_symbol = inner.symbol_reference;

				if (symbol_reference == null && (base_symbol is Namespace || base_symbol is TypeSymbol)) {
					symbol_reference = base_symbol.scope.lookup (member_name);
					if (inner is BaseAccess) {
						// inner expression is base access
						// access to instance members of the base type possible
						may_access_instance_members = true;
						may_access_klass_members = true;
					}
				}
			}

			if (symbol_reference == null && inner.value_type != null) {
				if (pointer_member_access) {
					symbol_reference = inner.value_type.get_pointer_member (member_name);
				} else {
					if (inner.value_type.data_type != null) {
						base_symbol = inner.value_type.data_type;
					}
					symbol_reference = inner.value_type.get_member (member_name);
				}
				if (symbol_reference != null) {
					// inner expression is variable, field, or parameter
					// access to instance members of the corresponding type possible
					may_access_instance_members = true;
					may_access_klass_members = true;
				}
			}

			if (symbol_reference == null && inner.value_type != null && inner.value_type.is_dynamic) {
				// allow late bound members for dynamic types
				var dynamic_object_type = (ObjectType) inner.value_type;
				if (parent_node is MethodCall) {
					var invoc = (MethodCall) parent_node;
					if (invoc.call == this) {
						// dynamic method
						DataType ret_type;
						if (invoc.target_type != null) {
							ret_type = invoc.target_type.copy ();
							ret_type.value_owned = true;
						} else if (invoc.parent_node is ExpressionStatement) {
							ret_type = new VoidType ();
						} else {
							// expect dynamic object of the same type
							ret_type = inner.value_type.copy ();
						}
						var m = new DynamicMethod (inner.value_type, member_name, ret_type, source_reference);
						m.invocation = invoc;
						var err = new ErrorType (null, null);
						err.dynamic_error = true;
						m.add_error_type (err);
						m.access = SymbolAccessibility.PUBLIC;
						m.add_parameter (new FormalParameter.with_ellipsis ());
						dynamic_object_type.type_symbol.scope.add (null, m);
						symbol_reference = m;
					}
				} else if (parent_node is Assignment) {
					var a = (Assignment) parent_node;
					if (a.left == this
					    && (a.operator == AssignmentOperator.ADD
					        || a.operator == AssignmentOperator.SUB)) {
						// dynamic signal
						var s = new DynamicSignal (inner.value_type, member_name, new VoidType (), source_reference);
						s.handler = a.right;
						s.access = SymbolAccessibility.PUBLIC;
						dynamic_object_type.type_symbol.scope.add (null, s);
						symbol_reference = s;
					} else if (a.left == this) {
						// dynamic property assignment
						var prop = new DynamicProperty (inner.value_type, member_name, source_reference);
						prop.access = SymbolAccessibility.PUBLIC;
						prop.set_accessor = new PropertyAccessor (false, true, false, null, null, prop.source_reference);
						prop.set_accessor.access = SymbolAccessibility.PUBLIC;
						prop.owner = inner.value_type.data_type.scope;
						dynamic_object_type.type_symbol.scope.add (null, prop);
						symbol_reference = prop;
					}
				}
				if (symbol_reference == null) {
					// dynamic property read access
					var prop = new DynamicProperty (inner.value_type, member_name, source_reference);
					if (target_type != null) {
						prop.property_type = target_type;
					} else {
						// expect dynamic object of the same type
						prop.property_type = inner.value_type.copy ();
					}
					prop.access = SymbolAccessibility.PUBLIC;
					prop.get_accessor = new PropertyAccessor (true, false, false, prop.property_type.copy (), null, prop.source_reference);
					prop.get_accessor.access = SymbolAccessibility.PUBLIC;
					prop.owner = inner.value_type.data_type.scope;
					dynamic_object_type.type_symbol.scope.add (null, prop);
					symbol_reference = prop;
				}
				if (symbol_reference != null) {
					may_access_instance_members = true;
					may_access_klass_members = true;
				}
			}
		}

		if (symbol_reference == null) {
			error = true;

			string base_type_name = "(null)";
			if (inner != null && inner.value_type != null) {
				base_type_name = inner.value_type.to_string ();
			} else if (base_symbol != null) {
				base_type_name = base_symbol.get_full_name ();
			}

			Report.error (source_reference, "The name `%s' does not exist in the context of `%s'".printf (member_name, base_type_name));
			return false;
		}

		var member = symbol_reference;
		var access = SymbolAccessibility.PUBLIC;
		bool instance = false;
		bool klass = false;

		if (!member.check (analyzer)) {
			return false;
		}

		if (member is LocalVariable) {
			var local = (LocalVariable) member;
			var block = (Block) local.parent_symbol;
			if (analyzer.find_parent_method (block) != analyzer.current_method) {
				// mark all methods between current method and the captured
				// block as closures (to support nested closures)
				Symbol sym = analyzer.current_method;
				while (sym != block) {
					var method = sym as Method;
					if (method != null) {
						method.closure = true;
						// consider captured variables as used
						// as we require captured variables to be initialized
						method.add_captured_variable (local);
					}
					sym = sym.parent_symbol;
				}

				local.captured = true;
				block.captured = true;
			}
		} else if (member is FormalParameter) {
			var param = (FormalParameter) member;
			var m = param.parent_symbol as Method;
			if (m != null && m != analyzer.current_method && param != m.this_parameter) {
				// mark all methods between current method and the captured
				// parameter as closures (to support nested closures)
				Symbol sym = analyzer.current_method;
				while (sym != m) {
					var method = sym as Method;
					if (method != null) {
						method.closure = true;
					}
					sym = sym.parent_symbol;
				}

				param.captured = true;
				m.body.captured = true;

				if (param.direction != ParameterDirection.IN) {
					error = true;
					Report.error (source_reference, "Cannot capture reference or output parameter `%s'".printf (param.get_full_name ()));
				}
			}
		} else if (member is Field) {
			var f = (Field) member;
			access = f.access;
			instance = (f.binding == MemberBinding.INSTANCE);
			klass = (f.binding == MemberBinding.CLASS);
		} else if (member is Method) {
			var m = (Method) member;
			if (m.is_async_callback) {
				// ensure to use right callback method for virtual/abstract async methods
				m = analyzer.current_method.get_callback_method ();
				symbol_reference = m;
				member = symbol_reference;
			} else if (m.base_method != null) {
				// refer to base method to inherit default arguments
				m = m.base_method;

				if (m.signal_reference != null) {
					// method is class/default handler for a signal
					// let signal deal with member access
					symbol_reference = m.signal_reference;
				} else {
					symbol_reference = m;
				}

				member = symbol_reference;
			} else if (m.base_interface_method != null) {
				// refer to base method to inherit default arguments
				m = m.base_interface_method;
				symbol_reference = m;
				member = symbol_reference;
			}
			access = m.access;
			if (!(m is CreationMethod)) {
				instance = (m.binding == MemberBinding.INSTANCE);
			}
			klass = (m.binding == MemberBinding.CLASS);
		} else if (member is Property) {
			var prop = (Property) member;
			if (!prop.check (analyzer)) {
				error = true;
				return false;
			}
			if (prop.base_property != null) {
				// refer to base property
				prop = prop.base_property;
				symbol_reference = prop;
				member = symbol_reference;
			} else if (prop.base_interface_property != null) {
				// refer to base property
				prop = prop.base_interface_property;
				symbol_reference = prop;
				member = symbol_reference;
			}
			access = prop.access;
			if (lvalue) {
				if (prop.set_accessor == null) {
					error = true;
					Report.error (source_reference, "Property `%s' is read-only".printf (prop.get_full_name ()));
					return false;
				}
				if (prop.access == SymbolAccessibility.PUBLIC) {
					access = prop.set_accessor.access;
				} else if (prop.access == SymbolAccessibility.PROTECTED
				           && prop.set_accessor.access != SymbolAccessibility.PUBLIC) {
					access = prop.set_accessor.access;
				}
			} else {
				if (prop.get_accessor == null) {
					error = true;
					Report.error (source_reference, "Property `%s' is write-only".printf (prop.get_full_name ()));
					return false;
				}
				if (prop.access == SymbolAccessibility.PUBLIC) {
					access = prop.get_accessor.access;
				} else if (prop.access == SymbolAccessibility.PROTECTED
				           && prop.get_accessor.access != SymbolAccessibility.PUBLIC) {
					access = prop.get_accessor.access;
				}
			}
			instance = (prop.binding == MemberBinding.INSTANCE);
		} else if (member is Signal) {
			instance = true;
		}

		member.used = true;

		if (access == SymbolAccessibility.PRIVATE) {
			var target_type = member.parent_symbol;

			bool in_target_type = false;
			for (Symbol this_symbol = analyzer.current_symbol; this_symbol != null; this_symbol = this_symbol.parent_symbol) {
				if (target_type == this_symbol) {
					in_target_type = true;
					break;
				}
			}

			if (!in_target_type) {
				error = true;
				Report.error (source_reference, "Access to private member `%s' denied".printf (member.get_full_name ()));
				return false;
			}
		}
		if ((instance && !may_access_instance_members) ||
		    (klass && !may_access_klass_members)) {
			prototype_access = true;

			if (symbol_reference is Method) {
				// also set static type for prototype access
				// required when using instance methods as delegates in constants
				// TODO replace by MethodPrototype
				value_type = analyzer.get_value_type_for_symbol (symbol_reference, lvalue);
			} else if (symbol_reference is Field) {
				value_type = new FieldPrototype ((Field) symbol_reference);
			} else {
				value_type = new InvalidType ();
			}

			if (target_type != null) {
				value_type.value_owned = target_type.value_owned;
			}
		} else {
			// implicit this access
			if (instance && inner == null) {
				inner = new MemberAccess (null, "this", source_reference);
				inner.value_type = this_parameter.parameter_type.copy ();
				inner.symbol_reference = this_parameter;
			}

			formal_value_type = analyzer.get_value_type_for_symbol (symbol_reference, lvalue);
			if (inner != null && formal_value_type != null) {
				value_type = formal_value_type.get_actual_type (inner.value_type, null, this);
			} else {
				value_type = formal_value_type;
			}

			if (symbol_reference is Method) {
				var m = (Method) symbol_reference;

				if (target_type != null) {
					value_type.value_owned = target_type.value_owned;
				}

				Method base_method;
				if (m.base_method != null) {
					base_method = m.base_method;
				} else if (m.base_interface_method != null) {
					base_method = m.base_interface_method;
				} else {
					base_method = m;
				}

				if (instance && base_method.parent_symbol is TypeSymbol) {
					inner.target_type = analyzer.get_data_type_for_symbol ((TypeSymbol) base_method.parent_symbol);
				}
			} else if (symbol_reference is Property) {
				var prop = (Property) symbol_reference;

				Property base_property;
				if (prop.base_property != null) {
					base_property = prop.base_property;
				} else if (prop.base_interface_property != null) {
					base_property = prop.base_interface_property;
				} else {
					base_property = prop;
				}

				if (instance && base_property.parent_symbol != null) {
					inner.target_type = analyzer.get_data_type_for_symbol ((TypeSymbol) base_property.parent_symbol);
				}
			} else if ((symbol_reference is Field
			            || symbol_reference is Signal)
			           && instance && symbol_reference.parent_symbol != null) {
				inner.target_type = analyzer.get_data_type_for_symbol ((TypeSymbol) symbol_reference.parent_symbol);
			}
		}

		return !error;
	}

	public override void get_defined_variables (Collection<LocalVariable> collection) {
		if (inner != null) {
			inner.get_defined_variables (collection);
		}
	}

	public override void get_used_variables (Collection<LocalVariable> collection) {
		if (inner != null) {
			inner.get_used_variables (collection);
		}
		var local = symbol_reference as LocalVariable;
		if (local != null) {
			collection.add (local);
		}
	}
}
