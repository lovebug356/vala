/* json-glib-1.0.vapi generated by lt-vapigen, do not modify. */

[CCode (cprefix = "Json", lower_case_cprefix = "json_")]
namespace Json {
	[CCode (cprefix = "JSON_NODE_", cheader_filename = "json-glib/json-glib.h")]
	public enum NodeType {
		OBJECT,
		ARRAY,
		VALUE,
		NULL,
	}
	[CCode (cprefix = "JSON_PARSER_ERROR_", cheader_filename = "json-glib/json-glib.h")]
	public enum ParserError {
		PARSE,
		UNKNOWN,
	}
	[CCode (cprefix = "JSON_TOKEN_", cheader_filename = "json-glib/json-glib.h")]
	public enum TokenType {
		INVALID,
		TRUE,
		FALSE,
		NULL,
		VAR,
		LAST,
	}
	[CCode (ref_function = "json_array_ref", unref_function = "json_array_unref", cheader_filename = "json-glib/json-glib.h")]
	public class Array : GLib.Boxed {
		public void add_element (Json.Node node);
		public weak Json.Node get_element (uint index_);
		public weak GLib.List get_elements ();
		public uint get_length ();
		public Array ();
		public void remove_element (uint index_);
		public static weak Json.Array sized_new (uint n_elements);
	}
	[CCode (copy_function = "json_node_copy", cheader_filename = "json-glib/json-glib.h")]
	public class Node : GLib.Boxed {
		public Json.NodeType type;
		public pointer data;
		public weak Json.Node parent;
		public weak Json.Node copy ();
		public weak Json.Array dup_array ();
		public weak Json.Object dup_object ();
		public weak string dup_string ();
		public weak Json.Array get_array ();
		public bool get_boolean ();
		public double get_double ();
		public int get_int ();
		public weak Json.Object get_object ();
		public weak Json.Node get_parent ();
		public weak string get_string ();
		public void get_value (GLib.Value value);
		public GLib.Type get_value_type ();
		public Node (Json.NodeType type);
		public void set_array (Json.Array array);
		public void set_boolean (bool value);
		public void set_double (double value);
		public void set_int (int value);
		public void set_object (Json.Object object);
		public void set_string (string value);
		public void set_value (GLib.Value value);
		public void take_array (Json.Array array);
		public void take_object (Json.Object object);
		public weak string type_name ();
	}
	[CCode (ref_function = "json_object_ref", unref_function = "json_object_unref", cheader_filename = "json-glib/json-glib.h")]
	public class Object : GLib.Boxed {
		public void add_member (string member_name, Json.Node node);
		public weak Json.Node get_member (string member_name);
		public weak GLib.List get_members ();
		public uint get_size ();
		public weak GLib.List get_values ();
		public bool has_member (string member_name);
		public Object ();
		public void remove_member (string member_name);
	}
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public class Generator : GLib.Object {
		public Generator ();
		public void set_root (Json.Node node);
		public weak string to_data (ulong length);
		public bool to_file (string filename) throws GLib.Error;
		[NoAccessorMethod]
		public weak uint indent { get; set; }
		[NoAccessorMethod]
		public weak bool pretty { get; set; }
		[NoAccessorMethod]
		public weak Json.Node root { get; set; }
	}
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public class Parser : GLib.Object {
		public static GLib.Quark error_quark ();
		public uint get_current_line ();
		public uint get_current_pos ();
		public weak Json.Node get_root ();
		public bool has_assignment (string variable_name);
		public bool load_from_data (string data, ulong length) throws GLib.Error;
		public bool load_from_file (string filename) throws GLib.Error;
		public Parser ();
		public signal void array_element (Json.Array array, int index_);
		public signal void array_end (Json.Array array);
		public signal void array_start ();
		public signal void error (pointer error);
		public signal void object_end (Json.Object object);
		public signal void object_member (Json.Object object, string member_name);
		public signal void object_start ();
		public signal void parse_end ();
		public signal void parse_start ();
	}
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public interface Serializable {
		public abstract bool deserialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec, Json.Node property_node);
		public abstract weak Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec);
	}
	public const int MAJOR_VERSION;
	public const int MICRO_VERSION;
	public const int MINOR_VERSION;
	public const int VERSION_HEX;
	public const string VERSION_S;
	public static weak GLib.Object construct_gobject (GLib.Type gtype, string data, ulong length) throws GLib.Error;
	public static weak string serialize_gobject (GLib.Object gobject, ulong length);
}