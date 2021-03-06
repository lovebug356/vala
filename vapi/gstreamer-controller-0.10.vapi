/* gstreamer-controller-0.10.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Gst", lower_case_cprefix = "gst_")]
namespace Gst {
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public class ControlSource : GLib.Object {
		public bool bound;
		public bool bind (GLib.ParamSpec pspec);
		public bool get_value (Gst.ClockTime timestamp, Gst.Value value);
		public bool get_value_array (Gst.ClockTime timestamp, Gst.ValueArray value_array);
	}
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public class Controller : GLib.Object {
		public weak GLib.Mutex @lock;
		public weak GLib.Object object;
		public weak GLib.List properties;
		[CCode (has_construct_function = false)]
		public Controller (GLib.Object object);
		public Gst.Value @get (string property_name, Gst.ClockTime timestamp);
		public unowned GLib.List get_all (string property_name);
		public unowned Gst.ControlSource get_control_source (string property_name);
		public bool get_value_array (Gst.ClockTime timestamp, Gst.ValueArray value_array);
		public bool get_value_arrays (Gst.ClockTime timestamp, GLib.SList value_arrays);
		public static bool init (int argc, out unowned string argv);
		[CCode (has_construct_function = false)]
		public Controller.list (GLib.Object object, GLib.List list);
		public bool remove_properties ();
		public bool remove_properties_list (GLib.List list);
		public bool remove_properties_valist (void* var_args);
		public bool @set (string property_name, Gst.ClockTime timestamp, Gst.Value value);
		public bool set_control_source (string property_name, Gst.ControlSource csource);
		public void set_disabled (bool disabled);
		public bool set_from_list (string property_name, GLib.SList timedvalues);
		public bool set_interpolation_mode (string property_name, Gst.InterpolateMode mode);
		public void set_property_disabled (string property_name, bool disabled);
		public Gst.ClockTime suggest_next_sync ();
		public bool sync_values (Gst.ClockTime timestamp);
		public bool unset (string property_name, Gst.ClockTime timestamp);
		public bool unset_all (string property_name);
		[CCode (has_construct_function = false)]
		public Controller.valist (GLib.Object object, void* var_args);
		[NoAccessorMethod]
		public uint64 control_rate { get; set; }
	}
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public class InterpolationControlSource : Gst.ControlSource {
		public weak GLib.Mutex @lock;
		[CCode (has_construct_function = false)]
		public InterpolationControlSource ();
		public unowned GLib.List get_all ();
		public int get_count ();
		public bool @set (Gst.ClockTime timestamp, Gst.Value value);
		public bool set_from_list (GLib.SList timedvalues);
		public bool set_interpolation_mode (Gst.InterpolateMode mode);
		public bool unset (Gst.ClockTime timestamp);
		public void unset_all ();
	}
	[CCode (cheader_filename = "gst/controller/gstlfocontrolsource.h")]
	public class LFOControlSource : Gst.ControlSource {
		public weak GLib.Mutex @lock;
		[CCode (has_construct_function = false)]
		public LFOControlSource ();
		[NoAccessorMethod]
		public Gst.Value amplitude { get; set; }
		[NoAccessorMethod]
		public double frequency { get; set; }
		[NoAccessorMethod]
		public Gst.Value offset { get; set; }
		[NoAccessorMethod]
		public uint64 timeshift { get; set; }
		[NoAccessorMethod]
		public Gst.LFOWaveform waveform { get; set; }
	}
	[Compact]
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public class TimedValue {
		public Gst.ClockTime timestamp;
		public Gst.Value value;
	}
	[Compact]
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public class ValueArray {
		public int nbsamples;
		public weak string property_name;
		public Gst.ClockTime sample_interval;
		public void* values;
	}
	[CCode (cprefix = "GST_INTERPOLATE_", has_type_id = "0", cheader_filename = "gst/controller/gstcontroller.h")]
	public enum InterpolateMode {
		NONE,
		TRIGGER,
		LINEAR,
		QUADRATIC,
		CUBIC,
		USER
	}
	[CCode (cprefix = "", cheader_filename = "gst/controller/gstlfocontrolsource.h")]
	public enum LFOWaveform {
		Sine waveform (default),
		Square waveform,
		Saw waveform,
		Reverse saw waveform,
		Triangle waveform
	}
	[CCode (cheader_filename = "gst/controller/gstcontroller.h", has_target = false)]
	public delegate bool ControlSourceBind (Gst.ControlSource _self, GLib.ParamSpec pspec);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h", has_target = false)]
	public delegate bool ControlSourceGetValue (Gst.ControlSource _self, Gst.ClockTime timestamp, Gst.Value value);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h", has_target = false)]
	public delegate bool ControlSourceGetValueArray (Gst.ControlSource _self, Gst.ClockTime timestamp, Gst.ValueArray value_array);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static unowned Gst.Controller object_control_properties (GLib.Object object);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static Gst.ClockTime object_get_control_rate (GLib.Object object);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static unowned Gst.ControlSource object_get_control_source (GLib.Object object, string property_name);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static unowned Gst.Controller object_get_controller (GLib.Object object);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static bool object_get_value_array (GLib.Object object, Gst.ClockTime timestamp, Gst.ValueArray value_array);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static bool object_get_value_arrays (GLib.Object object, Gst.ClockTime timestamp, GLib.SList value_arrays);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static void object_set_control_rate (GLib.Object object, Gst.ClockTime control_rate);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static bool object_set_control_source (GLib.Object object, string property_name, Gst.ControlSource csource);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static bool object_set_controller (GLib.Object object, Gst.Controller controller);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static Gst.ClockTime object_suggest_next_sync (GLib.Object object);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static bool object_sync_values (GLib.Object object, Gst.ClockTime timestamp);
	[CCode (cheader_filename = "gst/controller/gstcontroller.h")]
	public static bool object_uncontrol_properties (GLib.Object object);
}
