public class Song : Object{ 

	public string title {get; private set;}
	public string artist {get; private set;}
	public string album {get; private set;}
	public string length {get; private set;}
	public string id {get; private set;}
	public int64 seconds {get; private set;}
	public Gtk.TreePath treePath {get; set;}

	public Song( Json.Node t, string artist, Json.Node a, int64 seconds, int64 id) {
		if (t.type_name() == "Integer")
			this.title = t.get_int().to_string();
		else
			this.title = t.get_string();
		this.artist = artist;
		if (a.type_name() == "Integer")
			this.album = a.get_int().to_string();
		else
			this.album = a.get_string();
		this.seconds = seconds;
		int64 mintutes = seconds / 60;
	 	seconds = seconds % 60;
		length = seconds.to_string();
		if (seconds < 10) 
			length = "0" + length;
		length = mintutes.to_string() + ":" + length;
		this.id = id.to_string();
	}

	public string to_string() {
		return artist + " - " + title;
	}

}	


