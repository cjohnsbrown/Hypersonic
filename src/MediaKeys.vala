

[DBus (name = "org.gnome.SettingsDaemon.MediaKeys")]
internal interface Gnome.MediaKeys : Object {
    public abstract void grab_media_player_keys (string application,
                                                 uint   time) throws Error;
    public abstract void release_media_player_keys (string application)
                                                    throws Error;

    public signal void media_player_key_pressed (string application,
                                                 string key);
}

public class MediaKeys : Object {
    private Gnome.MediaKeys keys;

	private PlaybackView view;

    public MediaKeys (PlaybackView view) {
		this.view = view;
        try {
            this.keys = Bus.get_proxy_sync (BusType.SESSION,
                                            "org.gnome.SettingsDaemon",
                                            "/org/gnome/SettingsDaemon/MediaKeys");
            this.keys.grab_media_player_keys ("hypersonic", 0);
            this.keys.media_player_key_pressed.connect (this.on_key_pressed);
        } catch (Error error) {
            message ("Failed to connect to media keys: %s", error.message);
        }
    }

    ~MediaKeys () {
        if (this.keys != null) {
            try {
                this.keys.release_media_player_keys ("hypersonic");
            } catch (Error error) { };
        }
    }

    private void on_key_pressed (string application, string key) {
        if (application != "hypersonic") {
            return;
        }

        switch (key) {
            case "Play":
                view.on_pause_clicked();
                break;
            case "Pause":
                view.on_pause_clicked();
                break;
            //case "Stop":
                //this.stop ();
                //break;
            case "Next":
                view.on_next_clicked();
                break;
            case "Previous":
                view.on_prev_clicked();
                break;
            default:
                break;
        }
    }
}
