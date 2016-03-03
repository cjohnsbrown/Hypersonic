// modules: Gst
using Gst;

public class StreamPlayer {

	private PlaybackModel model;
	private string server;
	private string parameters;
    	private Element player = ElementFactory.make ("playbin2", "play");

	public StreamPlayer(PlaybackModel model, string server, string parameters) {
		this.model = model;
		this.server = server;
		this.parameters = parameters;
		Gst.Bus bus = player.get_bus ();
		bus.add_watch (bus_callback);
		
	}

    

	private bool bus_callback (Gst.Bus bus, Gst.Message message) {
		if (message.type == MessageType.ERROR) {
			GLib.Error err;
			string debug;
			message.parse_error (out err, out debug);
		} else if (message.type == MessageType.EOS) {
			model.next_song();
		}

		return true;
	}

	



    public void play (Song song) {
		string id = song.id;
        string uri = server + @"stream.view?id=$id&" + parameters;
		player.set("uri", uri);
		player.set_state (State.PLAYING);
		
    }
	
	public double get_volume() {
		var vol = GLib.Value (typeof(double)); 
		player.get_property("volume", ref vol);
		return (double)vol;
	}

	public void set_volume(double vol) {
		player.set_property("volume", vol);
	}

	public void seek(int mseconds) {
		player.seek_simple(Format.TIME, SeekFlags.FLUSH | SeekFlags.KEY_UNIT, mseconds*MSECOND);
	}

	public void stop() {
		player.set_state(State.READY);
	}

	public void resume() {
		player.set_state(State.PLAYING);
	}

	public void pause() {
		player.set_state(State.PAUSED);
	}

	public double get_position() {
		var format = Format.TIME;
		int64 pos;
		State s;
		player.get_state(out s, null, CLOCK_TIME_NONE);
		if (s == State.PLAYING || s == State.PAUSED) {
			player.query_position(ref format, out pos);
			return pos/MSECOND;
		}
		return 0;
	}
	public void close() {
		set_volume(1);
		player.set_state(State.NULL);
		player = null;
	}
}




