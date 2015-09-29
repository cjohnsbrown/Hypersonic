// modules: Gee json-glib-1.0
using Gee;
using Json;
using Notify;

public class PlaybackModel : GLib.Object {
	
	private Proxy proxy;
	private StreamPlayer player;
	public PlaybackView view {get; private set;}
	private Notify.Notification notification = new Notify.Notification("", "", null);
	public ArrayList<Song> songs {get; private set; default = new ArrayList<Song>();}

	private int nowPlaying;
	private HashMap<int,int> played = new HashMap<int,int>();
	private HashMap<int,int> nextMap = new HashMap<int,int>();
	public bool shuffled = false;
	public bool paused {get; private set; default = true;}
	public Gtk.Adjustment sliderAdj;


	public PlaybackModel(Proxy p) {
		proxy = p;
		view = new PlaybackView(this);
		view.show_all();
	   	player = new StreamPlayer(this, proxy.server, proxy.parameters);
		try {
			Thread<int> tree = new Thread<int>.try("tree", get_library);
			Thread<int> updater = new Thread<int>.try("up", update_posistion);
		} catch (ThreadError e) {
				stderr.printf("%s\n", e.message);
		}

	 }

	private int get_library() {
		string artistsJson = proxy.get_json("getArtists.view?");
		var artistIds = new ArrayList<string>();
		var albumIds = new ArrayList<string>();
		var parser = new Parser();
		try {
			parser.load_from_data(artistsJson, -1);
			var root = parser.get_root().get_object();
			var response = root.get_object_member("subsonic-response");
			var artists = response.get_object_member("artists");
			var index = artists.get_array_member("index");
			for(int i=0; i<index.get_length(); i++) {
				var node = index.get_object_element(i);
				var letter = node.get_member("artist");
				if (letter.get_node_type() == NodeType.ARRAY) {
					var artist = letter.get_array();
					foreach (var id in artist.get_elements()) {
						 artistIds.add(id.get_object().get_int_member("id").to_string());
					}
				} else {
					artistIds.add(letter.get_object().get_int_member("id").to_string());
				}
			}
		} catch (Error e) {
			stderr.printf("Error in parsing Json\n");
		}
		foreach (var id in artistIds) {
			string albumsJson = proxy.get_json(@"getArtist.view?id=$id&");
			try {
				parser.load_from_data(albumsJson, -1);
				var response = parser.get_root().get_object().get_object_member("subsonic-response");
				var artist =  response.get_object_member("artist");
				var node = artist.get_member("album");
				if (node.get_node_type() == NodeType.ARRAY) {
					var albums = node.get_array();
					foreach (var albumId in albums.get_elements()) {
						albumIds.add(albumId.get_object().get_int_member("id").to_string());
					}
				} else {
					albumIds.add(node.get_object().get_int_member("id").to_string());
				}
			} catch (Error e) {
				stderr.printf("Error in parser Json\n");
			}
		}
		Song song;
		foreach (var albumId in albumIds) {
			string songJson = proxy.get_json(@"getAlbum.view?id=$albumId&");
			try {
				parser.load_from_data(songJson);
				var response = parser.get_root().get_object().get_object_member("subsonic-response");
				var album = response.get_object_member("album");
				var s = album.get_member("song");
				if (s.get_node_type() == NodeType.ARRAY) {
					var songs = album.get_array_member("song");
					for (int i=0; i < songs.get_length(); i++) {
						var node = songs.get_object_element(i);
						song = new Song(node.get_member("title"),
									node.get_string_member("artist"),
									node.get_member("album"),
									node.get_int_member("duration"),
									node.get_int_member("id"));
						this.songs.add(song);
					}
				} else {
					var node = s.get_object();
					song = new Song(node.get_member("title"),
									node.get_string_member("artist"),
									node.get_member("album"),
									node.get_int_member("duration"),
									node.get_int_member("id"));
						this.songs.add(song);
				}

			} catch (Error e) {
				stderr.printf("Error in parsing Json\n");
			}
		
		}
		view.setup_treeview();
		return 0;
	}

	public void close() {
		player.close();
	}

	public void pause() {
		if (paused)
			player.resume();
		else
			player.pause();
		paused = !paused;
	}

	public string manualStart(int index) {
		if (shuffled) {
			played.clear();
			nextMap.clear();
			played.set(index, -1);
		}
		return startSong(index);
	}



	public string startSong(int index) {
		paused = false;
		var s = songs[index];
		nowPlaying = index;
		player.stop();
		sliderAdj.value = 0;
		sliderAdj.upper = s.seconds*1000;
		try {
			notification.update(s.to_string(), s.album, null);
			notification.show();
		} catch (Error e) {}
		player.play(s);
		return s.to_string();
	}
	
	public string prev_song() {
		if (!shuffled) {
			nowPlaying--;
			if (nowPlaying >= 0) {
				view.move_cursor(songs[nowPlaying].treePath);
				return startSong(nowPlaying);
			} else
				player.stop();	
		} else {
			var i = played.get(nowPlaying);
			if (i != -1) {
				nowPlaying = i;
				view.move_cursor(songs[nowPlaying].treePath);
			}
			return startSong(nowPlaying);
		}
		return "Subparsonic";
	}

	public string next_song() {
		if (!shuffled) {
			nowPlaying++;
			if (nowPlaying < songs.size) {
				view.move_cursor(songs[nowPlaying].treePath);
				return startSong(nowPlaying);
			}
		} else {
			if (nextMap.has_key(nowPlaying)) {
				nowPlaying = nextMap.get(nowPlaying);
			} else {
				if (played.size != songs.size) {
		   			var r = get_shuffled_song();
					if (played.size == 0)
						played.set(r, -1);
					else {
						played.set(r, nowPlaying);
						nextMap.set(nowPlaying, r);
					}
					nowPlaying = r;
				}
			}
			view.move_cursor(songs[nowPlaying].treePath);
			return startSong(nowPlaying);
		}
		return "Subparsonic";
	}

	public void shuffle() {
		if (shuffled) {
			played.clear();
			nextMap.clear();
		}
		shuffled = !shuffled;
	}

	public void seek(double mseconds) {
		player.seek( (int) mseconds);
	}


	public void set_volume(double vol) {
		player.set_volume(vol);
	}

	public double get_volume() {
		return player.get_volume();
	}

	private int update_posistion() {
		while (true) {
			sliderAdj.value = player.get_position();
			Thread.usleep(125000);
		}
	}

	private int get_shuffled_song() {
		var r = Random.int_range(0, songs.size-1);
		while (played.has_key(r))
			r = Random.int_range(0, songs.size-1);
		return r;
	}
}
	

