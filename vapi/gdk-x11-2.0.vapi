/* gdk-x11-2.0.vapi generated by lt-vapigen, do not modify. */

[CCode (cprefix = "Gdk", lower_case_cprefix = "gdk_")]
namespace Gdk {
	[CCode (cname = "gdkx_visual_get")]
	public static weak Gdk.Visual x11_visual_get (uint32 xvisualid);
	[CCode (cname = "gdk_net_wm_supports")]
	public static bool x11_net_wm_supports (Gdk.Atom property);
	public static Gdk.Atom x11_atom_to_xatom (Gdk.Atom atom);
	public static Gdk.Atom x11_atom_to_xatom_for_display (Gdk.Display display, Gdk.Atom atom);
	public static weak Gdk.Colormap x11_colormap_foreign_new (Gdk.Visual visual, Gdk.Colormap xcolormap);
	public static weak Gdk.Colormap x11_colormap_get_xcolormap (Gdk.Colormap colormap);
	public static pointer x11_colormap_get_xdisplay (Gdk.Colormap colormap);
	public static weak Gdk.Cursor x11_cursor_get_xcursor (Gdk.Cursor cursor);
	public static pointer x11_cursor_get_xdisplay (Gdk.Cursor cursor);
	public static void x11_display_broadcast_startup_message (Gdk.Display display, string message_type);
	public static weak string x11_display_get_startup_notification_id (Gdk.Display display);
	public static uint x11_display_get_user_time (Gdk.Display display);
	public static pointer x11_display_get_xdisplay (Gdk.Display display);
	public static void x11_display_grab (Gdk.Display display);
	public static void x11_display_set_cursor_theme (Gdk.Display display, string theme, int size);
	public static void x11_display_ungrab (Gdk.Display display);
	public static pointer x11_drawable_get_xdisplay (Gdk.Drawable drawable);
	public static uint32 x11_drawable_get_xid (Gdk.Drawable drawable);
	public static pointer x11_gc_get_xdisplay (Gdk.GC gc);
	public static pointer x11_gc_get_xgc (Gdk.GC gc);
	public static weak Gdk.Window x11_get_default_root_xwindow ();
	public static int x11_get_default_screen ();
	public static pointer x11_get_default_xdisplay ();
	public static uint x11_get_server_time (Gdk.Window window);
	public static Gdk.Atom x11_get_xatom_by_name (string atom_name);
	public static Gdk.Atom x11_get_xatom_by_name_for_display (Gdk.Display display, string atom_name);
	public static weak string x11_get_xatom_name (Gdk.Atom xatom);
	public static weak string x11_get_xatom_name_for_display (Gdk.Display display, Gdk.Atom xatom);
	public static void x11_grab_server ();
	public static pointer x11_image_get_xdisplay (Gdk.Image image);
	public static pointer x11_image_get_ximage (Gdk.Image image);
	public static weak Gdk.Display x11_lookup_xdisplay (pointer xdisplay);
	public static void x11_register_standard_event_type (Gdk.Display display, int event_base, int n_events);
	public static int x11_screen_get_screen_number (Gdk.Screen screen);
	public static weak string x11_screen_get_window_manager_name (Gdk.Screen screen);
	public static weak Gdk.Screen x11_screen_get_xscreen (Gdk.Screen screen);
	public static weak Gdk.Visual x11_screen_lookup_visual (Gdk.Screen screen, uint32 xvisualid);
	public static bool x11_screen_supports_net_wm_hint (Gdk.Screen screen, Gdk.Atom property);
	public static void x11_ungrab_server ();
	public static weak Gdk.Visual x11_visual_get_xvisual (Gdk.Visual visual);
	public static void x11_window_move_to_current_desktop (Gdk.Window window);
	public static void x11_window_set_user_time (Gdk.Window window, uint timestamp);
	public static Gdk.Atom x11_xatom_to_atom (Gdk.Atom xatom);
	public static Gdk.Atom x11_xatom_to_atom_for_display (Gdk.Display display, Gdk.Atom xatom);
	[CCode (cname = "gdk_xid_table_lookup")]
	public static pointer x11_xid_table_lookup (uint32 xid);
	[CCode (cname = "gdk_xid_table_lookup_for_display")]
	public static pointer x11_xid_table_lookup_for_display (Gdk.Display display, uint32 xid);
}