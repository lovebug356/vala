/* webkit-1.0.vapi generated by lt-vapigen, do not modify. */

[CCode (cprefix = "WebKit", lower_case_cprefix = "webkit_")]
namespace WebKit {
	[CCode (cprefix = "WEBKIT_NAVIGATION_RESPONSE_", cheader_filename = "webkit/webkit.h")]
	public enum NavigationResponse {
		ACCEPT,
		IGNORE,
		DOWNLOAD,
	}
	[CCode (cprefix = "WEBKIT_WEB_VIEW_TARGET_INFO_", cheader_filename = "webkit/webkit.h")]
	public enum WebViewTargetInfo {
		HTML,
		TEXT,
	}
	[CCode (cheader_filename = "webkit/webkit.h")]
	public class NetworkRequest : GLib.Object {
		public weak string get_uri ();
		public NetworkRequest (string uri);
		public void set_uri (string uri);
	}
	[CCode (cheader_filename = "webkit/webkit.h")]
	public class WebBackForwardList : GLib.Object {
		public bool contains_item (WebKit.WebHistoryItem history_item);
		public weak WebKit.WebHistoryItem get_back_item ();
		public int get_back_length ();
		public weak GLib.List get_back_list_with_limit (int limit);
		public weak WebKit.WebHistoryItem get_current_item ();
		public weak WebKit.WebHistoryItem get_forward_item ();
		public int get_forward_length ();
		public weak GLib.List get_forward_list_with_limit (int limit);
		public int get_limit ();
		public weak WebKit.WebHistoryItem get_nth_item (int index);
		public void go_back ();
		public void go_forward ();
		public void go_to_item (WebKit.WebHistoryItem history_item);
		public WebBackForwardList.with_web_view (WebKit.WebView web_view);
		public void set_limit (int limit);
	}
	[CCode (cheader_filename = "webkit/webkit.h")]
	public class WebFrame : GLib.Object {
		public weak WebKit.WebFrame find_frame (string name);
		public weak string get_name ();
		public weak WebKit.WebFrame get_parent ();
		public weak string get_title ();
		public weak string get_uri ();
		public weak WebKit.WebView get_web_view ();
		public void load_request (WebKit.NetworkRequest request);
		public WebFrame (WebKit.WebView web_view);
		public void reload ();
		public void stop_loading ();
		public weak string name { get; }
		public weak string title { get; }
		public weak string uri { get; }
		public signal void cleared ();
		public signal void hovering_over_link (string p0, string p1);
		public signal void load_committed ();
		public signal void load_done (bool p0);
		public signal void title_changed (string p0);
	}
	[CCode (cheader_filename = "webkit/webkit.h")]
	public class WebHistoryItem : GLib.Object {
		public weak string get_alternate_title ();
		public double get_last_visited_time ();
		public weak string get_original_uri ();
		public weak string get_title ();
		public weak string get_uri ();
		public WebHistoryItem ();
		public WebHistoryItem.with_data (string uri, string title);
		public void set_alternate_title (string title);
	}
	[CCode (cheader_filename = "webkit/webkit.h")]
	public class WebSettings : GLib.Object {
		public weak WebKit.WebSettings copy ();
		public WebSettings ();
		[NoAccessorMethod]
		public weak bool auto_load_images { get; set construct; }
		[NoAccessorMethod]
		public weak bool auto_shrink_images { get; set construct; }
		[NoAccessorMethod]
		public weak string cursive_font_family { get; set construct; }
		[NoAccessorMethod]
		public weak string default_encoding { get; set construct; }
		[NoAccessorMethod]
		public weak string default_font_family { get; set construct; }
		[NoAccessorMethod]
		public weak int default_font_size { get; set construct; }
		[NoAccessorMethod]
		public weak int default_monospace_font_size { get; set construct; }
		[NoAccessorMethod]
		public weak bool enable_plugins { get; set construct; }
		[NoAccessorMethod]
		public weak bool enable_scripts { get; set construct; }
		[NoAccessorMethod]
		public weak string fantasy_font_family { get; set construct; }
		[NoAccessorMethod]
		public weak int minimum_font_size { get; set construct; }
		[NoAccessorMethod]
		public weak int minimum_logical_font_size { get; set construct; }
		[NoAccessorMethod]
		public weak string monospace_font_family { get; set construct; }
		[NoAccessorMethod]
		public weak bool print_backgrounds { get; set construct; }
		[NoAccessorMethod]
		public weak bool resizable_text_areas { get; set construct; }
		[NoAccessorMethod]
		public weak string sans_serif_font_family { get; set construct; }
		[NoAccessorMethod]
		public weak string serif_font_family { get; set construct; }
		[NoAccessorMethod]
		public weak string user_stylesheet_uri { get; set construct; }
	}
	[CCode (cheader_filename = "webkit/webkit.h")]
	public class WebView : Gtk.Container, Atk.Implementor, Gtk.Buildable {
		public bool can_copy_clipboard ();
		public bool can_cut_clipboard ();
		public bool can_go_back ();
		public bool can_go_back_or_forward (int steps);
		public bool can_go_backward ();
		public bool can_go_forward ();
		public bool can_paste_clipboard ();
		public void delete_selection ();
		public void execute_script (string script);
		public weak WebKit.WebBackForwardList get_back_forward_list ();
		public weak Gtk.TargetList get_copy_target_list ();
		public bool get_editable ();
		public weak WebKit.WebFrame get_main_frame ();
		public weak Gtk.TargetList get_paste_target_list ();
		public weak WebKit.WebSettings get_settings ();
		public void go_back ();
		public void go_back_or_forward (int steps);
		public void go_backward ();
		public void go_forward ();
		public bool go_to_back_forward_item (WebKit.WebHistoryItem item);
		public bool has_selection ();
		public void load_html_string (string content, string base_uri);
		public void load_string (string content, string content_mime_type, string content_encoding, string base_uri);
		public uint mark_text_matches (string str, bool case_sensitive, uint limit);
		public WebView ();
		public void open (string uri);
		public void reload ();
		public bool search_text (string str, bool case_sensitive, bool forward, bool wrap);
		public void set_editable (bool flag);
		public void set_highlight_text_matches (bool highlight);
		public void set_maintains_back_forward_list (bool flag);
		public void set_settings (WebKit.WebSettings settings);
		public void stop_loading ();
		public void unmark_text_matches ();
		[NoWrapper]
		public virtual weak string choose_file (WebKit.WebFrame frame, string old_file);
		[NoWrapper]
		public virtual weak WebKit.WebView create_web_view ();
		public weak Gtk.TargetList copy_target_list { get; }
		public weak bool editable { get; set; }
		public weak Gtk.TargetList paste_target_list { get; }
		public weak WebKit.WebSettings settings { get; set; }
		public signal bool console_message (string message, int line_number, string source_id);
		[HasEmitter]
		public signal void copy_clipboard ();
		[HasEmitter]
		public signal void cut_clipboard ();
		public signal void hovering_over_link (string p0, string p1);
		public signal void icon_loaded ();
		public signal void load_committed (WebKit.WebFrame p0);
		public signal void load_finished (WebKit.WebFrame p0);
		public signal void load_progress_changed (int p0);
		public signal void load_started (WebKit.WebFrame p0);
		public signal int navigation_requested (GLib.Object frame, GLib.Object request);
		[HasEmitter]
		public signal void paste_clipboard ();
		public signal void populate_popup (Gtk.Menu p0);
		public signal bool script_alert (GLib.Object frame, string alert_message);
		public signal bool script_confirm (GLib.Object frame, string confirm_message, bool did_confirm);
		public signal bool script_prompt (GLib.Object frame, string message, string default_value, pointer value);
		[HasEmitter]
		public signal void select_all ();
		public signal void selection_changed ();
		public signal void set_scroll_adjustments (Gtk.Adjustment p0, Gtk.Adjustment p1);
		public signal void status_bar_text_changed (string p0);
		public signal void title_changed (WebKit.WebFrame p0, string p1);
		public signal void window_object_cleared (WebKit.WebFrame frame, pointer context, pointer window_object);
	}
}
