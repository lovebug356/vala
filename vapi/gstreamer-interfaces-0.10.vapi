/* gstreamer-interfaces-0.10.vapi generated by lt-vapigen, do not modify. */

[CCode (cprefix = "Gst", lower_case_cprefix = "gst_")]
namespace Gst {
	[CCode (cprefix = "GST_COLOR_BALANCE_", cheader_filename = "gst/gst.h")]
	public enum ColorBalanceType {
		HARDWARE,
		SOFTWARE,
	}
	[CCode (cprefix = "GST_MIXER_MESSAGE_", cheader_filename = "gst/gst.h")]
	public enum MixerMessageType {
		INVALID,
		MUTE_TOGGLED,
		RECORD_TOGGLED,
		VOLUME_CHANGED,
		OPTION_CHANGED,
	}
	[CCode (cprefix = "GST_MIXER_", cheader_filename = "gst/gst.h")]
	public enum MixerType {
		HARDWARE,
		SOFTWARE,
	}
	[CCode (cprefix = "GST_MIXER_FLAG_", cheader_filename = "gst/gst.h")]
	[Flags]
	public enum MixerFlags {
		NONE,
		AUTO_NOTIFICATIONS,
	}
	[CCode (cprefix = "GST_MIXER_TRACK_", cheader_filename = "gst/gst.h")]
	[Flags]
	public enum MixerTrackFlags {
		INPUT,
		OUTPUT,
		MUTE,
		RECORD,
		MASTER,
		SOFTWARE,
	}
	[CCode (cprefix = "GST_TUNER_CHANNEL_", cheader_filename = "gst/gst.h")]
	[Flags]
	public enum TunerChannelFlags {
		INPUT,
		OUTPUT,
		FREQUENCY,
		AUDIO,
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public class ColorBalanceChannel : GLib.Object {
		public weak string label;
		public int min_value;
		public int max_value;
		public signal void value_changed (int value);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public class MixerOptions : Gst.MixerTrack {
		public weak GLib.List values;
		public weak GLib.List get_values ();
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public class MixerTrack : GLib.Object {
		[NoAccessorMethod]
		public weak uint flags { get; }
		[NoAccessorMethod]
		public weak string label { get; }
		[NoAccessorMethod]
		public weak int max_volume { get; }
		[NoAccessorMethod]
		public weak int min_volume { get; }
		[NoAccessorMethod]
		public weak int num_channels { get; }
		[NoAccessorMethod]
		public weak string untranslated_label { get; construct; }
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public class TunerChannel : GLib.Object {
		public weak string label;
		public Gst.TunerChannelFlags flags;
		public float freq_multiplicator;
		public ulong min_frequency;
		public ulong max_frequency;
		public int min_signal;
		public int max_signal;
		public static void changed (Gst.Tuner tuner, Gst.TunerChannel channel);
		public signal void frequency_changed (ulong frequency);
		public signal void signal_changed (int @signal);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public class TunerNorm : GLib.Object {
		public weak string label;
		public weak GLib.Value framerate;
		public static void changed (Gst.Tuner tuner, Gst.TunerNorm norm);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public interface ColorBalance : Gst.ImplementsInterface, Gst.Element {
		public abstract int get_value (Gst.ColorBalanceChannel channel);
		public abstract weak GLib.List list_channels ();
		public abstract void set_value (Gst.ColorBalanceChannel channel, int value);
		[HasEmitter]
		public signal void value_changed (Gst.ColorBalanceChannel channel, int value);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public interface Mixer : Gst.ImplementsInterface, Gst.Element {
		public abstract Gst.MixerFlags get_mixer_flags ();
		public abstract weak string get_option (Gst.MixerOptions opts);
		public abstract void get_volume (Gst.MixerTrack track, int volumes);
		public abstract weak GLib.List list_tracks ();
		public static Gst.MixerMessageType message_get_type (Gst.Message message);
		public static void message_parse_mute_toggled (Gst.Message message, out weak Gst.MixerTrack track, bool mute);
		public static void message_parse_option_changed (Gst.Message message, out weak Gst.MixerOptions options, string value);
		public static void message_parse_record_toggled (Gst.Message message, out weak Gst.MixerTrack track, bool record);
		public static void message_parse_volume_changed (Gst.Message message, out weak Gst.MixerTrack track, int volumes, int num_channels);
		public abstract void mute_toggled (Gst.MixerTrack track, bool mute);
		public abstract void option_changed (Gst.MixerOptions opts, string value);
		public abstract void record_toggled (Gst.MixerTrack track, bool record);
		public abstract void set_mute (Gst.MixerTrack track, bool mute);
		public abstract void set_option (Gst.MixerOptions opts, string value);
		public abstract void set_record (Gst.MixerTrack track, bool record);
		public abstract void set_volume (Gst.MixerTrack track, int volumes);
		public abstract void volume_changed (Gst.MixerTrack track, int volumes);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public interface Navigation {
		public abstract void send_event (Gst.Structure structure);
		public void send_key_event (string event, string key);
		public void send_mouse_event (string event, int button, double x, double y);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public interface PropertyProbe {
		public abstract weak GLib.List get_properties ();
		public weak GLib.ParamSpec get_property (string name);
		public abstract GLib.ValueArray get_values (GLib.ParamSpec pspec);
		public GLib.ValueArray get_values_name (string name);
		public abstract bool needs_probe (GLib.ParamSpec pspec);
		public bool needs_probe_name (string name);
		public GLib.ValueArray probe_and_get_values (GLib.ParamSpec pspec);
		public GLib.ValueArray probe_and_get_values_name (string name);
		public abstract void probe_property (GLib.ParamSpec pspec);
		public void probe_property_name (string name);
		public signal void probe_needed (pointer pspec);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public interface Tuner : Gst.ImplementsInterface, Gst.Element {
		public weak Gst.TunerChannel find_channel_by_name (string channel);
		public weak Gst.TunerNorm find_norm_by_name (string norm);
		public abstract weak Gst.TunerChannel get_channel ();
		public abstract ulong get_frequency (Gst.TunerChannel channel);
		public abstract weak Gst.TunerNorm get_norm ();
		public abstract weak GLib.List list_channels ();
		public abstract weak GLib.List list_norms ();
		public abstract void set_channel (Gst.TunerChannel channel);
		public abstract void set_frequency (Gst.TunerChannel channel, ulong frequency);
		public abstract void set_norm (Gst.TunerNorm norm);
		public abstract int signal_strength (Gst.TunerChannel channel);
		public signal void channel_changed (Gst.TunerChannel channel);
		[HasEmitter]
		public signal void frequency_changed (Gst.TunerChannel channel, ulong frequency);
		public signal void norm_changed (Gst.TunerNorm norm);
		[HasEmitter]
		public signal void signal_changed (Gst.TunerChannel channel, int @signal);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public interface VideoOrientation : Gst.ImplementsInterface, Gst.Element {
		public abstract bool get_hcenter (int center);
		public abstract bool get_hflip (bool flip);
		public abstract bool get_vcenter (int center);
		public abstract bool get_vflip (bool flip);
		public abstract bool set_hcenter (int center);
		public abstract bool set_hflip (bool flip);
		public abstract bool set_vcenter (int center);
		public abstract bool set_vflip (bool flip);
	}
	[CCode (cheader_filename = "gst/gst.h")]
	public interface XOverlay : Gst.ImplementsInterface, Gst.Element {
		[CCode (cname = "gst_x_overlay_expose")]
		public abstract void expose ();
		[CCode (cname = "gst_x_overlay_got_xwindow_id")]
		public void got_xwindow_id (ulong xwindow_id);
		[CCode (cname = "gst_x_overlay_handle_events")]
		public abstract void handle_events (bool handle_events);
		[CCode (cname = "gst_x_overlay_prepare_xwindow_id")]
		public void prepare_xwindow_id ();
		[CCode (cname = "gst_x_overlay_set_xwindow_id")]
		public abstract void set_xwindow_id (ulong xwindow_id);
	}
}