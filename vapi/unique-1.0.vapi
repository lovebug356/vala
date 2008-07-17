/* unique-1.0.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Unique", lower_case_cprefix = "unique_")]
namespace Unique {
	[CCode (cprefix = "UNIQUE_", has_type_id = "0", cheader_filename = "unique/unique.h")]
	public enum Command {
		INVALID,
		ACTIVATE,
		NEW,
		OPEN,
		CLOSE
	}
	[CCode (cprefix = "UNIQUE_RESPONSE_", has_type_id = "0", cheader_filename = "unique/unique.h")]
	public enum Response {
		INVALID,
		OK,
		CANCEL,
		FAIL
	}
	[Compact]
	[CCode (copy_function = "unique_message_data_copy", cheader_filename = "unique/unique.h")]
	public class MessageData {
		public Unique.MessageData copy ();
		public weak Gdk.Screen get_screen ();
		public weak string get_startup_id ();
		public string get_text ();
		[NoArrayLength]
		public string[] get_uris ();
		public uint get_workspace ();
		public MessageData ();
		public void set (uchar[] data, ulong length);
		public bool set_text (string str, long length);
		[NoArrayLength]
		public bool set_uris (string[] uris);
	}
	[CCode (cheader_filename = "unique/unique.h")]
	public class App : GLib.Object {
		public void add_command (string command_name, int command_id);
		public App (string name, string startup_id);
		public App.with_commands (string name, string startup_id, ...);
		public Unique.Response send_message (int command_id, Unique.MessageData? message_data);
		public void watch_window (Gtk.Window window);
		[NoAccessorMethod]
		public bool is_running { get; }
		[NoAccessorMethod]
		public string name { get; construct; }
		[NoAccessorMethod]
		public Gdk.Screen screen { get; set construct; }
		[NoAccessorMethod]
		public string startup_id { get; construct; }
		public virtual signal Unique.Response message_received (int command, Unique.MessageData message_data, uint time_);
	}
	[CCode (cheader_filename = "unique/unique.h")]
	public class Backend : GLib.Object {
		public weak Unique.App parent;
		public weak string name;
		public weak string startup_id;
		public weak Gdk.Screen screen;
		public uint workspace;
		public static weak Unique.Backend create ();
		public weak string get_name ();
		public weak Gdk.Screen get_screen ();
		public weak string get_startup_id ();
		public uint get_workspace ();
		public void set_name (string name);
		public void set_screen (Gdk.Screen screen);
		public void set_startup_id (string startup_id);
		public virtual bool request_name ();
		public virtual Unique.Response send_message (int command_id, Unique.MessageData message_data, uint time_);
	}
	[CCode (cheader_filename = "unique/unique.h")]
	public const string API_VERSION_S;
	[CCode (cheader_filename = "unique/unique.h")]
	public const string DEFAULT_BACKEND_S;
	[CCode (cheader_filename = "unique/unique.h")]
	public const int MAJOR_VERSION;
	[CCode (cheader_filename = "unique/unique.h")]
	public const int MICRO_VERSION;
	[CCode (cheader_filename = "unique/unique.h")]
	public const int MINOR_VERSION;
	[CCode (cheader_filename = "unique/unique.h")]
	public const string PROTOCOL_VERSION_S;
	[CCode (cheader_filename = "unique/unique.h")]
	public const int VERSION_HEX;
	[CCode (cheader_filename = "unique/unique.h")]
	public const string VERSION_S;
}